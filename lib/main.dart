import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Punto de entrada de la app.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Permite dibujar detrás de la barra superior del sistema.
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // Configuración visual de la status bar.
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ),
  );

  runApp(const GoalKeeperApp());
}

/// Widget raíz de la aplicación.
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

/// Pantalla principal.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  /// Estado simple para mostrar si hay institución cargada o no.
  bool tieneInstitucion = true;

  /// Nombre visible de la institución.
  final String institucionNombre = 'San Fernando Handball';

  /// Si solo existe una temporada, el primer chip no debería borrarse.
  final bool hayMasDeUnaTemporada = false;

  /// Ruta / contexto actual activo.
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
          // Fondo principal
          Positioned.fill(
            child: Image.asset(
              'assets/images/fondohd.jpeg',
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
          ),

          // Oscurece el fondo para mejorar la legibilidad
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

  /// Navegación central de la home.
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

  /// Header superior con logo, texto y menú.
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

  /// Estado vacío: aún no hay institución creada.
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

  /// Estado principal de la home cuando ya hay institución activa.
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

          // Bloque montado con escudo + institución
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

  /// Cabecera montada sobre el recuadro principal.
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

  /// Círculo blanco con escudo de institución.
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

  /// Contenedor de la ruta actual (temporada, torneo, categoría, etc.).
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

  /// Línea horizontal de chips.
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

  /// Chip individual de contexto.
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

  /// Card clickeable de la home.
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

/// Widget reusable para dar feedback táctil a las cards.
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

/// Pantalla de próximo partido.
/// Hoy es opción A, pero pensada para crecer hacia fixture real.
class ProximoPartidoScreen extends StatefulWidget {
  const ProximoPartidoScreen({super.key});

  @override
  State<ProximoPartidoScreen> createState() => _ProximoPartidoScreenState();
}

class _ProximoPartidoScreenState extends State<ProximoPartidoScreen> {
  bool hayPartido = true;

  /// Partido principal visible arriba.
  final Map<String, dynamic> proximoPartido = {
    'rival': 'Argentinos Juniors',
    'fecha': 'Sabado 18/04',
    'hora': '13:00',
    'condicion': 'Local',
    'torneo': 'Local Apertura',
    'categoria': 'Cadetes',
    'estado': 'Pendiente',
  };

  /// Cola de siguientes partidos.
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

  /// Título y subtítulo superior.
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

  /// Card principal del partido destacado.
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

  /// Lista compacta de los siguientes partidos.
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
        ...siguientesPartidos.map((partido) {
          return _buildUpcomingItem(partido);
        }).toList(),
      ],
    );
  }

  /// Item individual de la lista de próximos.
  /// Al tocar uno, sube a principal y el principal baja a la lista.
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

  /// Escudo principal del rival.
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

  /// Chip de estado del partido.
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

  /// Botón de historial vs rival actual.
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

  /// Fila simple de dato + valor.
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

  /// Botón principal azul.
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

  /// Botón secundario tipo card, usado para "Ver fixture completo".
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

  /// Botón outlined para acciones secundarias de partido.
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

/// Pantalla básica de fixture completo.
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

