// Integration test for messaging flow isolation
// This test validates that a patient only sees their own messages and that
// a doctor sees messages addressed to them, using the in‑memory MessageService.

import 'package:flutter_test/flutter_test.dart';
import 'package:medscan/services/message_service.dart';
import 'package:medscan/core/utils/id_generator.dart';



void main() {
  group('Messaging isolation', () {
    final messageService = MessageService();
    final doctorId = IdGenerator.doctorId();
    final patientId = IdGenerator.patientId();
    final conversationId = IdGenerator.conversationId(patientId, doctorId);

    test('Patient sees only its own messages', () async {
      // Retrieve messages for patient
      final msgs = await messageService.getMessages(
        userId: patientId,
        isDoctor: false,
      );

      // All returned messages must belong to the patient
      for (final m in msgs) {
        expect(m.patientId, patientId);
        expect(m.recipientId, anyOf([doctorId, patientId]));
        // Patient should not see messages of another patient (none seeded)
      }
    });

    test('Doctor sees messages of its patients', () async {
      final msgs = await messageService.getMessages(
        userId: doctorId,
        isDoctor: true,
      );

      for (final m in msgs) {
        // Doctor can see any message where they are sender or recipient
        expect(m.senderId == doctorId || m.recipientId == doctorId, true);
        // Ensure patientId is correctly linked
        expect(m.patientId, anyOf([null, patientId]));
      }
    });

    test('Send a new message from patient to doctor', () async {
      final newMsg = await messageService.sendMessage({
        'content': 'Test message from patient',
        'senderId': patientId,
        'senderName': 'Patient Test',
        'senderRole': 'PATIENT',
        'recipientId': doctorId,
        'recipientName': 'Dr. Test',
        'recipientRole': 'DOCTOR',
        'patientId': patientId,
        'conversationId': conversationId,
      });

      expect(newMsg.senderId, patientId);
      expect(newMsg.recipientId, doctorId);
      expect(newMsg.content, 'Test message from patient');
    });
  });
}

