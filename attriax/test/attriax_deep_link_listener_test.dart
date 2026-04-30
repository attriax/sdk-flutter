import 'dart:async';

import 'package:attriax/src/attriax_deep_link_source.dart';
import 'package:attriax/src/internal/attriax_deep_link_listener.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AttriaxDeepLinkListener', () {
    test('does not await initial deep-link handling before start completes', () async {
      final source = FakeDeepLinkSource(
        initialLink: Uri.parse('myapp://promo/spring-launch'),
      );
      final listener = AttriaxDeepLinkListener(deepLinkSource: source);
      final onLinkStarted = Completer<void>();
      final onLinkCompletion = Completer<void>();

      await listener.start((uri, {required isInitialLink}) async {
        expect(uri, Uri.parse('myapp://promo/spring-launch'));
        expect(isInitialLink, isTrue);
        if (!onLinkStarted.isCompleted) {
          onLinkStarted.complete();
        }
        await onLinkCompletion.future;
      });

      await onLinkStarted.future;
      expect(onLinkCompletion.isCompleted, isFalse);

      onLinkCompletion.complete();
      await listener.stop();
      await source.dispose();
    });
  });
}

class FakeDeepLinkSource implements AttriaxDeepLinkSource {
  FakeDeepLinkSource({this.initialLink});

  final Uri? initialLink;
  final StreamController<Uri> _controller = StreamController<Uri>.broadcast();

  @override
  Future<Uri?> getInitialLink() async => initialLink;

  @override
  Stream<Uri> get uriLinkStream => _controller.stream;

  Future<void> dispose() => _controller.close();
}