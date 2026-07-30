import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../data/data_repository.dart';
import '../models/models.dart';
import '../theme.dart';
import '../widgets/star_rating_widget.dart';

/// Step 1: body part -> matching symptom -> Step 2: duration ->
/// Step 3: age & gender -> Result (or immediate Emergency redirect).
class QuestionnaireScreen extends StatefulWidget {
  const QuestionnaireScreen({super.key});

  @override
  State<QuestionnaireScreen> createState() => _QuestionnaireScreenState();
}

enum _Step { bodyPart, symptom, duration, ageGender, result }

class _QuestionnaireScreenState extends State<QuestionnaireScreen> {
  final repo = DataRepository.instance;

  _Step _step = _Step.bodyPart;
  BodyPart? _selectedBodyPart;
  SymptomOption? _selectedSymptom;
  DurationOption? _selectedDuration;
  String? _selectedGender;
  int? _selectedAge;

  final _ageController = TextEditingController();

  @override
  void dispose() {
    _ageController.dispose();
    super.dispose();
  }

  void _goToStep(_Step step) => setState(() => _step = step);

  void _selectBodyPart(BodyPart part) {
    setState(() {
      _selectedBodyPart = part;
      _step = _Step.symptom;
    });
  }

  void _selectSymptom(SymptomOption symptom) {
    if (symptom.isEmergency) {
      // Immediately break out to the Red Flag Alert Screen.
      context.pushNamed('emergency', extra: symptom);
      return;
    }
    setState(() {
      _selectedSymptom = symptom;
      _step = _Step.duration;
    });
  }

  void _selectDuration(DurationOption duration) {
    setState(() {
      _selectedDuration = duration;
      _step = _Step.ageGender;
    });
  }

  void _submitAgeGender() {
    final age = int.tryParse(_ageController.text.trim());
    setState(() {
      _selectedAge = age;
      _step = _Step.result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('উপসর্গ পরীক্ষা'),
        leading: _step == _Step.bodyPart
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _handleBack,
              ),
      ),
      body: SafeArea(child: _buildStepBody()),
    );
  }

  void _handleBack() {
    switch (_step) {
      case _Step.symptom:
        _goToStep(_Step.bodyPart);
        break;
      case _Step.duration:
        _goToStep(_Step.symptom);
        break;
      case _Step.ageGender:
        _goToStep(_Step.duration);
        break;
      case _Step.result:
        _goToStep(_Step.ageGender);
        break;
      case _Step.bodyPart:
        break;
    }
  }

  Widget _buildStepBody() {
    switch (_step) {
      case _Step.bodyPart:
        return _BodyPartStep(
          bodyParts: repo.bodyParts,
          onSelect: _selectBodyPart,
        );
      case _Step.symptom:
        return _SymptomStep(
          bodyPart: _selectedBodyPart!,
          symptoms: repo.symptomsForBodyPart(_selectedBodyPart!.id),
          onSelect: _selectSymptom,
        );
      case _Step.duration:
        return _DurationStep(
          options: repo.durationOptions,
          onSelect: _selectDuration,
        );
      case _Step.ageGender:
        return _AgeGenderStep(
          ageController: _ageController,
          selectedGender: _selectedGender,
          onGenderSelected: (g) => setState(() => _selectedGender = g),
          onSubmit: _submitAgeGender,
        );
      case _Step.result:
        return _ResultStep(
          symptom: _selectedSymptom!,
          duration: _selectedDuration!,
          age: _selectedAge,
          gender: _selectedGender,
        );
    }
  }
}

// ---------- Step 1: Body part ----------

class _BodyPartStep extends StatelessWidget {
  final List<BodyPart> bodyParts;
  final ValueChanged<BodyPart> onSelect;

