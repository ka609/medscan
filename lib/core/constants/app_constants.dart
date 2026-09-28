class AppConstants {
  AppConstants._();

  // Application
  static const String appName = 'MedScan';
  static const String appVersion = '1.0.0';

  // Environnement
  static const bool useMockData = false;
  static const bool enableOfflineMode = true;
  static const bool enableLogging = true;

  // Pagination
  static const int defaultPage = 0;
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Cache
  static const Duration identityCacheDuration = Duration(hours: 24);

  static const Duration emergencyCardCacheDuration = Duration(hours: 24);

  static const Duration criticalAllergiesCacheDuration = Duration(hours: 12);

  static const Duration essentialTreatmentsCacheDuration = Duration(hours: 12);

  static const Duration selectedHistoryCacheDuration = Duration(hours: 6);

  static const Duration authorizedExaminationsCacheDuration = Duration(
    hours: 6,
  );

  static const Duration authorizedDocumentsCacheDuration = Duration(hours: 6);

  // Synchronisation
  static const int maxSyncAttempts = 5;

  static const Duration syncRetryDelay = Duration(seconds: 30);

  static const Duration syncInterval = Duration(minutes: 5);

  // Réseau
  static const Duration networkTimeout = Duration(seconds: 30);

  // Offline
  static const bool allowExpiredCache = false;
  static const bool allowRevokedCache = false;
}
