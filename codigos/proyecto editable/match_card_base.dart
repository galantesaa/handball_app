import 'package:flutter/material.dart';
import '../models/match_model.dart';

/// ===============================
/// MatchCardPro
/// Card única para Fixture y Partidos Jugados.
/// - En Fixture muestra Fecha + Pendiente/Finalizado + botón de acción.
/// - En Historial puede ocultar chips y mantener Ver resumen.
/// - El nombre del rival prioriza legibilidad y no se corta agresivamente.
/// ===============================
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

  @override
  Widget build(BuildContext context) {
    final estadoColor = match.finalizado
        ? const Color(0xFF9F2D2D)
        : const Color(0xFF4F8CFF);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onPressed,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: EdgeInsets.all(compact ? 14 : 16),
        decoration: BoxDecoration(
          color: const Color(0xFF0F1722).withOpacity(0.88),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showFechaChip || showEstadoChip) ...[
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (showFechaChip && match.fechaNumero > 0)
                    _chip('Fecha ${match.fechaNumero}', const Color(0xFF4F8CFF)),
                  if (showEstadoChip)
                    _chip(match.finalizado ? 'Finalizado' : 'Pendiente', estadoColor),
                ],
              ),
              const SizedBox(height: 14),
            ],
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _shield(),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        match.rival,
                        maxLines: 3,
                        softWrap: true,
                        overflow: TextOverflow.visible,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: compact ? 16 : 18,
                          height: 1.12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _subtitle(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFFAAB4C3),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                if (match.finalizado) ...[
                  const SizedBox(width: 10),
                  Text(
                    match.marcadorCancha,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: compact ? 20 : 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onPressed,
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: match.finalizado
                      ? const Color(0xFF9F2D2D)
                      : const Color(0xFF4F8CFF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  actionText,
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
    );
  }

  String _subtitle() {
    final meta = <String>[];
    if (match.categoria != '-') meta.add(match.categoria);
    if (match.torneo != '-') meta.add(match.torneo);
    if (match.fecha != '-' || match.hora != '-') meta.add('${match.fecha} · ${match.hora}');
    if (match.condicionVisible != '-') meta.add(match.condicionVisible);
    return meta.join(' · ');
  }

  Widget _shield() {
    return Container(
      width: compact ? 54 : 62,
      height: compact ? 54 : 62,
      decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
      padding: const EdgeInsets.all(8),
      child: Center(
        child: match.escudoRival == null
            ? const Icon(Icons.sports_handball, color: Color(0xFF1C2B44), size: 24)
            : Image.asset(match.escudoRival!, fit: BoxFit.contain),
      ),
    );
  }

  Widget _chip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.16),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
