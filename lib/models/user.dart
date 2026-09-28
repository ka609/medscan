class User {
  final String id;
  final String username;
  final String email;
  final String displayName;
  final String tenantId;
  final String tenantCode;
  final List<String> roles;
  final List<String> permissions;

  const User({
    required this.id,
    required this.username,
    required this.email,
    required this.displayName,
    required this.tenantId,
    required this.tenantCode,
    required this.roles,
    required this.permissions,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String? ?? '',
      username: json['username'] as String? ?? '',
      email: json['email'] as String? ?? '',
      displayName: json['displayName'] as String? ?? '',
      tenantId: json['tenantId'] as String? ?? '',
      tenantCode: json['tenantCode'] as String? ?? '',
      roles: List<String>.from(json['roles'] ?? const []),
      permissions: List<String>.from(json['permissions'] ?? const []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'displayName': displayName,
      'tenantId': tenantId,
      'tenantCode': tenantCode,
      'roles': roles,
      'permissions': permissions,
    };
  }

  bool hasRole(String role) {
    return roles.contains(role);
  }

  bool hasPermission(String permission) {
    return permissions.contains(permission);
  }
}