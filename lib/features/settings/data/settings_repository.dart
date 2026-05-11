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

    if (raw == null || raw.trim().isEmpty || raw.trim() == 'null') {
      return ActiveContext.empty();
    }

    try {
      final decoded = jsonDecode(raw);

      if (decoded is! Map) {
        await prefs.remove(AppStorageKeys.activeContext);
        return ActiveContext.empty();
      }

      final map = Map<String, dynamic>.from(decoded);
      final context = ActiveContext.fromJson(map);

      // Compatibilidad con backups/contextos viejos:
      // antes algunos datos venían con torneo vacío y competencia como torneo.
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
      await prefs.remove(AppStorageKeys.activeContext);
      return ActiveContext.empty();
    }
  }

  Future<void> clearActiveContext() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppStorageKeys.activeContext);
  }

  Future<void> seedDevelopmentContext() async {
    final initial = ActiveContext.initialSeed();
    await saveActiveContext(initial);
  }
}