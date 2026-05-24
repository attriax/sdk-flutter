# Attriax Flutter Runtime Architecture

This document is the maintainer map for the main `attriax/` package runtime.
Use it before adding new behavior to the SDK so changes land in the smallest
owning layer instead of accumulating more work in the top-level runtime.

## Runtime Layers

### Public surface

- `lib/attriax.dart` and `lib/src/attriax.dart` expose the public `Attriax`
  API plus focused facades such as tracking, deep links, referrer access,
  consent, synchronization, and SKAN.
- Public methods should stay thin. They should validate API-facing arguments and
  forward into the runtime or a focused manager.
- The root `Attriax` instance should stay centered on lifecycle, global enable
  state, and a small number of direct transport-style calls such as
  `validateReceipt()`.

### Composition root

- `lib/src/internal/attriax_runtime.dart` is the composition root.
- It wires persistence, context collection, request dispatch, synchronization,
  consent, deep links, sessions, app-open handling, crash reporting, referrers,
  SKAN, and platform integrations.
- Keep new policy decisions here only when they coordinate multiple workflows.
  If logic mostly belongs to one workflow, move it into that workflow's owner
  or coordinator instead of growing the runtime class again.

### Policy coordinators

- `attriax_runtime_bootstrap_coordinator.dart` restores local state, listeners,
  and startup-owned manager state.
- `attriax_runtime_activation_coordinator.dart` owns enabled, deferred, and
  consent-driven activation transitions.
- `attriax_sdk_runtime_config_coordinator.dart` owns launch-time runtime-config
  loading and caching.
- `attriax_app_open_launch_coordinator.dart` owns app-open scheduling plus the
  extra iOS enrichment glue needed before startup attribution runs.
- `attriax_crash_reporting_coordinator.dart` owns crash listener registration,
  routing, and queue behavior.

If you are about to add branching startup policy to `AttriaxRuntime`, check
whether it belongs in one of these extracted coordinators first.

### Workflow managers

- Consent and gating: `attriax_consent_manager.dart`
- App-open lifecycle and results: `attriax_app_open_manager.dart`
- Request queueing and delivery order: `attriax_request_dispatcher.dart` and
  `attriax_synchronizer.dart`
- Session lifecycle: `attriax_session_manager.dart` and
  `attriax_session_lifecycle_manager.dart`
- Deep-link and referrer handling: `attriax_deep_link_manager.dart` and
  `attriax_referrer_manager.dart`
- Event and revenue tracking helpers: `attriax_tracking_manager.dart`
- Platform install referrer capture: `attriax_platform_install_referrer_manager.dart`
- SKAN ownership: `attriax_skan_manager.dart`

Managers should own one workflow end to end. They can depend on low-level
services, but they should not quietly coordinate unrelated startup behavior.

### Runtime settings and persistence

- `attriax_runtime_settings_state.dart` is the in-memory effective view of
  runtime enablement and tracking enablement.
- `attriax_runtime_settings_store.dart` defines the narrow persisted settings
  boundary used by the runtime settings state and other managers.
- `attriax_preferences_store.dart` remains the concrete shared-preferences
  backing store, but it should mostly be consumed through smaller read/write
  interfaces owned by the subsystem that needs them.

When a manager only needs one storage slice, depend on that slice instead of
passing the full preferences store through the stack.

### Context and platform capture

- `attriax_context_collector.dart` is now a small composition layer, not a
  monolithic collector.
- `attriax_context_platform_services.dart` wraps platform/environment access
  needed during capture.
- `attriax_native_context_capture.dart` owns native/platform snapshot calls.
- `attriax_context_snapshot_builder.dart` assembles the final runtime snapshot.
- `attriax_device_identity_resolver.dart` resolves the persisted device identity.

Keep new context fields in the context collaborators unless the change truly
requires runtime-wide startup policy.

### Low-level services

- Platform calls: `attriax_platform_*.dart`
- Generated/network transport: `attriax_generated_transport.dart`
- Queue models: `attriax_queue.dart`

These files should stay narrow and reusable. Avoid putting policy branches here
unless they are unavoidable transport or storage rules.

## Startup Flow

The intended startup split is:

1. `Attriax.init()` completes local startup.
2. The bootstrap coordinator restores runtime settings, queue/session state,
   listeners, and startup-owned manager state.
3. Context capture restores device identity and builds the runtime snapshot.
4. The activation coordinator decides whether startup should become disabled,
   deferred, or fully active.
5. If attribution startup is allowed, runtime config and app-open scheduling run
   before later queued work can synchronize.

Important current rule:

- Launch-time runtime config must not create network traffic while GDPR consent
  is still pending or attribution tracking is unavailable.
- The runtime only needs that config for attribution-driven app-open behavior,
  so consent-pending startup should stay locally initialized but network quiet.
- `init()` still means local startup is complete. It does not mean app-open has
  already succeeded.

## Network Delivery Rules

- App-open stays ahead of later queued SDK requests.
- Retryable HTTP failures leave requests queued with backoff metadata.
- Deferred requests with a future `nextRetryAt` stay queued while later
  deliverable work can still drain.
- Consent-pending startup may buffer analytics locally, but it should not emit
  attribution-driven network work until consent resolves.

When adding a new request type, decide explicitly:

- whether it is blocked by consent
- whether it requires a successful app-open first
- whether it belongs in batched synchronization or direct dispatch

## Test Seams

- Use `Attriax.test(...)` for high-level runtime tests.
- Use `test/test_support/fake_generated_transport.dart` for unit tests that only
  need transport-level observation or controlled failures.
- Use focused fake-based tests for extracted seams when the runtime itself is
  not the behavior under test. `attriax_context_manager_test.dart` and
  `attriax_platform_install_referrer_manager_test.dart` are the reference
  examples for narrow store/runtime-service fakes.
- Use `MockClient` HTTP tests when validating serialized request bodies or exact
  endpoint behavior in `attriax_generated_transport.dart`.
- Keep queueing and dispatch tests in `attriax_request_dispatcher_test.dart` and
  `attriax_synchronizer_test.dart` focused on delivery policy, not transport
  implementation details.

If a new transport method breaks unrelated tests, add the missing default to the
shared fake instead of re-copying local fake implementations.

## Maintenance Guardrails

- Prefer extracting a focused manager before growing `AttriaxRuntime` further.
- Prefer extracting or extending a coordinator before adding more startup-policy
  branches to the runtime root.
- Keep public API additions thin and route them into an existing owner.
- Keep the package example focused on integration basics, use `example-rich/`
  for broader public demo flows, and keep internal-only QA flows in
  `flutter-internal-tester/`.
- Update this document when startup ownership, gating rules, or runtime seams
  move.