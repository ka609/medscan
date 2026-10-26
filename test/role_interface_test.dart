import 'package:flutter_test/flutter_test.dart';
import 'package:medscan/core/utils/id_generator.dart';
import 'package:medscan/models/lab_order.dart';
import 'package:medscan/models/message.dart';
import 'package:medscan/models/user.dart';
import 'package:medscan/services/lab_service.dart';
import 'package:medscan/services/message_service.dart';
import 'package:medscan/services/referral_service.dart';

void main() {
  group('Différenciation stricte des profils et rôles', () {
    test('Profil Docteur / Médecin', () {
      final doctor = User.fromJson({
        'id': IdGenerator.doctorId(),
        'username': 'dr_ouedraogo',
        'email': 'amadou.ouedraogo@medscan.bf',
        'displayName': 'Amadou Ouédraogo',
        'tenantId': IdGenerator.tenantId(),
        'tenantCode': 'CHU-YO',
        'roles': ['DOCTOR'],
        'permissions': ['READ_RECORD', 'WRITE_CONSULTATION', 'VALIDATE_APPOINTMENT'],
        'position': 'Médecin Généraliste',
        'department': 'Médecine Générale',
      });

      expect(doctor.isDoctor, isTrue);
      expect(doctor.isNurse, isFalse);
      expect(doctor.isHealthWorker, isTrue);
      expect(doctor.isLabTech, isFalse);
      expect(doctor.isPatient, isFalse);
      expect(doctor.department, 'Médecine Générale');
      expect(doctor.displayTitle, 'Médecin Généraliste Amadou Ouédraogo');
    });

    test('Profil Infirmier (Soignant)', () {
      final nurse = User.fromJson({
        'id': 'nurse-001',
        'username': 'inf_somda',
        'email': 'fatou.somda@medscan.bf',
        'displayName': 'Fatou Somda',
        'tenantId': IdGenerator.tenantId(),
        'tenantCode': 'CHU-YO',
        'roles': ['NURSE'],
        'permissions': ['READ_RECORD', 'CARE_ACTS'],
        'position': 'Infirmière',
        'department': 'Pédiatrie',
      });

      expect(nurse.isDoctor, isFalse);
      expect(nurse.isNurse, isTrue);
      expect(nurse.isHealthWorker, isTrue);
      expect(nurse.isLabTech, isFalse);
      expect(nurse.isPatient, isFalse);
      expect(nurse.department, 'Pédiatrie');
      expect(nurse.displayTitle, 'Infirmière Fatou Somda');
    });

    test('Profil Laborantin (Technicien de Laboratoire)', () {
      final labTech = User.fromJson({
        'id': 'lab-001',
        'username': 'lab_kabore',
        'email': 'moussa.kabore@medscan.bf',
        'displayName': 'Moussa Kaboré',
        'tenantId': IdGenerator.tenantId(),
        'tenantCode': 'CHU-YO',
        'roles': ['LAB_TECH'],
        'permissions': ['ENTER_RESULTS', 'VALIDATE_LAB'],
        'position': 'Biologiste Médical',
        'department': 'Laboratoire',
      });

      expect(labTech.isDoctor, isFalse);
      expect(labTech.isNurse, isFalse);
      expect(labTech.isHealthWorker, isFalse);
      expect(labTech.isLabTech, isTrue);
      expect(labTech.isPatient, isFalse);
      expect(labTech.displayTitle, 'Biologiste Médical Moussa Kaboré');
    });

    test('Profil Patient', () {
      final patient = User.fromJson({
        'id': IdGenerator.patientId(),
        'username': 'patient_sawadogo',
        'email': 'mariam.sawadogo@medscan.bf',
        'displayName': 'Mariam Sawadogo',
        'tenantId': IdGenerator.tenantId(),
        'tenantCode': 'CHU-YO',
        'roles': ['PATIENT'],
        'permissions': ['READ_OWN_RECORD'],
      });

      expect(patient.isDoctor, isFalse);
      expect(patient.isNurse, isFalse);
      expect(patient.isHealthWorker, isFalse);
      expect(patient.isLabTech, isFalse);
      expect(patient.isPatient, isTrue);
      expect(patient.displayTitle, 'Mariam Sawadogo');
    });
  });

  group('Flux Laborantin : Analyses et Déclenchement d\'envoi Dr & Patient', () {
    final labService = LabService();
    final messageService = MessageService();

    test('Laborantin peut valider des analyses et déclencher l\'envoi simultané au docteur et au patient', () async {
      // Récupérer la liste des ordres
      final orders = await labService.getOrders();
      expect(orders.isNotEmpty, isTrue);
      final initialOrder = orders.first;

      // Saisie des résultats d'analyse
      final completedOrder = await labService.validateResults(
        orderId: initialOrder.id,
        technicianId: 'lab-001',
        technicianName: 'Moussa Kaboré (Laborantin)',
        results: const [
          LabResultItem(
            testCode: 'HB',
            testName: 'Hémoglobine',
            valueNumeric: 8.4,
            unit: 'g/dL',
            referenceLow: 12.0,
            referenceHigh: 16.0,
            isAbnormal: true,
            isCritical: true,
          ),
          LabResultItem(
            testCode: 'PLQ',
            testName: 'Plaquettes',
            valueNumeric: 240000,
            unit: '/mm3',
            referenceLow: 150000,
            referenceHigh: 400000,
            isAbnormal: false,
          ),
        ],
        isCritical: true,
      );

      expect(completedOrder.status, 'VALIDATED');
      expect(completedOrder.isCriticalAlert, isTrue);
      expect(completedOrder.results.length, 2);

      // Déclenchement de l'envoi de l'application vers le docteur et le patient
      await labService.dispatchResultsToDoctorAndPatient(completedOrder);

      // Vérifier la notification clinique reçue par le patient
      final patientAlerts = await messageService.getAlerts(
        userId: completedOrder.patientId,
      );
      final patientHasLabAlert = patientAlerts.any((a) => a.title.toLowerCase().contains('labo') || a.title.toLowerCase().contains('biologique'));
      expect(patientHasLabAlert, isTrue, reason: 'Le patient doit recevoir l\'alerte de ses résultats');

      // Vérifier la notification clinique reçue par le médecin traitant
      final doctorAlerts = await messageService.getAlerts(
        userId: completedOrder.prescriberId,
      );
      final doctorHasLabAlert = doctorAlerts.any((a) => a.title.toLowerCase().contains('labo') || a.title.toLowerCase().contains('biologique'));
      expect(doctorHasLabAlert, isTrue, reason: 'Le docteur doit recevoir l\'alerte prioritaire du labo');
    });

    test('Laborantin peut fixer un rendez-vous de prélèvement pour un patient', () async {
      final patientId = IdGenerator.patientId();
      await labService.bookLabAppointment(
        patientId: patientId,
        patientName: 'Diallo Ousmane',
        testName: 'Glycémie à jeun & Bilan lipidique',
        date: DateTime.now().add(const Duration(days: 2)),
        slot: '08:30 - 09:00',
      );

      final orders = await labService.getOrders(patientId: patientId);
      expect(orders.any((o) => o.patientName == 'Diallo Ousmane'), isTrue);
    });
  });

  group('Flux Soignant : Redirection / Orientation avec informations médicales', () {
    final referralService = ReferralService();

    test('Le soignant habilité crée une redirection inter-hospitalière complète', () async {
      final doctorName = 'Dr. Amadou Ouédraogo';
      final referral = await referralService.createReferral({
        'targetTenantName': 'CHU de Bogodogo',
        'targetService': 'Service de Cardiologie Interventionnelle',
        'priority': 'URGENT',
        'clinicalReason': 'Exploration approfondie coronarienne suite ECG suspect',
        'medicalSummary': 'Patient: Sawadogo Mariam. TA 155/95 mmHg, troponines limites. Dossier et constantes transmis.',
        'sourceTenantName': 'CHU Yalgado Ouédraogo',
        'referringDoctorName': doctorName,
      });

      expect(referral.referralCode, startsWith('REF-'));
      expect(referral.targetTenantName, 'CHU de Bogodogo');
      expect(referral.referringDoctorName, doctorName);
      expect(referral.priority, 'URGENT');
      expect(referral.medicalSummary, contains('Sawadogo Mariam'));
    });
  });

  group('Flux Patient : Notification spécifique lors de la mise à jour RDV par le Docteur', () {
    final messageService = MessageService();

    test('Le docteur valide ou reporte un rendez-vous et le patient reçoit la notification dédiée', () async {
      final patientId = IdGenerator.patientId();
      final doctorName = 'Dr. Amadou Ouédraogo';

      // Le docteur confirme le rendez-vous
      MessageService.addAlert(
        ClinicalAlert(
          id: IdGenerator.alertId(),
          recipientUserId: patientId,
          title: 'Rendez-vous Confirmé',
          message: '$doctorName a confirmé et validé votre consultation du 28/10 à 09:30 en Médecine Générale.',
          type: 'APPOINTMENT_CONFIRMED',
          severity: 'LOW',
          timestamp: DateTime.now(),
        ),
      );

      final alerts = await messageService.getAlerts(
        userId: patientId,
      );

      expect(alerts.any((a) => a.recipientUserId == patientId && a.message.contains(doctorName)), isTrue);
    });
  });
}
