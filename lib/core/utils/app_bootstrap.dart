import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../core/constants/app_constants.dart';

class AppBootstrap {
  static Future<void> initialize() async {
    // Lock orientation to portrait
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // Transparent status bar
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    // Hive
    await Hive.initFlutter();
    await _openHiveBoxes();
  }

  static Future<void> _openHiveBoxes() async {
    await Future.wait([
      Hive.openBox<Map>(AppConstants.documentCacheBox),
      Hive.openBox<Map>(AppConstants.userCacheBox),
      Hive.openBox<Map>(AppConstants.searchCacheBox),
      Hive.openBox<Map>(AppConstants.prefetchCacheBox),
    ]);
  }

  static Future<void> dispose() async {
    await Hive.close();
  }
}
