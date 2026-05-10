# attriax_flutter_windows

Windows implementation package for the Attriax Flutter SDK.

This package is published as the federated Windows implementation that backs
`attriax_flutter` on Windows. Most apps should depend on `attriax_flutter`
instead of importing this package directly.

## Usage

Add `attriax_flutter` to your Flutter app for the public cross-platform API.
Flutter will register `attriax_flutter_windows` automatically on Windows.

## Development

This repository keeps the Windows plugin package in the `sdk-flutter/`
workspace alongside the main `attriax_flutter` package and the shared API
client. Run workspace dependency resolution from the workspace root when
developing locally.

