const String exampleProjectToken = 'ax_b62ee57056374b76aa09b26fa071e561';

const String exampleDeepLinkHost = 'example-test.attriax.com';
const String exampleDeepLinkPath = 'example/deep-link-success';
const String exampleDeepLinkGroup = 'flutter-example';

bool get isExampleProjectConfigured => !exampleProjectToken.startsWith('ax_your_');

String maskExampleSecret(String value) {
  if (value.length <= 10) {
    return value;
  }

  return '${value.substring(0, 5)}...${value.substring(value.length - 4)}';
}

Uri buildExampleFallbackDeepLink() =>
    Uri.https(exampleDeepLinkHost, exampleDeepLinkPath, const <String, String>{
      'source': 'flutter_example',
      'surface': 'deeplinks_page',
    });

String exampleConfigurationHelpText() =>
  'Edit lib/example_app_configuration.dart to set the project token or deep-link demo defaults.';
