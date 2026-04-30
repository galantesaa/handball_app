/// ===============================
/// StatsService
/// Servicio puro para cálculos reutilizables.
/// No depende de Flutter ni de BuildContext.
/// ===============================
class StatsService {
  const StatsService._();

  static double eficaciaArquero({required int atajadas, required int goles}) {
    final total = atajadas + goles;
    if (total <= 0) return 0;
    return (atajadas / total) * 100;
  }

  static double efectividadJugador({required int goles, required int tiros}) {
    if (tiros <= 0) return 0;
    return (goles / tiros) * 100;
  }
}
