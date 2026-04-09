import 'package:flutter/material.dart';

void main() {
  runApp(const GoalKeeperApp());
}

class GoalKeeperApp extends StatelessWidget {
  const GoalKeeperApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GoalKeeper',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0D1016),
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

  /// 🔥 CAMBIAR ESTO PARA PROBAR ESTADOS
  bool tieneInstitucion = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// 🔵 FONDO
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/fondohd.jpeg'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          /// 🔵 CAPA OSCURA
          Container(
            color: const Color(0xFF090C12).withOpacity(0.75),
          ),

          /// 🔵 CONTENIDO
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  /// 🔥 HEADER (LOGO + SUBTITULO)
                  _buildHeader(),

                  const SizedBox(height: 30),

                  /// 🔥 CONTENIDO SEGÚN ESTADO
                  Expanded(
                    child: tieneInstitucion
                        ? _buildEstadoConInstitucion()
                        : _buildEstadoVacio(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 🔹 HEADER
  Widget _buildHeader() {
    return Column(
      children: [
        Image.asset(
          'assets/images/logohd.jpeg',
          height: 80,
        ),
        const SizedBox(height: 10),
        const Text(
          'Seguimiento y estadísticas',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 15,
          ),
        ),
      ],
    );
  }

  /// 🔹 ESTADO VACÍO
  Widget _buildEstadoVacio() {
    return Center(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF171C25).withOpacity(0.9),
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'No hay una institución creada',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                setState(() {
                  tieneInstitucion = true;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4F8CFF),
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Crear institución',
                style: TextStyle(fontSize: 15),
              ),
            ),

            const SizedBox(height: 10),

            TextButton(
              onPressed: () {},
              child: const Text(
                'Importar datos',
                style: TextStyle(color: Colors.white70),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🔹 ESTADO CON INSTITUCIÓN (MOCK)
  Widget _buildEstadoConInstitucion() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        /// 🔥 CARD INSTITUCIÓN
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF171C25).withOpacity(0.9),
            borderRadius: BorderRadius.circular(28),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundImage: const AssetImage(
                  'assets/images/logohd.jpeg',
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  'San Fernando',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.more_vert, color: Colors.white),
              )
            ],
          ),
        ),

        const SizedBox(height: 30),

        /// 🔥 ACCIONES PRINCIPALES
        _buildMainButton('Próximos partidos'),
        _buildMainButton('Partidos jugados'),
        _buildMainButton('Estadísticas'),

        const Spacer(),

        /// 🔥 BOTÓN RESET (solo para test)
        Center(
          child: TextButton(
            onPressed: () {
              setState(() {
                tieneInstitucion = false;
              });
            },
            child: const Text(
              'Volver a estado inicial',
              style: TextStyle(color: Colors.white38),
            ),
          ),
        )
      ],
    );
  }

  Widget _buildMainButton(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: const Color(0xFF232832),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}