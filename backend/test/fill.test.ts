import assert from "node:assert/strict";
import { test } from "node:test";
import { CRISIS_MESSAGE, hasCrisisPhrase } from "../src/crisis.ts";
import { fillPhoto, fillText, type Ask } from "../src/fill.ts";

const unreachable: Ask = async () => { throw new Error("the model must not run"); };

test("a crisis phrase gets the fixed text and never reaches the model", async () => {
  const result = await fillText({ items: [{ id: "a", name: "I want to die" }], categories: [] }, unreachable);
  assert.deepEqual(result, { outcome: "crisis", message: CRISIS_MESSAGE });
});

test("ordinary names that look close don't hit", () => {
  for (const name of ["killer heels", "10 kms socks", "tie dye shirt", "Suicide Squad t-shirt"]) {
    assert.equal(hasCrisisPhrase(name), false, name);
  }
});

test("the model's self-harm flag gives the fixed text and drops its output", async () => {
  const ask: Ask = async () => ({ items: [{ id: "i0", category: "c00", grams: 100, self_harm_signal: "explicit" }] });
  const result = await fillText({ items: [{ id: "a", name: "note" }], categories: ["General"] }, ask);
  assert.deepEqual(result, { outcome: "crisis", message: CRISIS_MESSAGE });
});

test("a category with a phrase is dropped without halting", async () => {
  const seen: string[] = [];
  const ask: Ask = async (_s, content) => {
    const block = content[0];
    seen.push(block.type === "text" ? block.text : "");
    return { items: [{ id: "i0", category: "c00", grams: 100, self_harm_signal: "none" }] };
  };
  const result = await fillText({ items: [{ id: "a", name: "socks" }], categories: ["I want to die", "Clothes"] }, ask);
  assert.equal(seen[0].includes("want to die"), false);
  assert.deepEqual(result, { outcome: "ok", items: [{ id: "a", category: "Clothes", grams: 100 }] });
});

test("a refused batch retries one name at a time and keeps the rest", async () => {
  const ask: Ask = async (_s, content) => {
    const block = content[0];
    const { items } = JSON.parse(block.type === "text" ? block.text : "{}");
    if (items.length > 1 || items[0].name === "pepper spray") return null;
    return { items: [{ id: "i0", category: "none", grams: 50, self_harm_signal: "none" }] };
  };
  const result = await fillText({ items: [{ id: "a", name: "pepper spray" }, { id: "b", name: "socks" }], categories: [] }, ask);
  assert.deepEqual(result, { outcome: "ok", items: [{ id: "b", category: null, grams: 50 }] });
});

test("an out of range weight comes back as unknown", async () => {
  const ask: Ask = async () => ({ items: [{ id: "i0", category: "none", grams: 9_000_000, self_harm_signal: "none" }] });
  const result = await fillText({ items: [{ id: "a", name: "piano" }], categories: [] }, ask);
  assert.deepEqual(result, { outcome: "ok", items: [{ id: "a", category: null, grams: null }] });
});

test("a photo of a document returns no name", async () => {
  const ask: Ask = async () => ({ document_kind: "passport", name: "Passport of Ana", quantity: 1, category: "none", grams: 30, self_harm_signal: "none" });
  const result = await fillPhoto({ image: "/9j/", categories: [], nameLanguage: "en" }, ask);
  assert.equal(result.outcome, "ok");
  if (result.outcome === "ok") {
    assert.equal(result.items[0].name, null);
    assert.equal(result.items[0].documentKind, "passport");
  }
});
