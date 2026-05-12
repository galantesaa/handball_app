import 'package:flutter/material.dart';

import '../../../../models_v2.dart';
import '../../../teams/data/team_repository.dart';

class MatchEditorScreen extends StatefulWidget {
  final PartidoModel? initial;
  final String temporada;
  final String competencia;
  final String torneo;
  final String categoria;

  const MatchEditorScreen({
    super.key,
    required this.temporada,
    required this.competencia,
    required this.torneo,
    required this.categoria,
    this.initial,
  });

  @override
  State<MatchEditorScreen> createState() => _MatchEditorScreenState();
}

class _MatchEditorScreenState extends State<MatchEditorScreen> {
  final TeamRepository _teamRepository = const TeamRepository();

  late final TextEditingController _rivalController;
  late final TextEditingController _fechaController;
  late final TextEditingController _horaController;
  late final TextEditingController _fechaNumeroController;

  String _condicion = 'Local';
  bool _saving = false;

  bool get _isEditing => widget.initial != null;

  @override
  void initState() {
    super.initState();

    final initial = widget.initial;

    _rivalController = TextEditingController(text: initial?.rival ?? '');
    _fechaController = TextEditingController(text: initial?.fecha ?? '');
    _horaController = TextEditingController(text: initial?.hora ?? '13:00');
    _fechaNumeroController = TextEditingController(
      text: initial?.fechaNumero?.toString() ?? '',
    );

    final condicionInicial = initial?.condicion.trim();

    if (condicionInicial == 'Visitante') {
      _condicion = 'Visitante';
    }
  }

  @override
  void dispose() {
    _rivalController.dispose();
    _fechaController.dispose();
    _horaController.dispose();
    _fechaNumeroController.dispose();
    super.dispose();
  }

  int? _parseFechaNumero() {
    final raw = _fechaNumeroController.text.trim();

    if (raw.isEmpty) return null;

    return int.tryParse(raw);
  }

  Future<String?> _resolveRivalShield(String rival) async {
    final existing = await _teamRepository.findByName(rival);

    if (existing?.shieldAsset != null &&
        existing!.shieldAsset!.trim().isNotEmpty) {
      return existing.shieldAsset;
    }

    return null;
  }

  Future<void> _guardar() async {
    if (_saving) return;

    final rival = _rivalController.text.trim();
    final fecha = _fechaController.text.trim();
    final hora = _horaController.text.trim();

    if (rival.isEmpty) {
      _showLocalMessage('Ingresá el rival.');
      return;
    }

    if (fecha.isEmpty) {
      _showLocalMessage('Ingresá la fecha.');
      return;
    }

    if (hora.isEmpty) {
      _showLocalMessage('Ingresá la hora.');
      return;
    }

    final fechaNumero = _parseFechaNumero();

    setState(() {
      _saving = true;
    });

    final escudoRival = await _resolveRivalShield(rival);

    if (!mounted) return;

    final partido = PartidoModel(
      temporada: widget.temporada,
      competencia: widget.competencia,
      rival: rival,
      fechaNumero: fechaNumero,
      fecha: fecha,
      hora: hora,
      condicion: _condicion,
      torneo: widget.torneo,
      categoria: widget.categoria,
      estado: 'Pendiente',
      estadoPartido: 'no_iniciado',
      golesSanFernando: 0,
      golesRival: 0,
      golesRecibidos: 0,
      atajadas: 0,
      penales: 0,
      exclusiones2Min: 0,
      amarillas: 0,
      rojas: 0,
      perdidas: 0,
      recuperaciones: 0,
      penalesConvertidosSanFernando: 0,
      penalesConvertidosRival: 0,
      eventos: const [],
      escudoRival: escudoRival,
      matchSquad: widget.initial?.matchSquad,
    );

    Navigator.pop(context, partido);
  }

  void _showLocalMessage(String message) {
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
        title: Text(_isEditing ? 'Editar partido' : 'Crear partido'),
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
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              children: [
                Text(
                  '${widget.temporada} · ${widget.competencia} · ${widget.torneo} · ${widget.categoria}',
                  style: const TextStyle(
                    color: Color(0xFFAAB4C3),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 18),
                _buildCard(
                  children: [
                    _buildTextField(
                      controller: _rivalController,
                      label: 'Rival',
                      hint: 'Ejemplo: C.A. River Plate',
                      textInputType: TextInputType.text,
                    ),
                    const SizedBox(height: 14),
                    _buildTextField(
                      controller: _fechaNumeroController,
                      label: 'Fecha número',
                      hint: 'Ejemplo: 1',
                      textInputType: TextInputType.number,
                    ),
                    const SizedBox(height: 14),
                    _buildTextField(
                      controller: _fechaController,
                      label: 'Fecha',
                      hint: 'Ejemplo: 21/03',
                      textInputType: TextInputType.datetime,
                    ),
                    const SizedBox(height: 14),
                    _buildTextField(
                      controller: _horaController,
                      label: 'Hora',
                      hint: 'Ejemplo: 13:00',
                      textInputType: TextInputType.datetime,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Condición',
                      style: TextStyle(
                        color: Color(0xFFAAB4C3),
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _buildConditionButton(
                            text: 'Local',
                            selected: _condicion == 'Local',
                            onTap: () {
                              setState(() {
                                _condicion = 'Local';
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildConditionButton(
                            text: 'Visitante',
                            selected: _condicion == 'Visitante',
                            onTap: () {
                              setState(() {
                                _condicion = 'Visitante';
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _saving ? null : _guardar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4F8CFF),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: const Color(0xFF263244),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: Text(
                      _saving ? 'Guardando...' : 'Guardar partido',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
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
    required TextInputType textInputType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: textInputType,
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

  Widget _buildConditionButton({
    required String text,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        height: 44,
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF4F8CFF) : const Color(0xFF182338),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: selected
                ? const Color(0xFF7DB7FF)
                : Colors.white.withOpacity(0.06),
          ),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}
