import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/storage/app_storage_keys.dart';
import '../domain/models/active_context.dart';

class SettingsRepository {
  Future<void> saveActiveContext(ActiveContext context) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      AppStorageKeys.activeContext,
      jsonEncode(context.toJson()),
    );
  }

  Future<ActiveContext> getActiveContext() async {
    final prefs = await SharedPreferences.getInstance();

    final raw = prefs.getString(AppStorageKeys.activeContext);

    if (raw == null || raw.trim().isEmpty) {
      final initial = ActiveContext.initialSeed();
      await saveActiveContext(initial);
      return initial;
    }

    try {
      final decoded = jsonDecode(raw);

      if (decoded is! Map) {
        final initial = ActiveContext.initialSeed();
        await saveActiveContext(initial);
        return initial;
      }

      final map = Map<String, dynamic>.from(decoded);

      final context = ActiveContext.fromJson(map);

      if (context.tournament.trim().isEmpty &&
          context.competition.trim().isNotEmpty) {
        final migrated = context.copyWith(
          tournament: context.competition,
          competition: 'Local',
        );

        await saveActiveContext(migrated);
        return migrated;
      }

      return context;
    } catch (_) {
      final initial = ActiveContext.initialSeed();
      await saveActiveContext(initial);
      return initial;
    }
  }

  Future<void> clearActiveContext() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppStorageKeys.activeContext);
  }
}