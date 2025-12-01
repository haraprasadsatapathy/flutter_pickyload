class Insurance {
  final String id;
  final String tripId;
  final double loadValue;
  final double premiumAmount;
  final double coverageAmount;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;

  Insurance({
    required this.id,
    required this.tripId,
    required this.loadValue,
    required this.premiumAmount,
    required this.coverageAmount,
    required this.startDate,
    required this.endDate,
    this.isActive = true,
  });

  static double calculatePremium(double loadValue, double distance) {
    double basePremium = loadValue * 0.02;
    double distanceFactor = distance * 0.5;
    return basePremium + distanceFactor;
  }

  static double getCoverageAmount(double loadValue) {
    return loadValue * 1.5;
  }
}
