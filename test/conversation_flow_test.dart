import 'package:flutter_test/flutter_test.dart';
import 'package:medscan/core/utils/id_generator.dart';
import 'package:medscan/services/message_service.dart';

void main() {
  group('Système de messagerie complet (Conversations & Contacts éligibles)', () {
    late MessageService messageService;

    setUp(() {
      MessageService.resetForTesting();
      messageService = MessageService();
    });

    test('Affichage initial de la liste des conversations pour les utilisateurs seed', () async {
      final docId = MessageService.seedDoctorId;
      final patId = MessageService.seedPatientId;

      // 1. Le docteur voit sa conversation avec la patiente
      final doctorConvs = await messageService.getConversations(
        userId: docId,
        isDoctor: true,
      );
      expect(doctorConvs.isNotEmpty, isTrue);
      final docConv = doctorConvs.first;
      expect(docConv.participantRole, 'PATIENT');
      expect(docConv.participantName, 'Fatou Ouédraogo');
      expect(docConv.lastMessage, isNotNull);

      // 2. La patiente voit sa conversation avec le docteur
      final patientConvs = await messageService.getConversations(
        userId: patId,
        isDoctor: false,
      );
      expect(patientConvs.isNotEmpty, isTrue);
      final patConv = patientConvs.first;
      expect(patConv.participantRole, 'DOCTOR');
      expect(patConv.participantName, 'Dr. Amadou Ouédraogo');
    });

    test('Isolation des contacts éligibles : Patient ne voit que des praticiens consultés', () async {
      final patientId = MessageService.seedPatientId;

      final contacts = await messageService.getEligibleContacts(
        userId: patientId,
        isDoctor: false,
      );

      expect(contacts.isNotEmpty, isTrue);
      for (final contact in contacts) {
        expect(contact.role, 'DOCTOR');
        expect(contact.name, startsWith('Dr.'));
      }
    });

    test('Isolation des contacts éligibles : Docteur ne voit que des patients suivis', () async {
      final doctorId = MessageService.seedDoctorId;

      final contacts = await messageService.getEligibleContacts(
        userId: doctorId,
        isDoctor: true,
      );

      expect(contacts.isNotEmpty, isTrue);
      for (final contact in contacts) {
        expect(contact.role, 'PATIENT');
        expect(contact.name.isNotEmpty, isTrue);
      }
    });

    test('Création d\'une nouvelle conversation et mise à jour dynamique du fil', () async {
      final newDoctorId = IdGenerator.doctorId();
      final newPatientId = IdGenerator.patientId();
      final convId = IdGenerator.conversationId(newPatientId, newDoctorId);

      // Avant envoi : aucune conversation pour ce nouveau médecin
      final convsBefore = await messageService.getConversations(
        userId: newDoctorId,
        isDoctor: true,
      );
      expect(convsBefore.isEmpty, isTrue);

      // Envoi d'un premier message pour initier la conversation
      final msg = await messageService.sendMessage({
        'conversationId': convId,
        'senderId': newPatientId,
        'senderName': 'Nouveau Patient',
        'senderRole': 'PATIENT',
        'recipientId': newDoctorId,
        'recipientName': 'Dr. Nouveau',
        'recipientRole': 'DOCTOR',
        'patientId': newPatientId,
        'content': 'Bonjour Docteur, j\'ai une question suite à mon ordonnance.',
        'priority': 'URGENT',
      });

      expect(msg.content, contains('ordonnance'));

      // Après envoi : la conversation apparaît immédiatement pour le médecin
      final convsAfter = await messageService.getConversations(
        userId: newDoctorId,
        isDoctor: true,
      );
      expect(convsAfter.length, 1);
      expect(convsAfter.first.id, convId);
      expect(convsAfter.first.participantName, 'Nouveau Patient');
      expect(convsAfter.first.participantRole, 'PATIENT');
      expect(convsAfter.first.lastMessage?.content, contains('ordonnance'));
      expect(convsAfter.first.lastMessage?.isUrgent, isTrue);

      // Récupération des messages de cette conversation spécifique
      final thread = await messageService.getMessages(conversationId: convId);
      expect(thread.length, 1);
      expect(thread.first.id, msg.id);

      // Vérification stricte d'isolation : un tiers ne voit pas cette conversation
      final thirdPartyId = IdGenerator.patientId();
      final thirdPartyConvs = await messageService.getConversations(
        userId: thirdPartyId,
        isDoctor: false,
      );
      expect(thirdPartyConvs.any((c) => c.id == convId), isFalse);
    });
  });
}
