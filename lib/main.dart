import 'dart:isolate';
import 'dart:ui';

import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flix_pro/Commons/kf_strings.dart';
import 'package:flix_pro/Commons/kf_themes.dart';
import 'package:flix_pro/Provider/kf_provider.dart';
import 'package:flix_pro/Provider/web_provider.dart';
import 'package:flix_pro/Screens/Auth/auth_provider.dart';
import 'package:flix_pro/Screens/Auth/login/provider.dart';
import 'package:flix_pro/Screens/Auth/password/provider.dart';
import 'package:flix_pro/Screens/Auth/register/provider.dart';
import 'package:flix_pro/Screens/kf_splash_screen.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import 'Commons/kf_keys.dart';
import 'Provider/flutter_downloader_provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initialize();
  await FlutterDownloader.initialize(
      debug:
          true, // optional: set to false to disable printing logs to console (default: true)
      ignoreSsl:
          true // option: set to false to disable working with http links (default: false)
      );

  FlutterDownloader.registerCallback(MyApp.downloadCallback);

  setOrientationPortrait();
  exitFullScreen();

  String storageLocation = (await getApplicationDocumentsDirectory()).path;
  await FastCachedImageConfig.init(
      path: storageLocation, clearCacheAfter: const Duration(days: 15));

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @pragma('vm:entry-point')
  static void downloadCallback(
      String id, DownloadTaskStatus status, int progress) {
    final SendPort? send =
        IsolateNameServer.lookupPortByName(keyDownloadReport);
    if (send != null) {
      send.send([id, status, progress]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return RestartAppWidget(
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => KFProvider()),
          ChangeNotifierProvider(create: (context) => KFWebProvider()),
          ChangeNotifierProvider(
              create: (context) => FlutterDownloaderProvider()),
          ChangeNotifierProvider(
            create: (context) => AuthProvider(),
          ),
          ChangeNotifierProvider(
              create: (BuildContext context) => PasswordProvider()),
          ChangeNotifierProvider(
            create: (BuildContext context) => RegisterProvider(),
          ),
          ChangeNotifierProvider(
            create: (BuildContext context) => LoginProvider(),
          ),
          ChangeNotifierProvider(
            create: (BuildContext context) => AuthProvider(),
          )
        ],
        child: MaterialApp(
          title: kfAppName,
          theme: kfMainTheme,
          home: const KFSplashScreen(),
          builder: EasyLoading.init(),
        ),
      ),
    );
  }
}
