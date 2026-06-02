// lib/screens/admin/mocktests/admin_mocktests_screen.dart
import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class AdminMocktestsScreen extends StatelessWidget {
  const AdminMocktestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mock Tests')),
      body: const Center(child: Text('Admin Mocktest Management')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Add Test', style: TextStyle(color: Colors.white, fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
      ),
    );
  }
}
