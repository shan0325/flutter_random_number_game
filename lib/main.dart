import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'app.dart';
import 'services/ad_mob_configuration.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureAdMobRequests();
  MobileAds.instance.initialize();
  runApp(const MyApp());
}
