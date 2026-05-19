import 'package:flutter/material.dart';
import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../models_v2.dart';
import '../../../teams/data/team_repository.dart';

class MatchEditorScreen extends StatefulWidget {
  final PartidoModel? initial;
  final String temporada;
  final String competencia;
  final String torneo;
  final String categoria;
  final String? institutionId;
  final String? equipoPropio;
  final String? escudoPropio;

  const MatchEditorScreen({
    super.key,
    required this.temporada,
    required this.competencia,
    required this.torneo,
    required this.categoria,
    this.initial,
    this.institutionId,
    this.equipoPropio,
    this.escudoPropio,
  });

  @override
  State<MatchEditorScreen> createState() => _MatchEditorScreenState();
}

class _MatchEditorScreenState extends State<MatchEditorScreen> {
  final TeamRepository _teamRepository = const TeamRepository();
  List<TeamModel> _availableTeams = [];
  TeamModel? _selectedOpponent;

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
    _loadTeams();
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

  String _generateMatchInstanceId() {
    String safe(dynamic value) {
      return (value ?? '')
          .toString()
          .trim()
          .toLowerCase()
          .replaceAll('á', 'a')
          .replaceAll('é', 'e')
          .replaceAll('í', 'i')
          .replaceAll('ó', 'o')
          .replaceAll('ú', 'u')
          .replaceAll('ü', 'u')
          .replaceAll('ñ', 'n')
          .replaceAll(RegExp(r'\s+'), '_')
          .replaceAll(RegExp(r'[^a-z0-9_]'), '');
    }

    final institution = safe(widget.institutionId);
    final season = safe(widget.temporada);
    final competition = safe(widget.competencia);
    final tournament = safe(widget.torneo);
    final category = safe(widget.categoria);
    final now = DateTime.now().microsecondsSinceEpoch;

    return 'match_${institution}_${season}_${competition}_${tournament}_${category}_$now';
  }

  Future<String?> _resolveRivalShield(String rival) async {
    final existing = await _teamRepository.findByName(rival);
    return existing?.displayShieldPath;
  }

  Future<void> _loadTeams() async {
    try {
      final teams = await _teamRepository.readTeams();

      if (!mounted) return;

      final currentRival = _rivalController.text.trim();
      TeamModel? selected;

      if (currentRival.isNotEmpty) {
        selected = await _teamRepository.findByName(currentRival);
      }

      if (!mounted) return;

      setState(() {
        _availableTeams = teams.where((team) => team.isActive).toList();
        _selectedOpponent = selected;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _availableTeams = [];
        _selectedOpponent = null;
      });
    }
  }

  Future<void> _createQuickTeam(String rawName) async {
    final cleanName = rawName.trim();

    if (cleanName.isEmpty) {
      _showLocalMessage('Ingresá el nombre del rival.');
      return;
    }

    final created = await _teamRepository.addTeam(name: cleanName);

    final team = await _teamRepository.findByName(cleanName);

    if (!mounted) return;

    await _loadTeams();

    if (!mounted) return;

    setState(() {
      _selectedOpponent = team;
      _rivalController.text = team?.name ?? cleanName;
    });

    _showLocalMessage(
      created ? 'Rival agregado al catálogo.' : 'Rival seleccionado.',
    );
  }

  Future<void> _pickAndAssignShieldForCurrentTeam() async {
    final cleanName = _rivalController.text.trim();

    if (cleanName.isEmpty) {
      _showLocalMessage('Primero ingresá o seleccioná un rival.');
      return;
    }

    TeamModel? team = await _teamRepository.findByName(cleanName);

    if (team == null) {
      await _teamRepository.addTeam(name: cleanName);
      team = await _teamRepository.findByName(cleanName);
    }

    if (!mounted || team == null) return;

    if ((team.shieldAsset ?? '').trim().isNotEmpty) {
      _showLocalMessage('Este equipo ya tiene un escudo incluido en la app.');
      return;
    }

    const typeGroup = XTypeGroup(
      label: 'Imágenes',
      extensions: <String>['png', 'jpg', 'jpeg', 'webp'],
    );

    final file = await openFile(
      acceptedTypeGroups: const <XTypeGroup>[typeGroup],
    );

    if (file == null) return;

    final sourcePath = file.path;
    if (sourcePath.isEmpty) {
      _showLocalMessage('No se pudo leer la imagen seleccionada.');
      return;
    }

    final sourceFile = File(sourcePath);
    final exists = await sourceFile.exists();

    if (!exists) {
      _showLocalMessage('La imagen seleccionada no existe.');
      return;
    }

    final extension = sourcePath.split('.').last.toLowerCase();
    final safeExtension = ['png', 'jpg', 'jpeg', 'webp'].contains(extension)
        ? extension
        : 'png';

    final appDir = await getApplicationDocumentsDirectory();
    final shieldsDir = Directory('${appDir.path}/team_shields');

    if (!await shieldsDir.exists()) {
      await shieldsDir.create(recursive: true);
    }

    final targetPath =
        '${shieldsDir.path}/${team.id}_${DateTime.now().millisecondsSinceEpoch}.$safeExtension';

    await sourceFile.copy(targetPath);

    final updated = await _teamRepository.updateTeamShieldFilePath(
      teamId: team.id,
      shieldFilePath: targetPath,
    );

    if (!mounted) return;

    if (!updated) {
      _showLocalMessage('No se pudo guardar el escudo.');
      return;
    }

    await _loadTeams();

    final refreshed = await _teamRepository.findByName(cleanName);

    if (!mounted) return;

    setState(() {
      _selectedOpponent = refreshed;
      _rivalController.text = refreshed?.name ?? cleanName;
    });

    _showLocalMessage('Escudo agregado correctamente.');
  }

