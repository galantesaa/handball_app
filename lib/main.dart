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
/// ===============================
/// CENTRO DE CONTROL
/// ===============================
/// ===============================
/// 
/// 
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

  int penalesConvertidosSanFernando = 0;
  int penalesConvertidosRival = 0;

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
      return 'Volver desde entretiempo';
    case 'penales':
      return 'Volver a penales';
    default:
      return 'Ir a partido en vivo';
  }
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
          penalesConvertidosSanFernandoInicial: penalesConvertidosSanFernando,
          penalesConvertidosRivalInicial: penalesConvertidosRival,
        ),
      ),
    );

    if (resultado != null && mounted) {
      setState(() {
        estadoPartido = (resultado['estadoPartido'] ?? estadoPartido) as String;
        golesSanFernando =
            (resultado['golesSanFernando'] ?? golesSanFernando) as int;
        golesRival = (resultado['golesRival'] ?? golesRival) as int;
        golesRecibidos =
            (resultado['golesRecibidos'] ?? golesRecibidos) as int;
        atajadas = (resultado['atajadas'] ?? atajadas) as int;
        penales = (resultado['penales'] ?? penales) as int;
        exclusiones2Min =
            (resultado['exclusiones2Min'] ?? exclusiones2Min) as int;
        amarillas = (resultado['amarillas'] ?? amarillas) as int;
        rojas = (resultado['rojas'] ?? rojas) as int;
        perdidas = (resultado['perdidas'] ?? perdidas) as int;
        penalesConvertidosSanFernando =
            (resultado['penalesConvertidosSanFernando'] ??
                    penalesConvertidosSanFernando)
                as int;
        penalesConvertidosRival =
            (resultado['penalesConvertidosRival'] ??
                    penalesConvertidosRival)
                as int;
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
            child: Container(
              color: const Color(0xFF05080D).withOpacity(0.88),
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
                  _buildQuickSummaryCard(),
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
      style: const TextStyle(
        fontSize: 14,
        color: Color(0xFFD4DCE7),
      ),
    );
  }

  Widget _buildScoreCard() {
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
  final int penalesConvertidosSanFernandoInicial;
  final int penalesConvertidosRivalInicial;

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
    required this.penalesConvertidosSanFernandoInicial,
    required this.penalesConvertidosRivalInicial,
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

  late int penalesConvertidosSanFernando;
  late int penalesConvertidosRival;
  late int penalesIntentadosSanFernando;
  late int penalesIntentadosRival;

  String modo = 'ataque';

  String? zonaTiro;
  String? zonaArco;

  // Penal de partido normal en curso
  bool penalEnCurso = false;
  String? actorPenalActual;

  // Sanción / pérdida: por ahora actor genérico
  String? ultimoActorSeleccionado;

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

    penalesConvertidosSanFernando =
        widget.penalesConvertidosSanFernandoInicial;
    penalesConvertidosRival = widget.penalesConvertidosRivalInicial;

    penalesIntentadosSanFernando = penalesConvertidosSanFernando;
    penalesIntentadosRival = penalesConvertidosRival;
  }

  bool _isMatchFinalized() => estadoPartido == 'finalizado';

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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
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
            onPressed: _goBack,
          ),
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
                            onTap: _isPlayLocked() || _isPenaltyShootout()
                                ? null
                                : _registrarPerdida,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildEventButton(
                            text: 'Penal',
                            onTap: _isPlayLocked() || _isPenaltyShootout()
                                ? null
                                : _iniciarFlujoPenalNormal,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildEventButton(
                            text: 'Sanción',
                            onTap: _isPlayLocked() ? null : _showSancionTargetSheet,
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

  Widget _buildCompactScoreBar() {
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
                if (_isPlayLocked()) return;
                setState(() {
                  modo = 'defensa';
                  zonaTiro = null;
                  zonaArco = null;
                  penalEnCurso = false;
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
      child: _isPenaltyShootout()
          ? _buildPenaltyOnlyGrid()
          : Column(
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

  Widget _buildPenaltyOnlyGrid() {
    return Column(
      children: [
        const SizedBox(height: 12),
        Text(
          modo == 'ataque'
              ? 'Penal nuestro'
              : 'Penal rival',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          modo == 'ataque'
              ? 'Lanzador: jugador genérico'
              : 'Arquero: arquero genérico',
          style: const TextStyle(
            color: Color(0xFFAAB4C3),
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: _buildGoalZones(),
        ),
      ],
    );
  }

  Widget _buildShotZones() {
    return Row(
      children: [
        Expanded(child: _buildShotZone('EI', 'Extremo izquierdo')),
        const SizedBox(width: 6),
        Expanded(child: _buildShotZone('LI', 'Lateral izquierdo')),
        const SizedBox(width: 6),
        Expanded(child: _buildShotZone('C', 'Central')),
        const SizedBox(width: 6),
        Expanded(child: _buildShotZone('LD', 'Lateral derecho')),
        const SizedBox(width: 6),
        Expanded(child: _buildShotZone('ED', 'Extremo derecho')),
      ],
    );
  }

  Widget _buildShotZone(String shortLabel, String fullLabel) {
    final bool isSelected = zonaTiro == fullLabel;

    return GestureDetector(
      onTap: _isPlayLocked() || _isPenaltyShootout() || penalEnCurso
          ? null
          : () {
              setState(() {
                zonaTiro = fullLabel;
              });
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
        onTap: _isPlayLocked()
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
                  zonaArco = label;
                });
                _showZoneActionSheet();
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

  void _registrarPerdida() {
    setState(() {
      perdidas++;
      ultimoActorSeleccionado = 'Jugador genérico ataque';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pérdida registrada para jugador genérico ataque'),
      ),
    );
  }

  void _iniciarFlujoPenalNormal() {
    final String actor = modo == 'ataque'
        ? 'Jugador genérico ataque'
        : 'Arquero genérico';

    setState(() {
      penalEnCurso = true;
      actorPenalActual = actor;
      zonaTiro = null;
      zonaArco = null;
      ultimoActorSeleccionado = actor;
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
              const Text(
                'Penal',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                modo == 'ataque'
                    ? 'Lanzador: $actor'
                    : 'Arquero: $actor',
                style: const TextStyle(
                  color: Color(0xFFAAB4C3),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              _floatingOption('Seleccionar arco', () {
                Navigator.pop(context);
              }),
            ],
          ),
        );
      },
    );
  }

  void _showNormalPenaltyResultSheet() {
    if (zonaArco == null) return;

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
                '${actorPenalActual ?? 'Penal'} → $zonaArco',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              _floatingOption('Gol', () {
                setState(() {
                  penales++;
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
                  penales++;
                  if (modo == 'defensa') {
                    atajadas++;
                  }
                });
                _clearSelection();
                Navigator.pop(context);
              }),
              _floatingOption('Desviado', () {
                setState(() {
                  penales++;
                });
                _clearSelection();
                Navigator.pop(context);
              }),
            ],
          ),
        );
      },
    );
  }

  void _showPenaltyShootoutResultSheet() {
    if (zonaArco == null) return;

    final String actor = modo == 'ataque'
        ? 'Jugador genérico ataque'
        : 'Arquero genérico';

    ultimoActorSeleccionado = actor;

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
                '$actor → $zonaArco',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              _floatingOption('Gol', () {
                _registrarPenalTanda('gol');
                Navigator.pop(context);
              }),
              _floatingOption('Atajado', () {
                _registrarPenalTanda('atajado');
                Navigator.pop(context);
              }),
              _floatingOption('Desviado', () {
                _registrarPenalTanda('desviado');
                Navigator.pop(context);
              }),
            ],
          ),
        );
      },
    );
  }

  void _registrarPenalTanda(String resultado) {
    setState(() {
      if (modo == 'ataque') {
        penalesIntentadosSanFernando++;
        if (resultado == 'gol') {
          penalesConvertidosSanFernando++;
        }
      } else {
        penalesIntentadosRival++;
        if (resultado == 'gol') {
          penalesConvertidosRival++;
        }
        if (resultado == 'atajado') {
          atajadas++;
        }
      }
    });

    _clearSelection();
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

    // Después de 5 por lado, si ya no están empatados, finaliza
    if (intentosSF >= 5 && intentosRival >= 5 && intentosSF == intentosRival) {
      if (convertidosSF != convertidosRival) {
        _finalizarPartido();
        return;
      }
    }

    // Muerte súbita: después del quinto, cuando ambos hayan pateado la misma cantidad
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
                '¿A quién sancionar?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              _floatingOption('Jugador genérico', () {
                Navigator.pop(context);
                _showSancionSheet('Jugador genérico');
              }),
              _floatingOption('Arquero genérico', () {
                Navigator.pop(context);
                _showSancionSheet('Arquero genérico');
              }),
              _floatingOption('Técnico genérico', () {
                Navigator.pop(context);
                _showSancionSheet('Técnico genérico');
              }),
            ],
          ),
        );
      },
    );
  }

  void _showSancionSheet(String actor) {
    ultimoActorSeleccionado = actor;

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
                setState(() {
                  exclusiones2Min++;
                });
                Navigator.pop(context);
              }),
              _floatingOption('Tarjeta amarilla', () {
                setState(() {
                  amarillas++;
                });
                Navigator.pop(context);
              }),
              _floatingOption('Tarjeta roja', () {
                setState(() {
                  rojas++;
                });
                Navigator.pop(context);
              }),
            ],
          ),
        );
      },
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
      penalEnCurso = false;
      actorPenalActual = null;
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
      setState(() => estadoPartido = 'primer_tiempo');
      return;
    }

    if (estadoPartido == 'primer_tiempo') {
      setState(() => estadoPartido = 'entretiempo');
      return;
    }

    if (estadoPartido == 'entretiempo') {
      setState(() => estadoPartido = 'segundo_tiempo');
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
      setState(() => estadoPartido = 'entretiempo_alargue');
      return;
    }

    if (estadoPartido == 'entretiempo_alargue') {
      setState(() => estadoPartido = 'segundo_tiempo_alargue');
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
                setState(() => estadoPartido = 'primer_tiempo_alargue');
              }),
              const SizedBox(height: 10),
              _sheetButton('Ir a penales', () {
                Navigator.pop(context);
                setState(() => estadoPartido = 'penales');
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
                setState(() => estadoPartido = 'penales');
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
      'penalesConvertidosSanFernando': penalesConvertidosSanFernando,
      'penalesConvertidosRival': penalesConvertidosRival,
    });
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
