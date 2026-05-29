class RegisterRfidRequest {
  const RegisterRfidRequest({
    required this.epc,
    required this.trayTypeId,
    required this.locationId,
  });

  final String epc;
  final int trayTypeId;
  final int locationId;
}
