import { readFileSync } from "node:fs";

/** The fixed support text. A model never writes this. */
export const CRISIS_MESSAGE =
  "If you are feeling overwhelmed, hopeless, or having thoughts of self-harm, please know that you are not alone and support is available. In the US, call or text 988 to reach the Suicide & Crisis Lifeline (available 24/7), or chat at 988lifeline.org. If you are outside the US, please visit findahelpline.com or contact your local emergency services immediately.";

export const normalizeForCrisis = (s: string) =>
  s.normalize("NFKC").replace(/[\p{Cf}\p{Variation_Selector}]/gu, "").toLowerCase()
    .normalize("NFD").replace(/[̀-ͯ]/g, "").normalize("NFC")
    .replace(/\s+/gu, " ").trim();

const phrases: string[] = JSON.parse(readFileSync(new URL("./crisis-phrases.json", import.meta.url), "utf8"))
  .map(normalizeForCrisis);
const escape = (p: string) => p.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
const isAscii = (p: string) => /^[\x00-\x7f]*$/.test(p);
// Word edges for ASCII, so "killer heels" and "10 kms socks" don't hit. Plain substring otherwise.
const edged = phrases.filter(isAscii).map(p => new RegExp(`(?<![\\p{L}\\p{N}_])${escape(p)}(?![\\p{L}\\p{N}_])`, "u"));
const substrings = phrases.filter(p => !isAscii(p));

export function hasCrisisPhrase(text: string): boolean {
  const n = normalizeForCrisis(text);
  return edged.some(r => r.test(n)) || substrings.some(p => n.includes(p));
}
