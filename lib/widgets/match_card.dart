import 'package:flutter/material.dart';
import '../models/match_model.dart';

class MatchCardPro extends StatelessWidget {
  final MatchModel match;
  final VoidCallback onPressed;
  final String actionText;
  final bool showFechaChip;
  final bool showEstadoChip;
  final bool compact;

  const MatchCardPro({
    super.key,
    required this.match,
    required this.onPressed,
    required this.actionText,
    this.showFechaChip = true,
    this.showEstadoChip = true,
    this.compact = false,
  });

  static const String _sanFernandoAsset = 'assets/images/san_fernando.png';

  @override
  Widget build(BuildContext context) {
    final buttonColor = match.finalizado
        ? const Color(0xFF6F2428)
        : const Color(0xFF4F8CFF);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onPressed,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: EdgeInsets.all(compact ? 12 : 14),
        decoration: BoxDecoration(
          color: const Color(0xFF0F1722).withOpacity(0.90),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                _DateBlock(fecha: match.fecha, hora: match.hora),
                Container(
                  width: 1,
                  height: 86,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  color: Colors.white.withOpacity(0.08),
                ),
                Expanded(
                  child: Column(
                    children: [
                      _TeamScoreRow(
                        teamName: match.equipoLocal,
                        shieldAsset: _localShield(),
                        score: match.finalizado
                            ? match.golesLocal.toString()
                            : '-',
                        isWinner:
                            match.finalizado &&
                            match.golesLocal > match.golesVisitante,
                      ),
                      const SizedBox(height: 16),
                      _TeamScoreRow(
                        teamName: match.equipoVisitante,
                        shieldAsset: _visitorShield(),
                        score: match.finalizado
                            ? match.golesVisitante.toString()
                            : '-',
                        isWinner:
                            match.finalizado &&
                            match.golesVisitante > match.golesLocal,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _MetaLine(match: match),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onPressed,
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: buttonColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  minimumSize: const Size(double.infinity, 42),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),

                child: Text(
                  actionText,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _localShield() {
    if (match.somosLocales) return _sanFernandoAsset;
    return match.escudoRival;
  }

  String? _visitorShield() {
    if (match.somosLocales) return match.escudoRival;
    return _sanFernandoAsset;
  }
}

class _DateBlock extends StatelessWidget {
  final String fecha;
  final String hora;

  const _DateBlock({required this.fecha, required this.hora});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 54,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            fecha,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.visible,
            style: const TextStyle(
              color: Color(0xFFAAB4C3),
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            hora,
            textAlign: TextAlign.center,
            maxLines: 1,
            style: const TextStyle(
              color: Color(0xFFAAB4C3),
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _TeamScoreRow extends StatelessWidget {
  final String teamName;
  final String? shieldAsset;
  final String score;
  final bool isWinner;

  const _TeamScoreRow({
    required this.teamName,
    required this.shieldAsset,
    required this.score,
    required this.isWinner,
  });

  @override
  Widget build(BuildContext context) {
    final scoreColor = isWinner
        ? const Color(0xFF22C55E) // 🟢 verde ganador
        : Colors.white;

    final bgColor = isWinner
        ? const Color(0xFF22C55E).withOpacity(0.18)
        : Colors.white.withOpacity(0.10);

    return Row(
      children: [
        _Shield(assetPath: shieldAsset),
        const SizedBox(width: 8),

        Expanded(
          child: Text(
            teamName,
            maxLines: 1,
            overflow: TextOverflow.visible,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),

        const SizedBox(width: 6),

        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Center(
            child: Text(
              score,
              style: TextStyle(
                color: scoreColor,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Shield extends StatelessWidget {
  final String? assetPath;

  const _Shield({required this.assetPath});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
      ),
      padding: const EdgeInsets.all(5),
      child: Center(
        child: assetPath == null
            ? const Icon(
                Icons.sports_handball,
                color: Color(0xFF1C2B44),
                size: 18,
              )
            : Image.asset(
                assetPath!,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.sports_handball,
                  color: Color(0xFF1C2B44),
                  size: 18,
                ),
              ),
      ),
    );
  }
}

class _MetaLine extends StatelessWidget {
  final MatchModel match;

  const _MetaLine({required this.match});

  @override
  Widget build(BuildContext context) {
    final estado = match.finalizado ? 'Finalizado' : 'Pendiente';

    final items = <String>[
      match.categoria,
      match.torneo,
      match.condicionVisible,
      estado,
    ].where((e) => e.trim().isNotEmpty && e != '-').toList();

    return Align(
      alignment: Alignment.centerLeft,
      child: Wrap(
        spacing: 7,
        runSpacing: 7,
        children: items.map((text) {
          final bool isEstado = text == 'Finalizado' || text == 'Pendiente';
          final Color color = text == 'Finalizado'
              ? const Color(0xFFFF6B6B)
              : text == 'Pendiente'
              ? const Color(0xFF4F8CFF)
              : const Color(0xFFAAB4C3);

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
            decoration: BoxDecoration(
              color: isEstado
                  ? color.withOpacity(0.15)
                  : Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              text,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
