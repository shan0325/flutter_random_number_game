import 'package:flutter/material.dart';

import 'ad_mob_banner.dart';

class GameScaffold extends StatelessWidget {
  const GameScaffold({
    super.key,
    this.appBar,
    required this.body,
  });

  final PreferredSizeWidget? appBar;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      body: body,
      bottomNavigationBar: const AdMobBanner(),
    );
  }
}
