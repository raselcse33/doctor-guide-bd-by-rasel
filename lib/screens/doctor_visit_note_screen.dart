import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../data/data_repository.dart';
import '../models/models.dart';
import '../theme.dart';
import '../widgets/summary_card_widget.dart';

/// Step 1: pick main symptom -> Step 2: 5 quick questions ->
/// Step 3: summary card with Save-as-PDF / Save-as-Image.
class DoctorVisitNoteScreen extends StatefulWidget {
  const DoctorVisitNoteScreen({super.key});

  @override
  State<DoctorVisitNoteScreen> createState() => _DoctorVisitNoteScreenState();
}

enum _NoteStep { pickSymptom, questions, summary }

class _DoctorVisitNoteScreenState extends State<DoctorVisitNoteScreen> {
  final repo = DataRepository.instance;
  final _repaintKey = GlobalKey();

  _NoteStep _step = _NoteStep.pickSymptom;
  SymptomOption? _selectedSymptom;

  // The 4-5 quick questions.
  final _painLocationController = TextEditingController();
  String? _mealTiming; // before / after / not_related
  final _medicationsController = TextEditingController();
  String? _feverStatus; // yes / no / not_sure
  final _otherNotesController = TextEditingController();

  bool _isExporting = false;

  @override
  void dispose() {
    _painLocationController.dispose();
    _medicationsController.dispose();
    _otherNotesController.dispose();
    super.dispose();
  }

  List<VisitNoteAnswer> get _answers => [
        VisitNoteAnswer(
          questionEn: 'Pain / symptom location',
          questionBn: 'ব্যথা/সমস্যার স্থান',
          answer: _painLocationController.text.trim(),
        ),
        VisitNoteAnswer(
          questionEn: 'Timing relative to meals',
          questionBn: 'খাবারের আগে/পরে কিনা',
          answer: switch (_mealTiming) {
            'before' => 'খাবারের আগে',
            'after' => 'খাবারের পরে',
            'not_related' => 'খাবারের সাথে সম্পর্কিত নয়',
            _ => '',
          },
        ),
        VisitNoteAnswer(
          questionEn: 'Current medications',
          questionBn: 'বর্তমানে চলমান ওষুধ',
          answer: _medicationsController.text.trim(),
        ),
        VisitNoteAnswer(
          questionEn: 'Fever',
          questionBn: 'জ্বর আছে কিনা',
          answer: switch (_feverStatus) {
            'yes' => 'হ্যাঁ',
            'no' => 'না',
            'not_sure' => 'নিশ্চিত নই',
            _ => '',
          },
        ),
        VisitNoteAnswer(
          questionEn: 'Other notes',
          questionBn: 'অন্যান্য মন্তব্য',
          answer: _otherNotesController.text.trim(),
        ),
      ];

  bool get _questionsValid =>
      _painLocationController.text.trim().isNotEmpty &&
      _mealTiming != null &&
      _feverStatus != null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ভিজিট নোট'),
        leading: _step == _NoteStep.pickSymptom
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    _step = _step == _NoteStep.summary
                        ? _NoteStep.questions
                        : _NoteStep.pickSymptom;
                  });
                },
              ),
      ),
      body: SafeArea(child: _buildBody()),
    );
  }

  Widget _buildBody() {
    switch (_step) {
      case _NoteStep.pickSymptom:
        return _SymptomPickerStep(
          symptoms: repo.symptoms,
          onSelect: (s) => setState(() {
            _selectedSymptom = s;
            _step = _NoteStep.questions;
          }),
        );
      case _NoteStep.questions:
        return _QuestionsStep(
          painLocationController: _painLocationController,
          medicationsController: _medicationsController,
          otherNotesController: _otherNotesController,
          mealTiming: _mealTiming,
          feverStatus: _feverStatus,
          onMealTimingChanged: (v) => setState(() => _mealTiming = v),
          onFeverChanged: (v) => setState(() => _feverStatus = v),
          canContinue: _questionsValid,
          onContinue: () => setState(() => _step = _NoteStep.summary),
        );
      case _NoteStep.summary:
        return _SummaryStep(
          repaintKey: _repaintKey,
          symptom: _selectedSymptom!,
          answers: _answers,
          isExporting: _isExporting,
          onSaveImage: _handleSaveImage,
          onSavePdf: _handleSavePdf,
        );
    }
  }

  Future<Uint8List?> _captureCard() async {
    final boundary = _repaintKey.currentContext?.findRenderObject()
        as RenderRepaintBoundary?;
    if (boundary == null) return null;
    final image = await boundary.toImage(pixelRatio: 3);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  }

  Future<void> _handleSaveImage() async {
    setState(() => _isExporting = true);
    try {
      final bytes = await _captureCard();
      if (bytes == null) return;
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/doctor_visit_summary.png');
      await file.writeAsBytes(bytes);
      await SharePlus.instance.share(
        ShareParams(files: [XFile(file.path)], text: 'Doctor Visit Summary Card'),
      );
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  Future<void> _handleSavePdf() async {
    setState(() => _isExporting = true);
    try {
      final bytes = await _captureCard();
      if (bytes == null) return;
      final image = pw.MemoryImage(bytes);
      final doc = pw.Document();
      doc.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a5,
          build: (context) => pw.Center(child: pw.Image(image)),
        ),
      );
      await Printing.sharePdf(
        bytes: await doc.save(),
        filename: 'doctor_visit_summary.pdf',
      );
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }
}

