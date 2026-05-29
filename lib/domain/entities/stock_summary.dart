class StockSummary {
  const StockSummary({
    required this.locationId,
    required this.locationName,
    required this.total,
  });

  final int locationId;
  final String locationName;
  final int total;
}
