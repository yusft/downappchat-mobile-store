import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:downapp/core/network/pocketbase_client.dart';
import 'package:downapp/core/network/network_info.dart';

/// ──────────────────────────────────────────────
/// Client Providers
/// ──────────────────────────────────────────────

final pocketBaseProvider = Provider<PocketBase>(
  (ref) => PocketBaseClient.instance,
);

/// ──────────────────────────────────────────────
/// Utility Providers
/// ──────────────────────────────────────────────

final connectivityProvider = Provider<Connectivity>(
  (ref) => Connectivity(),
);

final networkInfoProvider = Provider<NetworkInfo>(
  (ref) => NetworkInfoImpl(ref.watch(connectivityProvider)),
);

final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('SharedPreferences must be overridden'),
);

/// ──────────────────────────────────────────────
/// Theme & Locale
/// ──────────────────────────────────────────────

enum AppThemeMode { light, dark, system }

final themeModeProvider = StateProvider<AppThemeMode>((ref) {
  return AppThemeMode.system;
});

final localeProvider = StateProvider<String>((ref) {
  return 'tr';
});