// ---------- Step 1: pick symptom ----------

class _SymptomPickerStep extends StatelessWidget {
  final List<SymptomOption> symptoms;
  final ValueChanged<SymptomOption> onSelect;

  const _SymptomPickerStep({required this.symptoms, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('প্রধান সমস্যা নির্বাচন করুন',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              itemCount: symptoms.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final s = symptoms[index];
                return Card(
                  child: ListTile(
                    title: Text(s.nameBn),
                    subtitle: Text(s.nameEn),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => onSelect(s),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ---------- Step 2: quick questions ----------

class _QuestionsStep extends StatelessWidget {
  final TextEditingController painLocationController;
  final TextEditingController medicationsController;
  final TextEditingController otherNotesController;
  final String? mealTiming;
  final String? feverStatus;
  final ValueChanged<String> onMealTimingChanged;
  final ValueChanged<String> onFeverChanged;
  final bool canContinue;
  final VoidCallback onContinue;

  const _QuestionsStep({
    required this.painLocationController,
    required this.medicationsController,
    required this.otherNotesController,
    required this.mealTiming,
    required this.feverStatus,
    required this.onMealTimingChanged,
    required this.onFeverChanged,
    required this.canContinue,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('কিছু দ্রুত প্রশ্ন',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        const _QuestionLabel('ব্যথা/সমস্যার স্থান'),
        TextField(
          controller: painLocationController,
          decoration: _fieldDecoration('যেমন: উপরের পেটে'),
        ),
        const SizedBox(height: 16),
        const _QuestionLabel('খাবারের আগে না পরে সমস্যা বাড়ে?'),
        Wrap(
          spacing: 8,
          children: [
            _OptionChip(
              label: 'খাবারের আগে',
              selected: mealTiming == 'before',
              onTap: () => onMealTimingChanged('before'),
            ),
            _OptionChip(
              label: 'খাবারের পরে',
              selected: mealTiming == 'after',
              onTap: () => onMealTimingChanged('after'),
            ),
            _OptionChip(
              label: 'সম্পর্কিত নয়',
              selected: mealTiming == 'not_related',
              onTap: () => onMealTimingChanged('not_related'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const _QuestionLabel('বর্তমানে কোনো ওষুধ খাচ্ছেন?'),
        TextField(
          controller: medicationsController,
          decoration: _fieldDecoration('যেমন: প্যারাসিটামল'),
        ),
        const SizedBox(height: 16),
        const _QuestionLabel('জ্বর আছে?'),
        Wrap(
          spacing: 8,
          children: [
            _OptionChip(
              label: 'হ্যাঁ',
              selected: feverStatus == 'yes',
              onTap: () => onFeverChanged('yes'),
            ),
            _OptionChip(
              label: 'না',
              selected: feverStatus == 'no',
              onTap: () => onFeverChanged('no'),
            ),
            _OptionChip(
              label: 'নিশ্চিত নই',
              selected: feverStatus == 'not_sure',
              onTap: () => onFeverChanged('not_sure'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const _QuestionLabel('অন্য কোনো মন্তব্য (ঐচ্ছিক)'),
        TextField(
          controller: otherNotesController,
          maxLines: 2,
          decoration: _fieldDecoration('অতিরিক্ত তথ্য...'),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: canContinue ? onContinue : null,
          child: const Text('সারাংশ তৈরি করুন'),
        ),
      ],
    );
  }

  InputDecoration _fieldDecoration(String hint) => InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      );
}

class _QuestionLabel extends StatelessWidget {
  final String text;
  const _QuestionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }
}

class _OptionChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _OptionChip(
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
    );
  }
}

// ---------- Step 3: summary + export ----------

class _SummaryStep extends StatelessWidget {
  final GlobalKey repaintKey;
  final SymptomOption symptom;
  final List<VisitNoteAnswer> answers;
  final bool isExporting;
  final VoidCallback onSaveImage;
  final VoidCallback onSavePdf;

  const _SummaryStep({
    required this.repaintKey,
    required this.symptom,
    required this.answers,
    required this.isExporting,
    required this.onSaveImage,
    required this.onSavePdf,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Center(
          child: RepaintBoundary(
            key: repaintKey,
            child: SummaryCardWidget(
              mainSymptomBn: symptom.nameBn,
              answers: answers,
              createdAt: DateTime.now(),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: isExporting ? null : onSavePdf,
                icon: const Icon(Icons.picture_as_pdf_rounded),
                label: const Text('PDF'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: isExporting ? null : onSaveImage,
                icon: const Icon(Icons.image_rounded),
                label: const Text('ছবি (Image)'),
              ),
            ),
          ],
        ),
        if (isExporting)
          const Padding(
            padding: EdgeInsets.only(top: 16),
            child: Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }
}
