class ApiConstants {
  ApiConstants._();

  // API
  static const String baseUrl = 'https://medscan-sluw.onrender.com/medscan/api';

  static const String apiVersion = '/v1';

  // Headers
  static const String contentType = 'application/json';

  static const String accept = 'application/json';

  static const String authorization = 'Authorization';

  static const String bearer = 'Bearer';

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);

  static const Duration receiveTimeout = Duration(seconds: 30);

  static const Duration sendTimeout = Duration(seconds: 30);

  // Auth
  static const String login = '/v1/auth/login';

  static const String me = '/v1/auth/me';

  static const String refresh = '/v1/auth/refresh';

  // Patients
  static const String patients = '/v1/patients';

  static String patient(String patientId) {
    return '/v1/patients/$patientId';
  }

  static String patientVitals(String patientId) {
    return '/v1/patients/$patientId/vitals';
  }

  static String patientConsultations(String patientId) {
    return '/v1/patients/$patientId/consultations';
  }

  static String patientPrescriptions(String patientId) {
    return '/v1/patients/$patientId/prescriptions';
  }

  // Prescriptions
  static String prescription(String code) {
    return '/v1/prescriptions/$code';
  }

  static String dispensePrescription(String code) {
    return '/v1/prescriptions/$code/dispense';
  }

  // Imaging
  static const String imagingStudies = '/v1/imaging/studies';

  static String imagingStudy(String studyId) {
    return '/v1/imaging/studies/$studyId';
  }

  static String analyzeImagingStudy(String studyId) {
    return '/v1/imaging/studies/$studyId/ai-analyze';
  }

  static String imagingReport(String studyId) {
    return '/v1/imaging/studies/$studyId/report';
  }

  // Santé du serveur
  static const String health = '/health';
}
