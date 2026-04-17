import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';


/// ===============================
/// PUNTO DE ENTRADA
/// ===============================
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
/// HOME PRINCIPAL
/// ===============================
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool tieneInstitucion = true;
  final String institucionNombre = 'San Fernando Handball';
  final bool hayMasDeUnaTemporada = false;

  final List<String> contexto = <String>[
    '2026',
    'Local',
    'Apertura',
    'Cadetes',
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

  void _openSection(BuildContext context, String title) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          switch (title) {
            case 'Próximo partido':
              return const ProximoPartidoScreen();
            case 'Partidos jugados':
              return const HistorialScreen();
            case 'Estadísticas':
              return const EstadisticasScreen();
            case 'Equipo':
              return const EquiposScreen();
            case 'Jugadores':
              return const JugadoresScreen();
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
            'Seguimiento y estadísticas',
            style: TextStyle(
              fontSize: 15,
              color: Color(0xFFD5DCE5),
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        IconButton(
          onPressed: () {},
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
      padding: const EdgeInsets.only(top: 6),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: 18),
            padding: const EdgeInsets.fromLTRB(14, 42, 14, 14),
            decoration: BoxDecoration(
              color: const Color(0xFF0D1520).withOpacity(0.18),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: const Color(0xFF3FA2FF).withOpacity(0.95),
                width: 1.4,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildContextSection(),
                const SizedBox(height: 8),
                _buildActionTile(
                  imagePath: 'assets/icons/icon_proximo_partido.png',
                  title: 'Próximo partido',
                  subtitle: 'Fixture y agenda',
                ),
                const SizedBox(height: 3),
                _buildActionTile(
                  imagePath: 'assets/icons/icon_partidos_jugados.png',
                  title: 'Partidos jugados',
                  subtitle: 'Historial cargado',
                ),
                const SizedBox(height: 8),
                Container(height: 1, color: Colors.white.withOpacity(0.06)),
                const SizedBox(height: 6),
                _buildActionTile(
                  imagePath: 'assets/icons/icon_estadisticas.png',
                  title: 'Estadísticas',
                  subtitle: 'Rendimiento y análisis',
                ),
                const SizedBox(height: 8),
                Container(height: 1, color: Colors.white.withOpacity(0.06)),
                const SizedBox(height: 6),
                _buildActionTile(
                  imagePath: 'assets/icons/icon_equipos.png',
                  title: 'Equipo',
                  subtitle: 'Categorías y estructura',
                ),
                const SizedBox(height: 5),
                _buildActionTile(
                  imagePath: 'assets/icons/icon_jugador_campo.png',
                  title: 'Jugadores',
                  subtitle: 'Plantel y perfiles',
                ),
              ],
            ),
          ),
          Positioned(
            top: -10,
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
          final bool removable = index == 0 ? hayMasDeUnaTemporada : true;

          return Padding(
            padding: EdgeInsets.only(
              right: index == contexto.length - 1 ? 0 : 4,
            ),
            child: _buildContextToken(
              text: value,
              removable: removable,
              onRemove: removable
                  ? () {
                      setState(() {
                        contexto.removeAt(index);
                      });
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
///
///
class ProximoPartidoScreen extends StatefulWidget {
  const ProximoPartidoScreen({super.key});

  @override
  State<ProximoPartidoScreen> createState() => _ProximoPartidoScreenState();
}

class _ProximoPartidoScreenState extends State<ProximoPartidoScreen> {
  bool hayPartido = true;

  final Map<String, dynamic> proximoPartido = {
    'rival': 'Argentinos Juniors',
    'fecha': 'Sabado 18/04',
    'hora': '13:00',
    'condicion': 'Local',
    'torneo': 'Local Apertura',
    'categoria': 'Cadetes',
    'estado': 'Pendiente',
  };

  final List<Map<String, String>> siguientesPartidos = [
    {
      'rival': 'River Plate',
      'fecha': 'Sab 25/04',
      'hora': '15:30',
      'condicion': 'Visitante',
    },
    {
      'rival': 'SEDALO',
      'fecha': 'Sab 02/05',
      'hora': '13:00',
      'condicion': 'Local',
    },
    {
      'rival': 'Ferro',
      'fecha': 'Sab 08/05',
      'hora': '13:00',
      'condicion': 'Visitante',
    },
  ];

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
          text: 'Iniciar partido',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PartidoEnJuegoScreen(partido: proximoPartido),
              ),
            );
          },
        ),
        const SizedBox(height: 10),
        _buildOutlinedAction(
          text: 'Editar partido',
          onTap: () {
            debugPrint('Editar partido');
          },
        ),
        const SizedBox(height: 10),
        _buildOutlinedAction(
          text: 'Marcar como jugado',
          onTap: () {
            debugPrint('Marcar como jugado');
          },
        ),
      ],
    );
  }

  Widget _buildEstadoSinPartido() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildScreenHeader(),
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

  Widget _buildMatchCard() {
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
          _buildStatusChip(proximoPartido['estado']),
          const SizedBox(height: 14),
          Row(
            children: [
              _buildTeamBadge(),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  proximoPartido['rival'],
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
          _buildInfoRow('Condición', proximoPartido['condicion']),
        ],
      ),
    );
  }

  Widget _buildUpcomingList() {
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
        ...siguientesPartidos.map(_buildUpcomingItem),
      ],
    );
  }

  Widget _buildUpcomingItem(Map<String, String> partido) {
    return GestureDetector(
      onTap: () {
        setState(() {
          final partidoActualAnterior = {
            'rival': proximoPartido['rival'].toString(),
            'fecha': proximoPartido['fecha'].toString(),
            'hora': proximoPartido['hora'].toString(),
            'condicion': proximoPartido['condicion'].toString(),
          };

          final nuevosSiguientes = siguientesPartidos
              .where((p) => p != partido)
              .toList();

          nuevosSiguientes.add(partidoActualAnterior);

          proximoPartido['rival'] = partido['rival']!;
          proximoPartido['fecha'] = partido['fecha']!;
          proximoPartido['hora'] = partido['hora']!;
          proximoPartido['condicion'] = partido['condicion']!;
          proximoPartido['estado'] = 'Pendiente';

          siguientesPartidos
            ..clear()
            ..addAll(nuevosSiguientes);
        });
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
                child: Image.asset(
                  'assets/images/san_fernando.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                partido['rival']!,
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
              partido['condicion']!,
              style: const TextStyle(color: Color(0xFF4DA3FF), fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamBadge() {
    return Container(
      width: 58,
      height: 58,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
      ),
      padding: const EdgeInsets.all(8),
      child: Center(
        child: Image.asset(
          'assets/images/san_fernando.png',
          fit: BoxFit.contain,
        ),
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
/// FIXTURE
/// ===============================
/// ===============================
///
///
class FixtureScreen extends StatelessWidget {
  final String categoria;
  final String torneo;

  const FixtureScreen({
    super.key,
    required this.categoria,
    required this.torneo,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1320),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Fixture'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$categoria • $torneo',
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 16),
            const Text(
              'Fixture completo (próximo paso)',
              style: TextStyle(color: Colors.white),
            ),
          ],
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
///
///
class PartidoEnJuegoScreen extends StatefulWidget {
  final Map<String, dynamic> partido;

  const PartidoEnJuegoScreen({super.key, required this.partido});

  @override
  State<PartidoEnJuegoScreen> createState() => _PartidoEnJuegoScreenState();
}

class _PartidoEnJuegoScreenState extends State<PartidoEnJuegoScreen> {
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

  bool get _partidoFinalizado => estadoPartido == 'finalizado';
  bool get _somosLocales => widget.partido['condicion'] == 'Local';

  String get _nombreLocal =>
      _somosLocales ? 'San Fernando' : (widget.partido['rival'] ?? 'Rival');

  String get _nombreVisitante =>
      _somosLocales ? (widget.partido['rival'] ?? 'Rival') : 'San Fernando';

  int get _golesLocal => _somosLocales ? golesSanFernando : golesRival;
  int get _golesVisitante => _somosLocales ? golesRival : golesSanFernando;

  String get _escudoLocalPath {
    if (_somosLocales) return 'assets/images/san_fernando.png';
    return (widget.partido['escudoRival'] as String?) ??
        'assets/images/san_fernando.png';
  }

  String get _escudoVisitantePath {
    if (_somosLocales) {
      return (widget.partido['escudoRival'] as String?) ??
          'assets/images/san_fernando.png';
    }
    return 'assets/images/san_fernando.png';
  }

  Future<void> _irAPartidoEnVivo() async {
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
      });
    }
  }

  void _abrirPlantel() {
    debugPrint('Abrir plantel');
  }

  void _abrirResumen() {
    debugPrint('Abrir resumen');
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

  Widget _buildControlHeader() {
    return Text(
      '${widget.partido['categoria']} · ${widget.partido['torneo']}',
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
            '${eficaciaArquero.toStringAsFixed(1)}%',
          ),
          _buildSummaryRow('Pérdidas', '$perdidas'),
          _buildSummaryRow('Recuperaciones', '$recuperaciones'),
          _buildSummaryRow('Penales', '$penales'),
          _buildSummaryRow('Exclusiones 2 min', '$exclusiones2Min'),
          _buildSummaryRow('Tarjetas amarillas', '$amarillas'),
          _buildSummaryRow('Tarjetas rojas', '$rojas'),
          _buildSummaryRow('Eventos cargados', '${eventos.length}'),
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
///
///

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

  String _currentFieldPlayerActorName() {
    return 'Jugador genérico';
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
  static const String _finishedMatchesStorageKey = 'finished_matches_history_v1';

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

  String get _currentGoalkeeperActorName {
    if (currentGoalkeeperNumber == null) return 'Arquero genérico';
    return 'Arquero $currentGoalkeeperNumber';
  }

  String? _rivalShieldAsset() {
    if (_normalizeValue(widget.partido['rival']) == 'argentinos juniors') {
      return 'assets/images/argentinos.png';
    }
    return null;
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
    if (!_isArgentinosJuniorsOfficialMatch) {
      await _clearPersistedLiveMatch();
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_finishedMatchesStorageKey);

    List<dynamic> history = [];
    if (raw != null && raw.isNotEmpty) {
      history = jsonDecode(raw) as List<dynamic>;
    }

    final finishedData = _toPersistedMatchMap()
      ..['archivedAt'] = DateTime.now().toIso8601String()
      ..['finalizado'] = true;

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

    final Map<String, dynamic> data =
        Map<String, dynamic>.from(jsonDecode(raw) as Map);

    if ((data['matchIdentity'] ?? '') != _matchIdentity) return;
    if ((data['estadoPartido'] ?? '') == 'finalizado') return;

    setState(() {
      estadoPartido = (data['estadoPartido'] ?? estadoPartido) as String;
      golesSanFernando =
          (data['golesSanFernando'] ?? golesSanFernando) as int;
      golesRival = (data['golesRival'] ?? golesRival) as int;
      golesRecibidos = (data['golesRecibidos'] ?? golesRecibidos) as int;

      atajadas = (data['atajadas'] ?? atajadas) as int;
      penales = (data['penales'] ?? penales) as int;
      exclusiones2Min =
          (data['exclusiones2Min'] ?? exclusiones2Min) as int;
      amarillas = (data['amarillas'] ?? amarillas) as int;
      rojas = (data['rojas'] ?? rojas) as int;
      perdidas = (data['perdidas'] ?? perdidas) as int;
      recuperaciones = (data['recuperaciones'] ?? recuperaciones) as int;

      penalesConvertidosSanFernando =
          (data['penalesConvertidosSanFernando'] ??
              penalesConvertidosSanFernando) as int;
      penalesConvertidosRival =
          (data['penalesConvertidosRival'] ??
              penalesConvertidosRival) as int;
      penalesIntentadosSanFernando =
          (data['penalesIntentadosSanFernando'] ??
              penalesIntentadosSanFernando) as int;
      penalesIntentadosRival =
          (data['penalesIntentadosRival'] ??
              penalesIntentadosRival) as int;

      modo = data['modo'] as String?;
      zonaTiro = data['zonaTiro'] as String?;
      zonaArco = data['zonaArco'] as String?;
      penalEnCurso = (data['penalEnCurso'] ?? false) as bool;
      actorPenalActual = data['actorPenalActual'] as String?;
      mostrarContra = (data['mostrarContra'] ?? false) as bool;
      contraDebeCambiarModo =
          (data['contraDebeCambiarModo'] ?? true) as bool;
      origenJugadaActual =
          (data['origenJugadaActual'] ?? 'normal') as String;

      modoInicioPrimerTiempo = data['modoInicioPrimerTiempo'] as String?;
      modoInicioPrimerTiempoAlargue =
          data['modoInicioPrimerTiempoAlargue'] as String?;

      currentGoalkeeperNumber =
          data['currentGoalkeeperNumber'] as String?;

      final persistedEvents =
          (data['eventos'] as List<dynamic>? ?? const [])
              .map((e) => Map<String, dynamic>.from(e as Map))
              .toList();

      eventos = persistedEvents;
      gameEvents = eventos
          .map((e) => GameEvent.fromLegacyMap(e))
          .toList();

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
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
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

    gameEvents = eventos
        .map((e) => GameEvent.fromLegacyMap(e))
        .toList();

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
          _buildMiniShield(
            assetPath: 'assets/images/san_fernando.png',
          ),
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
          _buildMiniShield(
            assetPath: _rivalShieldAsset(),
          ),
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
                    onSelected33: () {
                      setState(() {
                        currentGoalkeeperNumber = '33';
                      });
                      _persistLiveMatch();
                    },
                    onSelected1: () {
                      setState(() {
                        currentGoalkeeperNumber = '1';
                      });
                      _persistLiveMatch();
                    },
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
            : Image.asset(
                assetPath,
                fit: BoxFit.contain,
              ),
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
          Expanded(child: Row(children: [
            Expanded(child: _goalCell('AI')),
            const SizedBox(width: 5),
            Expanded(child: _goalCell('AC')),
            const SizedBox(width: 5),
            Expanded(child: _goalCell('AD')),
          ])),
          const SizedBox(height: 3),
          Expanded(child: Row(children: [
            Expanded(child: _goalCell('CI')),
            const SizedBox(width: 5),
            Expanded(child: _goalCell('CC')),
            const SizedBox(width: 5),
            Expanded(child: _goalCell('CD')),
          ])),
          const SizedBox(height: 3),
          Expanded(child: Row(children: [
            Expanded(child: _goalCell('BI')),
            const SizedBox(width: 5),
            Expanded(child: _goalCell('BC')),
            const SizedBox(width: 5),
            Expanded(child: _goalCell('BD')),
          ])),
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
    };

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
    return gameEvents
        .where((e) => e.phase == GameEventPhase.ataque)
        .toList();
  }

  List<GameEvent> get _defenseEvents {
    return gameEvents
        .where((e) => e.phase == GameEventPhase.defensa)
        .toList();
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

    final String actor = modo == 'ataque'
        ? 'Jugador genérico ataque'
        : 'Jugador genérico defensa';

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

    final String actor = modo == 'ataque'
        ? 'Jugador genérico ataque'
        : 'Jugador genérico defensa';

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

    if (!_fueraGestureEnabled || currentMode == null || currentGoalZone == null) {
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
  final String actor = modo == 'ataque'
      ? 'Jugador genérico ataque'
      : 'Arquero genérico';

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
              modo == 'ataque'
                  ? 'Penal nuestro'
                  : 'Penal rival',
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

              _floatingOption('Gol', () {
                final Map<String, dynamic> prevState = _captureStateSnapshot();
                final String modoAntesDelEvento = currentModo;

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

              _floatingOption('Atajado', () {
                final Map<String, dynamic> prevState = _captureStateSnapshot();
                final String modoAntesDelEvento = currentModo;

                setState(() {
                  penales++;

                  if (modoAntesDelEvento == 'defensa') {
                    atajadas++;
                    modo = 'ataque';
                    mostrarContra = true;
                    contraDebeCambiarModo = false;
                  } else {
                    modo = 'defensa';
                    mostrarContra = false;
                  }
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

                _clearSelection(keepContra: modoAntesDelEvento == 'defensa');
                Navigator.pop(context);
              }),

              _floatingOption('Fuera', () {
                final Map<String, dynamic> prevState = _captureStateSnapshot();
                final String modoAntesDelEvento = currentModo;

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

              _floatingOption('Gol', () {
                final Map<String, dynamic> prevState = _captureStateSnapshot();
                final String modoAntesDelEvento = currentModo;

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

              _floatingOption('Atajado', () {
                final Map<String, dynamic> prevState = _captureStateSnapshot();
                final String modoAntesDelEvento = currentModo;

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

              _floatingOption('Fuera', () {
                final Map<String, dynamic> prevState = _captureStateSnapshot();
                final String modoAntesDelEvento = currentModo;

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

  Future<void> _showGoalkeeperSelectorSheet({
    required VoidCallback onSelected33,
    required VoidCallback onSelected1,
    String title = 'Seleccionar arquero',
  }) async {
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
              _floatingOption('Arquero 33', () {
                Navigator.pop(context);
                onSelected33();
              }),
              _floatingOption('Arquero 1', () {
                Navigator.pop(context);
                onSelected1();
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
      onSelected33: () {
        setState(() {
          currentGoalkeeperNumber = '33';
        });
        _persistLiveMatch();
        onAfterSelect();
      },
      onSelected1: () {
        setState(() {
          currentGoalkeeperNumber = '1';
        });
        _persistLiveMatch();
        onAfterSelect();
      },
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
    final String actor = _resolvePrimaryActorForShot(
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

                setState(() {
                  if (modoAntesDelEvento == 'ataque') {
                    golesSanFernando++;
                    modo = 'defensa';
                  } else {
                    golesRival++;
                    golesRecibidos++;
                    modo = 'ataque';
                  }
                  mostrarContra = false;
                });

                _registrarEvento(
                  tipo: 'tiro',
                  resultado: 'gol',
                  actorPrincipal: actor,
                  zonaTiroValor: zonaTiro,
                  zonaArcoValor: zonaArco,
                  mantieneContexto: false,
                  prevState: prevState,
                  modoEvento: modoAntesDelEvento,
                );

                _clearSelection();
                Navigator.pop(context);
              }),

              _floatingOption('Atajado', () {
                final Map<String, dynamic> prevState = _captureStateSnapshot();
                final String modoAntesDelEvento = currentMode;

                setState(() {
                  if (modoAntesDelEvento == 'defensa') {
                    atajadas++;
                    modo = 'ataque';
                    mostrarContra = true;
                    contraDebeCambiarModo = false;
                  } else {
                    modo = 'defensa';
                    mostrarContra = false;
                  }
                });

                _registrarEvento(
                  tipo: 'tiro',
                  resultado: 'atajado',
                  actorPrincipal: actor,
                  zonaTiroValor: zonaTiro,
                  zonaArcoValor: zonaArco,
                  mantieneContexto: true,
                  prevState: prevState,
                  modoEvento: modoAntesDelEvento,
                );

                _clearSelection(keepContra: modoAntesDelEvento == 'defensa');
                Navigator.pop(context);
              }),

              _floatingOption('Fuera', () {
                final Map<String, dynamic> prevState = _captureStateSnapshot();
                final String modoAntesDelEvento = currentMode;

                setState(() {
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
                  tipo: 'tiro',
                  resultado: 'fuera',
                  actorPrincipal: actor,
                  zonaTiroValor: zonaTiro,
                  zonaArcoValor: zonaArco,
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

    void _finalizarPartido() {
    setState(() => estadoPartido = 'finalizado');

    _archiveFinishedMatchIfNeeded();

    Future.delayed(const Duration(milliseconds: 150), () {
      if (!mounted) return;
      _goBack();
    });
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
    });
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
      const SnackBar(
        content: Text('No hay eventos de juego para deshacer'),
      ),
    );
    return;
  }

  final eventoADeshacer = eventos[index];
  final prevState =
      Map<String, dynamic>.from(eventoADeshacer['prevState'] as Map);

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
 ///heatmap de eventos, estadísticas detalladas por jugador, exportación de datos, etc. 
 ///=======================
  
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
  
  ///=======================
  ///heatmap de eventos, estadísticas detalladas por jugador, exportación de datos, etc. 
  ///======================
  
  class _UndoSanctionOption {
    final String label;
    final String resultado;

  const _UndoSanctionOption({required this.label, required this.resultado});
  }

  enum GameEventPhase {
    ataque,
    defensa,
    neutral,
  }

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
        timestamp: DateTime.tryParse(
              (map['timestamp'] ?? '').toString(),
            ) ??
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
        kind == GameEventKind.sancion ||
        kind == GameEventKind.correccionSancion;

    bool get isUndoableGameEvent => !isSanctionLike;

    bool get isGoal => resultado == 'gol';
    bool get isSave => resultado == 'atajado';
    bool get isMiss => resultado == 'fuera' || resultado == 'desvio';
  }

  GameEventKind _gameEventKindFromString(
    String tipo,
    Map<String, dynamic> map,
  ) {
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
  /// PLACEHOLDERS
  /// ==============================
  ///===============================

  class HistorialScreen extends StatelessWidget {
    const HistorialScreen({super.key});

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(title: const Text('Partidos Jugados')),
        body: const Center(child: Text('Pantalla Partidos Jugados')),
      );
    }
  }

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

  class EquiposScreen extends StatelessWidget {
    const EquiposScreen({super.key});

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(title: const Text('Equipos')),
        body: const Center(child: Text('Pantalla Equipos')),
      );
    }
  }

  class JugadoresScreen extends StatelessWidget {
    const JugadoresScreen({super.key});

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(title: const Text('Jugadores')),
        body: const Center(child: Text('Pantalla Jugadores')),
      );
    }
  }
