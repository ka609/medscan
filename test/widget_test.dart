import 'package:flutter_test/flutter_test.dart';
import 'package:medscan/core/theme/app_colors.dart';
import 'package:medscan/models/certificate.dart';
import 'package:medscan/models/grievance.dart';
import 'package:medscan/models/message.dart';
import 'package:medscan/models/patient.dart';
import 'package:medscan/models/referral.dart';
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
        'id': 'cert-1',
        'certificateNumber': 'CERT-2026-001',
        'type': 'SICK_LEAVE',
        'patientName': 'Kaboré Souleymane',
        'doctorName': 'Dr. Amadou Ouédraogo',
        'restDurationDays': 5,
        'digitalSealHash': 'SHA256:abcd1234',
      });

      expect(cert.certificateNumber, 'CERT-2026-001');
      expect(cert.restDurationDays, 5);
      expect(cert.typeLabel, 'Arrêt de Travail Médical (Employeur)');
      expect(cert.digitalSealHash, 'SHA256:abcd1234');
    });
  });

  group('MedicalReferral', () {
    test('MedicalReferral deserialization and priority tracking', () {
      final ref = MedicalReferral.fromJson({
        'id': 'ref-1',
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
        'id': 'grv-1',
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
        'id': 'msg-1',
        'conversationId': 'conv-1',
        'senderName': 'Dr. Amadou Ouédraogo',
        'content': 'Prenez contact avec les urgences',
        'priority': 'URGENT',
      });

      expect(msg.isUrgent, isTrue);

      final routineMsg = ClinicalMessage.fromJson({
        'id': 'msg-2',
        'conversationId': 'conv-1',
        'senderName': 'Dr. Amadou Ouédraogo',
        'content': 'Ordonnance renouvelée',
        'priority': 'ROUTINE',
      });

      expect(routineMsg.isUrgent, isFalse);
    });

    test('MessageService isolates messages per user', () async {
      final msgService = MessageService();

      // M. Kaboré Souleymane (pat-001)
      final user1Msgs = await msgService.getMessages(userId: 'pat-001');
      expect(user1Msgs.isNotEmpty, isTrue);
      expect(user1Msgs.every((m) => m.patientId == 'pat-001' || m.senderId == 'pat-001' || m.recipientId == 'pat-001'), isTrue);

      // Nouvel utilisateur sans messages
      final user2Msgs = await msgService.getMessages(userId: 'pat-unknown-999');
      expect(user2Msgs.isEmpty, isTrue);
    });

    test('MessageService isolates clinical alerts per user', () async {
      final msgService = MessageService();

      final user1Alerts = await msgService.getAlerts(userId: 'pat-001');
      expect(user1Alerts.isNotEmpty, isTrue);

      final otherUserAlerts = await msgService.getAlerts(userId: 'pat-isolated-user');
      // L'utilisateur isolé ne reçoit pas les alertes privées de pat-001
      expect(otherUserAlerts.any((a) => a.recipientUserId == 'pat-001'), isFalse);
    });
  });
}
