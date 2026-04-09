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
        scaffoldBackgroundColor: const Color(0xFF0B0D12),
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3D5AFE),
          brightness: Brightness.dark,
        ),
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int? temporadaSeleccionada;
  String? torneoSeleccionado;
  String? formatoSeleccionado;
  String? categoriaSeleccionada;
  String? divisionSeleccionada;

  final List<int> temporadas = [2026, 2027, 2028];

  final List<String> torneosBase = ['Local', 'Nacional', 'Crear nuevo torneo'];

  final List<String> formatosConApertura = [
    'Apertura',
    'Clausura',
    'Torneo único',
  ];

  final List<String> formatosSoloUnico = ['Torneo único'];

  final List<String> categoriasBase = [
    'Cadetes',
    'Juveniles',
    'Crear nueva categoría',
  ];

  final List<String> divisionesNacional = ['A', 'B'];

  bool get requiereDivision => torneoSeleccionado == 'Nacional';

  List<String> get formatosDisponibles {
    if (torneoSeleccionado == 'Nacional') {
      return formatosSoloUnico;
    }
    return formatosConApertura;
  }

  bool get contextoCompleto {
    if (temporadaSeleccionada == null ||
        torneoSeleccionado == null ||
        formatoSeleccionado == null ||
        categoriaSeleccionada == null) {
      return false;
    }

    if (requiereDivision && divisionSeleccionada == null) {
      return false;
    }

    return true;
  }

  void _seleccionarTemporada(int? value) {
    setState(() {
      temporadaSeleccionada = value;

      torneoSeleccionado = null;
      formatoSeleccionado = null;
      categoriaSeleccionada = null;
      divisionSeleccionada = null;
    });
  }

  void _seleccionarTorneo(String? value) {
    setState(() {
      torneoSeleccionado = value;

      formatoSeleccionado = null;
      categoriaSeleccionada = null;
      divisionSeleccionada = null;
    });
  }

  void _seleccionarFormato(String? value) {
    setState(() {
      formatoSeleccionado = value;
      categoriaSeleccionada = null;
      divisionSeleccionada = null;
    });
  }

  void _seleccionarCategoria(String? value) {
    setState(() {
      categoriaSeleccionada = value;
    });
  }

  void _seleccionarDivision(String? value) {
    setState(() {
      divisionSeleccionada = value;
    });
  }

  String _textoContextoActivo() {
    if (temporadaSeleccionada == null) {
      return 'Todavía no seleccionaste una temporada.';
    }

    final partes = <String>[];

    partes.add('Temporada $temporadaSeleccionada');

    if (torneoSeleccionado != null) {
      partes.add(torneoSeleccionado!);
    }

    if (formatoSeleccionado != null) {
      partes.add(formatoSeleccionado!);
    }

    if (categoriaSeleccionada != null) {
      partes.add(categoriaSeleccionada!);
    }

    if (requiereDivision && divisionSeleccionada != null) {
      partes.add('División $divisionSeleccionada');
    }

    return partes.join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/fondohd.jpeg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(color: Colors.black.withOpacity(0.74)),
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'GoalKeeper',
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Definí el contexto de trabajo para entrar al torneo correcto.',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.white70,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildContextCard(),
                    const SizedBox(height: 18),
                    _buildActiveContextCard(),
                    const SizedBox(height: 18),
                    _buildContinueButton(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContextCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF151922).withOpacity(0.92),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Contexto activo',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'La selección se abre paso a paso. Si cambiás algo anterior, lo dependiente se reinicia automáticamente.',
            style: TextStyle(fontSize: 14, color: Colors.white70, height: 1.45),
          ),
          const SizedBox(height: 20),

          _buildDropdownField<int>(
            label: '1. Temporada',
            hint: 'Seleccionar temporada',
            value: temporadaSeleccionada,
            items: temporadas,
            itemLabel: (value) => 'Temporada $value',
            onChanged: _seleccionarTemporada,
          ),

          if (temporadaSeleccionada != null) ...[
            const SizedBox(height: 14),
            _buildDropdownField<String>(
              label: '2. Torneo',
              hint: 'Seleccionar torneo',
              value: torneoSeleccionado,
              items: torneosBase,
              itemLabel: (value) => value,
              onChanged: _seleccionarTorneo,
            ),
          ],

          if (torneoSeleccionado != null) ...[
            const SizedBox(height: 14),
            _buildDropdownField<String>(
              label: '3. Competencia / Formato',
              hint: 'Seleccionar formato',
              value: formatoSeleccionado,
              items: formatosDisponibles,
              itemLabel: (value) => value,
              onChanged: _seleccionarFormato,
            ),
          ],

          if (formatoSeleccionado != null) ...[
            const SizedBox(height: 14),
            _buildDropdownField<String>(
              label: '4. Categoría',
              hint: 'Seleccionar categoría',
              value: categoriaSeleccionada,
              items: categoriasBase,
              itemLabel: (value) => value,
              onChanged: _seleccionarCategoria,
            ),
          ],

          if (categoriaSeleccionada != null && requiereDivision) ...[
            const SizedBox(height: 14),
            _buildDropdownField<String>(
              label: '5. División',
              hint: 'Seleccionar división',
              value: divisionSeleccionada,
              items: divisionesNacional,
              itemLabel: (value) => 'División $value',
              onChanged: _seleccionarDivision,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActiveContextCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF10141C).withOpacity(0.90),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Resumen actual',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _textoContextoActivo(),
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContinueButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: contextoCompleto
            ? () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Contexto listo: ${_textoContextoActivo()}'),
                  ),
                );
              }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF3D5AFE),
          disabledBackgroundColor: Colors.white.withOpacity(0.12),
          foregroundColor: Colors.white,
          disabledForegroundColor: Colors.white54,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          contextoCompleto
              ? 'Continuar al fixture'
              : 'Completá el contexto para continuar',
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildDropdownField<T>({
    required String label,
    required String hint,
    required T? value,
    required List<T> items,
    required String Function(T) itemLabel,
    required ValueChanged<T?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white70,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: const Color(0xFF0E1218),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              isExpanded: true,
              hint: Text(hint, style: const TextStyle(color: Colors.white54)),
              dropdownColor: const Color(0xFF151922),
              style: const TextStyle(color: Colors.white, fontSize: 15),
              iconEnabledColor: Colors.white70,
              items: items.map((item) {
                return DropdownMenuItem<T>(
                  value: item,
                  child: Text(itemLabel(item)),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
