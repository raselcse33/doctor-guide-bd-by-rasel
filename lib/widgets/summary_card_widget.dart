import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme.dart';

/// The visual "Doctor Visit Summary Card" — this exact widget tree is
/// what gets captured to an image / embedded into the exported PDF,
/// so keep it self-contained and free of external state.
class SummaryCardWidget extends StatelessWidget {
  final String mainSymptomBn;
  final List<VisitNoteAnswer> answers;
  final DateTime createdAt;

  const SummaryCardWidget({
    super.key,
    required this.mainSymptomBn,
    required this.answers,
    required this.createdAt,
  });

  @override
  Widget build(BuildContext context) {
    final dateStr =
        '${createdAt.day.toString().padLeft(2, '0')}-${createdAt.month.toString().padLeft(2, '0')}-${createdAt.year}';

    return Container(
      width: 340,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryLight, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.local_hospital_rounded,
                  color: AppColors.primary, size: 22),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Doctor Visit Summary Card',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary),
                ),
              ),
            ],
          ),
          Text(dateStr,
              style: const TextStyle(
                  fontSize: 11, color: AppColors.textSecondary)),
          const Divider(height: 24),
          const Text('প্রধান সমস্যা',
              style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text(mainSymptomBn,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ...answers.map((a) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(a.questionBn,
                        style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(
                      a.answer.isEmpty ? '—' : a.answer,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              )),
          const Divider(height: 8),
          const SizedBox(height: 8),
          const Text(
            'এই সারাংশটি Doctor Guide BD অ্যাপ থেকে তৈরি — এটি রোগনির্ণয় নয়, শুধুমাত্র ডাক্তারকে দ্রুত তথ্য দেওয়ার জন্য।',
            style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
