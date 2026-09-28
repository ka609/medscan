class StorageKeys {
  StorageKeys._();

  // Authentification
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String tokenType = 'token_type';
  static const String expiresAt = 'expires_at';
  static const String userId = 'user_id';
  static const String patientId = 'patient_id';
  static const String userRole = 'user_role';
  static const String userData = 'user_data';

  // État de l'application
  static const String onboardingCompleted = 'onboarding_completed';

  static const String selectedLanguage = 'selected_language';

  // Cache
  static const String cachePrefix = 'cache_';

  static const String identityCache = 'identity';

  static const String emergencyCardCache = 'emergency_card';

  static const String criticalAllergiesCache = 'critical_allergies';

  static const String essentialTreatmentsCache = 'essential_treatments';

  static const String selectedHistoryCache = 'selected_history';

  static const String authorizedExaminationsCache = 'authorized_examinations';

  static const String authorizedDocumentsCache = 'authorized_documents';

  // Base de données
  static const String databaseName = 'medscan_local.db';

  static const int databaseVersion = 3;

  // Tables
  static const String cacheTable = 'cache';

  static const String syncQueueTable = 'sync_queue';

  static const String syncLogTable = 'sync_log';

  // Statuts de synchronisation
  static const String syncPending = 'pending';

  static const String syncProcessing = 'processing';

  static const String syncRetry = 'retry';

  static const String syncCompleted = 'completed';

  static const String syncConflict = 'conflict';

  static const String syncFailed = 'failed';

  // Types de fraîcheur
  static const String freshnessFresh = 'fresh';

  static const String freshnessStale = 'stale';

  static const String freshnessExpired = 'expired';

  static const String freshnessRevoked = 'revoked';
}
