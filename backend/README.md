# PacBag AI server

The optional AI service used by the iOS app. It receives item names or selected photos and asks Anthropic's Claude for weights, categories, and photo item details. It does not store packing lists.

## Run locally

Use Node.js 23.10 or later.

```bash
cd backend
npm ci
FAKE_CLAUDE=1 npm start
```

Fake mode returns test estimates without calling Anthropic. For real estimates, set `ANTHROPIC_API_KEY` and run `npm start` without `FAKE_CLAUDE`. Keep the key on the server.

The server listens on port 8787 by default. `GET /healthz` checks the process; `POST /v1/fill` handles text and photo requests.

For a Debug app build, set `PACBAG_API_URL` in the Xcode scheme. Use `http://localhost:8787` on a simulator or a reachable HTTPS address on a device. The app requests consent before sending AI data.

## Configuration

`PORT` changes the port. `CLAUDE_MODEL` selects the model. Production requires `APPLE_APP_ID` to verify App Store records. Requests without a verified record use a separate shared quota.

Quota settings are in [src/quota.ts](src/quota.ts). Counters are held in memory and reset daily or on restart. The server code does not save item names or photos; hosting and Anthropic data handling are described in the [privacy policy](https://pacbag.app/privacy).

Run `FAKE_CLAUDE=1 npm test` and `npm run typecheck` to check backend changes.
