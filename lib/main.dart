import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

class ProximoPartidoScreen extends StatelessWidget {
  const ProximoPartidoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Próximo partido')),
      body: const Center(child: Text('Pantalla Próximo Partido')),
    );
  }
}

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
