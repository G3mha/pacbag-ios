// Counts live in memory, so a restart clears them. That's fine for one small server, and it means
// the server stores nothing about anyone. The global cap is what limits the bill.
const NAMES_PER_DAY = Number(process.env.NAMES_PER_DAY) || 300;
const PHOTOS_PER_DAY = Number(process.env.PHOTOS_PER_DAY) || 30;
const GLOBAL_CALLS_PER_DAY = Number(process.env.GLOBAL_CALLS_PER_DAY) || 2000;

type Counts = { names: number; photos: number };
let day = "";
let globalCalls = 0;
let counts = new Map<string, Counts>();

function roll() {
  const today = new Date().toISOString().slice(0, 10);
  if (today !== day) {
    day = today;
    globalCalls = 0;
    counts = new Map();
  }
}

export function isPaused(): boolean {
  roll();
  return process.env.AI_PAUSED === "1" || globalCalls >= GLOBAL_CALLS_PER_DAY;
}

export function take(identity: string, kind: "names" | "photos", amount: number): boolean {
  roll();
  const entry = counts.get(identity) ?? { names: 0, photos: 0 };
  const limit = kind === "names" ? NAMES_PER_DAY : PHOTOS_PER_DAY;
  if (entry[kind] + amount > limit) return false;
  entry[kind] += amount;
  counts.set(identity, entry);
  return true;
}

export function countCall() {
  roll();
  globalCalls += 1;
}

export function resetQuotaForTests() {
  day = "";
  roll();
}
