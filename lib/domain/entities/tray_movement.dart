class TrayMovement {
  const TrayMovement({
    required this.id,
    required this.movementNumber,
    required this.fromLocationName,
    required this.toLocationName,
    required this.rfids,
    required this.totalRfid,
    this.createdAt,
  });

  final int id;
  final String movementNumber;
  final String fromLocationName;
  final String toLocationName;
  final List<String> rfids;
  final int totalRfid;
  final DateTime? createdAt;
}
