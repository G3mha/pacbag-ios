import Anthropic from "@anthropic-ai/sdk";
import { CRISIS_MESSAGE, hasCrisisPhrase } from "./crisis.ts";
import { PHOTO_SYSTEM, TEXT_SYSTEM } from "./prompts.ts";
import { countCall } from "./quota.ts";

export const MAX_NAMES = 25;
export const MAX_CATEGORIES = 40;
export const MAX_NAME_CHARS = 120;
const MIN_GRAMS = 1;
const MAX_GRAMS = 100_000;

export type TextRequest = { items: { id: string; name: string }[]; categories: string[] };
export type PhotoRequest = { image: string; categories: string[]; nameLanguage: string };
export type Outcome =
  | { outcome: "ok"; items: FilledItem[] }
  | { outcome: "crisis"; message: string }
  | { outcome: "unusable" }
  | { outcome: "paused" };
export type FilledItem = {
  id: string; category: string | null; grams: number | null;
  name?: string | null; quantity?: number; documentKind?: string;
};

const range = (n: number) => Array.from({ length: n }, (_, i) => i);
const token = (i: number) => `c${String(i).padStart(2, "0")}`;
const categoryEnum = ["none", ...range(MAX_CATEGORIES).map(token)];
const grams = { type: ["integer", "null"] };
const signal = { type: "string", enum: ["none", "explicit"] };

const TEXT_SCHEMA = {
  type: "object", additionalProperties: false, required: ["items"],
  properties: { items: { type: "array", items: {
    type: "object", additionalProperties: false,
    required: ["id", "category", "grams", "self_harm_signal"],
    properties: { id: { type: "string", enum: range(MAX_NAMES).map(i => `i${i}`) },
                  category: { type: "string", enum: categoryEnum }, grams, self_harm_signal: signal },
  } } },
};

const PHOTO_SCHEMA = {
  type: "object", additionalProperties: false,
  required: ["document_kind", "name", "quantity", "category", "grams", "self_harm_signal"],
  properties: {
    document_kind: { type: "string", enum: ["none", "passport", "boarding_pass", "payment_card",
                                            "insurance_card", "drivers_licence", "other_document"] },
    name: { type: ["string", "null"] }, quantity: { type: "integer" },
    category: { type: "string", enum: categoryEnum }, grams, self_harm_signal: signal,
  },
};

/** One Claude call. Null means a refusal. Anything else unexpected throws, which the app retries later. */
export type Ask = (system: string, content: Anthropic.ContentBlockParam[], schema: object) => Promise<unknown | null>;

const client = process.env.FAKE_CLAUDE === "1" ? null : new Anthropic({ timeout: 45_000, maxRetries: 1 });
const MODEL = process.env.CLAUDE_MODEL ?? "claude-opus-5-5";

export const askClaude: Ask = async (system, content, schema) => {
  countCall();
  const response = await client!.messages.create({
    model: MODEL,
    max_tokens: 4096,
    system,
    messages: [{ role: "user", content }],
    inference_geo: "us",
    output_config: { effort: "low", format: { type: "json_schema", schema: schema as Record<string, unknown> } },
  });
  // Counts only, so the bill can be checked. Never the text.
  console.log("claude", MODEL, response.stop_reason, response.usage.input_tokens, response.usage.output_tokens);
  if (response.stop_reason === "refusal") return null;
  if (response.stop_reason === "max_tokens") throw new Error("output was cut off");
  const text = response.content.find(block => block.type === "text");
  if (!text || text.type !== "text") throw new Error("no text in the response");
  return JSON.parse(text.text);
};

/** Free stand-in for testing the whole path on a simulator. It never runs in a deployed server. */
export const askFake: Ask = async (_system, content, schema) => {
  if (schema === PHOTO_SCHEMA) {
    return { document_kind: "none", name: "Test backpack", quantity: 1, category: "c00", grams: 900, self_harm_signal: "none" };
  }
  const text = content.find(block => block.type === "text");
  const { items } = JSON.parse(text && text.type === "text" ? text.text : "{}") as { items: { id: string }[] };
  return { items: items.map(item => ({ id: item.id, category: "c00", grams: 450, self_harm_signal: "none" })) };
};

export const defaultAsk: Ask = client ? askClaude : askFake;

function catalogFor(categories: string[]) {
  // A category name is repeated on every request, so a phrase in one is dropped and never halts.
  return categories.filter(name => !hasCrisisPhrase(name)).slice(0, MAX_CATEGORIES)
    .map((name, i) => ({ token: token(i), name }));
}

const nameOf = (catalog: { token: string; name: string }[], picked: unknown) =>
  catalog.find(c => c.token === picked)?.name ?? null;
const cleanGrams = (value: unknown) =>
  typeof value === "number" && value >= MIN_GRAMS && value <= MAX_GRAMS ? Math.round(value) : null;

export async function fillText(request: TextRequest, ask: Ask = defaultAsk): Promise<Outcome> {
  if (request.items.some(item => hasCrisisPhrase(item.name))) {
    return { outcome: "crisis", message: CRISIS_MESSAGE };
  }
  const catalog = catalogFor(request.categories);
  const body = { categories: catalog, items: request.items.map((item, i) => ({ id: `i${i}`, name: item.name })) };
  const output = await ask(TEXT_SYSTEM, [{ type: "text", text: JSON.stringify(body) }], TEXT_SCHEMA) as
    { items: { id: string; category: string; grams: number | null; self_harm_signal: string }[] } | null;

  if (output === null) {
    if (request.items.length === 1) return { outcome: "unusable" };
    // One refused name shouldn't cost the names next to it, so they go one at a time.
    const singles = await Promise.all(request.items.map(item => fillText({ ...request, items: [item] }, ask)));
    const crisis = singles.find(single => single.outcome === "crisis");
    if (crisis) return crisis;
    return { outcome: "ok", items: singles.flatMap(single => single.outcome === "ok" ? single.items : []) };
  }
  if (output.items.some(item => item.self_harm_signal === "explicit")) {
    return { outcome: "crisis", message: CRISIS_MESSAGE };
  }
  const items: FilledItem[] = [];
  for (const item of output.items) {
    const original = request.items[Number(item.id.slice(1))];
    if (original) items.push({ id: original.id, category: nameOf(catalog, item.category), grams: cleanGrams(item.grams) });
  }
  return { outcome: "ok", items };
}

export async function fillPhoto(request: PhotoRequest, ask: Ask = defaultAsk): Promise<Outcome> {
  const catalog = catalogFor(request.categories);
  const output = await ask(PHOTO_SYSTEM, [
    { type: "image", source: { type: "base64", media_type: "image/jpeg", data: request.image } },
    { type: "text", text: JSON.stringify({ categories: catalog, name_language: request.nameLanguage }) },
  ], PHOTO_SCHEMA) as { document_kind: string; name: string | null; quantity: number; category: string;
                        grams: number | null; self_harm_signal: string } | null;
  if (output === null) return { outcome: "unusable" };
  if (output.self_harm_signal === "explicit" || (output.name && hasCrisisPhrase(output.name))) {
    return { outcome: "crisis", message: CRISIS_MESSAGE };
  }
  const isDocument = output.document_kind !== "none";
  return { outcome: "ok", items: [{
    id: "i0",
    name: isDocument ? null : output.name,
    quantity: Number.isInteger(output.quantity) && output.quantity >= 1 && output.quantity <= 99 ? output.quantity : 1,
    category: nameOf(catalog, output.category),
    grams: cleanGrams(output.grams),
    documentKind: output.document_kind,
  }] };
}
