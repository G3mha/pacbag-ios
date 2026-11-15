import { createHash } from "node:crypto";
import { readFileSync } from "node:fs";
import { Environment, SignedDataVerifier, VerificationStatus } from "@apple/app-store-server-library";

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
  const reasons: string[] = [];
  if (jws) {
    for (const verifier of verifiers) {
      try {
        const payload = await verifier.verifyAndDecodeAppTransaction(jws);
        const id = payload.appTransactionId;
        if (id) return hash(id);
        reasons.push("no appTransactionId");
      } catch (error) {
        // Try the next environment.
        const status = (error as { status?: number }).status;
        reasons.push(status === undefined ? String((error as Error).message) : VerificationStatus[status]);
      }
    }
  }
  if (allowUnsigned) return hash("dev");
  console.log("identity rejected:", jws ? `claimed=${claimed(jws)} reasons=${reasons.join(",")}` : "no X-App-Transaction header");
  return null;
}

/** What the unverified payload says about itself, without any id, so a rejection can be explained. */
function claimed(jws: string): string {
  try {
    const payload = JSON.parse(Buffer.from(jws.split(".")[1], "base64url").toString());
    return `${payload.receiptType}/${payload.bundleId}`;
  } catch {
    return "unreadable";
  }
}
