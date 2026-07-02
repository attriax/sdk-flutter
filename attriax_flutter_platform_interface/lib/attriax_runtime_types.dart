// Runtime-oriented shared types used by the main Attriax Flutter package.
//
// App integrations should prefer `attriax_platform_types.dart`, which keeps a
// smaller stable public surface. This library intentionally exposes the full
// shared model set needed by the SDK runtime and its maintainer tests.
export 'src/types.dart';
export 'src/attriax_platform_attestation.dart'
    show
        AttriaxPlatformAttestationProvider,
        attriaxAttestationMethodChannelName,
        attriaxAcquireAttestationTokenMethod;
