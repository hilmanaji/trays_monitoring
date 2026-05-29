class User {
  const User({
    required this.id,
    required this.nik,
    required this.name,
    required this.email,
    required this.role,
  });

  final int id;
  final String nik;
  final String name;
  final String email;
  final String role;
}
