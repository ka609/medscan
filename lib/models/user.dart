import '../core/utils/id_generator.dart';

/// Définition modulaire des postes médicaux renseignés lors de l'inscription
enum MedicalPosition {
  doctor('Docteur en Médecine', 'DOCTEUR'),
  physician('Médecin Généraliste', 'MEDECIN'),
  practitioner('Praticien Hospitalier', 'PRATICIEN'),
  specialist('Médecin Spécialiste', 'SPECIALISTE');

  final String label;
  final String code;
  const MedicalPosition(this.label, this.code);

  static MedicalPosition? fromString(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final val = value.toUpperCase().trim();
    for (final pos in MedicalPosition.values) {
      if (val.contains(pos.code) || val.contains(pos.name.toUpperCase())) {
        return pos;
      }
    }
    return null;
  }
}

/// Rôles normalisés au sein du système
enum UserRole {
  patient('PATIENT', 'Patient'),
  doctor('DOCTOR', 'Médecin'),
  practitioner('PRATICIEN', 'Praticien'),
  nurse('NURSE', 'Infirmier'),
  labTech('LAB_TECH', 'Laborantin'),
  admin('ADMIN', 'Administrateur');

  final String code;
  final String label;
  const UserRole(this.code, this.label);
}

class User {
  final String id;
  final String username;
  final String email;
  final String displayName;
  final String tenantId;
  final String tenantCode;
  final List<String> roles;
  final List<String> permissions;
  final String? position; // Poste médical / statut (Praticien, Médecin, Docteur, etc.)
  final String? specialty; // Spécialité médicale éventuelle
  final String? departmentName; // Département médical d'appartenance

  const User({
    required this.id,
    required this.username,
    required this.email,
    required this.displayName,
    required this.tenantId,
    required this.tenantCode,
    required this.roles,
    required this.permissions,
    this.position,
    this.specialty,
    this.departmentName,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String? ?? IdGenerator.generate('usr'),
      username: json['username'] as String? ?? '',
      email: json['email'] as String? ?? '',
      displayName: json['displayName'] as String? ?? '',
      tenantId: json['tenantId'] as String? ?? IdGenerator.tenantId(),
      tenantCode: json['tenantCode'] as String? ?? '',
      roles: List<String>.from(json['roles'] ?? const []),
      permissions: List<String>.from(json['permissions'] ?? const []),
      position: json['position'] as String? ??
          json['medicalPosition'] as String? ??
          json['title'] as String?,
      specialty: json['specialty'] as String?,
      departmentName: json['department'] as String? ?? json['departmentName'] as String?,
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
      'position': position,
      'specialty': specialty,
      'departmentName': departmentName,
    };
  }

  bool hasRole(String role) {
    return roles.contains(role);
  }

  bool hasPermission(String permission) {
    return permissions.contains(permission);
  }

  /// Propriété modulaire indiquant si l'utilisateur est un praticien / médecin / docteur
  bool get isDoctor {
    if (position != null && position!.trim().isNotEmpty) {
      final p = position!.toLowerCase().trim();
      if (p.contains('medecin') ||
          p.contains('médecin') ||
          p.contains('docteur') ||
          p.contains('praticien') ||
          p.contains('doctor')) {
        return true;
      }
    }
    return roles.any((r) {
      final normalized = r.toUpperCase();
      return normalized.contains('DOCTOR') ||
          normalized.contains('PRATICIEN') ||
          normalized.contains('MEDECIN') ||
          normalized.contains('PHYSICIAN');
    });
  }

  /// Propriété modulaire indiquant si l'utilisateur est un infirmier
  bool get isNurse {
    if (position != null && position!.trim().isNotEmpty) {
      final p = position!.toLowerCase().trim();
      if (p.contains('infirmier') || p.contains('infirmière') || p.contains('nurse')) {
        return true;
      }
    }
    return roles.any((r) {
      final normalized = r.toUpperCase();
      return normalized.contains('NURSE') || normalized.contains('INFIRMIER');
    });
  }

  /// Propriété modulaire indiquant si l'utilisateur est un personnel soignant (médecin ou infirmier)
  bool get isHealthWorker => isDoctor || isNurse;

  /// Propriété modulaire indiquant si l'utilisateur est un laborantin / technicien de labo
  bool get isLabTech {
    if (position != null && position!.trim().isNotEmpty) {
      final p = position!.toLowerCase().trim();
      if (p.contains('laborat') || p.contains('biologiste') || p.contains('technicien')) {
        return true;
      }
    }
    return roles.any((r) {
      final normalized = r.toUpperCase();
      return normalized.contains('LAB') ||
          normalized.contains('LABORANTIN') ||
          normalized.contains('TECHNICIAN');
    });
  }

  /// Propriété modulaire indiquant si l'utilisateur est un patient
  bool get isPatient => !isHealthWorker && !isLabTech;

  /// Département de santé d'affectation
  String get department {
    if (departmentName != null && departmentName!.trim().isNotEmpty) {
      return departmentName!;
    }
    if (specialty != null && specialty!.trim().isNotEmpty) {
      return specialty!;
    }
    if (isDoctor) {
      if (displayName.toLowerCase().contains('pediatr') || (position?.toLowerCase().contains('pediatr') ?? false)) {
        return 'Pédiatrie';
      }
      return 'Médecine Générale';
    }
    if (isNurse) {
      return 'Soins & Urgences';
    }
    if (isLabTech) {
      return 'Laboratoire d\'analyses';
    }
    return 'Tous Départements';
  }

  /// Libellé d'affichage professionnel (Ex: Dr. Traoré, Infirmier Sawadogo, Tech. Sanou)
  String get displayTitle {
    if (position != null && position!.trim().isNotEmpty) {
      return '$position $displayName'.trim();
    }
    if (isDoctor) {
      return 'Dr. $displayName';
    }
    if (isNurse) {
      return 'Inf. $displayName';
    }
    if (isLabTech) {
      return 'Tech. $displayName';
    }
    return displayName;
  }
}

/// Extension modulaire sur [User?] pour un accès direct et typé sans vérifications en dur répétées
extension UserExtension on User? {
  bool get isDoctor => this?.isDoctor ?? false;
  bool get isNurse => this?.isNurse ?? false;
  bool get isHealthWorker => this?.isHealthWorker ?? false;
  bool get isLabTech => this?.isLabTech ?? false;
  bool get isPatient => this?.isPatient ?? true;
  String get department => this?.department ?? 'Tous Départements';
  String get displayTitle => this?.displayTitle ?? 'Utilisateur';
}
