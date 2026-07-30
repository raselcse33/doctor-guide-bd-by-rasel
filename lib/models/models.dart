// Core data models for Doctor Guide BD.
// Kept plain (no code-gen) so the app stays lightweight and fully offline.

class BodyPart {
  final String id;
  final String nameEn;
  final String nameBn;
  final String icon;

  BodyPart({
    required this.id,
    required this.nameEn,
    required this.nameBn,
    required this.icon,
  });

  factory BodyPart.fromJson(Map<String, dynamic> json) => BodyPart(
        id: json['id'],
        nameEn: json['nameEn'],
        nameBn: json['nameBn'],
        icon: json['icon'],
      );
}

class DurationOption {
  final String id;
  final String labelEn;
  final String labelBn;

  DurationOption({
    required this.id,
    required this.labelEn,
    required this.labelBn,
  });

  factory DurationOption.fromJson(Map<String, dynamic> json) => DurationOption(
        id: json['id'],
        labelEn: json['labelEn'],
        labelBn: json['labelBn'],
      );
}

class SpecialistMapping {
  final String specialistId;
  final int stars;

  SpecialistMapping({required this.specialistId, required this.stars});

  factory SpecialistMapping.fromJson(Map<String, dynamic> json) =>
      SpecialistMapping(
        specialistId: json['specialistId'],
        stars: json['stars'],
      );
}

class SymptomOption {
  final String id;
  final String bodyPartId;
  final String nameEn;
  final String nameBn;
  final bool isEmergency;
  final String? emergencyNoteEn;
  final String? emergencyNoteBn;
  final List<SpecialistMapping> specialistMap;

  SymptomOption({
    required this.id,
    required this.bodyPartId,
    required this.nameEn,
    required this.nameBn,
    required this.isEmergency,
    this.emergencyNoteEn,
    this.emergencyNoteBn,
    required this.specialistMap,
  });

  factory SymptomOption.fromJson(Map<String, dynamic> json) => SymptomOption(
        id: json['id'],
        bodyPartId: json['bodyPartId'],
        nameEn: json['nameEn'],
        nameBn: json['nameBn'],
        isEmergency: json['isEmergency'] ?? false,
        emergencyNoteEn: json['emergencyNoteEn'],
        emergencyNoteBn: json['emergencyNoteBn'],
        specialistMap: (json['specialistMap'] as List<dynamic>? ?? [])
            .map((e) => SpecialistMapping.fromJson(e))
            .toList(),
      );
}

class Specialist {
  final String id;
  final String nameEn;
  final String nameBn;
  final String descriptionBn;
  final String whenToVisitBn;

  Specialist({
    required this.id,
    required this.nameEn,
    required this.nameBn,
    required this.descriptionBn,
    required this.whenToVisitBn,
  });

  factory Specialist.fromJson(Map<String, dynamic> json) => Specialist(
        id: json['id'],
        nameEn: json['nameEn'],
        nameBn: json['nameBn'],
        descriptionBn: json['descriptionBn'],
        whenToVisitBn: json['whenToVisitBn'],
      );
}

class MedicalDegree {
  final String id;
  final String title;
  final String fullFormEn;
  final String explanationBn;

  MedicalDegree({
    required this.id,
    required this.title,
    required this.fullFormEn,
    required this.explanationBn,
  });

  factory MedicalDegree.fromJson(Map<String, dynamic> json) => MedicalDegree(
        id: json['id'],
        title: json['title'],
        fullFormEn: json['fullFormEn'],
        explanationBn: json['explanationBn'],
      );
}

/// A single answer captured while building a Doctor Visit Note.
class VisitNoteAnswer {
  final String questionEn;
  final String questionBn;
  final String answer;

  VisitNoteAnswer({
    required this.questionEn,
    required this.questionBn,
    required this.answer,
  });
}
