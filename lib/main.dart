import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'package:downapp/app/app.dart';
import 'package:downapp/app/di/providers.dart';
import 'package:downapp/core/network/pocketbase_client.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Durum çubuğu stilini ayarla
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  // Ekran yönünü kilitle (sadece dikey)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // SharedPreferences başlat
  final sharedPreferences = await SharedPreferences.getInstance();

  // PocketBase istemcisini başlat
  PocketBaseClient.init(sharedPreferences);

  // Timeago Türkçe dil desteği
  timeago.setLocaleMessages('tr', timeago.TrMessages());

  // Uygulamayı başlat
  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const DownApp(),
    ),
  );
}
