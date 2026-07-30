import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/models.dart';

/// Loads all local JSON data once and keeps it in memory.
/// Everything in this app works fully offline — no network calls, ever.
class DataRepository {
  DataRepository._internal();
  static final DataRepository instance = DataRepository._internal();

  List<BodyPart> bodyParts = [];
  List<DurationOption> durationOptions = [];
  List<SymptomOption> symptoms = [];
  List<Specialist> specialists = [];
  List<MedicalDegree> medicalDegrees = [];

  bool _loaded = false;
  bool get isLoaded => _loaded;

  Future<void> loadAll() async {
    if (_loaded) return;

    final symptomsRaw = await rootBundle.loadString('assets/data/symptoms.json');
    final specialistsRaw = await rootBundle.loadString('assets/data/specialists.json');
    final degreesRaw = await rootBundle.loadString('assets/data/medical_degrees.json');

    final symptomsJson = json.decode(symptomsRaw) as Map<String, dynamic>;
    final specialistsJson = json.decode(specialistsRaw) as Map<String, dynamic>;
    final degreesJson = json.decode(degreesRaw) as Map<String, dynamic>;

    bodyParts = (symptomsJson['bodyParts'] as List)
        .map((e) => BodyPart.fromJson(e))
        .toList();

    durationOptions = (symptomsJson['durationOptions'] as List)
        .map((e) => DurationOption.fromJson(e))
        .toList();

    symptoms = (symptomsJson['symptoms'] as List)
        .map((e) => SymptomOption.fromJson(e))
        .toList();

    specialists = (specialistsJson['specialists'] as List)
        .map((e) => Specialist.fromJson(e))
        .toList();

    medicalDegrees = (degreesJson['degrees'] as List)
        .map((e) => MedicalDegree.fromJson(e))
        .toList();

    _loaded = true;
  }

  List<SymptomOption> symptomsForBodyPart(String bodyPartId) =>
      symptoms.where((s) => s.bodyPartId == bodyPartId).toList();

  Specialist? specialistById(String id) =>
      specialists.where((s) => s.id == id).cast<Specialist?>().firstWhere(
            (s) => s != null,
            orElse: () => null,
          );
}
