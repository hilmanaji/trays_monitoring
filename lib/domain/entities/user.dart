class User {
  const User({
    required this.id,
    required this.nik,
    required this.name,
    required this.email,
    required this.role,
    this.roles = const <String>[],
  });

  final int id;
  final String nik;
  final String name;
  final String email;
  final String role;
  final List<String> roles;

  List<String> get resolvedRoles {
    final uniqueRoles = <String>{};
    for (final candidate in roles) {
      final normalized = candidate.trim();
      if (normalized.isNotEmpty) {
        uniqueRoles.add(normalized);
      }
    }
    if (uniqueRoles.isNotEmpty) {
      return uniqueRoles.toList(growable: false);
    }
    final normalizedRole = role.trim();
    if (normalizedRole.isNotEmpty) {
      return <String>[normalizedRole];
    }
    return const <String>[];
  }

  String get primaryRole => resolvedRoles.isNotEmpty ? resolvedRoles.first : '-';

  String get rolesLabel => resolvedRoles.isNotEmpty ? resolvedRoles.join(', ') : '-';
}
