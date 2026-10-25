import 'package:flutter_test/flutter_test.dart';
import 'package:medscan/core/theme/app_colors.dart';
import 'package:medscan/core/utils/id_generator.dart';
import 'package:medscan/models/certificate.dart';
import 'package:medscan/models/grievance.dart';
import 'package:medscan/models/message.dart';
import 'package:medscan/models/patient.dart';
import 'package:medscan/models/referral.dart';
import 'package:medscan/models/user.dart';
import 'package:medscan/services/message_service.dart';

void main() {
  group('Theme & Design System', () {
    test('AppColors matches template blue and slate palette', () {
      expect(AppColors.primary.toARGB32(), 0xFF1B5FE0);
      expect(AppColors.background.toARGB32(), 0xFFF7F9FC);
      expect(AppColors.surface.toARGB32(), 0xFFFFFFFF);
      expect(AppColors.starGold.toARGB32(), 0xFFF59E0B);
    });
  });

  group('IdGenerator (Zéro ID codé en dur)', () {
    test('Generates dynamic, unique IDs with proper prefixes', () {
      final patId1 = IdGenerator.patientId();
      final patId2 = IdGenerator.patientId();
      expect(patId1, startsWith('pat_'));
      expect(patId2, startsWith('pat_'));
      expect(patId1, isNot(equals(patId2)));

      final docId = IdGenerator.doctorId();
      expect(docId, startsWith('doc_'));

      final certCode = IdGenerator.certificateCode();
      expect(certCode, startsWith('CERT-'));

      final convId = IdGenerator.conversationId(patId1, docId);
      expect(convId, startsWith('conv_'));
    });
  });

  group('User & Modular Medical Position', () {
    test('Identifies doctor via position or roles without hardcoded strings', () {
      final practitioner = User(
        id: IdGenerator.doctorId(),
        username: 'dr_ouedraogo',
        email: 'amadou@chu.bf',
        displayName: 'Amadou Ouédraogo',
        tenantId: IdGenerator.tenantId(),
        tenantCode: 'CHU-YO',
        roles: const ['USER'],
        permissions: const [],
        position: 'Praticien Hospitalier',
      );
      expect(practitioner.isDoctor, isTrue);
      expect(practitioner.isPatient, isFalse);
      expect(practitioner.displayTitle, 'Praticien Hospitalier Amadou Ouédraogo');

      final patient = User(
        id: IdGenerator.patientId(),
        username: 'souleymane',
        email: 'kabore@gmail.com',
        displayName: 'Kaboré Souleymane',
        tenantId: IdGenerator.tenantId(),
        tenantCode: 'CHU-YO',
        roles: const ['ROLE_PATIENT'],
        permissions: const [],
      );
      expect(patient.isDoctor, isFalse);
      expect(patient.isPatient, isTrue);
      expect(patient.displayTitle, 'Kaboré Souleymane');
    });

    test('MedicalPosition enum helper returns correct labels and codes', () {
      final pos = MedicalPosition.fromString('PRATICIEN');
      expect(pos, equals(MedicalPosition.practitioner));
      expect(pos?.label, 'Praticien Hospitalier');

      final med = MedicalPosition.fromString('MEDECIN');
      expect(med, equals(MedicalPosition.physician));
    });
  });

  group('Patient & BMI Live Calculation', () {
    test('calculateBmi returns correct value and category', () {
      final bmi = Patient.calculateBmi(70.0, 175.0);
      expect(bmi, closeTo(22.9, 0.1));
      expect(Patient.classifyBmi(bmi), 'Poids normal / Idéal');

      final obeseBmi = Patient.calculateBmi(100.0, 170.0);
      expect(obeseBmi, closeTo(34.6, 0.1));
      expect(Patient.classifyBmi(obeseBmi), 'Obésité clinique');
    });
  });

  group('MedicalCertificate', () {
    test('MedicalCertificate deserialization and type labels', () {
      final cert = MedicalCertificate.fromJson({
        'id': IdGenerator.certificateId(),
        'certificateNumber': IdGenerator.certificateCode(),
        'type': 'SICK_LEAVE',
        'patientName': 'Kaboré Souleymane',
        'doctorName': 'Dr. Amadou Ouédraogo',
        'restDurationDays': 5,
        'digitalSealHash': 'SHA256:abcd1234',
      });

      expect(cert.certificateNumber, startsWith('CERT-'));
      expect(cert.restDurationDays, 5);
      expect(cert.typeLabel, 'Arrêt de Travail Médical (Employeur)');
      expect(cert.digitalSealHash, 'SHA256:abcd1234');
    });
  });

  group('MedicalReferral', () {
    test('MedicalReferral deserialization and priority tracking', () {
      final ref = MedicalReferral.fromJson({
        'id': IdGenerator.referralId(),
        'referralCode': 'REF-2026-0891',
        'patientName': 'Kaboré Souleymane',
        'referringDoctorName': 'Dr. Amadou Ouédraogo',
        'sourceTenantName': 'CHU Yalgado Ouédraogo',
        'targetTenantName': 'CHU de Tengandogo',
        'targetService': 'Service de Cardiologie Interventionnelle',
        'clinicalReason': 'Coronarographie urgente',
        'priority': 'URGENT',
        'status': 'PENDING',
      });

      expect(ref.referralCode, 'REF-2026-0891');
      expect(ref.priority, 'URGENT');
      expect(ref.status, 'PENDING');
      expect(ref.targetService, 'Service de Cardiologie Interventionnelle');
    });
  });

  group('PatientGrievance', () {
    test('PatientGrievance deserialization and status tracking', () {
      final grv = PatientGrievance.fromJson({
        'id': IdGenerator.grievanceId(),
        'grievanceCode': 'REC-2026-001',
        'patientName': 'Kaboré Souleymane',
        'doctorName': 'Dr. Amadou Ouédraogo',
        'grievanceType': 'COMPLAINT',
        'category': 'DELAY_WAIT_TIME',
        'rating': 2,
        'severity': 'MEDIUM',
        'title': 'Attente excessive',
        'description': 'Plus de 2 heures sans prise en charge',
        'status': 'UNDER_REVIEW',
      });

      expect(grv.grievanceCode, 'REC-2026-001');
      expect(grv.rating, 2);
      expect(grv.categoryLabel, 'Délai d\'attente excessif');
      expect(grv.statusLabel, 'En cours d\'examen');
    });
  });

  group('ClinicalMessage & Alert', () {
    test('ClinicalMessage urgent flag detection', () {
      final msg = ClinicalMessage.fromJson({
        'id': IdGenerator.messageId(),
        'conversationId': 'conv-1',
        'senderName': 'Dr. Amadou Ouédraogo',
        'content': 'Prenez contact avec les urgences',
        'priority': 'URGENT',
      });

      expect(msg.isUrgent, isTrue);

      final routineMsg = ClinicalMessage.fromJson({
        'id': IdGenerator.messageId(),
        'conversationId': 'conv-1',
        'senderName': 'Dr. Amadou Ouédraogo',
        'content': 'Ordonnance renouvelée',
        'priority': 'ROUTINE',
      });

      expect(routineMsg.isUrgent, isFalse);
    });

    test('MessageService dynamically isolates messages per user session', () async {
      final msgService = MessageService();

      // Utilisateur A envoie un message
      final userAId = IdGenerator.patientId();
      final doctorId = IdGenerator.doctorId();
      await msgService.sendMessage({
        'senderId': userAId,
        'recipientId': doctorId,
        'patientId': userAId,
        'content': 'Message privé de User A',
      });

      final userAMsgs = await msgService.getMessages(userId: userAId);
      expect(userAMsgs.isNotEmpty, isTrue);
      expect(userAMsgs.every((m) => m.senderId == userAId || m.recipientId == userAId || m.patientId == userAId), isTrue);

      // Utilisateur B isolé ne reçoit pas les messages de User A
      final userBId = IdGenerator.patientId();
      final userBMsgs = await msgService.getMessages(userId: userBId);
      expect(userBMsgs.isEmpty, isTrue);
    });

    test('MessageService isolates clinical alerts per user without data leak', () async {
      final msgService = MessageService();
      final targetPatientId = IdGenerator.patientId();

      MessageService.addAlert(
        ClinicalAlert(
          id: IdGenerator.alertId(),
          recipientUserId: targetPatientId,
          title: 'Résultats Confidentiels',
          message: 'Bilan réservé au patient',
          type: 'LAB_CRITICAL',
          severity: 'INFO',
          timestamp: DateTime.now(),
        ),
      );

      final patientAlerts = await msgService.getAlerts(userId: targetPatientId);
      expect(patientAlerts.any((a) => a.recipientUserId == targetPatientId), isTrue);

      final anotherUserAlerts = await msgService.getAlerts(userId: IdGenerator.patientId());
      expect(anotherUserAlerts.any((a) => a.recipientUserId == targetPatientId), isFalse);
    });
  });
}
