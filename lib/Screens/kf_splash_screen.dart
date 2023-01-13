import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flix_pro/Commons/kf_strings.dart';
import 'package:nb_utils/nb_utils.dart' hide log;
import 'package:provider/provider.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

import '../Commons/kf_functions.dart';
import '../Provider/kf_provider.dart';
import 'Auth/auth_home_screen.dart';

class KFSplashScreen extends StatefulWidget {
  const KFSplashScreen({Key? key}) : super(key: key);

  @override
  State<KFSplashScreen> createState() => _KFSplashScreenState();
}

class _KFSplashScreenState extends State<KFSplashScreen> {
  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    final provider = context.read<KFProvider>();
    provider.stracturePopularMoviesAndSeriesData();
    await fetchDataAndStoreData(provider);
  }

  Future<void> _ready() async {
    await 5.seconds.delay;
  }

  void launchToHomeScreen() {
    Future.delayed(Duration.zero,
        () => const AuthHomeScreen().launch(context, isNewTask: true));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
        future: _ready(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            launchToHomeScreen();
            return _loadingWidget();
          }
          return _loadingWidget();
        });
  }

  Widget _loadingWidget() => Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DefaultTextStyle(
                style: boldTextStyle(
                    size: 44,
                    color: Colors.white,
                    fontFamily: 'assets/fonts/BungeeInline-Regular.ttf'),
                child: AnimatedTextKit(
                    isRepeatingAnimation: false,
                    animatedTexts: [
                      TypewriterAnimatedText(kfAppName.toUpperCase(),
                          speed: 200.milliseconds)
                    ])),
          ],
        ).center().paddingSymmetric(vertical: 30),
      );
}
