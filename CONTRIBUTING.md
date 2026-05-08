# Developing the Attriax Flutter SDK

This document describes the internal development workflow for the Attriax Flutter SDK packages.

## Code of Conduct

Be respectful and constructive in all interactions with other contributors and maintainers.

## Getting Started

1. **Clone the workspace** locally:
   ```bash
   git clone <your-internal-repository-url>
   cd attriax
   ```

2. **Create a branch** for your changes:
   ```bash
   git checkout -b feature/your-feature-name
   ```

3. **Install dependencies**:
   ```bash
   cd sdk-flutter
   flutter pub get
   ```

## Development Workflow

### Code Style

- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines
- Use meaningful variable and method names
- Add documentation comments for public APIs

### Before Committing

1. **Run analysis**:
   ```bash
   dart analyze
   ```

2. **Format code**:
   ```bash
   dart format .
   ```

3. **Run tests**:
   ```bash
   cd attriax && flutter test
   cd ..\attriax\example && flutter test
   cd ..\..\attriax_flutter_platform_interface && flutter test
   cd ..\attriax_flutter_android && flutter test
   cd ..\attriax_flutter_ios && flutter test
   ```

4. **Test on both platforms**:
   ```bash
   cd attriax\example && flutter run
   ```

### Commit Messages

- Use clear, descriptive commit messages
- Follow Conventional Commits specification https://www.conventionalcommits.org/en/v1.0.0/
- Reference issues when applicable: "fix: #123 change synchronization logic to handle edge cases"

Example:
```
feat: add method to record custom events

- Implement recordEvent() in platform interface
- Add Android implementation
- Add iOS implementation
- Update example app
```

## Change Review Process

1. **Update documentation** if you're adding new features
2. **Add/update tests** for your changes
3. **Ensure all checks pass**:
   - Code analysis passes
   - Code is properly formatted
   - Tests pass on both platforms
4. **Write a clear change summary** explaining:
   - What changes were made
   - Why the changes were made
   - How to test the changes
   - Any breaking changes

## Project Structure

The project uses a federated plugin architecture:

```
sdk-flutter/
├── attriax/                    # Public package and example app
├── attriax_flutter_platform_interface/ # Interface definitions
├── attriax_flutter_android/            # Android implementation
├── attriax_flutter_ios/                # iOS implementation
```

The internal tester lives in the sibling repository `../flutter-internal-tester/`.

### When Adding Features

1. **Define the interface** in `attriax_flutter_platform_interface/`
2. **Implement on Android** in `attriax_flutter_android/`
3. **Implement on iOS** in `attriax_flutter_ios/`
4. **Expose through main package** in `attriax/`
5. **Demonstrate in the public example** in `attriax/example/`
6. **Exercise deeper flows in the internal tester** in `../flutter-internal-tester/`

## Testing

- Write tests for all new functionality
- Tests should be in a `test/` directory within each package
- Run tests from the package directories that own them; the workspace root does not have a top-level `test/` directory

## Documentation

- Document public APIs with doc comments
- Update README files when necessary
- Add comments for complex logic

## Reporting Issues

When reporting bugs:
- Describe the problem clearly
- Include steps to reproduce
- Provide error messages and logs
- Specify your environment (Flutter version, OS, device/simulator)
- Include a minimal example if possible

## Questions?

- Contact the maintainers directly through the internal team channels.
