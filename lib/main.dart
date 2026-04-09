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
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4F8CFF),
          brightness: Brightness.dark,
        ),
      ),
      home: const MainScreen(),
    );
  }
}

enum SelectionStep {
  temporada,
  torneo,
  competencia,
  categoria,
  division,
  complete,
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  String? temporada;
  String? torneo;
  String? competencia;
  String? categoria;
  String? division;

  final List<String> temporadasDisponibles = ['2026'];
  final List<String> torneosDisponibles = ['Local', 'Nacional'];
  final List<String> competenciasLocal = ['Apertura', 'Clausura'];
  final List<String> categoriasBase = ['Cadetes', 'Juveniles'];

  final Map<String, List<String>> divisionesNacionalPorCompetencia = {
    'Apertura': ['A', 'B'],
    'Clausura': ['A', 'B'],
  };

  bool get nacionalConfigurado {
    if (temporada == '2026' && torneo == 'Nacional') {
      return false;
    }
    return true;
  }

  bool get requiereDivision {
    if (torneo != 'Nacional') return false;
    if (competencia == null) return false;
    return divisionesNacionalPorCompetencia.containsKey(competencia);
  }

  List<String> get competenciasDisponibles {
    if (torneo == 'Local') {
      return competenciasLocal;
    }

    if (torneo == 'Nacional' && nacionalConfigurado) {
      return ['Apertura', 'Clausura'];
    }

    return [];
  }

  List<String> get divisionesDisponibles {
    if (!requiereDivision || competencia == null) {
      return [];
    }
    return divisionesNacionalPorCompetencia[competencia] ?? [];
  }

  SelectionStep get currentStep {
    if (temporada == null) return SelectionStep.temporada;
    if (torneo == null) return SelectionStep.torneo;

    if (torneo == 'Nacional' && !nacionalConfigurado) {
      return SelectionStep.complete;
    }

    if (competencia == null) return SelectionStep.competencia;
    if (categoria == null) return SelectionStep.categoria;
    if (requiereDivision && division == null) return SelectionStep.division;
    return SelectionStep.complete;
  }

  bool get contextoCompleto {
    if (temporada == null ||
        torneo == null ||
        competencia == null ||
        categoria == null) {
      return false;
    }

    if (requiereDivision && division == null) {
      return false;
    }

    if (torneo == 'Nacional' && !nacionalConfigurado) {
      return false;
    }

    return true;
  }

  void _selectTemporada(String value) {
    setState(() {
      temporada = value;
      torneo = null;
      competencia = null;
      categoria = null;
      division = null;
    });
  }

  void _selectTorneo(String value) {
    setState(() {
      torneo = value;
      competencia = null;
      categoria = null;
      division = null;
    });
  }

  void _selectCompetencia(String value) {
    setState(() {
      competencia = value;
      categoria = null;
      division = null;
    });
  }

  void _selectCategoria(String value) {
    setState(() {
      categoria = value;
      division = null;
    });
  }

  void _selectDivision(String value) {
    setState(() {
      division = value;
    });
  }

  void _removeChip(String key) {
    setState(() {
      switch (key) {
        case 'temporada':
          temporada = null;
          torneo = null;
          competencia = null;
          categoria = null;
          division = null;
          break;
        case 'torneo':
          torneo = null;
          competencia = null;
          categoria = null;
          division = null;
          break;
        case 'competencia':
          competencia = null;
          categoria = null;
          division = null;
          break;
        case 'categoria':
          categoria = null;
          division = null;
          break;
        case 'division':
          division = null;
          break;
      }
    });
  }

