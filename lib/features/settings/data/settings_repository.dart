import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/storage/app_storage_keys.dart';
import '../domain/models/active_context.dart';

class SettingsRepository {
  Future<void> saveActiveContext(
    ActiveContext context,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      AppStorageKeys.activeContext,
      jsonEncode(context.toJson()),
    );
  }

  Future<ActiveContext> getActiveContext() async {
    final prefs = await SharedPreferences.getInstance();

    final raw = prefs.getString(
      AppStorageKeys.activeContext,
    );

    if (raw == null || raw.isEmpty) {
      final initial = ActiveContext.initial();

      await saveActiveContext(initial);

      return initial;
    }

    try {
      final decoded = jsonDecode(raw);

      if (decoded is! Map<String, dynamic>) {
        return ActiveContext.initial();
      }

      return ActiveContext.fromJson(decoded);
    } catch (_) {
      return ActiveContext.initial();
    }
  }
}