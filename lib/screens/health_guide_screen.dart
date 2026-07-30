import 'package:flutter/material.dart';
import '../data/data_repository.dart';
import '../models/models.dart';
import '../theme.dart';

/// Two tabs: "Medical Degrees Explained" and "Specialists Guide".
/// Search filtering runs entirely against the in-memory JSON-backed
/// lists loaded at startup — no network calls involved.
class HealthGuideScreen extends StatefulWidget {
  const HealthGuideScreen({super.key});

  @override
  State<HealthGuideScreen> createState() => _HealthGuideScreenState();
}

class _HealthGuideScreenState extends State<HealthGuideScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _degreeQueryController = TextEditingController();
  final _specialistQueryController = TextEditingController();

  String _degreeQuery = '';
  String _specialistQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _degreeQueryController.addListener(() {
      setState(() => _degreeQuery = _degreeQueryController.text.trim());
    });
    _specialistQueryController.addListener(() {
      setState(() => _specialistQuery = _specialistQueryController.text.trim());
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _degreeQueryController.dispose();
    _specialistQueryController.dispose();
    super.dispose();
  }

  List<MedicalDegree> get _filteredDegrees {
    final repo = DataRepository.instance;
    if (_degreeQuery.isEmpty) return repo.medicalDegrees;
    final q = _degreeQuery.toLowerCase();
    return repo.medicalDegrees
        .where((d) =>
            d.title.toLowerCase().contains(q) ||
            d.fullFormEn.toLowerCase().contains(q) ||
            d.explanationBn.contains(_degreeQuery))
        .toList();
  }

  List<Specialist> get _filteredSpecialists {
    final repo = DataRepository.instance;
    if (_specialistQuery.isEmpty) return repo.specialists;
    final q = _specialistQuery.toLowerCase();
    return repo.specialists
        .where((s) =>
            s.nameEn.toLowerCase().contains(q) ||
            s.nameBn.contains(_specialistQuery) ||
            s.descriptionBn.contains(_specialistQuery))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('স্বাস্থ্য গাইড'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'ডিগ্রি ব্যাখ্যা'),
            Tab(text: 'বিশেষজ্ঞ গাইড'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _DegreesTab(
            controller: _degreeQueryController,
            degrees: _filteredDegrees,
          ),
          _SpecialistsTab(
            controller: _specialistQueryController,
            specialists: _filteredSpecialists,
          ),
        ],
      ),
    );
  }
}

class _DegreesTab extends StatelessWidget {
  final TextEditingController controller;
  final List<MedicalDegree> degrees;

  const _DegreesTab({required this.controller, required this.degrees});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _SearchField(controller: controller, hint: 'ডিগ্রি খুঁজুন (MBBS, FCPS...)'),
          const SizedBox(height: 12),
          Expanded(
            child: degrees.isEmpty
                ? const Center(child: Text('কোনো ফলাফল পাওয়া যায়নি'))
                : ListView.separated(
                    itemCount: degrees.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final d = degrees[index];
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(d.title,
                                      style: const TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primary)),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      d.fullFormEn,
                                      style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textSecondary),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(d.explanationBn,
                                  style: const TextStyle(height: 1.5)),
                            ],
                          ),
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

class _SpecialistsTab extends StatelessWidget {
  final TextEditingController controller;
  final List<Specialist> specialists;

  const _SpecialistsTab({required this.controller, required this.specialists});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _SearchField(
              controller: controller, hint: 'বিশেষজ্ঞ খুঁজুন (Cardiology, ENT...)'),
          const SizedBox(height: 12),
          Expanded(
            child: specialists.isEmpty
                ? const Center(child: Text('কোনো ফলাফল পাওয়া যায়নি'))
                : ListView.separated(
                    itemCount: specialists.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final s = specialists[index];
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(s.nameBn,
                                  style: const TextStyle(
                                      fontSize: 16, fontWeight: FontWeight.bold)),
                              Text(s.nameEn,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary)),
                              const SizedBox(height: 8),
                              Text(s.descriptionBn),
                              const SizedBox(height: 6),
                              Text(
                                'কখন দেখাবেন: ${s.whenToVisitBn}',
                                style: const TextStyle(
                                    fontSize: 13,
                                    fontStyle: FontStyle.italic,
                                    color: AppColors.textSecondary),
                              ),
                            ],
                          ),
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

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;

  const _SearchField({required this.controller, required this.hint});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: const Icon(Icons.search_rounded),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