/// Pantalla intermedia: centro de control del partido.
/// Desde acá se ve el estado general, el tanteador y se entra al módulo en vivo.
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
  // =========================
  // DATOS MOCK DEL PARTIDO
  // =========================

  /// Tanteador actual mock.
  int golesSanFernando = 10;
  int golesRival = 7;

  /// Métricas mock del resumen.
  int atajadas = 9;
  int golesRecibidos = 7;
  int perdidas = 5;

  /// Exclusiones temporales (2 minutos).
  int exclusiones2Min = 3;

  /// Amarilla: advertencia.
  int amarillas = 2;

  /// Rojas: exclusión definitiva del partido.
  int rojas = 1;

    /// Penales cobrados en contra o a favor.
  int penales = 2;

  /// Estado actual del partido.
  /// Valores posibles mock:
  /// - no_iniciado
  /// - primer_tiempo
  /// - entretiempo
  /// - segundo_tiempo
  /// - finalizado
  String estadoPartido = 'segundo_tiempo';

  @override
  Widget build(BuildContext context) {
    final bool somosLocales = widget.partido['condicion'] == 'Local';
///la logica es que el local siempre a la izquierda y el visitante a la derecha, entonces dependiendo de si somos locales o visitantes, asignamos los nombres y goles en consecuencia para que se muestren correctamente en el tanteador.
    final String nombreLocal = somosLocales ? 'San Fernando' : widget.partido['rival'];
    final String nombreVisitante = somosLocales ? widget.partido['rival'] : 'San Fernando';

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
          // Fondo general
          Positioned.fill(
            child: Image.asset(
              'assets/images/fondohd.jpeg',
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
          ),

          // Overlay oscuro
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
///BOTON PRINCIPAL
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

    // Cuando vuelve desde Partido en vivo, actualizamos el centro de control.
    if (resultado != null && mounted) {
      setState(() {
        estadoPartido = resultado['estadoPartido'] as String;
        golesSanFernando = resultado['golesSanFernando'] as int;
        golesRival = resultado['golesRival'] as int;
        atajadas = resultado['atajadas'] as int;
        penales = resultado['penales'] as int;
        exclusiones2Min = resultado['exclusiones2Min'] as int;
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

  // =========================
  // HEADER SUPERIOR
  // =========================

  /// Encabezado contextual del centro de control.
  /// Sacamos el nombre grande del rival porque ya aparece en el tanteador.
  /// sacamos fecha y hora, solo dejamos centro de control y ruta
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

  // =========================
  // TANTEADOR PRINCIPAL
  // =========================

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

  // =========================
  // BOTÓN PRINCIPAL DINÁMICO
  // =========================

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

  // =========================
  // ACCIONES SECUNDARIAS
  // =========================

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

  // =========================
  // RESUMEN RÁPIDO
  // =========================

  /// Resumen mock más útil a nivel diseño y concepto.
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
}

/// Pantalla operativa del partido.
/// Acá se registran eventos rápidos del partido en curso.
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
  late int atajadas;
  late int penales;
  late int exclusiones2Min;
  late int amarillas;
  late int rojas;
  late int perdidas;

  @override
  void initState() {
    super.initState();
    estadoPartido = widget.estadoInicial;
    golesSanFernando = widget.golesSanFernandoInicial;
    golesRival = widget.golesRivalInicial;
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

    final String nombreLocal =
        somosLocales ? 'San Fernando' : widget.partido['rival'];
    final String nombreVisitante =
        somosLocales ? widget.partido['rival'] : 'San Fernando';

    final int golesLocal = somosLocales ? golesSanFernando : golesRival;
    final int golesVisitante = somosLocales ? golesRival : golesSanFernando;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Partido en vivo'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Fondo
          Positioned.fill(
            child: Image.asset(
              'assets/images/fondohd.jpeg',
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
          ),

          // Overlay
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
                  _buildLiveHeader(),
                  const SizedBox(height: 18),

                  _buildLiveScoreCard(
                    nombreLocal: nombreLocal,
                    nombreVisitante: nombreVisitante,
                    golesLocal: golesLocal,
                    golesVisitante: golesVisitante,
                  ),

                  const SizedBox(height: 16),

                  _buildSectionTitle('Eventos rápidos'),
                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Expanded(
                        child: _buildEventButton(
                          text: 'Gol nuestro',
                          onTap: () {
                            setState(() {
                              golesSanFernando++;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildEventButton(
                          text: 'Gol rival',
                          onTap: () {
                            setState(() {
                              golesRival++;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Expanded(
                        child: _buildEventButton(
                          text: 'Atajada',
                          onTap: () {
                            setState(() {
                              atajadas++;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildEventButton(
                          text: 'Pérdida',
                          onTap: () {
                            setState(() {
                              perdidas++;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Expanded(
                        child: _buildEventButton(
                          text: 'Penal',
                          onTap: () {
                            setState(() {
                              penales++;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildEventButton(
                          text: '2 min',
                          onTap: () {
                            setState(() {
                              exclusiones2Min++;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Expanded(
                        child: _buildEventButton(
                          text: 'Amarilla',
                          onTap: () {
                            setState(() {
                              amarillas++;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildEventButton(
                          text: 'Roja',
                          onTap: () {
                            setState(() {
                              rojas++;
                            });
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  _buildPrimaryAction(
                    text: _getActionByMatchState(),
                    onTap: () {
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
                    },
                  ),

                  const SizedBox(height: 10),

                  _buildOutlinedAction(
                    text: 'Volver al centro de control',
                    onTap: () {
                      Navigator.pop(
                        context,
                        {
                          'estadoPartido': estadoPartido,
                          'golesSanFernando': golesSanFernando,
                          'golesRival': golesRival,
                          'atajadas': atajadas,
                          'penales': penales,
                          'exclusiones2Min': exclusiones2Min,
                          'amarillas': amarillas,
                          'rojas': rojas,
                          'perdidas': perdidas,
                        },
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

  /// Header contextual de la pantalla en vivo.
  Widget _buildLiveHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${widget.partido['categoria']} · ${widget.partido['torneo']} · ${widget.partido['condicion']}',
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFFD4DCE7),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${widget.partido['fecha']} • ${widget.partido['hora']}',
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFFAAB4C3),
          ),
        ),
      ],
    );
  }

  /// Card principal del tanteador en vivo.
  Widget _buildLiveScoreCard({
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

  /// Lado de equipo en el tanteador.
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

  /// Chip del tiempo / estado actual.
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

  Widget _buildSectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  /// Botón chico para sumar un evento.
  Widget _buildEventButton({
    required String text,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
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
          ),
        ),
      ),
    );
  }

  /// Botón principal.
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

  /// Botón outlined.
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

  /// Texto dinámico del botón principal según el estado.
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

  /// Texto del chip superior.
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
}
/// Placeholder de partidos jugados.
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

/// Placeholder de estadísticas.
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

/// Placeholder de equipos.
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

/// Placeholder de jugadores.
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