  const _BodyPartStep({required this.bodyParts, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _StepHeader(
            stepLabel: 'ধাপ ১',
            titleBn: 'শরীরের কোন অংশে সমস্যা?',
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              itemCount: bodyParts.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.5,
              ),
              itemBuilder: (context, index) {
                final part = bodyParts[index];
                return _SelectableTile(
                  labelBn: part.nameBn,
                  labelEn: part.nameEn,
                  onTap: () => onSelect(part),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ---------- Step 1b: Symptom within body part ----------

class _SymptomStep extends StatelessWidget {
  final BodyPart bodyPart;
  final List<SymptomOption> symptoms;
  final ValueChanged<SymptomOption> onSelect;

  const _SymptomStep({
    required this.bodyPart,
    required this.symptoms,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StepHeader(
            stepLabel: 'ধাপ ১',
            titleBn: '${bodyPart.nameBn} - কোন লক্ষণটি আপনার আছে?',
          ),
          const SizedBox(height: 16),
          Expanded(
            child: symptoms.isEmpty
                ? const Center(child: Text('কোনো লক্ষণ পাওয়া যায়নি'))
                : ListView.separated(
                    itemCount: symptoms.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final symptom = symptoms[index];
                      return _SelectableListRow(
                        labelBn: symptom.nameBn,
                        labelEn: symptom.nameEn,
                        isEmergency: symptom.isEmergency,
                        onTap: () => onSelect(symptom),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ---------- Step 2: Duration ----------

class _DurationStep extends StatelessWidget {
  final List<DurationOption> options;
  final ValueChanged<DurationOption> onSelect;

  const _DurationStep({required this.options, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _StepHeader(
            stepLabel: 'ধাপ ২',
            titleBn: 'কতদিন ধরে এই সমস্যা?',
          ),
          const SizedBox(height: 16),
          ...options.map((o) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _SelectableListRow(
                  labelBn: o.labelBn,
                  labelEn: o.labelEn,
                  isEmergency: false,
                  onTap: () => onSelect(o),
                ),
              )),
        ],
      ),
    );
  }
}

// ---------- Step 3: Age & Gender ----------

class _AgeGenderStep extends StatefulWidget {
  final TextEditingController ageController;
  final String? selectedGender;
  final ValueChanged<String> onGenderSelected;
  final VoidCallback onSubmit;

  const _AgeGenderStep({
    required this.ageController,
    required this.selectedGender,
    required this.onGenderSelected,
    required this.onSubmit,
  });

  @override
  State<_AgeGenderStep> createState() => _AgeGenderStepState();
}

class _AgeGenderStepState extends State<_AgeGenderStep> {
  @override
  void initState() {
    super.initState();
    widget.ageController.addListener(_onAgeChanged);
  }

  void _onAgeChanged() => setState(() {});

  @override
  void dispose() {
    widget.ageController.removeListener(_onAgeChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ageController = widget.ageController;
    final selectedGender = widget.selectedGender;
    final onGenderSelected = widget.onGenderSelected;
    final onSubmit = widget.onSubmit;
    final canSubmit =
        ageController.text.trim().isNotEmpty && selectedGender != null;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _StepHeader(stepLabel: 'ধাপ ৩', titleBn: 'বয়স ও লিঙ্গ'),
          const SizedBox(height: 20),
          const Text('বয়স', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextField(
            controller: ageController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'যেমন: ৩২',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text('লিঙ্গ', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Row(
            children: [
              _GenderChip(
                label: 'পুরুষ',
                selected: selectedGender == 'male',
                onTap: () => onGenderSelected('male'),
              ),
              const SizedBox(width: 10),
              _GenderChip(
                label: 'মহিলা',
                selected: selectedGender == 'female',
                onTap: () => onGenderSelected('female'),
              ),
              const SizedBox(width: 10),
              _GenderChip(
                label: 'অন্যান্য',
                selected: selectedGender == 'other',
                onTap: () => onGenderSelected('other'),
              ),
            ],
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: canSubmit ? onSubmit : null,
              child: const Text('ফলাফল দেখুন'),
            ),
          ),
        ],
      ),
    );
  }
}

class _GenderChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _GenderChip(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: AppColors.primary,
      labelStyle: TextStyle(
        color: selected ? Colors.white : AppColors.textPrimary,
        fontWeight: FontWeight.w600,
      ),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }
}

// ---------- Result ----------

class _ResultStep extends StatelessWidget {
  final SymptomOption symptom;
  final DurationOption duration;
  final int? age;
  final String? gender;

  const _ResultStep({
    required this.symptom,
    required this.duration,
    required this.age,
    required this.gender,
  });

  @override
  Widget build(BuildContext context) {
    final repo = DataRepository.instance;
    final sortedMap = [...symptom.specialistMap]
      ..sort((a, b) => b.stars.compareTo(a.stars));

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const _StepHeader(stepLabel: 'ফলাফল', titleBn: 'প্রস্তাবিত বিশেষজ্ঞ'),
        const SizedBox(height: 8),
        Text(
          '${symptom.nameBn} • ${duration.labelBn}',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 16),
        ...sortedMap.map((mapping) {
          final specialist = repo.specialistById(mapping.specialistId);
          if (specialist == null) return const SizedBox.shrink();
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(specialist.nameBn,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w700)),
                        Text(specialist.nameEn,
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.textSecondary)),
                        const SizedBox(height: 6),
                        Text(specialist.whenToVisitBn,
                            style: const TextStyle(fontSize: 13)),
                      ],
                    ),
                  ),
                  StarRatingWidget(stars: mapping.stars),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            'এটি শুধুমাত্র একটি প্রাথমিক দিকনির্দেশনা, সঠিক রোগনির্ণয়ের জন্য ডাক্তারের পরামর্শ নিন।',
            style: TextStyle(fontSize: 13),
          ),
        ),
        const SizedBox(height: 20),
        OutlinedButton(
          onPressed: () => context.goNamed('home'),
          child: const Text('হোমে ফিরে যান'),
        ),
      ],
    );
  }
}

// ---------- Shared small widgets ----------

class _StepHeader extends StatelessWidget {
  final String stepLabel;
  final String titleBn;

  const _StepHeader({required this.stepLabel, required this.titleBn});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(stepLabel,
            style: const TextStyle(
                color: AppColors.primary, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text(titleBn,
            style: const TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _SelectableTile extends StatelessWidget {
  final String labelBn;
  final String labelEn;
  final VoidCallback onTap;

  const _SelectableTile(
      {required this.labelBn, required this.labelEn, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(labelBn,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700)),
              Text(labelEn,
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textSecondary)),
            ],
          ),
        ),
      ),
    );
  }
}

class _SelectableListRow extends StatelessWidget {
  final String labelBn;
  final String labelEn;
  final bool isEmergency;
  final VoidCallback onTap;

  const _SelectableListRow({
    required this.labelBn,
    required this.labelEn,
    required this.isEmergency,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isEmergency ? AppColors.emergencyLight : AppColors.card,
      child: ListTile(
        onTap: onTap,
        title: Text(labelBn, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(labelEn),
        leading: isEmergency
            ? const Icon(Icons.warning_rounded, color: AppColors.emergency)
            : null,
        trailing: const Icon(Icons.chevron_right_rounded),
      ),
    );
  }
}
