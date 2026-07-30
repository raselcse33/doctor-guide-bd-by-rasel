import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Doctor Guide BD')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const SizedBox(height: 8),
            const Icon(Icons.local_hospital_rounded,
                color: AppColors.primary, size: 56),
            const SizedBox(height: 12),
            const Text(
              'সঠিক ডাক্তার খুঁজে নিন',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary),
            ),
            const SizedBox(height: 4),
            const Text(
              'সম্পূর্ণ অফলাইনে — কোনো ইন্টারনেট প্রয়োজন নেই',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 28),
            _HomeActionCard(
              icon: Icons.fact_check_rounded,
              titleBn: 'উপসর্গ পরীক্ষা করুন',
              subtitleBn: 'লক্ষণ অনুযায়ী বিশেষজ্ঞ খুঁজুন',
              onTap: () => context.pushNamed('questionnaire'),
            ),
            const SizedBox(height: 14),
            _HomeActionCard(
              icon: Icons.menu_book_rounded,
              titleBn: 'স্বাস্থ্য গাইড',
              subtitleBn: 'ডিগ্রি ও বিশেষজ্ঞ সম্পর্কে জানুন',
              onTap: () => context.pushNamed('health-guide'),
            ),
            const SizedBox(height: 14),
            _HomeActionCard(
              icon: Icons.note_alt_rounded,
              titleBn: 'ভিজিট নোট তৈরি করুন',
              subtitleBn: 'ডাক্তারকে দেখানোর জন্য সারাংশ তৈরি করুন',
              onTap: () => context.pushNamed('visit-note'),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeActionCard extends StatelessWidget {
  final IconData icon;
  final String titleBn;
  final String subtitleBn;
  final VoidCallback onTap;

  const _HomeActionCard({
    required this.icon,
    required this.titleBn,
    required this.subtitleBn,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.primary, size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(titleBn,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(subtitleBn,
                        style: const TextStyle(
                            fontSize: 13, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
