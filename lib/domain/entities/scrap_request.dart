class ScrapRequest {
  const ScrapRequest({
    required this.epc,
    required this.reason,
    required this.remarks,
  });

  final String epc;
  final String reason;
  final String remarks;
}
