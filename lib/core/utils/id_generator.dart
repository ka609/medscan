import 'dart:math';

/// Générateur d'identifiants dynamiques, sécurisés et modulaires.
/// Élimine tout identifiant codé en dur (ex: pat-001, doc-001, etc.) dans l'application.
class IdGenerator {
  static final Random _random = Random.secure();

  /// Génère un identifiant unique avec un préfixe donné (ex: 'pat', 'doc', 'cert', 'msg')
  static String generate(String prefix) {
    final timestamp = DateTime.now().microsecondsSinceEpoch;
    final randomSuffix = _random.nextInt(0xFFFFFF).toRadixString(16).padLeft(6, '0');
    return '${prefix}_${timestamp.toRadixString(36)}_$randomSuffix';
  }

  /// Identifiants d'utilisateurs et rôles
  static String patientId() => generate('pat');
  static String doctorId() => generate('doc');
  static String tenantId() => generate('ten');

  /// Identifiants de documents et flux cliniques
  static String certificateId() => generate('cert');
  static String messageId() => generate('msg');
  static String alertId() => generate('alt');
  static String referralId() => generate('ref');
  static String grievanceId() => generate('grv');

  /// Code officiel de certificat médical (ex: CERT-2026-8A3F1)
  static String certificateCode() {
    final year = DateTime.now().year;
    final suffix = (_random.nextInt(0xFFFFF) + 0x10000).toRadixString(16).toUpperCase();
    return 'CERT-$year-$suffix';
  }

  /// Identifiant étanche et cloisonné d'une conversation entre deux participants
  static String conversationId(String participantA, String participantB) {
    final safeA = participantA.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
    final safeB = participantB.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
    final sorted = [safeA, safeB]..sort();
    return 'conv_${sorted[0]}_${sorted[1]}';
  }

  /// Code sécurisé de salle de téléconsultation WebRTC/Jitsi (ex: #medscan-8F3A2B)
  static String roomCode([String? seed]) {
    if (seed != null && seed.trim().isNotEmpty) {
      final cleaned = seed.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toUpperCase();
      if (cleaned.length >= 6) {
        return cleaned.substring(0, 6);
      }
    }
    final suffix = (_random.nextInt(0xFFFFFF) + 0x100000).toRadixString(16).toUpperCase();
    return suffix.substring(0, 6);
  }
}
