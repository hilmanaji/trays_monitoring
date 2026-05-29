class PendingMovement {
  const PendingMovement({
    required this.localId,
    required this.fromLocationId,
    required this.toLocationId,
    required this.rfids,
    required this.createdAt,
  });

  final String localId;
  final int fromLocationId;
  final int toLocationId;
  final List<String> rfids;
  final DateTime createdAt;
}
