class Tray {
  const Tray({
    required this.id,
    required this.epc,
    required this.trayTypeName,
    required this.currentLocationName,
    required this.status,
    this.createdAt,
  });

  final int id;
  final String epc;
  final String trayTypeName;
  final String currentLocationName;
  final String status;
  final DateTime? createdAt;
}
