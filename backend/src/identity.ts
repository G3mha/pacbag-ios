import { createHash } from "node:crypto";
import { readFileSync } from "node:fs";
import { Environment, SignedDataVerifier } from "@apple/app-store-server-library";

const BUNDLE_ID = "enriccogemha.PacBagApp";
const root = readFileSync(new URL("../certs/AppleRootCA-G3.cer", import.meta.url));
const appAppleId = Number(process.env.APPLE_APP_ID) || undefined;

// Online checks stay off, so verifying makes no outbound call. The cost is no revocation check.
const verifiers = [new SignedDataVerifier([root], false, Environment.SANDBOX, BUNDLE_ID, undefined)];
if (appAppleId) verifiers.unshift(new SignedDataVerifier([root], false, Environment.PRODUCTION, BUNDLE_ID, appAppleId));

export const allowUnsigned = process.env.ALLOW_UNSIGNED_IDENTITY === "1";
if (process.env.NODE_ENV === "production" && (allowUnsigned || !appAppleId)) {
  throw new Error("production needs APPLE_APP_ID and can't allow unsigned identities");
}

/** A hash that changes daily, so counters can't follow anyone. Null means no valid identity. */
export async function identify(jws: string | undefined): Promise<string | null> {
  const day = new Date().toISOString().slice(0, 10);
  const hash = (id: string) => createHash("sha256").update(`${day}:${id}`).digest("hex");
  if (jws) {
    for (const verifier of verifiers) {
      try {
        const payload = await verifier.verifyAndDecodeAppTransaction(jws);
        const id = payload.appTransactionId;
        if (id) return hash(id);
      } catch {
        // Try the next environment.
      }
    }
  }
  return allowUnsigned ? hash("dev") : null;
}