  bool _isAssetPath(String value) {
    return value.trim().startsWith('assets/');
  }

  Iterable<TeamModel> _filterTeams(String query) {
    final normalizedQuery = TeamRepository.normalize(query);

    if (normalizedQuery.isEmpty) {
      return _availableTeams;
    }

    return _availableTeams.where((team) {
      final name = TeamRepository.normalize(team.name);
      final shortName = TeamRepository.normalize(team.shortName);

      return name.contains(normalizedQuery) ||
          shortName.contains(normalizedQuery);
    });
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

    final equipoPropio = widget.equipoPropio?.trim().isNotEmpty == true
        ? widget.equipoPropio!.trim()
        : 'Institución';

    final escudoPropio = widget.escudoPropio?.trim().isNotEmpty == true
        ? widget.escudoPropio!.trim()
        : null;

    final somosLocales = _condicion.trim().toLowerCase() == 'local';

    final equipoLocal = somosLocales ? equipoPropio : rival;
    final equipoVisitante = somosLocales ? rival : equipoPropio;

    final escudoLocal = somosLocales ? escudoPropio : escudoRival;
    final escudoVisitante = somosLocales ? escudoRival : escudoPropio;

    final existingMatchInstanceId = widget.initial?.matchInstanceId?.trim();

    final matchInstanceId =
        existingMatchInstanceId != null &&
            existingMatchInstanceId.isNotEmpty &&
            existingMatchInstanceId.toLowerCase() != 'null'
        ? existingMatchInstanceId
        : _generateMatchInstanceId();

    final partido = PartidoModel(
      temporada: widget.temporada,
      competencia: widget.competencia,
      institutionId: widget.institutionId,
      matchInstanceId: matchInstanceId,
      equipoPropio: equipoPropio,
      escudoPropio: escudoPropio,
      equipoLocal: equipoLocal,
      equipoVisitante: equipoVisitante,
      escudoLocal: escudoLocal,
      escudoVisitante: escudoVisitante,
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
                    _buildOpponentAutocompleteField(),
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

  Widget _buildOpponentAutocompleteField() {
    return Autocomplete<TeamModel>(
      initialValue: TextEditingValue(text: _rivalController.text),
      displayStringForOption: (team) => team.name,
      optionsBuilder: (textEditingValue) {
        return _filterTeams(textEditingValue.text);
      },
      onSelected: (team) {
        setState(() {
          _selectedOpponent = team;
          _rivalController.text = team.name;
        });
      },
      optionsViewBuilder: (context, onSelected, options) {
        final list = options.toList();

        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            color: const Color(0xFF0F1722),
            elevation: 8,
            borderRadius: BorderRadius.circular(14),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 260, maxWidth: 360),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: list.length,
                itemBuilder: (context, index) {
                  final team = list[index];

                  return ListTile(
                    dense: true,
                    leading: _buildTeamShield(team.displayShieldPath),
                    title: Text(
                      team.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    subtitle: team.shortName == null
                        ? null
                        : Text(
                            team.shortName!,
                            style: const TextStyle(
                              color: Color(0xFFAAB4C3),
                              fontSize: 12,
                            ),
                          ),
                    onTap: () => onSelected(team),
                  );
                },
              ),
            ),
          ),
        );
      },
      fieldViewBuilder:
          (context, textEditingController, focusNode, onFieldSubmitted) {
            if (textEditingController.text != _rivalController.text) {
              textEditingController.text = _rivalController.text;
              textEditingController.selection = TextSelection.collapsed(
                offset: textEditingController.text.length,
              );
            }

            return TextField(
              controller: textEditingController,
              focusNode: focusNode,
              textInputAction: TextInputAction.next,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Rival',
                hintText: 'Ejemplo: C.A. River Plate',
                labelStyle: const TextStyle(color: Color(0xFFAAB4C3)),
                hintStyle: const TextStyle(color: Color(0xFF6B7280)),
                filled: true,
                fillColor: const Color(0xFF111A28),
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(8),
                  child: _buildTeamShield(_selectedOpponent?.displayShieldPath),
                ),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: 'Agregar escudo',
                      icon: const Icon(Icons.image_rounded),
                      onPressed: _pickAndAssignShieldForCurrentTeam,
                    ),
                    IconButton(
                      tooltip: 'Agregar rival al catálogo',
                      icon: const Icon(Icons.add_rounded),
                      onPressed: () async {
                        await _createQuickTeam(textEditingController.text);

                        if (!mounted) return;

                        textEditingController.text = _rivalController.text;
                        textEditingController.selection =
                            TextSelection.collapsed(
                              offset: textEditingController.text.length,
                            );
                      },
                    ),
                  ],
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(color: Color(0xFF4F8CFF)),
                ),
              ),
              onChanged: (value) async {
                _rivalController.text = value;

                final selected = await _teamRepository.findByName(value);

                if (!mounted) return;

                setState(() {
                  _selectedOpponent = selected;
                });
              },
            );
          },
    );
  }

  Widget _buildTeamShield(String? shieldPath) {
    final path = (shieldPath ?? '').trim();

    if (path.isEmpty) {
      return const Icon(
        Icons.shield_outlined,
        color: Color(0xFFAAB4C3),
        size: 22,
      );
    }

    if (_isAssetPath(path)) {
      return Image.asset(
        path,
        width: 26,
        height: 26,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) {
          return const Icon(
            Icons.shield_outlined,
            color: Color(0xFFAAB4C3),
            size: 22,
          );
        },
      );
    }

    return Image.file(
      File(path),
      width: 26,
      height: 26,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) {
        return const Icon(
          Icons.shield_outlined,
          color: Color(0xFFAAB4C3),
          size: 22,
        );
      },
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
