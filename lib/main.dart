import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
            child: Container(
              color: const Color(0xFF05080D).withOpacity(0.82),
            ),
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
          icon: const Icon(
            Icons.menu_rounded,
            color: Colors.white,
            size: 28,
          ),
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
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () {},
            child: const Text(
              'Importar datos',
              style: TextStyle(
                color: Color(0xFFD7DCE3),
                fontSize: 15,
              ),
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
                Container(
                  height: 1,
                  color: Colors.white.withOpacity(0.06),
                ),
                const SizedBox(height: 6),
                _buildActionTile(
                  imagePath: 'assets/icons/icon_estadisticas.png',
                  title: 'Estadísticas',
                  subtitle: 'Rendimiento y análisis',
                ),
                const SizedBox(height: 8),
                Container(
                  height: 1,
                  color: Colors.white.withOpacity(0.06),
                ),
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
        border: Border.all(
          color: Colors.white.withOpacity(0.03),
        ),
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
        border: Border.all(
          color: Colors.white.withOpacity(0.035),
        ),
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
          border: Border.all(
            color: Colors.white.withOpacity(0.03),
          ),
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

  const _PressableTile({
    required this.child,
    required this.onTap,
  });

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
            child: Container(
              color: const Color(0xFF05080D).withOpacity(0.84),
            ),
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
                builder: (_) => PartidoEnJuegoScreen(
                  partido: proximoPartido,
                ),
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
            border: Border.all(
              color: Colors.white.withOpacity(0.04),
            ),
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
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFFD4DCE7),
          ),
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
        border: Border.all(
          color: Colors.white.withOpacity(0.04),
        ),
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

          final nuevosSiguientes =
              siguientesPartidos.where((p) => p != partido).toList();

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
              style: const TextStyle(
                color: Color(0xFFAAB4C3),
                fontSize: 12,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              partido['condicion']!,
              style: const TextStyle(
                color: Color(0xFF4DA3FF),
                fontSize: 12,
              ),
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
          border: Border.all(
            color: Colors.white.withOpacity(0.04),
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.history,
              size: 18,
              color: Color(0xFFDCE4EF),
            ),
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
            const Icon(
              Icons.chevron_right,
              size: 18,
              color: Color(0xFF8FA3BF),
            ),
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
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
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
          side: BorderSide(
            color: Colors.white.withOpacity(0.08),
          ),
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

/// ===============================
/// FIXTURE
/// ===============================
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
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
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
/// CENTRO DE CONTROL
/// ===============================
class PartidoEnJuegoScreen extends StatefulWidget {
  final Map<String, dynamic> partido;

  const PartidoEnJuegoScreen({
    super.key,
    required this.partido,
  });

  @override
  State<PartidoEnJuegoScreen> createState() => _PartidoEnJuegoScreenState();
}

class _PartidoEnJuegoScreenState extends State<PartidoEnJuegoScreen> {
  int golesSanFernando = 10;
  int golesRival = 7;
  int golesRecibidos = 7;
  int atajadas = 9;
  int perdidas = 5;
  int penales = 2;
  int exclusiones2Min = 3;
  int amarillas = 2;
  int rojas = 1;

  String estadoPartido = 'segundo_tiempo';

  @override
  Widget build(BuildContext context) {
    final bool somosLocales = widget.partido['condicion'] == 'Local';

    final String nombreLocal =
        somosLocales ? 'San Fernando' : widget.partido['rival'];
    final String nombreVisitante =
        somosLocales ? widget.partido['rival'] : 'San Fernando';

    final int golesLocal = somosLocales ? golesSanFernando : golesRival;
    final int golesVisitante = somosLocales ? golesRival : golesSanFernando;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Partido en curso'),
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
            child: Container(
              color: const Color(0xFF05080D).withOpacity(0.86),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildControlHeader(),
                  const SizedBox(height: 18),
                  _buildScoreCard(
                    nombreLocal: nombreLocal,
                    nombreVisitante: nombreVisitante,
                    golesLocal: golesLocal,
                    golesVisitante: golesVisitante,
                  ),
                  const SizedBox(height: 16),
                  _buildPrimaryAction(
                    text: _getPrimaryActionText(),
                    onTap: () async {
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
                          ),
                        ),
                      );

                      if (resultado != null && mounted) {
                        setState(() {
                          estadoPartido = resultado['estadoPartido'] as String;
                          golesSanFernando =
                              resultado['golesSanFernando'] as int;
                          golesRival = resultado['golesRival'] as int;
                          golesRecibidos = resultado['golesRecibidos'] as int;
                          atajadas = resultado['atajadas'] as int;
                          penales = resultado['penales'] as int;
                          exclusiones2Min =
                              resultado['exclusiones2Min'] as int;
                          amarillas = resultado['amarillas'] as int;
                          rojas = resultado['rojas'] as int;
                          perdidas = resultado['perdidas'] as int;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _buildMiniAction(
                          text: 'Plantel',
                          icon: Icons.groups_rounded,
                          onTap: () {
                            debugPrint('Abrir plantel');
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildMiniAction(
                          text: 'Resumen',
                          icon: Icons.bar_chart_rounded,
                          onTap: () {
                            debugPrint('Abrir resumen');
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  _buildQuickSummaryCard(),
                  const SizedBox(height: 18),
                  _buildOutlinedAction(
                    text: 'Finalizar partido',
                    onTap: () {
                      debugPrint('Finalizar partido');
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

  Widget _buildControlHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Centro de control',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${widget.partido['categoria']} · ${widget.partido['torneo']}',
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFFD4DCE7),
          ),
        ),
      ],
    );
  }

  Widget _buildScoreCard({
    required String nombreLocal,
    required String nombreVisitante,
    required int golesLocal,
    required int golesVisitante,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1722).withOpacity(0.90),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.white.withOpacity(0.04),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.22),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: _buildTimeChip(_getTimeChipText()),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _buildTeamSide(
                  nombre: nombreLocal,
                  condicion: 'Local',
                  assetPath: 'assets/images/san_fernando.png',
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  '$golesLocal - $golesVisitante',
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              Expanded(
                child: _buildTeamSide(
                  nombre: nombreVisitante,
                  condicion: 'Visitante',
                  assetPath: 'assets/images/san_fernando.png',
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
          child: Center(
            child: Image.asset(
              assetPath,
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          nombre,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildTimeChip(String text) {
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

  String _getPrimaryActionText() {
    switch (estadoPartido) {
      case 'no_iniciado':
        return 'Iniciar 1T';
      case 'primer_tiempo':
        return 'Continuar 1T';
      case 'entretiempo':
        return 'Iniciar 2T';
      case 'segundo_tiempo':
        return 'Continuar 2T';
      case 'finalizado':
        return 'Ver resumen final';
      default:
        return 'Ir a partido en vivo';
    }
  }

  String _getTimeChipText() {
    switch (estadoPartido) {
      case 'no_iniciado':
        return 'Previo';
      case 'primer_tiempo':
        return '1T';
      case 'entretiempo':
        return 'Entretiempo';
      case 'segundo_tiempo':
        return '2T';
      case 'finalizado':
        return 'Final';
      default:
        return 'En juego';
    }
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
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildMiniAction({
    required String text,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF182338).withOpacity(0.75),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(0.04),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: Colors.white70),
            const SizedBox(width: 8),
            Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickSummaryCard() {
    final double eficaciaArquero = (atajadas + golesRecibidos) == 0
        ? 0
        : (atajadas / (atajadas + golesRecibidos)) * 100;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1722).withOpacity(0.82),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.04),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Resumen rápido',
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
          _buildSummaryRow('Penales', '$penales'),
          _buildSummaryRow('Exclusiones 2 min', '$exclusiones2Min'),
          _buildSummaryRow('Tarjetas amarillas', '$amarillas'),
          _buildSummaryRow('Tarjetas rojas', '$rojas'),
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
              style: const TextStyle(
                color: Color(0xFFAAB4C3),
                fontSize: 13,
              ),
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
          side: BorderSide(
            color: Colors.white.withOpacity(0.08),
          ),
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

/// ===============================
/// PARTIDO EN VIVO
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
  });

  @override
  State<PartidoEnVivoScreen> createState() => _PartidoEnVivoScreenState();
}

class _PartidoEnVivoScreenState extends State<PartidoEnVivoScreen> {
  late String estadoPartido;

  late int golesSanFernando;
  late int golesRival;
  late int golesRecibidos;

  late int atajadas;
  late int penales;
  late int exclusiones2Min;
  late int amarillas;
  late int rojas;
  late int perdidas;

  String modo = 'ataque';

  String? zonaTiro;
  String? zonaArco;

  @override
  void initState() {
    super.initState();
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
  }

  @override
  Widget build(BuildContext context) {
    final bool somosLocales = widget.partido['condicion'] == 'Local';
    final int golesLocal = somosLocales ? golesSanFernando : golesRival;
    final int golesVisitante = somosLocales ? golesRival : golesSanFernando;

    return WillPopScope(
      onWillPop: () async {
        _popWithResult();
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
            onPressed: _popWithResult,
          ),
          actions: [
            IconButton(
              onPressed: _isMatchFinalized()
                  ? null
                  : () {
                      debugPrint('Abrir sanción');
                    },
              icon: const Icon(Icons.gavel_rounded),
              tooltip: 'Sanción',
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
                color: const Color(0xFF05080D).withOpacity(0.9),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildCompactScoreBar(
                      golesLocal: golesLocal,
                      golesVisitante: golesVisitante,
                    ),
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
                      child: Center(
                        child: AspectRatio(
                          aspectRatio: 1.1,
                          child: _buildGoalGrid(),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildEventButton(
                            text: 'Pérdida',
                            onTap: _isMatchFinalized()
                                ? null
                                : () {
                                    setState(() {
                                      perdidas++;
                                    });
                                  },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildEventButton(
                            text: 'Sanción',
                            onTap: _isMatchFinalized()
                                ? null
                                : () {
                                    debugPrint('Abrir selección de sanción');
                                  },
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
                        text: _getActionByMatchState(),
                        onTap: _handleMatchState,
                      ),
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

  Widget _buildCompactScoreBar({
    required int golesLocal,
    required int golesVisitante,
  }) {
    final bool mostrarChipTiempo = estadoPartido != 'entretiempo';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1722).withOpacity(0.88),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withOpacity(0.04),
        ),
      ),
      child: Row(
        children: [
          _buildMiniTeamTag('L'),
          const SizedBox(width: 8),
          _buildMiniShield(),
          const Spacer(),
          if (mostrarChipTiempo) _buildTimeChip(_getTimeChipText()),
          if (mostrarChipTiempo) const SizedBox(width: 12),
          Opacity(
            opacity: estadoPartido == 'entretiempo' ? 0.42 : 1,
            child: Text(
              '$golesLocal - $golesVisitante',
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          if (estadoPartido == 'entretiempo') ...[
            const SizedBox(width: 12),
            _buildTimeChip('Entretiempo'),
          ],
          const Spacer(),
          _buildMiniShield(),
          const SizedBox(width: 8),
          _buildMiniTeamTag('V'),
        ],
      ),
    );
  }

  Widget _buildMiniShield() {
    return Container(
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

  Widget _buildTimeChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1C2B44).withOpacity(0.95),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFFDCE4EF),
          fontSize: 12,
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
        border: Border.all(
          color: Colors.white.withOpacity(0.04),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildModeOption(
              label: 'Defensa',
              isSelected: modo == 'defensa',
              onTap: () {
                if (_isMatchFinalized()) return;
                setState(() {
                  modo = 'defensa';
                  zonaTiro = null;
                  zonaArco = null;
                });
              },
            ),
          ),
          Expanded(
            child: _buildModeOption(
              label: 'Ataque',
              isSelected: modo == 'ataque',
              onTap: () {
                if (_isMatchFinalized()) return;
                setState(() {
                  modo = 'ataque';
                  zonaTiro = null;
                  zonaArco = null;
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1722).withOpacity(0.82),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.04),
        ),
      ),
      child: Column(
        children: [
          Expanded(
            flex: 3,
            child: _buildShotZones(),
          ),
          const SizedBox(height: 12),
          Expanded(
            flex: 2,
            child: _buildGoalZones(),
          ),
        ],
      ),
    );
  }

  Widget _buildShotZones() {
    return Row(
      children: [
        Expanded(
          child: _buildShotZone('EI', 'Extremo izquierdo'),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: _buildShotZone('LI', 'Lateral izquierdo'),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: _buildShotZone('C', 'Central'),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: _buildShotZone('LD', 'Lateral derecho'),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: _buildShotZone('ED', 'Extremo derecho'),
        ),
      ],
    );
  }

  Widget _buildShotZone(String shortLabel, String fullLabel) {
    final bool isSelected = zonaTiro == fullLabel;

    return GestureDetector(
      onTap: _isMatchFinalized()
          ? null
          : () {
              setState(() {
                zonaTiro = fullLabel;
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
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF4F8CFF).withOpacity(0.55)
                : Colors.white.withOpacity(0.04),
          ),
        ),
        child: Center(
          child: Text(
            shortLabel,
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

  Widget _buildGoalZones() {
    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              _goalCell('AI'),
              const SizedBox(width: 6),
              _goalCell('AC'),
              const SizedBox(width: 6),
              _goalCell('AD'),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Expanded(
          child: Row(
            children: [
              _goalCell('CI'),
              const SizedBox(width: 6),
              _goalCell('CC'),
              const SizedBox(width: 6),
              _goalCell('CD'),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Expanded(
          child: Row(
            children: [
              _goalCell('BI'),
              const SizedBox(width: 6),
              _goalCell('BC'),
              const SizedBox(width: 6),
              _goalCell('BD'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _goalCell(String label) {
    final bool isSelected = zonaArco == label;

    return Expanded(
      child: GestureDetector(
        onTap: _isMatchFinalized()
            ? null
            : () {
                setState(() {
                  zonaArco = label;
                });
                if (zonaTiro != null) {
                  _showZoneActionSheet();
                }
              },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF4F8CFF).withOpacity(0.24)
                : Colors.white.withOpacity(0.035),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF4F8CFF).withOpacity(0.55)
                  : Colors.white.withOpacity(0.04),
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
      ),
    );
  }

  void _showZoneActionSheet() {
    if (zonaTiro == null || zonaArco == null) return;

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
                '$zonaTiro → $zonaArco',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              _floatingOption('Gol', () {
                setState(() {
                  if (modo == 'ataque') {
                    golesSanFernando++;
                  } else {
                    golesRival++;
                    golesRecibidos++;
                  }
                });
                _clearSelection();
                Navigator.pop(context);
              }),
              _floatingOption('Atajado', () {
                setState(() {
                  if (modo == 'defensa') {
                    atajadas++;
                  }
                });
                _clearSelection();
                Navigator.pop(context);
              }),
              _floatingOption('Desviado', () {
                _clearSelection();
                Navigator.pop(context);
              }),
              _floatingOption('Penal', () {
                Navigator.pop(context);
                _showPenalDialog();
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

  void _clearSelection() {
    setState(() {
      zonaTiro = null;
      zonaArco = null;
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
            border: Border.all(
              color: Colors.white.withOpacity(0.04),
            ),
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
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  bool _isMatchFinalized() => estadoPartido == 'finalizado';

  String _getActionByMatchState() {
    switch (estadoPartido) {
      case 'no_iniciado':
        return 'Iniciar 1T';
      case 'primer_tiempo':
        return 'Finalizar 1T';
      case 'entretiempo':
        return 'Iniciar 2T';
      case 'segundo_tiempo':
        return 'Finalizar 2T';
      case 'finalizado':
        return 'Partido finalizado';
      default:
        return 'Continuar';
    }
  }

  String _getTimeChipText() {
    switch (estadoPartido) {
      case 'no_iniciado':
        return 'Previo';
      case 'primer_tiempo':
        return '1T';
      case 'entretiempo':
        return 'Entretiempo';
      case 'segundo_tiempo':
        return '2T';
      case 'finalizado':
        return 'Final';
      default:
        return 'En juego';
    }
  }

  void _handleMatchState() {
    if (estadoPartido == 'finalizado') {
      _popWithResult();
      return;
    }

    setState(() {
      if (estadoPartido == 'no_iniciado') {
        estadoPartido = 'primer_tiempo';
      } else if (estadoPartido == 'primer_tiempo') {
        estadoPartido = 'entretiempo';
      } else if (estadoPartido == 'entretiempo') {
        estadoPartido = 'segundo_tiempo';
      } else if (estadoPartido == 'segundo_tiempo') {
        estadoPartido = 'finalizado';
      }
    });

    if (estadoPartido == 'finalizado') {
      Future.delayed(const Duration(milliseconds: 150), () {
        if (!mounted) return;
        _popWithResult();
      });
    }
  }

  void _popWithResult() {
    Navigator.pop(
      context,
      {
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
      },
    );
  }

  void _showPenalDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F1722),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Resultado del penal',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              _penalOption('Gol', () {
                setState(() {
                  penales++;
                  if (modo == 'ataque') {
                    golesSanFernando++;
                  } else {
                    golesRival++;
                    golesRecibidos++;
                  }
                });
                Navigator.pop(context);
              }),
              _penalOption('Atajado', () {
                setState(() {
                  penales++;
                  if (modo == 'defensa') {
                    atajadas++;
                  }
                });
                Navigator.pop(context);
              }),
              _penalOption('Desviado', () {
                setState(() {
                  penales++;
                });
                Navigator.pop(context);
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _penalOption(String text, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFF182338),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}

/// ===============================
/// PLACEHOLDERS
/// ===============================
class HistorialScreen extends StatelessWidget {
  const HistorialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Partidos Jugados')),
      body: const Center(
        child: Text('Pantalla Partidos Jugados'),
      ),
    );
  }
}

class EstadisticasScreen extends StatelessWidget {
  const EstadisticasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Estadísticas')),
      body: const Center(
        child: Text('Pantalla Estadísticas'),
      ),
    );
  }
}

class EquiposScreen extends StatelessWidget {
  const EquiposScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Equipos')),
      body: const Center(
        child: Text('Pantalla Equipos'),
      ),
    );
  }
}

class JugadoresScreen extends StatelessWidget {
  const JugadoresScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Jugadores')),
      body: const Center(
        child: Text('Pantalla Jugadores'),
      ),
    );
  }
}
