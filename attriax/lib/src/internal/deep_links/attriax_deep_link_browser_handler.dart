import 'package:attriax_flutter_platform_interface/attriax_platform_interface.dart';
import 'package:attriax_flutter_platform_interface/attriax_runtime_types.dart';

import '../attriax_logger.dart';

class AttriaxDeepLinkBrowserHandler {
  const AttriaxDeepLinkBrowserHandler({
    required AttriaxConfig config,
    required AttriaxPlatform platform,
    required AttriaxLogger logger,
  }) : _config = config,
       _platform = platform,
       _logger = logger;

  final AttriaxConfig _config;
  final AttriaxPlatform _platform;
  final AttriaxLogger _logger;

  Future<bool> handle(AttriaxResolvedUrlAction? browserAction) async {
    if (browserAction == null || !_config.automaticBrowserHandling) {
      return false;
    }

    final opened = await _platform.openBrowserUrl(
      uri: browserAction.uri,
      openMode: browserAction.openMode,
    );
    if (!opened) {
      _logger.warning(
        'SDK could not open the resolved browser URL ${browserAction.uri}.',
      );
    }
    return opened;
  }
}
