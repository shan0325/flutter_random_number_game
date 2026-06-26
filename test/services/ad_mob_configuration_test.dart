import 'package:flutter_test/flutter_test.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:onetotwentyfive/services/ad_mob_configuration.dart';

void main() {
  test('limits AdMob content rating to general audiences', () {
    final configuration = buildAdMobRequestConfiguration();

    expect(configuration.maxAdContentRating, MaxAdContentRating.g);
  });
}
