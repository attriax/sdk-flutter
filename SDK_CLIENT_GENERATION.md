# Flutter SDK Client Regeneration

The generated Flutter transport layer lives in `sdk-flutter/attriax_api_client/`.

That package is derived from `api/generated/sdk-contract.openapi.json`, which is itself derived from the NestJS SDK controllers and DTOs in `api/`.

Treat `attriax_api_client` as generated output, not handwritten source.

## Supported Commands

Run everything from the workspace root.

```bash
npm install
```

```bash
npm run sdk:flutter:generate
```

```bash
npm run sdk:flutter:generate:fast
```

```bash
npm run sdk:flutter:validate
```

```bash
npm run sdk:contract:generate
```

## What `sdk:flutter:generate` Does

`npm run sdk:flutter:generate` is the supported end-to-end regeneration flow.

It performs these steps in order:

1. Regenerates `api/generated/sdk-contract.openapi.json` from the NestJS API.
2. Deletes the previous `sdk-flutter/attriax_api_client/` output.
3. Generates a new Dart Dio client with `@openapitools/openapi-generator-cli` using `serializationLibrary=built_value`.
4. Reapplies Attriax-owned metadata and compatibility fixes:
   - `pubspec.yaml` metadata
   - `analysis_options.yaml`
   - `README.md`
   - enum mixin compatibility patches required by the current Flutter/Dart toolchain
5. Runs `flutter pub get` in `sdk-flutter/`.
6. Runs `dart run build_runner build --delete-conflicting-outputs` in `attriax_api_client/`.
7. Runs validation unless you used `sdk:flutter:generate:fast`.

## What `sdk:flutter:validate` Does

`npm run sdk:flutter:validate` performs the supported post-generation checks:

1. `flutter pub get` in `sdk-flutter/`
2. `dart analyze attriax attriax_api_client`
3. `flutter test` in `sdk-flutter/attriax`

That keeps validation focused on the generated client and the package that consumes it.

## When To Regenerate

Run `npm run sdk:flutter:generate` whenever one of these changes:

- SDK-facing controllers in `api/`
- SDK-facing request/response DTOs in `api/`
- the generator version pinned in `openapitools.json`
- the post-generation patch logic in `scripts/flutter-sdk-client.mjs`

Do not hand-edit generated transport models or generated API methods and then commit them without updating the generator flow. If something in generated output needs a permanent fix, put that fix into `scripts/flutter-sdk-client.mjs` so the next regeneration preserves it.

## Files Owned By The Generator

These paths are considered generated and may be replaced entirely:

- `sdk-flutter/attriax_api_client/lib/`
- `sdk-flutter/attriax_api_client/doc/`
- `sdk-flutter/attriax_api_client/.openapi-generator/`

These files are restored by the post-generation script and should still be treated as generated-package metadata, not as manually curated package docs:

- `sdk-flutter/attriax_api_client/pubspec.yaml`
- `sdk-flutter/attriax_api_client/analysis_options.yaml`
- `sdk-flutter/attriax_api_client/README.md`

## Why It Is A Separate Package

The current supported layout keeps the generated client in `attriax_api_client/` instead of embedding it directly into `attriax/lib/`.

That is intentional:

- generated code stays isolated from the handwritten public SDK runtime
- `build_runner` output stays confined to the generated package
- regeneration can replace the package atomically
- generator quirks are fixed in one place instead of being mixed into public package source
- review diffs stay easier to scan because transport churn is separated from runtime logic

## Can It Be Embedded Into `attriax_flutter`?

Yes, technically.

The same workflow can target `sdk-flutter/attriax/lib/src/generated/` instead of `sdk-flutter/attriax_api_client/`.

That would give you a single published package surface, but it comes with tradeoffs:

- generated files would sit next to handwritten runtime code
- generator cleanup becomes more delicate because the output directory is inside the main package source tree
- `build_runner` artifacts and generator quirks would affect the main package directly
- public package diffs become noisier and harder to review

For the current repository, the more reliable option is to keep generation isolated in `attriax_api_client/` and have `attriax/` consume it internally.

If later you need a single distributable package, the contract source and regeneration script can stay the same. The main change would be the output directory plus import rewrites.