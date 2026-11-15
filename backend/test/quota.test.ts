import assert from "node:assert/strict";
import { test } from "node:test";

process.env.UNVERIFIED_CALLS_PER_DAY = "2";
process.env.GLOBAL_CALLS_PER_DAY = "3";
const { countCall, isPaused, UNVERIFIED } = await import("../src/quota.ts");

test("unverified requests have their own pool and can't use up the App Store users' cap", () => {
  countCall(UNVERIFIED);
  assert.equal(isPaused(UNVERIFIED), false);
  countCall(UNVERIFIED);
  assert.equal(isPaused(UNVERIFIED), true);
  assert.equal(isPaused("someone"), false);

  countCall("someone");
  countCall("someone");
  countCall("someone");
  assert.equal(isPaused("someone"), true);
});
