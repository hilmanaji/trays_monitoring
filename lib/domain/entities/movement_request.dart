class MovementRequest {
  const MovementRequest({
    required this.fromLocationId,
    required this.toLocationId,
    required this.rfids,
  });

  final int fromLocationId;
  final int toLocationId;
  final List<String> rfids;
}