  void _showNotImplementedMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
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
          Container(
            color: const Color(0xFF090C12).withOpacity(0.82),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 22),
                  _buildSelectionCard(),
                  const SizedBox(height: 18),
                  if (torneo == 'Nacional' && !nacionalConfigurado)
                    _buildNationalNotConfiguredCard(),
                  if (contextoCompleto) _buildReadyCard(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'GoalKeeper',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.8,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Seguimiento y estadísticas',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.white70,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        PopupMenuButton<String>(
          icon: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Colors.white.withOpacity(0.06),
              ),
            ),
            child: const Icon(
              Icons.more_vert_rounded,
              color: Colors.white,
            ),
          ),
          color: const Color(0xFF1A1F29),
          onSelected: (value) {
            _showNotImplementedMessage('Abrir: $value');
          },
          itemBuilder: (context) => const [
            PopupMenuItem(
              value: 'Administrar',
              child: Text('Administrar'),
            ),
            PopupMenuItem(
              value: 'Cargar',
              child: Text('Cargar'),
            ),
            PopupMenuItem(
              value: 'Gestionar',
              child: Text('Gestionar'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSelectionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
      decoration: BoxDecoration(
        color: const Color(0xFF171C25).withOpacity(0.86),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: Colors.white.withOpacity(0.06),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_buildChips().isNotEmpty) ...[
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _buildChips(),
            ),
            const SizedBox(height: 18),
          ],
          _buildCurrentStepContent(),
        ],
      ),
    );
  }

  List<Widget> _buildChips() {
    final chips = <Widget>[];

    if (temporada != null) {
      chips.add(
        _SelectionChip(
          label: temporada!,
          onRemove: () => _removeChip('temporada'),
        ),
      );
    }

    if (torneo != null) {
      chips.add(
        _SelectionChip(
          label: torneo!,
          onRemove: () => _removeChip('torneo'),
        ),
      );
    }

    if (competencia != null) {
      chips.add(
        _SelectionChip(
          label: competencia!,
          onRemove: () => _removeChip('competencia'),
        ),
      );
    }

    if (categoria != null) {
      chips.add(
        _SelectionChip(
          label: categoria!,
          onRemove: () => _removeChip('categoria'),
        ),
      );
    }

    if (division != null) {
      chips.add(
        _SelectionChip(
          label: division!,
          onRemove: () => _removeChip('division'),
        ),
      );
    }

    return chips;
  }

  Widget _buildCurrentStepContent() {
    if (torneo == 'Nacional' && !nacionalConfigurado) {
      return const SizedBox.shrink();
    }

    switch (currentStep) {
      case SelectionStep.temporada:
        return _buildStepSection(
          title: 'Temporada',
          options: temporadasDisponibles,
          onTap: _selectTemporada,
        );

      case SelectionStep.torneo:
        return _buildStepSection(
          title: 'Torneo',
          options: torneosDisponibles,
          onTap: _selectTorneo,
        );

      case SelectionStep.competencia:
        return _buildStepSection(
          title: 'Competencia',
          options: competenciasDisponibles,
          onTap: _selectCompetencia,
        );

      case SelectionStep.categoria:
        return _buildStepSection(
          title: 'Categoría',
          options: categoriasBase,
          onTap: _selectCategoria,
        );

      case SelectionStep.division:
        return _buildStepSection(
          title: 'División',
          options: divisionesDisponibles,
          onTap: _selectDivision,
        );

      case SelectionStep.complete:
        return const SizedBox.shrink();
    }
  }

  Widget _buildStepSection({
    required String title,
    required List<String> options,
    required ValueChanged<String> onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 16),
        Column(
          children: options
              .map(
                (option) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _SelectableCard(
                    title: option,
                    onTap: () => onTap(option),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildNationalNotConfiguredCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1822).withOpacity(0.94),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF7E63FF).withOpacity(0.18),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Nacional no configurado',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Todavía no hay un torneo nacional creado para la temporada ${temporada ?? ''}.',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                _showNotImplementedMessage('Abrir creador de torneo nacional');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4F8CFF),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: const Text(
                'Crear torneo nacional',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadyCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        color: const Color(0xFF151D26).withOpacity(0.90),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.06),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Contexto listo',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            [
              temporada,
              torneo,
              competencia,
              categoria,
              if (division != null) division,
            ].whereType<String>().join(' · '),
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                _showNotImplementedMessage('Abrir fixture');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4F8CFF),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: const Text(
                'Abrir fixture',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectionChip extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;

  const _SelectionChip({
    required this.label,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
      decoration: BoxDecoration(
        color: const Color(0xFF12233A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF4F8CFF).withOpacity(0.22),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF6FB0FF),
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(
              Icons.close_rounded,
              size: 18,
              color: Color(0xFF6FB0FF),
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectableCard extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _SelectableCard({
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF232832),
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: Colors.white.withOpacity(0.03),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF4F8CFF),
                    width: 2.4,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 19,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}