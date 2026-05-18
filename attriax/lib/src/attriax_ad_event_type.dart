/// Canonical ad lifecycle events tracked by the Attriax SDKs.
enum AttriaxAdEventType {
  request('ad_request'),
  load('ad_load'),
  loadFailed('ad_load_failed'),
  show('ad_show'),
  showFailed('ad_show_failed'),
  impression('ad_impression'),
  click('ad_click'),
  dismiss('ad_dismiss'),
  reward('ad_reward');

  const AttriaxAdEventType(this.eventName);

  final String eventName;
}
