import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'models_v2.dart';
import 'partido_repository_v2.dart';

/// ===============================
/// PUNTO DE ENTRADA
/// ===============================
///
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

  String get nombreCompleto => '$nombre $apellido'.trim();

  String get displayName {
    final numero = (numeroPreferido ?? '').trim();
    if (numero.isEmpty || numero == 'DT') {
      return '$apellido, $nombre'.trim();
    }
    return '$numero · $apellido, $nombre'.trim();
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
      nombre: (map['nombre'] ?? '').toString(),
      apellido: (map['apellido'] ?? '').toString(),
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
      apellido: 'Guiñazu',
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
    final ids = assignments
        .where(
          (a) =>
              a.categoria == categoria && a.temporada == temporada && a.activo,
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
      if (aNum == null && bNum == null) return a.apellido.compareTo(b.apellido);
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
  static String _key({required String categoria, required String temporada}) {
    return 'roster_${temporada}_$categoria';
  }

  static Future<List<PlayerProfile>> readRosterForCategory({
    required String categoria,
    required String temporada,
    bool includeStaff = false,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(
      _key(categoria: categoria, temporada: temporada),
    );

    if (raw == null || raw.isEmpty) {
      return RosterRepository.rosterForCategory(
        categoria: categoria,
        temporada: temporada,
        includeStaff: includeStaff,
      );
    }

    final decoded = jsonDecode(raw) as List<dynamic>;

    final players = decoded
        .map((e) => PlayerProfile.fromMap(Map<String, dynamic>.from(e as Map)))
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
  }

  static Future<void> saveRosterForCategory({
    required String categoria,
    required String temporada,
    required List<PlayerProfile> players,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final data = players.map((p) => p.toMap()).toList();

    await prefs.setString(
      _key(categoria: categoria, temporada: temporada),
      jsonEncode(data),
    );
  }

  static Future<void> seedCategoryIfEmpty({
    required String categoria,
    required String temporada,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _key(categoria: categoria, temporada: temporada);

    if (prefs.containsKey(key)) return;

    final base = RosterRepository.rosterForCategory(
      categoria: categoria,
      temporada: temporada,
      includeStaff: true,
    );
    await saveRosterForCategory(
      categoria: categoria,
      temporada: temporada,
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

  late Future<List<PlayerProfile>> _rosterFuture;
  List<PlayerProfile> _roster = [];

  Future<List<PlayerProfile>> _loadRoster() async {
    await RosterStorage.seedCategoryIfEmpty(
      categoria: categoria,
      temporada: temporada,
    );

    final roster = await RosterStorage.readRosterForCategory(
      categoria: categoria,
      temporada: temporada,
      includeStaff: false,
    );

    _roster = roster;

    if (convocadosIds.isEmpty) {
      convocadosIds = roster
          .where((p) => p.esArquero)
          .map((p) => p.playerId)
          .toSet();

      arquerosIds = {...convocadosIds};
    }

    return roster;
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
    return _roster.where((p) => !p.esCuerpoTecnico).toList();
  }

  List<PlayerProfile> get _cadetesExtras => [];

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
    widget.partido['matchSquad'] = MatchSquadConfig(
      convocadosIds: convocadosIds,
      arquerosIds: arquerosIds,
    ).toMap();

    /// Snapshot del plantel real usado para este
    /// partido.
    /// Permite que PartidoEnVivo encuentre
    /// jugadores creados en storage
    widget.partido['matchRosterSnapshot'] = _roster
        .map((p) => p.toMap())
        .toList();

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
                      players: _titularesCategoria,
                    ),

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
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          ...players.map((p) {
            final convocado = convocadosIds.contains(p.playerId);
            final arquero = arquerosIds.contains(p.playerId);

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF182338).withOpacity(0.75),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          p.displayName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Checkbox(
                        value: convocadosIds.contains(p.playerId),
                        onChanged: (value) => _toggleConvocado(p, value),
                      ),
                    ],
                  ),

                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          p.esArquero
                              ? 'Arquero disponible'
                              : 'Jugador de campo',
                          style: const TextStyle(
                            color: Color(0xFFAAB4C3),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (p.esArquero)
                        Switch(
                          value: arquerosIds.contains(p.playerId),
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

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool tieneInstitucion = true;
  final String institucionNombre = 'San Fernando Handball';
  final bool hayMasDeUnaTemporada = false;

  String temporadaSeleccionada = '2026';
  String competenciaSeleccionada = 'Local';
  String torneoSeleccionado = 'Apertura';
  String categoriaSeleccionada = 'Cadetes';

  List<String> get contexto => <String>[
    temporadaSeleccionada,
    competenciaSeleccionada,
    torneoSeleccionado,
    categoriaSeleccionada,
  ];

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
              child: Column(
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
  /// GESTIÓN ADMINISTRATIVA
  /// Menú futuro para importaciones, exportaciones y configuración general.
  /// No pertenece a Equipo porque no es gestión deportiva directa.
  /// ===============================
  void _showGestionAdministrativaMenu() {
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
                'Gestión administrativa',
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
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              _buildAdminMenuOption(
                icon: Icons.calendar_month_rounded,
                text: 'Importar fixture',
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              _buildAdminMenuOption(
                icon: Icons.shield_rounded,
                text: 'Importar escudos',
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              _buildAdminMenuOption(
                icon: Icons.download_rounded,
                text: 'Exportar datos',
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  ///===============================
  /// Opción visual del menú administrativo.
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
            case 'Próximo partido':
              return ProximoPartidoScreen(
                categoria: categoriaSeleccionada,
                torneo: torneoSeleccionado,
              );
            case 'Partidos jugados':
              return const HistorialScreen();
            case 'Estadísticas':
              return const EstadisticasScreen();
            case 'Equipo':
              return EquiposScreen(
                categoriaInicial: categoriaSeleccionada,
                temporada: temporadaSeleccionada,
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
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FixtureScreen(
          categoria: categoriaSeleccionada,
          torneo: torneoSeleccionado,
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
    setState(() {
      torneoSeleccionado = torneoSeleccionado == 'Apertura'
          ? 'Clausura'
          : 'Apertura';
    });
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

  Widget _buildEstadoSinInstitucion(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.68,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'No hay una institución creada',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 22),
          ElevatedButton(
            onPressed: () {
              setState(() {
                tieneInstitucion = true;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4F8CFF),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            child: const Text(
              'Crear institución',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () {},
            child: const Text(
              'Importar datos',
              style: TextStyle(color: Color(0xFFD7DCE3), fontSize: 15),
            ),
          ),
        ],
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
                const SizedBox(height: 12),
                _buildSwitcherRow(),
                const SizedBox(height: 12),
                _buildPrimaryOutlineAction(
                  text: 'Ver fixture actual',
                  icon: Icons.calendar_month_rounded,
                  onTap: _abrirFixtureActual,
                ),
                const SizedBox(height: 18),
                _buildHomeActionCard(
                  icon: Icons.sports_handball_rounded,
                  title: 'Próximo partido',
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInstitutionBadge() {
    return Container(
      width: 48,
      height: 48,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
      ),
      padding: const EdgeInsets.all(8),
      child: Center(
        child: Image.asset(
          'assets/images/san_fernando.png',
          fit: BoxFit.contain,
          alignment: Alignment.center,
        ),
      ),
    );
  }

  Widget _buildContextSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF111A28).withOpacity(0.55),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.03)),
      ),
      child: _buildContextLine(),
    );
  }

  Widget _buildContextLine() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: contexto.asMap().entries.map((entry) {
          final int index = entry.key;
          final String value = entry.value;
          final bool removable = index == 0 ? hayMasDeUnaTemporada : false;

          return Padding(
            padding: EdgeInsets.only(
              right: index == contexto.length - 1 ? 0 : 4,
            ),
            child: _buildContextToken(
              text: value,
              removable: removable,
              onRemove: removable
                  ? () {
                      setState(() {});
                    }
                  : null,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildContextToken({
    required String text,
    required bool removable,
    VoidCallback? onRemove,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF182338).withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.035)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFFDCE4EF),
              fontWeight: FontWeight.w500,
              height: 1.0,
            ),
          ),
          if (removable) ...[
            const SizedBox(width: 5),
            GestureDetector(
              onTap: onRemove,
              child: const Icon(
                Icons.close_rounded,
                size: 14,
                color: Color(0xFFC9D3E0),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSwitcherRow() {
    return Row(
      children: [
        Expanded(
          child: _buildSecondaryButton(
            text: 'Categoría: $categoriaSeleccionada',
            onTap: _toggleCategoria,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildSecondaryButton(
            text: 'Torneo: $torneoSeleccionado',
            onTap: _toggleTorneo,
          ),
        ),
      ],
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
/// PRÓXIMO PARTIDO
/// ===============================
/// ===============================

class ProximoPartidoScreen extends StatefulWidget {
  final String categoria;
  final String torneo;

  const ProximoPartidoScreen({
    super.key,
    required this.categoria,
    required this.torneo,
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

  Future<void> _loadEstadoRealV2() async {
    final live = await PartidoRepositoryV2.readLiveMatch();
    final finished = await PartidoRepositoryV2.readFinishedMatches();

    if (!mounted) return;

    setState(() {
      _partidoEnVivoV2 = live;
      _finalizadosV2 = finished;
    });
  }

  bool hayPartido = true;

  Map<String, dynamic> proximoPartido = {};
  List<Map<String, dynamic>> siguientesPartidos = [];
  List<Map<String, dynamic>> partidosFinalizados = [];

  String get _proximoPartidoStorageKey =>
      'proximo_partido_${widget.categoria}_${widget.torneo}';

  String get _siguientesPartidosStorageKey =>
      'siguientes_${widget.categoria}_${widget.torneo}';

  String get _partidosFinalizadosStorageKey =>
      'finalizados_${widget.categoria}_${widget.torneo}';
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
    final identidad = _identityFromMap(partido);

    return _finalizadosV2.any(
      (p) => PartidoRepositoryV2.buildMatchIdentityFromModel(p) == identidad,
    );
  }

  /// ===============================
  /// RECALCULAR PRÓXIMO PARTIDO DESDE FIXTURE BASE
  /// Si el próximo actual quedó inválido, toma el primer pendiente real
  /// y recompone también los siguientes partidos.
  /// ===============================
  /// ===============================
  /// RECALCULAR PRÓXIMO Y SIGUIENTES DESDE FIXTURE BASE
  /// Usa solo el fixture base del torneo/categoría actual
  /// y filtra por partidos no finalizados según V2.
  /// ===============================
  void _recalcularProximoYSiguientesDesdeBase() {
    final todos = _buildFixtureCompleto(
      categoria: widget.categoria,
    ).where((p) => (p['torneo'] ?? '').toString() == widget.torneo).toList();

    final pendientes = todos.where((p) => !_estaFinalizadoV2(p)).toList();

    pendientes.sort((a, b) {
      final fa = (a['fechaNumero'] ?? 0) as int;
      final fb = (b['fechaNumero'] ?? 0) as int;
      return fa.compareTo(fb);
    });

    if (pendientes.isEmpty) {
      proximoPartido = {};
      siguientesPartidos = [];
      hayPartido = false;
      return;
    }

    final proximo = Map<String, dynamic>.from(pendientes.first);

    final siguientes = pendientes.skip(1).map((p) {
      return {
        'rival': p['rival'],
        'fechaNumero': p['fechaNumero'],
        'fecha': p['fecha'],
        'hora': p['hora'],
        'condicion': p['condicion'],
        'torneo': p['torneo'],
        'categoria': p['categoria'],
        'escudoRival': p['escudoRival'],
      };
    }).toList();

    proximoPartido = proximo;
    siguientesPartidos = siguientes;
    hayPartido = true;
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadEstadoRealV2();
      await _loadFixtureState();

      if (!mounted) return;

      setState(() {
        _recalcularProximoYSiguientesDesdeBase();
      });
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
        'local': 'Municipalidad de Vicente López',
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
        'visitante': 'C.A. Vélez Sarsfield',
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
        'visitante': 'C.A. Lanús',
        'torneo': 'Apertura',
        'categoria': categoria,
      },
      {
        'fechaNumero': 14,
        'fecha': '04/07',
        'hora': '13:00',
        'local': 'Nuestra Señora de Luján',
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
    switch (rival.toLowerCase()) {
      case 'argentinos juniors':
        return 'assets/images/argentinos.png';
      case 'ferro carril oeste':
        return 'assets/images/ferro.png';
      case 's.a.g. villa ballester':
        return 'assets/images/ballester.png';
      case 'colegio ward':
        return 'assets/images/ward.png';
      case 'municipalidad de vicente lópez':
        return 'assets/images/vicente_lopez.png';
      case 'c.a. vélez sarsfield':
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
      case 'c.a. lanús':
        return 'assets/images/lanus.png';
      case 'nuestra señora de luján':
        return 'assets/images/nsl.png';
      case 'a.a.c.f. quilmes':
        return 'assets/images/quilmes.png';
      default:
        return null;
    }
  }

  List<Map<String, dynamic>> _buildFixtureCompleto({
    required String categoria,
  }) {
    final apertura = _buildAperturaBase(
      categoria: categoria,
    ).map(_convertirAFixturePartido).toList();

    final clausura = _buildClausuraBase(
      categoria: categoria,
    ).map(_convertirAFixturePartido).toList();

    return [...apertura, ...clausura];
  }

  List<Map<String, dynamic>> _defaultSiguientesPartidos() {
    final fixture = _buildFixtureCompleto(categoria: widget.categoria);

    final identidadesFinalizadas = partidosFinalizados
        .map((p) => _partidoIdentity(p))
        .toSet();

    final pendientes = fixture.where((p) {
      return p['torneo'] == widget.torneo &&
          p['categoria'] == widget.categoria &&
          !identidadesFinalizadas.contains(_partidoIdentity(p));
    }).toList();

    if (pendientes.isEmpty) return [];

    final identidadProximo = _partidoIdentity(proximoPartido);

    final siguientes = pendientes
        .where((p) => _partidoIdentity(p) != identidadProximo)
        .toList();

    return siguientes.take(3).map((p) {
      return {
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
    final prefs = await SharedPreferences.getInstance();

    final proximoRaw = prefs.getString(_proximoPartidoStorageKey);
    final siguientesRaw = prefs.getString(_siguientesPartidosStorageKey);
    final finalizadosRaw = prefs.getString(_partidosFinalizadosStorageKey);
    final finishedHistoryRaw = prefs.getString(_finishedMatchesStorageKey);

    if (proximoRaw != null && proximoRaw.isNotEmpty) {
      proximoPartido = Map<String, dynamic>.from(jsonDecode(proximoRaw) as Map);
    }
    // ===============================
    // VALIDACIÓN V2
    // Si el próximo partido ya está finalizado según V2,
    // lo invalidamos
    // ===============================
    if (_estaFinalizadoV2(proximoPartido)) {
      _recalcularProximoYSiguientesDesdeBase();
      return;
    }

    if (siguientesRaw != null && siguientesRaw.isNotEmpty) {
      final decoded = jsonDecode(siguientesRaw) as List<dynamic>;
      siguientesPartidos = decoded.map((e) {
        final item = Map<String, dynamic>.from(e as Map);

        item['escudoRival'] =
            item['escudoRival'] ??
            _rivalShieldAssetByName((item['rival'] ?? '').toString());

        return item;
      }).toList();
    }

    List<Map<String, dynamic>> finalizadosDesdeProximo = [];
    List<Map<String, dynamic>> finalizadosDesdeHistory = [];

    if (finalizadosRaw != null && finalizadosRaw.isNotEmpty) {
      final decoded = jsonDecode(finalizadosRaw) as List<dynamic>;
      finalizadosDesdeProximo = decoded
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    }

    if (finishedHistoryRaw != null && finishedHistoryRaw.isNotEmpty) {
      final decoded = jsonDecode(finishedHistoryRaw) as List<dynamic>;
      finalizadosDesdeHistory = decoded
          .map(
            (e) => _partidoDesdeFinishedHistoryEntry(
              Map<String, dynamic>.from(e as Map),
            ),
          )
          .toList();
    }

    partidosFinalizados = _mergeFinalizados(
      desdeProximoScreen: finalizadosDesdeProximo,
      desdeFinishedHistory: finalizadosDesdeHistory,
    );

    hayPartido = proximoPartido.isNotEmpty;
  }

  Future<void> _persistFixtureState() async {
    final prefs = await SharedPreferences.getInstance();

    if (hayPartido && proximoPartido.isNotEmpty) {
      await prefs.setString(
        _proximoPartidoStorageKey,
        jsonEncode(proximoPartido),
      );
    } else {
      await prefs.remove(_proximoPartidoStorageKey);
    }

    await prefs.setString(
      _siguientesPartidosStorageKey,
      jsonEncode(siguientesPartidos),
    );

    await prefs.setString(
      _partidosFinalizadosStorageKey,
      jsonEncode(partidosFinalizados),
    );
  }

  Future<void> _resetPartidosDePrueba() async {
    final prefs = await SharedPreferences.getInstance();

    final fixture = _buildFixtureCompleto(
      categoria: widget.categoria,
    ).where((p) => p['torneo'] == widget.torneo).toList();

    final Map<String, Map<String, dynamic>> finalizadosPorId = {
      for (final p in partidosFinalizados)
        _partidoIdentity(p): Map<String, dynamic>.from(p),
    };

    final List<Map<String, dynamic>> pendientes = [];
    final List<Map<String, dynamic>> finalizadosConservados = [];

    for (final partido in fixture) {
      final id = _partidoIdentity(partido);

      if (finalizadosPorId.containsKey(id)) {
        final partidoFinalizado =
            Map<String, dynamic>.from(finalizadosPorId[id]!)
              ..['estado'] = 'Finalizado'
              ..['estadoPartido'] = 'finalizado';
        finalizadosConservados.add(partidoFinalizado);
      } else {
        pendientes.add(Map<String, dynamic>.from(partido));
      }
    }

    setState(() {
      partidosFinalizados = finalizadosConservados;

      if (pendientes.isNotEmpty) {
        proximoPartido = pendientes.first;
        siguientesPartidos = pendientes.skip(1).map((p) {
          return {
            'rival': p['rival'],
            'fecha': p['fecha'],
            'hora': p['hora'],
            'condicion': p['condicion'],
            'torneo': p['torneo'],
            'categoria': p['categoria'],
            'fechaNumero': p['fechaNumero'],
            'escudoRival': p['escudoRival'],
          };
        }).toList();
        hayPartido = true;
      } else {
        proximoPartido = {};
        siguientesPartidos = [];
        hayPartido = false;
      }
    });

    if (hayPartido && proximoPartido.isNotEmpty) {
      await prefs.setString(
        _proximoPartidoStorageKey,
        jsonEncode(proximoPartido),
      );
    } else {
      await prefs.remove(_proximoPartidoStorageKey);
    }

    await prefs.setString(
      _siguientesPartidosStorageKey,
      jsonEncode(siguientesPartidos),
    );

    await prefs.setString(
      _partidosFinalizadosStorageKey,
      jsonEncode(partidosFinalizados),
    );
  }

  Future<void> _eliminarPartidosDePrueba() async {
    final prefs = await SharedPreferences.getInstance();

    final rawFinished = prefs.getString('finished_matches_history_v1');

    if (rawFinished != null && rawFinished.isNotEmpty) {
      final decoded = jsonDecode(rawFinished) as List<dynamic>;

      final soloReales = decoded.where((item) {
        if (item is! Map) return false;
        return item['isReal'] == true;
      }).toList();

      await prefs.setString(
        'finished_matches_history_v1',
        jsonEncode(soloReales),
      );
    }

    if (!mounted) return;

    await _loadEstadoRealV2();
    await _loadFixtureState();

    if (!mounted) return;

    setState(() {
      _recalcularProximoYSiguientesDesdeBase();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Se eliminaron los partidos de prueba')),
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
          'Se van a borrar solo los partidos que no estén marcados como reales. Los partidos finalizados reales se conservarán.',
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
      unicos[_partidoIdentity(partido)] = partido;
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

    final actualId = _partidoIdentity(proximoPartido);
    final yaExiste = partidosFinalizados.any(
      (p) => _partidoIdentity(p) == actualId,
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
    if (!hayPartido) return;
    proximoPartido['esPartidoReal'] ??= false;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Próximo partido'),
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
              child: hayPartido
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
            'Último partido finalizado',
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
        const SizedBox(height: 10),
        _buildSecondaryAction(
          text: 'Ver fixture completo',
          icon: Icons.calendar_month_outlined,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => FixtureScreen(
                  categoria: proximoPartido['categoria'],
                  torneo: proximoPartido['torneo'],
                ),
              ),
            );
          },
        ),
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
          onTap: () {
            debugPrint('Editar partido');
          },
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
                'No hay un próximo partido cargado',
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
                onTap: () {
                  debugPrint('Crear partido');
                },
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
        const Text(
          'San Fernando Handball',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${proximoPartido['categoria']} · ${proximoPartido['torneo']}',
          style: const TextStyle(fontSize: 14, color: Color(0xFFD4DCE7)),
        ),
      ],
    );
  }

  Widget _buildScreenHeaderSinPartido() {
    final ultimo = partidosFinalizados.isNotEmpty
        ? partidosFinalizados.first
        : null;

    final categoria = ultimo?['categoria']?.toString() ?? 'Cadetes';
    final torneo = ultimo?['torneo']?.toString() ?? 'Apertura';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'San Fernando Handball',
          style: TextStyle(
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
                assetPath: proximoPartido['escudoRival'] as String?,
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
            '${proximoPartido['fecha']} • ${proximoPartido['hora']}',
          ),
          _buildInfoRow(
            'Condición',
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

          final nuevosSiguientes = siguientesPartidos
              .where((p) => p != partido)
              .toList();

          nuevosSiguientes.add(partidoActualAnterior);

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
              child: Center(
                child: escudoRival == null
                    ? const Icon(
                        Icons.sports_handball,
                        size: 18,
                        color: Color(0xFF1C2B44),
                      )
                    : Image.asset(escudoRival, fit: BoxFit.contain),
              ),
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
      child: Center(
        child: assetPath == null
            ? const Icon(
                Icons.sports_handball,
                color: Color(0xFF1C2B44),
                size: 24,
              )
            : Image.asset(assetPath, fit: BoxFit.contain),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF182338).withOpacity(0.95),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: const TextStyle(
          fontSize: 12,
          color: Color(0xFFDCE4EF),
          fontWeight: FontWeight.w600,
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
                'Historial vs ${proximoPartido['rival']}',
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

/// ===============================
/// ===============================
/// RESUMEN DEL PARTIDO FINALIZADO
/// ===============================
/// ===============================

class ResumenPartidoFinalizadoScreen extends StatelessWidget {
  final Map<String, dynamic> partido;

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

    for (final e in _eventos) {
      final map = Map<String, dynamic>.from(e as Map);

      final tipo = (map['tipo'] ?? map['kind'] ?? '').toString();
      final resultado = (map['resultado'] ?? '').toString();
      final modo = (map['modo'] ?? map['phase'] ?? '').toString();

      final bool esTiro =
          tipo == 'tiro' || tipo == 'penal' || tipo == 'penal_tanda';

      final bool esDefensivo = modo == 'defensa';

      if (!esTiro || !esDefensivo) continue;
      if (resultado != 'atajado' && resultado != 'gol') continue;

      String arquero = (map['arquero'] ?? '').toString().trim();
      if (arquero.isEmpty || arquero == 'null') {
        arquero = 'Sin arquero';
      }

      acumulado.putIfAbsent(arquero, () {
        return {'arquero': arquero, 'atajadas': 0, 'golesRecibidos': 0};
      });

      if (resultado == 'atajado') {
        acumulado[arquero]!['atajadas'] =
            (acumulado[arquero]!['atajadas'] as int) + 1;
      }

      if (resultado == 'gol') {
        acumulado[arquero]!['golesRecibidos'] =
            (acumulado[arquero]!['golesRecibidos'] as int) + 1;
      }
    }

    final lista = acumulado.values.map((item) {
      final atajadas = item['atajadas'] as int;
      final golesRecibidos = item['golesRecibidos'] as int;
      final total = atajadas + golesRecibidos;
      final eficacia = total == 0 ? 0.0 : (atajadas / total) * 100;

      return {
        'arquero': item['arquero'],
        'atajadas': atajadas,
        'golesRecibidos': golesRecibidos,
        'eficacia': eficacia,
      };
    }).toList();

    lista.sort((a, b) {
      final nombreA = (a['arquero'] ?? '').toString();
      final nombreB = (b['arquero'] ?? '').toString();
      return nombreA.compareTo(nombreB);
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
                  _buildHeaderCard(),
                  const SizedBox(height: 16),
                  _buildKpiGrid(),
                  TextButton(
                    onPressed: _debugPrintHistorial,
                    child: const Text('DEBUG historial'),
                  ),

                  /*const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => _marcarEsteFinalizadoComoReal(context),
                    child: const Text('Marcar como REAL'),
                  ),*/
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
                  _buildSectionCard(
                    title: 'Arquero',
                    child: Column(
                      children: [
                        _buildInfoRow(
                          'Eficacia',
                          '${_eficaciaDesdeArqueros.toStringAsFixed(1)}%',
                        ),
                        _buildInfoRow('Atajadas', '$_atajadasDesdeArqueros'),
                        _buildInfoRow(
                          'Goles recibidos',
                          '$_golesRecibidosDesdeArqueros',
                        ),
                        _buildInfoRow('Penales en contra', '$_penalesV2'),
                      ],
                    ),
                  ),
                  _buildSectionCard(
                    title: 'Estadísticas por arquero',
                    child: estadisticasPorArquero.isEmpty
                        ? const Text(
                            'No hay eventos suficientes para separar estadísticas por arquero.',
                            style: TextStyle(
                              color: Color(0xFFAAB4C3),
                              fontSize: 13,
                            ),
                          )
                        : Column(
                            children: estadisticasPorArquero.map((item) {
                              final arquero = (item['arquero'] ?? 'Sin arquero')
                                  .toString();
                              final atajadas = item['atajadas'] as int;
                              final golesRecibidos =
                                  item['golesRecibidos'] as int;
                              final eficacia = item['eficacia'] as double;

                              return Container(
                                width: double.infinity,
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF182338,
                                  ).withOpacity(0.75),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      arquero == 'Sin arquero'
                                          ? 'Sin arquero'
                                          : nombreArqueroDesdeDorsal(
                                              categoria: partidoV2.categoria,
                                              dorsal: arquero,
                                            ),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    _buildInfoRow('Atajadas', '$atajadas'),
                                    _buildInfoRow(
                                      'Goles recibidos',
                                      '$golesRecibidos',
                                    ),
                                    _buildInfoRow(
                                      'Eficacia',
                                      '${eficacia.toStringAsFixed(1)}%',
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
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

  Future<void> _marcarEsteFinalizadoComoReal(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('finished_matches_history_v1');

    if (raw == null || raw.isEmpty) return;

    final history = jsonDecode(raw) as List<dynamic>;

    final identity = PartidoRepositoryV2.buildMatchIdentityFromMap(partido);

    final nuevoHistory = history.map((item) {
      if (item is! Map) return item;

      final map = Map<String, dynamic>.from(item);

      if ((map['matchIdentity'] ?? '').toString() == identity) {
        map['isReal'] = true;
        map['finalizado'] = true;
        map['estadoPartido'] = 'finalizado';
      }

      return map;
    }).toList();

    await prefs.setString(
      'finished_matches_history_v1',
      jsonEncode(nuevoHistory),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ Partido marcado como REAL')),
    );
  }

  /// ===============================
  /// DEBUG HISTORIAL RESUMIDO
  /// Muestra identidad + isReal de cada finalizado.
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

  Widget _buildHeaderCard() {
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
          const SizedBox(height: 18),
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

/// ===============================
/// ===============================
/// FIXTURE
/// ===============================
///
class FixtureScreen extends StatefulWidget {
  final String categoria;
  final String torneo;

  const FixtureScreen({
    super.key,
    required this.categoria,
    required this.torneo,
  });

  @override
  State<FixtureScreen> createState() => _FixtureScreenState();
}

class _FixtureScreenState extends State<FixtureScreen> {
  static const String _liveMatchStorageKey = 'live_match_current_v1';
  static const String _finishedMatchesStorageKey =
      'finished_matches_history_v1';

  /// ===============================
  /// PARTIDOS FINALIZADOS V2
  /// Cache local usando el nuevo repository
  /// ===============================
  List<PartidoModel> _finalizadosV2 = [];

  @override
  void initState() {
    super.initState();
    _loadFinalizadosV2();
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
        'local': 'Municipalidad de Vicente López',
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
        'visitante': 'C.A. Vélez Sarsfield',
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
        'visitante': 'C.A. Lanús',
        'torneo': 'Apertura',
        'categoria': categoria,
      },
      {
        'fechaNumero': 14,
        'fecha': '04/07',
        'hora': '13:00',
        'local': 'Nuestra Señora de Luján',
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
    return (value ?? '')
        .toString()
        .trim()
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u');
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
      final data = Map<String, dynamic>.from(jsonDecode(rawLive) as Map);
      if ((data['matchIdentity'] ?? '') == identity) {
        return _mergePersistedStateIntoPartido(partidoBase, data);
      }
    }

    final rawFinished = prefs.getString(_finishedMatchesStorageKey);
    if (rawFinished != null && rawFinished.isNotEmpty) {
      final decoded = jsonDecode(rawFinished) as List<dynamic>;
      for (final item in decoded) {
        final data = Map<String, dynamic>.from(item as Map);
        if ((data['matchIdentity'] ?? '') == identity) {
          return _mergePersistedStateIntoPartido(partidoBase, data);
        }
      }
    }

    return partidoBase;
  }

  String? _rivalShieldAssetByName(String rival) {
    switch (rival.toLowerCase()) {
      case 'argentinos juniors':
        return 'assets/images/argentinos.png';
      case 'ferro carril oeste':
        return 'assets/images/ferro.png';
      case 's.a.g. villa ballester':
        return 'assets/images/ballester.png';
      case 'colegio ward':
        return 'assets/images/ward.png';
      case 'municipalidad de vicente lópez':
        return 'assets/images/vicente_lopez.png';
      case 'c.a. vélez sarsfield':
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
      case 'c.a. lanús':
        return 'assets/images/lanus.png';
      case 'nuestra señora de luján':
        return 'assets/images/nsl.png';
      case 'a.a.c.f. quilmes':
        return 'assets/images/quilmes.png';
      default:
        return null;
    }
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

  List<Map<String, dynamic>> _obtenerFixturePorCategoriaYTorneo() {
    if (widget.torneo == 'Apertura') {
      return _buildAperturaBase(
        categoria: widget.categoria,
      ).map(_convertirAFixturePartido).toList();
    }

    return _buildClausuraBase(
      categoria: widget.categoria,
    ).map(_convertirAFixturePartido).toList();
  }

  Future<void> _abrirPartido(
    BuildContext context,
    Map<String, dynamic> partido,
  ) async {
    final partidoReal = await _resolverPartidoConEstadoReal(
      Map<String, dynamic>.from(partido),
    );

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
            child: Container(color: const Color(0xFF05080D).withOpacity(0.88)),
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
                ...partidos.map((p) => _buildFixtureCard(context, p)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFixtureCard(BuildContext context, Map<String, dynamic> partido) {
    final identidad = PartidoRepositoryV2.buildMatchIdentityFromMap(partido);

    final estaFinalizadoV2 = _finalizadosV2.any(
      (p) => PartidoRepositoryV2.buildMatchIdentityFromModel(p) == identidad,
    );

    final bool somosLocales = (partido['condicion'] ?? 'Local') == 'Local';
    final String rival = (partido['rival'] ?? 'Rival').toString();
    final String fecha = (partido['fecha'] ?? '-').toString();
    final String hora = (partido['hora'] ?? '-').toString();
    final int fechaNumero = (partido['fechaNumero'] ?? 0) as int;
    final String? escudoRival = partido['escudoRival'] as String?;

    return GestureDetector(
      onTap: () async {
        if (estaFinalizadoV2) {
          final finalizado = _finalizadosV2.firstWhere(
            (p) =>
                PartidoRepositoryV2.buildMatchIdentityFromModel(p) == identidad,
          );

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  ResumenPartidoFinalizadoScreen(partido: finalizado.toMap()),
            ),
          );
        } else {
          _abrirPartido(context, partido);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF0F1722).withOpacity(0.88),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.04)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildStatusChip('Fecha $fechaNumero'),
                const SizedBox(width: 8),
                _buildStatusChip(estaFinalizadoV2 ? 'Finalizado' : 'Pendiente'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Center(
                    child: escudoRival == null
                        ? const Icon(
                            Icons.sports_handball,
                            color: Color(0xFF1C2B44),
                            size: 22,
                          )
                        : Image.asset(escudoRival, fit: BoxFit.contain),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    rival,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            //const Text('•', style: TextStyle(color: Color(0xFF7C8BA0))),
            Row(
              children: [
                const SizedBox(width: 2), // pequeño ajuste fino

                Text(
                  fecha,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFFAAB4C3),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 6),

                const Text(
                  '•',
                  style: TextStyle(color: Color(0xFF7C8BA0), fontSize: 12),
                ),
                const SizedBox(width: 6),

                Text(
                  hora,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFFAAB4C3),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 6),

                const Text(
                  '•',
                  style: TextStyle(color: Color(0xFF7C8BA0), fontSize: 12),
                ),
                const SizedBox(width: 6),

                Text(
                  somosLocales ? 'Local' : 'Visitante',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFFAAB4C3),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildOpenButton(
              text: estaFinalizadoV2 ? 'Ver resumen' : 'Abrir partido',
              onTap: () async {
                if (estaFinalizadoV2) {
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
                } else {
                  _abrirPartido(context, partido);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    final bool esFinalizado = status.toLowerCase() == 'finalizado';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: esFinalizado
            ? const Color(0xFF1E7D4F)
            : const Color(0xFF182338).withOpacity(0.95),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 12,
          color: esFinalizado ? Colors.white : const Color(0xFFDCE4EF),
          fontWeight: FontWeight.w600,
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
  bool get _somosLocales => partidoV2.condicion == 'Local';

  String get _nombreLocal => _somosLocales ? 'San Fernando' : partidoV2.rival;

  String get _nombreVisitante =>
      _somosLocales ? partidoV2.rival : 'San Fernando';

  int get _golesLocal => _somosLocales ? golesSanFernando : golesRival;
  int get _golesVisitante => _somosLocales ? golesRival : golesSanFernando;

  String get _escudoLocalPath {
    if (_somosLocales) return 'assets/images/san_fernando.png';
    return partidoV2.escudoRival ?? 'assets/images/san_fernando.png';
  }

  String get _escudoVisitantePath {
    if (_somosLocales) {
      return partidoV2.escudoRival ?? 'assets/images/san_fernando.png';
    }
    return 'assets/images/san_fernando.png';
  }

  void _asegurarConvocatoriaDefaultSoloArqueros() {
    final squadMap = widget.partido['matchSquad'] as Map<String, dynamic>?;

    if (squadMap != null) return;

    final categoria = (widget.partido['categoria'] ?? 'Cadetes').toString();

    final arqueros = RosterRepository.goalkeepersForCategory(
      categoria: categoria,
      temporada: '2026',
    );

    widget.partido['matchSquad'] = MatchSquadConfig(
      convocadosIds: arqueros.map((p) => p.playerId).toSet(),
      arquerosIds: arqueros.map((p) => p.playerId).toSet(),
    ).toMap();
  }

  Future<void> _irAPartidoEnVivo() async {
    _asegurarConvocatoriaDefaultSoloArqueros();
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
    final dynamic matchSquadActual = widget.partido['matchSquad'];

    widget.partido
      ..clear()
      ..addAll(actualizadoMap)
      ..['esPartidoReal'] = esPartidoRealActual;

    if (matchSquadActual != null) {
      widget.partido['matchSquad'] = matchSquadActual;
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
          content: Text('No encontré este partido en el historial finalizado'),
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
  /// pero sin alterar la lógica actual de la pantalla.
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
    required String assetPath,
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
          child: Center(child: Image.asset(assetPath, fit: BoxFit.contain)),
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
  /// Muestra métricas rápidas del partido.
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
          _buildSummaryRow('Pérdidas', '$_perdidasV2'),
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
  /// Si está vacío, el evento queda como jugador genérico.
  String? jugadorSeleccionado;
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

  bool get _hasUndoableGameEvents {
    return gameEvents.any((e) => e.isUndoableGameEvent);
  }

  String? currentGoalkeeperNumber; // '33' o '1'

  static const String _liveMatchStorageKey = 'live_match_current_v1';
  static const String _finishedMatchesStorageKey =
      'finished_matches_history_v1';

  String _normalizeValue(dynamic value) {
    return (value ?? '')
        .toString()
        .trim()
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u');
  }

  String get _matchIdentity {
    return [
      _normalizeValue(widget.partido['torneo']),
      _normalizeValue(widget.partido['categoria']),
      _normalizeValue(widget.partido['fecha']),
      _normalizeValue(widget.partido['rival']),
      _normalizeValue(widget.partido['condicion']),
    ].join('|');
  }

  bool get _isArgentinosJuniorsOfficialMatch {
    return _normalizeValue(widget.partido['torneo']) == 'apertura' &&
        _normalizeValue(widget.partido['categoria']) == 'cadetes' &&
        _normalizeValue(widget.partido['fecha']) == '4' &&
        _normalizeValue(widget.partido['rival']) == 'argentinos juniors' &&
        _normalizeValue(widget.partido['condicion']) == 'local';
  }

  List<PlayerProfile> get _jugadoresConvocados {
    final squadMap = widget.partido['matchSquad'] as Map<String, dynamic>?;

    final snapshotRaw = widget.partido['matchRosterSnapshot'] as List<dynamic>?;

    final rosterBase = snapshotRaw == null
        ? RosterRepository.rosterForCategory(
            categoria: widget.partido['categoria'],
            temporada: '2026',
            includeStaff: false,
          )
        : snapshotRaw
              .map(
                (e) =>
                    PlayerProfile.fromMap(Map<String, dynamic>.from(e as Map)),
              )
              .toList();

    if (squadMap == null) {
      return rosterBase.where((p) => p.esArquero).toList();
    }

    final squad = MatchSquadConfig.fromMap(squadMap);

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

  List<PlayerProfile> _availableGoalkeepersForMatch() {
    final matchSquad = widget.partido['matchSquad'] as Map<String, dynamic>?;

    if (matchSquad != null) {
      final config = MatchSquadConfig.fromMap(matchSquad);

      final arquerosConvocados = RosterRepository.players.where((p) {
        return p.esArquero && config.arquerosIds.contains(p.playerId);
      }).toList();

      if (arquerosConvocados.isNotEmpty) {
        return arquerosConvocados;
      }
    }

    final categoria = (widget.partido['categoria'] ?? 'Cadetes').toString();

    return RosterRepository.goalkeepersForCategory(
      categoria: categoria,
      temporada: '2026',
    );
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
    switch (_normalizeValue(widget.partido['rival'])) {
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
        return null;
    }
  }

  Map<String, dynamic> _toPersistedMatchMap() {
    return {
      'version': 1,
      'matchIdentity': _matchIdentity,
      'partido': Map<String, dynamic>.from(widget.partido),
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

  bool get _somosLocales => widget.partido['condicion'] == 'Local';

  String get _nombreLocalEnVivo => _somosLocales
      ? 'San Fernando'
      : (widget.partido['rival'] ?? 'Rival').toString();

  String get _nombreVisitanteEnVivo => _somosLocales
      ? (widget.partido['rival'] ?? 'Rival').toString()
      : 'San Fernando';

  String? get _escudoLocalEnVivo =>
      _somosLocales ? 'assets/images/san_fernando.png' : _rivalShieldAsset();

  String? get _escudoVisitanteEnVivo =>
      _somosLocales ? _rivalShieldAsset() : 'assets/images/san_fernando.png';

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
                    'Deshacer último evento',
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
                    'Deshacer sanción',
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
                            text: mostrarContra ? 'Contra' : 'Pérdida',
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
                            text: 'Penal',
                            onTap:
                                _isPlayLocked() ||
                                    _isPenaltyShootout() ||
                                    modo == null
                                ? null
                                : _iniciarFlujoPenalNormal,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildEventButton(
                            text: 'Sanción',
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
    return Container(
      width: 34,
      height: 34,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
      ),
      padding: const EdgeInsets.all(6),
      child: Center(
        child: assetPath == null
            ? const Icon(
                Icons.sports_handball,
                size: 18,
                color: Color(0xFF1C2B44),
              )
            : Image.asset(assetPath, fit: BoxFit.contain),
      ),
    );
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

  Widget _goalCell(String label) {
    final bool isSelected = zonaTiro != null && zonaArco == label;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _isPlayLocked() || modo == null
          ? null
          : () {
              if (_isPenaltyShootout()) {
                setState(() {
                  zonaArco = label;
                });
                _showPenaltyShootoutResultSheet();
                return;
              }

              if (penalEnCurso) {
                setState(() {
                  zonaArco = label;
                });
                _showNormalPenaltyResultSheet();
                return;
              }

              if (zonaTiro == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Primero seleccioná zona de tiro'),
                  ),
                );
                return;
              }

              setState(() {
                if (zonaArco == label) {
                  zonaArco = null;
                } else {
                  zonaArco = label;
                }
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
  }) {
    _contadorEventoId++;

    final now = DateTime.now();

    final legacyEvent = <String, dynamic>{
      'id': _contadorEventoId,
      'timestamp': now.toIso8601String(),
      'estadoPartido': estadoPartido,
      'modo': modoEvento ?? modo,
      'origenJugada': origenJugadaActual,
      'tipo': tipo,
      'resultado': resultado,
      'actorPrincipal': actorPrincipal,
      'actorSecundario': actorSecundario,
      'zonaTiro': zonaTiroValor,
      'zonaArco': zonaArcoValor,
      'detalle': detalle,
      'subtipo': subtipo,
      'mantieneContexto': mantieneContexto,
      'prevState': prevState == null
          ? null
          : Map<String, dynamic>.from(prevState),
      'arquero': currentGoalkeeperNumber,
    };
    debugPrint(
      'EVENTO -> tipo:$tipo resultado:$resultado modo:${modoEvento ?? modo} actor:$actorPrincipal zonaTiro:$zonaTiroValor zonaArco:$zonaArcoValor',
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
                'Seleccioná tipo de pérdida',
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
              _floatingOption('Invasión', () {
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
              _floatingOption('Error técnico', () {
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
      fallbackAtaque: 'Jugador genérico ataque',
      fallbackDefensa: 'Jugador genérico defensa',
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
      fallbackAtaque: 'Jugador genérico ataque',
      fallbackDefensa: 'Jugador genérico defensa',
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
    final Map<String, dynamic> prevState = _captureStateSnapshot();

    setState(() {
      if (contraDebeCambiarModo) {
        modo = modo == 'ataque' ? 'defensa' : 'ataque';
      }
      mostrarContra = false;
      zonaTiro = null;
      zonaArco = null;
      jugadorSeleccionado = null;
      origenJugadaActual = 'contra';
      contraDebeCambiarModo = true;
    });

    _registrarEvento(
      tipo: 'contra',
      resultado: 'inicio_contra',
      actorPrincipal: 'Cambio de contexto',
      detalle: 'Se activa contragolpe',
      subtipo: 'inicio_contra',
      mantieneContexto: false,
      prevState: prevState,
    );
  }

  void _iniciarFlujoPenalNormal() {
    final String actor = _actorPrincipalActual(
      fallbackAtaque: 'Jugador genérico ataque',
      fallbackDefensa: 'Arquero genérico',
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

                  // 🔥 NUEVA LÓGICA:
                  // no cambia modo automáticamente
                  // solo habilita contra
                  mostrarContra = true;
                  contraDebeCambiarModo = true;
                });

                _registrarEvento(
                  tipo: 'penal',
                  resultado: 'atajado',
                  actorPrincipal: actor,
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
                '¿A quién querés sancionar?',
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
                'Sanción para $actor',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              _floatingOption('Exclusión 2 min', () {
                final Map<String, dynamic> prevState = _captureStateSnapshot();

                setState(() {
                  exclusiones2Min++;
                });

                _registrarEvento(
                  tipo: 'sancion',
                  resultado: 'exclusion_2_min',
                  actorPrincipal: actor,
                  detalle: 'Exclusión de 2 minutos',
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

  void _showZoneActionSheet() {
    if (zonaArco == null || modo == null) return;

    final String currentMode = modo!;

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
                'Resultado → $zonaArco',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),

              _floatingOption('Gol', () {
                final Map<String, dynamic> prevState = _captureStateSnapshot();
                final String modoAntesDelEvento = currentMode;

                Navigator.pop(context);

                _prepararORegistrarTiroNormal(
                  resultado: 'gol',
                  modoAntesDelEvento: modoAntesDelEvento,
                  mantieneContexto: false,
                  prevState: prevState,
                );
              }),

              _floatingOption('Atajado', () {
                final Map<String, dynamic> prevState = _captureStateSnapshot();
                final String modoAntesDelEvento = currentMode;

                Navigator.pop(context);

                _prepararORegistrarTiroNormal(
                  resultado: 'atajado',
                  modoAntesDelEvento: modoAntesDelEvento,
                  mantieneContexto: true,
                  prevState: prevState,
                );
              }),

              _floatingOption('Fuera', () {
                final Map<String, dynamic> prevState = _captureStateSnapshot();
                final String modoAntesDelEvento = currentMode;

                Navigator.pop(context);

                _prepararORegistrarTiroNormal(
                  resultado: 'fuera',
                  modoAntesDelEvento: modoAntesDelEvento,
                  mantieneContexto: false,
                  prevState: prevState,
                );
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

  void _prepararORegistrarTiroNormal({
    required String resultado,
    required String modoAntesDelEvento,
    required bool mantieneContexto,
    required Map<String, dynamic> prevState,
  }) async {
    final bool necesitaJugador =
        modoAntesDelEvento == 'ataque' && _jugadoresCampoConvocados.isNotEmpty;

    if (necesitaJugador) {
      setState(() {
        _tiroPendienteResultado = resultado;
        _tiroPendienteModo = modoAntesDelEvento;
        _tiroPendienteZonaTiro = zonaTiro;
        _tiroPendienteZonaArco = zonaArco;
        _tiroPendienteMantieneContexto = mantieneContexto;
        _tiroPendientePrevState = prevState;
        mostrarSelectorLateralJugador = true;
      });
      return;
    }

    final actor = await _actorParaTiro(modoAntesDelEvento);

    _registrarTiroNormalResuelto(
      resultado: resultado,
      modoAntesDelEvento: modoAntesDelEvento,
      actor: actor,
      zonaTiroEvento: zonaTiro,
      zonaArcoEvento: zonaArco,
      mantieneContexto: mantieneContexto,
      prevState: prevState,
    );
  }

  void _registrarTiroNormalResuelto({
    required String resultado,
    required String modoAntesDelEvento,
    required String actor,
    required String? zonaTiroEvento,
    required String? zonaArcoEvento,
    required bool mantieneContexto,
    required Map<String, dynamic> prevState,
  }) {
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
      zonaTiroValor: zonaTiroEvento,
      zonaArcoValor: zonaArcoEvento,
      mantieneContexto: mantieneContexto,
      prevState: prevState,
      modoEvento: modoAntesDelEvento,
    );

    _clearSelection(
      keepContra: resultado == 'atajado' || modoAntesDelEvento == 'defensa',
    );
  }

  void _seleccionarJugadorParaTiroPendiente(PlayerProfile jugador) {
    final dorsal = jugador.numeroPreferido ?? '-';
    final nombre = '${jugador.apellido}, ${jugador.nombre}'.trim();
    final actor = '$dorsal · $nombre';

    final resultado = _tiroPendienteResultado;
    final modoPendiente = _tiroPendienteModo;
    final prevState = _tiroPendientePrevState;

    if (resultado == null || modoPendiente == null || prevState == null) return;

    jugadorSeleccionado = actor;

    _registrarTiroNormalResuelto(
      resultado: resultado,
      modoAntesDelEvento: modoPendiente,
      actor: actor,
      zonaTiroEvento: _tiroPendienteZonaTiro,
      zonaArcoEvento: _tiroPendienteZonaArco,
      mantieneContexto: _tiroPendienteMantieneContexto,
      prevState: prevState,
    );

    _tiroPendienteResultado = null;
    _tiroPendienteModo = null;
    _tiroPendienteZonaTiro = null;
    _tiroPendienteZonaArco = null;
    _tiroPendientePrevState = null;
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
          '¿Seguro que querés finalizar el partido?',
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
          label: 'Quitar exclusión 2 min',
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
                'Deshacer sanción',
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
          content: Text('No hay una sanción de ese tipo para revertir'),
        ),
      );
      return;
    }

    _registrarEvento(
      tipo: 'correccion_sancion',
      resultado: tipoSancion,
      actorPrincipal: 'Corrección manual',
      detalle: 'Se revierte sanción',
      subtipo: 'undo_sancion',
      mantieneContexto: true,
      prevState: prevState,
    );
  }
}

///=======================
///=======================
///heatmap de eventos, estadísticas detalladas por jugador, exportación de datos, etc.
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
  const HistorialScreen({super.key});

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

  @override
  void initState() {
    super.initState();
    _cargarHistorial();
  }

  Future<void> _cargarHistorial() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_finishedMatchesStorageKey);

    List<Map<String, dynamic>> items = [];

    if (raw != null && raw.isNotEmpty) {
      final decoded = jsonDecode(raw) as List<dynamic>;

      items = decoded.map((e) {
        final map = Map<String, dynamic>.from(e as Map);
        final partido = Map<String, dynamic>.from(
          (map['partido'] as Map?)?.cast<String, dynamic>() ??
              <String, dynamic>{},
        );

        return {
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
        };
      }).toList();

      items.sort((a, b) {
        final aDate = DateTime.tryParse((a['archivedAt'] ?? '').toString());
        final bDate = DateTime.tryParse((b['archivedAt'] ?? '').toString());

        if (aDate == null && bDate == null) return 0;
        if (aDate == null) return 1;
        if (bDate == null) return -1;
        return bDate.compareTo(aDate);
      });
    }

    setState(() {
      _todos = items;
      _aplicarFiltros();
    });
  }

  void _aplicarFiltros() {
    final q = _busqueda.trim().toLowerCase();

    _filtrados = _todos.where((p) {
      final rival = (p['rival'] ?? '').toString().toLowerCase();
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
    final r = rival.toLowerCase();

    if (r.contains('argentinos')) return 'assets/images/argentinos.png';
    if (r.contains('ferro')) return 'assets/images/ferro.png';
    if (r.contains('vélez') || r.contains('velez')) {
      return 'assets/images/velez.png';
    }
    if (r.contains('campana')) return 'assets/images/campana.png';
    if (r.contains('river')) return 'assets/images/river.png';
    if (r.contains('dorrego')) return 'assets/images/dorrego.png';
    if (r.contains('ballester')) return 'assets/images/ballester.png';
    if (r.contains('s.a.g.a.b.') || r.contains('sagab')) {
      return 'assets/images/sagab.png';
    }
    if (r.contains('quilmes')) return 'assets/images/quilmes.png';
    if (r.contains('lanús') || r.contains('lanus')) {
      return 'assets/images/lanus.png';
    }
    if (r.contains('s.e.d.a.l.o.') || r.contains('sedalo')) {
      return 'assets/images/sedalo.png';
    }
    if (r.contains('vicente lópez') || r.contains('vicente lopez')) {
      return 'assets/images/vicente_lopez.png';
    }
    if (r.contains('estudiantes')) {
      return 'assets/images/estudiantes_lp.png';
    }
    if (r.contains('ward')) return 'assets/images/ward.png';
    if (r.contains('luján') || r.contains('lujan')) {
      return 'assets/images/nsl.png';
    }

    return null;
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
                      Row(
                        children: [
                          Expanded(
                            child: _buildDropdown<String>(
                              value: _categoriaSeleccionada,
                              items: const ['Todas', 'Cadetes', 'Juveniles'],
                              onChanged: (value) {
                                if (value == null) return;
                                setState(() {
                                  _categoriaSeleccionada = value;
                                  _aplicarFiltros();
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildDropdown<String>(
                              value: _torneoSeleccionado,
                              items: const ['Todos', 'Apertura', 'Clausura'],
                              onChanged: (value) {
                                if (value == null) return;
                                setState(() {
                                  _torneoSeleccionado = value;
                                  _aplicarFiltros();
                                });
                              },
                            ),
                          ),
                        ],
                      ),
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
                            final rival = (partido['rival'] ?? 'Rival')
                                .toString();
                            final escudo = _rivalShieldAsset(rival);
                            final golesSF =
                                (partido['golesSanFernando'] ?? 0) as int;
                            final golesR = (partido['golesRival'] ?? 0) as int;

                            return GestureDetector(
                              onTap: () {
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
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF0F1722,
                                  ).withOpacity(0.84),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.04),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 54,
                                      height: 54,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white,
                                      ),
                                      padding: const EdgeInsets.all(8),
                                      child: Center(
                                        child: escudo == null
                                            ? const Icon(
                                                Icons.sports_handball,
                                                color: Color(0xFF1C2B44),
                                                size: 22,
                                              )
                                            : Image.asset(
                                                escudo,
                                                fit: BoxFit.contain,
                                              ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'San Fernando vs $rival',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '${partido['categoria']} · ${partido['torneo']}',
                                            style: const TextStyle(
                                              color: Color(0xFFAAB4C3),
                                              fontSize: 12,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '${partido['fecha']} • ${partido['hora']}',
                                            style: const TextStyle(
                                              color: Color(0xFFAAB4C3),
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          '$golesSF - $golesR',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 22,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        const Text(
                                          'Ver resumen',
                                          style: TextStyle(
                                            color: Color(0xFF4F8CFF),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
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

///===============================
///===============================
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
  bool get isMiss => resultado == 'fuera' || resultado == 'desvio';
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

    // Separación arco / zona
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

class EstadisticasScreen extends StatelessWidget {
  const EstadisticasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Estadísticas')),
      body: const Center(child: Text('Pantalla Estadísticas')),
    );
  }
}

///===============================
/// EQUIPOS
/// gestion de jugadores, arqueros, cuerpo técnico, categorías, convocados por partido, etc.
///===============================
///===============================

/// ===============================
/// EQUIPO 2.1
/// Gestión deportiva del equipo.
/// Acá NO va importación/exportación.
/// La convocatoria por partido queda en Centro de control.
/// ===============================
class EquiposScreen extends StatelessWidget {
  final String categoriaInicial;
  final String temporada;

  const EquiposScreen({
    super.key,
    required this.categoriaInicial,
    required this.temporada,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Equipo'),
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
                    'Gestión de estructura deportiva',
                    style: TextStyle(color: Color(0xFFD4DCE7), fontSize: 14),
                  ),
                  const SizedBox(height: 18),
                  _buildEquipoActionCard(
                    context: context,
                    icon: Icons.groups_rounded,
                    title: 'Plantel',
                    subtitle: 'Jugadores, arqueros y cuerpo técnico',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PlantelScreen(
                            categoriaInicial: categoriaInicial,
                            temporada: temporada,
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

  const PlantelScreen({
    super.key,
    required this.categoriaInicial,
    required this.temporada,
  });

  @override
  State<PlantelScreen> createState() => _PlantelScreenState();
}

@override
State<PlantelScreen> createState() => _PlantelScreenState();

class _PlantelScreenState extends State<PlantelScreen> {
  late String categoriaSeleccionada;

  @override
  void initState() {
    super.initState();

    /// La categoría inicial viene desde el contexto activo del Home.
    categoriaSeleccionada = widget.categoriaInicial;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Plantel'),
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
                  const SizedBox(height: 18),
                  _buildCategoriaSelector(),
                  const SizedBox(height: 18),
                  _buildPlantelCard(
                    icon: Icons.sports_handball_rounded,
                    title: 'Jugadores',
                    subtitle: 'Jugadores de campo de $categoriaSeleccionada',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => JugadoresCampoScreen(
                            categoria: categoriaSeleccionada,
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
                          builder: (_) =>
                              ArquerosScreen(categoria: categoriaSeleccionada),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildPlantelCard(
                    icon: Icons.badge_rounded,
                    title: 'Cuerpo técnico',
                    subtitle: 'Estructura técnica de $categoriaSeleccionada',
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
              ),
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

  const ArquerosScreen({super.key, required this.categoria});

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
      temporada: '2026',
    );

    final roster = await RosterStorage.readRosterForCategory(
      categoria: widget.categoria,
      temporada: '2026',
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
      temporada: '2026',
      includeStaff: true,
    );

    final nuevoArquero = PlayerProfile(
      playerId: 'local_gk_${DateTime.now().millisecondsSinceEpoch}',
      clubId: RosterRepository.currentClub.clubId,
      nombre: nombre,
      apellido: apellido,
      posicion: 'Arquero',
      numeroPreferido: dorsal.isEmpty ? null : dorsal,
      esArquero: true,
      esCuerpoTecnico: false,
    );

    await RosterStorage.saveRosterForCategory(
      categoria: widget.categoria,
      temporada: '2026',
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
  /// También permite eliminarlo del plantel persistente.
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
  /// No borra eventos históricos ya cargados.
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
          '¿Seguro que querés eliminar a ${arquero.displayName} de ${widget.categoria}?',
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

  /// Campo visual reutilizable para alta/edición de arquero.
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

/// ===============================
/// JUGADORES CAMPO 2.1
/// Lee jugadores de campo desde el plantel persistente.
/// Si no hay datos guardados, inicializa desde el hardcode actual.
/// ===============================
class JugadoresCampoScreen extends StatefulWidget {
  final String categoria;

  const JugadoresCampoScreen({super.key, required this.categoria});

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
      temporada: '2026',
    );

    final roster = await RosterStorage.readRosterForCategory(
      categoria: widget.categoria,
      temporada: '2026',
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
                _inputAltaJugador('Posición', posicionController),
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
      temporada: '2026',
      includeStaff: true,
    );

    final nuevoJugador = PlayerProfile(
      playerId: 'local_${DateTime.now().millisecondsSinceEpoch}',
      clubId: RosterRepository.currentClub.clubId,
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
      temporada: '2026',
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
  /// Permite modificar nombre, apellido, dorsal y posición.
  /// También permite eliminarlo del plantel persistente.
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
                _inputAltaJugador('Posición', posicionController),
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
  /// No borra eventos históricos ya cargados.
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
          '¿Seguro que querés eliminar a ${jugador.displayName} de ${widget.categoria}?',
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
                                    nombre.isNotEmpty ? nombre : 'Jugador',
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
/// CUERPO TÉCNICO 2.1
/// Lee cuerpo técnico desde plantel persistente.
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
  /// ALTA CUERPO TÉCNICO
  /// Crea un integrante del cuerpo técnico
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
          'Agregar cuerpo técnico',
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
    ).showSnackBar(const SnackBar(content: Text('Cuerpo técnico agregado')));
  }

  /// ===============================
  /// EDITAR CUERPO TÉCNICO
  /// Edita nombre, apellido y rol.
  /// También permite eliminar.
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
          'Editar cuerpo técnico',
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
    ).showSnackBar(const SnackBar(content: Text('Cuerpo técnico actualizado')));
  }

  /// ===============================
  /// ELIMINAR CUERPO TÉCNICO
  /// Elimina el integrante técnico de esta categoría.
  /// ===============================
  Future<void> _confirmarEliminarStaff(PlayerProfile staff) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF0F1722),
        title: const Text(
          'Eliminar cuerpo técnico',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          '¿Seguro que querés eliminar a ${staff.displayName} de ${widget.categoria}?',
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
    ).showSnackBar(const SnackBar(content: Text('Cuerpo técnico eliminado')));
  }

  /// Campo visual reutilizable para alta/edición de cuerpo técnico.
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
        title: const Text('Cuerpo técnico'),
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
                      'No hay cuerpo técnico cargado',
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
                                nombre.isNotEmpty ? nombre : 'Staff',
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
