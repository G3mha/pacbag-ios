import { createServer, type IncomingMessage, type ServerResponse } from "node:http";
import { CRISIS_MESSAGE, hasCrisisPhrase } from "./crisis.ts";
import { fillPhoto, fillText, MAX_CATEGORIES, MAX_NAME_CHARS, MAX_NAMES } from "./fill.ts";
import { identify } from "./identity.ts";
import { isPaused, take } from "./quota.ts";

const MAX_BODY_BYTES = 4 * 1024 * 1024;

function readBody(req: IncomingMessage): Promise<string | null> {
  return new Promise((resolve, reject) => {
    const chunks: Buffer[] = [];
    let size = 0;
    req.on("data", (chunk: Buffer) => {
      size += chunk.length;
      if (size > MAX_BODY_BYTES) {
        resolve(null);
        req.destroy();
      } else {
        chunks.push(chunk);
      }
    });
    req.on("end", () => resolve(Buffer.concat(chunks).toString("utf8")));
    req.on("error", reject);
  });
}

const isCategories = (v: unknown): v is string[] =>
  Array.isArray(v) && v.length <= 200 && v.every(c => typeof c === "string" && c.length <= MAX_NAME_CHARS);
const isItems = (v: unknown): v is { id: string; name: string }[] =>
  Array.isArray(v) && v.length >= 1 && v.length <= MAX_NAMES && v.every(i =>
    typeof i?.id === "string" && i.id.length <= 64 && typeof i?.name === "string" &&
    i.name.length >= 1 && i.name.length <= MAX_NAME_CHARS);
const isJpeg = (v: unknown): v is string =>
  typeof v === "string" && Buffer.from(v.slice(0, 8), "base64").subarray(0, 3).equals(Buffer.from([0xff, 0xd8, 0xff]));

async function fill(req: IncomingMessage): Promise<{ status: number; body?: unknown }> {
  const identity = await identify(req.headers["x-app-transaction"] as string | undefined);
  if (!identity) return { status: 401 };

  const raw = await readBody(req);
  if (raw === null) return { status: 413 };
  let request: Record<string, unknown>;
  try {
    request = JSON.parse(raw);
  } catch {
    return { status: 400 };
  }
  const categories = request.categories;
  if (!isCategories(categories) || categories.length > MAX_CATEGORIES) return { status: 400 };

  if (request.kind === "text") {
    if (!isItems(request.items)) return { status: 400 };
    // A crisis phrase gets its answer even when the budget is spent, and costs no quota.
    if (request.items.some(item => hasCrisisPhrase(item.name))) {
      return { status: 200, body: { outcome: "crisis", message: CRISIS_MESSAGE } };
    }
    if (isPaused() || !take(identity, "names", request.items.length)) return { status: 200, body: { outcome: "paused" } };
    return { status: 200, body: await fillText({ items: request.items, categories }) };
  }
  if (request.kind === "photo") {
    if (!isJpeg(request.image)) return { status: 400 };
    if (isPaused() || !take(identity, "photos", 1)) return { status: 200, body: { outcome: "paused" } };
    const nameLanguage = typeof request.nameLanguage === "string" ? request.nameLanguage.slice(0, 16) : "en";
    return { status: 200, body: await fillPhoto({ image: request.image, categories, nameLanguage }) };
  }
  return { status: 400 };
}

async function route(req: IncomingMessage, res: ServerResponse) {
  const started = Date.now();
  let status = 404;
  let body: unknown;
  try {
    if (req.method === "GET" && req.url === "/healthz") {
      status = 200;
      body = { ok: true };
    } else if (req.method === "POST" && req.url === "/v1/fill") {
      ({ status, body } = await fill(req));
    }
  } catch (error) {
    status = 502;
    console.error("fill failed:", error instanceof Error ? error.name : "unknown");
  }
  res.writeHead(status, { "content-type": "application/json" });
  res.end(body === undefined ? "" : JSON.stringify(body));
  // Never log a name, a photo or an identity.
  console.log(req.method, req.url, status, `${Date.now() - started}ms`);
}

const port = Number(process.env.PORT) || 8787;
createServer((req, res) => void route(req, res)).listen(port, () => console.log(`listening on ${port}`));
