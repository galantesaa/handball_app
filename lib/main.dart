import 'core/context/app_context_key.dart';
import 'features/settings/data/structure_repository.dart' as structure;
import 'features/settings/domain/models/active_context.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:shared_preferences/shared_preferences.dart';
import 'models_v2.dart';
import 'partido_repository_v2.dart';
import 'widgets/match_card.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:file_selector/file_selector.dart';
import 'models/match_model.dart';
import 'services/stats_service.dart';
import 'package:flutter/rendering.dart';
import 'features/settings/data/settings_repository.dart';
import 'features/matches/data/repositories/fixture_repository_v2.dart';
import 'features/matches/presentation/screens/match_editor_screen.dart';
import 'features/institutions/data/institution_repository.dart';

/// ===============================
/// PUNTO DE ENTRADA
/// ===============================
///
///
bool isAssetShieldPath(String? value) {
  return (value ?? '').trim().startsWith('assets/');
}

Widget buildShieldAvatar(String? path, {double size = 58, double padding = 8}) {
  final cleanPath = (path ?? '').trim();

  Widget fallback() {
    return Icon(
      Icons.sports_handball,
      color: const Color(0xFF1C2B44),
      size: size * 0.42,
    );
  }

  Widget image;

  if (cleanPath.isEmpty) {
    image = fallback();
  } else if (isAssetShieldPath(cleanPath)) {
    image = Image.asset(
      cleanPath,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => fallback(),
    );
  } else {
    image = Image.file(
      File(cleanPath),
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => fallback(),
    );
  }

  return Container(
    width: size,
    height: size,
    decoration: const BoxDecoration(
      shape: BoxShape.circle,
      color: Colors.white,
    ),
    padding: EdgeInsets.all(padding),
    child: ClipOval(child: Center(child: image)),
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ),
  );

  runApp(const GoalKeeperApp());
}

/// ===============================
/// APP RAÍZ
/// ===============================

class GoalKeeperApp extends StatelessWidget {
  const GoalKeeperApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Handball SGS',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A0E14),
        fontFamily: 'Roboto',
      ),
      home: const HomeScreen(),
    );
  }
}

/// ===============================
/// ===============================
/// PLANTEL
/// ===============================
/// ===============================

class PlayerProfile {
  final String playerId;
  final String clubId;
  final String nombre;
  final String apellido;
  final String? posicion;
  final String? numeroPreferido;
  final bool esArquero;
  final bool esCuerpoTecnico;

  const PlayerProfile({
    required this.playerId,
    required this.clubId,
    required this.nombre,
    required this.apellido,
    this.posicion,
    this.numeroPreferido,
    required this.esArquero,
    this.esCuerpoTecnico = false,
  });

  String get nombreCompleto {
    return fixTextoRoto('$nombre $apellido'.trim());
  }

  String get displayName {
    final numero = (numeroPreferido ?? '').trim();
    final nombreLimpio = fixTextoRoto(nombre);
    final apellidoLimpio = fixTextoRoto(apellido);

    if (numero.isEmpty || numero == 'DT') {
      return '$apellidoLimpio, $nombreLimpio'.trim();
    }

    return '$numero · $apellidoLimpio, $nombreLimpio'.trim();
  }

  String get nombreLista {
    return '${fixTextoRoto(apellido)}, ${fixTextoRoto(nombre)}'.trim();
  }

  Map<String, dynamic> toMap() {
    return {
      'playerId': playerId,
      'clubId': clubId,
      'nombre': nombre,
      'apellido': apellido,
      'posicion': posicion,
      'numeroPreferido': numeroPreferido,
      'esArquero': esArquero,
      'esCuerpoTecnico': esCuerpoTecnico,
    };
  }

  factory PlayerProfile.fromMap(Map<String, dynamic> map) {
    return PlayerProfile(
      playerId: (map['playerId'] ?? '').toString(),
      clubId: (map['clubId'] ?? 'san_fernando').toString(),
      nombre: fixTextoRoto(map['nombre']),
      apellido: fixTextoRoto(map['apellido']),
      posicion: map['posicion']?.toString(),
      numeroPreferido: map['numeroPreferido']?.toString(),
      esArquero: map['esArquero'] == true,
      esCuerpoTecnico: map['esCuerpoTecnico'] == true,
    );
  }
}

class RosterAssignment {
  final String playerId;
  final String categoria;
  final String temporada;
  final String? numeroEnCategoria;
  final bool activo;

  const RosterAssignment({
    required this.playerId,
    required this.categoria,
    required this.temporada,
    this.numeroEnCategoria,
    this.activo = true,
  });
}

class ClubContext {
  final String clubId;
  final String clubNombre;
  final String escudoAsset;

  const ClubContext({
    required this.clubId,
    required this.clubNombre,
    required this.escudoAsset,
  });
}

class RosterRepository {
  static const ClubContext currentClub = ClubContext(
    clubId: 'san_fernando',
    clubNombre: 'San Fernando Handball',
    escudoAsset: 'assets/images/san_fernando.png',
  );

  static const List<PlayerProfile> players = [
    PlayerProfile(
      playerId: 'sf_bautista_galante_saavedra',
      clubId: 'san_fernando',
      nombre: 'Bautista',
      apellido: 'Galante Saavedra',
      posicion: 'Arquero',
      numeroPreferido: '33',
      esArquero: true,
    ),
    PlayerProfile(
      playerId: 'sf_juan_frascarelli',
      clubId: 'san_fernando',
      nombre: 'Juan',
      apellido: 'Frascarelli',
      posicion: 'Pivot',
      numeroPreferido: '77',
      esArquero: false,
    ),
    PlayerProfile(
      playerId: 'sf_julian_della_vecchia',
      clubId: 'san_fernando',
      nombre: 'Julian',
      apellido: 'Della Vecchia',
      posicion: 'Central',
      numeroPreferido: '54',
      esArquero: false,
    ),
    PlayerProfile(
      playerId: 'sf_joaquin_leon_rodriguez',
      clubId: 'san_fernando',
      nombre: 'Joaquin',
      apellido: 'Leon Rodriguez',
      posicion: 'Extremo izquierdo',
      numeroPreferido: '26',
      esArquero: false,
    ),
    PlayerProfile(
      playerId: 'sf_juan_pundang',
      clubId: 'san_fernando',
      nombre: 'Juan',
      apellido: 'Pundang',
      posicion: 'Extremo derecho',
      numeroPreferido: '78',
      esArquero: false,
    ),
    PlayerProfile(
      playerId: 'sf_francisco_parente',
      clubId: 'san_fernando',
      nombre: 'Francisco',
      apellido: 'Parente',
      posicion: 'Lateral derecho',
      numeroPreferido: '2',
      esArquero: false,
    ),
    PlayerProfile(
      playerId: 'sf_lucas_fontana_bondar',
      clubId: 'san_fernando',
      nombre: 'Lucas',
      apellido: 'Fontana Bondar',
      posicion: 'Extremo izquierdo',
      numeroPreferido: '7',
      esArquero: false,
    ),
    PlayerProfile(
      playerId: 'sf_bautista_villarino',
      clubId: 'san_fernando',
      nombre: 'Bautista',
      apellido: 'Villarino',
      posicion: 'Extremo derecho',
      numeroPreferido: '32',
      esArquero: false,
    ),
    PlayerProfile(
      playerId: 'sf_ulises_lopez_aranda',
      clubId: 'san_fernando',
      nombre: 'Ulises',
      apellido: 'Lopez Aranda',
      posicion: 'Extremo izquierdo',
      numeroPreferido: '17',
      esArquero: false,
    ),
    PlayerProfile(
      playerId: 'sf_felipe_palacios',
      clubId: 'san_fernando',
      nombre: 'Felipe',
      apellido: 'Palacios',
      posicion: 'Lateral derecho',
      numeroPreferido: '61',
      esArquero: false,
    ),
    PlayerProfile(
      playerId: 'sf_agustin_del_groso',
      clubId: 'san_fernando',
      nombre: 'Agustin',
      apellido: 'Del Groso',
      posicion: 'Pivot',
      numeroPreferido: '37',
      esArquero: false,
    ),
    PlayerProfile(
      playerId: 'sf_facundo_avero',
      clubId: 'san_fernando',
      nombre: 'Facundo',
      apellido: 'Avero',
      posicion: 'Pivot',
      numeroPreferido: '55',
      esArquero: false,
    ),
    PlayerProfile(
      playerId: 'sf_lorenzo_guinazu',
      clubId: 'san_fernando',
      nombre: 'Lorenzo',
      apellido: 'Guinazu',
      posicion: 'Lateral izquierdo',
      numeroPreferido: '4',
      esArquero: false,
    ),
    PlayerProfile(
      playerId: 'sf_lautaro_zapata',
      clubId: 'san_fernando',
      nombre: 'Lautaro',
      apellido: 'Zapata',
      posicion: 'Arquero',
      numeroPreferido: '1',
      esArquero: true,
    ),
    PlayerProfile(
      playerId: 'sf_gabriel_farias',
      clubId: 'san_fernando',
      nombre: 'Gabriel',
      apellido: 'Farias',
      posicion: 'DT',
      numeroPreferido: 'DT',
      esArquero: false,
      esCuerpoTecnico: true,
    ),
    PlayerProfile(
      playerId: 'sf_lorenzo_baron_siccardi',
      clubId: 'san_fernando',
      nombre: 'Lorenzo',
      apellido: 'Baron Siccardi',
      numeroPreferido: '5',
      esArquero: false,
    ),
    PlayerProfile(
      playerId: 'sf_luciano_farfallini',
      clubId: 'san_fernando',
      nombre: 'Luciano',
      apellido: 'Farfallini',
      numeroPreferido: '7',
      esArquero: false,
    ),
    PlayerProfile(
      playerId: 'sf_valentin_villar_senra',
      clubId: 'san_fernando',
      nombre: 'Valentin',
      apellido: 'Villar Senra',
      numeroPreferido: '8',
      esArquero: false,
    ),
    PlayerProfile(
      playerId: 'sf_juan_manuel_medan',
      clubId: 'san_fernando',
      nombre: 'Juan Manuel',
      apellido: 'Medan',
      numeroPreferido: '9',
      esArquero: false,
    ),
    PlayerProfile(
      playerId: 'sf_francisco_javier_sanches',
      clubId: 'san_fernando',
      nombre: 'Francisco Javier',
      apellido: 'Sanches',
      posicion: 'Arquero',
      numeroPreferido: '12',
      esArquero: true,
    ),
    PlayerProfile(
      playerId: 'sf_mario_bautista_salgado',
      clubId: 'san_fernando',
      nombre: 'Mario Bautista',
      apellido: 'Salgado',
      numeroPreferido: '16',
      esArquero: false,
    ),
    PlayerProfile(
      playerId: 'sf_bautista_dominguez_bianco',
      clubId: 'san_fernando',
      nombre: 'Bautista',
      apellido: 'Dominguez Bianco',
      numeroPreferido: '17',
      esArquero: false,
    ),
    PlayerProfile(
      playerId: 'sf_agustin_emanuel_drewanz',
      clubId: 'san_fernando',
      nombre: 'Agustin Emanuel',
      apellido: 'Drewanz',
      numeroPreferido: '20',
      esArquero: false,
    ),
    PlayerProfile(
      playerId: 'sf_tiziano_folino_carames',
      clubId: 'san_fernando',
      nombre: 'Tiziano',
      apellido: 'Folino Carames',
      numeroPreferido: '22',
      esArquero: false,
    ),
    PlayerProfile(
      playerId: 'sf_felipe_verdejo',
      clubId: 'san_fernando',
      nombre: 'Felipe',
      apellido: 'Verdejo',
      posicion: 'Arquero',
      numeroPreferido: '23',
      esArquero: true,
    ),
    PlayerProfile(
      playerId: 'sf_lucas_riesgo_santos',
      clubId: 'san_fernando',
      nombre: 'Lucas',
      apellido: 'Riesgo Santos',
      numeroPreferido: '26',
      esArquero: false,
    ),
    PlayerProfile(
      playerId: 'sf_alvaro_joaquin_alcaraz',
      clubId: 'san_fernando',
      nombre: 'Alvaro Joaquin',
      apellido: 'Alcaraz',
      numeroPreferido: '28',
      esArquero: false,
    ),
    PlayerProfile(
      playerId: 'sf_jairo_uriel_perez',
      clubId: 'san_fernando',
      nombre: 'Jairo Uriel',
      apellido: 'Perez',
      numeroPreferido: '39',
      esArquero: false,
    ),
    PlayerProfile(
      playerId: 'sf_benicio_dominguez_rividdi',
      clubId: 'san_fernando',
      nombre: 'Benicio',
      apellido: 'Dominguez Rividdi',
      numeroPreferido: '74',
      esArquero: false,
    ),
    PlayerProfile(
      playerId: 'sf_alejo_ricalde',
      clubId: 'san_fernando',
      nombre: 'Alejo',
      apellido: 'Ricalde',
      numeroPreferido: '76',
      esArquero: false,
    ),
    PlayerProfile(
      playerId: 'sf_federico_fernandez',
      clubId: 'san_fernando',
      nombre: 'Federico',
      apellido: 'Fernandez',
      posicion: 'DT',
      numeroPreferido: 'DT',
      esArquero: false,
      esCuerpoTecnico: true,
    ),
  ];

  static const List<RosterAssignment> assignments = [
    RosterAssignment(
      playerId: 'sf_bautista_galante_saavedra',
      categoria: 'Cadetes',
      temporada: '2026',
      numeroEnCategoria: '33',
    ),
    RosterAssignment(
      playerId: 'sf_juan_frascarelli',
      categoria: 'Cadetes',
      temporada: '2026',
      numeroEnCategoria: '77',
    ),
    RosterAssignment(
      playerId: 'sf_julian_della_vecchia',
      categoria: 'Cadetes',
      temporada: '2026',
      numeroEnCategoria: '54',
    ),
    RosterAssignment(
      playerId: 'sf_joaquin_leon_rodriguez',
      categoria: 'Cadetes',
      temporada: '2026',
      numeroEnCategoria: '26',
    ),
    RosterAssignment(
      playerId: 'sf_juan_pundang',
      categoria: 'Cadetes',
      temporada: '2026',
      numeroEnCategoria: '78',
    ),
    RosterAssignment(
      playerId: 'sf_francisco_parente',
      categoria: 'Cadetes',
      temporada: '2026',
      numeroEnCategoria: '2',
    ),
    RosterAssignment(
      playerId: 'sf_lucas_fontana_bondar',
      categoria: 'Cadetes',
      temporada: '2026',
      numeroEnCategoria: '7',
    ),
    RosterAssignment(
      playerId: 'sf_bautista_villarino',
      categoria: 'Cadetes',
      temporada: '2026',
      numeroEnCategoria: '32',
    ),
    RosterAssignment(
      playerId: 'sf_ulises_lopez_aranda',
      categoria: 'Cadetes',
      temporada: '2026',
      numeroEnCategoria: '17',
    ),
    RosterAssignment(
      playerId: 'sf_felipe_palacios',
      categoria: 'Cadetes',
      temporada: '2026',
      numeroEnCategoria: '61',
    ),
    RosterAssignment(
      playerId: 'sf_agustin_del_groso',
      categoria: 'Cadetes',
      temporada: '2026',
      numeroEnCategoria: '37',
    ),
    RosterAssignment(
      playerId: 'sf_facundo_avero',
      categoria: 'Cadetes',
      temporada: '2026',
      numeroEnCategoria: '55',
    ),
    RosterAssignment(
      playerId: 'sf_lorenzo_guinazu',
      categoria: 'Cadetes',
      temporada: '2026',
      numeroEnCategoria: '4',
    ),
    RosterAssignment(
      playerId: 'sf_lautaro_zapata',
      categoria: 'Cadetes',
      temporada: '2026',
      numeroEnCategoria: '1',
    ),
    RosterAssignment(
      playerId: 'sf_gabriel_farias',
      categoria: 'Cadetes',
      temporada: '2026',
      numeroEnCategoria: 'DT',
    ),
    RosterAssignment(
      playerId: 'sf_lorenzo_baron_siccardi',
      categoria: 'Juveniles',
      temporada: '2026',
      numeroEnCategoria: '5',
    ),
    RosterAssignment(
      playerId: 'sf_luciano_farfallini',
      categoria: 'Juveniles',
      temporada: '2026',
      numeroEnCategoria: '7',
    ),
    RosterAssignment(
      playerId: 'sf_valentin_villar_senra',
      categoria: 'Juveniles',
      temporada: '2026',
      numeroEnCategoria: '8',
    ),
    RosterAssignment(
      playerId: 'sf_juan_manuel_medan',
      categoria: 'Juveniles',
      temporada: '2026',
      numeroEnCategoria: '9',
    ),
    RosterAssignment(
      playerId: 'sf_francisco_javier_sanches',
      categoria: 'Juveniles',
      temporada: '2026',
      numeroEnCategoria: '12',
    ),
    RosterAssignment(
      playerId: 'sf_mario_bautista_salgado',
      categoria: 'Juveniles',
      temporada: '2026',
      numeroEnCategoria: '16',
    ),
    RosterAssignment(
      playerId: 'sf_bautista_dominguez_bianco',
      categoria: 'Juveniles',
      temporada: '2026',
      numeroEnCategoria: '17',
    ),
    RosterAssignment(
      playerId: 'sf_agustin_emanuel_drewanz',
      categoria: 'Juveniles',
      temporada: '2026',
      numeroEnCategoria: '20',
    ),
    RosterAssignment(
      playerId: 'sf_tiziano_folino_carames',
      categoria: 'Juveniles',
      temporada: '2026',
      numeroEnCategoria: '22',
    ),
    RosterAssignment(
      playerId: 'sf_felipe_verdejo',
      categoria: 'Juveniles',
      temporada: '2026',
      numeroEnCategoria: '23',
    ),
    RosterAssignment(
      playerId: 'sf_lucas_riesgo_santos',
      categoria: 'Juveniles',
      temporada: '2026',
      numeroEnCategoria: '26',
    ),
    RosterAssignment(
      playerId: 'sf_alvaro_joaquin_alcaraz',
      categoria: 'Juveniles',
      temporada: '2026',
      numeroEnCategoria: '28',
    ),
    RosterAssignment(
      playerId: 'sf_jairo_uriel_perez',
      categoria: 'Juveniles',
      temporada: '2026',
      numeroEnCategoria: '39',
    ),
    RosterAssignment(
      playerId: 'sf_benicio_dominguez_rividdi',
      categoria: 'Juveniles',
      temporada: '2026',
      numeroEnCategoria: '74',
    ),
    RosterAssignment(
      playerId: 'sf_alejo_ricalde',
      categoria: 'Juveniles',
      temporada: '2026',
      numeroEnCategoria: '76',
    ),
    RosterAssignment(
      playerId: 'sf_federico_fernandez',
      categoria: 'Juveniles',
      temporada: '2026',
      numeroEnCategoria: 'DT',
    ),
  ];

  static List<PlayerProfile> rosterForCategory({
    required String categoria,
    required String temporada,
    bool includeStaff = false,
  }) {
    final categoriaNormalizada = normalizeHandballText(categoria);
    final temporadaNormalizada = normalizeHandballText(temporada);

    final ids = assignments
        .where(
          (a) =>
              normalizeHandballText(a.categoria) == categoriaNormalizada &&
              normalizeHandballText(a.temporada) == temporadaNormalizada &&
              a.activo,
        )
        .map((a) => a.playerId)
        .toSet();

    final result = players.where((p) {
      if (!ids.contains(p.playerId)) return false;
      if (!includeStaff && p.esCuerpoTecnico) return false;
      return true;
    }).toList();

    result.sort((a, b) {
      final aNum = int.tryParse(a.numeroPreferido ?? '');
      final bNum = int.tryParse(b.numeroPreferido ?? '');

      if (aNum == null && bNum == null) {
        return a.apellido.compareTo(b.apellido);
      }

      if (aNum == null) return 1;
      if (bNum == null) return -1;

      return aNum.compareTo(bNum);
    });

    return result;
  }

  static List<PlayerProfile> goalkeepersForCategory({
    required String categoria,
    required String temporada,
  }) {
    return rosterForCategory(
      categoria: categoria,
      temporada: temporada,
      includeStaff: false,
    ).where((p) => p.esArquero).toList();
  }

  static PlayerProfile? findByPreferredNumber(String? number) {
    if (number == null) return null;
    for (final p in players) {
      if (p.numeroPreferido == number) return p;
    }
    return null;
  }
}

/// ===============================
/// ROSTER STORAGE 2.1
/// Guarda y lee el plantel base por categoría/temporada.
/// Si no hay datos guardados, usa RosterRepository hardcodeado.
/// ===============================
class RosterStorage {
  static String _normalize(dynamic value) {
    return (value ?? '')
        .toString()
        .trim()
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ü', 'u')
        .replaceAll('ñ', 'n')
        .replaceAll(RegExp(r'\s+'), '_')
        .replaceAll(RegExp(r'[^a-z0-9_]'), '');
  }

  static bool _isSanFernandoInstitution(String? institutionId) {
    final id = _normalize(institutionId);
    return id == 'san_fernando_handball' || id == 'san_fernando';
  }

  static String _legacyKey({
    required String categoria,
    required String temporada,
  }) {
    return 'roster_${temporada}_$categoria';
  }

  static String _key({
    required String? institutionId,
    required String categoria,
    required String temporada,
  }) {
    final safeInstitutionId = _normalize(institutionId);

    if (safeInstitutionId.isEmpty) {
      return _legacyKey(categoria: categoria, temporada: temporada);
    }

    return 'roster_${safeInstitutionId}_${temporada}_$categoria';
  }

  static Future<List<PlayerProfile>> readRosterForCategory({
    required String categoria,
    required String temporada,
    String? institutionId,
    bool includeStaff = false,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final scopedKey = _key(
      institutionId: institutionId,
      categoria: categoria,
      temporada: temporada,
    );

    final rawScoped = prefs.getString(scopedKey);

    if (rawScoped != null && rawScoped.trim().isNotEmpty) {
      return _decodeRoster(rawScoped, includeStaff: includeStaff);
    }

    final legacyKey = _legacyKey(categoria: categoria, temporada: temporada);
    final rawLegacy = prefs.getString(legacyKey);

    if (_isSanFernandoInstitution(institutionId) &&
        rawLegacy != null &&
        rawLegacy.trim().isNotEmpty) {
      return _decodeRoster(rawLegacy, includeStaff: includeStaff);
    }

    if (_isSanFernandoInstitution(institutionId)) {
      return RosterRepository.rosterForCategory(
        categoria: categoria,
        temporada: temporada,
        includeStaff: includeStaff,
      );
    }

    return const [];
  }

  static List<PlayerProfile> _decodeRoster(
    String raw, {
    required bool includeStaff,
  }) {
    try {
      final decoded = jsonDecode(raw);

      if (decoded is! List) {
        return const [];
      }

      final players = decoded
          .whereType<Map>()
          .map((e) => PlayerProfile.fromMap(Map<String, dynamic>.from(e)))
          .where((p) => includeStaff || !p.esCuerpoTecnico)
          .toList();

      players.sort((a, b) {
        final aNum = int.tryParse(a.numeroPreferido ?? '');
        final bNum = int.tryParse(b.numeroPreferido ?? '');

        if (aNum == null && bNum == null) {
          return a.apellido.compareTo(b.apellido);
        }

        if (aNum == null) return 1;
        if (bNum == null) return -1;

        return aNum.compareTo(bNum);
      });

      return players;
    } catch (_) {
      return const [];
    }
  }

  static Future<void> saveRosterForCategory({
    required String categoria,
    required String temporada,
    String? institutionId,
    required List<PlayerProfile> players,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final key = _key(
      institutionId: institutionId,
      categoria: categoria,
      temporada: temporada,
    );

    final data = players.map((p) => p.toMap()).toList();

    await prefs.setString(key, jsonEncode(data));
  }

  static Future<void> seedCategoryIfEmpty({
    required String categoria,
    required String temporada,
    String? institutionId,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final key = _key(
      institutionId: institutionId,
      categoria: categoria,
      temporada: temporada,
    );

    if (prefs.containsKey(key)) return;

    if (!_isSanFernandoInstitution(institutionId)) {
      return;
    }

    final base = RosterRepository.rosterForCategory(
      categoria: categoria,
      temporada: temporada,
      includeStaff: true,
    );

    await saveRosterForCategory(
      categoria: categoria,
      temporada: temporada,
      institutionId: institutionId,
      players: base,
    );
  }
}

class MatchSquadConfig {
  final Set<String> convocadosIds;
  final Set<String> arquerosIds;

  const MatchSquadConfig({
    required this.convocadosIds,
    required this.arquerosIds,
  });

  Map<String, dynamic> toMap() {
    return {
      'convocadosIds': convocadosIds.toList(),
      'arquerosIds': arquerosIds.toList(),
    };
  }

  factory MatchSquadConfig.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return const MatchSquadConfig(
        convocadosIds: <String>{},
        arquerosIds: <String>{},
      );
    }

    final convocadosRaw = (map['convocadosIds'] as List?) ?? const [];
    final arquerosRaw = (map['arquerosIds'] as List?) ?? const [];

    return MatchSquadConfig(
      convocadosIds: convocadosRaw.map((e) => e.toString()).toSet(),
      arquerosIds: arquerosRaw.map((e) => e.toString()).toSet(),
    );
  }
}

class MatchSquadScreen extends StatefulWidget {
  final Map<String, dynamic> partido;

  const MatchSquadScreen({super.key, required this.partido});

  @override
  State<MatchSquadScreen> createState() => _MatchSquadScreenState();
}

class _MatchSquadScreenState extends State<MatchSquadScreen> {
  late Set<String> convocadosIds;
  late Set<String> arquerosIds;

  String get categoria => (widget.partido['categoria'] ?? 'Cadetes').toString();
  String get temporada => '2026';
  String? get institutionId {
    final value = widget.partido['institutionId']?.toString().trim();

    if (value == null || value.isEmpty || value.toLowerCase() == 'null') {
      return null;
    }

    return value;
  }

  late Future<List<PlayerProfile>> _rosterFuture;

  List<PlayerProfile> _rosterPrincipal = [];
  List<PlayerProfile> _rosterExtras = [];

  final Map<String, String> _categoriaPorJugadorId = {};

  List<String> get _ordenCategorias => const [
    'Mini',
    'Infantiles',
    'Menores',
    'Cadetes',
    'Juveniles',
    'Juniors',
    'Mayores',
  ];

  List<String> get _categoriasInferioresHabilitadas {
    final categoriaNormalizada = categoria.trim().toLowerCase();

    final reglasConvocatoria = <String, List<String>>{
      'cadetes': ['Menores'],
      'juveniles': ['Cadetes'],
      'juniors': ['Juveniles'],

      /// Ligas / Mayores pueden usar dos categorías inferiores inmediatas.
      'mayores': ['Juniors', 'Juveniles'],
      'liga': ['Juniors', 'Juveniles'],
      'primera': ['Juniors', 'Juveniles'],
    };

    return reglasConvocatoria[categoriaNormalizada] ?? [];
  }

  Future<List<PlayerProfile>> _loadRoster() async {
    await RosterStorage.seedCategoryIfEmpty(
      categoria: categoria,
      temporada: temporada,
      institutionId: institutionId,
    );

    final principal = await RosterStorage.readRosterForCategory(
      categoria: categoria,
      temporada: temporada,
      institutionId: institutionId,
      includeStaff: false,
    );

    final extras = <PlayerProfile>[];

    for (final cat in _categoriasInferioresHabilitadas) {
      await RosterStorage.seedCategoryIfEmpty(
        categoria: cat,
        temporada: temporada,
        institutionId: institutionId,
      );

      final rosterCat = await RosterStorage.readRosterForCategory(
        categoria: cat,
        temporada: temporada,
        institutionId: institutionId,
        includeStaff: false,
      );

      for (final jugador in rosterCat) {
        extras.add(jugador);
        _categoriaPorJugadorId[jugador.playerId] = cat;
      }
    }

    for (final jugador in principal) {
      _categoriaPorJugadorId[jugador.playerId] = categoria;
    }

    _rosterPrincipal = principal;
    _rosterExtras = extras;

    if (convocadosIds.isEmpty && arquerosIds.isEmpty) {
      final arquerosDefault = principal
          .where((p) => p.esArquero && !p.esCuerpoTecnico)
          .map((p) => p.playerId)
          .toSet();

      convocadosIds = {...arquerosDefault};
      arquerosIds = {...arquerosDefault};
    }

    return <PlayerProfile>[...principal, ...extras];
  }

  @override
  void initState() {
    super.initState();

    final saved = MatchSquadConfig.fromMap(
      widget.partido['matchSquad'] as Map<String, dynamic>?,
    );

    convocadosIds = {...saved.convocadosIds};
    arquerosIds = {...saved.arquerosIds};

    _rosterFuture = _loadRoster();
  }

  List<PlayerProfile> get _titularesCategoria {
    return _rosterPrincipal.where((p) => !p.esCuerpoTecnico).toList();
  }

  List<PlayerProfile> get _extrasDisponibles {
    final idsPrincipales = _rosterPrincipal.map((p) => p.playerId).toSet();

    return _rosterExtras
        .where(
          (p) => !p.esCuerpoTecnico && !idsPrincipales.contains(p.playerId),
        )
        .toList();
  }

  void _toggleConvocado(PlayerProfile player, bool? selected) {
    setState(() {
      final value = selected ?? false;

      if (value) {
        convocadosIds.add(player.playerId);
      } else {
        convocadosIds.remove(player.playerId);
        arquerosIds.remove(player.playerId);
      }
    });
  }

  void _toggleArquero(PlayerProfile player, bool? selected) {
    setState(() {
      final value = selected ?? false;

      if (value) {
        convocadosIds.add(player.playerId);
        arquerosIds.add(player.playerId);
      } else {
        arquerosIds.remove(player.playerId);
      }
    });
  }

  void _guardar() {
    final todos = [..._rosterPrincipal, ..._rosterExtras];

    /// Solo se guardan los jugadores realmente convocados.
    /// Esto evita que el partido en vivo reciba todo el plantel completo.
    final convocados = todos.where((p) {
      return convocadosIds.contains(p.playerId);
    }).toList();

    widget.partido['matchSquad'] = MatchSquadConfig(
      convocadosIds: convocadosIds,
      arquerosIds: arquerosIds,
    ).toMap();

    /// Snapshot real del partido.
    /// Incluye:
    /// - arqueros convocados por defecto
    /// - jugadores de campo solo si fueron seleccionados manualmente
    /// - categoría de origen para refuerzos
    widget.partido['matchRosterSnapshot'] = convocados.map((p) {
      return {
        ...p.toMap(),
        'categoriaOrigen': _categoriaPorJugadorId[p.playerId] ?? categoria,
        'convocado': true,
        'arqueroPartido': arquerosIds.contains(p.playerId),
      };
    }).toList();

    Navigator.pop(context, widget.partido['matchSquad']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Plantel del partido'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/fondohd.jpeg',
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
          ),
          Positioned.fill(
            child: Container(color: const Color(0xFF05080D).withOpacity(0.88)),
          ),
          SafeArea(
            child: FutureBuilder<List<PlayerProfile>>(
              future: _rosterFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                return ListView(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                  children: [
                    Text(
                      '${widget.partido['categoria']} · ${widget.partido['torneo']}',
                      style: const TextStyle(
                        color: Color(0xFFD4DCE7),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 18),

                    _buildSectionCard(
                      title: 'Convocados $categoria',
                      subtitle: 'Plantel principal de la categoría',
                      players: _titularesCategoria,
                    ),

                    if (_extrasDisponibles.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      _buildSectionCard(
                        title: 'Refuerzos habilitados',
                        subtitle:
                            'Jugadores de ${_categoriasInferioresHabilitadas.join(', ')}',
                        players: _extrasDisponibles,
                      ),
                    ],

                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _guardar,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4F8CFF),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: const Text(
                          'Guardar convocatoria',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required String subtitle,
    required List<PlayerProfile> players,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1722).withOpacity(0.88),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              color: Color(0xFFAAB4C3),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),

          if (players.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'No hay jugadores disponibles.',
                style: TextStyle(color: Color(0xFFAAB4C3), fontSize: 13),
              ),
            ),

          ...players.map((p) {
            final convocado = convocadosIds.contains(p.playerId);
            final arquero = arquerosIds.contains(p.playerId);
            final categoriaOrigen =
                _categoriaPorJugadorId[p.playerId] ?? categoria;

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF182338).withOpacity(0.75),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: convocado
                      ? const Color(0xFF4F8CFF).withOpacity(0.35)
                      : Colors.white.withOpacity(0.03),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: const Color(0xFF101827),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            p.numeroPreferido ?? '-',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          p.displayName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Checkbox(
                        value: convocado,
                        onChanged: (value) => _toggleConvocado(p, value),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          p.esArquero
                              ? 'Arquero · $categoriaOrigen'
                              : 'Jugador de campo · $categoriaOrigen',
                          style: const TextStyle(
                            color: Color(0xFFAAB4C3),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (p.esArquero)
                        Switch(
                          value: arquero,
                          onChanged: (value) => _toggleArquero(p, value),
                          activeColor: const Color(0xFFBDA7FF),
                        ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

/// ===============================
/// HOME PRINCIPAL
/// ===============================
///

class CompetitionCreationResult {
  final String name;
  final String type;
  final String mode;
  final bool hasFixture;
  final bool allowManualMatches;
  final bool allowKnockoutRounds;
  final List<String> tournaments;
  final List<structure.CompetitionStageConfig> stages;

  const CompetitionCreationResult({
    required this.name,
    required this.type,
    required this.mode,
    required this.hasFixture,
    required this.allowManualMatches,
    required this.allowKnockoutRounds,
    required this.tournaments,
    required this.stages,
  });
}

class CompetitionCreatorScreen extends StatefulWidget {
  final String initialName;

  const CompetitionCreatorScreen({super.key, this.initialName = ''});

  @override
  State<CompetitionCreatorScreen> createState() =>
      _CompetitionCreatorScreenState();
}

class _CompetitionCreatorScreenState extends State<CompetitionCreatorScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _stagesController = TextEditingController();

  String _mode = 'single_fixture';
  bool _allowManualMatches = true;
  bool _allowKnockoutRounds = true;

  @override
  void initState() {
    super.initState();

    final initialName = widget.initialName.trim();

    if (initialName.isNotEmpty) {
      _nameController.text = initialName;
    }

    _syncDefaultStages();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _stagesController.dispose();
    super.dispose();
  }

  bool get _hasFixture => _mode != 'loose_matches';

  String get _type {
    if (_mode == 'split_fixture') return 'local';
    return 'single';
  }

  String get _modeTitle {
    switch (_mode) {
      case 'loose_matches':
        return 'Partidos sueltos';
      case 'split_fixture':
        return 'Apertura / Clausura';
      case 'phased_fixture':
        return 'Por fases';
      case 'single_fixture':
      default:
        return 'Fixture único';
    }
  }

  void _syncDefaultStages() {
    if (_mode == 'loose_matches') {
      _stagesController.text = 'Partidos sueltos';
      _allowKnockoutRounds = false;
      return;
    }

    if (_mode == 'split_fixture') {
      _stagesController.text = 'Apertura, Clausura';
      _allowKnockoutRounds = false;
      return;
    }

    if (_mode == 'phased_fixture') {
      _stagesController.text = 'Clasificación, Playoffs';
      _allowKnockoutRounds = true;
      return;
    }

    _stagesController.text = 'Único';
    _allowKnockoutRounds = true;
  }

  List<String> _parseStages() {
    final raw = _stagesController.text.trim();

    if (raw.isEmpty) {
      if (_mode == 'loose_matches') return const ['Partidos sueltos'];
      if (_mode == 'split_fixture') return const ['Apertura', 'Clausura'];
      return const ['Único'];
    }

    final result = raw
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toSet()
        .toList();

    if (result.isEmpty) {
      return const ['Único'];
    }

    return result;
  }

  String _stageTypeForMode() {
    if (_mode == 'loose_matches') return 'friendly';
    if (_mode == 'phased_fixture') return 'phase';
    return 'league';
  }

  void _submit() {
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresá el nombre de la competencia.')),
      );
      return;
    }

    final tournaments = _parseStages();

    final stages = List.generate(tournaments.length, (index) {
      final stageName = tournaments[index];

      return structure.CompetitionStageConfig(
        id: structure.StructureRepository.stageIdFromName(stageName),
        name: stageName,
        order: index,
        hasFixture: _hasFixture,
        allowManualMatches: _allowManualMatches,
        allowKnockoutRounds: _allowKnockoutRounds,
        stageType: _stageTypeForMode(),
      );
    });

    Navigator.pop(
      context,
      CompetitionCreationResult(
        name: name,
        type: _type,
        mode: _mode,
        hasFixture: _hasFixture,
        allowManualMatches: _allowManualMatches,
        allowKnockoutRounds: _allowKnockoutRounds,
        tournaments: tournaments,
        stages: stages,
      ),
    );
  }

  void _setMode(String value) {
    setState(() {
      _mode = value;
      _syncDefaultStages();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Crear competencia'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/fondohd.jpeg',
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
          ),
          Positioned.fill(
            child: Container(color: const Color(0xFF05080D).withOpacity(0.88)),
          ),
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
              children: [
                const Text(
                  'Configuración flexible',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Definí cómo se organiza esta competencia. La app va a usar esta estructura para fixtures, partidos sueltos y futuras fases.',
                  style: TextStyle(
                    color: Color(0xFFAAB4C3),
                    fontSize: 13,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 18),
                _buildCard(
                  children: [
                    _buildTextField(
                      controller: _nameController,
                      label: 'Nombre de la competencia',
                      hint: 'Ejemplo: Nacional B, Amistosos, Copa Metro',
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Tipo de competencia',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildModeTile(
                      value: 'single_fixture',
                      title: 'Fixture único',
                      subtitle:
                          'Una etapa principal. Puede ampliarse con cuartos, semifinal o final.',
                    ),
                    _buildModeTile(
                      value: 'split_fixture',
                      title: 'Apertura / Clausura',
                      subtitle:
                          'Competencia dividida en torneos o etapas independientes.',
                    ),
                    _buildModeTile(
                      value: 'phased_fixture',
                      title: 'Por fases',
                      subtitle:
                          'Clasificación, zonas, playoffs u otras fases configurables.',
                    ),
                    _buildModeTile(
                      value: 'loose_matches',
                      title: 'Partidos sueltos',
                      subtitle:
                          'Sin fixture. Ideal para amistosos o partidos independientes.',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildCard(
                  children: [
                    Text(
                      'Etapas / torneos iniciales ($_modeTitle)',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Separá las etapas con coma. Después se podrán ampliar.',
                      style: TextStyle(
                        color: Color(0xFFAAB4C3),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _stagesController,
                      label: 'Etapas',
                      hint: 'Ejemplo: Clasificación, Playoffs',
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      value: _allowManualMatches,
                      contentPadding: EdgeInsets.zero,
                      activeColor: const Color(0xFF4F8CFF),
                      title: const Text(
                        'Permitir partidos manuales',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      subtitle: const Text(
                        'Permite agregar partidos extra dentro de esta competencia.',
                        style: TextStyle(color: Color(0xFFAAB4C3)),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _allowManualMatches = value;
                        });
                      },
                    ),
                    SwitchListTile(
                      value: _allowKnockoutRounds,
                      contentPadding: EdgeInsets.zero,
                      activeColor: const Color(0xFF4F8CFF),
                      title: const Text(
                        'Permitir eliminatorias',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      subtitle: const Text(
                        'Habilita cuartos, semifinal, final u otras rondas futuras.',
                        style: TextStyle(color: Color(0xFFAAB4C3)),
                      ),
                      onChanged: _mode == 'loose_matches'
                          ? null
                          : (value) {
                              setState(() {
                                _allowKnockoutRounds = value;
                              });
                            },
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: _submit,
                    icon: const Icon(Icons.check_rounded),
                    label: const Text('Crear competencia'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4F8CFF),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      textStyle: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1722).withOpacity(0.92),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    return TextField(
      controller: controller,
      textInputAction: TextInputAction.next,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(color: Color(0xFFAAB4C3)),
        hintStyle: const TextStyle(color: Color(0xFF6B7280)),
        filled: true,
        fillColor: const Color(0xFF111A28),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFF4F8CFF)),
        ),
      ),
    );
  }

  Widget _buildModeTile({
    required String value,
    required String title,
    required String subtitle,
  }) {
    final selected = _mode == value;

    return GestureDetector(
      onTap: () => _setMode(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF4F8CFF).withOpacity(0.22)
              : const Color(0xFF182338),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? const Color(0xFF4F8CFF)
                : Colors.white.withOpacity(0.06),
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              color: selected ? const Color(0xFF7DB7FF) : Colors.white70,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color(0xFFAAB4C3),
                      fontSize: 12,
                      height: 1.25,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoadingContext = true;
  bool tieneInstitucion = false;

  String institucionNombre = '';
  String? institucionId;
  String? institucionEscudo;
  String temporadaSeleccionada = '';
  String competenciaSeleccionada = '';
  String torneoSeleccionado = '';
  String categoriaSeleccionada = '';

  String _contextStep = '';

  final SettingsRepository _settingsRepository = SettingsRepository();
  final InstitutionRepository _institutionRepository =
      const InstitutionRepository();

  final structure.StructureRepository _structureRepository =
      structure.StructureRepository();

  List<String> temporadasDinamicas = [];
  List<String> categoriasDinamicas = [];
  List<structure.CompetitionConfig> competenciasDinamicas = [];
  bool _seasonEditorVisible = false;
  final TextEditingController _seasonController = TextEditingController();
  final TextEditingController _competitionController = TextEditingController();
  final TextEditingController _tournamentController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _institutionController = TextEditingController();

  List<String> get contexto => <String>[
    temporadaSeleccionada,
    competenciaSeleccionada,
    torneoSeleccionado,
    categoriaSeleccionada,
  ];

  Future<void> _showInstitutionSwitcher() async {
    final institutions = await _institutionRepository.readInstitutions();

    if (!mounted) return;

    String newInstitutionName = '';

    final selected = await showModalBottomSheet<InstitutionModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0F1722),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (sheetContext) {
        Future<void> createInstitution() async {
          final name = newInstitutionName.trim();
          if (name.isEmpty) return;

          FocusScope.of(sheetContext).unfocus();

          await _institutionRepository.addInstitution(name: name);
          final created = await _institutionRepository.findByName(name);

          if (created != null && sheetContext.mounted) {
            Navigator.pop(sheetContext, created);
          }
        }

        return SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              20,
              20,
              MediaQuery.of(sheetContext).viewInsets.bottom + 28,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Cambiar institución',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 16),

                  ...institutions.map((institution) {
                    final isCurrent = institution.id == institucionId;

                    return GestureDetector(
                      onTap: () {
                        FocusScope.of(sheetContext).unfocus();
                        Navigator.pop(sheetContext, institution);
                      },
                      child: Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: isCurrent
                              ? const Color(0xFF4F8CFF).withOpacity(0.22)
                              : const Color(0xFF182338),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isCurrent
                                ? const Color(0xFF4F8CFF)
                                : Colors.white.withOpacity(0.06),
                          ),
                        ),
                        child: Row(
                          children: [
                            buildShieldAvatar(
                              institution.displayShieldPath,
                              size: 38,
                              padding: 6,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                institution.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            if (isCurrent)
                              const Icon(
                                Icons.check_circle_rounded,
                                color: Color(0xFF4F8CFF),
                              ),
                          ],
                        ),
                      ),
                    );
                  }),

                  const SizedBox(height: 12),
                  TextField(
                    textInputAction: TextInputAction.done,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Nueva institución',
                      hintStyle: const TextStyle(color: Color(0xFF6B7280)),
                      filled: true,
                      fillColor: const Color(0xFF111A28),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: Colors.white.withOpacity(0.08),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFF4F8CFF)),
                      ),
                    ),
                    onChanged: (value) {
                      newInstitutionName = value;
                    },
                    onSubmitted: (_) => createInstitution(),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: createInstitution,
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Crear nueva institución'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4F8CFF),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (!mounted || selected == null) return;

    setState(() {
      tieneInstitucion = true;
      institucionId = selected.id;
      institucionNombre = selected.name;
      institucionEscudo = selected.displayShieldPath;
      temporadaSeleccionada = '';
      competenciaSeleccionada = '';
      torneoSeleccionado = '';
      categoriaSeleccionada = '';
      _contextStep = 'temporada';
    });

    await _saveActiveContext();

    if (!mounted) return;

    await _showMessage('Institución seleccionada correctamente.');
  }

  @override
  void initState() {
    super.initState();
    _loadActiveContext();
  }

  @override
  void dispose() {
    _seasonController.dispose();
    _institutionController.dispose();
    _competitionController.dispose();
    _tournamentController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _createInstitutionFromEmptyState() async {
    final name = _institutionController.text.trim();

    if (name.isEmpty) {
      await _showMessage('Ingresá el nombre de la institución.');
      return;
    }

    await _institutionRepository.addInstitution(name: name);

    final institution = await _institutionRepository.findByName(name);

    if (!mounted) return;

    if (institution == null) {
      await _showMessage('No se pudo crear la institución.');
      return;
    }

    setState(() {
      tieneInstitucion = true;
      institucionId = institution.id;
      institucionNombre = institution.name;
      institucionEscudo = institution.displayShieldPath;
      temporadaSeleccionada = '';
      competenciaSeleccionada = '';
      torneoSeleccionado = '';
      categoriaSeleccionada = '';
      _contextStep = 'temporada';
      _institutionController.clear();
    });

    await _saveActiveContext();
  }

  void _openContextStep(String step) {
    setState(() {
      _contextStep = step;

      if (step == 'temporada') {
        competenciaSeleccionada = '';
        torneoSeleccionado = '';
        categoriaSeleccionada = '';
      }

      if (step == 'competencia') {
        torneoSeleccionado = '';
        categoriaSeleccionada = '';
      }

      if (step == 'torneo') {
        categoriaSeleccionada = '';
      }
    });

    _saveActiveContext();
  }

  Future<void> _selectSeasonFlow(String season) async {
    final clean = season.trim();
    if (clean.isEmpty) return;

    setState(() {
      temporadaSeleccionada = clean;
      competenciaSeleccionada = '';
      torneoSeleccionado = '';
      categoriaSeleccionada = '';
      _contextStep = 'competencia';
      _seasonController.clear();
    });

    await _saveActiveContext();
  }

  Future<void> _createOrSelectSeasonFlow() async {
    final value = _seasonController.text.trim();

    if (value.isEmpty) {
      await _showMessage('Ingresá una temporada válida.');
      return;
    }

    final exists = temporadasDinamicas.any(
      (e) => e.trim().toLowerCase() == value.toLowerCase(),
    );

    if (!exists) {
      final created = await _structureRepository.addSeason(value, institutionId: institucionId);

      if (!mounted) return;

      if (!created) {
        await _showMessage('La temporada ya existe o no es válida.');
        return;
      }

      await _loadStructureData();

      if (!mounted) return;
    }

    await _selectSeasonFlow(value);
  }

  Future<void> _selectCompetitionFlow(String competition) async {
    final clean = competition.trim();
    if (clean.isEmpty) return;

    setState(() {
      competenciaSeleccionada = clean;
      torneoSeleccionado = '';
      categoriaSeleccionada = '';
      _contextStep = 'torneo';
      _competitionController.clear();
    });

    await _saveActiveContext();
  }

  Future<void> _createOrSelectCompetitionFlow() async {
    final value = _competitionController.text.trim();

    if (value.isNotEmpty) {
      final exists = competenciasDinamicas.any(
        (e) => e.name.trim().toLowerCase() == value.toLowerCase(),
      );

      if (exists) {
        await _selectCompetitionFlow(value);
        return;
      }

      _competitionController.clear();

      await _crearCompetencia(initialName: value);
      return;
    }

    await _crearCompetencia();
  }

  Future<void> _selectTournamentFlow(String tournament) async {
    final clean = tournament.trim();
    if (clean.isEmpty) return;

    setState(() {
      torneoSeleccionado = clean;
      categoriaSeleccionada = '';
      _contextStep = 'categoria';
      _tournamentController.clear();
    });

    await _saveActiveContext();
  }

  Future<void> _createOrSelectTournamentFlow() async {
    final value = _tournamentController.text.trim();

    if (value.isEmpty) {
      await _showMessage('Ingresá un torneo válido.');
      return;
    }

    final exists = torneosDisponibles.any(
      (e) => e.trim().toLowerCase() == value.toLowerCase(),
    );

    if (!exists) {
      final created = await _structureRepository.addTournamentToCompetition(
        competitionName: competenciaSeleccionada,
        tournament: value,
      );

      if (!mounted) return;

      if (!created) {
        await _showMessage('El torneo ya existe o no es válido.');
        return;
      }

      await _loadStructureData();

      if (!mounted) return;
    }

    await _selectTournamentFlow(value);
  }

  Future<void> _selectCategoryFlow(String category) async {
    final clean = category.trim();
    if (clean.isEmpty) return;

    setState(() {
      categoriaSeleccionada = clean;
      _contextStep = '';
      _categoryController.clear();
    });

    await _saveActiveContext();
  }

  Future<void> _createOrSelectCategoryFlow() async {
    final value = _categoryController.text.trim();

    if (value.isEmpty) {
      await _showMessage('Ingresá una categoría válida.');
      return;
    }

    final exists = categoriasDinamicas.any(
      (e) => e.trim().toLowerCase() == value.toLowerCase(),
    );

    if (!exists) {
      final created = await _structureRepository.addCategory(value, institutionId: institucionId);

      if (!mounted) return;

      if (!created) {
        await _showMessage('La categoría ya existe o no es válida.');
        return;
      }

      await _loadStructureData();

      if (!mounted) return;
    }

    await _selectCategoryFlow(value);
  }

  Future<void> _loadActiveContext() async {
    final activeContext = await _settingsRepository.getActiveContext();

    if (!mounted) return;
    await _structureRepository.ensureInitialStructureFromActiveContext(
  institutionId: activeContext.institutionId,
  season: activeContext.season,
  competition: activeContext.competition,
  tournament: activeContext.tournament,
  category: activeContext.category,
);

await _loadStructureData(institutionId: activeContext.institutionId);
    final resolvedInstitutionShield = await _resolveInstitutionShieldPath(
      institutionId: activeContext.institutionId,
      institutionName: activeContext.institutionName,
    );

    if (!mounted) return;
    setState(() {
      tieneInstitucion = activeContext.hasInstitution;
      institucionId = activeContext.institutionId;
      institucionNombre = activeContext.institutionName;
      institucionEscudo = resolvedInstitutionShield;
      temporadaSeleccionada = activeContext.season;
      competenciaSeleccionada = activeContext.competition;
      torneoSeleccionado = activeContext.tournament;
      categoriaSeleccionada = activeContext.category;
      _isLoadingContext = false;
    });
  }

  Future<void> _pickAndAssignInstitutionShield() async {
    final cleanId = (institucionId ?? '').trim();
    final cleanName = institucionNombre.trim();

    if (cleanId.isEmpty && cleanName.isEmpty) {
      await _showMessage('Primero creá o seleccioná una institución.');
      return;
    }

    InstitutionModel? institution;

    if (cleanId.isNotEmpty) {
      institution = await _institutionRepository.findById(cleanId);
    }

    institution ??= await _institutionRepository.findByName(cleanName);

    if (!mounted) return;

    if (institution == null) {
      await _showMessage('No se encontró la institución actual.');
      return;
    }

    if ((institution.shieldAsset ?? '').trim().isNotEmpty) {
      await _showMessage(
        'Esta institución ya tiene un escudo incluido en la app.',
      );
      return;
    }

    const typeGroup = XTypeGroup(
      label: 'Imágenes',
      extensions: <String>['png', 'jpg', 'jpeg', 'webp'],
    );

    final file = await openFile(
      acceptedTypeGroups: const <XTypeGroup>[typeGroup],
    );

    if (file == null) return;

    final sourcePath = file.path;

    if (sourcePath.isEmpty) {
      await _showMessage('No se pudo leer la imagen seleccionada.');
      return;
    }

    final sourceFile = File(sourcePath);

    if (!await sourceFile.exists()) {
      await _showMessage('La imagen seleccionada no existe.');
      return;
    }

    final extension = sourcePath.split('.').last.toLowerCase();
    final safeExtension = ['png', 'jpg', 'jpeg', 'webp'].contains(extension)
        ? extension
        : 'png';

    final appDir = await getApplicationDocumentsDirectory();
    final shieldsDir = Directory('${appDir.path}/institution_shields');

    if (!await shieldsDir.exists()) {
      await shieldsDir.create(recursive: true);
    }

    final targetPath =
        '${shieldsDir.path}/${institution.id}_${DateTime.now().millisecondsSinceEpoch}.$safeExtension';

    await sourceFile.copy(targetPath);

    final updated = await _institutionRepository
        .updateInstitutionShieldFilePath(
          institutionId: institution.id,
          shieldFilePath: targetPath,
        );

    if (!mounted) return;

    if (!updated) {
      await _showMessage('No se pudo guardar el escudo institucional.');
      return;
    }

    final refreshed = await _institutionRepository.findById(institution.id);

    if (!mounted) return;

    final resolvedInstitution = refreshed ?? institution;

    setState(() {
      institucionId = resolvedInstitution.id;
      institucionNombre = resolvedInstitution.name;
      institucionEscudo = resolvedInstitution.displayShieldPath ?? targetPath;
    });

    await _saveActiveContext();

    if (!mounted) return;

    await _showMessage('Escudo institucional guardado correctamente.');
  }

  Future<String?> _resolveInstitutionShieldPath({
    required String? institutionId,
    required String institutionName,
  }) async {
    InstitutionModel? institution;

    final cleanId = (institutionId ?? '').trim();

    if (cleanId.isNotEmpty) {
      institution = await _institutionRepository.findById(cleanId);
    }

    institution ??= await _institutionRepository.findByName(institutionName);

    return institution?.displayShieldPath;
  }

  Future<void> _loadStructureData({String? institutionId}) async {
  final targetInstitutionId = institutionId ?? institucionId;

  final seasons = await _structureRepository.getSeasons(
    institutionId: targetInstitutionId,
  );

  final categories = await _structureRepository.getCategories(
    institutionId: targetInstitutionId,
  );

  final competitions = await _structureRepository.getCompetitions(
    institutionId: targetInstitutionId,
  );

  if (!mounted) return;

  setState(() {
    temporadasDinamicas = seasons;
    categoriasDinamicas = categories;
    competenciasDinamicas = competitions;
  });
}

  Future<void> _saveActiveContext() async {
    await _settingsRepository.saveActiveContext(
      ActiveContext(
        hasInstitution: tieneInstitucion,
        institutionName: institucionNombre,
        institutionId: institucionId,
        season: temporadaSeleccionada,
        competition: competenciaSeleccionada,
        tournament: torneoSeleccionado,
        category: categoriaSeleccionada,
      ),
    );
  }

  Future<String?> _showTextInputDialog({
    required String title,
    required String label,
    required String hint,
  }) async {
    final controller = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0F1722),
          title: Text(title, style: const TextStyle(color: Colors.white)),
          content: TextField(
            controller: controller,
            autofocus: true,
            textInputAction: TextInputAction.done,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: label,
              hintText: hint,
              labelStyle: const TextStyle(color: Color(0xFFAAB4C3)),
              hintStyle: const TextStyle(color: Color(0xFF6B7280)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFF263244)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFF4F8CFF)),
              ),
            ),
            onSubmitted: (_) {
              Navigator.pop(dialogContext, controller.text.trim());
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, controller.text.trim());
              },
              child: const Text('Crear'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    final clean = result?.trim();
    if (clean == null || clean.isEmpty) return null;

    return clean;
  }

  Future<void> _showMessage(String message) async {
    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _selectSeasonInline(String value) async {
    final clean = value.trim();
    if (clean.isEmpty) return;

    setState(() {
      temporadaSeleccionada = clean;
      _seasonEditorVisible = false;
      _seasonController.clear();
    });

    await _saveActiveContext();
  }

  Future<void> _createOrSelectSeasonInline() async {
    final value = _seasonController.text.trim();

    if (value.isEmpty) {
      await _showMessage('Ingresá una temporada válida.');
      return;
    }

    final exists = temporadasDinamicas.any(
      (e) => e.trim().toLowerCase() == value.toLowerCase(),
    );

    if (!exists) {
      final created = await _structureRepository.addSeason(value, institutionId: institucionId);

      if (!mounted) return;

      if (!created) {
        await _showMessage('La temporada ya existe o no es válida.');
        return;
      }

      await _loadStructureData();

      if (!mounted) return;
    }

    setState(() {
      temporadaSeleccionada = value;
      _seasonEditorVisible = false;
      _seasonController.clear();
    });

    await _saveActiveContext();
  }

  Future<String?> _crearTemporada() async {
    final value = await _showTextInputDialog(
      title: 'Crear temporada',
      label: 'Temporada',
      hint: 'Ejemplo: 2027',
    );

    if (value == null) return null;

    final created = await _structureRepository.addSeason(value, institutionId: institucionId);

    if (!mounted) return null;

    if (!created) {
      await _showMessage('La temporada ya existe o no es válida.');
      return null;
    }

    return value;
  }

  Future<void> _crearCategoria() async {
    final value = await _showTextInputDialog(
      title: 'Crear categoría',
      label: 'Categoría',
      hint: 'Ejemplo: Juniors',
    );

    if (value == null) return;

    final created = await _structureRepository.addCategory(value, institutionId: institucionId);

    if (!mounted) return;

    if (!created) {
      await _showMessage('La categoría ya existe o no es válida.');
      return;
    }

    await _loadStructureData();

    if (!mounted) return;

    setState(() {
      categoriaSeleccionada = value;
    });

    await _saveActiveContext();
  }

  Future<void> _crearTorneo() async {
    if (competenciaSeleccionada.trim().isEmpty) {
      await _showMessage('Primero seleccioná una competencia.');
      return;
    }

    final value = await _showTextInputDialog(
      title: 'Crear torneo',
      label: 'Torneo',
      hint: 'Ejemplo: Copa Oro',
    );

    if (value == null) return;

    final created = await _structureRepository.addTournamentToCompetition(
  competitionName: competenciaSeleccionada,
  tournament: value,
  institutionId: institucionId,
);

    if (!mounted) return;

    if (!created) {
      await _showMessage('El torneo ya existe o no es válido.');
      return;
    }

    await _loadStructureData();

    if (!mounted) return;

    setState(() {
      torneoSeleccionado = value;
    });

    await _saveActiveContext();
  }

  Future<void> _crearCompetencia({String initialName = ''}) async {
    final result = await Navigator.push<CompetitionCreationResult>(
      context,
      MaterialPageRoute(
        builder: (_) => CompetitionCreatorScreen(initialName: initialName),
      ),
    );

    if (!mounted || result == null) return;

    final created = await _structureRepository.addCompetition(
      name: result.name,
        institutionId: institucionId,
      type: result.type,
      tournaments: result.tournaments,
      mode: result.mode,
      hasFixture: result.hasFixture,
      allowManualMatches: result.allowManualMatches,
      allowKnockoutRounds: result.allowKnockoutRounds,
      stages: result.stages,
    );

    if (!mounted) return;

    if (!created) {
      await _showMessage('La competencia ya existe o no es válida.');
      return;
    }

    await _loadStructureData();

    if (!mounted) return;

    final firstTournament = result.tournaments.isEmpty
        ? ''
        : result.tournaments.first;

    setState(() {
      competenciaSeleccionada = result.name;
      torneoSeleccionado = firstTournament;
      categoriaSeleccionada = '';
      _contextStep = 'categoria';
    });

    await _saveActiveContext();

    if (!mounted) return;

    await _showMessage('Competencia creada correctamente.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/fondohd.jpeg',
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
          ),
          Positioned.fill(
            child: Container(color: const Color(0xFF05080D).withOpacity(0.82)),
          ),
          SafeArea(
            top: false,
            bottom: true,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 46, 20, 24),
              child: _isLoadingContext
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTopIdentityRow(),
                        const SizedBox(height: 30),
                        tieneInstitucion
                            ? _buildEstadoConInstitucion()
                            : _buildEstadoSinInstitucion(context),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  /// ===============================
  /// GESTIoN ADMINISTRATIVA
  /// Menu futuro para importaciones, exportaciones y configuracion general.
  /// No pertenece a Equipo porque no es gestion deportiva directa.
  /// ===============================
  void _showGestionAdministrativaMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F1722),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Gestion administrativa',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                _buildAdminMenuOption(
                  icon: Icons.upload_file_rounded,
                  text: 'Importar jugadores',
                  onTap: () => Navigator.pop(context),
                ),
                _buildAdminMenuOption(
                  icon: Icons.calendar_month_rounded,
                  text: 'Importar fixture',
                  onTap: () => Navigator.pop(context),
                ),
                _buildAdminMenuOption(
                  icon: Icons.shield_rounded,
                  text: 'Importar escudos',
                  onTap: () => Navigator.pop(context),
                ),
                _buildAdminMenuOption(
                  icon: Icons.storage_rounded,
                  text: 'Exportar datos',
                  onTap: () {
                    Navigator.pop(context);
                    _showExportarDatosMenu();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showExportarDatosMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F1722),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Exportar datos',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                _buildAdminMenuOption(
                  icon: Icons.download_rounded,
                  text: 'Exportar backup',
                  onTap: () async {
                    Navigator.pop(context);

                    try {
                      await exportarBackupComoArchivo();
                    } catch (_) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('No se pudo exportar el backup'),
                        ),
                      );
                    }
                  },
                ),
                _buildAdminMenuOption(
                  icon: Icons.upload_rounded,
                  text: 'Importar backup',
                  onTap: () async {
                    Navigator.pop(context);

                    setState(() {
                      _isLoadingContext = true;
                    });

                    await importarBackupDesdeArchivo(context);

                    if (!mounted) return;

                    await _loadActiveContext();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  ///===============================
  /// Opcion visual del menu administrativo.
  ///================================
  Widget _buildAdminMenuOption({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
          decoration: BoxDecoration(
            color: const Color(0xFF182338),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openSection(BuildContext context, String title) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          switch (title) {
            case 'Proximo partido':
              return ProximoPartidoScreen(
                temporada: temporadaSeleccionada,
                competencia: competenciaSeleccionada,
                torneo: torneoSeleccionado,
                categoria: categoriaSeleccionada,
                tieneFixture: competenciaActualTieneFixture,
                institutionName: institucionNombre,
                institutionId: institucionId,
                institutionShieldPath: institucionEscudo,
              );

            case 'Partidos jugados':
              return HistorialScreen(
                temporada: temporadaSeleccionada,
                competencia: competenciaSeleccionada,
                torneo: torneoSeleccionado,
                categoria: categoriaSeleccionada,
                institutionName: institucionNombre,
                institutionId: institucionId,
                institutionShieldPath: institucionEscudo,
              );

            case 'Estadísticas':
              return EstadisticasScreen(
                temporada: temporadaSeleccionada,
                competencia: competenciaSeleccionada,
                torneo: torneoSeleccionado,
                categoria: categoriaSeleccionada,
                institutionName: institucionNombre,
                institutionId: institucionId,
                institutionShieldPath: institucionEscudo,
              );

            case 'Equipo':
              return EquiposScreen(
                temporada: temporadaSeleccionada,
                competencia: competenciaSeleccionada,
                torneo: torneoSeleccionado,
                categoriaInicial: categoriaSeleccionada,
                institutionId: institucionId,
              );

            default:
              return Scaffold(
                appBar: AppBar(title: Text(title)),
                body: Center(child: Text('Pantalla $title')),
              );
          }
        },
      ),
    );
  }

  void _abrirFixtureActual() {
    if (!competenciaActualTieneFixture) {
      _showMessage('Esta competencia usa partidos sueltos y no tiene fixture.');
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FixtureScreen(
          temporada: temporadaSeleccionada,
          competencia: competenciaSeleccionada,
          torneo: torneoSeleccionado,
          categoria: categoriaSeleccionada,
          institutionName: institucionNombre,
          institutionId: institucionId,
          institutionShieldPath: institucionEscudo,
        ),
      ),
    );
  }

  void _toggleCategoria() {
    setState(() {
      categoriaSeleccionada = categoriaSeleccionada == 'Cadetes'
          ? 'Juveniles'
          : 'Cadetes';
    });
  }

  void _toggleTorneo() {
    final disponibles = torneosDisponibles;

    if (disponibles.isEmpty) return;

    final actualIndex = disponibles.indexOf(torneoSeleccionado);

    final siguienteIndex = actualIndex < 0
        ? 0
        : (actualIndex + 1) % disponibles.length;

    setState(() {
      torneoSeleccionado = disponibles[siguienteIndex];
    });
  }

  List<String> get competenciasDisponibles {
    return competenciasDinamicas.map((e) => e.name).toList();
  }

  List<String> get torneosDisponibles {
    if (competenciaSeleccionada.trim().isEmpty) return const [];

    final selected = competenciasDinamicas
        .where((e) => e.name == competenciaSeleccionada)
        .toList();

    if (selected.isEmpty) return const [];

    return selected.first.tournaments;
  }

  structure.CompetitionConfig? get competenciaActualConfig {
    final actual = competenciaSeleccionada.trim().toLowerCase();

    if (actual.isEmpty) return null;

    for (final competition in competenciasDinamicas) {
      if (competition.name.trim().toLowerCase() == actual) {
        return competition;
      }
    }

    return null;
  }

  bool get competenciaActualTieneFixture {
    final competition = competenciaActualConfig;

    if (competenciaSeleccionada.trim().isEmpty) return false;

    // Compatibilidad defensiva:
    // si por algún motivo la competencia todavía no está cargada en memoria,
    // no bloqueamos el flujo existente.
    if (competition == null) return true;

    return competition.hasFixture && !competition.isLooseMatches;
  }

  Future<void> _setCompetencia(String competencia) async {
    final selected = competenciasDinamicas
        .where((e) => e.name == competencia)
        .toList();

    final torneos = selected.isEmpty
        ? const <String>[]
        : selected.first.tournaments;

    setState(() {
      competenciaSeleccionada = competencia;
      torneoSeleccionado = torneos.isEmpty ? '' : torneos.first;
    });

    await _saveActiveContext();
  }

  Future<void> _setTorneo(String torneo) async {
    setState(() {
      torneoSeleccionado = torneo;
    });

    await _saveActiveContext();
  }

  void _cancelContextStep() {
    FocusScope.of(context).unfocus();

    setState(() {
      _contextStep = '';
      _seasonController.clear();
      _competitionController.clear();
      _tournamentController.clear();
      _categoryController.clear();
    });
  }

  Widget _buildSelectableChip({
    required String text,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF4F8CFF)
              : const Color(0xFF182338).withOpacity(0.95),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? const Color(0xFF4F8CFF)
                : Colors.white.withOpacity(0.05),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildTopIdentityRow() {
    return Row(
      children: [
        ClipOval(
          child: Image.asset(
            'assets/images/logohd.jpeg',
            width: 42,
            height: 42,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 10),
        const Expanded(
          child: Text(
            'Seguimiento y análisis',
            style: TextStyle(
              fontSize: 15,
              color: Color(0xFFD5DCE5),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        IconButton(
          onPressed: _showGestionAdministrativaMenu,
          icon: const Icon(Icons.menu_rounded, color: Colors.white, size: 28),
        ),
      ],
    );
  }

  Future<void> _importarBackupDesdeEstadoVacio() async {
    setState(() {
      _isLoadingContext = true;
    });

    await importarBackupDesdeArchivo(context);

    if (!mounted) return;

    await _loadActiveContext();
  }

  Widget _buildEstadoSinInstitucion(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.72,
      child: Center(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: const Color(0xFF0F1722).withOpacity(0.82),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: const Color(0xFF4F8CFF).withOpacity(0.28),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildInstitutionBadge(),
              const SizedBox(height: 18),
              const Text(
                'No hay institución creada',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Creá una institución nueva o importá un backup existente.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.35,
                  color: Color(0xFFAAB4C3),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 18),
              TextField(
                controller: _institutionController,
                textInputAction: TextInputAction.done,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Nombre de la institución',
                  hintStyle: const TextStyle(color: Color(0xFF6B7280)),
                  filled: true,
                  fillColor: const Color(0xFF111A28),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: Colors.white.withOpacity(0.08),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFF4F8CFF)),
                  ),
                ),
                onSubmitted: (_) => _createInstitutionFromEmptyState(),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _createInstitutionFromEmptyState,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Crear institución'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F8CFF),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    textStyle: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: _importarBackupDesdeEstadoVacio,
                  icon: const Icon(Icons.upload_file_rounded),
                  label: const Text('Importar backup'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFD7DCE3),
                    side: BorderSide(color: Colors.white.withOpacity(0.10)),
                    textStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEstadoConInstitucion() {
    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: 28),
            padding: const EdgeInsets.fromLTRB(16, 52, 16, 18),
            decoration: BoxDecoration(
              color: const Color(0xFF0D1520).withOpacity(0.22),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: const Color(0xFF3FA2FF).withOpacity(0.65),
                width: 1.2,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildContextSection(),

                if (competenciaActualTieneFixture) ...[
                  const SizedBox(height: 12),
                  _buildPrimaryOutlineAction(
                    text: 'Ver fixture actual',
                    icon: Icons.calendar_month_rounded,
                    onTap: _abrirFixtureActual,
                  ),
                  const SizedBox(height: 18),
                ] else
                  const SizedBox(height: 12),
                _buildHomeActionCard(
                  icon: Icons.sports_handball_rounded,
                  title: 'Proximo partido',
                  subtitle: 'Fixture y agenda',
                ),
                const SizedBox(height: 12),
                _buildHomeActionCard(
                  icon: Icons.history_rounded,
                  title: 'Partidos jugados',
                  subtitle: 'Historial cargado',
                ),
                const SizedBox(height: 12),
                _buildHomeActionCard(
                  icon: Icons.bar_chart_rounded,
                  title: 'Estadísticas',
                  subtitle: 'Rendimiento y análisis',
                ),
                const SizedBox(height: 12),
                _buildHomeActionCard(
                  icon: Icons.groups_rounded,
                  title: 'Equipo',
                  subtitle: 'Plantel y estructura',
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            left: 18,
            right: 18,
            child: _buildInstitutionHeaderMounted(),
          ),
        ],
      ),
    );
  }

  Widget _buildInstitutionHeaderMounted() {
    return Center(
      child: GestureDetector(
        onTap: _showInstitutionSwitcher,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF0A1018).withOpacity(0.95),
            borderRadius: BorderRadius.circular(24),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildInstitutionBadge(),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    institucionNombre,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.1,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.swap_horiz_rounded,
                  color: Color(0xFF7DB7FF),
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInstitutionBadge() {
    return GestureDetector(
      onTap: tieneInstitucion ? _pickAndAssignInstitutionShield : null,
      child: buildShieldAvatar(institucionEscudo, size: 48, padding: 8),
    );
  }

  Widget _buildContextSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF111A28).withOpacity(0.55),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildContextLine(),
          if (_contextStep.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildContextStepEditor(),
          ],
        ],
      ),
    );
  }

  Widget _buildContextLine() {
    final items = <Widget>[];

    void addItem({
      required String value,
      required String fallback,
      required String step,
    }) {
      final text = value.trim().isEmpty ? fallback : value.trim();

      if (items.isNotEmpty) {
        items.add(
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 6),
            child: Text(
              '/',
              style: TextStyle(
                color: Color(0xFF8FA3BF),
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        );
      }

      items.add(
        GestureDetector(
          onTap: () => _openContextStep(step),
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: value.trim().isEmpty
                  ? const Color(0xFF8FA3BF)
                  : Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      );
    }

    addItem(
      value: temporadaSeleccionada,
      fallback: 'Temporada',
      step: 'temporada',
    );

    if (temporadaSeleccionada.trim().isNotEmpty) {
      addItem(
        value: competenciaSeleccionada,
        fallback: 'Competencia',
        step: 'competencia',
      );
    }

    if (competenciaSeleccionada.trim().isNotEmpty) {
      addItem(value: torneoSeleccionado, fallback: 'Torneo', step: 'torneo');
    }

    if (torneoSeleccionado.trim().isNotEmpty) {
      addItem(
        value: categoriaSeleccionada,
        fallback: 'Categoría',
        step: 'categoria',
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: const Color(0xFF182338),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: items),
      ),
    );
  }

  Widget _buildContextStepEditor() {
    if (_contextStep == 'temporada') {
      return _buildInlinePickerEditor(
        title: 'Elegí temporada',
        options: temporadasDinamicas,
        selectedValue: temporadaSeleccionada,
        controller: _seasonController,
        hintText: 'Nueva temporada, ejemplo: 2028',
        buttonText: 'Crear / seleccionar temporada',
        onSelect: _selectSeasonFlow,
        onCreate: _createOrSelectSeasonFlow,
      );
    }

    if (_contextStep == 'competencia') {
      return _buildInlinePickerEditor(
        title: 'Elegí competencia',
        options: competenciasDisponibles,
        selectedValue: competenciaSeleccionada,
        controller: _competitionController,
        hintText: 'Nueva competencia, ejemplo: Nacional C',
        buttonText: 'Crear / seleccionar competencia',
        onSelect: _selectCompetitionFlow,
        onCreate: _createOrSelectCompetitionFlow,
      );
    }

    if (_contextStep == 'torneo') {
      final isLocal = competenciaSeleccionada.trim().toLowerCase() == 'local';

      return _buildInlinePickerEditor(
        title: 'Elegí torneo',
        options: torneosDisponibles,
        selectedValue: torneoSeleccionado,
        controller: _tournamentController,
        hintText: isLocal
            ? 'Local usa Apertura / Clausura'
            : 'Nuevo torneo, ejemplo: Único',
        buttonText: 'Crear / seleccionar torneo',
        onSelect: _selectTournamentFlow,
        onCreate: isLocal ? null : _createOrSelectTournamentFlow,
      );
    }

    return _buildInlinePickerEditor(
      title: 'Elegí categoría',
      options: categoriasDinamicas,
      selectedValue: categoriaSeleccionada,
      controller: _categoryController,
      hintText: 'Nueva categoría, ejemplo: Juniors',
      buttonText: 'Crear / seleccionar categoría',
      onSelect: _selectCategoryFlow,
      onCreate: _createOrSelectCategoryFlow,
    );
  }

  Widget _buildInlinePickerEditor({
    required String title,
    required List<String> options,
    required String selectedValue,
    required TextEditingController controller,
    required String hintText,
    required String buttonText,
    required Future<void> Function(String) onSelect,
    required Future<void> Function()? onCreate,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF07111F).withOpacity(0.96),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF4F8CFF).withOpacity(0.35)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.28),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: options.map((item) {
              final selected = item == selectedValue;

              return GestureDetector(
                onTap: () => onSelect(item),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? const Color(0xFF4F8CFF)
                        : const Color(0xFF182338),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: selected
                          ? const Color(0xFF7DB7FF)
                          : Colors.white.withOpacity(0.06),
                    ),
                  ),
                  child: Text(
                    item,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          if (onCreate != null) ...[
            const SizedBox(height: 14),
            TextField(
              controller: controller,
              textInputAction: TextInputAction.done,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                isDense: true,
                hintText: hintText,
                hintStyle: const TextStyle(color: Color(0xFF6B7280)),
                filled: true,
                fillColor: const Color(0xFF0F1722),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 13,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFF263244)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFF4F8CFF)),
                ),
              ),
              onSubmitted: (_) => onCreate(),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton.icon(
                onPressed: onCreate,
                icon: const Icon(Icons.add_rounded, size: 19),
                label: Text(buttonText),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F8CFF),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  textStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 40,
              child: TextButton(
                onPressed: _cancelContextStep,
                child: const Text(
                  'Cancelar',
                  style: TextStyle(
                    color: Color(0xFFAAB4C3),
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildContextToken({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF182338),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
        ),
        child: Row(
          children: [
            Expanded(
              child: RichText(
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '$label: ',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    TextSpan(
                      text: value,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Colors.white70,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showSeasonPicker() async {
    final controller = TextEditingController();

    final selectedValue = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 24,
          ),
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
            decoration: BoxDecoration(
              color: const Color(0xFF0F1722),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.06)),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Seleccionar temporada',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: temporadasDinamicas.map((season) {
                      final selected = season == temporadaSeleccionada;

                      return GestureDetector(
                        onTap: () => Navigator.of(dialogContext).pop(season),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: selected
                                ? const Color(0xFF4F8CFF)
                                : const Color(0xFF182338),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: selected
                                  ? const Color(0xFF4F8CFF)
                                  : Colors.white.withOpacity(0.06),
                            ),
                          ),
                          child: Text(
                            season,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Crear temporada',
                      hintText: 'Ejemplo: 2027',
                      labelStyle: const TextStyle(color: Color(0xFFAAB4C3)),
                      hintStyle: const TextStyle(color: Color(0xFF6B7280)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFF263244)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFF4F8CFF)),
                      ),
                    ),
                    onSubmitted: (_) {
                      final value = controller.text.trim();
                      if (value.isEmpty) return;
                      Navigator.of(dialogContext).pop(value);
                    },
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        final value = controller.text.trim();
                        if (value.isEmpty) return;
                        Navigator.of(dialogContext).pop(value);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4F8CFF),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Crear / seleccionar',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    controller.dispose();

    if (!mounted) return;
    if (selectedValue == null || selectedValue.trim().isEmpty) return;

    final value = selectedValue.trim();

    if (!temporadasDinamicas.contains(value)) {
      final created = await _structureRepository.addSeason(value, institutionId: institucionId);

      if (!mounted) return;

      if (!created) {
        await _showMessage('La temporada ya existe o no es válida.');
        return;
      }

      await _loadStructureData();

      if (!mounted) return;
    }

    setState(() {
      temporadaSeleccionada = value;
    });

    await _saveActiveContext();
  }

  void _showContextPicker({
    required String title,
    required List<String> options,
    required String currentValue,
    required Future<void> Function(String) onSelected,
  }) {
    Future<void> openPicker() async {
      final selectedValue = await showDialog<String>(
        context: context,
        builder: (dialogContext) {
          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 24,
            ),
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
              decoration: BoxDecoration(
                color: const Color(0xFF0F1722),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withOpacity(0.06)),
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 520),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: options.map((option) {
                          final selected = option == currentValue;
                          final isCreate = option.startsWith('+');

                          return GestureDetector(
                            onTap: () {
                              Navigator.of(dialogContext).pop(option);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: selected
                                    ? const Color(0xFF4F8CFF)
                                    : const Color(0xFF182338),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: selected
                                      ? const Color(0xFF4F8CFF)
                                      : Colors.white.withOpacity(0.06),
                                ),
                              ),
                              child: Text(
                                option,
                                style: TextStyle(
                                  color: isCreate
                                      ? const Color(0xFF7DB7FF)
                                      : Colors.white,
                                  fontSize: 14,
                                  fontWeight: selected
                                      ? FontWeight.w900
                                      : FontWeight.w700,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );

      if (!mounted) return;
      if (selectedValue == null) return;

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        await onSelected(selectedValue);
      });
    }

    openPicker();
  }

  Widget _buildContextDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    final safeItems = items.contains(value) ? items : [value, ...items];

    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF182338).withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.035)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          dropdownColor: const Color(0xFF0F1722),
          iconEnabledColor: const Color(0xFFC9D3E0),
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFFDCE4EF),
            fontWeight: FontWeight.w600,
          ),
          items: safeItems.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: TextStyle(
                  color: item.startsWith('+')
                      ? const Color(0xFF4F8CFF)
                      : const Color(0xFFDCE4EF),
                  fontWeight: item.startsWith('+')
                      ? FontWeight.w800
                      : FontWeight.w600,
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildPrimaryOutlineAction({
    required String text,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF182338).withOpacity(0.78),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.04)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return _PressableTile(
      onTap: () {
        _openSection(context, title);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF0F1722).withOpacity(0.88),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.03)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.22),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: const Color(0xFF182338).withOpacity(0.95),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFFAAB4C3),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFFDCE4EF),
              size: 26,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecondaryButton({
    required String text,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF182338).withOpacity(0.85),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.04)),
        ),
        child: Center(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required String imagePath,
    required String title,
    required String subtitle,
  }) {
    return _PressableTile(
      onTap: () {
        _openSection(context, title);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 0),
        decoration: BoxDecoration(
          color: const Color(0xFF0F1722).withOpacity(0.88),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(color: Colors.white.withOpacity(0.03)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 110,
              height: 110,
              child: Center(
                child: Image.asset(
                  imagePath,
                  width: 110,
                  height: 110,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16.5,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFFAAB4C3),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFFDAE2EE),
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}

class _PressableTile extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _PressableTile({required this.child, required this.onTap});

  @override
  State<_PressableTile> createState() => _PressableTileState();
}

class _PressableTileState extends State<_PressableTile> {
  bool _active = false;

  void _triggerTapEffect() {
    setState(() => _active = true);
    Future.delayed(const Duration(milliseconds: 140), () {
      if (mounted) {
        setState(() => _active = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _triggerTapEffect(),
      onTap: widget.onTap,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 120),
        scale: _active ? 0.985 : 1.0,
        child: Stack(
          children: [
            widget.child,
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 170),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: _active
                        ? Colors.white.withOpacity(0.12)
                        : Colors.transparent,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ===============================
/// PRoXIMO PARTIDO
/// ===============================
/// ===============================

class ProximoPartidoScreen extends StatefulWidget {
  final String temporada;
  final String competencia;
  final String torneo;
  final String categoria;
  final bool tieneFixture;
  final String institutionName;
  final String? institutionId;
  final String? institutionShieldPath;

  const ProximoPartidoScreen({
    super.key,
    required this.temporada,
    required this.competencia,
    required this.torneo,
    required this.categoria,
    required this.tieneFixture,
    required this.institutionName,
    this.institutionId,
    this.institutionShieldPath,
  });

  @override
  State<ProximoPartidoScreen> createState() => _ProximoPartidoScreenState();
}

/// ===============================
/// ESTADO REAL V2
/// Lectura paralela del sistema nuevo:
/// - partido en vivo actual
/// - partidos finalizados reales
/// ===============================
PartidoModel? _partidoEnVivoV2;
List<PartidoModel> _finalizadosV2 = [];

class _ProximoPartidoScreenState extends State<ProximoPartidoScreen> {
  /// ===============================
  /// LOAD ESTADO REAL V2
  /// Lee partido en vivo y finalizados desde el repository 2.0
  /// ===============================

  final FixtureRepositoryV2 _fixtureRepository = const FixtureRepositoryV2();

  String? get _institutionShieldPath {
    final direct = (widget.institutionShieldPath ?? '').trim();

    if (direct.isNotEmpty && direct.toLowerCase() != 'null') {
      return direct;
    }

    final normalized = _institutionName.trim().toLowerCase();

    if (normalized == 'san fernando handball' || normalized == 'san fernando') {
      return 'assets/images/san_fernando.png';
    }

    return null;
  }

  List<PartidoModel> _customFixturesV2 = [];

  Future<void> _loadEstadoRealV2() async {
    final live = await PartidoRepositoryV2.readLiveMatch();
    final finished = await PartidoRepositoryV2.readFinishedMatches();

    if (!mounted) return;

    setState(() {
      _partidoEnVivoV2 = live;
      _finalizadosV2 = finished;
    });
  }

  bool _isAssetShieldPath(String? value) {
    return (value ?? '').trim().startsWith('assets/');
  }

  Widget _buildShieldImage(String? path, {double size = 18}) {
    final cleanPath = (path ?? '').trim();

    if (cleanPath.isEmpty) {
      return Icon(
        Icons.sports_handball,
        size: size,
        color: const Color(0xFF1C2B44),
      );
    }

    if (_isAssetShieldPath(cleanPath)) {
      return Image.asset(
        cleanPath,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) {
          return Icon(
            Icons.sports_handball,
            size: size,
            color: const Color(0xFF1C2B44),
          );
        },
      );
    }

    return Image.file(
      File(cleanPath),
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) {
        return Icon(
          Icons.sports_handball,
          size: size,
          color: const Color(0xFF1C2B44),
        );
      },
    );
  }

  bool hayPartido = true;

  Map<String, dynamic> proximoPartido = {};
  List<Map<String, dynamic>> siguientesPartidos = [];
  List<Map<String, dynamic>> partidosFinalizados = [];

  ActiveContext get _activeContext {
    return ActiveContext(
      hasInstitution: true,
      institutionName: _institutionName,
      institutionId: widget.institutionId,
      season: widget.temporada,
      competition: widget.competencia,
      tournament: widget.torneo,
      category: widget.categoria,
    );
  }

  String get _contextStorageSuffix {
    return AppContextKey.fromActiveContext(_activeContext);
  }

  String get _proximoPartidoStorageKey =>
      'proximo_partido_$_contextStorageSuffix';

  String get _siguientesPartidosStorageKey =>
      'siguientes_$_contextStorageSuffix';

  String get _partidosFinalizadosStorageKey =>
      'finalizados_$_contextStorageSuffix';

  String get _institutionTitle {
    final value = widget.institutionName.trim();

    if (value.isEmpty || value.toLowerCase() == 'null') {
      return 'Institución';
    }

    return value;
  }

  String get _institutionName => _institutionTitle;

  static const String _liveMatchStorageKey = 'live_match_current_v1';
  static const String _finishedMatchesStorageKey =
      'finished_matches_history_v1';

  /// ===============================
  /// MATCH IDENTITY HELPERS V2
  /// Permiten comparar Map actual con PartidoModel
  /// ===============================
  String _identityFromMap(Map<String, dynamic> partido) {
    return PartidoRepositoryV2.buildMatchIdentityFromMap(partido);
  }

  bool _estaFinalizadoV2(Map<String, dynamic> partido) {
    if (!_esPartidoValido(partido)) return false;

    final identidad = _identityFromMap(partido);

    return _finalizadosV2.any((p) {
      return PartidoRepositoryV2.buildMatchIdentityFromModel(p) == identidad;
    });
  }

  /// ===============================
  /// VALIDACIÓN LOCAL DEL MAPA PARTIDO
  /// Evita pantallas con null/null cuando quedó un próximo corrupto en prefs.
  /// ===============================
  bool _esPartidoValido(Map<String, dynamic> partido) {
    final rival = (partido['rival'] ?? '').toString().trim();
    final fecha = (partido['fecha'] ?? '').toString().trim();
    final hora = (partido['hora'] ?? '').toString().trim();
    final categoria = (partido['categoria'] ?? '').toString().trim();
    final torneo = (partido['torneo'] ?? '').toString().trim();

    return partido.isNotEmpty &&
        rival.isNotEmpty &&
        rival != 'null' &&
        fecha.isNotEmpty &&
        fecha != 'null' &&
        hora.isNotEmpty &&
        hora != 'null' &&
        categoria.isNotEmpty &&
        categoria != 'null' &&
        torneo.isNotEmpty &&
        torneo != 'null';
  }

  /// ===============================
  /// FINALIZADO GLOBAL
  /// Compara contra V2 y contra historial legado ya mergeado.
  /// ===============================
  bool _estaFinalizadoGlobal(Map<String, dynamic> partido) {
    if (!_esPartidoValido(partido)) return false;

    final identidad = _identityFromMap(partido);

    final enV2 = _estaFinalizadoV2(partido);

    final enLegacy = partidosFinalizados.any((p) {
      return PartidoRepositoryV2.buildMatchIdentityFromMap(p) == identidad ||
          _partidoIdentity(p) == _partidoIdentity(partido);
    });

    return enV2 || enLegacy;
  }

  /// ===============================
  /// RECALCULAR PRoXIMO PARTIDO DESDE FIXTURE BASE
  /// Si el proximo actual quedo inválido, toma el primer pendiente real
  /// y recompone tambien los siguientes partidos.
  /// ===============================
  /// ===============================
  /// RECALCULAR PRoXIMO Y SIGUIENTES DESDE FIXTURE BASE
  /// Usa solo el fixture base del torneo/categoría actual
  /// y filtra por partidos no finalizados segun V2.
  /// ===============================

  void _recalcularProximoYSiguientesDesdeBase() {
    final todos = _buildFixtureCompleto(
      categoria: widget.categoria,
    ).where(_matchesCurrentContext).toList();

    final pendientes = todos.where((p) {
      return _esPartidoValido(p) && !_estaFinalizadoGlobal(p);
    }).toList();

    pendientes.sort((a, b) {
      final fa = (a['fechaNumero'] as int?) ?? 999999;
      final fb = (b['fechaNumero'] as int?) ?? 999999;

      final byFecha = fa.compareTo(fb);
      if (byFecha != 0) return byFecha;

      return (a['rival'] ?? '').toString().toLowerCase().compareTo(
        (b['rival'] ?? '').toString().toLowerCase(),
      );
    });

    if (pendientes.isEmpty) {
      proximoPartido = {};
      siguientesPartidos = [];
      hayPartido = false;
      return;
    }

    proximoPartido = Map<String, dynamic>.from(pendientes.first);

    siguientesPartidos = pendientes.skip(1).map((p) {
      return {
        'temporada': p['temporada'],
        'competencia': p['competencia'],
        'rival': p['rival'],
        'institutionId': p['institutionId'] ?? widget.institutionId,
        'equipoPropio': p['equipoPropio'] ?? _institutionName,
        'escudoPropio': p['escudoPropio'] ?? _institutionShieldPath,
        'fechaNumero': p['fechaNumero'],
        'fecha': p['fecha'],
        'hora': p['hora'],
        'condicion': p['condicion'],
        'torneo': p['torneo'],
        'categoria': p['categoria'],
        'escudoRival': p['escudoRival'],
        'estado': p['estado'],
        'estadoPartido': p['estadoPartido'],
      };
    }).toList();

    hayPartido = true;
  }

  bool _matchesCurrentContext(Map<String, dynamic> partido) {
    final sameBase =
        FixtureRepositoryV2.normalize(partido['temporada']) ==
            FixtureRepositoryV2.normalize(widget.temporada) &&
        FixtureRepositoryV2.normalize(partido['competencia']) ==
            FixtureRepositoryV2.normalize(widget.competencia) &&
        FixtureRepositoryV2.normalize(partido['categoria']) ==
            FixtureRepositoryV2.normalize(widget.categoria);

    if (!sameBase) return false;

    return FixtureRepositoryV2.normalize(partido['torneo']) ==
            FixtureRepositoryV2.normalize(widget.torneo) ||
        FixtureRepositoryV2.isLooseStageAlias(
          partido['torneo'].toString(),
          widget.torneo,
        );
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadEstadoRealV2();
      await _loadFixtureState();

      if (!mounted) return;

      setState(() {});
    });
  }

  Map<String, dynamic> _defaultProximoPartido() {
    final fixture = _buildFixtureCompleto(categoria: widget.categoria);

    return fixture.firstWhere(
      (p) =>
          p['torneo'] == widget.torneo &&
          p['categoria'] == widget.categoria &&
          p['estadoPartido'] != 'finalizado',
      orElse: () => fixture.first,
    );
  }

  List<DateTime> _generarSabadosDesde({
    required DateTime inicio,
    required int cantidad,
  }) {
    return List.generate(cantidad, (i) => inicio.add(Duration(days: i * 7)));
  }

  String _formatFecha(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    return '$dd/$mm';
  }

  List<Map<String, dynamic>> _buildAperturaBase({required String categoria}) {
    return [
      {
        'fechaNumero': 1,
        'fecha': '21/03',
        'hora': '13:00',
        'local': 'Municipalidad de Vicente Lopez',
        'visitante': 'San Fernando Handball',
        'torneo': 'Apertura',
        'categoria': categoria,
      },
      {
        'fechaNumero': 2,
        'fecha': '28/03',
        'hora': '13:00',
        'local': 'San Fernando Handball',
        'visitante': 'Colegio Ward',
        'torneo': 'Apertura',
        'categoria': categoria,
      },
      {
        'fechaNumero': 3,
        'fecha': '11/04',
        'hora': '13:00',
        'local': 'S.A.G. Villa Ballester',
        'visitante': 'San Fernando Handball',
        'torneo': 'Apertura',
        'categoria': categoria,
      },
      {
        'fechaNumero': 4,
        'fecha': '18/04',
        'hora': '13:00',
        'local': 'San Fernando Handball',
        'visitante': 'Argentinos Juniors',
        'torneo': 'Apertura',
        'categoria': categoria,
      },
      {
        'fechaNumero': 5,
        'fecha': '25/04',
        'hora': '13:00',
        'local': 'Ferro Carril Oeste',
        'visitante': 'San Fernando Handball',
        'torneo': 'Apertura',
        'categoria': categoria,
      },
      {
        'fechaNumero': 6,
        'fecha': '02/05',
        'hora': '13:00',
        'local': 'San Fernando Handball',
        'visitante': 'C.A. Velez Sarsfield',
        'torneo': 'Apertura',
        'categoria': categoria,
      },
      {
        'fechaNumero': 7,
        'fecha': '09/05',
        'hora': '13:00',
        'local': 'Campana Boat Club',
        'visitante': 'San Fernando Handball',
        'torneo': 'Apertura',
        'categoria': categoria,
      },
      {
        'fechaNumero': 8,
        'fecha': '16/05',
        'hora': '13:00',
        'local': 'S.A.G.A.B.',
        'visitante': 'San Fernando Handball',
        'torneo': 'Apertura',
        'categoria': categoria,
      },
      {
        'fechaNumero': 9,
        'fecha': '23/05',
        'hora': '13:00',
        'local': 'San Fernando Handball',
        'visitante': 'C.A. River Plate',
        'torneo': 'Apertura',
        'categoria': categoria,
      },
      {
        'fechaNumero': 10,
        'fecha': '30/05',
        'hora': '13:00',
        'local': 'Dorrego Handball',
        'visitante': 'San Fernando Handball',
        'torneo': 'Apertura',
        'categoria': categoria,
      },
      {
        'fechaNumero': 11,
        'fecha': '06/06',
        'hora': '13:00',
        'local': 'San Fernando Handball',
        'visitante': 'Estudiantes de La Plata',
        'torneo': 'Apertura',
        'categoria': categoria,
      },
      {
        'fechaNumero': 12,
        'fecha': '20/06',
        'hora': '13:00',
        'local': 'S.E.D.A.L.O.',
        'visitante': 'San Fernando Handball',
        'torneo': 'Apertura',
        'categoria': categoria,
      },
      {
        'fechaNumero': 13,
        'fecha': '27/06',
        'hora': '13:00',
        'local': 'San Fernando Handball',
        'visitante': 'C.A. Lanus',
        'torneo': 'Apertura',
        'categoria': categoria,
      },
      {
        'fechaNumero': 14,
        'fecha': '04/07',
        'hora': '13:00',
        'local': 'Nuestra Senora de Luján',
        'visitante': 'San Fernando Handball',
        'torneo': 'Apertura',
        'categoria': categoria,
      },
      {
        'fechaNumero': 15,
        'fecha': '11/07',
        'hora': '13:00',
        'local': 'San Fernando Handball',
        'visitante': 'A.A.C.F. Quilmes',
        'torneo': 'Apertura',
        'categoria': categoria,
      },
    ];
  }

  List<Map<String, dynamic>> _buildClausuraBase({required String categoria}) {
    final apertura = _buildAperturaBase(categoria: categoria);
    final sabados = _generarSabadosDesde(
      inicio: DateTime(2026, 8, 8),
      cantidad: apertura.length,
    );

    return List.generate(apertura.length, (i) {
      final p = Map<String, dynamic>.from(apertura[i]);
      final tmpLocal = p['local'];
      p['local'] = p['visitante'];
      p['visitante'] = tmpLocal;
      p['torneo'] = 'Clausura';
      p['fecha'] = _formatFecha(sabados[i]);

      return p;
    });
  }

  Map<String, dynamic> _convertirAFixturePartido(Map<String, dynamic> raw) {
    final bool somosLocales =
        (raw['local'] ?? '').toString() == 'San Fernando Handball';

    final rival = somosLocales
        ? (raw['visitante'] ?? 'Rival').toString()
        : (raw['local'] ?? 'Rival').toString();

    return {
      'temporada': widget.temporada,
      'competencia': widget.competencia,
      'rival': rival,
      'fechaNumero': raw['fechaNumero'],
      'fecha': raw['fecha'],
      'hora': raw['hora'],
      'condicion': somosLocales ? 'Local' : 'Visitante',
      'torneo': raw['torneo'],
      'categoria': raw['categoria'],
      'estado': 'Pendiente',
      'estadoPartido': 'no_iniciado',
      'golesSanFernando': 0,
      'golesRival': 0,
      'golesRecibidos': 0,
      'atajadas': 0,
      'penales': 0,
      'exclusiones2Min': 0,
      'amarillas': 0,
      'rojas': 0,
      'perdidas': 0,
      'recuperaciones': 0,
      'penalesConvertidosSanFernando': 0,
      'penalesConvertidosRival': 0,
      'eventos': <Map<String, dynamic>>[],
      'modoActual': null,
      'modoInicioPrimerTiempo': null,
      'modoInicioPrimerTiempoAlargue': null,
      'currentGoalkeeperNumber': null,
      'escudoRival': _rivalShieldAssetByName(rival),
    };
  }

  String? _rivalShieldAssetByName(String rival) {
    return rivalShieldAssetGlobal(rival);
  }

  String _normalizeContextText(dynamic value) {
    return (value ?? '')
        .toString()
        .trim()
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ü', 'u')
        .replaceAll('ñ', 'n')
        .replaceAll(RegExp(r'\s+'), ' ');
  }

  bool _sameLooseStage(String a, String b) {
    final left = _normalizeContextText(a);
    final right = _normalizeContextText(b);

    if (left == right) return true;

    const looseAliases = {
      'partido suelto',
      'partidos sueltos',
      'amistoso',
      'amistosos',
    };

    return looseAliases.contains(left) && looseAliases.contains(right);
  }

  bool _customFixtureMatchesCurrentContext(PartidoModel partido) {
    final partidoInstitutionId = _normalizeContextText(partido.institutionId);
    final currentInstitutionId = _normalizeContextText(widget.institutionId);

    final sameInstitution =
        partidoInstitutionId.isNotEmpty &&
        currentInstitutionId.isNotEmpty &&
        partidoInstitutionId == currentInstitutionId;

    if (!sameInstitution) return false;

    final temporada = _normalizeContextText(partido.temporada);
    final competencia = _normalizeContextText(partido.competencia);
    final torneo = _normalizeContextText(partido.torneo);
    final categoria = _normalizeContextText(partido.categoria);

    final widgetTemporada = _normalizeContextText(widget.temporada);
    final widgetCompetencia = _normalizeContextText(widget.competencia);
    final widgetTorneo = _normalizeContextText(widget.torneo);
    final widgetCategoria = _normalizeContextText(widget.categoria);

    final sameBase =
        temporada == widgetTemporada &&
        competencia == widgetCompetencia &&
        categoria == widgetCategoria;

    if (!sameBase) return false;

    return torneo == widgetTorneo || _sameLooseStage(torneo, widgetTorneo);
  }

  Future<void> _loadCustomFixturesV2() async {
    final data = await _fixtureRepository.readFixtures();

    final filtered = data.where(_customFixtureMatchesCurrentContext).toList();

    filtered.sort((a, b) {
      final byFecha = (a.fechaNumero ?? 999999).compareTo(
        b.fechaNumero ?? 999999,
      );

      if (byFecha != 0) return byFecha;

      return a.rival.toLowerCase().compareTo(b.rival.toLowerCase());
    });

    if (!mounted) return;

    setState(() {
      _customFixturesV2 = filtered;
    });
  }

  String _stableFixtureIdentity(Map<String, dynamic> partido) {
    return FixtureRepositoryV2.buildStableFixtureIdentityFromMap({
      ...partido,
      'institutionId': partido['institutionId'] ?? widget.institutionId,
      'temporada': partido['temporada'] ?? widget.temporada,
      'competencia': partido['competencia'] ?? widget.competencia,
      'torneo': partido['torneo'] ?? widget.torneo,
      'categoria': partido['categoria'] ?? widget.categoria,
    });
  }

  List<Map<String, dynamic>> _mergeBaseWithCustomFixtures(
    List<Map<String, dynamic>> base,
  ) {
    final byStableId = <String, Map<String, dynamic>>{};

    for (final item in base) {
      final map = Map<String, dynamic>.from(item);
      byStableId[_stableFixtureIdentity(map)] = map;
    }

    for (final custom in _customFixturesV2) {
      final map = custom.toMap();
      byStableId[_stableFixtureIdentity(map)] = map;
    }

    final result = byStableId.values.toList();

    result.sort((a, b) {
      final fa = (a['fechaNumero'] as int?) ?? 999999;
      final fb = (b['fechaNumero'] as int?) ?? 999999;

      final byFecha = fa.compareTo(fb);
      if (byFecha != 0) return byFecha;

      return (a['rival'] ?? '').toString().toLowerCase().compareTo(
        (b['rival'] ?? '').toString().toLowerCase(),
      );
    });

    return result;
  }

  List<Map<String, dynamic>> _buildFixtureCompleto({
    required String categoria,
  }) {
    final base = <Map<String, dynamic>>[];

    if (widget.competencia.trim().toLowerCase() == 'local') {
      final apertura = _buildAperturaBase(
        categoria: categoria,
      ).map(_convertirAFixturePartido).toList();

      final clausura = _buildClausuraBase(
        categoria: categoria,
      ).map(_convertirAFixturePartido).toList();

      base.addAll(apertura);
      base.addAll(clausura);
    }

    return _mergeBaseWithCustomFixtures(base);
  }

  List<Map<String, dynamic>> _defaultSiguientesPartidos() {
    final fixture = _buildFixtureCompleto(categoria: widget.categoria);

    final identidadesFinalizadas = partidosFinalizados
        .map((p) => _identityFromMap(p))
        .toSet();

    final pendientes = fixture.where((p) {
      return p['torneo'] == widget.torneo &&
          p['categoria'] == widget.categoria &&
          !identidadesFinalizadas.contains(_identityFromMap(p));
    }).toList();

    if (pendientes.isEmpty) return [];

    final identidadProximo = _identityFromMap(proximoPartido);

    final siguientes = pendientes
        .where((p) => _identityFromMap(p) != identidadProximo)
        .toList();

    return siguientes.take(3).map((p) {
      return {
        'temporada': p['temporada'],
        'competencia': p['competencia'],
        'rival': p['rival'],
        'fecha': p['fecha'],
        'hora': p['hora'],
        'condicion': p['condicion'],
        'torneo': p['torneo'],
        'categoria': p['categoria'],
        'fechaNumero': p['fechaNumero'],
        'escudoRival': p['escudoRival'],
        'estado': p['estado'],
      };
    }).toList();
  }

  Future<void> _loadFixtureState() async {
    final repositoryFixtures = await _fixtureRepository.readFixturesFlexible(
      temporada: widget.temporada,
      competencia: widget.competencia,
      torneo: widget.torneo,
      categoria: widget.categoria,
      institutionId: widget.institutionId,
    );

    final customMaps = repositoryFixtures.map((e) => e.toMap()).toList();

    final baseMaps = <Map<String, dynamic>>[];

    if (FixtureRepositoryV2.normalize(widget.competencia) == 'local') {
      final apertura = _buildAperturaBase(
        categoria: widget.categoria,
      ).map(_convertirAFixturePartido).toList();

      final clausura = _buildClausuraBase(
        categoria: widget.categoria,
      ).map(_convertirAFixturePartido).toList();

      baseMaps.addAll(apertura);
      baseMaps.addAll(clausura);
    }

    final mergedByIdentity = <String, Map<String, dynamic>>{};

    for (final item in baseMaps) {
      if (!_matchesCurrentContext(item)) continue;

      mergedByIdentity[FixtureRepositoryV2.buildStableFixtureIdentityFromMap(
        item,
      )] = Map<String, dynamic>.from(
        item,
      );
    }

    for (final item in customMaps) {
      if (!_matchesCurrentContext(item)) continue;

      mergedByIdentity[FixtureRepositoryV2.buildStableFixtureIdentityFromMap(
        item,
      )] = Map<String, dynamic>.from(
        item,
      );
    }

    final todos = mergedByIdentity.values.toList();

    todos.sort((a, b) {
      final fa = (a['fechaNumero'] as int?) ?? 999999;
      final fb = (b['fechaNumero'] as int?) ?? 999999;

      final byFecha = fa.compareTo(fb);
      if (byFecha != 0) return byFecha;

      return (a['rival'] ?? '').toString().toLowerCase().compareTo(
        (b['rival'] ?? '').toString().toLowerCase(),
      );
    });

    final pendientes = todos.where((p) {
      return _esPartidoValido(p) && !_estaFinalizadoGlobal(p);
    }).toList();

    if (!mounted) return;

    setState(() {
      _customFixturesV2 = repositoryFixtures;

      if (pendientes.isEmpty) {
        proximoPartido = {};
        siguientesPartidos = [];
        hayPartido = false;
        return;
      }

      proximoPartido = Map<String, dynamic>.from(pendientes.first);

      siguientesPartidos = pendientes.skip(1).map((p) {
        return {
          'temporada': p['temporada'],
          'competencia': p['competencia'],
          'rival': p['rival'],
          'institutionId': p['institutionId'] ?? widget.institutionId,
          'equipoPropio': p['equipoPropio'] ?? _institutionName,
          'escudoPropio': p['escudoPropio'] ?? _institutionShieldPath,
          'fechaNumero': p['fechaNumero'],
          'fecha': p['fecha'],
          'hora': p['hora'],
          'condicion': p['condicion'],
          'torneo': p['torneo'],
          'categoria': p['categoria'],
          'escudoRival': p['escudoRival'],
          'estado': p['estado'],
          'estadoPartido': p['estadoPartido'],
        };
      }).toList();

      hayPartido = true;
    });
  }

  Future<void> _persistFixtureState() async {
    // Fuente única actual:
    // - fixtures_v1 para pendientes / fixture / partidos sueltos.
    // - finished_matches_history_v1 para finalizados.
    //
    // Este método queda intencionalmente como no-op para evitar volver a
    // escribir estados legacy:
    // - proximo_partido_*
    // - siguientes_*
    // - finalizados_*
    return;
  }

  Future<void> _resetPartidosDePrueba() async {
    // Método legacy desactivado.
    // La fuente única actual para fixture/pendientes es fixtures_v1
    // mediante FixtureRepositoryV2.
    await _loadEstadoRealV2();
    await _loadFixtureState();
  }

  Future<void> _eliminarPartidosDePrueba() async {
    // Método legacy desactivado.
    // No debe escribir proximo_partido_*, siguientes_* ni finalizados_*.
    await _loadEstadoRealV2();
    await _loadFixtureState();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Limpieza legacy desactivada. No se modificaron datos.'),
      ),
    );
  }

  Future<void> _confirmarEliminarPartidosDePrueba() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF0F1722),
        title: const Text(
          'Eliminar partidos de prueba',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Se van a borrar solo los partidos que no esten marcados como reales. Los partidos finalizados reales se conservarán.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Eliminar',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      await _eliminarPartidosDePrueba();
    }
  }

  String _partidoIdentity(Map<String, dynamic> partido) {
    return [
      (partido['torneo'] ?? '').toString(),
      (partido['categoria'] ?? '').toString(),
      (partido['rival'] ?? '').toString(),
      (partido['fecha'] ?? '').toString(),
      (partido['hora'] ?? '').toString(),
      (partido['condicion'] ?? '').toString(),
    ].join('|');
  }

  Map<String, dynamic> _partidoDesdeFinishedHistoryEntry(
    Map<String, dynamic> entry,
  ) {
    final base = Map<String, dynamic>.from(
      (entry['partido'] as Map?)?.cast<String, dynamic>() ??
          <String, dynamic>{},
    );

    return {
      ...base,
      'estado': 'Finalizado',
      'estadoPartido': 'finalizado',
      'golesSanFernando':
          entry['golesSanFernando'] ?? base['golesSanFernando'] ?? 0,
      'golesRival': entry['golesRival'] ?? base['golesRival'] ?? 0,
      'golesRecibidos': entry['golesRecibidos'] ?? base['golesRecibidos'] ?? 0,
      'atajadas': entry['atajadas'] ?? base['atajadas'] ?? 0,
      'penales': entry['penales'] ?? base['penales'] ?? 0,
      'exclusiones2Min':
          entry['exclusiones2Min'] ?? base['exclusiones2Min'] ?? 0,
      'amarillas': entry['amarillas'] ?? base['amarillas'] ?? 0,
      'rojas': entry['rojas'] ?? base['rojas'] ?? 0,
      'perdidas': entry['perdidas'] ?? base['perdidas'] ?? 0,
      'recuperaciones': entry['recuperaciones'] ?? base['recuperaciones'] ?? 0,
      'penalesConvertidosSanFernando':
          entry['penalesConvertidosSanFernando'] ??
          base['penalesConvertidosSanFernando'] ??
          0,
      'penalesConvertidosRival':
          entry['penalesConvertidosRival'] ??
          base['penalesConvertidosRival'] ??
          0,
      'eventos':
          entry['eventos'] ?? base['eventos'] ?? <Map<String, dynamic>>[],
      'archivedAt': entry['archivedAt'] ?? entry['timestamp'],
    };
  }

  List<Map<String, dynamic>> _mergeFinalizados({
    required List<Map<String, dynamic>> desdeProximoScreen,
    required List<Map<String, dynamic>> desdeFinishedHistory,
  }) {
    final Map<String, Map<String, dynamic>> unicos = {};

    for (final p in [...desdeProximoScreen, ...desdeFinishedHistory]) {
      final partido = Map<String, dynamic>.from(p)
        ..['estado'] = 'Finalizado'
        ..['estadoPartido'] = 'finalizado';

      unicos[_identityFromMap(partido)] = partido;
    }

    final lista = unicos.values.toList();

    lista.sort((a, b) {
      final aDate = DateTime.tryParse((a['archivedAt'] ?? '').toString());
      final bDate = DateTime.tryParse((b['archivedAt'] ?? '').toString());

      if (aDate == null && bDate == null) return 0;
      if (aDate == null) return 1;
      if (bDate == null) return -1;
      return bDate.compareTo(aDate);
    });

    return lista;
  }

  bool _partidoEstaFinalizado(Map<String, dynamic> partido) {
    return (partido['estadoPartido'] ?? '') == 'finalizado' ||
        (partido['estado'] ?? '') == 'Finalizado';
  }

  Map<String, dynamic> _crearPartidoBaseDesdeSiguiente(
    Map<String, dynamic> siguiente,
  ) {
    final String rival = (siguiente['rival'] ?? 'Rival').toString();

    return {
      'temporada': (siguiente['temporada'] ?? widget.temporada).toString(),
      'competencia': (siguiente['competencia'] ?? widget.competencia)
          .toString(),
      'rival': rival,
      'fechaNumero': siguiente['fechaNumero'],
      'fecha': (siguiente['fecha'] ?? '').toString(),
      'hora': (siguiente['hora'] ?? '').toString(),
      'condicion': (siguiente['condicion'] ?? 'Local').toString(),
      'torneo': (siguiente['torneo'] ?? 'Apertura').toString(),
      'categoria': (siguiente['categoria'] ?? 'Cadetes').toString(),
      'estado': 'Pendiente',
      'estadoPartido': 'no_iniciado',
      'golesSanFernando': 0,
      'golesRival': 0,
      'golesRecibidos': 0,
      'atajadas': 0,
      'penales': 0,
      'exclusiones2Min': 0,
      'amarillas': 0,
      'rojas': 0,
      'perdidas': 0,
      'recuperaciones': 0,
      'penalesConvertidosSanFernando': 0,
      'penalesConvertidosRival': 0,
      'eventos': <Map<String, dynamic>>[],
      'modoActual': null,
      'modoInicioPrimerTiempo': null,
      'modoInicioPrimerTiempoAlargue': null,
      'currentGoalkeeperNumber': null,
      'escudoRival': siguiente['escudoRival'] ?? _rivalShieldAssetByName(rival),
    };
  }

  void _promoverSiguienteSiActualEstaFinalizado({bool saveAfter = true}) {
    if (!hayPartido || !_partidoEstaFinalizado(proximoPartido)) return;

    final actualId = _identityFromMap(proximoPartido);
    final yaExiste = partidosFinalizados.any(
      (p) => _identityFromMap(p) == actualId,
    );

    if (!yaExiste) {
      final partidoArchivado = Map<String, dynamic>.from(proximoPartido)
        ..['estado'] = 'Finalizado'
        ..['estadoPartido'] = 'finalizado';
      partidosFinalizados.insert(0, partidoArchivado);
    }

    if (siguientesPartidos.isNotEmpty) {
      final siguiente = Map<String, dynamic>.from(
        siguientesPartidos.removeAt(0),
      );
      proximoPartido = _crearPartidoBaseDesdeSiguiente(siguiente);
      hayPartido = true;
    } else {
      proximoPartido = {};
      hayPartido = false;
    }

    if (saveAfter) {
      _persistFixtureState();
    }
  }

  Future<void> _abrirCentroDeControl() async {
    if (!hayPartido || proximoPartido.isEmpty) return;

    final rival = fixTextoRoto(proximoPartido['rival'] ?? 'Rival');
    if (rival.isEmpty) {
      setState(() {
        _recalcularProximoYSiguientesDesdeBase();
      });
      await _persistFixtureState();
      return;
    }

    proximoPartido['esPartidoReal'] ??= false;

    final ownTeamName = widget.institutionName.trim().isEmpty
        ? 'Institución'
        : widget.institutionName.trim();

    proximoPartido['institutionId'] = widget.institutionId;
    proximoPartido['equipoPropio'] = ownTeamName;
    proximoPartido['escudoPropio'] = _institutionShieldPath;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PartidoEnJuegoScreen(partido: proximoPartido),
      ),
    );

    if (!mounted) return;

    setState(() {
      if (_partidoEstaFinalizado(proximoPartido)) {
        _promoverSiguienteSiActualEstaFinalizado(saveAfter: false);
      }
    });

    await _persistFixtureState();
  }

  void _abrirResumenUltimoFinalizado() {
    if (partidosFinalizados.isEmpty) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            ResumenPartidoFinalizadoScreen(partido: partidosFinalizados.first),
      ),
    );
  }

  PartidoModel _partidoModelFromMap(Map<String, dynamic> map) {
    return PartidoModel.fromMap({
      ...map,
      'temporada': (map['temporada'] ?? widget.temporada).toString(),
      'competencia': (map['competencia'] ?? widget.competencia).toString(),
      'torneo': (map['torneo'] ?? widget.torneo).toString(),
      'categoria': (map['categoria'] ?? widget.categoria).toString(),
      'estado': (map['estado'] ?? 'Pendiente').toString(),
      'estadoPartido': (map['estadoPartido'] ?? 'no_iniciado').toString(),
      'eventos': map['eventos'] ?? <Map<String, dynamic>>[],
    });
  }

  bool _sameContextForPartidoModel(PartidoModel partido) {
    final sameSeason =
        _normalizeContextText(partido.temporada) ==
        _normalizeContextText(widget.temporada);

    final sameCompetition =
        _normalizeContextText(partido.competencia) ==
        _normalizeContextText(widget.competencia);

    final sameCategory =
        _normalizeContextText(partido.categoria) ==
        _normalizeContextText(widget.categoria);

    if (!sameSeason || !sameCompetition || !sameCategory) return false;

    final partidoTorneo = _normalizeContextText(partido.torneo);
    final widgetTorneo = _normalizeContextText(widget.torneo);

    return partidoTorneo == widgetTorneo ||
        _sameLooseStage(partidoTorneo, widgetTorneo);
  }

  bool _sameFixtureStableIdentity(PartidoModel a, PartidoModel b) {
    return FixtureRepositoryV2.buildStableFixtureIdentity(a) ==
        FixtureRepositoryV2.buildStableFixtureIdentity(b);
  }

  Future<void> _crearPartidoManual() async {
    final result = await Navigator.push<PartidoModel>(
      context,
      MaterialPageRoute(
        builder: (_) => MatchEditorScreen(
          temporada: widget.temporada,
          competencia: widget.competencia,
          torneo: widget.torneo,
          categoria: widget.categoria,
          institutionId: widget.institutionId,
          equipoPropio: _institutionName,
          escudoPropio: _institutionShieldPath,
        ),
      ),
    );

    if (!mounted || result == null) return;

    final saved = await _fixtureRepository.upsertFixture(result);

    if (!mounted) return;

    if (!saved) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo guardar el partido en fixtures_v1.'),
        ),
      );
      return;
    }

    await _loadFixtureState();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Partido creado correctamente.')),
    );
  }

  Future<void> _editarProximoPartido() async {
    if (!_esPartidoValido(proximoPartido)) {
      await _showEditError('No hay un partido válido para editar.');
      return;
    }

    if (_estaFinalizadoGlobal(proximoPartido)) {
      await _showEditError('No se puede editar un partido finalizado.');
      return;
    }

    final oldModel = _partidoModelFromMap(proximoPartido);

    final result = await Navigator.push<PartidoModel>(
      context,
      MaterialPageRoute(
        builder: (_) => MatchEditorScreen(
          initial: oldModel,
          temporada: widget.temporada,
          competencia: widget.competencia,
          torneo: widget.torneo,
          categoria: widget.categoria,
          institutionId: oldModel.institutionId ?? widget.institutionId,
          equipoPropio: oldModel.equipoPropio ?? _institutionName,
          escudoPropio: oldModel.escudoPropio ?? _institutionShieldPath,
        ),
      ),
    );

    if (!mounted || result == null) return;

    final replaced = await _fixtureRepository.replaceFixture(
      oldPartido: oldModel,
      newPartido: result,
    );

    if (!replaced) {
      final saved = await _fixtureRepository.upsertFixture(result);

      if (!saved && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo actualizar el partido.')),
        );
        return;
      }
    }

    await _loadFixtureState();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Partido actualizado correctamente.')),
    );
  }

  Future<void> _showEditError(String message) async {
    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Proximo partido'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/fondohd.jpeg',
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
          ),
          Positioned.fill(
            child: Container(color: const Color(0xFF05080D).withOpacity(0.84)),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: hayPartido && _esPartidoValido(proximoPartido)
                  ? _buildEstadoConPartido()
                  : _buildEstadoSinPartido(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEstadoConPartido() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildScreenHeader(),
        const SizedBox(height: 22),
        _buildMatchCard(),
        const SizedBox(height: 16),
        _buildUpcomingList(),
        /*if (partidosFinalizados.isNotEmpty) ...[
          const SizedBox(height: 20),
          const Text(
            'ultimo partido finalizado',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 10),

          Builder(
            builder: (context) {
              final partidosOrdenados = List<Map<String, dynamic>>.from(
                partidosFinalizados,
              );

              partidosOrdenados.sort((a, b) {
                final aDate = DateTime.tryParse(
                  (a['archivedAt'] ?? '').toString(),
                );
                final bDate = DateTime.tryParse(
                  (b['archivedAt'] ?? '').toString(),
                );

                if (aDate == null && bDate == null) return 0;
                if (aDate == null) return 1;
                if (bDate == null) return -1;

                return bDate.compareTo(aDate);
              });

              final partido = partidosOrdenados.first;

              final rival = (partido['rival'] ?? '').toString();
              final golesSanFernando =
                  (partido['golesSanFernando'] ?? 0) as int;
              final golesRival = (partido['golesRival'] ?? 0) as int;
              final condicion = (partido['condicion'] ?? '').toString();

              final esLocal = condicion == 'Local';

              final nombreLocal = esLocal ? 'San Fernando' : rival;
              final nombreVisitante = esLocal ? rival : 'San Fernando';

              final marcador = esLocal
                  ? '$golesSanFernando - $golesRival'
                  : '$golesRival - $golesSanFernando';

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$nombreLocal vs $nombreVisitante',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      marcador,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ResumenPartidoFinalizadoScreen(
                              partido: Map<String, dynamic>.from(partido),
                            ),
                          ),
                        );
                      },
                      child: const Text(
                        'Ver resumen',
                        style: TextStyle(
                          color: Colors.blueAccent,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],*/
        if (widget.tieneFixture) ...[
          const SizedBox(height: 10),
          _buildSecondaryAction(
            text: 'Ver fixture completo',
            icon: Icons.calendar_month_outlined,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FixtureScreen(
                    temporada: widget.temporada,
                    competencia: widget.competencia,
                    torneo: widget.torneo,
                    categoria: widget.categoria,
                    institutionName: widget.institutionName,
                  ),
                ),
              );
            },
          ),
        ],
        const SizedBox(height: 20),
        _buildPrimaryAction(
          text: _estaFinalizadoV2(proximoPartido)
              ? 'Ver resumen'
              : 'Iniciar partido',
          onTap: () {
            if (_estaFinalizadoV2(proximoPartido)) {
              final identidad = _identityFromMap(proximoPartido);

              final finalizado = _finalizadosV2.firstWhere(
                (p) =>
                    PartidoRepositoryV2.buildMatchIdentityFromModel(p) ==
                    identidad,
              );

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ResumenPartidoFinalizadoScreen(
                    partido: finalizado.toMap(),
                  ),
                ),
              );
              return;
            }

            _abrirCentroDeControl();
          },
        ),
        const SizedBox(height: 10),
        _buildOutlinedAction(
          text: 'Editar partido',
          onTap: _editarProximoPartido,
        ),

        const SizedBox(height: 12),
        _buildOutlinedAction(
          text: 'Eliminar partidos de prueba',
          onTap: _confirmarEliminarPartidosDePrueba,
        ),
        //const SizedBox(height: 10),
        /*_buildOutlinedAction(
          text: 'Marcar como jugado',
          onTap: () {
            final partidoManual = Map<String, dynamic>.from(proximoPartido)
              ..['estado'] = 'Finalizado'
              ..['estadoPartido'] = 'finalizado';
            setState(() {
              proximoPartido = partidoManual;
              _promoverSiguienteSiActualEstaFinalizado(saveAfter: false);
            });
            _persistFixtureState();
          },
        ),*/
      ],
    );
  }

  Widget _buildEstadoSinPartido() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildScreenHeaderSinPartido(),
        const SizedBox(height: 24),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: const Color(0xFF111A28).withOpacity(0.78),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.04)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'No hay un proximo partido cargado',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              if (partidosFinalizados.isNotEmpty) ...[
                const SizedBox(height: 18),
                _buildFinishedMatchesSection(),
              ],
              const SizedBox(height: 12),
              _buildOutlinedAction(
                text: 'Eliminar partidos de prueba',
                onTap: _confirmarEliminarPartidosDePrueba,
              ),
              const SizedBox(height: 18),
              _buildPrimaryAction(
                text: 'Crear partido',
                onTap: _crearPartidoManual,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildScreenHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _institutionTitle,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${(proximoPartido['categoria'] ?? widget.categoria).toString()} · ${(proximoPartido['torneo'] ?? widget.torneo).toString()}',
          style: const TextStyle(fontSize: 14, color: Color(0xFFD4DCE7)),
        ),
      ],
    );
  }

  Widget _buildScreenHeaderSinPartido() {
    final categoria = widget.categoria.trim().isEmpty
        ? 'Categoría'
        : widget.categoria;

    final torneo = widget.torneo.trim().isEmpty ? 'Torneo' : widget.torneo;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _institutionTitle,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$categoria · $torneo',
          style: const TextStyle(fontSize: 14, color: Color(0xFFD4DCE7)),
        ),
      ],
    );
  }

  Widget _buildMatchCard() {
    if (!_esPartidoValido(proximoPartido)) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFF0F1722).withOpacity(0.90),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white.withOpacity(0.04)),
        ),
        child: const Text(
          'No hay próximo partido válido. Entrá al fixture completo para seleccionar uno.',
          style: TextStyle(color: Color(0xFFAAB4C3)),
        ),
      );
    }

    final estaFinalizadoV2 = _estaFinalizadoV2(proximoPartido);
    final estadoVisual = estaFinalizadoV2
        ? 'Finalizado'
        : (proximoPartido['estado'] ?? 'Pendiente').toString();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1722).withOpacity(0.90),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.22),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatusChip(estadoVisual),
          const SizedBox(height: 14),
          Row(
            children: [
              _buildTeamBadge(
                assetPath:
                    proximoPartido['escudoRival'] as String? ??
                    _rivalShieldAssetByName(
                      (proximoPartido['rival'] ?? '').toString(),
                    ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  (proximoPartido['rival'] ?? '').toString(),
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          _buildHeadToHeadButton(),
          const SizedBox(height: 10),
          _buildInfoRow(
            'Fecha',
            '${(proximoPartido['fecha'] ?? '-').toString()} • ${(proximoPartido['hora'] ?? '-').toString()}',
          ),
          _buildInfoRow(
            'Condicion',
            (proximoPartido['condicion'] ?? '').toString(),
          ),
        ],
      ),
    );
  }

  Widget _buildFinishedMatchesSection() {
    final visibles = partidosFinalizados.take(3).toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1722).withOpacity(0.82),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Partidos finalizados',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          ...visibles.map((partido) {
            final int golesSF = (partido['golesSanFernando'] ?? 0) as int;
            final int golesR = (partido['golesRival'] ?? 0) as int;

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF182338).withOpacity(0.75),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'San Fernando vs ${partido['rival']}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$golesSF - $golesR',
                      style: const TextStyle(
                        color: Color(0xFFDCE4EF),
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildOutlinedAction(
                      text: 'Ver resumen',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ResumenPartidoFinalizadoScreen(
                              partido: partido,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildUpcomingList() {
    final visibles = siguientesPartidos.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'Siguientes partidos',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 10),
        if (visibles.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFF0F1A2B).withOpacity(0.6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'No hay más partidos cargados',
              style: TextStyle(color: Color(0xFFAAB4C3), fontSize: 13),
            ),
          )
        else
          ...visibles.map(_buildUpcomingItem),
      ],
    );
  }

  Widget _buildUpcomingItem(Map<String, dynamic> partido) {
    final String? escudoRival = partido['escudoRival'] as String?;

    return GestureDetector(
      onTap: () {
        setState(() {
          final nuevosSiguientes = siguientesPartidos
              .where((p) => p != partido)
              .toList();

          if (_esPartidoValido(proximoPartido)) {
            final partidoActualAnterior = {
              'rival': proximoPartido['rival'].toString(),
              'fecha': proximoPartido['fecha'].toString(),
              'hora': proximoPartido['hora'].toString(),
              'condicion': proximoPartido['condicion'].toString(),
              'torneo': proximoPartido['torneo'].toString(),
              'categoria': proximoPartido['categoria'].toString(),
              'fechaNumero': proximoPartido['fechaNumero'],
              'escudoRival': proximoPartido['escudoRival'],
            };
            nuevosSiguientes.add(partidoActualAnterior);
          }

          proximoPartido = _crearPartidoBaseDesdeSiguiente(partido);

          siguientesPartidos = nuevosSiguientes
              .map((e) => Map<String, dynamic>.from(e))
              .toList();
        });

        _persistFixtureState();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF0F1A2B).withOpacity(0.6),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              padding: const EdgeInsets.all(6),
              child: Center(child: _buildShieldImage(escudoRival, size: 18)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                (partido['rival'] ?? '').toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Text(
              '${partido['fecha']} • ${partido['hora']}',
              style: const TextStyle(color: Color(0xFFAAB4C3), fontSize: 12),
            ),
            const SizedBox(width: 10),
            Text(
              (partido['condicion'] ?? '').toString(),
              style: const TextStyle(color: Color(0xFF4DA3FF), fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamBadge({String? assetPath}) {
    return Container(
      width: 58,
      height: 58,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
      ),
      padding: const EdgeInsets.all(8),
      child: Center(child: _buildShieldImage(assetPath, size: 24)),
    );
  }

  /// ===============================
  /// CHIP DE ESTADO (MEJORADO CON COLOR DINÁMICO)
  /// ===============================

  Widget _buildStatusChip(String label, {Color? color}) {
    final baseColor = color ?? const Color(0xFF4F8CFF);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: baseColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: baseColor,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildHeadToHeadButton() {
    return GestureDetector(
      onTap: () {
        debugPrint('Ver historial vs rival');
      },
      child: Container(
        margin: const EdgeInsets.only(top: 10, bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF182338).withOpacity(0.85),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.04)),
        ),
        child: Row(
          children: [
            const Icon(Icons.history, size: 18, color: Color(0xFFDCE4EF)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Historial vs ${(proximoPartido['rival'] ?? 'rival').toString()}',
                style: const TextStyle(
                  fontSize: 13.5,
                  color: Color(0xFFDCE4EF),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, size: 18, color: Color(0xFF8FA3BF)),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 82,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFFAAB4C3),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryAction({
    required String text,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4F8CFF),
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget _buildSecondaryAction({
    required String text,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(top: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF0F1A2B).withOpacity(0.6),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white70, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFFDAE2EE),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOutlinedAction({
    required String text,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: BorderSide(color: Colors.white.withOpacity(0.08)),
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

/// ======================================================
/// BLOQUES FINALES - RESUMEN + ARQUEROS + JUGADORES
/// ======================================================
/// PEGADO RECOMENDADO:
/// 1) Reemplazá COMPLETA la class ResumenPartidoFinalizadoScreen.
/// 2) Reemplazá COMPLETA la class ArquerosPartidoScreen si tu versión quedó rota.
/// 3) Reemplazá COMPLETA la class JugadoresPartidoScreen si tu versión quedó rota.
/// 4) NO toques partido_repository_v2.dart ni models_v2.dart para este arreglo.
///
/// IMPORTANTE:
/// - _estadisticasPorArquero NO se elimina.
/// - Se corrige para no usar actorPrincipalId como nombre visual.
/// - _estadisticasJugadoresCampo usa actorPrincipal visible y filtra fantasmas.
/// ======================================================

/// ===============================
/// ===============================
/// RESUMEN DEL PARTIDO FINALIZADO
/// ===============================
/// ===============================

class ResumenPartidoFinalizadoScreen extends StatelessWidget {
  final Map<String, dynamic> partido;

  Map<String, int> _shareStatsPorPeriodo(String periodoObjetivo) {
    final stats = <String, int>{
      'golesFavor': 0,
      'golesContra': 0,
      'atajadas': 0,
      'perdidas': 0,
      'recuperaciones': 0,
      'penales': 0,
    };

    String normalizarPeriodo(Map<String, dynamic> map) {
      final raw =
          (map['periodo'] ??
                  map['tiempo'] ??
                  map['tiempoPartido'] ??
                  map['estadoTiempo'] ??
                  map['estadoPartido'] ??
                  '')
              .toString()
              .trim()
              .toLowerCase();

      if (raw == '1t' || raw == 'primer_tiempo' || raw == 'primer tiempo') {
        return '1T';
      }

      if (raw == '2t' || raw == 'segundo_tiempo' || raw == 'segundo tiempo') {
        return '2T';
      }

      return 'Global';
    }

    for (final e in _eventos) {
      if (e is! Map) continue;

      final map = Map<String, dynamic>.from(e);
      final periodo = normalizarPeriodo(map);

      if (periodo != periodoObjetivo) continue;

      final tipo = (map['tipo'] ?? map['kind'] ?? '').toString();
      final resultado = (map['resultado'] ?? '').toString();
      final modo = (map['modo'] ?? '').toString();

      if (tipo == 'tiro' || tipo == 'penal' || tipo == 'penal_tanda') {
        if (resultado == 'gol') {
          if (modo == 'ataque') {
            stats['golesFavor'] = stats['golesFavor']! + 1;
          } else if (modo == 'defensa') {
            stats['golesContra'] = stats['golesContra']! + 1;
          }
        }

        if (resultado == 'atajado' && modo == 'defensa') {
          stats['atajadas'] = stats['atajadas']! + 1;
        }

        if (tipo == 'penal' || tipo == 'penal_tanda') {
          stats['penales'] = stats['penales']! + 1;
        }
      }

      if (tipo == 'perdida' && resultado == 'perdida') {
        stats['perdidas'] = stats['perdidas']! + 1;
      }

      if (tipo == 'perdida' && resultado == 'recuperacion') {
        stats['recuperaciones'] = stats['recuperaciones']! + 1;
      }
    }

    return stats;
  }

  Widget _buildShareMiniStat(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.07),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFFAAB4C3),
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSharePeriodRow(String label, Map<String, int> stats) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 36,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Expanded(
            child: Text(
              'GF ${stats['golesFavor']} · GC ${stats['golesContra']} · AT ${stats['atajadas']} · P ${stats['perdidas']} · R ${stats['recuperaciones']}',
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Color(0xFFDCE4EF),
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoryGoalkeeperComparisonPanel(
    List<Map<String, dynamic>> arqueros,
  ) {
    if (arqueros.length < 2) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF111A28),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Text(
          'Análisis individual del arquero destacado',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFFAAB4C3),
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
      );
    }

    final ordenados = [...arqueros]
      ..sort((a, b) {
        final eb = (b['eficacia'] ?? 0.0) as double;
        final ea = (a['eficacia'] ?? 0.0) as double;
        return eb.compareTo(ea);
      });

    final mejor = ordenados.first;
    final segundo = ordenados[1];

    final mejorNombre =
        (mejor['arqueroNombre'] ?? mejor['arquero'] ?? 'Arquero').toString();

    final mejorDorsal = (mejor['arqueroDorsal'] ?? '').toString();
    final mejorEficacia = (mejor['eficacia'] ?? 0.0) as double;
    final segundaEficacia = (segundo['eficacia'] ?? 0.0) as double;
    final diferencia = mejorEficacia - segundaEficacia;

    final lectura = diferencia >= 20
        ? 'Dominio claro del arquero ${mejorDorsal.isEmpty ? '' : mejorDorsal}'
        : diferencia >= 10
        ? 'Ventaja moderada del arquero ${mejorDorsal.isEmpty ? '' : mejorDorsal}'
        : 'Rendimiento parejo entre arqueros';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF111A28),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Comparación de arqueros',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          _buildShareInsightRow('Mejor arquero', mejorNombre),
          _buildShareInsightRow(
            'Eficacia',
            '${mejorEficacia.toStringAsFixed(1)}%',
          ),
          _buildShareInsightRow(
            'Diferencia',
            '+${diferencia.toStringAsFixed(1)} pts',
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: (mejorEficacia / 100).clamp(0.0, 1.0),
              minHeight: 7,
              backgroundColor: Colors.white.withOpacity(0.10),
              valueColor: AlwaysStoppedAnimation<Color>(
                _colorEficacia(mejorEficacia),
              ),
            ),
          ),
          const SizedBox(height: 9),
          Text(
            lectura,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: _colorEficacia(mejorEficacia),
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Color _colorEficacia(double eficacia) {
    if (eficacia >= 50) return const Color(0xFF22C55E);
    if (eficacia >= 35) return const Color(0xFFFACC15);
    if (eficacia >= 25) return const Color(0xFFF97316);
    return const Color(0xFFEF4444);
  }

  Future<File> _captureShareCardAsFile({
    required BuildContext context,
    required String fileName,
    required Widget child,
  }) async {
    final captureKey = GlobalKey();

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.70),
      builder: (_) {
        return Center(
          child: RepaintBoundary(key: captureKey, child: child),
        );
      },
    );

    await Future.delayed(const Duration(milliseconds: 500));
    await WidgetsBinding.instance.endOfFrame;

    final renderObject = captureKey.currentContext?.findRenderObject();

    if (renderObject == null || renderObject is! RenderRepaintBoundary) {
      throw Exception('No se encontró RenderRepaintBoundary');
    }

    final image = await renderObject.toImage(pixelRatio: 3);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    if (byteData == null) {
      throw Exception('No se pudo generar PNG');
    }

    final bytes = byteData.buffer.asUint8List();
    final dir = await getTemporaryDirectory();

    final file = File(
      '${dir.path}/${fileName}_${DateTime.now().millisecondsSinceEpoch}.png',
    );

    await file.writeAsBytes(bytes, flush: true);

    if (context.mounted) {
      Navigator.of(context, rootNavigator: true).pop();
    }

    return file;
  }

  _ShareMatchTeamStats _buildShareStatsForMode(String modo) {
    int tiros = 0;
    int tirosConGol = 0;
    int tirosAtajados = 0;
    int tirosFuera = 0;
    int tirosAlPalo = 0;
    int penales = 0;
    int penalesConvertidos = 0;
    int penalesErrados = 0;
    int perdidas = 0;
    int recuperaciones = 0;

    final Map<String, int> perdidasPorTipo = {};

    void addPerdidaDetalle(String rawSubtipo) {
      final subtipo = rawSubtipo.trim().isEmpty ? 'sin_detalle' : rawSubtipo;
      perdidasPorTipo[subtipo] = (perdidasPorTipo[subtipo] ?? 0) + 1;
    }

    for (final raw in _eventos) {
      if (raw is! Map) continue;

      final e = Map<String, dynamic>.from(raw);
      final eventModo = (e['modo'] ?? '').toString();
      final tipo = (e['tipo'] ?? e['kind'] ?? '').toString();
      final resultado = (e['resultado'] ?? '').toString();
      final subtipo = (e['subtipo'] ?? e['detalle'] ?? '').toString();

      final esTiro = tipo == 'tiro';
      final esPenal = tipo == 'penal' || tipo == 'penal_tanda';

      if (eventModo == modo && (esTiro || esPenal)) {
        tiros++;

        if (resultado == 'gol') tirosConGol++;
        if (resultado == 'atajado') tirosAtajados++;
        if (resultado == 'fuera') tirosFuera++;
        if (resultado == 'palo') tirosAlPalo++;

        if (esPenal) {
          penales++;
          if (resultado == 'gol') {
            penalesConvertidos++;
          } else {
            penalesErrados++;
          }
        }
      }

      if (tipo == 'perdida') {
        final esPerdidaSanFernando = eventModo == 'ataque';
        final esPerdidaRival = eventModo == 'defensa';

        if (modo == 'ataque') {
          if (esPerdidaSanFernando) {
            perdidas++;
            addPerdidaDetalle(subtipo);
          }

          if (esPerdidaRival) {
            recuperaciones++;
          }
        }

        if (modo == 'defensa') {
          if (esPerdidaRival) {
            perdidas++;
            addPerdidaDetalle(subtipo);
          }

          if (esPerdidaSanFernando) {
            recuperaciones++;
          }
        }
      }
    }

    return _ShareMatchTeamStats(
      tiros: tiros,
      tirosConGol: tirosConGol,
      tirosAtajados: tirosAtajados,
      tirosFuera: tirosFuera,
      tirosAlPalo: tirosAlPalo,
      penales: penales,
      penalesConvertidos: penalesConvertidos,
      penalesErrados: penalesErrados,
      perdidas: perdidas,
      recuperaciones: recuperaciones,
      perdidasPorTipo: perdidasPorTipo,
    );
  }

  Widget _buildShareMatchOverviewCard(BuildContext context) {
    final ownStats = _buildShareStatsForMode('ataque');
    final rivalStatsRaw = _buildShareStatsForMode('defensa');

    final localName = _nombreLocal;
    final visitanteName = _nombreVisitante;

    final localStats = _somosLocales ? ownStats : rivalStatsRaw;
    final visitanteStats = _somosLocales ? rivalStatsRaw : ownStats;

    final int local2Min = _somosLocales ? _exclusiones2MinV2 : 0;
    final int visitante2Min = _somosLocales ? 0 : _exclusiones2MinV2;

    final int localAmarillas = _somosLocales ? _amarillasV2 : 0;
    final int visitanteAmarillas = _somosLocales ? 0 : _amarillasV2;

    final int localRojas = _somosLocales ? _rojasV2 : 0;
    final int visitanteRojas = _somosLocales ? 0 : _rojasV2;

    double safeEfficiency(int goals, int shots) {
      if (shots <= 0) return 0;
      return (goals * 100) / shots;
    }

    final double localEficacia = safeEfficiency(
      localStats.tirosConGol,
      localStats.tiros,
    );

    final double visitanteEficacia = safeEfficiency(
      visitanteStats.tirosConGol,
      visitanteStats.tiros,
    );

    double clampDouble(double value, double min, double max) {
      if (value < min) return min;
      if (value > max) return max;
      return value;
    }

    double balanceHigherBetter(double left, double right) {
      final total = left + right;
      if (total <= 0) return 0;
      return ((left - right) / total) * 100;
    }

    double balanceLowerBetter(double left, double right) {
      final total = left + right;
      if (total <= 0) return 0;
      return ((right - left) / total) * 100;
    }

    double buildLocalControlIndex() {
      final double eficaciaBalance = clampDouble(
        localEficacia - visitanteEficacia,
        -25,
        25,
      );

      final double robosBalance = clampDouble(
        balanceHigherBetter(
          localStats.recuperaciones.toDouble(),
          visitanteStats.recuperaciones.toDouble(),
        ),
        -25,
        25,
      );

      final double perdidasBalance = clampDouble(
        balanceLowerBetter(
          localStats.perdidasNoForzadas.toDouble(),
          visitanteStats.perdidasNoForzadas.toDouble(),
        ),
        -25,
        25,
      );

      final double marcadorBalance = clampDouble(
        ((_golesLocal - _golesVisitante) * 4).toDouble(),
        -20,
        20,
      );

      final double control =
          50 +
          (eficaciaBalance * 0.40) +
          (robosBalance * 0.25) +
          (perdidasBalance * 0.20) +
          (marcadorBalance * 0.15);

      return clampDouble(control, 0, 100);
    }

    final double localControl = buildLocalControlIndex();
    final double visitanteControl = 100 - localControl;

    String buildMatchKey() {
      final eficaciaDiff = (localEficacia - visitanteEficacia).abs();
      final robosDiff =
          (localStats.recuperaciones - visitanteStats.recuperaciones).abs();
      final perdidasDiff =
          (localStats.perdidasNoForzadas - visitanteStats.perdidasNoForzadas)
              .abs();

      if (eficaciaDiff >= 8) return 'Clave: eficacia ofensiva';
      if (robosDiff >= 5) return 'Clave: presión defensiva';
      if (perdidasDiff >= 5) return 'Clave: pérdidas no forzadas';

      return 'Partido parejo';
    }

    String buildInsight() {
      final eficaciaDiff = (localEficacia - visitanteEficacia).abs();
      final golesDiff = (_golesLocal - _golesVisitante).abs();

      if (eficaciaDiff > 10) {
        return localEficacia > visitanteEficacia
            ? '$localName fue mucho más eficaz'
            : '$visitanteName fue mucho más eficaz';
      }

      if (golesDiff >= 6) {
        return '$localName dominó claramente el partido';
      }

      if (golesDiff <= 2) {
        return 'Partido muy parejo';
      }

      return 'Partido definido por detalles';
    }

    Color valueColor({
      required double leftValue,
      required double rightValue,
      required bool isLeft,
      required String compareMode,
    }) {
      if (compareMode == 'neutral' || leftValue == rightValue) {
        return Colors.white;
      }

      final bool leftIsBetter = compareMode == 'higher'
          ? leftValue > rightValue
          : leftValue < rightValue;

      if (isLeft) {
        return leftIsBetter ? const Color(0xFF27D36B) : Colors.white;
      }

      return !leftIsBetter ? const Color(0xFF27D36B) : Colors.white;
    }

    Widget statRow(
      String label,
      String left,
      String right, {
      double? leftValue,
      double? rightValue,
      String compareMode = 'neutral',
    }) {
      final double resolvedLeftValue =
          leftValue ?? double.tryParse(left.replaceAll('%', '')) ?? 0;
      final double resolvedRightValue =
          rightValue ?? double.tryParse(right.replaceAll('%', '')) ?? 0;

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          children: [
            Expanded(
              child: Text(
                left,
                textAlign: TextAlign.center,
                style: TextStyle(
                  decoration: TextDecoration.none,
                  color: valueColor(
                    leftValue: resolvedLeftValue,
                    rightValue: resolvedRightValue,
                    isLeft: true,
                    compareMode: compareMode,
                  ),
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            SizedBox(
              width: 95,
              child: Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  decoration: TextDecoration.none,
                  color: Color(0xFFAAB4C3),
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Expanded(
              child: Text(
                right,
                textAlign: TextAlign.center,
                style: TextStyle(
                  decoration: TextDecoration.none,
                  color: valueColor(
                    leftValue: resolvedLeftValue,
                    rightValue: resolvedRightValue,
                    isLeft: false,
                    compareMode: compareMode,
                  ),
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      );
    }

    String shortTeamName(String name) {
      final lower = name.toLowerCase();

      if (lower.contains('vélez')) return 'Vélez';
      if (lower.contains('san fernando')) return 'San Fernando';

      // fallback inteligente
      final words = name.split(' ');
      if (words.length >= 2) {
        return words.last;
      }

      return name;
    }

    Widget controlIndexBar() {
      final localShort = shortTeamName(localName);
      final visitanteShort = shortTeamName(visitanteName);

      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${localControl.toStringAsFixed(0)}% $localShort',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    decoration: TextDecoration.none,
                    color: Color(0xFF27D36B),
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  '${visitanteControl.toStringAsFixed(0)}% $visitanteShort',
                  textAlign: TextAlign.right,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    decoration: TextDecoration.none,
                    color: Color(0xFF8FA3BF),
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: SizedBox(
              height: 6,
              child: Row(
                children: [
                  Expanded(
                    flex: localControl.round().clamp(1, 99),
                    child: Container(color: const Color(0xFF27D36B)),
                  ),
                  Expanded(
                    flex: visitanteControl.round().clamp(1, 99),
                    child: Container(color: const Color(0xFF324057)),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    Widget compactUnifiedPanel() {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(14, 11, 14, 11),
        decoration: BoxDecoration(
          color: const Color(0xFF111A28),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF27D36B).withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                buildMatchKey(),
                style: const TextStyle(
                  decoration: TextDecoration.none,
                  color: Color(0xFF27D36B),
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Análisis del partido',
              style: TextStyle(
                decoration: TextDecoration.none,
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            controlIndexBar(),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    localName,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      decoration: TextDecoration.none,
                      color: Color(0xFF8FA3BF),
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: 95),
                Expanded(
                  child: Text(
                    visitanteName,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      decoration: TextDecoration.none,
                      color: Color(0xFF8FA3BF),
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),

            statRow(
              'Tiros',
              localStats.tiros.toString(),
              visitanteStats.tiros.toString(),
            ),
            statRow(
              'Eficacia',
              '${localEficacia.toStringAsFixed(1)}%',
              '${visitanteEficacia.toStringAsFixed(1)}%',
              leftValue: localEficacia,
              rightValue: visitanteEficacia,
              compareMode: 'higher',
            ),
            statRow(
              'Atajados',
              localStats.tirosAtajados.toString(),
              visitanteStats.tirosAtajados.toString(),
              compareMode: 'lower',
            ),
            statRow(
              'Fuera',
              localStats.tirosFuera.toString(),
              visitanteStats.tirosFuera.toString(),
              compareMode: 'lower',
            ),
            statRow(
              'Palo',
              localStats.tirosAlPalo.toString(),
              visitanteStats.tirosAlPalo.toString(),
              compareMode: 'lower',
            ),

            const Divider(color: Color(0x223FFFFFF), height: 16, thickness: 1),

            statRow(
              'Robos',
              localStats.recuperaciones.toString(),
              visitanteStats.recuperaciones.toString(),
              compareMode: 'higher',
            ),
            statRow(
              'Pérd. no forzada',
              localStats.perdidasNoForzadas.toString(),
              visitanteStats.perdidasNoForzadas.toString(),
              compareMode: 'lower',
            ),

            const Divider(color: Color(0x223FFFFFF), height: 16, thickness: 1),

            const Text(
              'Penales y disciplina',
              style: TextStyle(
                decoration: TextDecoration.none,
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 5),

            statRow(
              'Penales',
              localStats.penales.toString(),
              visitanteStats.penales.toString(),
            ),
            statRow(
              'Convert.',
              localStats.penalesConvertidos.toString(),
              visitanteStats.penalesConvertidos.toString(),
              compareMode: 'higher',
            ),
            statRow(
              'Errados',
              localStats.penalesErrados.toString(),
              visitanteStats.penalesErrados.toString(),
              compareMode: 'lower',
            ),

            const Divider(color: Color(0x223FFFFFF), height: 16, thickness: 1),

            statRow(
              '2 min',
              local2Min.toString(),
              visitante2Min.toString(),
              compareMode: 'lower',
            ),
            statRow(
              'Amarillas',
              localAmarillas.toString(),
              visitanteAmarillas.toString(),
              compareMode: 'lower',
            ),
            statRow(
              'Rojas',
              localRojas.toString(),
              visitanteRojas.toString(),
              compareMode: 'lower',
            ),

            const SizedBox(height: 7),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xFF172235),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                buildInsight(),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  decoration: TextDecoration.none,
                  color: Color(0xFFE4EAF3),
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Material(
      color: Colors.transparent,
      child: DefaultTextStyle(
        style: const TextStyle(
          decoration: TextDecoration.none,
          color: Colors.white,
          fontSize: 12,
        ),
        child: Container(
          width: 390,
          height: 693,
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 14),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF070D17), Color(0xFF101827)],
            ),
          ),
          child: Column(
            children: [
              const Text(
                'HANDBALL SGS',
                style: TextStyle(
                  decoration: TextDecoration.none,
                  color: Color(0xFF8FA3BF),
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.4,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${partidoV2.categoria} · ${partidoV2.torneo}',
                style: const TextStyle(
                  decoration: TextDecoration.none,
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _buildShareTeam(
                      nombre: _nombreLocal,
                      assetPath: _somosLocales
                          ? 'assets/images/san_fernando.png'
                          : _rivalShieldAsset(),
                    ),
                  ),
                  Text(
                    '$_golesLocal - $_golesVisitante',
                    style: const TextStyle(
                      decoration: TextDecoration.none,
                      color: Colors.white,
                      fontSize: 39,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Expanded(
                    child: _buildShareTeam(
                      nombre: _nombreVisitante,
                      assetPath: _somosLocales
                          ? _rivalShieldAsset()
                          : 'assets/images/san_fernando.png',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF111A28),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  'Fecha: ${partidoV2.fecha} · Hora: ${partidoV2.hora} · Condición: ${partidoV2.condicion}',
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    decoration: TextDecoration.none,
                    color: Color(0xFFDCE4EF),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              compactUnifiedPanel(),
              const Spacer(),
              Text(
                '${partidoV2.fecha} · ${partidoV2.hora} · ${partidoV2.condicion}',
                style: const TextStyle(
                  decoration: TextDecoration.none,
                  color: Color(0xFF8FA3BF),
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShareGoalkeepersAnalysisCard(BuildContext context) {
    final arqueros = _estadisticasPorArquero();

    return Material(
      color: Colors.transparent,
      child: Container(
        width: 390,
        height: 693,
        padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF070D17), Color(0xFF101827)],
          ),
        ),
        child: Column(
          children: [
            const Text(
              'ANÁLISIS DE ARQUEROS',
              style: TextStyle(
                color: Color(0xFF8FA3BF),
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '${partidoV2.categoria} · ${partidoV2.torneo}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 21,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 14),

            _buildStoryGoalkeeperComparisonPanel(arqueros),

            const SizedBox(height: 14),

            if (arqueros.isNotEmpty)
              _buildShareGoalkeeperDetailPanel(arqueros.first),

            const SizedBox(height: 12),

            if (arqueros.length > 1)
              _buildShareGoalkeeperCompactPanel(arqueros[1], esMejor: false),

            const Spacer(),

            Text(
              '${partidoV2.fecha} · ${partidoV2.hora} · ${partidoV2.condicion}',
              style: const TextStyle(
                color: Color(0xFF8FA3BF),
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShareGoalkeeperCompactPanel(
    Map<String, dynamic> arquero, {
    required bool esMejor,
  }) {
    final nombre = (arquero['arqueroNombre'] ?? arquero['arquero'] ?? 'Arquero')
        .toString();

    final eficacia = (arquero['eficacia'] ?? 0.0) as double;
    final atajadas = (arquero['atajadas'] ?? 0) as int;
    final goles = (arquero['golesRecibidos'] ?? 0) as int;
    final penales = (arquero['penales'] ?? 0) as int;
    final penalesAtajados = (arquero['penalesAtajados'] ?? 0) as int;

    Color colorNivel;
    String nivel;

    if (esMejor) {
      colorNivel = Colors.green;
      nivel = 'TOP';
    } else if (eficacia >= 45) {
      colorNivel = Colors.green;
      nivel = 'ALTO';
    } else if (eficacia >= 30) {
      colorNivel = Colors.orange;
      nivel = 'MEDIO';
    } else {
      colorNivel = Colors.red;
      nivel = 'BAJO';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1722),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorNivel.withOpacity(esMejor ? 0.65 : 0.40),
          width: esMejor ? 2 : 1.2,
        ),
        boxShadow: esMejor
            ? [
                BoxShadow(
                  color: colorNivel.withOpacity(0.22),
                  blurRadius: 14,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  nombre,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: colorNivel.withOpacity(0.20),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  nivel,
                  style: TextStyle(
                    color: colorNivel,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildShareCompactStat(
                'Eficacia',
                '${eficacia.toStringAsFixed(1)}%',
              ),
              const SizedBox(width: 6),
              _buildShareCompactStat('Atajadas', '$atajadas'),
              const SizedBox(width: 6),
              _buildShareCompactStat('Goles', '$goles'),
              const SizedBox(width: 6),
              _buildShareCompactStat('Penales', '$penalesAtajados/$penales'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShareCompactStat(String label, String value) {
    double? numericValue;

    if (label == 'Eficacia' && value.contains('%')) {
      final cleanValue = value.replaceAll('%', '').trim();
      numericValue = double.tryParse(cleanValue);
    }

    final valueColor = numericValue == null
        ? Colors.white
        : _colorEficacia(numericValue);

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: valueColor,
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFFAAB4C3),
                fontSize: 8,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShareInfoPanel({
    required String title,
    required Map<String, String> rows,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF111A28),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          ...rows.entries.map((e) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      e.key,
                      style: const TextStyle(
                        color: Color(0xFFAAB4C3),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Text(
                    e.value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildShareTwoTeamPanel({
    required String title,
    required String leftTitle,
    required String rightTitle,
    required List<_ShareTeamStatRow> rows,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF111A28),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  leftTitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF8FA3BF),
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 90),
              Expanded(
                child: Text(
                  rightTitle,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF8FA3BF),
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...rows.map((row) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      row.left,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 90,
                    child: Text(
                      row.label,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFFAAB4C3),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      row.right,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildShareGoalkeeperDetailPanel(Map<String, dynamic> arquero) {
    final nombre = (arquero['arqueroNombre'] ?? arquero['arquero'] ?? 'Arquero')
        .toString();

    final eficacia = (arquero['eficacia'] ?? 0.0) as double;
    final atajadas = (arquero['atajadas'] ?? 0) as int;
    final goles = (arquero['golesRecibidos'] ?? 0) as int;
    final penales = (arquero['penales'] ?? 0) as int;
    final penalesAtajados = (arquero['penalesAtajados'] ?? 0) as int;
    final contra = (arquero['contraDirecta'] ?? 0) as int;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF111A28),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF22C55E).withOpacity(0.65),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF22C55E).withOpacity(0.18),
            blurRadius: 16,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  nombre,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF22C55E).withOpacity(0.18),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'TOP',
                  style: TextStyle(
                    color: Color(0xFF22C55E),
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildStoryKpi('${eficacia.toStringAsFixed(1)}%', 'Eficacia'),
              const SizedBox(width: 8),
              _buildStoryKpi('$atajadas', 'Atajadas'),
              const SizedBox(width: 8),
              _buildStoryKpi('$goles', 'Goles'),
            ],
          ),
          const SizedBox(height: 10),
          _buildShareInsightRow('Zona fuerte', _zonaFuerte(arquero)),
          _buildShareInsightRow('Zona débil', _zonaDebil(arquero)),
          _buildShareInsightRow('Más atacada', _zonaMasAtacada(arquero)),
          _buildShareInsightRow('Penales', '$penalesAtajados/$penales'),
          _buildShareInsightRow('Contra directa', '$contra'),
        ],
      ),
    );
  }

  int _tirosPorModo(String modoObjetivo) {
    return _eventos.where((e) {
      if (e is! Map) return false;

      final map = Map<String, dynamic>.from(e);
      final tipo = (map['tipo'] ?? map['kind'] ?? '').toString();
      final modo = (map['modo'] ?? '').toString();

      return modo == modoObjetivo &&
          (tipo == 'tiro' || tipo == 'penal' || tipo == 'penal_tanda');
    }).length;
  }

  int _tirosAtajadosPorModo(String modoObjetivo) {
    return _eventos.where((e) {
      if (e is! Map) return false;

      final map = Map<String, dynamic>.from(e);
      final tipo = (map['tipo'] ?? map['kind'] ?? '').toString();
      final modo = (map['modo'] ?? '').toString();
      final resultado = (map['resultado'] ?? '').toString();

      return modo == modoObjetivo &&
          resultado == 'atajado' &&
          (tipo == 'tiro' || tipo == 'penal' || tipo == 'penal_tanda');
    }).length;
  }

  /// ===============================
  /// PARTIDO V2
  /// Lectura paralela del resumen usando la base 2.0.
  /// Por ahora solo se usa para leer datos sin cambiar la pantalla.
  /// ===============================
  PartidoModel get partidoV2 => PartidoModel.fromMap(partido);

  /// ===============================
  /// ESTADÍSTICAS DESDE MODELO 2.0
  /// Lectura paralela del resumen usando PartidoModel.
  /// ===============================

  double get _eficaciaArqueroV2 => partidoV2.eficaciaArquero;

  int get _atajadasV2 => partidoV2.atajadas;

  int get _golesRecibidosV2 => partidoV2.golesRecibidos;

  int get _penalesV2 => partidoV2.penales;

  int get _perdidasV2 => partidoV2.perdidas;

  int get _recuperacionesV2 => partidoV2.recuperaciones;

  int get _exclusiones2MinV2 => partidoV2.exclusiones2Min;

  int get _amarillasV2 => partidoV2.amarillas;

  int get _rojasV2 => partidoV2.rojas;

  int get _golesSanFernandoV2 => partidoV2.golesSanFernando;

  int get _golesRivalV2 => partidoV2.golesRival;

  /// ===============================
  /// STATS POR ARQUERO
  /// Solo toma tiros defensivos del rival:
  /// - atajado
  /// - gol
  /// Ignora tiros en modo ataque, porque no pertenecen
  /// al arquero propio.
  /// ===============================

  List<Map<String, dynamic>> _estadisticasPorArquero() {
    final Map<String, Map<String, dynamic>> acumulado = {};

    PlayerProfile? arqueroDesdePlayerId(String? playerId) {
      final id = (playerId ?? '').trim();
      if (id.isEmpty || id == 'null') return null;

      for (final p in RosterRepository.players) {
        if (p.playerId == id && p.esArquero) return p;
      }

      return null;
    }

    PlayerProfile? arqueroDesdeDorsal(String? dorsal) {
      final value = (dorsal ?? '').trim();
      if (value.isEmpty || value == 'null') return null;

      final arqueros = RosterRepository.goalkeepersForCategory(
        categoria: partidoV2.categoria,
        temporada: '2026',
      );

      for (final p in arqueros) {
        if ((p.numeroPreferido ?? '').trim() == value) return p;
      }

      return null;
    }

    PlayerProfile? resolverArquero(Map<String, dynamic> map) {
      final arqueroId = (map['arqueroId'] ?? '').toString().trim();
      final actorId = (map['actorPrincipalId'] ?? '').toString().trim();
      final arqueroRaw = (map['arquero'] ?? '').toString().trim();

      return arqueroDesdePlayerId(arqueroId) ??
          arqueroDesdePlayerId(actorId) ??
          arqueroDesdeDorsal(arqueroRaw);
    }

    String periodoDesdeEvento(Map<String, dynamic> map) {
      final raw =
          (map['periodo'] ??
                  map['tiempo'] ??
                  map['tiempoPartido'] ??
                  map['estadoTiempo'] ??
                  map['estadoPartido'] ??
                  '')
              .toString()
              .trim()
              .toLowerCase();

      if (raw == '1t' || raw == 'primer_tiempo' || raw == 'primer tiempo') {
        return '1T';
      }

      if (raw == '2t' || raw == 'segundo_tiempo' || raw == 'segundo tiempo') {
        return '2T';
      }

      if (raw == '1ta' || raw == 'primer_tiempo_alargue') return '1TA';
      if (raw == '2ta' || raw == 'segundo_tiempo_alargue') return '2TA';
      if (raw == 'penales') return 'Penales';

      return 'Global';
    }

    Map<String, dynamic> crearItem(PlayerProfile arquero) {
      return {
        'arquero': arquero.playerId,
        'arqueroId': arquero.playerId,
        'arqueroNombre': arquero.displayName,
        'arqueroDorsal': arquero.numeroPreferido ?? '-',
        'atajadas': 0,
        'golesRecibidos': 0,
        'palos': 0,
        'fuera': 0,
        'tirosAlArco': 0,
        'totalEventos': 0,
        'penales': 0,
        'penalesAtajados': 0,
        'contraDirecta': 0,
        'periodos': <String, Map<String, dynamic>>{},
        'zonasArco': <String, Map<String, int>>{},
        'zonasTiro': <String, Map<String, int>>{},
      };
    }

    void sumarEnMapa(
      Map<String, Map<String, int>> destino,
      String key,
      String resultado,
    ) {
      if (key.trim().isEmpty || key == 'null') return;

      destino.putIfAbsent(key, () {
        return {'atajadas': 0, 'golesRecibidos': 0, 'palos': 0, 'fuera': 0};
      });

      if (resultado == 'atajado') {
        destino[key]!['atajadas'] = (destino[key]!['atajadas'] ?? 0) + 1;
      }

      if (resultado == 'gol') {
        destino[key]!['golesRecibidos'] =
            (destino[key]!['golesRecibidos'] ?? 0) + 1;
      }

      if (resultado == 'palo') {
        destino[key]!['palos'] = (destino[key]!['palos'] ?? 0) + 1;
      }

      if (resultado == 'fuera' ||
          resultado == 'desvio' ||
          resultado == 'desvío') {
        destino[key]!['fuera'] = (destino[key]!['fuera'] ?? 0) + 1;
      }
    }

    void sumarPeriodo({
      required Map<String, Map<String, dynamic>> periodos,
      required String periodo,
      required String resultado,
      required String zonaArco,
      required String zonaTiro,
      required bool esPenal,
      required bool esContraDirectaArquero,
    }) {
      periodos.putIfAbsent(periodo, () {
        return {
          'atajadas': 0,
          'golesRecibidos': 0,
          'palos': 0,
          'fuera': 0,
          'penales': 0,
          'penalesAtajados': 0,
          'contraDirecta': 0,
          'zonasArco': <String, Map<String, int>>{},
          'zonasTiro': <String, Map<String, int>>{},
        };
      });

      final data = periodos[periodo]!;

      if (esContraDirectaArquero) {
        data['contraDirecta'] = (data['contraDirecta'] as int) + 1;
        return;
      }

      if (resultado == 'atajado') {
        data['atajadas'] = (data['atajadas'] as int) + 1;
      }

      if (resultado == 'gol') {
        data['golesRecibidos'] = (data['golesRecibidos'] as int) + 1;
      }

      if (resultado == 'palo') {
        data['palos'] = (data['palos'] as int) + 1;
      }

      if (resultado == 'fuera' ||
          resultado == 'desvio' ||
          resultado == 'desvío') {
        data['fuera'] = (data['fuera'] as int) + 1;
      }

      if (esPenal) {
        data['penales'] = (data['penales'] as int) + 1;

        if (resultado == 'atajado') {
          data['penalesAtajados'] = (data['penalesAtajados'] as int) + 1;
        }
      }

      final zonasArcoPeriodo =
          data['zonasArco'] as Map<String, Map<String, int>>;
      final zonasTiroPeriodo =
          data['zonasTiro'] as Map<String, Map<String, int>>;

      sumarEnMapa(zonasArcoPeriodo, zonaArco, resultado);
      sumarEnMapa(zonasTiroPeriodo, zonaTiro, resultado);
    }

    for (final e in _eventos) {
      if (e is! Map) continue;

      final map = Map<String, dynamic>.from(e);

      final tipo = (map['tipo'] ?? map['kind'] ?? '').toString().trim();
      final resultado = (map['resultado'] ?? '').toString().trim();
      final modoEvento = (map['modo'] ?? map['phase'] ?? '').toString().trim();
      final origen = (map['origenJugada'] ?? '').toString().trim();
      final zonaTiro = (map['zonaTiro'] ?? '').toString().trim();
      final zonaArco = (map['zonaArco'] ?? '').toString().trim();

      final bool esTiro =
          tipo == 'tiro' || tipo == 'penal' || tipo == 'penal_tanda';

      if (!esTiro) continue;

      final bool resultadoValido =
          resultado == 'atajado' ||
          resultado == 'gol' ||
          resultado == 'palo' ||
          resultado == 'fuera' ||
          resultado == 'desvio' ||
          resultado == 'desvío';

      if (!resultadoValido) continue;

      final bool esContraDirectaArquero =
          modoEvento == 'ataque' &&
          origen == 'contra' &&
          zonaTiro == 'Contra directa arquero';

      final bool esDefensivoArquero = modoEvento == 'defensa';

      if (!esDefensivoArquero && !esContraDirectaArquero) continue;

      final arquero = resolverArquero(map);
      if (arquero == null) continue;

      acumulado.putIfAbsent(arquero.playerId, () => crearItem(arquero));

      final item = acumulado[arquero.playerId]!;

      item['totalEventos'] = (item['totalEventos'] as int) + 1;

      final periodos = item['periodos'] as Map<String, Map<String, dynamic>>;
      final periodo = periodoDesdeEvento(map);

      if (esContraDirectaArquero) {
        item['contraDirecta'] = (item['contraDirecta'] as int) + 1;

        sumarPeriodo(
          periodos: periodos,
          periodo: periodo,
          resultado: resultado,
          zonaArco: zonaArco,
          zonaTiro: zonaTiro,
          esPenal: false,
          esContraDirectaArquero: true,
        );

        continue;
      }

      if (resultado == 'atajado') {
        item['atajadas'] = (item['atajadas'] as int) + 1;
        item['tirosAlArco'] = (item['tirosAlArco'] as int) + 1;
      }

      if (resultado == 'gol') {
        item['golesRecibidos'] = (item['golesRecibidos'] as int) + 1;
        item['tirosAlArco'] = (item['tirosAlArco'] as int) + 1;
      }

      if (resultado == 'palo') {
        item['palos'] = (item['palos'] as int) + 1;
      }

      if (resultado == 'fuera' ||
          resultado == 'desvio' ||
          resultado == 'desvío') {
        item['fuera'] = (item['fuera'] as int) + 1;
      }

      final bool esPenal = tipo == 'penal' || tipo == 'penal_tanda';

      if (esPenal) {
        item['penales'] = (item['penales'] as int) + 1;

        if (resultado == 'atajado') {
          item['penalesAtajados'] = (item['penalesAtajados'] as int) + 1;
        }
      }

      final zonasArco = item['zonasArco'] as Map<String, Map<String, int>>;
      final zonasTiro = item['zonasTiro'] as Map<String, Map<String, int>>;

      sumarEnMapa(zonasArco, zonaArco, resultado);
      sumarEnMapa(zonasTiro, zonaTiro, resultado);

      sumarPeriodo(
        periodos: periodos,
        periodo: periodo,
        resultado: resultado,
        zonaArco: zonaArco,
        zonaTiro: zonaTiro,
        esPenal: esPenal,
        esContraDirectaArquero: false,
      );
    }

    final lista = acumulado.values
        .map((item) {
          final atajadas = item['atajadas'] as int;
          final golesRecibidos = item['golesRecibidos'] as int;
          final total = atajadas + golesRecibidos;
          final eficacia = total == 0 ? 0.0 : (atajadas / total) * 100;

          return {...item, 'eficacia': eficacia};
        })
        .where((item) {
          final atajadas = (item['atajadas'] ?? 0) as int;
          final goles = (item['golesRecibidos'] ?? 0) as int;
          final palos = (item['palos'] ?? 0) as int;
          final fuera = (item['fuera'] ?? 0) as int;
          final penales = (item['penales'] ?? 0) as int;
          final contraDirecta = (item['contraDirecta'] ?? 0) as int;

          return atajadas + goles + palos + fuera + penales + contraDirecta > 0;
        })
        .toList();

    lista.sort((a, b) {
      final efA = (a['eficacia'] ?? 0.0) as double;
      final efB = (b['eficacia'] ?? 0.0) as double;
      return efB.compareTo(efA);
    });

    return lista;
  }

  int get _atajadasDesdeArqueros {
    return _estadisticasPorArquero().fold(
      0,
      (acc, item) => acc + ((item['atajadas'] ?? 0) as int),
    );
  }

  int get _golesRecibidosDesdeArqueros {
    return _estadisticasPorArquero().fold(
      0,
      (acc, item) => acc + ((item['golesRecibidos'] ?? 0) as int),
    );
  }

  double get _eficaciaDesdeArqueros {
    final atajadas = _atajadasDesdeArqueros;
    final goles = _golesRecibidosDesdeArqueros;
    final total = atajadas + goles;
    if (total == 0) return 0;
    return (atajadas / total) * 100;
  }

  const ResumenPartidoFinalizadoScreen({super.key, required this.partido});

  bool get _somosLocales => (partido['condicion'] ?? 'Local') == 'Local';

  String get _nombreLocal =>
      _somosLocales ? 'San Fernando' : (partido['rival'] ?? 'Rival').toString();

  String get _nombreVisitante =>
      _somosLocales ? (partido['rival'] ?? 'Rival').toString() : 'San Fernando';

  int get _golesSanFernando => (partido['golesSanFernando'] ?? 0) as int;
  int get _golesRival => (partido['golesRival'] ?? 0) as int;

  int get _golesLocal => _somosLocales ? _golesSanFernando : _golesRival;
  int get _golesVisitante => _somosLocales ? _golesRival : _golesSanFernando;

  int get _atajadas => (partido['atajadas'] ?? 0) as int;
  int get _golesRecibidos => (partido['golesRecibidos'] ?? _golesRival) as int;
  int get _penales => (partido['penales'] ?? 0) as int;
  int get _perdidas => (partido['perdidas'] ?? 0) as int;
  int get _recuperaciones => (partido['recuperaciones'] ?? 0) as int;
  int get _exclusiones2Min => (partido['exclusiones2Min'] ?? 0) as int;
  int get _amarillas => (partido['amarillas'] ?? 0) as int;
  int get _rojas => (partido['rojas'] ?? 0) as int;

  List<dynamic> get _eventos =>
      (partido['eventos'] as List<dynamic>? ?? const []);

  double get _eficaciaArquero {
    final total = _atajadas + _golesRecibidos;
    if (total == 0) return 0;
    return (_atajadas / total) * 100;
  }

  int get _golesAFavor => _golesSanFernando;

  int get _golesEnContra => _golesRival;

  int get _tirosTotales {
    return _eventos.where((e) {
      final map = Map<String, dynamic>.from(e as Map);
      final tipo = (map['tipo'] ?? map['kind'] ?? '').toString();
      return tipo == 'tiro' || tipo == 'penal' || tipo == 'penal_tanda';
    }).length;
  }

  int get _tirosGol {
    return _eventos.where((e) {
      final map = Map<String, dynamic>.from(e as Map);
      return (map['resultado'] ?? '').toString() == 'gol';
    }).length;
  }

  int get _tirosAtajados {
    return _eventos.where((e) {
      final map = Map<String, dynamic>.from(e as Map);
      return (map['resultado'] ?? '').toString() == 'atajado';
    }).length;
  }

  int get _tirosFuera {
    return _eventos.where((e) {
      final map = Map<String, dynamic>.from(e as Map);
      final r = (map['resultado'] ?? '').toString();
      return r == 'fuera' || r == 'desvio';
    }).length;
  }

  String _fechaTexto() => (partido['fecha'] ?? '-').toString();
  String _horaTexto() => (partido['hora'] ?? '-').toString();
  String _condicionTexto() => (partido['condicion'] ?? '-').toString();
  String _torneoTexto() => (partido['torneo'] ?? '-').toString();
  String _categoriaTexto() => (partido['categoria'] ?? '-').toString();
  String _rivalTexto() => (partido['rival'] ?? 'Rival').toString();

  String? _rivalShieldAsset() {
    final rival = _rivalTexto().toLowerCase();

    if (rival.contains('argentinos')) return 'assets/images/argentinos.png';
    if (rival.contains('ferro')) return 'assets/images/ferro.png';
    if (rival.contains('vélez') || rival.contains('velez')) {
      return 'assets/images/velez.png';
    }
    if (rival.contains('campana')) return 'assets/images/campana.png';
    if (rival.contains('river')) return 'assets/images/river.png';
    if (rival.contains('dorrego')) return 'assets/images/dorrego.png';
    if (rival.contains('ballester')) return 'assets/images/ballester.png';
    if (rival.contains('s.a.g.a.b.') || rival.contains('sagab')) {
      return 'assets/images/sagab.png';
    }
    if (rival.contains('quilmes')) return 'assets/images/quilmes.png';
    if (rival.contains('lanús') || rival.contains('lanus')) {
      return 'assets/images/lanus.png';
    }
    if (rival.contains('s.e.d.a.l.o.') || rival.contains('sedalo')) {
      return 'assets/images/sedalo.png';
    }
    if (rival.contains('vicente lópez') || rival.contains('vicente lopez')) {
      return 'assets/images/vicente_lopez.png';
    }
    if (rival.contains('estudiantes')) {
      return 'assets/images/estudiantes_lp.png';
    }
    if (rival.contains('ward')) return 'assets/images/ward.png';
    if (rival.contains('luján') || rival.contains('lujan')) {
      return 'assets/images/nsl.png';
    }

    return null;
  }

  List<Map<String, dynamic>> _eventosImportantes() {
    final items = _eventos
        .map((e) => Map<String, dynamic>.from(e as Map))
        .where((map) {
          final tipo = (map['tipo'] ?? map['kind'] ?? '').toString();
          final resultado = (map['resultado'] ?? '').toString();

          if (tipo == 'sancion') return true;
          if (tipo == 'penal' || tipo == 'penal_tanda') return true;
          if (resultado == 'gol' || resultado == 'atajado') return true;
          if (tipo == 'perdida' || tipo == 'recuperacion') return true;

          return false;
        })
        .toList();

    return items.reversed.take(5).toList();
  }

  String _tituloEvento(Map<String, dynamic> e) {
    final tipo = (e['tipo'] ?? e['kind'] ?? '').toString();
    final resultado = (e['resultado'] ?? '').toString();

    if (tipo == 'tiro' && resultado == 'gol') return 'Gol';
    if (tipo == 'tiro' && resultado == 'atajado') return 'Atajada';
    if (tipo == 'tiro' && (resultado == 'fuera' || resultado == 'desvio')) {
      return 'Tiro fuera';
    }

    if (tipo == 'penal' && resultado == 'gol') return 'Gol de penal';
    if (tipo == 'penal' && resultado == 'atajado') return 'Penal atajado';
    if (tipo == 'penal' && resultado == 'fuera') return 'Penal fuera';

    if (tipo == 'penal_tanda' && resultado == 'gol') return 'Gol en penales';
    if (tipo == 'penal_tanda' && resultado == 'atajado') {
      return 'Atajado en penales';
    }
    if (tipo == 'penal_tanda' && resultado == 'fuera') {
      return 'Errado en penales';
    }

    if (tipo == 'sancion') {
      if (resultado == 'exclusion_2_min') return 'Exclusión 2 min';
      if (resultado == 'tarjeta_amarilla') return 'Tarjeta amarilla';
      if (resultado == 'tarjeta_roja') return 'Tarjeta roja';
      return 'Sanción';
    }

    if (tipo == 'perdida' && resultado == 'perdida') return 'Pérdida';
    if (tipo == 'perdida' && resultado == 'recuperacion') return 'Recuperación';

    return tipo.isEmpty ? 'Evento' : tipo;
  }

  String _subtituloEvento(Map<String, dynamic> e) {
    final actorRaw = (e['actorPrincipal'] ?? '-').toString();

    final actor = _normalizarActorEvento(actorRaw);
    final zonaTiro = (e['zonaTiro'] ?? '').toString();
    final zonaArco = (e['zonaArco'] ?? '').toString();

    final partes = <String>[actor];

    if (zonaTiro.isNotEmpty && zonaTiro != 'null') {
      partes.add(zonaTiro);
    }
    if (zonaArco.isNotEmpty && zonaArco != 'null') {
      partes.add(zonaArco);
    }

    return partes.join(' · ');
  }

  String _normalizarActorEvento(String actorRaw) {
    final actor = actorRaw.trim();

    if (actor.isEmpty || actor == '-' || actor == 'null') {
      return '-';
    }

    final dorsalMatch = RegExp(r'^(\d+)').firstMatch(actor);

    if (dorsalMatch == null) {
      return actor;
    }

    final dorsal = dorsalMatch.group(1)!;

    return nombreJugadorDesdeDorsal(
      categoria: partidoV2.categoria,
      dorsal: dorsal,
    );
  }

  @override
  Widget build(BuildContext context) {
    final eventosImportantes = _eventosImportantes();
    final estadisticasPorArquero = _estadisticasPorArquero();
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Resumen del partido'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/fondohd.jpeg',
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
          ),
          Positioned.fill(
            child: Container(color: const Color(0xFF05080D).withOpacity(0.88)),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${partidoV2.categoria} · ${partidoV2.torneo}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFFD4DCE7),
                    ),
                  ),
                  const SizedBox(height: 18),
                  _buildHeaderCard(context),
                  const SizedBox(height: 16),
                  _buildKpiGrid(),
                  const SizedBox(height: 16),
                  _buildSectionCard(
                    title: 'Datos del partido',
                    child: Column(
                      children: [
                        _buildInfoRow('Rival', partidoV2.rival),
                        _buildInfoRow('Fecha', partidoV2.fecha),
                        _buildInfoRow('Hora', partidoV2.hora),
                        _buildInfoRow('Condición', _condicionTexto()),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ArquerosPartidoScreen(
                            estadisticasPorArquero: estadisticasPorArquero,
                            categoria: partidoV2.categoria,
                          ),
                        ),
                      );
                    },
                    child: _buildSectionCard(
                      title: 'Arqueros del partido',
                      child: Column(
                        children: [
                          _buildInfoRow(
                            'Eficacia global',
                            '${_eficaciaDesdeArqueros.toStringAsFixed(1)}%',
                          ),
                          _buildInfoRow('Atajadas', '$_atajadasDesdeArqueros'),
                          _buildInfoRow(
                            'Goles recibidos',
                            '$_golesRecibidosDesdeArqueros',
                          ),
                          _buildInfoRow('Penales rival', '$_penalesV2'),
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              vertical: 14,
                              horizontal: 16,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF182338).withOpacity(0.85),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.06),
                              ),
                            ),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.sports_handball_rounded,
                                  color: Color(0xFF4F8CFF),
                                  size: 22,
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Ver análisis completo de arqueros',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                Icon(
                                  Icons.chevron_right_rounded,
                                  color: Colors.white70,
                                  size: 26,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSectionCard(
                    title: 'Ataque y juego',
                    child: Column(
                      children: [
                        _buildInfoRow('Goles a favor', '$_golesSanFernandoV2'),
                        _buildInfoRow('Goles en contra', '$_golesRivalV2'),
                        _buildInfoRow('Tiros registrados', '$_tirosTotales'),
                        _buildInfoRow('Tiros con gol', '$_tirosGol'),
                        _buildInfoRow('Tiros atajados', '$_tirosAtajados'),
                        _buildInfoRow('Tiros fuera', '$_tirosFuera'),
                        _buildInfoRow('Pérdidas', '$_perdidasV2'),
                        _buildInfoRow('Recuperaciones', '$_recuperacionesV2'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSectionCard(
                    title: 'Disciplina',
                    child: Column(
                      children: [
                        _buildInfoRow(
                          'Exclusiones 2 min',
                          '$_exclusiones2MinV2',
                        ),
                        _buildInfoRow('Tarjetas amarillas', '$_amarillasV2'),
                        _buildInfoRow('Tarjetas rojas', '$_rojasV2'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSectionCard(
                    title: 'Momentos importantes',
                    child: eventosImportantes.isEmpty
                        ? const Text(
                            'No hay eventos destacados para mostrar.',
                            style: TextStyle(
                              color: Color(0xFFAAB4C3),
                              fontSize: 13,
                            ),
                          )
                        : Column(
                            children: eventosImportantes.map((e) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFF182338,
                                    ).withOpacity(0.75),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _tituloEvento(e),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _subtituloEvento(e),
                                        style: const TextStyle(
                                          color: Color(0xFFAAB4C3),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _shareResumenComoImagen(BuildContext context) async {
    try {
      final resumenFile = await _captureShareCardAsFile(
        context: context,
        fileName: 'resumen_partido',
        child: _buildShareMatchOverviewCard(context),
      );

      final arquerosFile = await _captureShareCardAsFile(
        context: context,
        fileName: 'arqueros_partido',
        child: _buildShareGoalkeepersAnalysisCard(context),
      );

      final heatmapFile = await _captureShareCardAsFile(
        context: context,
        fileName: 'heatmap_arqueros',
        child: _buildShareGoalkeepersHeatmapCard(context),
      );

      await Share.shareXFiles(
        [
          XFile(resumenFile.path),
          XFile(arquerosFile.path),
          XFile(heatmapFile.path),
        ],
        text:
            'Resumen del partido - ${partidoV2.categoria} ${partidoV2.torneo}',
      );
    } catch (e) {
      debugPrint('ERROR SHARE MULTIPLE IMAGE -> $e');

      await Share.share(_buildResumenCompartible());

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudieron compartir las imágenes: $e')),
      );
    }
  }

  Color _shareIntensityColor(int value, int maxValue) {
    if (value <= 0 || maxValue <= 0) return const Color(0xFF1B2533);

    final ratio = value / maxValue;

    if (ratio >= 0.75) return const Color(0xFFEF4444);
    if (ratio >= 0.45) return const Color(0xFFF97316);
    if (ratio >= 0.20) return const Color(0xFFFACC15);

    return const Color(0xFF22C55E);
  }

  String _zonaLabel(String zona) {
    switch (zona) {
      case 'AI':
        return 'Arr. izq.';
      case 'AC':
        return 'Arr. centro';
      case 'AD':
        return 'Arr. der.';
      case 'CI':
        return 'Med. izq.';
      case 'CC':
        return 'Centro';
      case 'CD':
        return 'Med. der.';
      case 'BI':
        return 'Ab. izq.';
      case 'BC':
        return 'Ab. centro';
      case 'BD':
        return 'Ab. der.';
      default:
        return zona;
    }
  }

  Map<String, int> _zonasArcoTotales(Map<String, dynamic> arquero) {
    final result = <String, int>{
      'AI': 0,
      'AC': 0,
      'AD': 0,
      'CI': 0,
      'CC': 0,
      'CD': 0,
      'BI': 0,
      'BC': 0,
      'BD': 0,
    };

    final zonasRaw = arquero['zonasArco'];

    if (zonasRaw is! Map) return result;

    zonasRaw.forEach((key, value) {
      if (value is! Map) return;

      final zona = key.toString();
      final atajadas = (value['atajadas'] ?? 0) as int;
      final goles = (value['golesRecibidos'] ?? 0) as int;
      final palos = (value['palos'] ?? 0) as int;
      final fuera = (value['fuera'] ?? 0) as int;

      result[zona] = atajadas + goles + palos + fuera;
    });

    return result;
  }

  String _zonaMasAtacada(Map<String, dynamic> arquero) {
    final zonas = _zonasArcoTotales(arquero);
    final entries = zonas.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    if (entries.isEmpty || entries.first.value == 0) return '-';

    return _zonaLabel(entries.first.key);
  }

  String _zonaFuerte(Map<String, dynamic> arquero) {
    final zonasRaw = arquero['zonasArco'];
    if (zonasRaw is! Map) return '-';

    String bestZona = '-';
    double bestValue = -1;

    zonasRaw.forEach((key, value) {
      if (value is! Map) return;

      final atajadas = (value['atajadas'] ?? 0) as int;
      final goles = (value['golesRecibidos'] ?? 0) as int;
      final total = atajadas + goles;

      if (total == 0) return;

      final eficacia = atajadas / total;

      if (eficacia > bestValue) {
        bestValue = eficacia;
        bestZona = key.toString();
      }
    });

    return bestZona == '-' ? '-' : _zonaLabel(bestZona);
  }

  String _zonaDebil(Map<String, dynamic> arquero) {
    final zonasRaw = arquero['zonasArco'];
    if (zonasRaw is! Map) return '-';

    String worstZona = '-';
    double worstValue = 2;

    zonasRaw.forEach((key, value) {
      if (value is! Map) return;

      final atajadas = (value['atajadas'] ?? 0) as int;
      final goles = (value['golesRecibidos'] ?? 0) as int;
      final total = atajadas + goles;

      if (total == 0) return;

      final eficacia = atajadas / total;

      if (eficacia < worstValue) {
        worstValue = eficacia;
        worstZona = key.toString();
      }
    });

    return worstZona == '-' ? '-' : _zonaLabel(worstZona);
  }

  Widget _buildStoryHeatmap(Map<String, dynamic> arquero) {
    final zonas = _zonasArcoTotales(arquero);
    final maxValue = zonas.values.isEmpty
        ? 0
        : zonas.values.reduce((a, b) => a > b ? a : b);

    final order = [
      ['AI', 'AC', 'AD'],
      ['CI', 'CC', 'CD'],
      ['BI', 'BC', 'BD'],
    ];

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF111A28),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          const Text(
            'Arriba del arco',
            style: TextStyle(
              color: Color(0xFFAAB4C3),
              fontSize: 9,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 5),
          ...order.map((row) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Row(
                children: row.map((zona) {
                  final value = zonas[zona] ?? 0;

                  return Expanded(
                    child: Container(
                      height: 36,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        color: _shareIntensityColor(value, maxValue),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Center(
                        child: Text(
                          value == 0 ? '-' : '$value',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            );
          }),
          const SizedBox(height: 2),
          const Text(
            'Rojo = más atacada · Verde = menor volumen',
            textAlign: TextAlign.center,
            maxLines: 2,
            style: TextStyle(
              color: Color(0xFFAAB4C3),
              fontSize: 9,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoryKpi(String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF1A2433),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFFAAB4C3),
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoryGoalkeeperRow(Map<String, dynamic> item) {
    final nombre = (item['arqueroNombre'] ?? item['arquero'] ?? 'Arquero')
        .toString();

    final eficacia = (item['eficacia'] ?? 0.0) as double;
    final atajadas = (item['atajadas'] ?? 0) as int;
    final goles = (item['golesRecibidos'] ?? 0) as int;
    final contra = (item['contraDirecta'] ?? 0) as int;

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF111A28),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              nombre,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '${eficacia.toStringAsFixed(1)}% · A $atajadas · G $goles · CD $contra',
            maxLines: 1,
            style: const TextStyle(
              color: Color(0xFFDCE4EF),
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  String _buildResumenCompartible() {
    final local = _nombreLocal;
    final visitante = _nombreVisitante;

    final golesLocal = _golesLocal;
    final golesVisitante = _golesVisitante;

    final eficacia = _eficaciaDesdeArqueros;
    final atajadas = _atajadasDesdeArqueros;
    final golesRecibidos = _golesRecibidosDesdeArqueros;

    final fecha = partidoV2.fecha;
    final categoria = partidoV2.categoria;
    final torneo = partidoV2.torneo;
    final condicion = _condicionTexto();

    final arqueros = _estadisticasPorArquero();

    String arquerosDetalle = '';

    if (arqueros.isNotEmpty) {
      arquerosDetalle = '\n\n🧤 Arqueros:\n';

      for (int i = 0; i < arqueros.length && i < 2; i++) {
        final a = arqueros[i];

        final nombre = (a['arqueroNombre'] ?? a['arquero'] ?? 'Arquero')
            .toString();

        final ef = (a['eficacia'] ?? 0.0) as double;
        final at = (a['atajadas'] ?? 0) as int;
        final gr = (a['golesRecibidos'] ?? 0) as int;

        arquerosDetalle += '• $nombre → ${ef.toStringAsFixed(1)}% ($at/$gr)\n';
      }
    }

    return '''
🏆 $categoria · $torneo

🤾 $local vs $visitante
📍 $condicion
📊 Resultado: $golesLocal - $golesVisitante

🧤 Global:
- Eficacia: ${eficacia.toStringAsFixed(1)}%
- Atajadas: $atajadas
- Goles: $golesRecibidos
$arquerosDetalle
📅 $fecha
''';
  }

  Widget _buildShareGoalkeepersHeatmapCard(BuildContext context) {
    final arqueros = _estadisticasPorArquero();

    return Material(
      color: Colors.transparent,
      child: Container(
        width: 390,
        height: 693,
        padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF070D17), Color(0xFF101827)],
          ),
        ),
        child: Column(
          children: [
            const Text(
              'MAPA DE ARQUEROS',
              style: TextStyle(
                color: Color(0xFF8FA3BF),
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '${partidoV2.categoria} · ${partidoV2.torneo}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 21,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 18),

            if (arqueros.isEmpty)
              const Expanded(
                child: Center(
                  child: Text(
                    'No hay datos de arqueros para generar heatmap.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFFAAB4C3),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              )
            else
              Expanded(
                child: Column(
                  children: [
                    _buildShareHeatmapPanel(
                      arquero: arqueros.first,
                      destacado: true,
                    ),
                    if (arqueros.length > 1) ...[
                      const SizedBox(height: 14),
                      _buildShareHeatmapPanel(
                        arquero: arqueros[1],
                        destacado: false,
                      ),
                    ],
                  ],
                ),
              ),

            Text(
              '${partidoV2.fecha} · ${partidoV2.hora} · ${partidoV2.condicion}',
              style: const TextStyle(
                color: Color(0xFF8FA3BF),
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShareHeatmapPanel({
    required Map<String, dynamic> arquero,
    required bool destacado,
  }) {
    final nombre = (arquero['arqueroNombre'] ?? arquero['arquero'] ?? 'Arquero')
        .toString();

    final zonas = _zonasArcoDetalle(arquero);

    final eficacia = (arquero['eficacia'] ?? 0.0) as double;
    final atajadas = (arquero['atajadas'] ?? 0) as int;
    final goles = (arquero['golesRecibidos'] ?? 0) as int;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF111A28),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: destacado
              ? const Color(0xFF22C55E).withOpacity(0.55)
              : Colors.white.withOpacity(0.06),
          width: destacado ? 1.6 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  nombre,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text(
                '${eficacia.toStringAsFixed(1)}%',
                style: TextStyle(
                  color: _colorEficacia(eficacia),
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '$atajadas atajadas · $goles goles recibidos',
            style: const TextStyle(
              color: Color(0xFFAAB4C3),
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: destacado ? 190 : 145,
            width: double.infinity,
            child: CustomPaint(
              painter: _GoalkeeperBlurHeatmapPainter(zonas: zonas),
            ),
          ),
          const SizedBox(height: 10),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _HeatLegendDot(color: Color(0xFF22C55E), text: 'Atajadas'),
              SizedBox(width: 18),
              _HeatLegendDot(color: Color(0xFFEF4444), text: 'Goles'),
            ],
          ),
        ],
      ),
    );
  }

  Map<String, _GoalZoneHeatData> _zonasArcoDetalle(
    Map<String, dynamic> arquero,
  ) {
    final zonas = <String, _GoalZoneHeatData>{
      'AI': const _GoalZoneHeatData(),
      'AC': const _GoalZoneHeatData(),
      'AD': const _GoalZoneHeatData(),
      'CI': const _GoalZoneHeatData(),
      'CC': const _GoalZoneHeatData(),
      'CD': const _GoalZoneHeatData(),
      'BI': const _GoalZoneHeatData(),
      'BC': const _GoalZoneHeatData(),
      'BD': const _GoalZoneHeatData(),
    };

    final raw = arquero['zonasArco'];

    if (raw is! Map) return zonas;

    raw.forEach((key, value) {
      if (value is! Map) return;

      final zona = key.toString();

      if (!zonas.containsKey(zona)) return;

      zonas[zona] = _GoalZoneHeatData(
        atajadas: (value['atajadas'] ?? 0) as int,
        goles: (value['golesRecibidos'] ?? 0) as int,
        palos: (value['palos'] ?? 0) as int,
        fuera: (value['fuera'] ?? 0) as int,
      );
    });

    return zonas;
  }

  Widget _buildShareImageCard(BuildContext context) {
    final arqueros = _estadisticasPorArquero();

    final mejorArquero = arqueros.isNotEmpty ? arqueros.first : null;

    final mejorNombre = mejorArquero == null
        ? 'Sin arquero'
        : (mejorArquero['arqueroNombre'] ??
                  mejorArquero['arquero'] ??
                  'Arquero')
              .toString();

    final mejorEficacia = mejorArquero == null
        ? 0.0
        : (mejorArquero['eficacia'] ?? 0.0) as double;

    final mejorAtajadas = mejorArquero == null
        ? 0
        : (mejorArquero['atajadas'] ?? 0) as int;

    final mejorGoles = mejorArquero == null
        ? 0
        : (mejorArquero['golesRecibidos'] ?? 0) as int;

    final mejorContra = mejorArquero == null
        ? 0
        : (mejorArquero['contraDirecta'] ?? 0) as int;

    final stats1T = _shareStatsPorPeriodo('1T');
    final stats2T = _shareStatsPorPeriodo('2T');

    return Material(
      color: Colors.transparent,
      child: Container(
        width: 390,
        height: 693,
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF070D17), Color(0xFF101827)],
          ),
        ),
        child: Column(
          children: [
            const Text(
              'HANDBALL SGS',
              style: TextStyle(
                color: Color(0xFF8FA3BF),
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 2.4,
              ),
            ),
            const SizedBox(height: 10),

            Text(
              '${partidoV2.categoria} · ${partidoV2.torneo}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 21,
                fontWeight: FontWeight.w900,
              ),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildShareTeam(
                    nombre: _nombreLocal,
                    assetPath: _somosLocales
                        ? 'assets/images/san_fernando.png'
                        : _rivalShieldAsset(),
                  ),
                ),
                Text(
                  '$_golesLocal - $_golesVisitante',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 38,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Expanded(
                  child: _buildShareTeam(
                    nombre: _nombreVisitante,
                    assetPath: _somosLocales
                        ? _rivalShieldAsset()
                        : 'assets/images/san_fernando.png',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF1A2433),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                children: [
                  const Text(
                    'Arquero destacado',
                    style: TextStyle(
                      color: Color(0xFFAAB4C3),
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    mejorNombre,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildStoryKpi(
                        '${mejorEficacia.toStringAsFixed(1)}%',
                        'Eficacia',
                      ),
                      const SizedBox(width: 8),
                      _buildStoryKpi('$mejorAtajadas', 'Atajadas'),
                      const SizedBox(width: 8),
                      _buildStoryKpi('$mejorGoles', 'Goles'),
                      const SizedBox(width: 8),
                      _buildStoryKpi('$mejorContra', 'C. dir.'),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Mapa de arco',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      mejorArquero == null
                          ? const SizedBox.shrink()
                          : _buildStoryHeatmap(mejorArquero),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF111A28),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      children: [
                        _buildShareInsightRow(
                          'Zona fuerte',
                          mejorArquero == null
                              ? '-'
                              : _zonaFuerte(mejorArquero),
                        ),
                        _buildShareInsightRow(
                          'Zona débil',
                          mejorArquero == null ? '-' : _zonaDebil(mejorArquero),
                        ),
                        _buildShareInsightRow(
                          'Más atacada',
                          mejorArquero == null
                              ? '-'
                              : _zonaMasAtacada(mejorArquero),
                        ),
                        _buildShareInsightRow(
                          '1T',
                          'GF ${stats1T['golesFavor']} · GC ${stats1T['golesContra']}',
                        ),
                        _buildShareInsightRow(
                          '2T',
                          'GF ${stats2T['golesFavor']} · GC ${stats2T['golesContra']}',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF111A28),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                arqueros.length > 1
                    ? 'Participaron ${arqueros.length} arqueros · Ver detalle en análisis completo'
                    : 'Análisis individual del arquero destacado',
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFFAAB4C3),
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const Spacer(),

            Text(
              '${partidoV2.fecha} · ${partidoV2.hora} · ${partidoV2.condicion}',
              style: const TextStyle(
                color: Color(0xFF8FA3BF),
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShareInsightRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFFAAB4C3),
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShareTeam({required String nombre, String? assetPath}) {
    return Column(
      children: [
        Container(
          width: 58,
          height: 58,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
          padding: const EdgeInsets.all(8),
          child: Center(
            child: assetPath == null
                ? const Icon(
                    Icons.sports_handball,
                    color: Color(0xFF1C2B44),
                    size: 24,
                  )
                : Image.asset(assetPath, fit: BoxFit.contain),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          nombre,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _buildShareKpiRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFFAAB4C3),
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1722).withOpacity(0.90),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      child: Column(
        children: [
          /// 🔥 FILA SUPERIOR (estado + share)
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1C2B44).withOpacity(0.95),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Text(
                  'Finalizado',
                  style: TextStyle(
                    color: Color(0xFFDCE4EF),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              const Spacer(),

              /// 🔥 BOTÓN SHARE
              IconButton(
                icon: const Icon(Icons.ios_share_rounded, color: Colors.white),
                onPressed: () => _shareResumenComoImagen(context),
              ),
            ],
          ),

          const SizedBox(height: 18),

          /// 🔥 SCOREBOARD
          Row(
            children: [
              Expanded(
                child: _buildTeamSide(
                  nombre: _nombreLocal,
                  assetPath: _somosLocales
                      ? 'assets/images/san_fernando.png'
                      : _rivalShieldAsset(),
                  condicion: 'Local',
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    '$_golesLocal - $_golesVisitante',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: _buildTeamSide(
                  nombre: _nombreVisitante,
                  assetPath: _somosLocales
                      ? _rivalShieldAsset()
                      : 'assets/images/san_fernando.png',
                  condicion: 'Visitante',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKpiGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildKpiCard(
                'Eficacia',
                '${_eficaciaArquero.toStringAsFixed(1)}%',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(child: _buildKpiCard('Atajadas', '$_atajadas')),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _buildKpiCard('Pérdidas', '$_perdidas')),
            const SizedBox(width: 10),
            Expanded(
              child: _buildKpiCard('Recuperaciones', '$_recuperaciones'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildKpiCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1722).withOpacity(0.82),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFFAAB4C3),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1722).withOpacity(0.82),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildTeamSide({
    required String nombre,
    required String condicion,
    String? assetPath,
  }) {
    return Column(
      children: [
        Text(
          condicion,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFFAAB4C3),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 62,
          height: 62,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
          padding: const EdgeInsets.all(10),
          child: Center(
            child: assetPath == null
                ? const Icon(
                    Icons.sports_handball,
                    color: Color(0xFF1C2B44),
                    size: 24,
                  )
                : Image.asset(assetPath, fit: BoxFit.contain),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          nombre,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFFAAB4C3),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ShareMatchTeamStats {
  final int tiros;
  final int tirosConGol;
  final int tirosAtajados;
  final int tirosFuera;
  final int tirosAlPalo;
  final int penales;
  final int penalesConvertidos;
  final int penalesErrados;
  final int perdidas;
  final int recuperaciones;
  final Map<String, int> perdidasPorTipo;

  const _ShareMatchTeamStats({
    required this.tiros,
    required this.tirosConGol,
    required this.tirosAtajados,
    required this.tirosFuera,
    required this.tirosAlPalo,
    required this.penales,
    required this.penalesConvertidos,
    required this.penalesErrados,
    required this.perdidas,
    required this.recuperaciones,
    required this.perdidasPorTipo,
  });

  int get perdidasForzadas {
    return perdidasPorTipo['robo'] ?? 0;
  }

  int get perdidasNoForzadas {
    final value = perdidas - perdidasForzadas;
    return value < 0 ? 0 : value;
  }
}

String _sharePerdidaLabel(String key) {
  switch (key) {
    case 'robo':
      return 'Robo';
    case 'mal_pase':
      return 'Mal pase';
    case 'invasion':
      return 'Invasión';
    case 'falta_en_ataque':
      return 'Falta ataque';
    case 'pasos':
      return 'Pasos';
    case 'error_tecnico':
      return 'Error técnico';
    case 'doble_drible':
      return 'Doble drible';
    default:
      return key.trim().isEmpty ? 'Sin detalle' : key;
  }
}

String _shareTopPerdidasText(Map<String, int> detalle) {
  if (detalle.isEmpty) return '-';

  final entries = detalle.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));

  return entries
      .take(2)
      .map((e) => '${_sharePerdidaLabel(e.key)} ${e.value}')
      .join(' · ');
}

class _ShareTeamStatRow {
  final String label;
  final String left;
  final String right;

  const _ShareTeamStatRow({
    required this.label,
    required this.left,
    required this.right,
  });
}

class _GoalZoneHeatData {
  final int atajadas;
  final int goles;
  final int palos;
  final int fuera;

  const _GoalZoneHeatData({
    this.atajadas = 0,
    this.goles = 0,
    this.palos = 0,
    this.fuera = 0,
  });

  int get total => atajadas + goles + palos + fuera;
}

class _HeatLegendDot extends StatelessWidget {
  final Color color;
  final String text;

  const _HeatLegendDot({required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          text,
          style: const TextStyle(
            color: Color(0xFFAAB4C3),
            fontSize: 10,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _GoalkeeperBlurHeatmapPainter extends CustomPainter {
  final Map<String, _GoalZoneHeatData> zonas;

  Rect _zoneRect(String zone, Size size) {
    final left = size.width * 0.08;
    final top = size.height * 0.14;
    final goalWidth = size.width * 0.84;
    final goalHeight = size.height * 0.70;

    final cellWidth = goalWidth / 3;
    final cellHeight = goalHeight / 3;

    final index = _orderedZones.indexOf(zone);
    if (index < 0) {
      return Rect.fromLTWH(left, top, cellWidth, cellHeight);
    }

    final row = index ~/ 3;
    final col = index % 3;

    return Rect.fromLTWH(
      left + (cellWidth * col),
      top + (cellHeight * row),
      cellWidth,
      cellHeight,
    );
  }

  const _GoalkeeperBlurHeatmapPainter({required this.zonas});

  static const List<String> _orderedZones = [
    'AI',
    'AC',
    'AD',
    'CI',
    'CC',
    'CD',
    'BI',
    'BC',
    'BD',
  ];

  Offset _zoneCenter(String zone, Size size) {
    final left = size.width * 0.08;
    final top = size.height * 0.14;
    final goalWidth = size.width * 0.84;
    final goalHeight = size.height * 0.70;

    final positions = <String, Offset>{
      'AI': Offset(left + goalWidth * 0.18, top + goalHeight * 0.18),
      'AC': Offset(left + goalWidth * 0.50, top + goalHeight * 0.18),
      'AD': Offset(left + goalWidth * 0.82, top + goalHeight * 0.18),
      'CI': Offset(left + goalWidth * 0.18, top + goalHeight * 0.50),
      'CC': Offset(left + goalWidth * 0.50, top + goalHeight * 0.50),
      'CD': Offset(left + goalWidth * 0.82, top + goalHeight * 0.50),
      'BI': Offset(left + goalWidth * 0.18, top + goalHeight * 0.82),
      'BC': Offset(left + goalWidth * 0.50, top + goalHeight * 0.82),
      'BD': Offset(left + goalWidth * 0.82, top + goalHeight * 0.82),
    };

    return positions[zone] ?? Offset(size.width / 2, size.height / 2);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final maxGoles = zonas.values.fold<int>(
      0,
      (max, data) => data.goles > max ? data.goles : max,
    );

    final maxAtajadas = zonas.values.fold<int>(
      0,
      (max, data) => data.atajadas > max ? data.atajadas : max,
    );

    final goalRect = Rect.fromLTWH(
      size.width * 0.08,
      size.height * 0.14,
      size.width * 0.84,
      size.height * 0.70,
    );

    final bgPaint = Paint()
      ..color = const Color(0xFF07101B)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = Colors.white.withOpacity(0.22)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final netPaint = Paint()
      ..color = Colors.white.withOpacity(0.07)
      ..strokeWidth = 1;

    final rounded = RRect.fromRectAndRadius(
      goalRect,
      const Radius.circular(18),
    );

    canvas.drawRRect(rounded, bgPaint);
    canvas.drawRRect(rounded, borderPaint);

    for (int i = 1; i <= 2; i++) {
      final x = goalRect.left + goalRect.width * (i / 3);
      canvas.drawLine(
        Offset(x, goalRect.top),
        Offset(x, goalRect.bottom),
        netPaint,
      );

      final y = goalRect.top + goalRect.height * (i / 3);
      canvas.drawLine(
        Offset(goalRect.left, y),
        Offset(goalRect.right, y),
        netPaint,
      );
    }

    final maxValue = zonas.values.fold<int>(
      0,
      (max, data) => data.total > max ? data.total : max,
    );

    if (maxValue <= 0) {
      _drawEmptyText(canvas, size);
      return;
    }

    for (final zone in _orderedZones) {
      final data = zonas[zone] ?? const _GoalZoneHeatData();
      final center = _zoneCenter(zone, size);
      final zoneRect = _zoneRect(zone, size);

      _drawZoneHeat(
        canvas: canvas,
        zoneRect: zoneRect,
        atajadas: data.atajadas,
        goles: data.goles,
        maxValue: maxValue,
      );
    }
  }

  void _drawZoneHeat({
    required Canvas canvas,
    required Rect zoneRect,
    required int atajadas,
    required int goles,
    required int maxValue,
  }) {
    final total = atajadas + goles;
    final safeMaxValue = maxValue <= 0 ? 1 : maxValue;

    final ratio = total == 0 ? 0.0 : (total / safeMaxValue).clamp(0.20, 1.0);

    // 1) Nebulosa base gris para conectar todo el 3x3
    final neutralRadius = zoneRect.width * 0.86;

    final neutralPaint = Paint()
      ..shader = ui.Gradient.radial(
        zoneRect.center,
        neutralRadius,
        [
          Colors.white.withOpacity(total == 0 ? 0.030 : 0.022),
          Colors.white.withOpacity(total == 0 ? 0.016 : 0.010),
          Colors.white.withOpacity(0.0),
        ],
        const [0.0, 0.55, 1.0],
      )
      ..blendMode = BlendMode.srcOver
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

    canvas.drawCircle(zoneRect.center, neutralRadius, neutralPaint);

    if (total == 0) return;

    final dominantIsGoal = goles >= atajadas;

    final dominantColor = dominantIsGoal
        ? const Color(0xFFEF4444)
        : const Color(0xFF22C55E);

    final secondaryColor = dominantIsGoal
        ? const Color(0xFF22C55E)
        : const Color(0xFFEF4444);

    final dominantValue = dominantIsGoal ? goles : atajadas;
    final secondaryValue = dominantIsGoal ? atajadas : goles;

    final dominantShare = dominantValue / total;
    final secondaryShare = secondaryValue / total;

    // 2) Capa amplia de color dominante
    final dominantRadius = zoneRect.width * (0.76 + ratio * 0.32);

    final dominantPaint = Paint()
      ..shader = ui.Gradient.radial(
        zoneRect.center,
        dominantRadius,
        [
          dominantColor.withOpacity(0.34 + ratio * 0.10),
          dominantColor.withOpacity(0.20 + ratio * 0.07),
          dominantColor.withOpacity(0.085),
          dominantColor.withOpacity(0.0),
        ],
        const [0.0, 0.40, 0.74, 1.0],
      )
      ..blendMode = BlendMode.srcOver
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    canvas.drawCircle(zoneRect.center, dominantRadius, dominantPaint);

    // 3) Núcleo fuerte para que la zona importante se vea
    final coreRadius = zoneRect.width * (0.34 + ratio * 0.16);

    final corePaint = Paint()
      ..shader = ui.Gradient.radial(
        zoneRect.center,
        coreRadius,
        [
          dominantColor.withOpacity(0.36 + dominantShare * 0.10),
          dominantColor.withOpacity(0.18),
          dominantColor.withOpacity(0.0),
        ],
        const [0.0, 0.50, 1.0],
      )
      ..blendMode = BlendMode.srcOver
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

    canvas.drawCircle(zoneRect.center, coreRadius, corePaint);

    // 4) Color secundario si hubo mezcla
    if (secondaryValue > 0) {
      final secondaryCenter = Offset(
        zoneRect.center.dx + zoneRect.width * 0.16,
        zoneRect.center.dy + zoneRect.height * 0.08,
      );

      final secondaryRadius = zoneRect.width * (0.50 + ratio * 0.20);

      final secondaryPaint = Paint()
        ..shader = ui.Gradient.radial(
          secondaryCenter,
          secondaryRadius,
          [
            secondaryColor.withOpacity(0.16 + secondaryShare * 0.12),
            secondaryColor.withOpacity(0.08),
            secondaryColor.withOpacity(0.0),
          ],
          const [0.0, 0.55, 1.0],
        )
        ..blendMode = BlendMode.srcOver
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

      canvas.drawCircle(secondaryCenter, secondaryRadius, secondaryPaint);
    }
  }

  void _drawZoneValue({
    required Canvas canvas,
    required Offset center,
    required String text,
  }) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: Colors.white.withOpacity(0.75),
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final bgRect = Rect.fromCenter(
      center: center,
      width: textPainter.width + 10,
      height: textPainter.height + 6,
    );

    final paint = Paint()..color = Colors.black.withOpacity(0.35);

    final rRect = RRect.fromRectAndRadius(bgRect, const Radius.circular(6));

    canvas.drawRRect(rRect, paint);

    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy - textPainter.height / 2,
      ),
    );
  }

  void _drawEmptyText(Canvas canvas, Size size) {
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'Sin tiros registrados',
        style: TextStyle(
          color: Color(0xFFAAB4C3),
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      Offset(
        size.width / 2 - textPainter.width / 2,
        size.height / 2 - textPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant _GoalkeeperBlurHeatmapPainter oldDelegate) {
    return oldDelegate.zonas != zonas;
  }
}

/// ===============================
/// ===============================
/// FIXTURE
/// ===============================
///

class FixtureScreen extends StatefulWidget {
  final String temporada;
  final String competencia;
  final String torneo;
  final String categoria;
  final String institutionName;
  final String? institutionId;
  final String? institutionShieldPath;

  const FixtureScreen({
    super.key,
    required this.temporada,
    required this.competencia,
    required this.torneo,
    required this.categoria,
    required this.institutionName,
    this.institutionId,
    this.institutionShieldPath,
  });

  @override
  State<FixtureScreen> createState() => _FixtureScreenState();
}

class _FixtureScreenState extends State<FixtureScreen> {
  static const String _liveMatchStorageKey = 'live_match_current_v1';
  static const String _finishedMatchesStorageKey =
      'finished_matches_history_v1';
  late Future<List<PartidoModel>> _fixturesFuture;

  /// ===============================
  /// PARTIDOS FINALIZADOS V2

  /// Cache local usando el nuevo repository
  /// ===============================
  List<PartidoModel> _finalizadosV2 = [];

  final FixtureRepositoryV2 _fixtureRepository = const FixtureRepositoryV2();

  List<PartidoModel> _customFixturesV2 = [];

  String get _institutionName {
    final value = widget.institutionName.trim();

    if (value.isEmpty || value.toLowerCase() == 'null') {
      return 'Institución';
    }

    return value;
  }

  String? get _institutionShieldPath {
    final direct = (widget.institutionShieldPath ?? '').trim();

    if (direct.isNotEmpty && direct.toLowerCase() != 'null') {
      return direct;
    }

    final normalized = _institutionName.trim().toLowerCase();

    if (normalized == 'san fernando handball' || normalized == 'san fernando') {
      return 'assets/images/san_fernando.png';
    }

    return null;
  }

  ActiveContext get _activeContext {
    return ActiveContext(
      hasInstitution: true,
      institutionName: '',
      season: widget.temporada,
      competition: widget.competencia,
      tournament: widget.torneo,
      category: widget.categoria,
    );
  }

  @override
  void initState() {
    super.initState();

    _fixturesFuture = _fixtureRepository.readFixtures();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadFinalizadosV2();
      await _loadCustomFixturesV2();
    });
  }

  List<Map<String, dynamic>> _obtenerFixtureDesdeCustomDirecto(
    List<PartidoModel> fixtures,
  ) {
    final torneoActual = _normalizeContextText(widget.torneo);
    final categoriaActual = _normalizeContextText(widget.categoria);
    final temporadaActual = _normalizeContextText(widget.temporada);
    final competenciaActual = _normalizeContextText(widget.competencia);

    final result = fixtures
        .where((partido) {
          final sameSeason =
              _normalizeContextText(partido.temporada) == temporadaActual;

          final sameCompetition =
              _normalizeContextText(partido.competencia) == competenciaActual;

          final sameCategory =
              _normalizeContextText(partido.categoria) == categoriaActual;

          if (!sameSeason || !sameCompetition || !sameCategory) {
            return false;
          }

          final torneo = _normalizeContextText(partido.torneo);

          return torneo == torneoActual ||
              _sameLooseStage(torneo, torneoActual);
        })
        .map((p) {
          return p.toMap();
        })
        .toList();

    result.sort((a, b) {
      final fa = (a['fechaNumero'] as int?) ?? 999999;
      final fb = (b['fechaNumero'] as int?) ?? 999999;

      final byFecha = fa.compareTo(fb);
      if (byFecha != 0) return byFecha;

      return (a['rival'] ?? '').toString().toLowerCase().compareTo(
        (b['rival'] ?? '').toString().toLowerCase(),
      );
    });

    return result;
  }

  String get _contextStorageSuffix {
    return AppContextKey.fromActiveContext(_activeContext);
  }

  /// ===============================
  /// LOAD FINALIZADOS V2
  /// Lee partidos finalizados desde repository 2.0
  /// ===============================
  Future<void> _loadFinalizadosV2() async {
    final data = await PartidoRepositoryV2.readFinishedMatches();

    if (!mounted) return;

    setState(() {
      _finalizadosV2 = data;
    });
  }

  String _normalizeContextText(dynamic value) {
    return (value ?? '')
        .toString()
        .trim()
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ü', 'u')
        .replaceAll('ñ', 'n')
        .replaceAll(RegExp(r'\s+'), ' ');
  }

  bool _sameLooseStage(String a, String b) {
    final left = _normalizeContextText(a);
    final right = _normalizeContextText(b);

    if (left == right) return true;

    const aliases = {
      'partido suelto',
      'partidos sueltos',
      'amistoso',
      'amistosos',
    };

    return aliases.contains(left) && aliases.contains(right);
  }

  bool _customFixtureMatchesCurrentContext(PartidoModel partido) {
    final sameBase =
        _normalizeContextText(partido.temporada) ==
            _normalizeContextText(widget.temporada) &&
        _normalizeContextText(partido.competencia) ==
            _normalizeContextText(widget.competencia) &&
        _normalizeContextText(partido.categoria) ==
            _normalizeContextText(widget.categoria);

    if (!sameBase) return false;

    final torneo = _normalizeContextText(partido.torneo);
    final currentTorneo = _normalizeContextText(widget.torneo);

    return torneo == currentTorneo || _sameLooseStage(torneo, currentTorneo);
  }

  Future<void> _loadCustomFixturesV2() async {
    final allFixtures = await _fixtureRepository.readFixtures();

    final filtered = allFixtures.where((partido) {
      final sameSeason =
          _normalizeContextText(partido.temporada) ==
          _normalizeContextText(widget.temporada);

      final sameCompetition =
          _normalizeContextText(partido.competencia) ==
          _normalizeContextText(widget.competencia);

      final sameCategory =
          _normalizeContextText(partido.categoria) ==
          _normalizeContextText(widget.categoria);

      if (!sameSeason || !sameCompetition || !sameCategory) {
        return false;
      }

      final partidoTorneo = _normalizeContextText(partido.torneo);
      final widgetTorneo = _normalizeContextText(widget.torneo);

      if (partidoTorneo == widgetTorneo) return true;

      return _sameLooseStage(partidoTorneo, widgetTorneo);
    }).toList();

    filtered.sort((a, b) {
      final byFecha = (a.fechaNumero ?? 999999).compareTo(
        b.fechaNumero ?? 999999,
      );

      if (byFecha != 0) return byFecha;

      return a.rival.toLowerCase().compareTo(b.rival.toLowerCase());
    });

    if (!mounted) return;

    setState(() {
      _customFixturesV2 = filtered;
    });
  }

  String _stableFixtureIdentity(Map<String, dynamic> partido) {
    return FixtureRepositoryV2.buildStableFixtureIdentityFromMap({
      ...partido,
      'temporada': partido['temporada'] ?? widget.temporada,
      'competencia': partido['competencia'] ?? widget.competencia,
      'torneo': partido['torneo'] ?? widget.torneo,
      'categoria': partido['categoria'] ?? widget.categoria,
    });
  }

  List<Map<String, dynamic>> _mergeBaseWithCustomFixtures(
    List<Map<String, dynamic>> base,
  ) {
    final byStableId = <String, Map<String, dynamic>>{};

    for (final item in base) {
      final map = Map<String, dynamic>.from(item);
      byStableId[_stableFixtureIdentity(map)] = map;
    }

    for (final custom in _customFixturesV2) {
      final map = custom.toMap();
      byStableId[_stableFixtureIdentity(map)] = map;
    }

    final result = byStableId.values.toList();

    result.sort((a, b) {
      final fa = (a['fechaNumero'] as int?) ?? 999999;
      final fb = (b['fechaNumero'] as int?) ?? 999999;

      final byFecha = fa.compareTo(fb);
      if (byFecha != 0) return byFecha;

      return (a['rival'] ?? '').toString().toLowerCase().compareTo(
        (b['rival'] ?? '').toString().toLowerCase(),
      );
    });

    return result;
  }

  List<Map<String, dynamic>> _buildFixtureCompleto({
    required String categoria,
  }) {
    final base = <Map<String, dynamic>>[];

    if (_normalizeContextText(widget.competencia) == 'local') {
      final apertura = _buildAperturaBase(
        categoria: categoria,
      ).map(_convertirAFixturePartido).toList();

      final clausura = _buildClausuraBase(
        categoria: categoria,
      ).map(_convertirAFixturePartido).toList();

      base.addAll(apertura);
      base.addAll(clausura);
    }

    return _mergeBaseWithCustomFixtures(base);
  }

  List<DateTime> _generarSabadosDesde({
    required DateTime inicio,
    required int cantidad,
  }) {
    return List.generate(cantidad, (i) => inicio.add(Duration(days: i * 7)));
  }

  String _formatFecha(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    return '$dd/$mm';
  }

  List<Map<String, dynamic>> _buildAperturaBase({required String categoria}) {
    return [
      {
        'fechaNumero': 1,
        'fecha': '21/03',
        'hora': '13:00',
        'local': 'Municipalidad de Vicente Lopez',
        'visitante': 'San Fernando Handball',
        'torneo': 'Apertura',
        'categoria': categoria,
      },
      {
        'fechaNumero': 2,
        'fecha': '28/03',
        'hora': '13:00',
        'local': 'San Fernando Handball',
        'visitante': 'Colegio Ward',
        'torneo': 'Apertura',
        'categoria': categoria,
      },
      {
        'fechaNumero': 3,
        'fecha': '11/04',
        'hora': '13:00',
        'local': 'S.A.G. Villa Ballester',
        'visitante': 'San Fernando Handball',
        'torneo': 'Apertura',
        'categoria': categoria,
      },
      {
        'fechaNumero': 4,
        'fecha': '18/04',
        'hora': '13:00',
        'local': 'San Fernando Handball',
        'visitante': 'Argentinos Juniors',
        'torneo': 'Apertura',
        'categoria': categoria,
      },
      {
        'fechaNumero': 5,
        'fecha': '25/04',
        'hora': '13:00',
        'local': 'Ferro Carril Oeste',
        'visitante': 'San Fernando Handball',
        'torneo': 'Apertura',
        'categoria': categoria,
      },
      {
        'fechaNumero': 6,
        'fecha': '02/05',
        'hora': '13:00',
        'local': 'San Fernando Handball',
        'visitante': 'C.A. Velez Sarsfield',
        'torneo': 'Apertura',
        'categoria': categoria,
      },
      {
        'fechaNumero': 7,
        'fecha': '09/05',
        'hora': '13:00',
        'local': 'Campana Boat Club',
        'visitante': 'San Fernando Handball',
        'torneo': 'Apertura',
        'categoria': categoria,
      },
      {
        'fechaNumero': 8,
        'fecha': '16/05',
        'hora': '13:00',
        'local': 'S.A.G.A.B.',
        'visitante': 'San Fernando Handball',
        'torneo': 'Apertura',
        'categoria': categoria,
      },
      {
        'fechaNumero': 9,
        'fecha': '23/05',
        'hora': '13:00',
        'local': 'San Fernando Handball',
        'visitante': 'C.A. River Plate',
        'torneo': 'Apertura',
        'categoria': categoria,
      },
      {
        'fechaNumero': 10,
        'fecha': '30/05',
        'hora': '13:00',
        'local': 'Dorrego Handball',
        'visitante': 'San Fernando Handball',
        'torneo': 'Apertura',
        'categoria': categoria,
      },
      {
        'fechaNumero': 11,
        'fecha': '06/06',
        'hora': '13:00',
        'local': 'San Fernando Handball',
        'visitante': 'Estudiantes de La Plata',
        'torneo': 'Apertura',
        'categoria': categoria,
      },
      {
        'fechaNumero': 12,
        'fecha': '20/06',
        'hora': '13:00',
        'local': 'S.E.D.A.L.O.',
        'visitante': 'San Fernando Handball',
        'torneo': 'Apertura',
        'categoria': categoria,
      },
      {
        'fechaNumero': 13,
        'fecha': '27/06',
        'hora': '13:00',
        'local': 'San Fernando Handball',
        'visitante': 'C.A. Lanus',
        'torneo': 'Apertura',
        'categoria': categoria,
      },
      {
        'fechaNumero': 14,
        'fecha': '04/07',
        'hora': '13:00',
        'local': 'Nuestra Senora de Luján',
        'visitante': 'San Fernando Handball',
        'torneo': 'Apertura',
        'categoria': categoria,
      },
      {
        'fechaNumero': 15,
        'fecha': '11/07',
        'hora': '13:00',
        'local': 'San Fernando Handball',
        'visitante': 'A.A.C.F. Quilmes',
        'torneo': 'Apertura',
        'categoria': categoria,
      },
    ];
  }

  List<Map<String, dynamic>> _buildClausuraBase({required String categoria}) {
    final apertura = _buildAperturaBase(categoria: categoria);
    final sabados = _generarSabadosDesde(
      inicio: DateTime(2026, 8, 8),
      cantidad: apertura.length,
    );

    return List.generate(apertura.length, (i) {
      final p = Map<String, dynamic>.from(apertura[i]);

      final tmpLocal = p['local'];
      p['local'] = p['visitante'];
      p['visitante'] = tmpLocal;

      p['torneo'] = 'Clausura';
      p['fecha'] = _formatFecha(sabados[i]);
      return p;
    });
  }

  String _normalizeValue(dynamic value) {
    return normalizeHandballText(value);
  }

  String _matchIdentityForPartido(Map<String, dynamic> partido) {
    return [
      _normalizeValue(partido['torneo']),
      _normalizeValue(partido['categoria']),
      _normalizeValue(partido['fecha']),
      _normalizeValue(partido['rival']),
      _normalizeValue(partido['condicion']),
    ].join('|');
  }

  Map<String, dynamic> _mergePersistedStateIntoPartido(
    Map<String, dynamic> base,
    Map<String, dynamic> data,
  ) {
    return {
      ...base,
      'estado': (data['estadoPartido'] ?? '') == 'finalizado'
          ? 'Finalizado'
          : (base['estado'] ?? 'Pendiente'),
      'estadoPartido': data['estadoPartido'] ?? base['estadoPartido'],
      'golesSanFernando': data['golesSanFernando'] ?? base['golesSanFernando'],
      'golesRival': data['golesRival'] ?? base['golesRival'],
      'golesRecibidos': data['golesRecibidos'] ?? base['golesRecibidos'],
      'atajadas': data['atajadas'] ?? base['atajadas'],
      'penales': data['penales'] ?? base['penales'],
      'exclusiones2Min': data['exclusiones2Min'] ?? base['exclusiones2Min'],
      'amarillas': data['amarillas'] ?? base['amarillas'],
      'rojas': data['rojas'] ?? base['rojas'],
      'perdidas': data['perdidas'] ?? base['perdidas'],
      'recuperaciones': data['recuperaciones'] ?? base['recuperaciones'],
      'penalesConvertidosSanFernando':
          data['penalesConvertidosSanFernando'] ??
          base['penalesConvertidosSanFernando'],
      'penalesConvertidosRival':
          data['penalesConvertidosRival'] ?? base['penalesConvertidosRival'],
      'modoActual': data['modo'] ?? base['modoActual'],
      'modoInicioPrimerTiempo':
          data['modoInicioPrimerTiempo'] ?? base['modoInicioPrimerTiempo'],
      'modoInicioPrimerTiempoAlargue':
          data['modoInicioPrimerTiempoAlargue'] ??
          base['modoInicioPrimerTiempoAlargue'],
      'currentGoalkeeperNumber':
          data['currentGoalkeeperNumber'] ?? base['currentGoalkeeperNumber'],
      'eventos': data['eventos'] ?? base['eventos'],
    };
  }

  Future<Map<String, dynamic>> _resolverPartidoConEstadoReal(
    Map<String, dynamic> partidoBase,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final identity = _matchIdentityForPartido(partidoBase);

    final rawLive = prefs.getString(_liveMatchStorageKey);

    if (rawLive != null && rawLive.isNotEmpty) {
      try {
        final data = Map<String, dynamic>.from(jsonDecode(rawLive) as Map);
        final liveIdentity = (data['matchIdentity'] ?? '').toString();
        final liveEstado = (data['estadoPartido'] ?? '').toString();

        if (liveIdentity == identity) {
          if (liveEstado == 'finalizado') {
            await prefs.remove(_liveMatchStorageKey);
            return partidoBase;
          }

          return _mergePersistedStateIntoPartido(partidoBase, data);
        }
      } catch (_) {
        await prefs.remove(_liveMatchStorageKey);
      }
    }

    final rawFinished = prefs.getString(_finishedMatchesStorageKey);

    if (rawFinished != null && rawFinished.isNotEmpty) {
      final decoded = jsonDecode(rawFinished) as List<dynamic>;

      for (final item in decoded) {
        if (item is! Map) continue;

        final data = Map<String, dynamic>.from(item);

        if ((data['matchIdentity'] ?? '') == identity) {
          return _mergePersistedStateIntoPartido(partidoBase, data);
        }
      }
    }

    return partidoBase;
  }

  String? _rivalShieldAssetByName(String rival) {
    return rivalShieldAssetGlobal(rival);
  }

  Map<String, dynamic> _convertirAFixturePartido(Map<String, dynamic> raw) {
    final bool somosLocales =
        (raw['local'] ?? '').toString() == 'San Fernando Handball';

    final rival = somosLocales
        ? (raw['visitante'] ?? 'Rival').toString()
        : (raw['local'] ?? 'Rival').toString();

    return {
      'rival': rival,
      'fechaNumero': raw['fechaNumero'],
      'fecha': raw['fecha'],
      'hora': raw['hora'],
      'condicion': somosLocales ? 'Local' : 'Visitante',
      'torneo': raw['torneo'],
      'categoria': raw['categoria'],
      'estado': 'Pendiente',
      'estadoPartido': 'no_iniciado',
      'golesSanFernando': 0,
      'golesRival': 0,
      'golesRecibidos': 0,
      'atajadas': 0,
      'penales': 0,
      'exclusiones2Min': 0,
      'amarillas': 0,
      'rojas': 0,
      'perdidas': 0,
      'recuperaciones': 0,
      'penalesConvertidosSanFernando': 0,
      'penalesConvertidosRival': 0,
      'eventos': <Map<String, dynamic>>[],
      'modoActual': null,
      'modoInicioPrimerTiempo': null,
      'modoInicioPrimerTiempoAlargue': null,
      'currentGoalkeeperNumber': null,
      'escudoRival': _rivalShieldAssetByName(rival),
    };
  }

  Widget _buildEmptyFixtureState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1722).withOpacity(0.88),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.calendar_month_outlined,
            color: Color(0xFF8FA3BF),
            size: 34,
          ),
          const SizedBox(height: 12),
          const Text(
            'No hay fixture cargado para este contexto',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${widget.temporada} · ${widget.competencia} · ${widget.torneo} · ${widget.categoria}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFFAAB4C3),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _obtenerFixturePorCategoriaYTorneo() {
    final torneoActual = _normalizeContextText(widget.torneo);
    final categoriaActual = _normalizeContextText(widget.categoria);

    final partidos = _buildFixtureCompleto(categoria: widget.categoria).where((
      partido,
    ) {
      final torneo = _normalizeContextText(partido['torneo']);
      final categoria = _normalizeContextText(partido['categoria']);

      final sameCategory = categoria == categoriaActual;
      final sameTournament =
          torneo == torneoActual || _sameLooseStage(torneo, torneoActual);

      return sameCategory && sameTournament;
    }).toList();

    partidos.sort((a, b) {
      final fa = (a['fechaNumero'] as int?) ?? 999999;
      final fb = (b['fechaNumero'] as int?) ?? 999999;

      final byFecha = fa.compareTo(fb);
      if (byFecha != 0) return byFecha;

      return (a['rival'] ?? '').toString().toLowerCase().compareTo(
        (b['rival'] ?? '').toString().toLowerCase(),
      );
    });

    return partidos;
  }

  Future<void> _abrirPartido(
    BuildContext context,
    Map<String, dynamic> partido,
  ) async {
    final partidoReal = await _resolverPartidoConEstadoReal(
      Map<String, dynamic>.from(partido),
    );

    partidoReal['institutionId'] = widget.institutionId;
    partidoReal['equipoPropio'] = _institutionName;
    partidoReal['escudoPropio'] = _institutionShieldPath;

    if (!context.mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PartidoEnJuegoScreen(partido: partidoReal),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<PartidoModel>>(
      future: _fixturesFuture,
      builder: (context, snapshot) {
        final partidos = _obtenerFixturePorCategoriaYTorneo();

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text('Fixture'),
          ),
          body: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  'assets/images/fondohd.jpeg',
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                ),
              ),
              Positioned.fill(
                child: Container(
                  color: const Color(0xFF05080D).withOpacity(0.88),
                ),
              ),
              SafeArea(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                  children: [
                    Text(
                      '${widget.categoria} · ${widget.torneo}',
                      style: const TextStyle(
                        color: Color(0xFFD4DCE7),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 18),
                    if (snapshot.connectionState == ConnectionState.waiting)
                      const Center(child: CircularProgressIndicator())
                    else if (partidos.isEmpty)
                      _buildEmptyFixtureState()
                    else
                      ...partidos.map((p) => _buildFixtureCard(context, p)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFixtureCard(BuildContext context, Map<String, dynamic> partido) {
    final identidad = PartidoRepositoryV2.buildMatchIdentityFromMap(partido);

    final PartidoModel? finalizadoV2 = _finalizadosV2
        .cast<PartidoModel?>()
        .firstWhere(
          (p) =>
              p != null &&
              PartidoRepositoryV2.buildMatchIdentityFromModel(p) == identidad,
          orElse: () => null,
        );

    final bool estaFinalizadoV2 = finalizadoV2 != null;

    final Map<String, dynamic> partidoVisual = estaFinalizadoV2
        ? {
            ...partido,
            ...finalizadoV2.toMap(),
            'fechaNumero': partido['fechaNumero'],
            'rival': partido['rival'],
            'condicion': partido['condicion'],
            'escudoRival': partido['escudoRival'],
          }
        : partido;

    final String rival = fixTextoRoto(partidoVisual['rival'] ?? 'Rival');
    final String? escudoRival =
        (partidoVisual['escudoRival'] as String?) ??
        _rivalShieldAssetByName(rival);

    final match = MatchModel.fromMap(
      {...partidoVisual, 'rival': rival, 'escudoRival': escudoRival},
      finalizadoOverride: estaFinalizadoV2,
      escudoRivalOverride: escudoRival,
    );

    Future<void> abrir() async {
      if (estaFinalizadoV2 && finalizadoV2 != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ResumenPartidoFinalizadoScreen(
              partido: {
                ...partido,
                ...finalizadoV2.toMap(),
                'fechaNumero': partido['fechaNumero'],
                'rival': partido['rival'],
                'condicion': partido['condicion'],
                'escudoRival': partido['escudoRival'],
              },
            ),
          ),
        );
      } else {
        await _abrirPartido(context, partido);
      }
    }

    return MatchCardPro(
      match: match,
      actionText: estaFinalizadoV2 ? 'Ver resumen' : 'Abrir partido',
      onPressed: abrir,
      showFechaChip: true,
      showEstadoChip: true,
    );
  }

  /// CHIP DE ESTADO (CON COLOR DINÁMICO)
  /// ===============================
  Widget _buildStatusChip(String label, {Color? color}) {
    final baseColor = color ?? const Color(0xFF4F8CFF);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: baseColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: baseColor,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 82,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFFAAB4C3),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOpenButton({required String text, required VoidCallback onTap}) {
    final bool esResumen = text == 'Ver resumen';

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: esResumen
              ? const Color(0xFF2EA86B) // verde
              : const Color(0xFF4F8CFF), // azul
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

/// ===============================
/// ===============================
/// CENTRO DE CONTROL
/// ===============================
/// ===============================

class PartidoEnJuegoScreen extends StatefulWidget {
  final Map<String, dynamic> partido;

  const PartidoEnJuegoScreen({super.key, required this.partido});

  @override
  State<PartidoEnJuegoScreen> createState() => _PartidoEnJuegoScreenState();
}

class _PartidoEnJuegoScreenState extends State<PartidoEnJuegoScreen> {
  /// ===============================
  /// MODELO 2.0
  /// ===============================
  PartidoModel get partidoV2 => PartidoModel.fromMap(widget.partido);

  /// ===============================
  /// ESTADÍSTICAS DESDE MODELO 2.0
  /// ===============================
  double get _eficaciaArqueroV2 => partidoV2.eficaciaArquero;
  int get _atajadasV2 => partidoV2.atajadas;
  int get _golesRecibidosV2 => partidoV2.golesRecibidos;
  int get _perdidasV2 => partidoV2.perdidas;
  int get _recuperacionesV2 => partidoV2.recuperaciones;
  int get _penalesV2 => partidoV2.penales;
  int get _exclusiones2MinV2 => partidoV2.exclusiones2Min;
  int get _amarillasV2 => partidoV2.amarillas;
  int get _rojasV2 => partidoV2.rojas;
  int get _cantidadEventosV2 => partidoV2.eventos.length;

  String estadoPartido = 'no_iniciado';

  int golesSanFernando = 0;
  int golesRival = 0;
  int golesRecibidos = 0;

  int atajadas = 0;
  int penales = 0;
  int exclusiones2Min = 0;
  int amarillas = 0;
  int rojas = 0;
  int perdidas = 0;
  int recuperaciones = 0;

  int penalesConvertidosSanFernando = 0;
  int penalesConvertidosRival = 0;

  List<Map<String, dynamic>> eventos = [];

  String? modoActual;
  String? modoInicioPrimerTiempo;
  String? modoInicioPrimerTiempoAlargue;

  /// ===============================
  /// ESTADO SIMPLE DE PARTIDO
  /// Estos getters siguen manejando la UI actual,
  /// pero algunos datos ya se leen desde PartidoModel.
  /// ===============================

  bool get _partidoFinalizado => estadoPartido == 'finalizado';

  bool get _somosLocales => partidoV2.condicion.trim().toLowerCase() == 'local';

  String get _equipoPropioNombre {
    final raw = (widget.partido['equipoPropio'] ?? '').toString().trim();

    if (raw.isNotEmpty && raw.toLowerCase() != 'null') {
      return fixTextoRoto(raw);
    }

    return 'Institución';
  }

  String? get _equipoPropioEscudo {
    final raw = (widget.partido['escudoPropio'] ?? '').toString().trim();

    if (raw.isNotEmpty && raw.toLowerCase() != 'null') {
      return raw;
    }

    final normalized = _equipoPropioNombre.trim().toLowerCase();

    if (normalized == 'san fernando handball' || normalized == 'san fernando') {
      return 'assets/images/san_fernando.png';
    }

    return null;
  }

  String? get _rivalEscudoResuelto {
    final directo = (partidoV2.escudoRival ?? '').trim();

    if (directo.isNotEmpty && directo.toLowerCase() != 'null') {
      return directo;
    }

    final fallback = rivalShieldAssetGlobal(partidoV2.rival);

    if (fallback != null && fallback.trim().isNotEmpty) {
      return fallback;
    }

    return null;
  }

  String get _nombreLocal {
    return _somosLocales ? _equipoPropioNombre : partidoV2.rival;
  }

  String get _nombreVisitante {
    return _somosLocales ? partidoV2.rival : _equipoPropioNombre;
  }

  int get _golesLocal => _somosLocales ? golesSanFernando : golesRival;

  int get _golesVisitante => _somosLocales ? golesRival : golesSanFernando;

  String? get _escudoLocalPath {
    return _somosLocales ? _equipoPropioEscudo : _rivalEscudoResuelto;
  }

  String? get _escudoVisitantePath {
    return _somosLocales ? _rivalEscudoResuelto : _equipoPropioEscudo;
  }

  Future<void> _asegurarConvocatoriaDefaultSoloArqueros() async {
    final squadMap = widget.partido['matchSquad'] as Map<String, dynamic>?;

    if (squadMap != null) return;

    final categoria = (widget.partido['categoria'] ?? 'Cadetes').toString();

    await RosterStorage.seedCategoryIfEmpty(
      categoria: categoria,
      temporada: '2026',
    );

    final roster = await RosterStorage.readRosterForCategory(
      categoria: categoria,
      temporada: '2026',
      includeStaff: false,
    );

    final arqueros = roster.where((p) => p.esArquero).toList();

    widget.partido['matchSquad'] = MatchSquadConfig(
      convocadosIds: arqueros.map((p) => p.playerId).toSet(),
      arquerosIds: arqueros.map((p) => p.playerId).toSet(),
    ).toMap();
  }

  Future<void> _irAPartidoEnVivo() async {
    await _asegurarConvocatoriaDefaultSoloArqueros();
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PartidoEnVivoScreen(
          partido: widget.partido,
          estadoInicial: estadoPartido,
          golesSanFernandoInicial: golesSanFernando,
          golesRivalInicial: golesRival,
          atajadasInicial: atajadas,
          penalesInicial: penales,
          exclusiones2MinInicial: exclusiones2Min,
          amarillasInicial: amarillas,
          rojasInicial: rojas,
          perdidasInicial: perdidas,
          recuperacionesInicial: recuperaciones,
          penalesConvertidosSanFernandoInicial: penalesConvertidosSanFernando,
          penalesConvertidosRivalInicial: penalesConvertidosRival,
          eventosIniciales: eventos,
          modoInicial: modoActual,
          modoInicioPrimerTiempo: modoInicioPrimerTiempo,
          modoInicioPrimerTiempoAlargue: modoInicioPrimerTiempoAlargue,
        ),
      ),
    );

    if (resultado != null && mounted) {
      setState(() {
        estadoPartido = (resultado['estadoPartido'] ?? estadoPartido) as String;
        golesSanFernando =
            (resultado['golesSanFernando'] ?? golesSanFernando) as int;
        golesRival = (resultado['golesRival'] ?? golesRival) as int;
        golesRecibidos = (resultado['golesRecibidos'] ?? golesRecibidos) as int;

        atajadas = (resultado['atajadas'] ?? atajadas) as int;
        penales = (resultado['penales'] ?? penales) as int;
        exclusiones2Min =
            (resultado['exclusiones2Min'] ?? exclusiones2Min) as int;
        amarillas = (resultado['amarillas'] ?? amarillas) as int;
        rojas = (resultado['rojas'] ?? rojas) as int;
        perdidas = (resultado['perdidas'] ?? perdidas) as int;
        recuperaciones = (resultado['recuperaciones'] ?? recuperaciones) as int;

        penalesConvertidosSanFernando =
            (resultado['penalesConvertidosSanFernando'] ??
                    penalesConvertidosSanFernando)
                as int;
        penalesConvertidosRival =
            (resultado['penalesConvertidosRival'] ?? penalesConvertidosRival)
                as int;

        modoActual = resultado['modoActual'] as String?;
        modoInicioPrimerTiempo = resultado['modoInicioPrimerTiempo'] as String?;
        modoInicioPrimerTiempoAlargue =
            resultado['modoInicioPrimerTiempoAlargue'] as String?;

        final dynamic eventosResult = resultado['eventos'];
        if (eventosResult is List) {
          eventos = eventosResult
              .map((e) => Map<String, dynamic>.from(e as Map))
              .toList();
        }

        _syncStateToPartido();
      });
    }
  }

  Future<void> _abrirPlantel() async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MatchSquadScreen(partido: widget.partido),
      ),
    );

    if (resultado != null && mounted) {
      setState(() {
        widget.partido['matchSquad'] = resultado;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Plantel del partido actualizado')),
      );
    }
  }

  /// ===============================
  /// ABRIR RESUMEN
  /// Construye primero el partido con la base 2.0 (PartidoModel)
  /// y luego lo convierte a Map para no romper la pantalla actual.
  /// ===============================
  void _abrirResumen() {
    if (!_partidoFinalizado) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'El resumen completo se habilita al finalizar el partido',
          ),
        ),
      );
      return;
    }

    final PartidoModel partidoResumenV2 = partidoV2.copyWith(
      estado: 'Finalizado',
      estadoPartido: 'finalizado',
      golesSanFernando: golesSanFernando,
      golesRival: golesRival,
      golesRecibidos: golesRecibidos,
      atajadas: atajadas,
      penales: penales,
      exclusiones2Min: exclusiones2Min,
      amarillas: amarillas,
      rojas: rojas,
      perdidas: perdidas,
      recuperaciones: recuperaciones,
      penalesConvertidosSanFernando: penalesConvertidosSanFernando,
      penalesConvertidosRival: penalesConvertidosRival,
      eventos: eventos.map((e) => EventoModel.fromMap(e)).toList(),
    );

    final Map<String, dynamic> partidoResumen = partidoResumenV2.toMap();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ResumenPartidoFinalizadoScreen(partido: partidoResumen),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    estadoPartido =
        (widget.partido['estadoPartido'] ?? 'no_iniciado') as String;
    golesSanFernando = (widget.partido['golesSanFernando'] ?? 0) as int;
    golesRival = (widget.partido['golesRival'] ?? 0) as int;
    golesRecibidos = (widget.partido['golesRecibidos'] ?? 0) as int;

    atajadas = (widget.partido['atajadas'] ?? 0) as int;
    penales = (widget.partido['penales'] ?? 0) as int;
    exclusiones2Min = (widget.partido['exclusiones2Min'] ?? 0) as int;
    amarillas = (widget.partido['amarillas'] ?? 0) as int;
    rojas = (widget.partido['rojas'] ?? 0) as int;
    perdidas = (widget.partido['perdidas'] ?? 0) as int;
    recuperaciones = (widget.partido['recuperaciones'] ?? 0) as int;

    penalesConvertidosSanFernando =
        (widget.partido['penalesConvertidosSanFernando'] ?? 0) as int;
    penalesConvertidosRival =
        (widget.partido['penalesConvertidosRival'] ?? 0) as int;

    modoActual = widget.partido['modoActual'] as String?;
    modoInicioPrimerTiempo =
        widget.partido['modoInicioPrimerTiempo'] as String?;
    modoInicioPrimerTiempoAlargue =
        widget.partido['modoInicioPrimerTiempoAlargue'] as String?;

    final dynamic eventosRaw = widget.partido['eventos'];
    if (eventosRaw is List) {
      eventos = eventosRaw
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    }
  }

  /// ===============================
  /// SYNC STATE TO PARTIDO
  /// Sincroniza el estado actual del centro de control con widget.partido,
  /// pero usando PartidoModel como base intermedia.
  /// ===============================
  void _syncStateToPartido() {
    final PartidoModel partidoActualizado = partidoV2.copyWith(
      estado: estadoPartido == 'finalizado' ? 'Finalizado' : partidoV2.estado,
      estadoPartido: estadoPartido,
      golesSanFernando: golesSanFernando,
      golesRival: golesRival,
      golesRecibidos: golesRecibidos,
      atajadas: atajadas,
      penales: penales,
      exclusiones2Min: exclusiones2Min,
      amarillas: amarillas,
      rojas: rojas,
      perdidas: perdidas,
      recuperaciones: recuperaciones,
      penalesConvertidosSanFernando: penalesConvertidosSanFernando,
      penalesConvertidosRival: penalesConvertidosRival,
      modoActual: modoActual,
      modoInicioPrimerTiempo: modoInicioPrimerTiempo,
      modoInicioPrimerTiempoAlargue: modoInicioPrimerTiempoAlargue,
      eventos: eventos.map((e) => EventoModel.fromMap(e)).toList(),
    );

    final Map<String, dynamic> actualizadoMap = partidoActualizado.toMap();

    final bool esPartidoRealActual = widget.partido['esPartidoReal'] == true;

    final dynamic equipoPropioActual = widget.partido['equipoPropio'];
    final dynamic escudoPropioActual = widget.partido['escudoPropio'];
    final dynamic escudoRivalActual = widget.partido['escudoRival'];
    final dynamic equipoLocalActual = widget.partido['equipoLocal'];
    final dynamic equipoVisitanteActual = widget.partido['equipoVisitante'];
    final dynamic escudoLocalActual = widget.partido['escudoLocal'];
    final dynamic escudoVisitanteActual = widget.partido['escudoVisitante'];

    final dynamic matchSquadActual = widget.partido['matchSquad'];
    final dynamic matchRosterSnapshotActual =
        widget.partido['matchRosterSnapshot'];

    widget.partido
      ..clear()
      ..addAll(actualizadoMap)
      ..['esPartidoReal'] = esPartidoRealActual;

    if (equipoPropioActual != null) {
      widget.partido['equipoPropio'] = equipoPropioActual;
    }

    if (escudoPropioActual != null) {
      widget.partido['escudoPropio'] = escudoPropioActual;
    }

    if (escudoRivalActual != null) {
      widget.partido['escudoRival'] = escudoRivalActual;
    }

    if (equipoLocalActual != null) {
      widget.partido['equipoLocal'] = equipoLocalActual;
    }

    if (equipoVisitanteActual != null) {
      widget.partido['equipoVisitante'] = equipoVisitanteActual;
    }

    if (escudoLocalActual != null) {
      widget.partido['escudoLocal'] = escudoLocalActual;
    }

    if (escudoVisitanteActual != null) {
      widget.partido['escudoVisitante'] = escudoVisitanteActual;
    }

    if (matchSquadActual != null) {
      widget.partido['matchSquad'] = matchSquadActual;
    }

    if (matchRosterSnapshotActual != null) {
      widget.partido['matchRosterSnapshot'] = matchRosterSnapshotActual;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Centro de control'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/fondohd.jpeg',
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
          ),
          Positioned.fill(
            child: Container(color: const Color(0xFF05080D).withOpacity(0.88)),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildControlHeader(),
                  const SizedBox(height: 18),
                  _buildScoreCard(),
                  const SizedBox(height: 18),
                  if (!_partidoFinalizado) ...[
                    _buildPrimaryAction(
                      text: _getTextoBotonCentroControl(),
                      onTap: _irAPartidoEnVivo,
                    ),
                    const SizedBox(height: 14),
                  ],
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Partido real',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Switch(
                        value: widget.partido['esPartidoReal'] == true,
                        onChanged: (value) {
                          setState(() {
                            widget.partido['esPartidoReal'] = value;
                          });
                        },
                        activeColor: const Color(0xFF1E7D4F),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: _debugPrintHistorial,
                    child: const Text('DEBUG historial'),
                  ),

                  /*TextButton(
                    onPressed: _marcarEsteFinalizadoComoReal,
                    child: const Text('Marcar finalizado como real'),
                  ),*/
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _buildMiniAction(
                          text: 'Plantel',
                          icon: Icons.groups_rounded,
                          highlighted: false,
                          onTap: _abrirPlantel,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildMiniAction(
                          text: 'Resumen',
                          icon: Icons.bar_chart_rounded,
                          highlighted: _partidoFinalizado,
                          onTap: _abrirResumen,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  _buildPartialSummaryCard(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ===============================
  /// DEBUG HISTORIAL
  /// Imprime todos los partidos finalizados guardados.
  /// Sirve como backup manual antes de limpiar o tocar datos.
  /// ===============================
  Future<void> _debugPrintHistorial() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('finished_matches_history_v1');

    print('==============================');
    print('HISTORIAL RESUMIDO');
    print('==============================');

    if (raw == null || raw.isEmpty) {
      print('SIN HISTORIAL');
      return;
    }

    final history = jsonDecode(raw) as List<dynamic>;

    for (final item in history) {
      if (item is! Map) continue;

      final map = Map<String, dynamic>.from(item);

      print('matchIdentity: ${map['matchIdentity']}');
      print('estadoPartido externo: ${map['estadoPartido']}');
      print('finalizado: ${map['finalizado']}');
      print('isReal: ${map['isReal']}');
      print('------------------------------');
    }
  }

  /// ===============================
  /// MARCAR FINALIZADO COMO REAL
  /// Busca este partido en el historial finalizado
  /// y le agrega isReal: true sin borrar datos.
  /// ===============================
  Future<void> _marcarEsteFinalizadoComoReal() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('finished_matches_history_v1');

    if (raw == null || raw.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay historial finalizado guardado')),
      );
      return;
    }

    final history = jsonDecode(raw) as List<dynamic>;

    final identity = PartidoRepositoryV2.buildMatchIdentityFromMap(
      widget.partido,
    );

    bool actualizado = false;

    final nuevoHistory = history.map((item) {
      if (item is! Map) return item;

      final map = Map<String, dynamic>.from(item);

      if ((map['matchIdentity'] ?? '').toString() == identity) {
        map['isReal'] = true;
        map['finalizado'] = true;
        map['estadoPartido'] = 'finalizado';

        final partidoInterno = Map<String, dynamic>.from(
          (map['partido'] as Map?)?.cast<String, dynamic>() ??
              <String, dynamic>{},
        );

        partidoInterno['estado'] = 'Finalizado';
        partidoInterno['estadoPartido'] = 'finalizado';
        partidoInterno['esPartidoReal'] = true;

        map['partido'] = partidoInterno;
        actualizado = true;
      }

      return map;
    }).toList();

    if (!actualizado) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No encontre este partido en el historial finalizado'),
        ),
      );
      return;
    }

    await prefs.setString(
      'finished_matches_history_v1',
      jsonEncode(nuevoHistory),
    );

    setState(() {
      widget.partido['esPartidoReal'] = true;
      widget.partido['estado'] = 'Finalizado';
      widget.partido['estadoPartido'] = 'finalizado';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ Partido marcado como REAL')),
    );
  }

  /// ===============================
  ///   /// HEADER DEL CENTRO DE CONTROL
  /// Muestra categoría y torneo del partido.
  /// Ya lee esos datos desde PartidoModel (base 2.0),
  /// pero sin alterar la logica actual de la pantalla.
  /// ===============================

  Widget _buildControlHeader() {
    return Text(
      '${partidoV2.categoria} · ${partidoV2.torneo}',
      style: const TextStyle(fontSize: 14, color: Color(0xFFD4DCE7)),
    );
  }

  Widget _buildScoreCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1722).withOpacity(0.90),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      child: Column(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: _buildStateChip(_getEstadoTexto()),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              SizedBox(
                width: 110,
                child: _buildTeamSide(
                  nombre: _nombreLocal,
                  condicion: 'Local',
                  assetPath: _escudoLocalPath,
                ),
              ),
              Expanded(
                child: Center(
                  child: Column(
                    children: [
                      Text(
                        '$_golesLocal - $_golesVisitante',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      if (estadoPartido == 'penales' ||
                          penalesConvertidosSanFernando > 0 ||
                          penalesConvertidosRival > 0) ...[
                        const SizedBox(height: 6),
                        Text(
                          '($penalesConvertidosSanFernando - $penalesConvertidosRival)',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFFAAB4C3),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: 110,
                child: _buildTeamSide(
                  nombre: _nombreVisitante,
                  condicion: 'Visitante',
                  assetPath: _escudoVisitantePath,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTeamSide({
    required String nombre,
    required String condicion,
    required String? assetPath,
  }) {
    return Column(
      children: [
        Text(
          condicion,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFFAAB4C3),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        buildShieldAvatar(assetPath, size: 62, padding: 10),
        const SizedBox(height: 8),
        Text(
          nombre,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildStateChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1C2B44).withOpacity(0.95),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFFDCE4EF),
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildPrimaryAction({
    required String text,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4F8CFF),
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget _buildMiniAction({
    required String text,
    required IconData icon,
    required VoidCallback onTap,
    required bool highlighted,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          color: highlighted
              ? const Color(0xFF4F8CFF).withOpacity(0.22)
              : const Color(0xFF182338).withOpacity(0.75),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: highlighted
                ? const Color(0xFF4F8CFF).withOpacity(0.45)
                : Colors.white.withOpacity(0.04),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 22, color: Colors.white),
            const SizedBox(height: 8),
            Text(
              text,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: highlighted ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ===============================
  /// RESUMEN PARCIAL
  /// Muestra metricas rápidas del partido.
  /// Empieza a leer estadísticas desde PartidoModel (base 2.0).
  /// ===============================
  Widget _buildPartialSummaryCard() {
    final double eficaciaArquero = (atajadas + golesRecibidos) == 0
        ? 0
        : (atajadas / (atajadas + golesRecibidos)) * 100;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1722).withOpacity(0.82),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Resumen parcial',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          _buildSummaryRow(
            'Eficacia arquero',
            '${_eficaciaArqueroV2.toStringAsFixed(1)}%',
          ),
          _buildSummaryRow('Perdidas', '$_perdidasV2'),
          _buildSummaryRow('Recuperaciones', '$_recuperacionesV2'),
          _buildSummaryRow('Penales', '$_penalesV2'),
          _buildSummaryRow('Exclusiones 2 min', '$_exclusiones2MinV2'),
          _buildSummaryRow('Tarjetas amarillas', '$_amarillasV2'),
          _buildSummaryRow('Tarjetas rojas', '$_rojasV2'),
          _buildSummaryRow('Eventos cargados', '$_cantidadEventosV2'),
          _buildSummaryRow('Modo actual', modoActual ?? '-'),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Color(0xFFAAB4C3), fontSize: 13),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  String _getEstadoTexto() {
    switch (estadoPartido) {
      case 'no_iniciado':
        return 'Previo';
      case 'primer_tiempo':
        return '1T';
      case 'entretiempo':
        return 'Entretiempo';
      case 'segundo_tiempo':
        return '2T';
      case 'primer_tiempo_alargue':
        return '1T alargue';
      case 'entretiempo_alargue':
        return 'Entretiempo alargue';
      case 'segundo_tiempo_alargue':
        return '2T alargue';
      case 'penales':
        return 'Penales';
      case 'finalizado':
        return 'Final';
      default:
        return 'Estado';
    }
  }

  String _getTextoBotonCentroControl() {
    switch (estadoPartido) {
      case 'no_iniciado':
        return 'Ir a partido en vivo';
      case 'primer_tiempo':
      case 'segundo_tiempo':
      case 'primer_tiempo_alargue':
      case 'segundo_tiempo_alargue':
        return 'Volver al partido en vivo';
      case 'entretiempo':
      case 'entretiempo_alargue':
        return 'Volver';
      case 'penales':
        return 'Volver a penales';
      default:
        return 'Ir a partido en vivo';
    }
  }
}

/// ===============================
/// ===============================
/// PARTIDO EN VIVO
/// ===============================
/// ===============================

class PartidoEnVivoScreen extends StatefulWidget {
  final Map<String, dynamic> partido;

  final String estadoInicial;
  final int golesSanFernandoInicial;
  final int golesRivalInicial;
  final int atajadasInicial;
  final int penalesInicial;
  final int exclusiones2MinInicial;
  final int amarillasInicial;
  final int rojasInicial;
  final int perdidasInicial;
  final int recuperacionesInicial;
  final int penalesConvertidosSanFernandoInicial;
  final int penalesConvertidosRivalInicial;
  final List<Map<String, dynamic>> eventosIniciales;
  final String? modoInicial;
  final String? modoInicioPrimerTiempo;
  final String? modoInicioPrimerTiempoAlargue;

  const PartidoEnVivoScreen({
    super.key,
    required this.partido,
    required this.estadoInicial,
    required this.golesSanFernandoInicial,
    required this.golesRivalInicial,
    required this.atajadasInicial,
    required this.penalesInicial,
    required this.exclusiones2MinInicial,
    required this.amarillasInicial,
    required this.rojasInicial,
    required this.perdidasInicial,
    required this.recuperacionesInicial,
    required this.penalesConvertidosSanFernandoInicial,
    required this.penalesConvertidosRivalInicial,
    required this.eventosIniciales,
    required this.modoInicial,
    required this.modoInicioPrimerTiempo,
    required this.modoInicioPrimerTiempoAlargue,
  });

  @override
  State<PartidoEnVivoScreen> createState() => _PartidoEnVivoScreenState();
}

class _PartidoEnVivoScreenState extends State<PartidoEnVivoScreen> {
  late String estadoPartido;
  late List<GameEvent> gameEvents;

  late int golesSanFernando;
  late int golesRival;
  late int golesRecibidos;

  late int atajadas;
  late int penales;
  late int exclusiones2Min;
  late int amarillas;
  late int rojas;
  late int perdidas;
  late int recuperaciones;

  late int penalesConvertidosSanFernando;
  late int penalesConvertidosRival;
  late int penalesIntentadosSanFernando;
  late int penalesIntentadosRival;

  /// Jugador actualmente seleccionado para cargar eventos.
  /// Si está vacío, el evento queda como jugador generico.
  String? jugadorSeleccionado;
  String? jugadorSeleccionadoId;
  bool mostrarSelectorLateralJugador = false;

  String? _tiroPendienteResultado;
  String? _tiroPendienteModo;
  String? _tiroPendienteZonaTiro;
  String? _tiroPendienteZonaArco;
  bool _tiroPendienteMantieneContexto = false;
  Map<String, dynamic>? _tiroPendientePrevState;

  String? modo; // ataque / defensa

  String? zonaTiro;
  String? zonaArco;

  bool penalEnCurso = false;
  String? actorPenalActual;

  bool mostrarContra = false;
  bool contraDebeCambiarModo = true;
  String origenJugadaActual = 'normal';

  late List<Map<String, dynamic>> eventos;
  int _contadorEventoId = 0;

  String? modoInicioPrimerTiempo;
  String? modoInicioPrimerTiempoAlargue;

  PlayerProfile? _currentFieldPlayer;

  String _currentFieldPlayerActorName() {
    if (_currentFieldPlayer == null) return 'Jugador';

    return _currentFieldPlayer!.displayName;
  }

  String _resolvePrimaryActorForShot({
    required String eventMode,
    bool allowGoalkeeperInAttack = false,
  }) {
    if (eventMode == 'defensa') {
      return _currentGoalkeeperActorName;
    }

    if (allowGoalkeeperInAttack &&
        mostrarContra &&
        currentGoalkeeperNumber != null) {
      return _currentGoalkeeperActorName;
    }

    return _currentFieldPlayerActorName();
  }

  static const bool _showCourtOverlay = true;
  static const bool _showTouchDebug = false;

  void _activarSalidaNormal() {
    if (modo == null) return;

    setState(() {
      // Sale jugando normal el equipo que recuperó la pelota.
      modo = modo == 'ataque' ? 'defensa' : 'ataque';

      mostrarContra = false;
      contraDebeCambiarModo = true;

      zonaTiro = null;
      zonaArco = null;

      jugadorSeleccionado = null;
      jugadorSeleccionadoId = null;

      penalEnCurso = false;
      actorPenalActual = null;

      origenJugadaActual = 'normal';
      mostrarSelectorLateralJugador = false;
    });

    _persistLiveMatch();
  }

  bool get _hasUndoableGameEvents {
    return gameEvents.any((e) => e.isUndoableGameEvent);
  }

  String? currentGoalkeeperNumber; // '33' o '1'

  static const String _liveMatchStorageKey = 'live_match_current_v1';
  static const String _finishedMatchesStorageKey =
      'finished_matches_history_v1';

  String _normalizeValue(dynamic value) {
    return normalizeHandballText(value);
  }

  String get _matchIdentity {
    return PartidoRepositoryV2.buildMatchIdentityFromMap(
      Map<String, dynamic>.from(widget.partido),
    );
  }

  bool get _isArgentinosJuniorsOfficialMatch {
    return _normalizeValue(widget.partido['torneo']) == 'apertura' &&
        _normalizeValue(widget.partido['categoria']) == 'cadetes' &&
        _normalizeValue(widget.partido['fecha']) == '4' &&
        _normalizeValue(widget.partido['rival']) == 'argentinos juniors' &&
        _normalizeValue(widget.partido['condicion']) == 'local';
  }

  List<PlayerProfile> get _jugadoresConvocados {
    final squadMapRaw = widget.partido['matchSquad'];
    final snapshotRaw = widget.partido['matchRosterSnapshot'];

    final rosterBase = snapshotRaw is List
        ? snapshotRaw
              .whereType<Map>()
              .map((e) => PlayerProfile.fromMap(Map<String, dynamic>.from(e)))
              .where((p) => !p.esCuerpoTecnico)
              .toList()
        : RosterRepository.rosterForCategory(
            categoria: (widget.partido['categoria'] ?? '').toString(),
            temporada: (widget.partido['temporada'] ?? '2026').toString(),
            includeStaff: false,
          );

    if (squadMapRaw is! Map) {
      return rosterBase.where((p) => !p.esCuerpoTecnico).toList();
    }

    final squad = MatchSquadConfig.fromMap(
      Map<String, dynamic>.from(squadMapRaw),
    );

    if (squad.convocadosIds.isEmpty && squad.arquerosIds.isEmpty) {
      return rosterBase.where((p) => !p.esCuerpoTecnico).toList();
    }

    return rosterBase
        .where((p) => squad.convocadosIds.contains(p.playerId))
        .where((p) => !p.esCuerpoTecnico)
        .toList();
  }

  List<PlayerProfile> get _jugadoresCampoConvocados {
    return _jugadoresConvocados
        .where((p) => !p.esArquero && !p.esCuerpoTecnico)
        .toList();
  }

  bool _debeMostrarSelectorJugadorParaAtaque() {
    return modo == 'ataque' &&
        jugadorSeleccionado == null &&
        _jugadoresCampoConvocados.isNotEmpty;
  }

  /// ===============================
  /// ARQUEROS DISPONIBLES DEL PARTIDO
  /// Lee desde matchRosterSnapshot si existe.
  /// Esto permite usar arqueros creados/editados en Plantel 2.1.
  /// ===============================
  List<PlayerProfile> _availableGoalkeepersForMatch() {
    final matchSquadRaw = widget.partido['matchSquad'];
    final snapshotRaw = widget.partido['matchRosterSnapshot'];

    final rosterBase = snapshotRaw is List
        ? snapshotRaw
              .whereType<Map>()
              .map((e) => PlayerProfile.fromMap(Map<String, dynamic>.from(e)))
              .where((p) => !p.esCuerpoTecnico)
              .toList()
        : <PlayerProfile>[];

    if (matchSquadRaw is Map) {
      final config = MatchSquadConfig.fromMap(
        Map<String, dynamic>.from(matchSquadRaw),
      );

      final arquerosConvocados = rosterBase.where((p) {
        return p.esArquero && config.arquerosIds.contains(p.playerId);
      }).toList();

      if (arquerosConvocados.isNotEmpty) {
        return arquerosConvocados;
      }
    }

    return rosterBase.where((p) => p.esArquero).toList();
  }

  PlayerProfile? _getCurrentGoalkeeperProfile() {
    final arqueros = _availableGoalkeepersForMatch();

    if (arqueros.isEmpty) return null;

    if (currentGoalkeeperNumber == null) {
      return arqueros.first;
    }

    for (final gk in arqueros) {
      if (gk.numeroPreferido == currentGoalkeeperNumber) {
        return gk;
      }
    }

    return arqueros.first;
  }

  String get _currentGoalkeeperActorName {
    final gk = _getCurrentGoalkeeperProfile();
    if (gk == null) return 'Arquero';
    return gk.displayName;
  }

  String? _rivalShieldAsset() {
    return rivalShieldAssetGlobal(widget.partido['rival']);
  }

  Map<String, dynamic> _toPersistedMatchMap() {
    final partidoPersistido = Map<String, dynamic>.from(widget.partido);

    partidoPersistido['estado'] = estadoPartido == 'finalizado'
        ? 'Finalizado'
        : 'En vivo';
    partidoPersistido['estadoPartido'] = estadoPartido;
    partidoPersistido['finalizado'] = estadoPartido == 'finalizado';

    partidoPersistido['golesSanFernando'] = golesSanFernando;
    partidoPersistido['golesRival'] = golesRival;
    partidoPersistido['golesRecibidos'] = golesRecibidos;
    partidoPersistido['atajadas'] = atajadas;
    partidoPersistido['penales'] = penales;
    partidoPersistido['exclusiones2Min'] = exclusiones2Min;
    partidoPersistido['amarillas'] = amarillas;
    partidoPersistido['rojas'] = rojas;
    partidoPersistido['perdidas'] = perdidas;
    partidoPersistido['recuperaciones'] = recuperaciones;
    partidoPersistido['penalesConvertidosSanFernando'] =
        penalesConvertidosSanFernando;
    partidoPersistido['penalesConvertidosRival'] = penalesConvertidosRival;
    partidoPersistido['modoActual'] = modo;
    partidoPersistido['modoInicioPrimerTiempo'] = modoInicioPrimerTiempo;
    partidoPersistido['modoInicioPrimerTiempoAlargue'] =
        modoInicioPrimerTiempoAlargue;
    partidoPersistido['currentGoalkeeperNumber'] = currentGoalkeeperNumber;
    partidoPersistido['eventos'] = eventos;

    return {
      'version': 2,
      'matchIdentity': _matchIdentity,
      'partido': partidoPersistido,
      'institutionId': partidoPersistido['institutionId'],
      'temporada': partidoPersistido['temporada'],
      'competencia': partidoPersistido['competencia'],
      'torneo': partidoPersistido['torneo'],
      'categoria': partidoPersistido['categoria'],
      'estadoPartido': estadoPartido,
      'finalizado': estadoPartido == 'finalizado',
      'golesSanFernando': golesSanFernando,
      'golesRival': golesRival,
      'golesRecibidos': golesRecibidos,
      'atajadas': atajadas,
      'penales': penales,
      'exclusiones2Min': exclusiones2Min,
      'amarillas': amarillas,
      'rojas': rojas,
      'perdidas': perdidas,
      'recuperaciones': recuperaciones,
      'penalesConvertidosSanFernando': penalesConvertidosSanFernando,
      'penalesConvertidosRival': penalesConvertidosRival,
      'penalesIntentadosSanFernando': penalesIntentadosSanFernando,
      'penalesIntentadosRival': penalesIntentadosRival,
      'modo': modo,
      'zonaTiro': zonaTiro,
      'zonaArco': zonaArco,
      'penalEnCurso': penalEnCurso,
      'actorPenalActual': actorPenalActual,
      'mostrarContra': mostrarContra,
      'contraDebeCambiarModo': contraDebeCambiarModo,
      'origenJugadaActual': origenJugadaActual,
      'modoInicioPrimerTiempo': modoInicioPrimerTiempo,
      'modoInicioPrimerTiempoAlargue': modoInicioPrimerTiempoAlargue,
      'currentGoalkeeperNumber': currentGoalkeeperNumber,
      'eventos': eventos,
    };
  }

  Future<void> _persistLiveMatch() async {
    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final data = _toPersistedMatchMap();
    await prefs.setString(_liveMatchStorageKey, jsonEncode(data));
  }

  Future<void> _clearPersistedLiveMatch() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_liveMatchStorageKey);
  }

  Future<void> _archiveFinishedMatchIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_finishedMatchesStorageKey);

    List<dynamic> history = [];
    if (raw != null && raw.isNotEmpty) {
      history = jsonDecode(raw) as List<dynamic>;
    }

    final finishedData = _toPersistedMatchMap()
      ..['archivedAt'] = DateTime.now().toIso8601String()
      ..['finalizado'] = true
      ..['estadoPartido'] = 'finalizado'
      //..['isReal'] = true;
      ..['isReal'] = widget.partido['esPartidoReal'] == true;

    history.removeWhere((item) {
      if (item is! Map) return false;
      return (item['matchIdentity'] ?? '') == _matchIdentity;
    });

    history.add(finishedData);

    await prefs.setString(_finishedMatchesStorageKey, jsonEncode(history));
    await _clearPersistedLiveMatch();
  }

  Future<void> _loadSavedLiveMatchIfAny() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_liveMatchStorageKey);

    if (raw == null || raw.isEmpty) return;

    final Map<String, dynamic> data = Map<String, dynamic>.from(
      jsonDecode(raw) as Map,
    );

    if ((data['matchIdentity'] ?? '') != _matchIdentity) return;
    if ((data['estadoPartido'] ?? '') == 'finalizado') return;

    setState(() {
      estadoPartido = (data['estadoPartido'] ?? estadoPartido) as String;
      golesSanFernando = (data['golesSanFernando'] ?? golesSanFernando) as int;
      golesRival = (data['golesRival'] ?? golesRival) as int;
      golesRecibidos = (data['golesRecibidos'] ?? golesRecibidos) as int;

      atajadas = (data['atajadas'] ?? atajadas) as int;
      penales = (data['penales'] ?? penales) as int;
      exclusiones2Min = (data['exclusiones2Min'] ?? exclusiones2Min) as int;
      amarillas = (data['amarillas'] ?? amarillas) as int;
      rojas = (data['rojas'] ?? rojas) as int;
      perdidas = (data['perdidas'] ?? perdidas) as int;
      recuperaciones = (data['recuperaciones'] ?? recuperaciones) as int;

      penalesConvertidosSanFernando =
          (data['penalesConvertidosSanFernando'] ??
                  penalesConvertidosSanFernando)
              as int;
      penalesConvertidosRival =
          (data['penalesConvertidosRival'] ?? penalesConvertidosRival) as int;
      penalesIntentadosSanFernando =
          (data['penalesIntentadosSanFernando'] ?? penalesIntentadosSanFernando)
              as int;
      penalesIntentadosRival =
          (data['penalesIntentadosRival'] ?? penalesIntentadosRival) as int;

      modo = data['modo'] as String?;
      zonaTiro = data['zonaTiro'] as String?;
      zonaArco = data['zonaArco'] as String?;
      penalEnCurso = (data['penalEnCurso'] ?? false) as bool;
      actorPenalActual = data['actorPenalActual'] as String?;
      mostrarContra = (data['mostrarContra'] ?? false) as bool;
      contraDebeCambiarModo = (data['contraDebeCambiarModo'] ?? true) as bool;
      origenJugadaActual = (data['origenJugadaActual'] ?? 'normal') as String;

      modoInicioPrimerTiempo = data['modoInicioPrimerTiempo'] as String?;
      modoInicioPrimerTiempoAlargue =
          data['modoInicioPrimerTiempoAlargue'] as String?;

      currentGoalkeeperNumber = data['currentGoalkeeperNumber'] as String?;

      final persistedEvents = (data['eventos'] as List<dynamic>? ?? const [])
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();

      eventos = persistedEvents;
      gameEvents = eventos.map((e) => GameEvent.fromLegacyMap(e)).toList();

      if (eventos.isNotEmpty) {
        final dynamic ultimoId = eventos.last['id'];
        if (ultimoId is int) {
          _contadorEventoId = ultimoId;
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      await _loadSavedLiveMatchIfAny();
    });

    estadoPartido = widget.estadoInicial;
    golesSanFernando = widget.golesSanFernandoInicial;
    golesRival = widget.golesRivalInicial;
    golesRecibidos = widget.golesRivalInicial;

    atajadas = widget.atajadasInicial;
    penales = widget.penalesInicial;
    exclusiones2Min = widget.exclusiones2MinInicial;
    amarillas = widget.amarillasInicial;
    rojas = widget.rojasInicial;
    perdidas = widget.perdidasInicial;
    recuperaciones = widget.recuperacionesInicial;

    penalesConvertidosSanFernando = widget.penalesConvertidosSanFernandoInicial;
    penalesConvertidosRival = widget.penalesConvertidosRivalInicial;

    penalesIntentadosSanFernando = penalesConvertidosSanFernando;
    penalesIntentadosRival = penalesConvertidosRival;

    eventos = widget.eventosIniciales
        .map((e) => Map<String, dynamic>.from(e))
        .toList();

    gameEvents = eventos.map((e) => GameEvent.fromLegacyMap(e)).toList();

    if (eventos.isNotEmpty) {
      final dynamic ultimoId = eventos.last['id'];
      if (ultimoId is int) {
        _contadorEventoId = ultimoId;
      }
    }

    modo = widget.modoInicial;
    modoInicioPrimerTiempo = widget.modoInicioPrimerTiempo;
    modoInicioPrimerTiempoAlargue = widget.modoInicioPrimerTiempoAlargue;

    currentGoalkeeperNumber = null;

    _aplicarModoAutomaticoSegunEstado();
  }

  @override
  void dispose() {
    _persistLiveMatch();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  void _aplicarModoAutomaticoSegunEstado() {
    if (estadoPartido == 'segundo_tiempo' && modo == null) {
      if (modoInicioPrimerTiempo != null) {
        modo = _invertirModo(modoInicioPrimerTiempo!);
      }
    }

    if (estadoPartido == 'segundo_tiempo_alargue' && modo == null) {
      if (modoInicioPrimerTiempoAlargue != null) {
        modo = _invertirModo(modoInicioPrimerTiempoAlargue!);
      }
    }
  }

  String _invertirModo(String valor) {
    return valor == 'ataque' ? 'defensa' : 'ataque';
  }

  bool _isPlayLocked() {
    return estadoPartido == 'no_iniciado' ||
        estadoPartido == 'entretiempo' ||
        estadoPartido == 'entretiempo_alargue' ||
        estadoPartido == 'finalizado';
  }

  bool _isDraw() => golesSanFernando == golesRival;
  bool _isPenaltyShootout() => estadoPartido == 'penales';

  bool get _somosLocales {
    return (widget.partido['condicion'] ?? '')
            .toString()
            .trim()
            .toLowerCase() ==
        'local';
  }

  String get _equipoPropioNombreEnVivo {
    final raw = (widget.partido['equipoPropio'] ?? '').toString().trim();

    if (raw.isNotEmpty && raw.toLowerCase() != 'null') {
      return fixTextoRoto(raw);
    }

    return 'Institución';
  }

  String? get _equipoPropioEscudoEnVivo {
    final raw = (widget.partido['escudoPropio'] ?? '').toString().trim();

    if (raw.isNotEmpty && raw.toLowerCase() != 'null') {
      return raw;
    }

    return null;
  }

  String? get _rivalEscudoEnVivo {
    final directo = (widget.partido['escudoRival'] ?? '').toString().trim();

    if (directo.isNotEmpty && directo.toLowerCase() != 'null') {
      return directo;
    }

    return _rivalShieldAsset();
  }

  String get _nombreLocalEnVivo {
    return _somosLocales
        ? _equipoPropioNombreEnVivo
        : (widget.partido['rival'] ?? 'Rival').toString();
  }

  String get _nombreVisitanteEnVivo {
    return _somosLocales
        ? (widget.partido['rival'] ?? 'Rival').toString()
        : _equipoPropioNombreEnVivo;
  }

  String? get _escudoLocalEnVivo {
    return _somosLocales ? _equipoPropioEscudoEnVivo : _rivalEscudoEnVivo;
  }

  String? get _escudoVisitanteEnVivo {
    return _somosLocales ? _rivalEscudoEnVivo : _equipoPropioEscudoEnVivo;
  }

  int _golesLocal() => _somosLocales ? golesSanFernando : golesRival;
  int _golesVisitante() => _somosLocales ? golesRival : golesSanFernando;

  int _penalesLocal() =>
      _somosLocales ? penalesConvertidosSanFernando : penalesConvertidosRival;

  int _penalesVisitante() =>
      _somosLocales ? penalesConvertidosRival : penalesConvertidosSanFernando;

  bool get _lateralGestureEnabled =>
      !_isPlayLocked() && !_isPenaltyShootout() && !penalEnCurso;

  bool get _fueraGestureEnabled => !_isPlayLocked() && modo != null;

  Widget _buildCompactScoreBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1722).withOpacity(0.88),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      child: Row(
        children: [
          _buildMiniTeamTag('L'),
          const SizedBox(width: 8),
          _buildMiniShield(assetPath: _escudoLocalEnVivo),
          const Spacer(),
          Column(
            children: [
              Text(
                '${_golesLocal()} - ${_golesVisitante()}',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              if (_isPenaltyShootout()) ...[
                const SizedBox(height: 4),
                Text(
                  '(${_penalesLocal()} - ${_penalesVisitante()})',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFFAAB4C3),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
          const Spacer(),
          _buildMiniShield(assetPath: _escudoVisitanteEnVivo),
          const SizedBox(width: 8),
          _buildMiniTeamTag('V'),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await _persistLiveMatch();
        _goBack();
        return false;
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: const Text('Partido en vivo'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              await _persistLiveMatch();
              _goBack();
            },
          ),
          actions: [
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              color: const Color(0xFF0F1722),
              onSelected: (value) async {
                if (value == 'undo') {
                  if (_hasUndoableGameEvents) {
                    _deshacerUltimoEvento();
                  }
                } else if (value == 'undo_sanction') {
                  _showUndoSanctionSheet();
                } else if (value == 'goalkeeper') {
                  await _showGoalkeeperSelectorSheet(
                    title: 'Cambiar arquero activo',
                  );
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem<String>(
                  value: 'undo',
                  enabled: _hasUndoableGameEvents,
                  child: Text(
                    'Deshacer ultimo evento',
                    style: TextStyle(
                      color: _hasUndoableGameEvents
                          ? Colors.white
                          : Colors.white54,
                    ),
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'undo_sanction',
                  child: Text(
                    'Deshacer sancion',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'goalkeeper',
                  child: Text(
                    currentGoalkeeperNumber == null
                        ? 'Seleccionar arquero'
                        : 'Arquero actual: $currentGoalkeeperNumber',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
        body: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/fondohd.jpeg',
                fit: BoxFit.cover,
              ),
            ),
            Positioned.fill(
              child: Container(
                color: const Color(0xFF05080D).withOpacity(0.90),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildCompactScoreBar(),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildModeSwitch(),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _buildGoalGrid(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildEventButton(
                            text: mostrarContra ? 'Contra' : 'Perdida',
                            onTap:
                                _isPlayLocked() ||
                                    _isPenaltyShootout() ||
                                    modo == null
                                ? null
                                : () {
                                    if (mostrarContra) {
                                      _activarContra();
                                    } else {
                                      _showPerdidaSheet();
                                    }
                                  },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildEventButton(
                            text: mostrarContra ? 'Normal' : 'Penal',
                            onTap:
                                _isPlayLocked() ||
                                    _isPenaltyShootout() ||
                                    modo == null
                                ? null
                                : mostrarContra
                                ? _activarSalidaNormal
                                : _iniciarFlujoPenalNormal,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildEventButton(
                            text: 'Sancion',
                            onTap: _isPlayLocked()
                                ? null
                                : _showSancionTargetSheet,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: _buildPrimaryAction(
                        text: _getActionText(),
                        onTap: _handleMainAction,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (estadoPartido == 'entretiempo')
              _buildCenteredOverlay('Entretiempo'),
            if (estadoPartido == 'entretiempo_alargue')
              _buildCenteredOverlay('Entretiempo alargue'),
            if (mostrarSelectorLateralJugador) _buildSelectorLateralJugador(),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniShield({String? assetPath}) {
    return buildShieldAvatar(assetPath, size: 34, padding: 6);
  }

  Widget _buildMiniTeamTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF182338).withOpacity(0.9),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFFDCE4EF),
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildModeSwitch() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1722).withOpacity(0.85),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildModeOption(
              label: 'Defensa',
              isSelected: modo == 'defensa',
              onTap: () {
                if (_isPlayLocked()) return;
                setState(() {
                  modo = 'defensa';
                  zonaTiro = null;
                  zonaArco = null;
                  penalEnCurso = false;
                  mostrarContra = false;
                  origenJugadaActual = 'normal';
                  mostrarSelectorLateralJugador = false;

                  if (estadoPartido == 'primer_tiempo' &&
                      modoInicioPrimerTiempo == null) {
                    modoInicioPrimerTiempo = 'defensa';
                  }
                  if (estadoPartido == 'primer_tiempo_alargue' &&
                      modoInicioPrimerTiempoAlargue == null) {
                    modoInicioPrimerTiempoAlargue = 'defensa';
                  }
                });
              },
            ),
          ),
          Expanded(
            child: _buildModeOption(
              label: 'Ataque',
              isSelected: modo == 'ataque',
              onTap: () {
                if (_isPlayLocked()) return;
                setState(() {
                  modo = 'ataque';
                  zonaTiro = null;
                  zonaArco = null;
                  penalEnCurso = false;
                  mostrarContra = false;
                  origenJugadaActual = 'normal';
                  mostrarSelectorLateralJugador = false;

                  if (estadoPartido == 'primer_tiempo' &&
                      modoInicioPrimerTiempo == null) {
                    modoInicioPrimerTiempo = 'ataque';
                  }
                  if (estadoPartido == 'primer_tiempo_alargue' &&
                      modoInicioPrimerTiempoAlargue == null) {
                    modoInicioPrimerTiempoAlargue = 'ataque';
                  }
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeOption({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF4F8CFF).withOpacity(0.22)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(isSelected ? 1 : 0.8),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGoalGrid() {
    final bool soloArco = _isPenaltyShootout() || penalEnCurso;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
          decoration: BoxDecoration(
            color: const Color(0xFF0F1722).withOpacity(0.82),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.04)),
          ),
          child: Stack(
            children: [
              soloArco ? _buildPenaltyOnlyGrid() : _buildNormalPlayGrid(),
              if (_showCourtOverlay && !soloArco)
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(painter: CourtOverlayPainter()),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSelectorLateralJugador() {
    final jugadores = _jugadoresCampoConvocados;

    return Positioned(
      left: 0,
      top: 120,
      bottom: 120,
      child: Container(
        width: 72,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF0F1722).withOpacity(0.96),
          borderRadius: const BorderRadius.horizontal(
            right: Radius.circular(18),
          ),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: ListView(
          children: jugadores.map((p) {
            final dorsal = p.numeroPreferido ?? '-';

            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _seleccionarJugadorParaTiroPendiente(p),
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 7, horizontal: 10),
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF4F8CFF),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    dorsal,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildTouchLane({
    required bool enabled,
    required VoidCallback onTap,
    required Color debugColor,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: enabled ? onTap : null,
      child: Container(
        color: _showTouchDebug
            ? debugColor.withOpacity(0.35)
            : Colors.transparent,
      ),
    );
  }

  Widget _buildNormalPlayGrid() {
    const double fueraTopHeight = 18;
    const double fueraTopSideInset = 10;
    const double fueraTopTranslateY = -6;

    const double lateralWidth = 12;
    const double centerGapToLaterals = 6;

    const double fueraSideWidth = 12;
    const double fueraSideOffsetX = 10;
    const double fueraSideOffsetY = -10;
    const double fueraSideBottomTrim = 8;

    const double gapArcoToPenaltyLine = 22;
    const double gapPenaltyLineToZone = 14;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double totalHeight = constraints.maxHeight;
        final double arcoHeight = totalHeight * 0.28;
        final double lateralTopStart = arcoHeight;

        return Column(
          children: [
            SizedBox(
              height: fueraTopHeight,
              child: Row(
                children: [
                  const SizedBox(width: fueraTopSideInset),
                  Expanded(
                    child: Transform.translate(
                      offset: const Offset(0, fueraTopTranslateY),
                      child: _buildTouchLane(
                        enabled: _fueraGestureEnabled,
                        onTap: _registrarFueraPorGesto,
                        debugColor: Colors.red,
                      ),
                    ),
                  ),
                  const SizedBox(width: fueraTopSideInset),
                ],
              ),
            ),
            const SizedBox(height: 2),
            Expanded(
              child: Row(
                children: [
                  SizedBox(
                    width: lateralWidth,
                    child: Column(
                      children: [
                        SizedBox(height: lateralTopStart),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: _buildTouchLane(
                              enabled: _lateralGestureEnabled,
                              onTap: () => _showLateralSheet('izquierdo'),
                              debugColor: Colors.red,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: centerGapToLaterals),
                  Expanded(
                    child: Column(
                      children: [
                        SizedBox(
                          height: arcoHeight,
                          child: Row(
                            children: [
                              Transform.translate(
                                offset: const Offset(
                                  -fueraSideOffsetX,
                                  fueraSideOffsetY,
                                ),
                                child: SizedBox(
                                  width: fueraSideWidth,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                      bottom: fueraSideBottomTrim,
                                    ),
                                    child: _buildTouchLane(
                                      enabled: _fueraGestureEnabled,
                                      onTap: _registrarFueraPorGesto,
                                      debugColor: Colors.red,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(child: _buildFlatGoalAreaCompact()),
                              const SizedBox(width: 6),
                              Transform.translate(
                                offset: const Offset(
                                  fueraSideOffsetX,
                                  fueraSideOffsetY,
                                ),
                                child: SizedBox(
                                  width: fueraSideWidth,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                      bottom: fueraSideBottomTrim,
                                    ),
                                    child: _buildTouchLane(
                                      enabled: _fueraGestureEnabled,
                                      onTap: _registrarFueraPorGesto,
                                      debugColor: Colors.red,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: gapArcoToPenaltyLine),
                        _buildPenaltyLineMarker(),
                        const SizedBox(height: gapPenaltyLineToZone),
                        Expanded(child: _buildPerspectiveShotZonesLarge()),
                      ],
                    ),
                  ),
                  const SizedBox(width: centerGapToLaterals),
                  SizedBox(
                    width: lateralWidth,
                    child: Column(
                      children: [
                        SizedBox(height: lateralTopStart),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: _buildTouchLane(
                              enabled: _lateralGestureEnabled,
                              onTap: () => _showLateralSheet('derecho'),
                              debugColor: Colors.red,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPenaltyOnlyGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double totalHeight = constraints.maxHeight;

        // Antes ocupaba todo el alto.
        // Ahora usa aprox 2/3 del alto para el arco y deja aire arriba/abajo.
        final double goalHeight = totalHeight * 0.68;

        return Column(
          children: [
            const SizedBox(height: 4),
            Text(
              _isPenaltyShootout()
                  ? (modo == 'ataque'
                        ? 'Penal nuestro'
                        : modo == 'defensa'
                        ? 'Penal rival'
                        : 'Seleccioná contexto')
                  : 'Penal',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Center(
                child: SizedBox(
                  height: goalHeight,
                  child: _buildFlatGoalAreaCompact(),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFlatGoalAreaCompact() {
    return Stack(
      children: [
        Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  Expanded(child: _goalCell('AI')),
                  const SizedBox(width: 5),
                  Expanded(child: _goalCell('AC')),
                  const SizedBox(width: 5),
                  Expanded(child: _goalCell('AD')),
                ],
              ),
            ),
            const SizedBox(height: 3),
            Expanded(
              child: Row(
                children: [
                  Expanded(child: _goalCell('CI')),
                  const SizedBox(width: 5),
                  Expanded(child: _goalCell('CC')),
                  const SizedBox(width: 5),
                  Expanded(child: _goalCell('CD')),
                ],
              ),
            ),
            const SizedBox(height: 3),
            Expanded(
              child: Row(
                children: [
                  Expanded(child: _goalCell('BI')),
                  const SizedBox(width: 5),
                  Expanded(child: _goalCell('BC')),
                  const SizedBox(width: 5),
                  Expanded(child: _goalCell('BD')),
                ],
              ),
            ),
          ],
        ),

        // 🔥 HEATMAP
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: HeatmapPainter(
                gameEvents
                    .where((e) => e.phase == GameEventPhase.defensa)
                    .toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPenaltyLineMarker() {
    return Column(
      children: [
        Container(
          height: 2,
          width: double.infinity,
          color: Colors.white.withOpacity(0.20),
        ),
        const SizedBox(height: 3),
        Text(
          'Línea de penal',
          style: TextStyle(
            fontSize: 10,
            color: Colors.white.withOpacity(0.55),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildPerspectiveShotZonesLarge() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          flex: 12,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: _buildExtremeLane(
              shortLabel: 'EI',
              fullLabel: 'Extremo izquierdo',
              alignLeft: true,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(flex: 17, child: _buildSplitLaneLarge('LI')),
        const SizedBox(width: 6),
        Expanded(flex: 17, child: _buildSplitLaneLarge('C')),
        const SizedBox(width: 6),
        Expanded(flex: 17, child: _buildSplitLaneLarge('LD')),
        const SizedBox(width: 6),
        Expanded(
          flex: 12,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: _buildExtremeLane(
              shortLabel: 'ED',
              fullLabel: 'Extremo derecho',
              alignLeft: false,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSplitLaneLarge(String base) {
    final String zone6 = '$base 6m';
    final String zone9 = '$base 9m';

    return Column(
      children: [
        Expanded(
          flex: 5,
          child: _buildPerspectiveZoneCell(
            shortLabel: '$base\n6m',
            fullLabel: zone6,
            isSelected: zonaTiro == zone6,
            topWidthFactor: 0.70,
            bottomWidthFactor: 0.92,
          ),
        ),
        const SizedBox(height: 6),
        Expanded(
          flex: 10,
          child: _buildPerspectiveZoneCell(
            shortLabel: '$base\n9m',
            fullLabel: zone9,
            isSelected: zonaTiro == zone9,
            topWidthFactor: 0.84,
            bottomWidthFactor: 1.0,
          ),
        ),
      ],
    );
  }

  Widget _buildExtremeLane({
    required String shortLabel,
    required String fullLabel,
    required bool alignLeft,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap:
          _isPlayLocked() ||
              _isPenaltyShootout() ||
              penalEnCurso ||
              modo == null
          ? null
          : () {
              setState(() {
                zonaTiro = (zonaTiro == fullLabel) ? null : fullLabel;
                zonaArco = null;
                mostrarContra = false;
                origenJugadaActual = 'normal';
              });
            },
      child: CustomPaint(
        painter: _ExtremeZonePainter(
          selected: zonaTiro == fullLabel,
          alignLeft: alignLeft,
        ),
        child: Center(
          child: Text(
            shortLabel,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFFDCE4EF),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPerspectiveZoneCell({
    required String shortLabel,
    required String fullLabel,
    required bool isSelected,
    required double topWidthFactor,
    required double bottomWidthFactor,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap:
          _isPlayLocked() ||
              _isPenaltyShootout() ||
              penalEnCurso ||
              modo == null
          ? null
          : () {
              setState(() {
                zonaTiro = (zonaTiro == fullLabel) ? null : fullLabel;
                zonaArco = null;
                mostrarContra = false;
                origenJugadaActual = 'normal';
              });
            },
      child: CustomPaint(
        painter: _TrapezoidZonePainter(
          selected: isSelected,
          topWidthFactor: topWidthFactor,
          bottomWidthFactor: bottomWidthFactor,
        ),
        child: Center(
          child: Text(
            shortLabel,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFFDCE4EF),
              fontSize: 12,
              fontWeight: FontWeight.w700,
              height: 1.15,
            ),
          ),
        ),
      ),
    );
  }

  /// ===============================
  /// CONTRA DIRECTA DEL ARQUERO
  /// Permite que, luego de una atajada y activar Contra,
  /// el arquero pueda tirar directo al arco sin seleccionar zona de tiro.
  /// ===============================
  bool get _esContraArqueroDirecta {
    return origenJugadaActual == 'contra' &&
        _getCurrentGoalkeeperProfile() != null;
  }

  /// ===============================
  /// CELDA DE ARCO
  /// Maneja tiro normal, penal, tanda y contra directa del arquero.
  /// ===============================
  Widget _goalCell(String label) {
    final bool isSelected = zonaArco == label;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _isPlayLocked() || modo == null
          ? null
          : () {
              if (_isPenaltyShootout()) {
                setState(() {
                  zonaArco = label;
                  mostrarSelectorLateralJugador = false;
                });
                _showPenaltyShootoutResultSheet();
                return;
              }

              if (penalEnCurso) {
                setState(() {
                  zonaArco = label;
                  mostrarSelectorLateralJugador = false;
                });
                _showNormalPenaltyResultSheet();
                return;
              }

              if (zonaTiro == null && !_esContraArqueroDirecta) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Primero seleccioná zona de tiro'),
                  ),
                );
                return;
              }

              setState(() {
                zonaArco = zonaArco == label ? null : label;
                mostrarSelectorLateralJugador = false;
              });

              if (zonaArco != null) {
                _showZoneActionSheet();
              }
            },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF4F8CFF).withOpacity(0.24)
              : Colors.white.withOpacity(0.035),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF4F8CFF).withOpacity(0.55)
                : Colors.white.withOpacity(0.05),
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFFDCE4EF),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  Map<String, dynamic> _captureStateSnapshot() {
    return {
      'estadoPartido': estadoPartido,
      'golesSanFernando': golesSanFernando,
      'golesRival': golesRival,
      'golesRecibidos': golesRecibidos,
      'atajadas': atajadas,
      'penales': penales,
      'exclusiones2Min': exclusiones2Min,
      'amarillas': amarillas,
      'rojas': rojas,
      'perdidas': perdidas,
      'recuperaciones': recuperaciones,
      'penalesConvertidosSanFernando': penalesConvertidosSanFernando,
      'penalesConvertidosRival': penalesConvertidosRival,
      'penalesIntentadosSanFernando': penalesIntentadosSanFernando,
      'penalesIntentadosRival': penalesIntentadosRival,
      'modo': modo,
      'zonaTiro': zonaTiro,
      'zonaArco': zonaArco,
      'penalEnCurso': penalEnCurso,
      'actorPenalActual': actorPenalActual,
      'mostrarContra': mostrarContra,
      'contraDebeCambiarModo': contraDebeCambiarModo,
      'origenJugadaActual': origenJugadaActual,
      'modoInicioPrimerTiempo': modoInicioPrimerTiempo,
      'modoInicioPrimerTiempoAlargue': modoInicioPrimerTiempoAlargue,
    };
  }

  void _restoreStateSnapshot(Map<String, dynamic> snapshot) {
    estadoPartido = snapshot['estadoPartido'] as String? ?? estadoPartido;

    golesSanFernando = snapshot['golesSanFernando'] as int? ?? golesSanFernando;
    golesRival = snapshot['golesRival'] as int? ?? golesRival;
    golesRecibidos = snapshot['golesRecibidos'] as int? ?? golesRecibidos;

    atajadas = snapshot['atajadas'] as int? ?? atajadas;
    penales = snapshot['penales'] as int? ?? penales;
    exclusiones2Min = snapshot['exclusiones2Min'] as int? ?? exclusiones2Min;
    amarillas = snapshot['amarillas'] as int? ?? amarillas;
    rojas = snapshot['rojas'] as int? ?? rojas;
    perdidas = snapshot['perdidas'] as int? ?? perdidas;
    recuperaciones = snapshot['recuperaciones'] as int? ?? recuperaciones;

    penalesConvertidosSanFernando =
        snapshot['penalesConvertidosSanFernando'] as int? ??
        penalesConvertidosSanFernando;
    penalesConvertidosRival =
        snapshot['penalesConvertidosRival'] as int? ?? penalesConvertidosRival;

    penalesIntentadosSanFernando =
        snapshot['penalesIntentadosSanFernando'] as int? ??
        penalesIntentadosSanFernando;
    penalesIntentadosRival =
        snapshot['penalesIntentadosRival'] as int? ?? penalesIntentadosRival;

    modo = snapshot['modo'] as String?;
    zonaTiro = snapshot['zonaTiro'] as String?;
    zonaArco = snapshot['zonaArco'] as String?;
    penalEnCurso = snapshot['penalEnCurso'] as bool? ?? false;
    actorPenalActual = snapshot['actorPenalActual'] as String?;
    mostrarContra = snapshot['mostrarContra'] as bool? ?? false;
    contraDebeCambiarModo = snapshot['contraDebeCambiarModo'] as bool? ?? true;
    origenJugadaActual = snapshot['origenJugadaActual'] as String? ?? 'normal';

    modoInicioPrimerTiempo = snapshot['modoInicioPrimerTiempo'] as String?;
    modoInicioPrimerTiempoAlargue =
        snapshot['modoInicioPrimerTiempoAlargue'] as String?;
  }

  void _registrarEvento({
    required String tipo,
    String? actorPrincipalId,
    String? resultado,
    String? actorPrincipal,
    String? actorSecundario,
    String? zonaTiroValor,
    String? zonaArcoValor,
    String? detalle,
    String? subtipo,
    bool? mantieneContexto,
    Map<String, dynamic>? prevState,
    String? modoEvento,
    bool esContraDirectaArquero = false,
  }) {
    _contadorEventoId++;

    final now = DateTime.now();
    final eventMode = modoEvento ?? modo;

    final goalkeeper = _getCurrentGoalkeeperProfile();

    final bool debeAsociarArquero =
        eventMode == 'defensa' || esContraDirectaArquero;

    final String? arqueroId = debeAsociarArquero ? goalkeeper?.playerId : null;
    final String? arqueroNombre = debeAsociarArquero
        ? goalkeeper?.displayName
        : null;

    final legacyEvent = <String, dynamic>{
      'id': _contadorEventoId,
      'timestamp': now.toIso8601String(),
      'estadoPartido': estadoPartido,
      'modo': eventMode,
      'origenJugada': origenJugadaActual,
      'tipo': tipo,
      'resultado': resultado,
      'actorPrincipal': actorPrincipal,
      'actorPrincipalId': actorPrincipalId,
      'actorSecundario': actorSecundario,
      'zonaTiro': zonaTiroValor,
      'zonaArco': zonaArcoValor,
      'detalle': detalle,
      'subtipo': subtipo,
      'mantieneContexto': mantieneContexto ?? false,
      'prevState': prevState == null
          ? null
          : Map<String, dynamic>.from(prevState),

      // Legacy visual
      'arquero': debeAsociarArquero ? currentGoalkeeperNumber : null,

      // Nuevo estable
      'arqueroId': arqueroId,
      'arqueroNombre': arqueroNombre,
      'esContraDirectaArquero': esContraDirectaArquero,
    };

    debugPrint(
      'EVENTO -> tipo:$tipo resultado:$resultado modo:$eventMode '
      'actor:$actorPrincipal actorId:$actorPrincipalId '
      'arquero:$arqueroNombre arqueroId:$arqueroId '
      'zonaTiro:$zonaTiroValor zonaArco:$zonaArcoValor '
      'contraDirecta:$esContraDirectaArquero',
    );

    eventos.add(legacyEvent);
    gameEvents.add(GameEvent.fromLegacyMap(legacyEvent));

    _persistLiveMatch();
  }

  void _debugPrintEventSummary() {
    debugPrint('========== EVENT SUMMARY ==========');
    debugPrint('Legacy eventos: ${eventos.length}');
    debugPrint('Typed gameEvents: ${gameEvents.length}');
    debugPrint('Shots: ${_shotEvents.length}');
    debugPrint('Goals: ${_goalEvents.length}');
    debugPrint('Saves: ${_saveEvents.length}');
    debugPrint('Misses: ${_missEvents.length}');
    debugPrint('Attack events: ${_attackEvents.length}');
    debugPrint('Defense events: ${_defenseEvents.length}');
    debugPrint('==================================');
  }

  List<GameEvent> get _shotEvents {
    return gameEvents.where((e) => e.isShotLike).toList();
  }

  List<GameEvent> get _goalEvents {
    return gameEvents.where((e) => e.isGoal).toList();
  }

  List<GameEvent> get _saveEvents {
    return gameEvents.where((e) => e.isSave).toList();
  }

  List<GameEvent> get _missEvents {
    return gameEvents.where((e) => e.isMiss).toList();
  }

  List<GameEvent> get _attackEvents {
    return gameEvents.where((e) => e.phase == GameEventPhase.ataque).toList();
  }

  List<GameEvent> get _defenseEvents {
    return gameEvents.where((e) => e.phase == GameEventPhase.defensa).toList();
  }

  int _countByResult(String result) {
    return gameEvents.where((e) => e.resultado == result).length;
  }

  int _countShotsToZone(String zone) {
    return gameEvents.where((e) => e.zonaTiro == zone).length;
  }

  int _countShotsToGoalZone(String goalZone) {
    return gameEvents.where((e) => e.zonaArco == goalZone).length;
  }

  void _showPerdidaSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F1722),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Motivo de la perdida',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              _floatingOption('Robo', () {
                Navigator.pop(context);
                _registrarPerdidaConSubtipo('robo');
              }),
              _floatingOption('Mal pase', () {
                Navigator.pop(context);
                _registrarPerdidaConSubtipo('mal_pase');
              }),
              _floatingOption('Invasion', () {
                Navigator.pop(context);
                _registrarPerdidaConSubtipo('invasion');
              }),
              _floatingOption('Falta en ataque', () {
                Navigator.pop(context);
                _registrarPerdidaConSubtipo('falta_en_ataque');
              }),
              _floatingOption('Pasos', () {
                Navigator.pop(context);
                _registrarPerdidaConSubtipo('pasos');
              }),
              _floatingOption('Error tecnico', () {
                Navigator.pop(context);
                _registrarPerdidaConSubtipo('error_tecnico');
              }),
            ],
          ),
        );
      },
    );
  }

  void _registrarPerdidaConSubtipo(String subtipo) {
    if (modo == null) return;

    final Map<String, dynamic> prevState = _captureStateSnapshot();

    final String actor = _actorPrincipalActual(
      fallbackAtaque: 'Jugador generico ataque',
      fallbackDefensa: 'Jugador generico defensa',
    );

    final String? zonaActual = zonaTiro;
    final bool estabaEnAtaque = modo == 'ataque';

    setState(() {
      if (estabaEnAtaque) {
        perdidas++;
        modo = 'defensa';
      } else {
        recuperaciones++;
        modo = 'ataque';
      }
      mostrarContra = true;
      contraDebeCambiarModo = false;
      origenJugadaActual = 'normal';
    });

    _registrarEvento(
      tipo: 'perdida',
      resultado: estabaEnAtaque ? 'perdida' : 'recuperacion',
      actorPrincipal: actor,
      zonaTiroValor: zonaActual,
      detalle: subtipo,
      subtipo: subtipo,
      mantieneContexto: false,
      prevState: prevState,
    );

    _clearSelection(keepContra: true);
  }

  String _actorPrincipalActual({
    required String fallbackAtaque,
    required String fallbackDefensa,
  }) {
    final seleccionado = jugadorSeleccionado;

    if (seleccionado != null && seleccionado.toString().trim().isNotEmpty) {
      return seleccionado.toString();
    }

    return modo == 'ataque' ? fallbackAtaque : fallbackDefensa;
  }

  void _showLateralSheet(String lado) {
    if (!_lateralGestureEnabled || modo == null) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F1722),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Lateral $lado',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              _floatingOption('Lateral propio', () {
                Navigator.pop(context);
                _registrarLateral('propio', lado);
              }),
              _floatingOption('Lateral rival', () {
                Navigator.pop(context);
                _registrarLateral('rival', lado);
              }),
            ],
          ),
        );
      },
    );
  }

  void _registrarLateral(String resultado, String lado) {
    if (modo == null) return;

    final Map<String, dynamic> prevState = _captureStateSnapshot();

    final String actor = _actorPrincipalActual(
      fallbackAtaque: 'Jugador generico ataque',
      fallbackDefensa: 'Jugador generico defensa',
    );

    bool activaContra = false;
    bool mantiene = true;
    final String resultadoEvento = 'lateral_$resultado';
    final String subtipo = 'lateral_$lado';

    setState(() {
      if (modo == 'ataque' && resultado == 'propio') {
        mantiene = true;
      } else if (modo == 'ataque' && resultado == 'rival') {
        perdidas++;
        modo = 'defensa';
        activaContra = true;
        mantiene = false;
      } else if (modo == 'defensa' && resultado == 'propio') {
        recuperaciones++;
        modo = 'ataque';
        activaContra = true;
        mantiene = false;
      } else if (modo == 'defensa' && resultado == 'rival') {
        mantiene = true;
      }

      mostrarContra = activaContra;
      contraDebeCambiarModo = !activaContra;
      if (activaContra) contraDebeCambiarModo = false;
      if (!activaContra) origenJugadaActual = 'normal';
    });

    _registrarEvento(
      tipo: 'lateral',
      resultado: resultadoEvento,
      actorPrincipal: actor,
      detalle: lado,
      subtipo: subtipo,
      mantieneContexto: mantiene,
      prevState: prevState,
    );

    _clearSelection(keepContra: activaContra);
  }

  void _registrarFueraPorGesto() {
    final String? currentMode = modo;
    final String? currentGoalZone = zonaArco;

    if (!_fueraGestureEnabled ||
        currentMode == null ||
        currentGoalZone == null) {
      return;
    }

    final Map<String, dynamic> prevState = _captureStateSnapshot();
    final String modoAntesDelEvento = currentMode;

    final String actor = _resolvePrimaryActorForShot(
      eventMode: modoAntesDelEvento,
      allowGoalkeeperInAttack: true,
    );

    final bool esPenal = penalEnCurso;
    final bool esTanda = _isPenaltyShootout();

    if (esTanda) {
      _registrarEvento(
        tipo: 'penal_tanda',
        resultado: 'fuera',
        actorPrincipal: actor,
        zonaArcoValor: currentGoalZone,
        subtipo: 'tanda_penales',
        mantieneContexto: false,
        prevState: prevState,
        modoEvento: modoAntesDelEvento,
      );
      _registrarPenalTanda('fuera');
      return;
    }

    setState(() {
      if (esPenal) {
        penales++;
      }
      modo = modoAntesDelEvento == 'ataque' ? 'defensa' : 'ataque';
      mostrarContra = modoAntesDelEvento == 'defensa';
      contraDebeCambiarModo = false;
    });

    _registrarEvento(
      tipo: esPenal ? 'penal' : 'tiro',
      resultado: 'fuera',
      actorPrincipal: actor,
      zonaTiroValor: esPenal ? null : zonaTiro,
      zonaArcoValor: currentGoalZone,
      subtipo: esPenal ? 'penal_7m' : 'fuera_gesto',
      mantieneContexto: false,
      prevState: prevState,
      modoEvento: modoAntesDelEvento,
    );

    _clearSelection(keepContra: modoAntesDelEvento == 'defensa');
  }

  void _activarContra() {
    setState(() {
      // 🔥 Siempre invertir modo (clave)
      modo = modo == 'ataque' ? 'defensa' : 'ataque';

      mostrarContra = false;

      zonaTiro = null;
      zonaArco = null;

      jugadorSeleccionado = null;
      jugadorSeleccionadoId = null;

      // 🔥 marcar origen
      origenJugadaActual = 'contra';
    });
  }

  void _iniciarFlujoPenalNormal() {
    final String actor = _actorPrincipalActual(
      fallbackAtaque: 'Jugador generico ataque',
      fallbackDefensa: 'Arquero generico',
    );

    setState(() {
      penalEnCurso = true;
      actorPenalActual = actor;

      // penal arranca limpio
      zonaTiro = null;
      zonaArco = null;

      mostrarContra = false;
      origenJugadaActual = 'penal';
    });

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F1722),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                modo == 'ataque' ? 'Penal nuestro' : 'Penal rival',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 14),
              _floatingOption('Continuar', () {
                Navigator.pop(context);
              }),
            ],
          ),
        );
      },
    );
  }

  void _showNormalPenaltyResultSheet() {
    final String? currentModo = modo;
    final String? currentZonaArco = zonaArco;

    if (currentZonaArco == null || currentModo == null) return;

    final String actor = currentModo == 'defensa'
        ? _currentGoalkeeperActorName
        : _resolvePrimaryActorForShot(
            eventMode: currentModo,
            allowGoalkeeperInAttack: true,
          );

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F1722),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Penal → $currentZonaArco',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),

              _floatingOption('Gol', () async {
                final Map<String, dynamic> prevState = _captureStateSnapshot();
                final String modoAntesDelEvento = currentModo;
                final String actor = await _actorParaTiro(modoAntesDelEvento);

                setState(() {
                  penales++;

                  if (modoAntesDelEvento == 'ataque') {
                    golesSanFernando++;
                    modo = 'defensa';
                  } else {
                    golesRival++;
                    golesRecibidos++;
                    modo = 'ataque';
                  }

                  mostrarContra = false;
                  contraDebeCambiarModo = true;
                });

                _registrarEvento(
                  tipo: 'penal',
                  resultado: 'gol',
                  actorPrincipal: actor,
                  actorPrincipalId: modoAntesDelEvento == 'ataque'
                      ? jugadorSeleccionadoId
                      : _getCurrentGoalkeeperProfile()?.playerId,
                  zonaArcoValor: currentZonaArco,
                  subtipo: 'penal_7m',
                  mantieneContexto: false,
                  prevState: prevState,
                  modoEvento: modoAntesDelEvento,
                );

                _clearSelection();
                Navigator.pop(context);
              }),

              _floatingOption('Atajado', () async {
                final Map<String, dynamic> prevState = _captureStateSnapshot();
                final String modoAntesDelEvento = currentModo;
                final String actor = await _actorParaTiro(modoAntesDelEvento);

                setState(() {
                  penales++;

                  if (modoAntesDelEvento == 'defensa') {
                    atajadas++;
                  }

                  // 🔥 NUEVA LoGICA:
                  // no cambia modo automáticamente
                  // solo habilita contra
                  mostrarContra = true;
                  contraDebeCambiarModo = true;
                });

                _registrarEvento(
                  tipo: 'penal',
                  resultado: 'atajado',
                  actorPrincipal: actor,
                  actorPrincipalId: modoAntesDelEvento == 'ataque'
                      ? jugadorSeleccionadoId
                      : _getCurrentGoalkeeperProfile()?.playerId,
                  zonaArcoValor: currentZonaArco,
                  subtipo: 'penal_7m',
                  mantieneContexto: true,
                  prevState: prevState,
                  modoEvento: modoAntesDelEvento,
                );

                _clearSelection(keepContra: true);
                Navigator.pop(context);
              }),
              _floatingOption('Palo', () async {
                final Map<String, dynamic> prevState = _captureStateSnapshot();
                final String modoAntesDelEvento = currentModo;
                final String actor = await _actorParaTiro(modoAntesDelEvento);

                setState(() {
                  penales++;

                  if (modoAntesDelEvento == 'defensa') {
                    atajadas++;
                  }

                  // 🔥 NUEVA LoGICA:
                  // no cambia modo automáticamente
                  // solo habilita contra
                  mostrarContra = true;
                  contraDebeCambiarModo = true;
                });

                _registrarEvento(
                  tipo: 'penal',
                  resultado: 'palo',
                  actorPrincipal: actor,
                  actorPrincipalId: modoAntesDelEvento == 'ataque'
                      ? jugadorSeleccionadoId
                      : _getCurrentGoalkeeperProfile()?.playerId,
                  zonaArcoValor: currentZonaArco,
                  subtipo: 'penal_7m',
                  mantieneContexto: true,
                  prevState: prevState,
                  modoEvento: modoAntesDelEvento,
                );

                _clearSelection(keepContra: true);
                Navigator.pop(context);
              }),
              _floatingOption('Fuera', () async {
                final Map<String, dynamic> prevState = _captureStateSnapshot();
                final String modoAntesDelEvento = currentModo;
                final String actor = await _actorParaTiro(modoAntesDelEvento);

                setState(() {
                  penales++;

                  if (modoAntesDelEvento == 'ataque') {
                    modo = 'defensa';
                    mostrarContra = false;
                  } else {
                    modo = 'ataque';
                    mostrarContra = true;
                    contraDebeCambiarModo = false;
                  }
                });

                _registrarEvento(
                  tipo: 'penal',
                  resultado: 'fuera',
                  actorPrincipal: actor,
                  actorPrincipalId: modoAntesDelEvento == 'ataque'
                      ? jugadorSeleccionadoId
                      : _getCurrentGoalkeeperProfile()?.playerId,
                  zonaArcoValor: currentZonaArco,
                  subtipo: 'penal_7m',
                  mantieneContexto: false,
                  prevState: prevState,
                  modoEvento: modoAntesDelEvento,
                );

                _clearSelection(keepContra: modoAntesDelEvento == 'defensa');
                Navigator.pop(context);
              }),
            ],
          ),
        );
      },
    );
  }

  void _showPenaltyShootoutResultSheet() {
    final String? currentModo = modo;
    final String? currentZonaArco = zonaArco;

    if (currentZonaArco == null || currentModo == null) return;

    final String actor = currentModo == 'defensa'
        ? _currentGoalkeeperActorName
        : _resolvePrimaryActorForShot(
            eventMode: currentModo,
            allowGoalkeeperInAttack: true,
          );

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F1722),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Penal → $currentZonaArco',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),

              _floatingOption('Gol', () async {
                final Map<String, dynamic> prevState = _captureStateSnapshot();
                final String modoAntesDelEvento = currentModo;
                final String actor = await _actorParaTiro(modoAntesDelEvento);

                _registrarEvento(
                  tipo: 'penal_tanda',
                  resultado: 'gol',
                  actorPrincipal: actor,
                  zonaArcoValor: currentZonaArco,
                  subtipo: 'tanda_penales',
                  mantieneContexto: false,
                  prevState: prevState,
                  modoEvento: modoAntesDelEvento,
                );

                _registrarPenalTanda('gol');
                Navigator.pop(context);
              }),

              _floatingOption('Atajado', () async {
                final Map<String, dynamic> prevState = _captureStateSnapshot();
                final String modoAntesDelEvento = currentModo;
                final String actor = await _actorParaTiro(modoAntesDelEvento);

                _registrarEvento(
                  tipo: 'penal_tanda',
                  resultado: 'atajado',
                  actorPrincipal: actor,
                  zonaArcoValor: currentZonaArco,
                  subtipo: 'tanda_penales',
                  mantieneContexto: false,
                  prevState: prevState,
                  modoEvento: modoAntesDelEvento,
                );

                _registrarPenalTanda('atajado');
                Navigator.pop(context);
              }),

              _floatingOption('Fuera', () async {
                final Map<String, dynamic> prevState = _captureStateSnapshot();
                final String modoAntesDelEvento = currentModo;
                final String actor = await _actorParaTiro(modoAntesDelEvento);

                _registrarEvento(
                  tipo: 'penal_tanda',
                  resultado: 'fuera',
                  actorPrincipal: actor,
                  zonaArcoValor: currentZonaArco,
                  subtipo: 'tanda_penales',
                  mantieneContexto: false,
                  prevState: prevState,
                  modoEvento: modoAntesDelEvento,
                );

                _registrarPenalTanda('fuera');
                Navigator.pop(context);
              }),
              _floatingOption('Palo', () async {
                final Map<String, dynamic> prevState = _captureStateSnapshot();
                final String modoAntesDelEvento = currentModo;
                final String actor = await _actorParaTiro(modoAntesDelEvento);

                _registrarEvento(
                  tipo: 'penal_tanda',
                  resultado: 'palo',
                  actorPrincipal: actor,
                  zonaArcoValor: currentZonaArco,
                  subtipo: 'tanda_penales',
                  mantieneContexto: false,
                  prevState: prevState,
                  modoEvento: modoAntesDelEvento,
                );

                _registrarPenalTanda('palo');
                Navigator.pop(context);
              }),
            ],
          ),
        );
      },
    );
  }

  void _registrarPenalTanda(String resultado) {
    final String? currentModo = modo;
    if (currentModo == null) return;

    final String modoAntesDelEvento = currentModo;

    setState(() {
      if (modoAntesDelEvento == 'ataque') {
        penalesIntentadosSanFernando++;
        if (resultado == 'gol') {
          penalesConvertidosSanFernando++;
        }
      } else {
        penalesIntentadosRival++;
        if (resultado == 'gol') {
          penalesConvertidosRival++;
        } else if (resultado == 'atajado') {
          atajadas++;
        }
      }

      zonaTiro = null;
      zonaArco = null;
      penalEnCurso = false;
      actorPenalActual = null;
      mostrarContra = false;
      origenJugadaActual = 'normal';
      contraDebeCambiarModo = true;
    });

    _alternarModoPenales();
    _evaluarFinPenales();
  }

  void _alternarModoPenales() {
    setState(() {
      modo = modo == 'ataque' ? 'defensa' : 'ataque';
    });
  }

  void _evaluarFinPenales() {
    final int intentosSF = penalesIntentadosSanFernando;
    final int intentosRival = penalesIntentadosRival;
    final int convertidosSF = penalesConvertidosSanFernando;
    final int convertidosRival = penalesConvertidosRival;

    if (intentosSF >= 5 && intentosRival >= 5 && intentosSF == intentosRival) {
      if (convertidosSF != convertidosRival) {
        _finalizarPartido();
        return;
      }
    }

    if (intentosSF > 5 && intentosRival > 5 && intentosSF == intentosRival) {
      if (convertidosSF != convertidosRival) {
        _finalizarPartido();
      }
    }
  }

  void _showSancionTargetSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F1722),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '¿A quien queres sancionar?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              _floatingOption('Jugador propio', () {
                Navigator.pop(context);
                _showSancionSheet('Jugador propio');
              }),
              _floatingOption('Jugador rival', () {
                Navigator.pop(context);
                _showSancionSheet('Jugador rival');
              }),
              _floatingOption('Arquero propio', () {
                Navigator.pop(context);
                _showSancionSheet('Arquero propio');
              }),
              _floatingOption('Arquero rival', () {
                Navigator.pop(context);
                _showSancionSheet('Arquero rival');
              }),
              _floatingOption('DT propio', () {
                Navigator.pop(context);
                _showSancionSheet('DT propio');
              }),
              _floatingOption('DT rival', () {
                Navigator.pop(context);
                _showSancionSheet('DT rival');
              }),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showFieldPlayerSelector() async {
    final jugadores = _jugadoresConvocados
        .where((p) => !p.esArquero && !p.esCuerpoTecnico)
        .toList();

    final seleccionado = await showModalBottomSheet<PlayerProfile>(
      context: context,
      backgroundColor: const Color(0xFF0F1722),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Seleccionar jugador',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              if (jugadores.isEmpty)
                const Text(
                  'No hay jugadores de campo convocados',
                  style: TextStyle(color: Colors.white70),
                )
              else
                ...jugadores.map((p) {
                  final dorsal = p.numeroPreferido;
                  final nombre = '${p.apellido}, ${p.nombre}'.trim();

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFF182338),
                      child: Text(
                        dorsal == null || dorsal.isEmpty ? '-' : dorsal,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(
                      nombre,
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: const Text(
                      'Jugador de campo',
                      style: TextStyle(color: Color(0xFFAAB4C3)),
                    ),
                    onTap: () => Navigator.pop(context, p),
                  );
                }),
            ],
          ),
        );
      },
    );

    if (seleccionado == null) return;

    setState(() {
      final dorsal = seleccionado.numeroPreferido;
      final nombre = '${seleccionado.apellido}, ${seleccionado.nombre}'.trim();

      jugadorSeleccionado = dorsal == null || dorsal.isEmpty
          ? nombre
          : '$dorsal · $nombre';
    });
  }

  Future<void> _showGoalkeeperSelectorSheet({
    String title = 'Seleccionar arquero',
    VoidCallback? onAfterSelected,
  }) async {
    final arqueros = _availableGoalkeepersForMatch();

    await showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F1722),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              if (arqueros.isEmpty)
                const Text(
                  'No hay arqueros convocados para este partido',
                  style: TextStyle(color: Colors.white70),
                )
              else
                ...arqueros.map((gk) {
                  return _floatingOption(gk.displayName, () {
                    Navigator.pop(context);
                    setState(() {
                      currentGoalkeeperNumber = gk.numeroPreferido;
                    });
                    _persistLiveMatch();
                    onAfterSelected?.call();
                  });
                }),
            ],
          ),
        );
      },
    );
  }

  Future<void> _selectGoalkeeperForCurrentPeriod({
    required VoidCallback onAfterSelect,
    String title = 'Seleccionar arquero inicial',
  }) async {
    await _showGoalkeeperSelectorSheet(
      title: title,
      onAfterSelected: onAfterSelect,
    );
  }

  void _showSancionSheet(String actor) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F1722),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Sancion para $actor',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              _floatingOption('Exclusion 2 min', () {
                final Map<String, dynamic> prevState = _captureStateSnapshot();

                setState(() {
                  exclusiones2Min++;
                });

                _registrarEvento(
                  tipo: 'sancion',
                  resultado: 'exclusion_2_min',
                  actorPrincipal: actor,
                  detalle: 'Exclusion de 2 minutos',
                  subtipo: 'disciplina',
                  mantieneContexto: true,
                  prevState: prevState,
                );

                _clearSelection();
                Navigator.pop(context);
              }),
              _floatingOption('Tarjeta amarilla', () {
                final Map<String, dynamic> prevState = _captureStateSnapshot();

                setState(() {
                  amarillas++;
                });

                _registrarEvento(
                  tipo: 'sancion',
                  resultado: 'tarjeta_amarilla',
                  actorPrincipal: actor,
                  detalle: 'Tarjeta amarilla',
                  subtipo: 'disciplina',
                  mantieneContexto: true,
                  prevState: prevState,
                );

                _clearSelection();
                Navigator.pop(context);
              }),
              _floatingOption('Tarjeta roja', () {
                final Map<String, dynamic> prevState = _captureStateSnapshot();

                setState(() {
                  rojas++;
                });

                _registrarEvento(
                  tipo: 'sancion',
                  resultado: 'tarjeta_roja',
                  actorPrincipal: actor,
                  detalle: 'Tarjeta roja',
                  subtipo: 'disciplina',
                  mantieneContexto: true,
                  prevState: prevState,
                );

                _clearSelection();
                Navigator.pop(context);
              }),
            ],
          ),
        );
      },
    );
  }

  /// ===============================
  /// RESULTADO DE TIRO NORMAL
  /// Incluye contra directa del arquero.
  /// ===============================
  void _showZoneActionSheet() {
    if (zonaArco == null || modo == null) return;

    final String currentMode = modo!;
    final bool esContraDirecta = _esContraArqueroDirecta;

    final String actor = esContraDirecta
        ? _currentGoalkeeperActorName
        : _resolvePrimaryActorForShot(
            eventMode: currentMode,
            allowGoalkeeperInAttack: true,
          );

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F1722),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                esContraDirecta
                    ? 'Contra directa arquero → $zonaArco'
                    : 'Resultado → $zonaArco',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),

              _floatingOption('Gol', () {
                Navigator.pop(context);
                _registrarTiroNormal(resultado: 'gol', actorForzado: actor);
              }),

              _floatingOption('Atajado', () {
                Navigator.pop(context);
                _registrarTiroNormal(resultado: 'atajado', actorForzado: actor);
              }),

              _floatingOption('Palo', () {
                Navigator.pop(context);
                _registrarTiroNormal(resultado: 'palo', actorForzado: actor);
              }),

              _floatingOption('Fuera', () {
                Navigator.pop(context);
                _registrarTiroNormal(resultado: 'fuera', actorForzado: actor);
              }),
            ],
          ),
        );
      },
    );
  }

  Future<String> _actorParaTiro(String modoEvento) async {
    if (modoEvento == 'ataque' &&
        jugadorSeleccionado != null &&
        jugadorSeleccionado!.trim().isNotEmpty) {
      return jugadorSeleccionado!;
    }

    return _resolvePrimaryActorForShot(
      eventMode: modoEvento,
      allowGoalkeeperInAttack: true,
    );
  }

  /// ===============================
  /// REGISTRAR TIRO NORMAL
  /// Centraliza el tiro de cancha.
  /// Si es contra directa del arquero:
  /// - no exige zona de tiro
  /// - usa actor arquero
  /// - guarda zonaTiro = Contra directa arquero
  /// ===============================
  void _registrarTiroNormal({required String resultado, String? actorForzado}) {
    final String? currentMode = modo;
    final String? currentZonaArco = zonaArco;

    if (currentMode == null || currentZonaArco == null) return;

    final bool esContraDirecta = _esContraArqueroDirecta;

    final Map<String, dynamic> prevState = _captureStateSnapshot();
    final String modoAntesDelEvento = currentMode;

    final String? zonaTiroEvento = esContraDirecta
        ? 'Contra directa arquero'
        : zonaTiro;

    /// En ataque, si hay jugadores de campo convocados,
    /// el jugador se pide DESPUÉS de elegir el resultado.
    if (modoAntesDelEvento == 'ataque' &&
        !esContraDirecta &&
        _jugadoresCampoConvocados.isNotEmpty) {
      _tiroPendienteResultado = resultado;
      _tiroPendienteModo = modoAntesDelEvento;
      _tiroPendienteZonaTiro = zonaTiroEvento;
      _tiroPendienteZonaArco = currentZonaArco;
      _tiroPendienteMantieneContexto = false;
      _tiroPendientePrevState = prevState;

      setState(() {
        jugadorSeleccionado = null;
        jugadorSeleccionadoId = null;
        mostrarSelectorLateralJugador = true;
      });

      return;
    }

    final String actor =
        actorForzado ??
        (esContraDirecta
            ? _currentGoalkeeperActorName
            : _resolvePrimaryActorForShot(
                eventMode: modoAntesDelEvento,
                allowGoalkeeperInAttack: true,
              ));

    _registrarTiroNormalResuelto(
      resultado: resultado,
      modoAntesDelEvento: modoAntesDelEvento,
      actor: actor,
      zonaTiroEvento: zonaTiroEvento,
      zonaArcoEvento: currentZonaArco,
      mantieneContexto: false,
      prevState: prevState,
    );
  }

  /// ===============================
  /// TIRO NORMAL RESUELTO
  /// Actualiza marcador, contexto y registra evento.
  /// Incluye:
  /// - gol
  /// - atajado
  /// - palo
  /// - fuera
  /// - contra directa arquero
  /// ===============================
  void _registrarTiroNormalResuelto({
    required String resultado,
    required String modoAntesDelEvento,
    required String actor,
    required String? zonaTiroEvento,
    required String? zonaArcoEvento,
    required bool mantieneContexto,
    required Map<String, dynamic> prevState,
  }) {
    final bool esContraDirectaArquero =
        origenJugadaActual == 'contra' &&
        (zonaTiroEvento == 'Contra directa arquero');

    setState(() {
      if (resultado == 'gol') {
        if (modoAntesDelEvento == 'ataque') {
          golesSanFernando++;
          modo = 'defensa';
        } else {
          golesRival++;
          golesRecibidos++;
          modo = 'ataque';
        }

        mostrarContra = false;
        contraDebeCambiarModo = true;
      }

      if (resultado == 'atajado') {
        if (modoAntesDelEvento == 'defensa') {
          atajadas++;
        }

        mostrarContra = true;
        contraDebeCambiarModo = true;
      }

      if (resultado == 'palo') {
        mostrarContra = true;
        contraDebeCambiarModo = true;
      }

      if (resultado == 'fuera') {
        if (modoAntesDelEvento == 'ataque') {
          modo = 'defensa';
          mostrarContra = false;
        } else {
          modo = 'ataque';
          mostrarContra = true;
          contraDebeCambiarModo = false;
        }
      }

      mostrarSelectorLateralJugador = false;
    });

    _registrarEvento(
      tipo: 'tiro',
      resultado: resultado,
      actorPrincipal: actor,
      actorPrincipalId: esContraDirectaArquero
          ? _getCurrentGoalkeeperProfile()?.playerId
          : modoAntesDelEvento == 'ataque'
          ? jugadorSeleccionadoId
          : _getCurrentGoalkeeperProfile()?.playerId,
      zonaTiroValor: zonaTiroEvento,
      zonaArcoValor: zonaArcoEvento,
      mantieneContexto: mantieneContexto,
      prevState: prevState,
      modoEvento: modoAntesDelEvento,
      esContraDirectaArquero: esContraDirectaArquero,
    );
    _clearSelection(
      keepContra:
          resultado == 'atajado' ||
          resultado == 'palo' ||
          modoAntesDelEvento == 'defensa',
    );
  }

  void _seleccionarJugadorParaTiroPendiente(PlayerProfile jugador) {
    final dorsal = jugador.numeroPreferido ?? '-';
    final nombre = jugador.nombreLista;
    final actor = '$dorsal · $nombre';

    final resultado = _tiroPendienteResultado;
    final modoPendiente = _tiroPendienteModo;
    final prevState = _tiroPendientePrevState;

    if (resultado == null || modoPendiente == null || prevState == null) {
      setState(() {
        mostrarSelectorLateralJugador = false;
      });
      return;
    }

    jugadorSeleccionado = actor;
    jugadorSeleccionadoId = jugador.playerId;

    _registrarTiroNormalResuelto(
      resultado: resultado,
      modoAntesDelEvento: modoPendiente,
      actor: actor,
      zonaTiroEvento: _tiroPendienteZonaTiro,
      zonaArcoEvento: _tiroPendienteZonaArco,
      mantieneContexto: _tiroPendienteMantieneContexto,
      prevState: prevState,
    );

    // 🔥 LIMPIEZA TOTAL
    _tiroPendienteResultado = null;
    _tiroPendienteModo = null;
    _tiroPendienteZonaTiro = null;
    _tiroPendienteZonaArco = null;
    _tiroPendientePrevState = null;

    setState(() {
      mostrarSelectorLateralJugador = false;
    });
  }

  Widget _floatingOption(String text, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
            color: const Color(0xFF182338),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _clearSelection({bool keepContra = false}) {
    setState(() {
      zonaTiro = null;
      zonaArco = null;
      penalEnCurso = false;
      actorPenalActual = null;

      mostrarSelectorLateralJugador = false; // 🔥 CLAVE

      if (!keepContra) {
        mostrarContra = false;
        origenJugadaActual = 'normal';
        contraDebeCambiarModo = true;
      }
    });
  }

  Widget _buildEventButton({
    required String text,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: onTap == null ? 0.45 : 1,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFF182338).withOpacity(0.75),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.04)),
          ),
          child: Center(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPrimaryAction({
    required String text,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4F8CFF),
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 17),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget _buildCenteredOverlay(String text) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF1C2B44).withOpacity(0.96),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  String _getActionText() {
    switch (estadoPartido) {
      case 'no_iniciado':
        return 'Iniciar 1T';
      case 'primer_tiempo':
        return 'Finalizar 1T';
      case 'entretiempo':
        return 'Iniciar 2T';
      case 'segundo_tiempo':
        return 'Finalizar partido';
      case 'primer_tiempo_alargue':
        return 'Finalizar 1T alargue';
      case 'entretiempo_alargue':
        return 'Iniciar 2T alargue';
      case 'segundo_tiempo_alargue':
        return 'Finalizar partido';
      case 'penales':
        return 'Finalizar partido';
      case 'finalizado':
        return 'Partido finalizado';
      default:
        return 'Continuar';
    }
  }

  void _handleMainAction() {
    if (estadoPartido == 'finalizado') {
      _goBack();
      return;
    }

    if (estadoPartido == 'no_iniciado') {
      _selectGoalkeeperForCurrentPeriod(
        title: 'Seleccionar arquero inicial (1T)',
        onAfterSelect: () {
          setState(() {
            estadoPartido = 'primer_tiempo';
            modo = null;
          });
          _persistLiveMatch();
        },
      );
      return;
    }

    if (estadoPartido == 'primer_tiempo') {
      setState(() {
        estadoPartido = 'entretiempo';
        modo = null;
      });
      _persistLiveMatch();
      return;
    }

    if (estadoPartido == 'entretiempo') {
      _selectGoalkeeperForCurrentPeriod(
        title: 'Seleccionar arquero inicial (2T)',
        onAfterSelect: () {
          setState(() {
            estadoPartido = 'segundo_tiempo';
            if (modoInicioPrimerTiempo != null) {
              modo = _invertirModo(modoInicioPrimerTiempo!);
            }
          });
          _persistLiveMatch();
        },
      );
      return;
    }

    if (estadoPartido == 'segundo_tiempo') {
      if (_isDraw()) {
        _showEndOptions();
      } else {
        _finalizarPartido();
      }
      return;
    }

    if (estadoPartido == 'primer_tiempo_alargue') {
      setState(() {
        estadoPartido = 'entretiempo_alargue';
        modo = null;
      });
      _persistLiveMatch();
      return;
    }

    if (estadoPartido == 'entretiempo_alargue') {
      _selectGoalkeeperForCurrentPeriod(
        title: 'Seleccionar arquero inicial (2T alargue)',
        onAfterSelect: () {
          setState(() {
            estadoPartido = 'segundo_tiempo_alargue';
            if (modoInicioPrimerTiempoAlargue != null) {
              modo = _invertirModo(modoInicioPrimerTiempoAlargue!);
            }
          });
          _persistLiveMatch();
        },
      );
      return;
    }

    if (estadoPartido == 'segundo_tiempo_alargue') {
      if (_isDraw()) {
        _showPenalesOrEnd();
      } else {
        _finalizarPartido();
      }
      return;
    }

    if (estadoPartido == 'penales') {
      _finalizarPartido();
    }
  }

  void _showEndOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F1722),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _sheetButton('Ir a alargue', () {
                Navigator.pop(context);
                _selectGoalkeeperForCurrentPeriod(
                  title: 'Seleccionar arquero inicial (1T alargue)',
                  onAfterSelect: () {
                    setState(() {
                      estadoPartido = 'primer_tiempo_alargue';
                      modo = null;
                    });
                    _persistLiveMatch();
                  },
                );
              }),
              const SizedBox(height: 10),
              _sheetButton('Ir a penales', () {
                Navigator.pop(context);
                setState(() {
                  estadoPartido = 'penales';
                  modo = 'defensa';
                  zonaTiro = null;
                  zonaArco = null;
                  penalEnCurso = false;
                  actorPenalActual = null;
                  mostrarContra = false;
                  origenJugadaActual = 'normal';
                  contraDebeCambiarModo = true;
                });
                _persistLiveMatch();
              }),
              const SizedBox(height: 10),
              _sheetButton('Finalizar partido', () {
                Navigator.pop(context);
                _finalizarPartido();
              }),
            ],
          ),
        );
      },
    );
  }

  void _showPenalesOrEnd() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F1722),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _sheetButton('Ir a penales', () {
                Navigator.pop(context);
                setState(() {
                  estadoPartido = 'penales';
                  modo = 'defensa';
                  zonaTiro = null;
                  zonaArco = null;
                  penalEnCurso = false;
                  actorPenalActual = null;
                  mostrarContra = false;
                  origenJugadaActual = 'normal';
                  contraDebeCambiarModo = true;
                });
                _persistLiveMatch();
              }),
              const SizedBox(height: 10),
              _sheetButton('Finalizar partido', () {
                Navigator.pop(context);
                _finalizarPartido();
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _sheetButton(String text, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4F8CFF),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(text),
      ),
    );
  }

  Future<void> _finalizarPartido() async {
    setState(() {
      estadoPartido = 'finalizado';
      modo = null;
      zonaTiro = null;
      zonaArco = null;
      penalEnCurso = false;
      actorPenalActual = null;
      mostrarContra = false;
      origenJugadaActual = 'normal';
      contraDebeCambiarModo = true;
    });

    await _persistLiveMatch();
    await _archiveFinishedMatchIfNeeded();

    if (!mounted) return;
    _goBack();
  }

  void _goBack() {
    Navigator.pop(context, {
      'estadoPartido': estadoPartido,
      'golesSanFernando': golesSanFernando,
      'golesRival': golesRival,
      'golesRecibidos': golesRecibidos,
      'atajadas': atajadas,
      'penales': penales,
      'exclusiones2Min': exclusiones2Min,
      'amarillas': amarillas,
      'rojas': rojas,
      'perdidas': perdidas,
      'recuperaciones': recuperaciones,
      'penalesConvertidosSanFernando': penalesConvertidosSanFernando,
      'penalesConvertidosRival': penalesConvertidosRival,
      'eventos': eventos,
      'modoActual': modo,
      'modoInicioPrimerTiempo': modoInicioPrimerTiempo,
      'modoInicioPrimerTiempoAlargue': modoInicioPrimerTiempoAlargue,
      'currentGoalkeeperNumber': currentGoalkeeperNumber,
      'partidoFinalizado': estadoPartido == 'finalizado',
    });
  }

  void _confirmarFinalizarPartido() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF0F1722),
        title: const Text(
          'Finalizar partido',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          '¿Seguro que queres finalizar el partido?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _finalizarPartido();
            },
            child: const Text('Finalizar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _deshacerUltimoEvento() {
    if (eventos.isEmpty || gameEvents.isEmpty) return;

    int index = eventos.length - 1;

    while (index >= 0) {
      final evento = eventos[index];
      final tipo = (evento['tipo'] ?? '').toString();
      final prevState = evento['prevState'];

      final bool esSancion = tipo == 'sancion';
      final bool esCorreccionSancion = tipo == 'correccion_sancion';
      final bool tieneSnapshotValido = prevState is Map;

      if (esSancion || esCorreccionSancion || !tieneSnapshotValido) {
        index--;
        continue;
      }

      break;
    }

    if (index < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay eventos de juego para deshacer')),
      );
      return;
    }

    final eventoADeshacer = eventos[index];
    final prevState = Map<String, dynamic>.from(
      eventoADeshacer['prevState'] as Map,
    );

    final int id = (eventoADeshacer['id'] as int?) ?? -1;

    setState(() {
      eventos.removeAt(index);
      gameEvents.removeWhere((e) => e.id == id);

      _restoreStateSnapshot(prevState);

      zonaTiro = null;
      zonaArco = null;
      penalEnCurso = false;
      actorPenalActual = null;
      mostrarContra = false;
      origenJugadaActual = 'normal';
      contraDebeCambiarModo = true;
    });
  }

  void _showUndoSanctionSheet() {
    final List<_UndoSanctionOption> opciones = [];

    if (exclusiones2Min > 0) {
      opciones.add(
        const _UndoSanctionOption(
          label: 'Quitar exclusion 2 min',
          resultado: 'exclusion_2_min',
        ),
      );
    }

    if (amarillas > 0) {
      opciones.add(
        const _UndoSanctionOption(
          label: 'Quitar tarjeta amarilla',
          resultado: 'tarjeta_amarilla',
        ),
      );
    }

    if (rojas > 0) {
      opciones.add(
        const _UndoSanctionOption(
          label: 'Quitar tarjeta roja',
          resultado: 'tarjeta_roja',
        ),
      );
    }

    if (opciones.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay sanciones para deshacer')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F1722),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Deshacer sancion',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              for (final opcion in opciones)
                _floatingOption(opcion.label, () {
                  Navigator.pop(context);
                  _revertirSancion(opcion.resultado);
                }),
            ],
          ),
        );
      },
    );
  }

  void _revertirSancion(String tipoSancion) {
    final Map<String, dynamic> prevState = _captureStateSnapshot();

    bool huboCambio = false;

    setState(() {
      if (tipoSancion == 'exclusion_2_min' && exclusiones2Min > 0) {
        exclusiones2Min--;
        huboCambio = true;
      } else if (tipoSancion == 'tarjeta_amarilla' && amarillas > 0) {
        amarillas--;
        huboCambio = true;
      } else if (tipoSancion == 'tarjeta_roja' && rojas > 0) {
        rojas--;
        huboCambio = true;
      }
    });

    if (!huboCambio) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay una sancion de ese tipo para revertir'),
        ),
      );
      return;
    }

    _registrarEvento(
      tipo: 'correccion_sancion',
      resultado: tipoSancion,
      actorPrincipal: 'Correccion manual',
      detalle: 'Se revierte sancion',
      subtipo: 'undo_sancion',
      mantieneContexto: true,
      prevState: prevState,
    );
  }
}

///=======================
///=======================
///heatmap de eventos, estadísticas detalladas por jugador, exportacion de datos, etc.
///=======================
//=======================

class HeatmapPainter extends CustomPainter {
  final List<GameEvent> events;

  HeatmapPainter(this.events);

  final Random _random = Random(1);

  @override
  void paint(Canvas canvas, Size size) {
    for (final e in events) {
      if (!e.isShotLike) continue;
      if (e.zonaArco == null) continue;

      final Offset center = _getZoneCenter(e.zonaArco!, size);
      final int repetitions = e.resultado == 'gol' ? 5 : 4;

      for (int i = 0; i < repetitions; i++) {
        final double dx = center.dx + (_random.nextDouble() * 10 - 5);
        final double dy = center.dy + (_random.nextDouble() * 10 - 5);

        final paint = Paint()
          ..color = _colorByResult(e.resultado)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);

        canvas.drawCircle(Offset(dx, dy), 22, paint);
      }
    }
  }

  Offset _getZoneCenter(String zone, Size size) {
    final double w = size.width;
    final double h = size.height;

    switch (zone) {
      case 'AI':
        return Offset(w * 0.2, h * 0.2);
      case 'AC':
        return Offset(w * 0.5, h * 0.2);
      case 'AD':
        return Offset(w * 0.8, h * 0.2);
      case 'CI':
        return Offset(w * 0.2, h * 0.5);
      case 'CC':
        return Offset(w * 0.5, h * 0.5);
      case 'CD':
        return Offset(w * 0.8, h * 0.5);
      case 'BI':
        return Offset(w * 0.2, h * 0.8);
      case 'BC':
        return Offset(w * 0.5, h * 0.8);
      case 'BD':
        return Offset(w * 0.8, h * 0.8);
      default:
        return Offset(w * 0.5, h * 0.5);
    }
  }

  Color _colorByResult(String? result) {
    switch (result) {
      case 'gol':
        return Colors.red.withOpacity(0.6);
      case 'atajado':
        return Colors.green.withOpacity(0.6);
      case 'fuera':
      case 'desvio':
        return Colors.yellow.withOpacity(0.55);
      default:
        return Colors.white.withOpacity(0.3);
    }
  }

  @override
  bool shouldRepaint(covariant HeatmapPainter oldDelegate) {
    return oldDelegate.events != events;
  }
}

///===============================
///===============================
/// HISTORIAL
///==============================
///===============================

class HistorialScreen extends StatefulWidget {
  final String temporada;
  final String competencia;
  final String torneo;
  final String categoria;
  final String institutionName;
  final String? institutionId;
  final String? institutionShieldPath;

  const HistorialScreen({
    super.key,
    required this.temporada,
    required this.competencia,
    required this.torneo,
    required this.categoria,
    required this.institutionName,
    this.institutionId,
    this.institutionShieldPath,
  });

  @override
  State<HistorialScreen> createState() => _HistorialScreenState();
}

class _HistorialScreenState extends State<HistorialScreen> {
  static const String _finishedMatchesStorageKey =
      'finished_matches_history_v1';

  List<Map<String, dynamic>> _todos = [];
  List<Map<String, dynamic>> _filtrados = [];

  String _categoriaSeleccionada = 'Todas';
  String _torneoSeleccionado = 'Todos';
  String _busqueda = '';

  int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value.trim()) ?? 0;
    return 0;
  }

  DateTime _parseFechaPartido(dynamic value) {
    final raw = (value ?? '').toString().trim();

    final parts = raw.split('/');
    if (parts.length != 2) return DateTime(2000);

    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);

    if (day == null || month == null) return DateTime(2000);

    return DateTime(2026, month, day);
  }

  @override
  void initState() {
    super.initState();
    _cargarHistorial();
  }

  Future<void> _cargarHistorial() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_finishedMatchesStorageKey);

    final List<Map<String, dynamic>> items = [];

    if (raw != null && raw.isNotEmpty) {
      final decoded = jsonDecode(raw) as List<dynamic>;

      for (final item in decoded) {
        if (item is! Map) continue;

        final map = Map<String, dynamic>.from(item);
        final partido = Map<String, dynamic>.from(
          (map['partido'] as Map?)?.cast<String, dynamic>() ??
              <String, dynamic>{},
        );

        items.add({
          ...partido,
          'archivedAt': map['archivedAt'],
          'matchIdentity': map['matchIdentity'],
          'golesSanFernando':
              map['golesSanFernando'] ?? partido['golesSanFernando'] ?? 0,
          'golesRival': map['golesRival'] ?? partido['golesRival'] ?? 0,
          'golesRecibidos':
              map['golesRecibidos'] ?? partido['golesRecibidos'] ?? 0,
          'atajadas': map['atajadas'] ?? partido['atajadas'] ?? 0,
          'penales': map['penales'] ?? partido['penales'] ?? 0,
          'exclusiones2Min':
              map['exclusiones2Min'] ?? partido['exclusiones2Min'] ?? 0,
          'amarillas': map['amarillas'] ?? partido['amarillas'] ?? 0,
          'rojas': map['rojas'] ?? partido['rojas'] ?? 0,
          'perdidas': map['perdidas'] ?? partido['perdidas'] ?? 0,
          'recuperaciones':
              map['recuperaciones'] ?? partido['recuperaciones'] ?? 0,
          'eventos': map['eventos'] ?? partido['eventos'] ?? <dynamic>[],
          'estado': 'Finalizado',
          'estadoPartido': 'finalizado',
        });
      }

      items.sort((a, b) {
        final fechaNumeroA = _toInt(a['fechaNumero']);
        final fechaNumeroB = _toInt(b['fechaNumero']);

        if (fechaNumeroA != fechaNumeroB) {
          return fechaNumeroB.compareTo(fechaNumeroA);
        }

        final fechaA = _parseFechaPartido(a['fecha']);
        final fechaB = _parseFechaPartido(b['fecha']);

        if (fechaA != fechaB) {
          return fechaB.compareTo(fechaA);
        }

        final archivedA = DateTime.tryParse((a['archivedAt'] ?? '').toString());
        final archivedB = DateTime.tryParse((b['archivedAt'] ?? '').toString());

        if (archivedA == null && archivedB == null) return 0;
        if (archivedA == null) return 1;
        if (archivedB == null) return -1;

        return archivedB.compareTo(archivedA);
      });
    }

    if (!mounted) return;

    setState(() {
      _todos = items;
      _aplicarFiltros();
    });
  }

  ActiveContext get _activeContext {
    return ActiveContext(
      hasInstitution: true,
      institutionName: widget.institutionName,
      institutionId: widget.institutionId,
      season: widget.temporada,
      competition: widget.competencia,
      tournament: widget.torneo,
      category: widget.categoria,
    );
  }

  bool _matchesCurrentContext(Map<String, dynamic> item) {
    final partido = item['partido'] is Map
        ? Map<String, dynamic>.from(item['partido'] as Map)
        : item;

    return AppContextKey.matchesMap(data: partido, context: _activeContext);
  }

  void _aplicarFiltros() {
    final q = _busqueda.trim().toLowerCase();

    _filtrados = _todos.where((p) {
      if (!_matchesCurrentContext(p)) {
        return false;
      }

      final rival = fixTextoRoto(p['rival'] ?? '').toLowerCase();
      final categoria = (p['categoria'] ?? '').toString();
      final torneo = (p['torneo'] ?? '').toString();

      final okCategoria =
          _categoriaSeleccionada == 'Todas' ||
          categoria == _categoriaSeleccionada;

      final okTorneo =
          _torneoSeleccionado == 'Todos' || torneo == _torneoSeleccionado;

      final okBusqueda = q.isEmpty || rival.contains(q);

      return okCategoria && okTorneo && okBusqueda;
    }).toList();
  }

  String? _rivalShieldAsset(String rival) {
    return rivalShieldAssetGlobal(rival);
  }

  Widget _buildContextPathLabel() {
    final path = [
      widget.temporada,
      widget.competencia,
      widget.torneo,
      widget.categoria,
    ].where((e) => e.trim().isNotEmpty).join(' · ');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1722).withOpacity(0.85),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          const Icon(Icons.route_rounded, color: Color(0xFFAAB4C3), size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              path.isEmpty ? 'Contexto no seleccionado' : path,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFFD4DCE7),
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Partidos Jugados'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/fondohd.jpeg',
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
          ),
          Positioned.fill(
            child: Container(color: const Color(0xFF05080D).withOpacity(0.88)),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 10),
                  child: Column(
                    children: [
                      TextField(
                        onChanged: (value) {
                          setState(() {
                            _busqueda = value;
                            _aplicarFiltros();
                          });
                        },
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Buscar por rival',
                          hintStyle: const TextStyle(color: Color(0xFFAAB4C3)),
                          prefixIcon: const Icon(
                            Icons.search,
                            color: Color(0xFFAAB4C3),
                          ),
                          filled: true,
                          fillColor: const Color(0xFF0F1722).withOpacity(0.85),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildContextPathLabel(),
                    ],
                  ),
                ),
                Expanded(
                  child: _filtrados.isEmpty
                      ? const Center(
                          child: Text(
                            'No hay partidos cargados',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                          itemCount: _filtrados.length,
                          itemBuilder: (context, index) {
                            final partido = _filtrados[index];
                            final rival = fixTextoRoto(
                              partido['rival'] ?? 'Rival',
                            );
                            final escudo = _rivalShieldAsset(rival);

                            final condicion = (partido['condicion'] ?? '')
                                .toString()
                                .trim();
                            final somosLocales =
                                condicion.toLowerCase() == 'local';

                            final equipoPropio =
                                widget.institutionName.trim().isEmpty
                                ? (partido['equipoPropio'] ?? 'Institución')
                                      .toString()
                                : widget.institutionName.trim();

                            final escudoPropio =
                                widget.institutionShieldPath ??
                                partido['escudoPropio']?.toString();

                            final match = MatchModel.fromMap(
                              {
                                ...partido,
                                'institutionId':
                                    partido['institutionId'] ??
                                    widget.institutionId,
                                'equipoPropio': equipoPropio,
                                'escudoPropio': escudoPropio,
                                'equipoLocal': somosLocales
                                    ? equipoPropio
                                    : rival,
                                'equipoVisitante': somosLocales
                                    ? rival
                                    : equipoPropio,
                                'escudoLocal': somosLocales
                                    ? escudoPropio
                                    : escudo,
                                'escudoVisitante': somosLocales
                                    ? escudo
                                    : escudoPropio,
                                'rival': rival,
                                'escudoRival': escudo,
                                'estado': 'Finalizado',
                                'estadoPartido': 'finalizado',
                                'finalizado': true,
                              },
                              finalizadoOverride: true,
                              escudoRivalOverride: escudo,
                            );

                            return MatchCardPro(
                              match: match,
                              actionText: 'Ver resumen',
                              showFechaChip: false,
                              showEstadoChip: false,
                              compact: true,
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        ResumenPartidoFinalizadoScreen(
                                          partido: partido,
                                        ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown<T>({
    required T value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1722).withOpacity(0.85),
        borderRadius: BorderRadius.circular(14),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          dropdownColor: const Color(0xFF0F1722),
          style: const TextStyle(color: Colors.white, fontSize: 14),
          iconEnabledColor: Colors.white,
          isExpanded: true,
          items: items.map((item) {
            return DropdownMenuItem<T>(
              value: item,
              child: Text(
                item.toString(),
                style: const TextStyle(color: Colors.white),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

/// OTROS
///==============================
///===============================

class _UndoSanctionOption {
  final String label;
  final String resultado;

  const _UndoSanctionOption({required this.label, required this.resultado});
}

enum GameEventPhase { ataque, defensa, neutral }

enum GameEventKind {
  tiro,
  penal,
  penalTanda,
  perdida,
  recuperacion,
  lateral,
  contra,
  sancion,
  correccionSancion,
  inicioPeriodo,
  finPeriodo,
  otro,
}

class GameEvent {
  final int id;
  final DateTime timestamp;
  final GameEventKind kind;
  final GameEventPhase phase;

  final String? resultado;
  final String? actorPrincipal;
  final String? actorSecundario;
  final String? zonaTiro;
  final String? zonaArco;
  final String? detalle;
  final String? subtipo;
  final String? origenJugada;

  final bool mantieneContexto;

  const GameEvent({
    required this.id,
    required this.timestamp,
    required this.kind,
    required this.phase,
    this.resultado,
    this.actorPrincipal,
    this.actorSecundario,
    this.zonaTiro,
    this.zonaArco,
    this.detalle,
    this.subtipo,
    this.origenJugada,
    required this.mantieneContexto,
  });

  factory GameEvent.fromLegacyMap(Map<String, dynamic> map) {
    return GameEvent(
      id: (map['id'] as int?) ?? 0,
      timestamp:
          DateTime.tryParse((map['timestamp'] ?? '').toString()) ??
          DateTime.now(),
      kind: _gameEventKindFromString((map['tipo'] ?? '').toString(), map),
      phase: _gameEventPhaseFromString((map['modo'] ?? '').toString()),
      resultado: map['resultado']?.toString(),
      actorPrincipal: map['actorPrincipal']?.toString(),
      actorSecundario: map['actorSecundario']?.toString(),
      zonaTiro: map['zonaTiro']?.toString(),
      zonaArco: map['zonaArco']?.toString(),
      detalle: map['detalle']?.toString(),
      subtipo: map['subtipo']?.toString(),
      origenJugada: map['origenJugada']?.toString(),
      mantieneContexto: (map['mantieneContexto'] as bool?) ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'kind': kind.name,
      'phase': phase.name,
      'resultado': resultado,
      'actorPrincipal': actorPrincipal,
      'actorSecundario': actorSecundario,
      'zonaTiro': zonaTiro,
      'zonaArco': zonaArco,
      'detalle': detalle,
      'subtipo': subtipo,
      'origenJugada': origenJugada,
      'mantieneContexto': mantieneContexto,
    };
  }

  bool get isShotLike =>
      kind == GameEventKind.tiro ||
      kind == GameEventKind.penal ||
      kind == GameEventKind.penalTanda;

  bool get isSanctionLike =>
      kind == GameEventKind.sancion || kind == GameEventKind.correccionSancion;

  bool get isUndoableGameEvent => !isSanctionLike;

  bool get isGoal => resultado == 'gol';
  bool get isSave => resultado == 'atajado';
  bool get isMiss =>
      resultado == 'fuera' || resultado == 'desvio' || resultado == 'palo';
}

GameEventKind _gameEventKindFromString(String tipo, Map<String, dynamic> map) {
  switch (tipo) {
    case 'tiro':
      return GameEventKind.tiro;
    case 'penal':
      return GameEventKind.penal;
    case 'penal_tanda':
      return GameEventKind.penalTanda;
    case 'perdida':
      final resultado = (map['resultado'] ?? '').toString();
      return resultado == 'recuperacion'
          ? GameEventKind.recuperacion
          : GameEventKind.perdida;
    case 'lateral':
      return GameEventKind.lateral;
    case 'contra':
      return GameEventKind.contra;
    case 'sancion':
      return GameEventKind.sancion;
    case 'correccion_sancion':
      return GameEventKind.correccionSancion;
    default:
      return GameEventKind.otro;
  }
}

GameEventPhase _gameEventPhaseFromString(String modo) {
  switch (modo) {
    case 'ataque':
      return GameEventPhase.ataque;
    case 'defensa':
      return GameEventPhase.defensa;
    default:
      return GameEventPhase.neutral;
  }
}

class CourtOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    final Paint strongLine = Paint()
      ..color = Colors.white.withOpacity(0.20)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final Paint softLine = Paint()
      ..color = Colors.white.withOpacity(0.10)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3;

    final Paint softFill = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..style = PaintingStyle.fill;

    final RRect outerFrame = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.02, h * 0.02, w * 0.96, h * 0.96),
      const Radius.circular(26),
    );
    canvas.drawRRect(outerFrame, strongLine);

    final RRect topArea = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.08, h * 0.04, w * 0.84, h * 0.18),
      const Radius.circular(22),
    );
    canvas.drawRRect(topArea, softFill);

    // Separacion arco / zona
    canvas.drawLine(
      Offset(w * 0.06, h * 0.41),
      Offset(w * 0.94, h * 0.41),
      strongLine,
    );

    // Línea de penal
    canvas.drawLine(
      Offset(w * 0.10, h * 0.49),
      Offset(w * 0.90, h * 0.49),
      strongLine,
    );

    // Punto penal
    canvas.drawCircle(
      Offset(w * 0.50, h * 0.55),
      3,
      Paint()..color = Colors.white.withOpacity(0.20),
    );

    // Laterales en perspectiva
    canvas.drawLine(
      Offset(w * 0.09, h * 0.54),
      Offset(w * 0.06, h * 0.96),
      strongLine,
    );
    canvas.drawLine(
      Offset(w * 0.91, h * 0.54),
      Offset(w * 0.94, h * 0.96),
      strongLine,
    );

    // Curva 6m
    final Path sixMeterPath = Path()
      ..moveTo(w * 0.18, h * 0.63)
      ..quadraticBezierTo(w * 0.50, h * 0.74, w * 0.82, h * 0.63);
    canvas.drawPath(sixMeterPath, strongLine);

    // Curva 9m
    final Path nineMeterPath = Path()
      ..moveTo(w * 0.08, h * 0.82)
      ..quadraticBezierTo(w * 0.50, h * 0.96, w * 0.92, h * 0.82);
    canvas.drawPath(nineMeterPath, strongLine);

    // Base inferior
    canvas.drawLine(
      Offset(w * 0.11, h * 0.96),
      Offset(w * 0.89, h * 0.96),
      strongLine,
    );

    // Guías suaves verticales
    for (final x in [0.18, 0.32, 0.50, 0.68, 0.82]) {
      canvas.drawLine(
        Offset(w * x, h * 0.49),
        Offset(w * (x - 0.03), h * 0.98),
        softLine,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TrapezoidZonePainter extends CustomPainter {
  final bool selected;
  final double topWidthFactor;
  final double bottomWidthFactor;

  _TrapezoidZonePainter({
    required this.selected,
    required this.topWidthFactor,
    required this.bottomWidthFactor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double topWidth = size.width * topWidthFactor;
    final double bottomWidth = size.width * bottomWidthFactor;

    final double topLeft = (size.width - topWidth) / 2;
    final double topRight = topLeft + topWidth;

    final double bottomLeft = (size.width - bottomWidth) / 2;
    final double bottomRight = bottomLeft + bottomWidth;

    final path = Path()
      ..moveTo(topLeft, 0)
      ..lineTo(topRight, 0)
      ..lineTo(bottomRight, size.height)
      ..lineTo(bottomLeft, size.height)
      ..close();

    final fill = Paint()
      ..color = selected
          ? const Color(0xFF4F8CFF).withOpacity(0.24)
          : Colors.white.withOpacity(0.04)
      ..style = PaintingStyle.fill;

    final stroke = Paint()
      ..color = selected
          ? const Color(0xFF4F8CFF).withOpacity(0.60)
          : Colors.white.withOpacity(0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    canvas.drawPath(path, fill);
    canvas.drawPath(path, stroke);
  }

  @override
  bool shouldRepaint(covariant _TrapezoidZonePainter oldDelegate) {
    return oldDelegate.selected != selected ||
        oldDelegate.topWidthFactor != topWidthFactor ||
        oldDelegate.bottomWidthFactor != bottomWidthFactor;
  }
}

class _ExtremeZonePainter extends CustomPainter {
  final bool selected;
  final bool alignLeft;

  _ExtremeZonePainter({required this.selected, required this.alignLeft});

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();

    if (alignLeft) {
      path
        ..moveTo(size.width * 0.28, 0)
        ..lineTo(size.width, 0)
        ..lineTo(size.width * 0.84, size.height)
        ..lineTo(0, size.height)
        ..close();
    } else {
      path
        ..moveTo(0, 0)
        ..lineTo(size.width * 0.72, 0)
        ..lineTo(size.width, size.height)
        ..lineTo(size.width * 0.16, size.height)
        ..close();
    }

    final fill = Paint()
      ..color = selected
          ? const Color(0xFF4F8CFF).withOpacity(0.24)
          : Colors.white.withOpacity(0.04)
      ..style = PaintingStyle.fill;

    final stroke = Paint()
      ..color = selected
          ? const Color(0xFF4F8CFF).withOpacity(0.60)
          : Colors.white.withOpacity(0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    canvas.drawPath(path, fill);
    canvas.drawPath(path, stroke);
  }

  @override
  bool shouldRepaint(covariant _ExtremeZonePainter oldDelegate) {
    return oldDelegate.selected != selected ||
        oldDelegate.alignLeft != alignLeft;
  }
}

///===============================
/// ESTADISTICAS
/// ==============================
///===============================

class EstadisticasScreen extends StatefulWidget {
  final String temporada;
  final String competencia;
  final String torneo;
  final String categoria;
  final String institutionName;
  final String? institutionId;
  final String? institutionShieldPath;

  const EstadisticasScreen({
    super.key,
    required this.temporada,
    required this.competencia,
    required this.torneo,
    required this.categoria,
    required this.institutionName,
    this.institutionId,
    this.institutionShieldPath,
  });

  @override
  State<EstadisticasScreen> createState() => _EstadisticasScreenState();
}

class _EstadisticasScreenState extends State<EstadisticasScreen> {
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _future = _loadPartidosReales();
  }

  ActiveContext get _activeContext {
    return ActiveContext(
      hasInstitution: true,
      institutionName: widget.institutionName,
      institutionId: widget.institutionId,
      season: widget.temporada,
      competition: widget.competencia,
      tournament: widget.torneo,
      category: widget.categoria,
    );
  }

  String _normalizeStatsText(dynamic value) {
    return (value ?? '')
        .toString()
        .trim()
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ü', 'u')
        .replaceAll('ñ', 'n')
        .replaceAll(RegExp(r'\s+'), ' ');
  }

  bool get _isSanFernandoContext {
    final id = _normalizeStatsText(widget.institutionId);
    final name = _normalizeStatsText(widget.institutionName);

    return id == 'san_fernando_handball' ||
        name == 'san fernando handball' ||
        name == 'san fernando';
  }

  bool _matchesCurrentContext(Map<String, dynamic> partido) {
    final currentInstitutionId = _normalizeStatsText(widget.institutionId);
    final partidoInstitutionId = _normalizeStatsText(partido['institutionId']);

    if (currentInstitutionId.isNotEmpty) {
      if (partidoInstitutionId.isEmpty && !_isSanFernandoContext) {
        return false;
      }

      if (partidoInstitutionId.isNotEmpty &&
          partidoInstitutionId != currentInstitutionId) {
        return false;
      }
    }

    return AppContextKey.matchesMap(data: partido, context: _activeContext);
  }

  Future<List<Map<String, dynamic>>> _loadPartidosReales() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('finished_matches_history_v1');

    if (raw == null || raw.isEmpty) return [];

    final decoded = jsonDecode(raw) as List<dynamic>;

    final partidos = <Map<String, dynamic>>[];

    for (final item in decoded) {
      if (item is! Map) continue;
      final map = Map<String, dynamic>.from(item);

      final partidoInterno = Map<String, dynamic>.from(
        (map['partido'] as Map?)?.cast<String, dynamic>() ??
            <String, dynamic>{},
      );

      final esFinalizado =
          map['finalizado'] == true ||
          map['estadoPartido'] == 'finalizado' ||
          partidoInterno['finalizado'] == true ||
          partidoInterno['estadoPartido'] == 'finalizado';

      final esReal =
          map['isReal'] == true ||
          map['esPartidoReal'] == true ||
          partidoInterno['isReal'] == true ||
          partidoInterno['esPartidoReal'] == true;

      if (!esFinalizado && !esReal) continue;

      final base = partidoInterno;

      final merged = {
        ...base,

        'institutionId': map['institutionId'] ?? base['institutionId'],
        'temporada': map['temporada'] ?? base['temporada'] ?? '2026',
        'competencia': map['competencia'] ?? base['competencia'] ?? 'Local',
        'torneo': map['torneo'] ?? base['torneo'],
        'categoria': map['categoria'] ?? base['categoria'],

        'matchIdentity': map['matchIdentity'] ?? base['matchIdentity'],
        'archivedAt':
            map['archivedAt'] ?? map['timestamp'] ?? base['archivedAt'],

        'estado': 'Finalizado',
        'estadoPartido': 'finalizado',
        'finalizado': true,

        'golesSanFernando':
            map['golesSanFernando'] ?? base['golesSanFernando'] ?? 0,
        'golesRival': map['golesRival'] ?? base['golesRival'] ?? 0,
        'atajadas': map['atajadas'] ?? base['atajadas'] ?? 0,
        'golesRecibidos': map['golesRecibidos'] ?? base['golesRecibidos'] ?? 0,
        'eventos': map['eventos'] ?? base['eventos'] ?? <dynamic>[],
      };

      if (!_matchesCurrentContext(merged)) {
        continue;
      }

      partidos.add(merged);
    }

    partidos.sort((a, b) {
      final fa = _fechaOrden(a);
      final fb = _fechaOrden(b);
      return fa.compareTo(fb);
    });

    return partidos;
  }

  static int _fechaOrden(Map<String, dynamic> p) {
    final fecha = (p['fecha'] ?? '').toString();
    final parts = fecha.split('/');
    if (parts.length != 2) return 9999;
    final d = int.tryParse(parts[0]) ?? 0;
    final m = int.tryParse(parts[1]) ?? 0;
    return (m * 100) + d;
  }

  int _int(Map<String, dynamic> p, String key) {
    final v = p[key];
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }

  String _resultado(Map<String, dynamic> p) {
    final gf = _int(p, 'golesSanFernando');
    final gc = _int(p, 'golesRival');
    if (gf > gc) return 'W';
    if (gf < gc) return 'L';
    return 'D';
  }

  Color _rachaColor(String r) {
    if (r == 'W') return const Color(0xFF1E7D4F);
    if (r == 'L') return const Color(0xFF9F2D2D);
    return const Color(0xFFC58B1D);
  }

  IconData _rachaIcon(String r) {
    if (r == 'W') return Icons.keyboard_double_arrow_up_rounded;
    if (r == 'L') return Icons.keyboard_double_arrow_down_rounded;
    return Icons.remove_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Estadísticas'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/fondohd.jpeg',
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
          ),
          Positioned.fill(
            child: Container(color: const Color(0xFF05080D).withOpacity(0.88)),
          ),
          SafeArea(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final partidos = snapshot.data ?? [];

                if (partidos.isEmpty) {
                  return const Center(
                    child: Text(
                      'Todavía no hay partidos reales para estadísticas.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFFAAB4C3), fontSize: 14),
                    ),
                  );
                }

                final jugados = partidos.length;
                final golesFavor = partidos.fold<int>(
                  0,
                  (acc, p) => acc + _int(p, 'golesSanFernando'),
                );
                final golesContra = partidos.fold<int>(
                  0,
                  (acc, p) => acc + _int(p, 'golesRival'),
                );
                final atajadas = partidos.fold<int>(
                  0,
                  (acc, p) => acc + _int(p, 'atajadas'),
                );

                final promedio = jugados == 0 ? 0.0 : golesFavor / jugados;
                final racha = partidos.reversed
                    .take(3)
                    .map(_resultado)
                    .toList();

                return ListView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  children: [
                    Text(
                      'Temporada ${widget.temporada}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 18),
                    _buildStatsCard(
                      jugados: jugados,
                      golesFavor: golesFavor,
                      golesContra: golesContra,
                      promedio: promedio,
                      atajadas: atajadas,
                      racha: racha,
                    ),
                    const SizedBox(height: 16),
                    _buildUltimosPartidos(partidos.reversed.take(5).toList()),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard({
    required int jugados,
    required int golesFavor,
    required int golesContra,
    required double promedio,
    required int atajadas,
    required List<String> racha,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1722).withOpacity(0.88),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        children: [
          _statRow(Icons.stadium_rounded, 'Partidos jugados', '$jugados'),
          _statRow(
            Icons.sports_handball_rounded,
            'Goles en temporada',
            '$golesFavor',
          ),
          _statRow(Icons.shield_rounded, 'Goles en contra', '$golesContra'),
          _statRow(
            Icons.show_chart_rounded,
            'Promedio de goles',
            promedio.toStringAsFixed(2),
          ),
          _statRow(Icons.sports_mma_rounded, 'Atajadas', '$atajadas'),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 9),
            child: Row(
              children: [
                const Icon(
                  Icons.bar_chart_rounded,
                  color: Color(0xFF4F8CFF),
                  size: 26,
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Text(
                    'Racha últimos 3',
                    style: TextStyle(
                      color: Color(0xFFAAB4C3),
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Row(
                  children: racha.map((r) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Icon(
                        _rachaIcon(r),
                        color: _rachaColor(r),
                        size: 26,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF4F8CFF), size: 26),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFFAAB4C3),
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUltimosPartidos(List<Map<String, dynamic>> partidos) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1722).withOpacity(0.88),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Últimos partidos',
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          ...partidos.map((p) {
            final r = _resultado(p);
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(_rachaIcon(r), color: _rachaColor(r), size: 22),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      (p['rival'] ?? 'Rival').toString(),
                      style: const TextStyle(
                        color: Color(0xFFDCE4EF),
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Builder(
                    builder: (_) {
                      final gf = _int(p, 'golesSanFernando');
                      final gc = _int(p, 'golesRival');
                      final condicion = (p['condicion'] ?? '').toString();
                      final esLocal = condicion == 'Local';

                      final score = esLocal ? '$gf - $gc' : '$gc - $gf';

                      return Text(
                        score,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

///===============================
/// EQUIPOS
/// gestion de jugadores, arqueros, cuerpo tecnico, categorías, convocados por partido, etc.
///===============================
///===============================

///===============================
/// EQUIPOS
/// gestion de jugadores, arqueros, cuerpo tecnico, categorías, convocados por partido, etc.
///===============================
///===============================

/// ===============================
/// EQUIPO 2.1
/// Gestion deportiva del equipo.
/// Acá NO va importacion/exportacion.
/// La convocatoria por partido queda en Centro de control.
/// ===============================
class EquiposScreen extends StatelessWidget {
  final String categoriaInicial;
  final String temporada;
  final String competencia;
  final String torneo;
  final String? institutionId;

  const EquiposScreen({
    super.key,
    required this.categoriaInicial,
    required this.temporada,
    required this.competencia,
    required this.torneo,
    this.institutionId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Equipo',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/fondohd.jpeg',
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
          ),
          Positioned.fill(
            child: Container(color: const Color(0xFF05080D).withOpacity(0.88)),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Gestion de estructura deportiva',
                    style: TextStyle(color: Color(0xFFD4DCE7), fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$temporada · $competencia · $torneo · $categoriaInicial',
                    style: const TextStyle(
                      color: Color(0xFFAAB4C3),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 18),
                  _buildEquipoActionCard(
                    context: context,
                    icon: Icons.groups_rounded,
                    title: 'Plantel',
                    subtitle: 'Jugadores, arqueros y cuerpo tecnico',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PlantelScreen(
                            categoriaInicial: categoriaInicial,
                            temporada: temporada,
                            competencia: competencia,
                            torneo: torneo,
                            institutionId: institutionId,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEquipoActionCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF0F1722).withOpacity(0.88),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.03)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.22),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: const Color(0xFF182338).withOpacity(0.95),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFFAAB4C3),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFFDCE4EF),
              size: 26,
            ),
          ],
        ),
      ),
    );
  }
}

/// ===============================
/// PLANTEL 2.1
/// Gestiona el plantel base de la categoría activa.
/// Recibe categoría y temporada desde Home.
/// ===============================
class PlantelScreen extends StatefulWidget {
  final String categoriaInicial;
  final String temporada;
  final String competencia;
  final String torneo;
  final String? institutionId;

  const PlantelScreen({
    super.key,
    required this.categoriaInicial,
    required this.temporada,
    required this.competencia,
    required this.torneo,
    this.institutionId,
  });

  @override
  State<PlantelScreen> createState() => _PlantelScreenState();
}

class _PlantelScreenState extends State<PlantelScreen> {
  late String categoriaSeleccionada;

  @override
  void initState() {
    super.initState();
    categoriaSeleccionada = widget.categoriaInicial;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Plantel',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/fondohd.jpeg',
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
          ),
          Positioned.fill(
            child: Container(color: const Color(0xFF05080D).withOpacity(0.88)),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Estructura del plantel por categoría',
                    style: TextStyle(color: Color(0xFFD4DCE7), fontSize: 14),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${widget.temporada} · ${widget.competencia} · ${widget.torneo} · $categoriaSeleccionada',
                    style: const TextStyle(
                      color: Color(0xFFAAB4C3),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 18),
                  _buildCategoriaSelector(),
                  const SizedBox(height: 18),
                  ...[
                    _buildPlantelCard(
                      icon: Icons.sports_handball_rounded,
                      title: 'Jugadores',
                      subtitle: 'Jugadores de campo de $categoriaSeleccionada',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => JugadoresCampoScreen(
                              categoria: widget.categoriaInicial,
                              temporada: widget.temporada,
                              institutionId: widget.institutionId,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildPlantelCard(
                      icon: Icons.shield_rounded,
                      title: 'Arqueros',
                      subtitle: 'Arqueros de $categoriaSeleccionada',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ArquerosScreen(
                              categoria: widget.categoriaInicial,
                              temporada: widget.temporada,
                              institutionId: widget.institutionId,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildPlantelCard(
                      icon: Icons.badge_rounded,
                      title: 'Cuerpo tecnico',
                      subtitle: 'Estructura tecnica de $categoriaSeleccionada',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CuerpoTecnicoScreen(
                              categoria: categoriaSeleccionada,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyContextState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1722).withOpacity(0.88),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.groups_2_outlined,
            color: Color(0xFF8FA3BF),
            size: 36,
          ),
          const SizedBox(height: 12),
          const Text(
            'No hay plantel cargado para este contexto',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${widget.temporada} · ${widget.competencia} · ${widget.torneo} · $categoriaSeleccionada',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFFAAB4C3),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'La edición de planteles por competencia/torneo se migrará en el próximo paso, sin tocar la convocatoria del partido.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF8FA3BF),
              fontSize: 12,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriaSelector() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1722).withOpacity(0.88),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.03)),
      ),
      child: Row(
        children: [
          const Icon(Icons.category_rounded, color: Colors.white, size: 20),
          const SizedBox(width: 10),
          const Text(
            'Categoría',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          _buildCategoriaChip('Cadetes'),
          const SizedBox(width: 8),
          _buildCategoriaChip('Juveniles'),
        ],
      ),
    );
  }

  Widget _buildCategoriaChip(String categoria) {
    final bool activa = categoriaSeleccionada == categoria;

    return GestureDetector(
      onTap: () {
        setState(() {
          categoriaSeleccionada = categoria;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: activa
              ? const Color(0xFF4F8CFF)
              : const Color(0xFF182338).withOpacity(0.95),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: activa
                ? const Color(0xFF4F8CFF)
                : Colors.white.withOpacity(0.04),
          ),
        ),
        child: Text(
          categoria,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildPlantelCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF0F1722).withOpacity(0.88),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.03)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.22),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: const Color(0xFF182338).withOpacity(0.95),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFFAAB4C3),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFFDCE4EF),
              size: 26,
            ),
          ],
        ),
      ),
    );
  }
}

class ArquerosScreen extends StatefulWidget {
  final String categoria;
  final String temporada;
  final String? institutionId;

  const ArquerosScreen({
    super.key,
    required this.categoria,
    required this.temporada,
    this.institutionId,
  });
  @override
  State<ArquerosScreen> createState() => _ArquerosScreenState();
}

class _ArquerosScreenState extends State<ArquerosScreen> {
  late Future<List<PlayerProfile>> _arquerosFuture;

  @override
  void initState() {
    super.initState();
    _arquerosFuture = _loadArqueros();
  }

  /// Carga el plantel persistente y filtra solo arqueros.
  Future<List<PlayerProfile>> _loadArqueros() async {
    await RosterStorage.seedCategoryIfEmpty(
      categoria: widget.categoria,
      temporada: widget.temporada,
      institutionId: widget.institutionId,
    );

    final roster = await RosterStorage.readRosterForCategory(
      categoria: widget.categoria,
      temporada: widget.temporada,
      institutionId: widget.institutionId,
      includeStaff: false,
    );

    return roster.where((p) => p.esArquero).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF4F8CFF),
        onPressed: _abrirAltaArquero,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Arqueros'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/fondohd.jpeg',
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
          ),
          Positioned.fill(
            child: Container(color: const Color(0xFF05080D).withOpacity(0.88)),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Plantel de arqueros · ${widget.categoria}',
                    style: const TextStyle(
                      color: Color(0xFFD4DCE7),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 18),
                  FutureBuilder<List<PlayerProfile>>(
                    future: _arquerosFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Padding(
                          padding: EdgeInsets.all(18),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      final arqueros = snapshot.data ?? [];

                      if (arqueros.isEmpty) {
                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F1722).withOpacity(0.88),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.03),
                            ),
                          ),
                          child: const Text(
                            'No hay arqueros cargados para esta categoría.',
                            style: TextStyle(
                              color: Color(0xFFAAB4C3),
                              fontSize: 14,
                            ),
                          ),
                        );
                      }

                      return Column(
                        children: arqueros
                            .map(
                              (arquero) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: GestureDetector(
                                  onTap: () => _abrirEditarArquero(arquero),
                                  child: _buildArqueroCard(
                                    context: context,
                                    dorsal: _dorsalArquero(arquero),
                                    nombre: _nombreArquero(arquero),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ===============================
  /// ALTA ARQUERO
  /// Crea un arquero nuevo en la categoría actual
  /// y lo guarda en el plantel persistente.
  /// ===============================
  Future<void> _abrirAltaArquero() async {
    final nombreController = TextEditingController();
    final apellidoController = TextEditingController();
    final dorsalController = TextEditingController();

    final confirmado = await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0F1722),
          title: const Text(
            'Agregar arquero',
            style: TextStyle(color: Colors.white),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _inputArquero('Nombre', nombreController),
                const SizedBox(height: 10),
                _inputArquero('Apellido', apellidoController),
                const SizedBox(height: 10),
                _inputArquero('Dorsal', dorsalController),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );

    if (confirmado != true) return;

    final nombre = nombreController.text.trim();
    final apellido = apellidoController.text.trim();
    final dorsal = dorsalController.text.trim();

    if (nombre.isEmpty && apellido.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresá al menos nombre o apellido')),
      );
      return;
    }

    final rosterActual = await RosterStorage.readRosterForCategory(
      categoria: widget.categoria,
      temporada: widget.temporada,
      institutionId: widget.institutionId,
      includeStaff: true,
    );

    final nuevoArquero = PlayerProfile(
      playerId: 'local_gk_${DateTime.now().millisecondsSinceEpoch}',
      clubId: widget.institutionId ?? 'local',
      nombre: nombre,
      apellido: apellido,
      posicion: 'Arquero',
      numeroPreferido: dorsal.isEmpty ? null : dorsal,
      esArquero: true,
      esCuerpoTecnico: false,
    );

    await RosterStorage.saveRosterForCategory(
      categoria: widget.categoria,
      temporada: widget.temporada,
      institutionId: widget.institutionId,
      players: [...rosterActual, nuevoArquero],
    );

    if (!mounted) return;

    setState(() {
      _arquerosFuture = _loadArqueros();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Arquero agregado al plantel')),
    );
  }

  /// ===============================
  /// EDITAR ARQUERO
  /// Permite modificar nombre, apellido y dorsal.
  /// Tambien permite eliminarlo del plantel persistente.
  /// ===============================
  Future<void> _abrirEditarArquero(PlayerProfile arquero) async {
    final nombreController = TextEditingController(text: arquero.nombre);
    final apellidoController = TextEditingController(text: arquero.apellido);
    final dorsalController = TextEditingController(
      text: arquero.numeroPreferido ?? '',
    );

    final accion = await showDialog<String>(
      context: context,
      builder: (_) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0F1722),
          title: const Text(
            'Editar arquero',
            style: TextStyle(color: Colors.white),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _inputArquero('Nombre', nombreController),
                const SizedBox(height: 10),
                _inputArquero('Apellido', apellidoController),
                const SizedBox(height: 10),
                _inputArquero('Dorsal', dorsalController),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, 'delete'),
              child: const Text(
                'Eliminar',
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, 'cancel'),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, 'save'),
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );

    if (accion == null || accion == 'cancel') return;

    if (accion == 'delete') {
      await _confirmarEliminarArquero(arquero);
      return;
    }

    final rosterActual = await RosterStorage.readRosterForCategory(
      categoria: widget.categoria,
      temporada: '2026',
      includeStaff: true,
    );

    final actualizado = rosterActual.map((p) {
      if (p.playerId != arquero.playerId) return p;

      return PlayerProfile(
        playerId: p.playerId,
        clubId: p.clubId,
        nombre: nombreController.text.trim(),
        apellido: apellidoController.text.trim(),
        posicion: 'Arquero',
        numeroPreferido: dorsalController.text.trim().isEmpty
            ? null
            : dorsalController.text.trim(),
        esArquero: true,
        esCuerpoTecnico: false,
      );
    }).toList();

    await RosterStorage.saveRosterForCategory(
      categoria: widget.categoria,
      temporada: '2026',
      players: actualizado,
    );

    if (!mounted) return;

    setState(() {
      _arquerosFuture = _loadArqueros();
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Arquero actualizado')));
  }

  /// ===============================
  /// ELIMINAR ARQUERO
  /// Elimina al arquero del plantel persistente de esta categoría.
  /// No borra eventos historicos ya cargados.
  /// ===============================
  Future<void> _confirmarEliminarArquero(PlayerProfile arquero) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF0F1722),
        title: const Text(
          'Eliminar arquero',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          '¿Seguro que queres eliminar a ${arquero.displayName} de ${widget.categoria}?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Eliminar',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    final rosterActual = await RosterStorage.readRosterForCategory(
      categoria: widget.categoria,
      temporada: '2026',
      includeStaff: true,
    );

    final actualizado = rosterActual
        .where((p) => p.playerId != arquero.playerId)
        .toList();

    await RosterStorage.saveRosterForCategory(
      categoria: widget.categoria,
      temporada: '2026',
      players: actualizado,
    );

    if (!mounted) return;

    setState(() {
      _arquerosFuture = _loadArqueros();
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Arquero eliminado')));
  }

  /// Campo visual reutilizable para alta/edicion de arquero.
  Widget _inputArquero(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFFAAB4C3)),
        filled: true,
        fillColor: const Color(0xFF182338),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  /// ===============================
  /// ARQUEROS 2.1
  /// Lee arqueros desde el plantel persistente.
  /// Si todavía no hay storage, se inicializa desde el hardcode actual.
  /// ===============================

  String _dorsalArquero(PlayerProfile arquero) {
    final dorsal = arquero.numeroPreferido;
    if (dorsal == null || dorsal.trim().isEmpty) return '-';
    return dorsal;
  }

  String _nombreArquero(PlayerProfile arquero) {
    final apellido = arquero.apellido.trim();
    final nombre = arquero.nombre.trim();

    if (apellido.isEmpty && nombre.isEmpty) return 'Arquero';
    if (apellido.isEmpty) return nombre;
    if (nombre.isEmpty) return apellido;

    return '$apellido, $nombre';
  }

  Widget _buildArqueroCard({
    required BuildContext context,
    required String dorsal,
    required String nombre,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1722).withOpacity(0.88),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.03)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.22),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFF182338).withOpacity(0.95),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                dorsal,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nombre,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Arquero · ${widget.categoria}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFFAAB4C3),
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: Color(0xFFDCE4EF),
            size: 26,
          ),
        ],
      ),
    );
  }
}

///======================================================
/// ArquerosPartidoScreen (FIX COMPLETO Y ESTABLE)
/// - Lee datos desde PartidoModel (V2)
/// - Calcula correctamente atajadas, goles y eficacia
/// - NO depende de Maps sueltos inconsistentes
///======================================================

/// 2) ARQUEROSPARTIDOSCREEN COMPLETO
/// Reemplazá tu class ArquerosPartidoScreen completa por esta
/// SOLO si tu versión quedó rota.
/// ======================================================

class ArquerosPartidoScreen extends StatelessWidget {
  final List<Map<String, dynamic>> estadisticasPorArquero;
  final String categoria;

  const ArquerosPartidoScreen({
    super.key,
    required this.estadisticasPorArquero,
    required this.categoria,
  });

  int _int(Map<dynamic, dynamic> item, String key) {
    final value = item[key];
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  double _double(Map<dynamic, dynamic> item, String key) {
    final value = item[key];
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  List<Map<String, dynamic>> get _visibles {
    bool esArqueroValido(Map<String, dynamic> item) {
      final raw = (item['arquero'] ?? '').toString().trim();
      final nombre = (item['arqueroNombre'] ?? '').toString().trim();

      final identidad = nombre.isNotEmpty ? nombre : raw;
      final normalizado = identidad.toLowerCase().trim();

      if (normalizado.isEmpty) return false;
      if (normalizado == 'null') return false;
      if (normalizado == 'sin arquero') return false;
      if (normalizado == 'cambio de contexto') return false;
      if (normalizado.contains('gen')) return false;

      return true;
    }

    return estadisticasPorArquero.where((item) {
      if (!esArqueroValido(item)) return false;

      final atajadas = _int(item, 'atajadas');
      final goles = _int(item, 'golesRecibidos');
      final penales = _int(item, 'penales');
      final contra = _int(item, 'contraDirecta');

      return atajadas + goles + penales + contra > 0;
    }).toList();
  }

  String _nombreArquero(Map<String, dynamic> item) {
    final nombre = (item['arqueroNombre'] ?? '').toString().trim();
    if (nombre.isNotEmpty && nombre != 'null') {
      return fixTextoRoto(nombre);
    }

    final raw = (item['arquero'] ?? '').toString().trim();

    if (raw.isEmpty || raw == 'null' || raw == 'Sin arquero') {
      return 'Sin arquero';
    }

    final dorsalMatch = RegExp(r'^(\d+)').firstMatch(raw);
    if (dorsalMatch != null) {
      return nombreArqueroDesdeDorsal(
        categoria: categoria,
        dorsal: dorsalMatch.group(1)!,
      );
    }

    return fixTextoRoto(raw);
  }

  String _dorsalArquero(Map<String, dynamic> item) {
    final dorsal = (item['arqueroDorsal'] ?? '').toString().trim();
    if (dorsal.isNotEmpty && dorsal != 'null') return dorsal;

    final raw = (item['arquero'] ?? '').toString().trim();
    final dorsalMatch = RegExp(r'^(\d+)').firstMatch(raw);

    if (dorsalMatch != null) return dorsalMatch.group(1)!;

    return '-';
  }

  Map<String, Map<String, int>> _nestedStats(dynamic raw) {
    if (raw is! Map) return {};

    final result = <String, Map<String, int>>{};

    raw.forEach((key, value) {
      if (value is! Map) return;

      final inner = <String, int>{};
      value.forEach((k, v) {
        if (v is int) {
          inner[k.toString()] = v;
        } else if (v is double) {
          inner[k.toString()] = v.toInt();
        } else if (v is String) {
          inner[k.toString()] = int.tryParse(v) ?? 0;
        }
      });

      result[key.toString()] = inner;
    });

    return result;
  }

  String _traducirZona(String zona) {
    switch (zona) {
      case 'AI':
        return 'Arriba izquierda';
      case 'AC':
        return 'Arriba centro';
      case 'AD':
        return 'Arriba derecha';
      case 'CI':
        return 'Medio izquierda';
      case 'CC':
        return 'Centro';
      case 'CD':
        return 'Medio derecha';
      case 'BI':
        return 'Abajo izquierda';
      case 'BC':
        return 'Abajo centro';
      case 'BD':
        return 'Abajo derecha';
      default:
        return zona;
    }
  }

  Map<String, String> _analisisArquero(Map<String, dynamic> item) {
    final zonasArco = _nestedStats(item['zonasArco']);
    final periodos = _nestedStats(item['periodos']);

    String mejorTramo = 'Sin datos';
    double mejorEficaciaTramo = -1;

    periodos.forEach((key, data) {
      final atajadas = data['atajadas'] ?? 0;
      final goles = data['golesRecibidos'] ?? 0;
      final total = atajadas + goles;
      if (total == 0) return;

      final eficacia = atajadas / total;
      if (eficacia > mejorEficaciaTramo) {
        mejorEficaciaTramo = eficacia;
        mejorTramo = key;
      }
    });

    String mejorZona = '';
    String peorZona = '';
    String zonaMasAtacada = '';
    double mejorEfZona = -1;
    double peorEfZona = 999;
    int maxTiros = -1;

    zonasArco.forEach((zona, data) {
      final atajadas = data['atajadas'] ?? 0;
      final goles = data['golesRecibidos'] ?? 0;
      final palos = data['palos'] ?? 0;
      final fuera = data['fuera'] ?? 0;

      final totalAlArco = atajadas + goles;
      final volumen = totalAlArco + palos + fuera;

      if (volumen > maxTiros) {
        maxTiros = volumen;
        zonaMasAtacada = zona;
      }

      if (totalAlArco == 0) return;

      final eficacia = atajadas / totalAlArco;

      if (eficacia > mejorEfZona) {
        mejorEfZona = eficacia;
        mejorZona = zona;
      }

      if (eficacia < peorEfZona) {
        peorEfZona = eficacia;
        peorZona = zona;
      }
    });

    final penales = _int(item, 'penales');
    final penalesAtajados = _int(item, 'penalesAtajados');
    String penalesTxt = '';

    if (penales > 0) {
      final ef = (penalesAtajados / penales) * 100;
      penalesTxt = '$penalesAtajados/$penales (${ef.toStringAsFixed(0)}%)';
    }

    return {
      'mejorTramo': mejorTramo,
      'mejorZona': mejorZona,
      'peorZona': peorZona,
      'zonaMasAtacada': zonaMasAtacada,
      'penales': penalesTxt,
    };
  }

  Color _colorEficacia(double eficacia) {
    if (eficacia >= 45) return const Color(0xFF1E7D4F);
    if (eficacia >= 30) return const Color(0xFFC58B1D);
    return const Color(0xFF9F2D2D);
  }

  String _nivelTexto(double eficacia) {
    if (eficacia >= 45) return 'Alto';
    if (eficacia >= 30) return 'Medio';
    return 'Bajo';
  }

  Widget _buildComparacionArqueros(List<Map<String, dynamic>> data) {
    if (data.length < 2) return const SizedBox.shrink();

    final ordenados = [...data]
      ..sort((a, b) {
        final eb = _double(b, 'eficacia');
        final ea = _double(a, 'eficacia');
        return eb.compareTo(ea);
      });

    final mejor = ordenados.first;
    final segundo = ordenados[1];
    final ef1 = _double(mejor, 'eficacia');
    final ef2 = _double(segundo, 'eficacia');
    final dif = ef1 - ef2;
    final mejorNombre = _nombreArquero(mejor);

    String lectura;
    if (dif > 20) {
      lectura = 'Dominio claro del arquero ${_dorsalArquero(mejor)}';
    } else if (dif > 10) {
      lectura =
          'Mejor rendimiento de ${_dorsalArquero(mejor)}, diferencia moderada';
    } else {
      lectura = 'Rendimiento parejo entre arqueros';
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1722).withOpacity(0.88),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Comparación de arqueros',
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          _row('Mejor arquero', mejorNombre),
          _row('Eficacia', '${ef1.toStringAsFixed(1)}%'),
          _row('Diferencia', '+${dif.toStringAsFixed(1)} pts'),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: (ef1 / 100).clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: Colors.white.withOpacity(0.08),
              valueColor: AlwaysStoppedAnimation<Color>(_colorEficacia(ef1)),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            lectura,
            style: TextStyle(
              color: Colors.white.withOpacity(0.86),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniStatCard(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF182338).withOpacity(0.80),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFFAAB4C3),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    if (value.trim().isEmpty || value.trim() == '-') {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Color(0xFFAAB4C3), fontSize: 14),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = _visibles;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Arqueros del partido'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/fondohd.jpeg',
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
          ),
          Positioned.fill(
            child: Container(color: const Color(0xFF05080D).withOpacity(0.88)),
          ),
          SafeArea(
            child: data.isEmpty
                ? const Center(
                    child: Text(
                      'No hay estadísticas por arquero.',
                      style: TextStyle(color: Color(0xFFAAB4C3)),
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                    children: [
                      _buildComparacionArqueros(data),
                      ...data.map((item) {
                        final nombre = _nombreArquero(item);
                        final dorsal = _dorsalArquero(item);
                        final eficacia = _double(item, 'eficacia');
                        final analisis = _analisisArquero(item);
                        final colorNivel = _colorEficacia(eficacia);

                        final mejorTramo = (analisis['mejorTramo'] ?? '')
                            .toString();
                        final mejorZona = _traducirZona(
                          (analisis['mejorZona'] ?? '').toString(),
                        );
                        final peorZona = _traducirZona(
                          (analisis['peorZona'] ?? '').toString(),
                        );
                        final zonaMasAtacada = _traducirZona(
                          (analisis['zonaMasAtacada'] ?? '').toString(),
                        );
                        final penales = (analisis['penales'] ?? '').toString();

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DetalleArqueroPartidoScreen(
                                  stats: {...item, 'arqueroNombre': nombre},
                                ),
                              ),
                            );
                          },
                          child: Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 14),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F1722).withOpacity(0.88),
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.06),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.22),
                                  blurRadius: 12,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 54,
                                      height: 54,
                                      decoration: BoxDecoration(
                                        color: const Color(
                                          0xFF182338,
                                        ).withOpacity(0.95),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: colorNivel.withOpacity(0.55),
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          dorsal,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        nombre.replaceFirst(
                                          RegExp(r'^\d+\s*·\s*'),
                                          '',
                                        ),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 17,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 7,
                                      ),
                                      decoration: BoxDecoration(
                                        color: colorNivel.withOpacity(0.18),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Text(
                                        _nivelTexto(eficacia),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 18),
                                Text(
                                  'Nivel de eficacia',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.65),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: LinearProgressIndicator(
                                    value: (eficacia / 100).clamp(0.0, 1.0),
                                    minHeight: 8,
                                    backgroundColor: Colors.white.withOpacity(
                                      0.10,
                                    ),
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      colorNivel,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _miniStatCard(
                                        '${eficacia.toStringAsFixed(1)}%',
                                        'Eficacia',
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: _miniStatCard(
                                        '${_int(item, 'atajadas')}',
                                        'Atajadas',
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: _miniStatCard(
                                        '${_int(item, 'golesRecibidos')}',
                                        'Goles',
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Divider(color: Colors.white.withOpacity(0.08)),
                                const SizedBox(height: 8),
                                _row('Mejor tramo', mejorTramo),
                                _row('Zona fuerte', mejorZona),
                                _row('Zona débil', peorZona),
                                _row('Zona más atacada', zonaMasAtacada),
                                _row('Penales', penales),
                                const SizedBox(height: 10),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    'Ver detalle profundo ›',
                                    style: TextStyle(
                                      color: colorNivel.withOpacity(0.9),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

/// ===============================
/// DETALLE ARQUERO PARTIDO
/// Muestra el detalle profundo de un arquero
/// dentro de un partido finalizado.
/// ===============================

class DetalleArqueroPartidoScreen extends StatelessWidget {
  final Map<String, dynamic> stats;

  const DetalleArqueroPartidoScreen({super.key, required this.stats});

  String get _nombreArquero {
    final nombre = (stats['arqueroNombre'] ?? '').toString().trim();
    if (nombre.isNotEmpty) return nombre;
    return (stats['arquero'] ?? 'Arquero').toString();
  }

  int _valor(String key) {
    final value = stats[key];
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  double get _eficacia {
    final value = stats['eficacia'];
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  Map<String, Map<String, int>> _mapStatsInt(String key) {
    final raw = stats[key];

    if (raw is Map) {
      final result = <String, Map<String, int>>{};

      raw.forEach((k, v) {
        if (v is Map) {
          final inner = <String, int>{};

          v.forEach((ik, iv) {
            if (iv is int) {
              inner[ik.toString()] = iv;
            } else if (iv is double) {
              inner[ik.toString()] = iv.toInt();
            } else if (iv is String) {
              inner[ik.toString()] = int.tryParse(iv) ?? 0;
            }
          });

          result[k.toString()] = inner;
        }
      });

      return result;
    }

    return {};
  }

  Map<String, Map<String, dynamic>> get _periodos {
    final raw = stats['periodos'];

    if (raw is Map) {
      final result = <String, Map<String, dynamic>>{};

      raw.forEach((k, v) {
        if (v is Map) {
          result[k.toString()] = Map<String, dynamic>.from(v);
        }
      });

      return result;
    }

    return {};
  }

  Map<String, Map<String, int>> get _zonasArco => _mapStatsInt('zonasArco');

  Map<String, Map<String, int>> get _zonasTiro => _mapStatsInt('zonasTiro');

  Map<String, Map<String, int>> _zonasArcoPorPeriodo(String periodo) {
    final dataPeriodo = _periodos[periodo];
    if (dataPeriodo == null) return {};

    final raw = dataPeriodo['zonasArco'];

    if (raw is Map) {
      final result = <String, Map<String, int>>{};

      raw.forEach((k, v) {
        if (v is Map) {
          final inner = <String, int>{};

          v.forEach((ik, iv) {
            if (iv is int) {
              inner[ik.toString()] = iv;
            } else if (iv is double) {
              inner[ik.toString()] = iv.toInt();
            } else if (iv is String) {
              inner[ik.toString()] = int.tryParse(iv) ?? 0;
            }
          });

          result[k.toString()] = inner;
        }
      });

      return result;
    }

    return {};
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: Text(_nombreArquero),
          backgroundColor: Colors.transparent,
          elevation: 0,
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Global'),
              Tab(text: 'Tiempos'),
              Tab(text: 'Arco'),
              Tab(text: 'Tiro'),
            ],
          ),
        ),
        body: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/fondohd.jpeg',
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
            ),
            Positioned.fill(
              child: Container(
                color: const Color(0xFF05080D).withOpacity(0.88),
              ),
            ),
            SafeArea(
              child: TabBarView(
                children: [
                  _buildGlobalTab(),
                  _buildPeriodosTab(),
                  _buildArcoTabConPeriodos(),
                  _buildZonasTab(_zonasTiro, 'Zona de tiro'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlobalTab() {
    final penales = _valor('penales');
    final penalesAtajados = _valor('penalesAtajados');
    final eficaciaPenales = penales == 0
        ? 0.0
        : (penalesAtajados / penales) * 100;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      children: [
        _buildCard(
          title: 'Resumen global',
          children: [
            _row('Eficacia', '${_eficacia.toStringAsFixed(1)}%'),
            _row('Atajadas', '${_valor('atajadas')}'),
            _row('Goles recibidos', '${_valor('golesRecibidos')}'),
            _row('Eficacia penales', '${eficaciaPenales.toStringAsFixed(1)}%'),
            _row('Penales', '$penales'),
            _row('Penales atajados', '$penalesAtajados'),
            _row('Contra directa', '${_valor('contraDirecta')}'),
            _row('Palos', '${_valor('palos')}'),
            _row('Fuera', '${_valor('fuera')}'),
          ],
        ),
      ],
    );
  }

  Widget _buildPeriodosTab() {
    if (_periodos.isEmpty) {
      return _empty('No hay detalle por tiempos.');
    }

    final orden = ['1T', '2T', '1TA', '2TA', 'Penales', 'Otro'];

    final keys = [
      ...orden.where(_periodos.containsKey),
      ..._periodos.keys.where((k) => !orden.contains(k)),
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      children: keys.map((periodo) {
        final data = _periodos[periodo]!;

        final atajadas = _dynamicInt(data['atajadas']);
        final goles = _dynamicInt(data['golesRecibidos']);
        final total = atajadas + goles;
        final eficacia = total == 0 ? 0.0 : (atajadas / total) * 100;

        final penales = _dynamicInt(data['penales']);
        final penalesAtajados = _dynamicInt(data['penalesAtajados']);
        final eficaciaPenales = penales == 0
            ? 0.0
            : (penalesAtajados / penales) * 100;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildCard(
            title: periodo,
            children: [
              _row('Eficacia', '${eficacia.toStringAsFixed(1)}%'),
              _row('Atajadas', '$atajadas'),
              _row('Goles recibidos', '$goles'),
              _row(
                'Eficacia penales',
                '${eficaciaPenales.toStringAsFixed(1)}%',
              ),
              _row('Penales', '$penales'),
              _row('Penales atajados', '$penalesAtajados'),
              _row('Contra directa', '${_dynamicInt(data['contraDirecta'])}'),
              _row('Palos', '${_dynamicInt(data['palos'])}'),
              _row('Fuera', '${_dynamicInt(data['fuera'])}'),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildArcoTabConPeriodos() {
    final periodosDisponibles = <String>[
      'Global',
      if (_zonasArcoPorPeriodo('1T').isNotEmpty) '1T',
      if (_zonasArcoPorPeriodo('2T').isNotEmpty) '2T',
    ];

    return DefaultTabController(
      length: periodosDisponibles.length,
      child: Column(
        children: [
          const SizedBox(height: 8),
          TabBar(
            isScrollable: true,
            tabs: periodosDisponibles.map((p) => Tab(text: p)).toList(),
          ),
          Expanded(
            child: TabBarView(
              children: periodosDisponibles.map((periodo) {
                final data = periodo == 'Global'
                    ? _zonasArco
                    : _zonasArcoPorPeriodo(periodo);

                return ListView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                  children: [
                    _buildCard(
                      title: periodo == 'Global'
                          ? 'Mapa de arco'
                          : 'Mapa de arco · $periodo',
                      children: [_buildArcoGrid(data)],
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildZonasTab(
    Map<String, Map<String, int>> data,
    String titlePrefix,
  ) {
    if (data.isEmpty) {
      return _empty('No hay datos suficientes.');
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      children: _buildZonasDetalle(data, titlePrefix),
    );
  }

  List<Widget> _buildZonasDetalle(
    Map<String, Map<String, int>> data,
    String titlePrefix,
  ) {
    final keys = data.keys.toList()..sort();

    return keys.map((zona) {
      final item = data[zona]!;

      final atajadas = item['atajadas'] ?? 0;
      final goles = item['golesRecibidos'] ?? 0;
      final total = atajadas + goles;
      final eficacia = total == 0 ? 0.0 : (atajadas / total) * 100;

      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: _buildCard(
          title: '$titlePrefix · $zona',
          children: [
            _row('Eficacia', '${eficacia.toStringAsFixed(1)}%'),
            _row('Atajadas', '$atajadas'),
            _row('Goles recibidos', '$goles'),
            _row('Palos', '${item['palos'] ?? 0}'),
            _row('Fuera', '${item['fuera'] ?? 0}'),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildArcoGrid(Map<String, Map<String, int>> zonas) {
    final orden = [
      ['AI', 'AC', 'AD'],
      ['CI', 'CC', 'CD'],
      ['BI', 'BC', 'BD'],
    ];

    return Column(
      children: orden.map((fila) {
        return Row(
          children: fila.map((zona) {
            final data = zonas[zona] ?? {};

            final atajadas = data['atajadas'] ?? 0;
            final goles = data['golesRecibidos'] ?? 0;
            final palos = data['palos'] ?? 0;
            final fuera = data['fuera'] ?? 0;

            final totalAlArco = atajadas + goles;
            final eficacia = totalAlArco == 0 ? 0.0 : atajadas / totalAlArco;
            final volumen = atajadas + goles + palos + fuera;

            return Expanded(
              child: _zonaHeatBox(
                zona: zona,
                atajadas: atajadas,
                goles: goles,
                palos: palos,
                fuera: fuera,
                eficacia: eficacia,
                volumen: volumen,
              ),
            );
          }).toList(),
        );
      }).toList(),
    );
  }

  Widget _zonaHeatBox({
    required String zona,
    required int atajadas,
    required int goles,
    required int palos,
    required int fuera,
    required double eficacia,
    required int volumen,
  }) {
    final sinDatos = volumen == 0;
    final double intensidad = sinDatos ? 0.12 : (volumen / 10).clamp(0.18, 1.0);

    Color baseColor;

    if (sinDatos) {
      baseColor = const Color(0xFF182338).withOpacity(0.60);
    } else if (eficacia >= 0.60) {
      baseColor = const Color(0xFF1E7D4F).withOpacity(0.22 + intensidad * 0.46);
    } else if (eficacia >= 0.40) {
      baseColor = const Color(0xFFC58B1D).withOpacity(0.22 + intensidad * 0.46);
    } else {
      baseColor = const Color(0xFF9F2D2D).withOpacity(0.22 + intensidad * 0.46);
    }

    final totalAlArco = atajadas + goles;
    final eficaciaTexto = sinDatos || totalAlArco == 0
        ? ''
        : '${(eficacia * 100).toStringAsFixed(0)}%';

    return GestureDetector(
      onTap: sinDatos
          ? null
          : () {
              // Este diálogo usa el contexto más cercano disponible por Builder.
            },
      child: Builder(
        builder: (context) {
          return GestureDetector(
            onTap: sinDatos
                ? null
                : () {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        backgroundColor: const Color(0xFF0F1722),
                        title: Text(
                          'Zona $zona',
                          style: const TextStyle(color: Colors.white),
                        ),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _row(
                              'Eficacia',
                              '${(eficacia * 100).toStringAsFixed(1)}%',
                            ),
                            _row('Atajadas', '$atajadas'),
                            _row('Goles recibidos', '$goles'),
                            _row('Palos', '$palos'),
                            _row('Fuera', '$fuera'),
                            _row('Volumen total', '$volumen'),
                          ],
                        ),
                      ),
                    );
                  },
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 550),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: 0.96 + (0.04 * value),
                  child: Opacity(opacity: value, child: child),
                );
              },
              child: Container(
                height: 92,
                margin: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      baseColor.withOpacity(sinDatos ? 0.50 : 0.95),
                      baseColor.withOpacity(sinDatos ? 0.28 : 0.45),
                      Colors.black.withOpacity(0.12),
                    ],
                  ),
                  border: Border.all(
                    color: Colors.white.withOpacity(sinDatos ? 0.045 : 0.07),
                  ),
                  boxShadow: [
                    if (!sinDatos)
                      BoxShadow(
                        color: baseColor.withOpacity(0.22),
                        blurRadius: 14,
                        offset: const Offset(0, 5),
                      ),
                  ],
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: 8,
                      top: 6,
                      child: Text(
                        eficaciaTexto,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.55),
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            zona,
                            style: TextStyle(
                              color: Colors.white.withOpacity(
                                sinDatos ? 0.45 : 0.72,
                              ),
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            sinDatos ? '—' : '$atajadas / $goles',
                            style: TextStyle(
                              color: Colors.white.withOpacity(
                                sinDatos ? 0.45 : 1,
                              ),
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCard({required String title, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1722).withOpacity(0.88),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Color(0xFFAAB4C3), fontSize: 14),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _empty(String text) {
    return Center(
      child: Text(
        text,
        style: const TextStyle(color: Color(0xFFAAB4C3), fontSize: 14),
      ),
    );
  }

  int _dynamicInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}

/// ======================================================
/// 3) JUGADORESPARTIDOSCREEN COMPLETO
/// Reemplazá tu class JugadoresPartidoScreen completa por esta
/// SOLO si tu versión quedó rota.
/// ======================================================
class JugadoresPartidoScreen extends StatelessWidget {
  final List<Map<String, dynamic>> estadisticasPorJugador;
  final String categoria;

  const JugadoresPartidoScreen({
    super.key,
    required this.estadisticasPorJugador,
    required this.categoria,
  });

  int _int(Map<dynamic, dynamic> item, String key) {
    final value = item[key];
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  double _double(Map<dynamic, dynamic> item, String key) {
    final value = item[key];
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  String _nombreJugador(Map<String, dynamic> item) {
    final raw = (item['jugador'] ?? '').toString().trim();
    if (raw.isEmpty || raw == 'null') return 'Sin jugador';

    final dorsalMatch = RegExp(r'^(\d+)').firstMatch(raw);
    if (dorsalMatch != null) {
      return nombreJugadorDesdeDorsal(
        categoria: categoria,
        dorsal: dorsalMatch.group(1)!,
      );
    }

    return fixTextoRoto(raw);
  }

  String _dorsalJugador(Map<String, dynamic> item) {
    final raw = (item['jugador'] ?? '').toString().trim();
    final dorsalMatch = RegExp(r'^(\d+)').firstMatch(raw);
    if (dorsalMatch != null) return dorsalMatch.group(1)!;
    return '-';
  }

  Color _colorEfectividad(double efectividad) {
    if (efectividad >= 65) return const Color(0xFF1E7D4F);
    if (efectividad >= 45) return const Color(0xFFC58B1D);
    return const Color(0xFF9F2D2D);
  }

  Widget _miniStat(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF182338).withOpacity(0.80),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFFAAB4C3),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = estadisticasPorJugador.where((j) {
      return _int(j, 'tiros') +
              _int(j, 'perdidas') +
              _int(j, 'recuperaciones') >
          0;
    }).toList();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Jugadores de campo'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/fondohd.jpeg',
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
          ),
          Positioned.fill(
            child: Container(color: const Color(0xFF05080D).withOpacity(0.88)),
          ),
          SafeArea(
            child: data.isEmpty
                ? const Center(
                    child: Text(
                      'No hay estadísticas de jugadores de campo.',
                      style: TextStyle(color: Color(0xFFAAB4C3)),
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                    children: data.map((item) {
                      final nombre = _nombreJugador(item);
                      final dorsal = _dorsalJugador(item);
                      final efectividad = _double(item, 'efectividad');
                      final color = _colorEfectividad(efectividad);

                      return Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F1722).withOpacity(0.88),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.06),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 54,
                                  height: 54,
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFF182338,
                                    ).withOpacity(0.95),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: color.withOpacity(0.55),
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      dorsal,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    nombre.replaceFirst(
                                      RegExp(r'^\d+\s*·\s*'),
                                      '',
                                    ),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: LinearProgressIndicator(
                                value: (efectividad / 100).clamp(0.0, 1.0),
                                minHeight: 8,
                                backgroundColor: Colors.white.withOpacity(0.10),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  color,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: _miniStat(
                                    '${_int(item, 'goles')}',
                                    'Goles',
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _miniStat(
                                    '${_int(item, 'tiros')}',
                                    'Tiros',
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _miniStat(
                                    '${efectividad.toStringAsFixed(1)}%',
                                    'Efectividad',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: _miniStat(
                                    '${_int(item, 'perdidas')}',
                                    'Pérdidas',
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _miniStat(
                                    '${_int(item, 'recuperaciones')}',
                                    'Recuperaciones',
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }
}

/// ===============================
/// HISToRICO DE ARQUEROS
/// Lee partidos finalizados reales desde SharedPreferences
/// y arma ranking acumulado por arquero.
/// ===============================

class HistoricoArquerosScreen extends StatefulWidget {
  final String categoria;
  final String temporada;

  const HistoricoArquerosScreen({
    super.key,
    required this.categoria,
    required this.temporada,
  });

  @override
  State<HistoricoArquerosScreen> createState() =>
      _HistoricoArquerosScreenState();
}

class _HistoricoArquerosScreenState extends State<HistoricoArquerosScreen> {
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _future = _loadHistoricoArqueros();
  }

  Future<List<Map<String, dynamic>>> _loadHistoricoArqueros() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('finished_matches_history_v1');

    if (raw == null || raw.isEmpty) return [];

    final history = jsonDecode(raw) as List<dynamic>;
    final acumulado = <String, Map<String, dynamic>>{};

    for (final item in history) {
      if (item is! Map) continue;

      final match = Map<String, dynamic>.from(item);

      if (match['isReal'] != true) continue;

      final partido = Map<String, dynamic>.from(
        (match['partido'] as Map?) ?? const {},
      );

      final categoria = (partido['categoria'] ?? '').toString();
      if (categoria != widget.categoria) continue;

      final eventos = (match['eventos'] as List<dynamic>? ?? const []);

      for (final e in eventos) {
        if (e is! Map) continue;

        final ev = Map<String, dynamic>.from(e);

        final tipo = (ev['tipo'] ?? '').toString();
        final resultado = (ev['resultado'] ?? '').toString();
        final modo = (ev['modo'] ?? '').toString();
        final origen = (ev['origenJugada'] ?? '').toString();
        final zonaTiro = (ev['zonaTiro'] ?? '').toString();
        final actorId = (ev['actorPrincipalId'] ?? '').toString();

        final esTiro =
            tipo == 'tiro' || tipo == 'penal' || tipo == 'penal_tanda';
        if (!esTiro) continue;

        final esDefensa = modo == 'defensa';
        final esContraDirecta =
            modo == 'ataque' &&
            origen == 'contra' &&
            zonaTiro == 'Contra directa arquero' &&
            actorId.isNotEmpty;

        if (!esDefensa && !esContraDirecta) continue;

        String arquero = (ev['arquero'] ?? '').toString().trim();

        if (esContraDirecta) {
          arquero = actorId;
        }

        if (arquero.isEmpty || arquero == 'null') {
          arquero = 'Sin arquero';
        }

        acumulado.putIfAbsent(arquero, () {
          return {
            'arquero': arquero,
            'partidos': <String>{},
            'atajadas': 0,
            'golesRecibidos': 0,
            'palos': 0,
            'fuera': 0,
            'penales': 0,
            'penalesAtajados': 0,
            'contraDirecta': 0,
          };
        });

        final row = acumulado[arquero]!;
        final partidos = row['partidos'] as Set<String>;
        partidos.add((match['matchIdentity'] ?? '').toString());

        if (resultado == 'atajado') {
          row['atajadas'] = (row['atajadas'] as int) + 1;
        }

        if (resultado == 'gol') {
          row['golesRecibidos'] = (row['golesRecibidos'] as int) + 1;
        }

        if (resultado == 'palo') {
          row['palos'] = (row['palos'] as int) + 1;
        }

        if (resultado == 'fuera' || resultado == 'desvio') {
          row['fuera'] = (row['fuera'] as int) + 1;
        }

        if (tipo == 'penal' || tipo == 'penal_tanda') {
          row['penales'] = (row['penales'] as int) + 1;

          if (resultado == 'atajado') {
            row['penalesAtajados'] = (row['penalesAtajados'] as int) + 1;
          }
        }

        if (esContraDirecta) {
          row['contraDirecta'] = (row['contraDirecta'] as int) + 1;
        }
      }
    }

    final lista = acumulado.values.map((row) {
      final atajadas = row['atajadas'] as int;
      final goles = row['golesRecibidos'] as int;
      final total = atajadas + goles;
      final eficacia = total == 0 ? 0.0 : (atajadas / total) * 100;

      final penales = row['penales'] as int;
      final penalesAtajados = row['penalesAtajados'] as int;
      final eficaciaPenales = penales == 0
          ? 0.0
          : (penalesAtajados / penales) * 100;

      return {
        ...row,
        'partidosJugados': (row['partidos'] as Set<String>).length,
        'eficacia': eficacia,
        'eficaciaPenales': eficaciaPenales,
      };
    }).toList();

    lista.sort((a, b) {
      final eb = b['eficacia'] as double;
      final ea = a['eficacia'] as double;
      return eb.compareTo(ea);
    });

    return lista;
  }

  String _nombreArquero(Map<String, dynamic> item) {
    final arquero = (item['arquero'] ?? 'Sin arquero').toString();

    if (RegExp(r'^\d+$').hasMatch(arquero)) {
      return nombreArqueroDesdeDorsal(
        categoria: widget.categoria,
        dorsal: arquero,
      );
    }

    return arquero;
  }

  Color _colorEficacia(double eficacia) {
    if (eficacia >= 45) return const Color(0xFF1E7D4F);
    if (eficacia >= 30) return const Color(0xFFC58B1D);
    return const Color(0xFF9F2D2D);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Historico de arqueros'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/fondohd.jpeg',
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
          ),
          Positioned.fill(
            child: Container(color: const Color(0xFF05080D).withOpacity(0.88)),
          ),
          SafeArea(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final data = snapshot.data ?? [];

                if (data.isEmpty) {
                  return const Center(
                    child: Text(
                      'Todavía no hay partidos reales para armar historico.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFFAAB4C3), fontSize: 14),
                    ),
                  );
                }

                return ListView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  children: [
                    _buildIntroCard(data),
                    const SizedBox(height: 14),
                    ...data.map(_buildArqueroHistoricoCard).toList(),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntroCard(List<Map<String, dynamic>> data) {
    final mejor = data.first;
    final nombre = _nombreArquero(mejor);
    final eficacia = mejor['eficacia'] as double;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1722).withOpacity(0.88),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Lectura historica',
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          _row('Mejor promedio', nombre),
          _row('Eficacia', '${eficacia.toStringAsFixed(1)}%'),
          _row('Arqueros analizados', '${data.length}'),
        ],
      ),
    );
  }

  Widget _buildArqueroHistoricoCard(Map<String, dynamic> item) {
    final nombre = _nombreArquero(item);
    final eficacia = item['eficacia'] as double;
    final color = _colorEficacia(eficacia);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1722).withOpacity(0.88),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            nombre,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          _animatedBar(value: eficacia / 100, color: color),
          const SizedBox(height: 14),
          _row('Partidos', '${item['partidosJugados']}'),
          _row('Eficacia', '${eficacia.toStringAsFixed(1)}%'),
          _row('Atajadas', '${item['atajadas']}'),
          _row('Goles recibidos', '${item['golesRecibidos']}'),
          _row('Penales', '${item['penales']}'),
          _row('Penales atajados', '${item['penalesAtajados']}'),
          _row(
            'Eficacia penales',
            '${(item['eficaciaPenales'] as double).toStringAsFixed(1)}%',
          ),
          _row('Contra directa', '${item['contraDirecta']}'),
        ],
      ),
    );
  }

  Widget _animatedBar({required double value, required Color color}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value.clamp(0.0, 1.0)),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      builder: (context, v, _) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: Container(
            height: 8,
            color: Colors.white.withOpacity(0.08),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: v,
              child: Container(color: color),
            ),
          ),
        );
      },
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Color(0xFFAAB4C3), fontSize: 14),
            ),
          ),
          Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

/// ===============================
/// JUGADORES CAMPO 2.1
/// Lee jugadores de campo desde el plantel persistente.
/// Si no hay datos guardados, inicializa desde el hardcode actual.
/// ===============================
class JugadoresCampoScreen extends StatefulWidget {
  final String categoria;
  final String temporada;
  final String? institutionId;

  const JugadoresCampoScreen({
    super.key,
    required this.categoria,
    required this.temporada,
    this.institutionId,
  });
  @override
  State<JugadoresCampoScreen> createState() => _JugadoresCampoScreenState();
}

class _JugadoresCampoScreenState extends State<JugadoresCampoScreen> {
  late Future<List<PlayerProfile>> _jugadoresFuture;

  @override
  void initState() {
    super.initState();
    _jugadoresFuture = _loadJugadores();
  }

  /// Carga el plantel persistente y filtra solo jugadores de campo.
  Future<List<PlayerProfile>> _loadJugadores() async {
    await RosterStorage.seedCategoryIfEmpty(
      categoria: widget.categoria,
      temporada: widget.temporada,
      institutionId: widget.institutionId,
    );

    final roster = await RosterStorage.readRosterForCategory(
      categoria: widget.categoria,
      temporada: widget.temporada,
      institutionId: widget.institutionId,
      includeStaff: false,
    );

    return roster.where((p) => !p.esArquero && !p.esCuerpoTecnico).toList();
  }

  /// ===============================
  /// ALTA JUGADOR DE CAMPO
  /// Crea un jugador nuevo en la categoría actual
  /// y lo guarda en el plantel persistente.
  /// ===============================
  Future<void> _abrirAltaJugador() async {
    final nombreController = TextEditingController();
    final apellidoController = TextEditingController();
    final dorsalController = TextEditingController();
    final posicionController = TextEditingController();

    final confirmado = await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0F1722),
          title: const Text(
            'Agregar jugador',
            style: TextStyle(color: Colors.white),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _inputAltaJugador('Nombre', nombreController),
                const SizedBox(height: 10),
                _inputAltaJugador('Apellido', apellidoController),
                const SizedBox(height: 10),
                _inputAltaJugador('Dorsal', dorsalController),
                const SizedBox(height: 10),
                _inputAltaJugador('Posicion', posicionController),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );

    if (confirmado != true) return;

    final nombre = nombreController.text.trim();
    final apellido = apellidoController.text.trim();
    final dorsal = dorsalController.text.trim();
    final posicion = posicionController.text.trim();

    if (nombre.isEmpty && apellido.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresá al menos nombre o apellido')),
      );
      return;
    }

    final rosterActual = await RosterStorage.readRosterForCategory(
      categoria: widget.categoria,
      temporada: widget.temporada,
      institutionId: widget.institutionId,
      includeStaff: true,
    );

    final nuevoJugador = PlayerProfile(
      playerId: 'local_${DateTime.now().millisecondsSinceEpoch}',
      clubId: widget.institutionId ?? 'local',
      nombre: nombre,
      apellido: apellido,
      posicion: posicion.isEmpty ? null : posicion,
      numeroPreferido: dorsal.isEmpty ? null : dorsal,
      esArquero: false,
      esCuerpoTecnico: false,
    );

    final actualizado = [...rosterActual, nuevoJugador];

    await RosterStorage.saveRosterForCategory(
      categoria: widget.categoria,
      temporada: widget.temporada,
      institutionId: widget.institutionId,
      players: actualizado,
    );

    if (!mounted) return;

    setState(() {
      _jugadoresFuture = _loadJugadores();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Jugador agregado al plantel')),
    );
  }

  /// Campo visual reutilizable para alta de jugador.
  Widget _inputAltaJugador(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFFAAB4C3)),
        filled: true,
        fillColor: const Color(0xFF182338),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  /// ===============================
  /// EDITAR JUGADOR
  /// Permite modificar nombre, apellido, dorsal y posicion.
  /// Tambien permite eliminarlo del plantel persistente.
  /// ===============================
  Future<void> _abrirEditarJugador(PlayerProfile jugador) async {
    final nombreController = TextEditingController(text: jugador.nombre);
    final apellidoController = TextEditingController(text: jugador.apellido);
    final dorsalController = TextEditingController(
      text: jugador.numeroPreferido ?? '',
    );
    final posicionController = TextEditingController(
      text: jugador.posicion ?? '',
    );

    final accion = await showDialog<String>(
      context: context,
      builder: (_) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0F1722),
          title: const Text(
            'Editar jugador',
            style: TextStyle(color: Colors.white),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _inputAltaJugador('Nombre', nombreController),
                const SizedBox(height: 10),
                _inputAltaJugador('Apellido', apellidoController),
                const SizedBox(height: 10),
                _inputAltaJugador('Dorsal', dorsalController),
                const SizedBox(height: 10),
                _inputAltaJugador('Posicion', posicionController),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, 'delete'),
              child: const Text(
                'Eliminar',
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, 'cancel'),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, 'save'),
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );

    if (accion == null || accion == 'cancel') return;

    if (accion == 'delete') {
      await _confirmarEliminarJugador(jugador);
      return;
    }

    final rosterActual = await RosterStorage.readRosterForCategory(
      categoria: widget.categoria,
      temporada: '2026',
      includeStaff: true,
    );

    final actualizado = rosterActual.map((p) {
      if (p.playerId != jugador.playerId) return p;

      return PlayerProfile(
        playerId: p.playerId,
        clubId: p.clubId,
        nombre: nombreController.text.trim(),
        apellido: apellidoController.text.trim(),
        posicion: posicionController.text.trim().isEmpty
            ? null
            : posicionController.text.trim(),
        numeroPreferido: dorsalController.text.trim().isEmpty
            ? null
            : dorsalController.text.trim(),
        esArquero: p.esArquero,
        esCuerpoTecnico: p.esCuerpoTecnico,
      );
    }).toList();

    await RosterStorage.saveRosterForCategory(
      categoria: widget.categoria,
      temporada: '2026',
      players: actualizado,
    );

    if (!mounted) return;

    setState(() {
      _jugadoresFuture = _loadJugadores();
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Jugador actualizado')));
  }

  /// ===============================
  /// ELIMINAR JUGADOR
  /// Elimina al jugador del plantel persistente de esta categoría.
  /// No borra eventos historicos ya cargados.
  /// ===============================
  Future<void> _confirmarEliminarJugador(PlayerProfile jugador) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF0F1722),
        title: const Text(
          'Eliminar jugador',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          '¿Seguro que queres eliminar a ${jugador.displayName} de ${widget.categoria}?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Eliminar',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    final rosterActual = await RosterStorage.readRosterForCategory(
      categoria: widget.categoria,
      temporada: '2026',
      includeStaff: true,
    );

    final actualizado = rosterActual
        .where((p) => p.playerId != jugador.playerId)
        .toList();

    await RosterStorage.saveRosterForCategory(
      categoria: widget.categoria,
      temporada: '2026',
      players: actualizado,
    );

    if (!mounted) return;

    setState(() {
      _jugadoresFuture = _loadJugadores();
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Jugador eliminado')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF4F8CFF),
        onPressed: _abrirAltaJugador,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Jugadores'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/fondohd.jpeg', fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: Container(color: const Color(0xFF05080D).withOpacity(0.88)),
          ),
          SafeArea(
            child: FutureBuilder<List<PlayerProfile>>(
              future: _jugadoresFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final jugadores = snapshot.data ?? [];

                if (jugadores.isEmpty) {
                  return const Center(
                    child: Text(
                      'No hay jugadores cargados',
                      style: TextStyle(color: Colors.white70),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: jugadores.length,
                  itemBuilder: (context, index) {
                    final j = jugadores[index];

                    final dorsal = j.numeroPreferido?.isNotEmpty == true
                        ? j.numeroPreferido!
                        : '-';

                    final nombre = [
                      j.apellido.trim(),
                      j.nombre.trim(),
                    ].where((e) => e.isNotEmpty).join(', ');

                    return GestureDetector(
                      onTap: () => _abrirEditarJugador(j),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F1722).withOpacity(0.9),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: const Color(0xFF182338),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                dorsal,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    fixTextoRoto(nombre).isNotEmpty
                                        ? nombre
                                        : 'Jugador',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                  if ((j.posicion ?? '').trim().isNotEmpty)
                                    Text(
                                      j.posicion!,
                                      style: const TextStyle(
                                        color: Color(0xFFAAB4C3),
                                        fontSize: 12,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.edit_rounded,
                              color: Colors.white54,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// ===============================
/// CUERPO TeCNICO 2.1
/// Lee cuerpo tecnico desde plantel persistente.
/// ===============================
class CuerpoTecnicoScreen extends StatefulWidget {
  final String categoria;

  const CuerpoTecnicoScreen({super.key, required this.categoria});

  @override
  State<CuerpoTecnicoScreen> createState() => _CuerpoTecnicoScreenState();
}

class _CuerpoTecnicoScreenState extends State<CuerpoTecnicoScreen> {
  late Future<List<PlayerProfile>> _staffFuture;

  /// ===============================
  /// ALTA CUERPO TeCNICO
  /// Crea un integrante del cuerpo tecnico
  /// y lo guarda en el plantel persistente.
  /// ===============================
  Future<void> _abrirAltaStaff() async {
    final nombreController = TextEditingController();
    final apellidoController = TextEditingController();
    final rolController = TextEditingController(text: 'DT');

    final confirmado = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF0F1722),
        title: const Text(
          'Agregar cuerpo tecnico',
          style: TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _inputStaff('Nombre', nombreController),
              const SizedBox(height: 10),
              _inputStaff('Apellido', apellidoController),
              const SizedBox(height: 10),
              _inputStaff('Rol', rolController),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );

    if (confirmado != true) return;

    final nombre = nombreController.text.trim();
    final apellido = apellidoController.text.trim();
    final rol = rolController.text.trim();

    if (nombre.isEmpty && apellido.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresá al menos nombre o apellido')),
      );
      return;
    }

    final rosterActual = await RosterStorage.readRosterForCategory(
      categoria: widget.categoria,
      temporada: '2026',
      includeStaff: true,
    );

    final nuevoStaff = PlayerProfile(
      playerId: 'local_staff_${DateTime.now().millisecondsSinceEpoch}',
      clubId: RosterRepository.currentClub.clubId,
      nombre: nombre,
      apellido: apellido,
      posicion: rol.isEmpty ? 'DT' : rol,
      numeroPreferido: 'DT',
      esArquero: false,
      esCuerpoTecnico: true,
    );

    await RosterStorage.saveRosterForCategory(
      categoria: widget.categoria,
      temporada: '2026',
      players: [...rosterActual, nuevoStaff],
    );

    if (!mounted) return;

    setState(() {
      _staffFuture = _loadStaff();
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Cuerpo tecnico agregado')));
  }

  /// ===============================
  /// EDITAR CUERPO TeCNICO
  /// Edita nombre, apellido y rol.
  /// Tambien permite eliminar.
  /// ===============================
  Future<void> _abrirEditarStaff(PlayerProfile staff) async {
    final nombreController = TextEditingController(text: staff.nombre);
    final apellidoController = TextEditingController(text: staff.apellido);
    final rolController = TextEditingController(text: staff.posicion ?? 'DT');

    final accion = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF0F1722),
        title: const Text(
          'Editar cuerpo tecnico',
          style: TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _inputStaff('Nombre', nombreController),
              const SizedBox(height: 10),
              _inputStaff('Apellido', apellidoController),
              const SizedBox(height: 10),
              _inputStaff('Rol', rolController),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 'delete'),
            child: const Text(
              'Eliminar',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'cancel'),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'save'),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );

    if (accion == null || accion == 'cancel') return;

    if (accion == 'delete') {
      await _confirmarEliminarStaff(staff);
      return;
    }

    final rosterActual = await RosterStorage.readRosterForCategory(
      categoria: widget.categoria,
      temporada: '2026',
      includeStaff: true,
    );

    final actualizado = rosterActual.map((p) {
      if (p.playerId != staff.playerId) return p;

      return PlayerProfile(
        playerId: p.playerId,
        clubId: p.clubId,
        nombre: nombreController.text.trim(),
        apellido: apellidoController.text.trim(),
        posicion: rolController.text.trim().isEmpty
            ? 'DT'
            : rolController.text.trim(),
        numeroPreferido: 'DT',
        esArquero: false,
        esCuerpoTecnico: true,
      );
    }).toList();

    await RosterStorage.saveRosterForCategory(
      categoria: widget.categoria,
      temporada: '2026',
      players: actualizado,
    );

    if (!mounted) return;

    setState(() {
      _staffFuture = _loadStaff();
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Cuerpo tecnico actualizado')));
  }

  /// ===============================
  /// ELIMINAR CUERPO TeCNICO
  /// Elimina el integrante tecnico de esta categoría.
  /// ===============================
  Future<void> _confirmarEliminarStaff(PlayerProfile staff) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF0F1722),
        title: const Text(
          'Eliminar cuerpo tecnico',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          '¿Seguro que queres eliminar a ${staff.displayName} de ${widget.categoria}?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Eliminar',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    final rosterActual = await RosterStorage.readRosterForCategory(
      categoria: widget.categoria,
      temporada: '2026',
      includeStaff: true,
    );

    final actualizado = rosterActual
        .where((p) => p.playerId != staff.playerId)
        .toList();

    await RosterStorage.saveRosterForCategory(
      categoria: widget.categoria,
      temporada: '2026',
      players: actualizado,
    );

    if (!mounted) return;

    setState(() {
      _staffFuture = _loadStaff();
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Cuerpo tecnico eliminado')));
  }

  /// Campo visual reutilizable para alta/edicion de cuerpo tecnico.
  Widget _inputStaff(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFFAAB4C3)),
        filled: true,
        fillColor: const Color(0xFF182338),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _staffFuture = _loadStaff();
  }

  Future<List<PlayerProfile>> _loadStaff() async {
    await RosterStorage.seedCategoryIfEmpty(
      categoria: widget.categoria,
      temporada: '2026',
    );

    final roster = await RosterStorage.readRosterForCategory(
      categoria: widget.categoria,
      temporada: '2026',
      includeStaff: true,
    );

    return roster.where((p) => p.esCuerpoTecnico).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF4F8CFF),
        onPressed: _abrirAltaStaff,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Cuerpo tecnico'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/fondohd.jpeg', fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: Container(color: const Color(0xFF05080D).withOpacity(0.88)),
          ),
          SafeArea(
            child: FutureBuilder<List<PlayerProfile>>(
              future: _staffFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final staff = snapshot.data ?? [];

                if (staff.isEmpty) {
                  return const Center(
                    child: Text(
                      'No hay cuerpo tecnico cargado',
                      style: TextStyle(color: Colors.white70),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: staff.length,
                  itemBuilder: (context, index) {
                    final s = staff[index];

                    final nombre = [
                      s.apellido.trim(),
                      s.nombre.trim(),
                    ].where((e) => e.isNotEmpty).join(', ');

                    return GestureDetector(
                      onTap: () => _abrirEditarStaff(s),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F1722).withOpacity(0.9),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.person, color: Colors.white),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                fixTextoRoto(nombre).isNotEmpty
                                    ? nombre
                                    : 'Staff',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// ===============================
/// BACKUP TOTAL APP
/// Exporta historial + planteles.
/// ===============================
Future<String> generarBackupCompleto() async {
  final prefs = await SharedPreferences.getInstance();

  final Map<String, dynamic> allPrefs = {};

  for (final key in prefs.getKeys()) {
    final value = prefs.get(key);

    if (value == null) continue;

    allPrefs[key] = value;
  }

  final backup = <String, dynamic>{
    'createdAt': DateTime.now().toIso8601String(),
    'app': 'Handball SGS',
    'version': 2,
    'sharedPreferences': allPrefs,
  };

  return const JsonEncoder.withIndent('  ').convert(backup);
}

/// ===============================
/// SANEAR TEXTO IMPORTADO
/// Corrige textos rotos antes de guardarlos.
/// ===============================
String sanitizeImportedJsonText(dynamic value) {
  return fixTextoRoto(value);
}

/// ===============================
/// RESTAURAR BACKUP APP
/// Restaura historial + planteles desde JSON.
/// Guarda todo saneado para evitar acentos rotos.
/// ===============================
Future<void> restaurarBackupCompleto(String backupJson) async {
  final prefs = await SharedPreferences.getInstance();

  final jsonLimpio = sanitizeImportedJsonText(backupJson);
  final data = Map<String, dynamic>.from(jsonDecode(jsonLimpio) as Map);

  final rawPrefs = data['sharedPreferences'];

  if (rawPrefs is Map) {
    final restoredPrefs = Map<String, dynamic>.from(rawPrefs);

    await prefs.clear();

    for (final entry in restoredPrefs.entries) {
      final key = entry.key;
      final value = entry.value;

      if (value is String) {
        await prefs.setString(key, sanitizeImportedJsonText(value));
      } else if (value is bool) {
        await prefs.setBool(key, value);
      } else if (value is int) {
        await prefs.setInt(key, value);
      } else if (value is double) {
        await prefs.setDouble(key, value);
      } else if (value is List) {
        await prefs.setStringList(
          key,
          value.map((e) => sanitizeImportedJsonText(e)).toList(),
        );
      }
    }

    return;
  }

  // Compatibilidad con backups viejos.
  if (data['historial'] != null) {
    await prefs.setString(
      'finished_matches_history_v1',
      sanitizeImportedJsonText(data['historial']),
    );
  }

  if (data['liveMatch'] != null &&
      data['liveMatch'].toString().trim().isNotEmpty &&
      data['liveMatch'].toString().trim() != 'null') {
    await prefs.setString(
      'live_match_current_v1',
      sanitizeImportedJsonText(data['liveMatch']),
    );
  } else {
    await prefs.remove('live_match_current_v1');
  }

  for (final entry in data.entries) {
    if (entry.key.startsWith('roster_') && entry.value != null) {
      await prefs.setString(entry.key, sanitizeImportedJsonText(entry.value));
    }
  }
}

/// ===============================
/// EXPORTAR BACKUP A ARCHIVO
/// Genera un .json UTF-8 y abre compartir.
/// ===============================
Future<void> exportarBackupComoArchivo() async {
  final backup = await generarBackupCompleto();

  final dir = await getTemporaryDirectory();

  final fecha = DateTime.now()
      .toIso8601String()
      .replaceAll(':', '-')
      .replaceAll('.', '-');

  final file = File('${dir.path}/backup_handball_sgs_$fecha.json');

  await file.writeAsBytes(utf8.encode(backup), flush: true);

  await Share.shareXFiles([XFile(file.path)], text: 'Backup Handball SGS');
}

/// ===============================
/// IMPORTAR BACKUP DESDE ARCHIVO
/// Lee bytes UTF-8 desde archivo/Drive.
/// ===============================
Future<void> importarBackupDesdeArchivo(BuildContext context) async {
  try {
    const typeGroup = XTypeGroup(
      label: 'Backup JSON',
      extensions: ['json'],
      mimeTypes: ['application/json'],
    );

    final XFile? pickedFile = await openFile(acceptedTypeGroups: [typeGroup]);

    if (pickedFile == null) return;

    final file = File(pickedFile.path);
    final bytes = await file.readAsBytes();
    final backupJson = utf8.decode(bytes);

    await restaurarBackupCompleto(backupJson);

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Backup importado correctamente')),
    );
  } catch (e) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Error al importar backup: $e')));
  }
}

/// ===============================
/// TEXTO SEGURO / NORMALIZACIÓN GLOBAL
/// fixTextoRoto: visual y saneo.
/// textoKey / normalizeHandballText: comparación.
/// ===============================
String fixTextoRoto(dynamic value) {
  var text = (value ?? '').toString();

  text = text
      .replaceAll('Ã¡', 'á')
      .replaceAll('Ã©', 'é')
      .replaceAll('Ã­', 'í')
      .replaceAll('Ã³', 'ó')
      .replaceAll('Ãº', 'ú')
      .replaceAll('Ã±', 'ñ')
      .replaceAll('Ã', 'Á')
      .replaceAll('Ã‰', 'É')
      .replaceAll('Ã', 'Í')
      .replaceAll('Ã“', 'Ó')
      .replaceAll('Ãš', 'Ú')
      .replaceAll('Ã‘', 'Ñ')
      .replaceAll('Â', '');

  text = text
      .replaceAll('Guinazu', 'Guiñazu')
      .replaceAll('GuiÃ±azu', 'Guiñazu')
      .replaceAll('Joaquin', 'Joaquín')
      .replaceAll('Julian', 'Julián')
      .replaceAll('Agustin', 'Agustín')
      .replaceAll('Leon Rodriguez', 'León Rodríguez')
      .replaceAll('Lopez Aranda', 'López Aranda')
      .replaceAll(
        'Municipalidad de Vicente Lopez',
        'Municipalidad de Vicente López',
      )
      .replaceAll('C.A. Velez Sarsfield', 'C.A. Vélez Sarsfield')
      .replaceAll('Velez', 'Vélez');

  return text;
}

String normalizeHandballText(dynamic value) {
  var text = fixTextoRoto(value).trim().toLowerCase();

  text = text
      .replaceAll('á', 'a')
      .replaceAll('é', 'e')
      .replaceAll('í', 'i')
      .replaceAll('ó', 'o')
      .replaceAll('ú', 'u')
      .replaceAll('ñ', 'n');

  text = text.replaceAll(RegExp(r'\s+'), ' ');
  return text;
}

String textoKey(dynamic value) {
  return normalizeHandballText(value);
}

/// ===============================
/// IDENTIDAD NORMALIZADA DE PARTIDO
/// Evita que acentos o encoding rompan finalizados / fixture / próximo.
/// ===============================
String buildNormalizedMatchIdentity(Map<String, dynamic> partido) {
  String rival = fixTextoRoto(partido['rival'] ?? '');
  String condicion = fixTextoRoto(partido['condicion'] ?? '');

  if (rival.trim().isEmpty || rival == 'null') {
    final local = fixTextoRoto(partido['local'] ?? '');
    final visitante = fixTextoRoto(partido['visitante'] ?? '');
    final localNorm = normalizeHandballText(local);
    final visitanteNorm = normalizeHandballText(visitante);

    if (localNorm == 'san fernando handball' || localNorm == 'san fernando') {
      rival = visitante;
      condicion = condicion.trim().isEmpty ? 'Local' : condicion;
    } else if (visitanteNorm == 'san fernando handball' ||
        visitanteNorm == 'san fernando') {
      rival = local;
      condicion = condicion.trim().isEmpty ? 'Visitante' : condicion;
    }
  }

  return [
    normalizeHandballText(partido['torneo']),
    normalizeHandballText(partido['categoria']),
    normalizeHandballText(partido['fecha']),
    normalizeHandballText(rival),
    normalizeHandballText(condicion),
  ].join('|');
}

/// ===============================
/// ESCUDO DE RIVAL POR NOMBRE NORMALIZADO
/// ===============================
String? rivalShieldAssetGlobal(dynamic rivalRaw) {
  switch (normalizeHandballText(rivalRaw)) {
    case 'argentinos juniors':
      return 'assets/images/argentinos.png';
    case 'ferro carril oeste':
      return 'assets/images/ferro.png';
    case 's.a.g. villa ballester':
      return 'assets/images/ballester.png';
    case 'colegio ward':
      return 'assets/images/ward.png';
    case 'municipalidad de vicente lopez':
      return 'assets/images/vicente_lopez.png';
    case 'c.a. velez sarsfield':
      return 'assets/images/velez.png';
    case 'campana boat club':
      return 'assets/images/campana.png';
    case 's.a.g.a.b.':
      return 'assets/images/sagab.png';
    case 'c.a. river plate':
      return 'assets/images/river.png';
    case 'dorrego handball':
      return 'assets/images/dorrego.png';
    case 'estudiantes de la plata':
      return 'assets/images/estudiantes_lp.png';
    case 's.e.d.a.l.o.':
      return 'assets/images/sedalo.png';
    case 'c.a. lanus':
      return 'assets/images/lanus.png';
    case 'nuestra senora de lujan':
      return 'assets/images/nsl.png';
    case 'a.a.c.f. quilmes':
      return 'assets/images/quilmes.png';
    default:
      final r = normalizeHandballText(rivalRaw);
      if (r.contains('argentinos')) return 'assets/images/argentinos.png';
      if (r.contains('ferro')) return 'assets/images/ferro.png';
      if (r.contains('ballester')) return 'assets/images/ballester.png';
      if (r.contains('ward')) return 'assets/images/ward.png';
      if (r.contains('vicente lopez')) return 'assets/images/vicente_lopez.png';
      if (r.contains('velez')) return 'assets/images/velez.png';
      if (r.contains('campana')) return 'assets/images/campana.png';
      if (r.contains('sagab')) return 'assets/images/sagab.png';
      if (r.contains('river')) return 'assets/images/river.png';
      if (r.contains('dorrego')) return 'assets/images/dorrego.png';
      if (r.contains('estudiantes')) return 'assets/images/estudiantes_lp.png';
      if (r.contains('sedalo')) return 'assets/images/sedalo.png';
      if (r.contains('lanus')) return 'assets/images/lanus.png';
      if (r.contains('lujan')) return 'assets/images/nsl.png';
      if (r.contains('quilmes')) return 'assets/images/quilmes.png';
      return null;
  }
}

String nombreArqueroDesdeDorsal({
  required String categoria,
  required String dorsal,
}) {
  final arquerosCategoria = RosterRepository.goalkeepersForCategory(
    categoria: categoria,
    temporada: '2026',
  );

  PlayerProfile? encontrado;

  for (final arquero in arquerosCategoria) {
    if (arquero.numeroPreferido == dorsal) {
      encontrado = arquero;
      break;
    }
  }

  encontrado ??= RosterRepository.players
      .where((p) => p.esArquero)
      .where((p) => p.numeroPreferido == dorsal)
      .cast<PlayerProfile?>()
      .firstOrNull;

  if (encontrado == null) {
    return 'Arquero $dorsal';
  }

  final apellido = encontrado.apellido.trim();
  final nombre = encontrado.nombre.trim();

  final nombreCompleto = [
    apellido,
    nombre,
  ].where((p) => p.isNotEmpty).join(', ');

  if (nombreCompleto.isEmpty) return 'Arquero $dorsal';

  return '$dorsal · $nombreCompleto';
}

String nombreJugadorDesdeDorsal({
  required String categoria,
  required String dorsal,
}) {
  final jugadores = RosterRepository.rosterForCategory(
    categoria: categoria,
    temporada: '2026',
  );

  try {
    final jugador = jugadores.firstWhere((j) => j.numeroPreferido == dorsal);

    final apellido = jugador.apellido.trim();
    final nombre = jugador.nombre.trim();

    final nombreCompleto = [
      apellido,
      nombre,
    ].where((p) => p.isNotEmpty).join(', ');

    if (nombreCompleto.isEmpty) return 'Jugador $dorsal';

    return '$dorsal · $nombreCompleto';
  } catch (_) {
    return 'Jugador $dorsal';
  }
}
