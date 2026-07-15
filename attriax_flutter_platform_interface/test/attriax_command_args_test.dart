import 'package:attriax_flutter_platform_interface/attriax_platform_types.dart';
import 'package:attriax_flutter_platform_interface/src/marshalling/attriax_command_args.dart';
import 'package:flutter_test/flutter_test.dart';

/// Equivalence + drift-prevention gate for the RPC argument DTOs.
///
/// Each expectation is a golden map transcribed from the argument [Map] the
/// retired hand-written `MethodChannelAttriax` code sent over the `attriax`
/// channel. Asserting `dto.toJson()` deep-equals that golden proves two things
/// at once:
///   1. Equivalence — the DTO swap changes NOTHING on the wire (key names,
///      enum encodings, and null-omission are byte-for-byte identical). The
///      native KMP / JS / FFI handlers parse these exact keys, so exactness is
///      safety-critical.
///   2. Contract / drift — a future field rename or omission change fails here.
///
/// Coverage spans null/optional fields, the fields that are emitted even when
/// null, enum encodings, nested objects, and empty/batch shapes.
void main() {
  group('lifecycle', () {
    test('initialize wraps the serialized config', () {
      const config = AttriaxConfig(projectToken: 'ax_test', gdprEnabled: true);
      expect(
        const AttriaxInitializeArgs(config: config).toJson(),
        <String, Object?>{'config': config.toJson()},
      );
    });
  });

  group('tracking — events / page views', () {
    test('recordEvent omits null eventData', () {
      expect(
        const AttriaxRecordEventArgs(
          name: 'tap',
          flushImmediately: false,
        ).toJson(),
        <String, Object?>{'name': 'tap', 'flushImmediately': false},
      );
    });

    test('recordEvent carries eventData when present', () {
      expect(
        const AttriaxRecordEventArgs(
          name: 'checkout',
          eventData: <String, Object?>{'value': 10},
          flushImmediately: true,
        ).toJson(),
        <String, Object?>{
          'name': 'checkout',
          'eventData': <String, Object?>{'value': 10},
          'flushImmediately': true,
        },
      );
    });

    test('recordPageView minimal omits all optionals', () {
      expect(
        const AttriaxRecordPageViewArgs(
          pageName: 'Home',
          source: 'manual',
          flushImmediately: false,
        ).toJson(),
        <String, Object?>{
          'pageName': 'Home',
          'source': 'manual',
          'flushImmediately': false,
        },
      );
    });

    test('recordPageView full', () {
      expect(
        const AttriaxRecordPageViewArgs(
          pageName: 'Cart',
          pageClass: 'CartScreen',
          pageTitle: 'Your Cart',
          previousPageName: 'Home',
          parameters: <String, Object?>{'items': 3},
          source: 'observer',
          flushImmediately: true,
        ).toJson(),
        <String, Object?>{
          'pageName': 'Cart',
          'pageClass': 'CartScreen',
          'pageTitle': 'Your Cart',
          'previousPageName': 'Home',
          'parameters': <String, Object?>{'items': 3},
          'source': 'observer',
          'flushImmediately': true,
        },
      );
    });
  });

  group('tracking — revenue / ad events', () {
    test('recordPurchase minimal (required only)', () {
      expect(
        const AttriaxRecordPurchaseArgs(
          revenue: 4.99,
          currency: 'USD',
          revenueInMicros: false,
          quantity: 1,
          flushImmediately: true,
        ).toJson(),
        <String, Object?>{
          'revenue': 4.99,
          'currency': 'USD',
          'revenueInMicros': false,
          'quantity': 1,
          'flushImmediately': true,
        },
      );
    });

    test('recordPurchase full', () {
      expect(
        const AttriaxRecordPurchaseArgs(
          revenue: 9,
          currency: 'EUR',
          revenueInMicros: true,
          purchaseType: 'subscription',
          productId: 'pro_monthly',
          transactionId: 't1',
          originalTransactionId: 'o1',
          validationProvider: 'app_store',
          validationEnvironment: 'production',
          purchaseToken: 'ptok',
          receiptData: 'rdata',
          signedPayload: 'spayload',
          receiptSignature: 'rsig',
          isRenewal: true,
          quantity: 2,
          store: 'app_store',
          packageName: 'com.demo',
          voided: false,
          test: true,
          validationId: 'v1',
          metadata: <String, Object?>{'k': 'v'},
          flushImmediately: false,
        ).toJson(),
        <String, Object?>{
          'revenue': 9,
          'currency': 'EUR',
          'revenueInMicros': true,
          'purchaseType': 'subscription',
          'productId': 'pro_monthly',
          'transactionId': 't1',
          'originalTransactionId': 'o1',
          'validationProvider': 'app_store',
          'validationEnvironment': 'production',
          'purchaseToken': 'ptok',
          'receiptData': 'rdata',
          'signedPayload': 'spayload',
          'receiptSignature': 'rsig',
          'isRenewal': true,
          'quantity': 2,
          'store': 'app_store',
          'packageName': 'com.demo',
          'voided': false,
          'test': true,
          'validationId': 'v1',
          'metadata': <String, Object?>{'k': 'v'},
          'flushImmediately': false,
        },
      );
    });

    test('recordRefund minimal', () {
      expect(
        const AttriaxRecordRefundArgs(
          revenue: 4.99,
          currency: 'USD',
          revenueInMicros: false,
          quantity: 1,
          flushImmediately: true,
        ).toJson(),
        <String, Object?>{
          'revenue': 4.99,
          'currency': 'USD',
          'revenueInMicros': false,
          'quantity': 1,
          'flushImmediately': true,
        },
      );
    });

    test('recordRefund with reason', () {
      expect(
        const AttriaxRecordRefundArgs(
          revenue: 4.99,
          currency: 'USD',
          revenueInMicros: false,
          productId: 'pro',
          quantity: 1,
          reason: 'chargeback',
          metadata: <String, Object?>{'k': 1},
          flushImmediately: true,
        ).toJson(),
        <String, Object?>{
          'revenue': 4.99,
          'currency': 'USD',
          'revenueInMicros': false,
          'productId': 'pro',
          'quantity': 1,
          'reason': 'chargeback',
          'metadata': <String, Object?>{'k': 1},
          'flushImmediately': true,
        },
      );
    });

    test('recordAdRevenue', () {
      expect(
        const AttriaxRecordAdRevenueArgs(
          revenue: 0.02,
          currency: 'USD',
          revenueInMicros: false,
          adNetwork: 'admob',
          adFormat: 'banner',
          test: true,
          flushImmediately: true,
        ).toJson(),
        <String, Object?>{
          'revenue': 0.02,
          'currency': 'USD',
          'revenueInMicros': false,
          'adNetwork': 'admob',
          'adFormat': 'banner',
          'test': true,
          'flushImmediately': true,
        },
      );
    });

    test('recordAdEvent full incl numeric optionals', () {
      expect(
        const AttriaxRecordAdEventArgs(
          eventName: 'ad_impression',
          adNetwork: 'admob',
          mediationNetwork: 'max',
          adUnitId: 'unit-1',
          adPlacement: 'main',
          adFormat: 'rewarded',
          adType: 'video',
          loadLatencyMs: 120,
          rewardType: 'coins',
          rewardAmount: 50,
          test: false,
          metadata: <String, Object?>{'x': true},
          flushImmediately: true,
        ).toJson(),
        <String, Object?>{
          'eventName': 'ad_impression',
          'adNetwork': 'admob',
          'mediationNetwork': 'max',
          'adUnitId': 'unit-1',
          'adPlacement': 'main',
          'adFormat': 'rewarded',
          'adType': 'video',
          'loadLatencyMs': 120,
          'rewardType': 'coins',
          'rewardAmount': 50,
          'test': false,
          'metadata': <String, Object?>{'x': true},
          'flushImmediately': true,
        },
      );
    });
  });

  group('tracking — notifications / errors', () {
    test('recordNotification minimal', () {
      expect(
        const AttriaxRecordNotificationArgs(
          type: 'opened',
          notificationId: 'n-1',
          flushImmediately: false,
        ).toJson(),
        <String, Object?>{
          'type': 'opened',
          'notificationId': 'n-1',
          'flushImmediately': false,
        },
      );
    });

    test('recordNotification full', () {
      expect(
        const AttriaxRecordNotificationArgs(
          type: 'received',
          notificationId: 'n-2',
          linkId: 'l1',
          campaignId: 'c1',
          title: 'Hi',
          source: 'fcm',
          payload: <String, Object?>{'a': 1},
          metadata: <String, Object?>{'b': 2},
          flushImmediately: true,
        ).toJson(),
        <String, Object?>{
          'type': 'received',
          'notificationId': 'n-2',
          'linkId': 'l1',
          'campaignId': 'c1',
          'title': 'Hi',
          'source': 'fcm',
          'payload': <String, Object?>{'a': 1},
          'metadata': <String, Object?>{'b': 2},
          'flushImmediately': true,
        },
      );
    });

    test('recordError minimal omits stackTrace/reason/metadata', () {
      expect(
        const AttriaxRecordErrorArgs(
          message: 'boom',
          exceptionType: 'StateError',
          fatal: false,
          source: 'manual',
        ).toJson(),
        <String, Object?>{
          'message': 'boom',
          'exceptionType': 'StateError',
          'fatal': false,
          'source': 'manual',
        },
      );
    });

    test('recordError full', () {
      expect(
        const AttriaxRecordErrorArgs(
          message: 'boom',
          exceptionType: 'StateError',
          stackTrace: '#0 main',
          fatal: true,
          source: 'flutter',
          reason: 'assertion',
          metadata: <String, Object?>{'k': 'v'},
        ).toJson(),
        <String, Object?>{
          'message': 'boom',
          'exceptionType': 'StateError',
          'stackTrace': '#0 main',
          'fatal': true,
          'source': 'flutter',
          'reason': 'assertion',
          'metadata': <String, Object?>{'k': 'v'},
        },
      );
    });
  });

  group('identify — the "emit even when null" fields', () {
    test('setUser keeps userId when null, omits userName', () {
      expect(const AttriaxSetUserArgs().toJson(), <String, Object?>{
        'userId': null,
      });
    });

    test('setUser full', () {
      expect(
        const AttriaxSetUserArgs(userId: 'u1', userName: 'Ada').toJson(),
        <String, Object?>{'userId': 'u1', 'userName': 'Ada'},
      );
    });

    test('setUserProperty keeps a null value', () {
      expect(
        const AttriaxSetUserPropertyArgs(name: 'plan').toJson(),
        <String, Object?>{'name': 'plan', 'value': null},
      );
    });

    test('setUserProperty with value', () {
      expect(
        const AttriaxSetUserPropertyArgs(name: 'plan', value: 'pro').toJson(),
        <String, Object?>{'name': 'plan', 'value': 'pro'},
      );
    });

    test('setUserProperties', () {
      expect(
        const AttriaxSetUserPropertiesArgs(
          properties: <String, Object?>{'a': 1, 'b': null},
        ).toJson(),
        <String, Object?>{
          'properties': <String, Object?>{'a': 1, 'b': null},
        },
      );
    });

    test('clearUserProperties omits null names, carries a list', () {
      expect(
        const AttriaxClearUserPropertiesArgs().toJson(),
        <String, Object?>{},
      );
      expect(
        const AttriaxClearUserPropertiesArgs(
          propertyNames: <String>['a', 'b'],
        ).toJson(),
        <String, Object?>{
          'propertyNames': <String>['a', 'b'],
        },
      );
    });

    test('registerPushToken maps provider slug, keeps a null token', () {
      expect(
        const AttriaxRegisterPushTokenArgs(
          provider: AttriaxPushTokenProvider.fcm,
        ).toJson(),
        <String, Object?>{'provider': 'fcm', 'token': null},
      );
      expect(
        const AttriaxRegisterPushTokenArgs(
          provider: AttriaxPushTokenProvider.apns,
          token: 'apns-token',
          metadata: <String, Object?>{'env': 'prod'},
        ).toJson(),
        <String, Object?>{
          'provider': 'apns',
          'token': 'apns-token',
          'metadata': <String, Object?>{'env': 'prod'},
        },
      );
    });
  });

  group('deep links', () {
    test('handleIncomingLink', () {
      expect(
        const AttriaxHandleIncomingLinkArgs(
          uri: 'https://demo.attriax.com/x',
          isInitialLink: true,
        ).toJson(),
        <String, Object?>{
          'uri': 'https://demo.attriax.com/x',
          'isInitialLink': true,
        },
      );
    });

    test('recordDeepLink omits null metadata', () {
      expect(
        const AttriaxRecordDeepLinkArgs(
          uri: 'https://demo.attriax.com/p',
          source: 'manual',
        ).toJson(),
        <String, Object?>{
          'uri': 'https://demo.attriax.com/p',
          'source': 'manual',
        },
      );
    });

    test('waitForDeepLinkResolution lowers the raw event to its map', () {
      final rawEvent = AttriaxRawDeepLinkEvent(
        uri: Uri.parse('https://demo.attriax.com/r'),
        receivedAt: DateTime.utc(2026, 5, 4, 10),
        isInitial: true,
      );
      expect(
        AttriaxWaitForDeepLinkResolutionArgs(rawEvent: rawEvent).toJson(),
        <String, Object?>{'rawEvent': rawEvent.toJson()},
      );
    });

    test('createDynamicLink with everything null is an empty map', () {
      expect(AttriaxCreateDynamicLinkArgs().toJson(), <String, Object?>{});
    });

    test('createDynamicLink full with nested objects', () {
      expect(
        AttriaxCreateDynamicLinkArgs(
          name: 'promo',
          destinationUrl: 'https://demo.attriax.com/promo',
          group: 'g1',
          prefix: 'px',
          socialPreview: const AttriaxDynamicLinkSocialPreview(title: 'Hello'),
          utms: const AttriaxDynamicLinkUtms(source: 'newsletter'),
          redirects: const AttriaxDynamicLinkRedirects(ios: true),
          data: const <String, Object?>{'ref': 'abc'},
        ).toJson(),
        <String, Object?>{
          'name': 'promo',
          'destinationUrl': 'https://demo.attriax.com/promo',
          'group': 'g1',
          'prefix': 'px',
          'socialPreview': <String, Object?>{'title': 'Hello'},
          'utms': <String, Object?>{'source': 'newsletter'},
          'redirects': <String, Object?>{'ios': true},
          'data': <String, Object?>{'ref': 'abc'},
        },
      );
    });
  });

  group('revenue receipt validation', () {
    test('validateReceipt minimal', () {
      expect(
        const AttriaxValidateReceiptArgs(
          receipt: 'base64',
          test: false,
        ).toJson(),
        <String, Object?>{'receipt': 'base64', 'test': false},
      );
    });

    test('validateReceipt full', () {
      expect(
        const AttriaxValidateReceiptArgs(
          receipt: 'base64',
          test: true,
          provider: 'app_store',
          environment: 'sandbox',
          productId: 'pro',
          transactionId: 't1',
        ).toJson(),
        <String, Object?>{
          'receipt': 'base64',
          'test': true,
          'provider': 'app_store',
          'environment': 'sandbox',
          'productId': 'pro',
          'transactionId': 't1',
        },
      );
    });
  });

  group('consent', () {
    test('setGdprConsent', () {
      expect(
        const AttriaxSetGdprConsentArgs(
          analytics: true,
          attribution: false,
          adEvents: true,
        ).toJson(),
        <String, Object?>{
          'analytics': true,
          'attribution': false,
          'adEvents': true,
        },
      );
    });

    test('needsGdprConsent', () {
      expect(
        const AttriaxNeedsGdprConsentArgs(localOnly: true).toJson(),
        <String, Object?>{'localOnly': true},
      );
    });

    test('setCcpaConsent omits null fields', () {
      expect(
        const AttriaxSetCcpaConsentArgs(doNotSell: true).toJson(),
        <String, Object?>{'doNotSell': true},
      );
      expect(
        const AttriaxSetCcpaConsentArgs(
          doNotSell: false,
          usPrivacy: '1YYN',
        ).toJson(),
        <String, Object?>{'doNotSell': false, 'usPrivacy': '1YYN'},
      );
    });
  });

  group('toggles', () {
    test('enabled flag', () {
      expect(
        const AttriaxEnabledArgs(enabled: true).toJson(),
        <String, Object?>{'enabled': true},
      );
      expect(
        const AttriaxEnabledArgs(enabled: false).toJson(),
        <String, Object?>{'enabled': false},
      );
    });
  });

  group('apple seams', () {
    test('submitAsaToken', () {
      expect(
        const AttriaxSubmitAsaTokenArgs(token: 'asa').toJson(),
        <String, Object?>{'token': 'asa'},
      );
    });

    test('setTrackingAuthorizationStatus encodes the wire slug', () {
      expect(
        const AttriaxSetTrackingAuthorizationStatusArgs(
          status: AttriaxTrackingAuthorizationStatus.authorized,
        ).toJson(),
        <String, Object?>{'status': 'authorized'},
      );
      expect(
        const AttriaxSetTrackingAuthorizationStatusArgs(
          status: AttriaxTrackingAuthorizationStatus.notDetermined,
        ).toJson(),
        <String, Object?>{'status': 'not_determined'},
      );
      expect(
        const AttriaxSetTrackingAuthorizationStatusArgs(
          status: AttriaxTrackingAuthorizationStatus.timedOut,
        ).toJson(),
        <String, Object?>{'status': 'timed_out'},
      );
    });

    test('updateSkanConversionValue omits null coarse, encodes .name', () {
      expect(
        const AttriaxUpdateSkanConversionValueArgs(
          fineValue: 12,
          lockWindow: false,
        ).toJson(),
        <String, Object?>{'fineValue': 12, 'lockWindow': false},
      );
      expect(
        const AttriaxUpdateSkanConversionValueArgs(
          fineValue: 30,
          coarseValue: AttriaxSkanCoarseValue.high,
          lockWindow: true,
        ).toJson(),
        <String, Object?>{
          'fineValue': 30,
          'coarseValue': 'high',
          'lockWindow': true,
        },
      );
    });
  });

  group('retained legacy signal surface', () {
    test('collectNativeContext', () {
      expect(
        const AttriaxCollectNativeContextArgs(
          collectAdvertisingId: false,
        ).toJson(),
        <String, Object?>{'collectAdvertisingId': false},
      );
    });

    test('openBrowserUrl encodes the open-mode wire slug', () {
      expect(
        const AttriaxOpenBrowserUrlArgs(
          url: 'https://demo.attriax.com/o',
          openMode: AttriaxResolvedUrlOpenMode.external,
        ).toJson(),
        <String, Object?>{
          'url': 'https://demo.attriax.com/o',
          'openMode': 'external',
        },
      );
      expect(
        const AttriaxOpenBrowserUrlArgs(
          url: 'https://demo.attriax.com/o',
          openMode: AttriaxResolvedUrlOpenMode.inApp,
        ).toJson(),
        <String, Object?>{
          'url': 'https://demo.attriax.com/o',
          'openMode': 'in_app',
        },
      );
      expect(
        const AttriaxOpenBrowserUrlArgs(
          url: 'https://demo.attriax.com/o',
          openMode: AttriaxResolvedUrlOpenMode.unknown,
        ).toJson(),
        <String, Object?>{
          'url': 'https://demo.attriax.com/o',
          'openMode': 'in_app',
        },
      );
    });
  });
}
