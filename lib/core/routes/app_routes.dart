class AppRoutes {
  AppRoutes._();

  // Général
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const home = '/home';

  // Authentification
  static const login = '/login';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';
  static const otp = '/otp';
  static const resetPassword = '/reset-password';

  // Profil
  static const profile = '/profile';
  static const editProfile = '/profile/edit';
  static const security = '/profile/security';

  // Organisations
  static const organizations = '/organizations';
  static const organizationDetails =
      '/organizations/details';

  // Praticiens
  static const practitioners = '/practitioners';
  static const practitionerDetails =
      '/practitioners/details';

  // Rendez-vous
  static const appointments = '/appointments';
  static const appointmentDetails =
      '/appointments/details';
  static const bookAppointment =
      '/appointments/book';

  // Dossier médical & Consultations
  static const medicalRecord = '/medical-record';
  static const consultations = '/medical-record/consultations';
  static const doctorConsultations = '/doctor/consultations';
  static const labManagement = '/lab';
  static const examinations = '/medical-record/examinations';
  static const results = '/medical-record/results';
  static const medications = '/medical-record/medications';
  static const conditions = '/medical-record/conditions';
  static const allergies = '/medical-record/allergies';
  static const documents = '/medical-record/documents';

  // Messages
  static const messages = '/messages';
  static const conversation = '/messages/conversation';

  // Notifications
  static const notifications = '/notifications';

  // Consentements
  static const consents = '/consents';
  static const consentDetails = '/consents/details';
  static const sharing = '/consents/sharing';

  // Pharmacies
  static const pharmacies = '/pharmacies';
  static const pharmacyDetails = '/pharmacies/details';
  static const prescriptions = '/prescriptions';
  static const prescriptionDetails =
      '/prescriptions/details';

  // Commandes
  static const orders = '/orders';
  static const orderDetails = '/orders/details';

  // Téléconsultation
  static const teleconsult = '/teleconsult';

  // Certificats officiels
  static const certificates = '/certificates';

  // Orientations & Redirections
  static const referrals = '/referrals';

  // Réclamations & Déontologie
  static const grievances = '/grievances';

  // Livraison
  static const deliveryTracking = '/delivery/tracking';
}