import 'package:google_mobile_ads/google_mobile_ads.dart';

RequestConfiguration buildAdMobRequestConfiguration() {
  return RequestConfiguration(
    maxAdContentRating: MaxAdContentRating.g,
  );
}

Future<void> configureAdMobRequests() {
  return MobileAds.instance.updateRequestConfiguration(
    buildAdMobRequestConfiguration(),
  );
}
