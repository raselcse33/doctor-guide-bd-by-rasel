import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/models.dart';
import '../theme.dart';

/// Shown immediately whenever a symptom is flagged `isEmergency: true`.
/// Deliberately blocks the normal questionnaire flow — the priority
/// here is getting the user to real, in-person emergency care.
class EmergencyAlertScreen extends StatelessWidget {
  final SymptomOption? symptom;

  const EmergencyAlertScreen({super.key, required this.symptom});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.emergency,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.warning_amber_rounded,
                  color: Colors.white, size: 80),
              const SizedBox(height: 20),
              const Text(
                'জরুরি সতর্কতা',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              if (symptom != null)
                Text(
                  symptom!.nameBn,
                  style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  symptom?.emergencyNoteBn ??
                      'এই লক্ষণটি জরুরি হতে পারে। দ্রুত নিকটস্থ হাসপাতালের জরুরি বিভাগে (ER) যান।',
                  style: const TextStyle(
                      color: Colors.white, fontSize: 15, height: 1.5),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final uri = Uri.parse('tel:999');
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.emergency,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  icon: const Icon(Icons.call_rounded),
                  label: const Text('জরুরি নম্বরে কল করুন (৯৯৯)'),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => context.goNamed('home'),
                style: TextButton.styleFrom(foregroundColor: Colors.white70),
                child: const Text('হোমে ফিরে যান'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
