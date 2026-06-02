// lib/screens/admin/batches/admin_batches_screen.dart
import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class AdminBatchesScreen extends StatelessWidget {
  const AdminBatchesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final batches = [
      {'name': 'Semester 1', 'desc': 'First semester students'},
      {'name': 'Semester 2', 'desc': 'Second semester students'},
      {'name': 'Semester 3', 'desc': 'Third semester students'},
      {'name': 'Backlog Batch', 'desc': 'Students with backlogs'},
      {'name': 'Special Course Batch', 'desc': 'Premium special course'},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Batches')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: batches.length,
        itemBuilder: (_, i) => Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : AppColors.cardLight,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.group_rounded, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(batches[i]['name']!, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, fontFamily: 'Poppins')),
                    Text(batches[i]['desc']!, style: TextStyle(fontSize: 11, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight, fontFamily: 'Poppins')),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 14),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Add Batch', style: TextStyle(color: Colors.white, fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
      ),
    );
  }
}
