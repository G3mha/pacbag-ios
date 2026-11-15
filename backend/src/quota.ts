// Counts live in memory, so a restart clears them. That's fine for one small server, and it means
// the server stores nothing about anyone. The global cap is what limits the bill.
const NAMES_PER_DAY = Number(process.env.NAMES_PER_DAY) || 300;
const PHOTOS_PER_DAY = Number(process.env.PHOTOS_PER_DAY) || 30;
const GLOBAL_CALLS_PER_DAY = Number(process.env.GLOBAL_CALLS_PER_DAY) || 2000;
// Requests with no App Store record (builds from Xcode, or anyone calling directly) share this
// separate pool, so they can never use up the App Store users' cap. 0 turns them off.
const UNVERIFIED_CALLS_PER_DAY = Number(process.env.UNVERIFIED_CALLS_PER_DAY ?? 50);
export const UNVERIFIED = "unverified";

type Counts = { names: number; photos: number };
let day = "";
let globalCalls = 0;
let unverifiedCalls = 0;
let counts = new Map<string, Counts>();

function roll() {
  const today = new Date().toISOString().slice(0, 10);
  if (today !== day) {
    day = today;
    globalCalls = 0;
    unverifiedCalls = 0;
    counts = new Map();
  }
}

export function isPaused(identity: string): boolean {
  roll();
  if (process.env.AI_PAUSED === "1") return true;
  return identity === UNVERIFIED ? unverifiedCalls >= UNVERIFIED_CALLS_PER_DAY : globalCalls >= GLOBAL_CALLS_PER_DAY;
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

export function countCall(identity: string) {
  roll();
  if (identity === UNVERIFIED) unverifiedCalls += 1;
  else globalCalls += 1;
}

export function resetQuotaForTests() {
  day = "";
  roll();
}
