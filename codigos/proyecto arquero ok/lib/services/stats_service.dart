/// ===============================
/// StatsService
/// Servicio puro para cálculos reutilizables.
/// No depende de Flutter ni de BuildContext.
/// ===============================
class StatsService {
  /// ================================
  /// Eficacia arquero
  /// ================================
  static double calcularEficacia(int atajadas, int goles) {
    final total = atajadas + goles;
    if (total == 0) return 0;
    return (atajadas / total) * 100;
  }
}