import 'package:flutter_test/flutter_test.dart';
import 'package:doctor_guide_bd/models/models.dart';

void main() {
  group('BodyPart', () {
    test('fromJson parses correctly', () {
      final json = {
        'id': 'head',
        'nameEn': 'Head',
        'nameBn': 'মাথা',
        'icon': 'face',
      };
      final part = BodyPart.fromJson(json);
      expect(part.id, 'head');
      expect(part.nameEn, 'Head');
      expect(part.nameBn, 'মাথা');
      expect(part.icon, 'face');
    });
  });

  group('SymptomOption', () {
    test('fromJson parses with specialistMap', () {
      final json = {
        'id': 'headache',
        'bodyPartId': 'head',
        'nameEn': 'Headache',
        'nameBn': 'মাথাব্যথা',
        'isEmergency': false,
        'specialistMap': [
          {'specialistId': 'neuro', 'stars': 4},
        ],
      };
      final symptom = SymptomOption.fromJson(json);
      expect(symptom.id, 'headache');
      expect(symptom.isEmergency, false);
      expect(symptom.specialistMap.length, 1);
      expect(symptom.specialistMap[0].specialistId, 'neuro');
    });

    test('fromJson defaults isEmergency to false', () {
      final json = {
        'id': 'mild-pain',
        'bodyPartId': 'chest',
        'nameEn': 'Mild chest pain',
        'nameBn': 'বুকের হালকা ব্যথা',
        'specialistMap': [],
      };
      final symptom = SymptomOption.fromJson(json);
      expect(symptom.isEmergency, false);
    });
  });

  group('Specialist', () {
    test('fromJson parses correctly', () {
      final json = {
        'id': 'cardio',
        'nameEn': 'Cardiology',
        'nameBn': 'কার্ডিওলজি',
        'descriptionBn': 'হৃদরোগ বিশেষজ্ঞ',
        'whenToVisitBn': 'বুকে ব্যথা হলে',
      };
      final specialist = Specialist.fromJson(json);
      expect(specialist.id, 'cardio');
      expect(specialist.nameEn, 'Cardiology');
    });
  });

  group('MedicalDegree', () {
    test('fromJson parses correctly', () {
      final json = {
        'id': 'mbbs',
        'title': 'MBBS',
        'fullFormEn': 'Bachelor of Medicine and Bachelor of Surgery',
        'explanationBn': 'স্নাতক পর্যায়ের চিকিৎসা ডিগ্রি',
      };
      final degree = MedicalDegree.fromJson(json);
      expect(degree.id, 'mbbs');
      expect(degree.title, 'MBBS');
    });
  });

  group('VisitNoteAnswer', () {
    test('stores question and answer correctly', () {
      final answer = VisitNoteAnswer(
        questionEn: 'Pain location',
        questionBn: 'ব্যথার স্থান',
        answer: 'Chest',
      );
      expect(answer.questionEn, 'Pain location');
      expect(answer.answer, 'Chest');
    });
  });
}
