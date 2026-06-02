import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../theme/app_theme.dart';
import '../../../services/notification_service.dart';
import '../../../widgets/custom_button.dart';

class AdminNotificationsScreen extends StatefulWidget {
  const AdminNotificationsScreen({super.key});
  @override
  State<AdminNotificationsScreen> createState() => _AdminNotificationsScreenState();
}

class _AdminNotificationsScreenState extends State<AdminNotificationsScreen> {
  final _titleCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();
  String _selectedType = 'announcement';
  bool _isImportant = false;
  bool _sending = false;
  final _types = ['announcement', 'class_reminder', 'payment', 'exam', 'holiday'];

  @override
  void dispose() { _titleCtrl.dispose(); _bodyCtrl.dispose(); super.dispose(); }

  Future<void> _send() async {
    if (_titleCtrl.text.trim().isEmpty || _bodyCtrl.text.trim().isEmpty) {
      Get.snackbar('Required', 'Please fill title and message', backgroundColor: AppColors.error, colorText: Colors.white, snackPosition: SnackPosition.TOP, margin: EdgeInsets.all(16.w));
      return;
    }
    setState(() => _sending = true);
    try {
      await NotificationService.instance.sendNotificationToTopic(title: _titleCtrl.text.trim(), body: _bodyCtrl.text.trim(), type: _selectedType);
      setState(() { _sending = false; _titleCtrl.clear(); _bodyCtrl.clear(); });
      Get.snackbar('Sent! 🎉', 'Notification sent to all students', backgroundColor: AppColors.success, colorText: Colors.white, snackPosition: SnackPosition.TOP, margin: EdgeInsets.all(16.w));
    } catch (_) {
      setState(() => _sending = false);
      Get.snackbar('Error', 'Failed to send notification', backgroundColor: AppColors.error, colorText: Colors.white, snackPosition: SnackPosition.TOP, margin: EdgeInsets.all(16.w));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(title: const Text('Send Notification')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Notification Type', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, fontFamily: 'Poppins', color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)),
            SizedBox(height: 8.h),
            Wrap(
              spacing: 8.w,
              children: _types.map((t) {
                final isSelected = _selectedType == t;
                return FilterChip(
                  label: Text(t.replaceAll('_', ' ').capitalizeFirst!, style: TextStyle(fontSize: 11.sp, fontFamily: 'Poppins', fontWeight: FontWeight.w600, color: isSelected ? Colors.white : isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)),
                  selected: isSelected,
                  onSelected: (_) => setState(() => _selectedType = t),
                  selectedColor: AppColors.primary,
                  backgroundColor: isDark ? AppColors.cardDark : AppColors.bgLight,
                );
              }).toList(),
            ),
            SizedBox(height: 16.h),
            TextField(controller: _titleCtrl, decoration: const InputDecoration(labelText: 'Notification Title', hintText: 'e.g. Class Tomorrow at 6 PM')),
            SizedBox(height: 12.h),
            TextField(controller: _bodyCtrl, maxLines: 4, decoration: const InputDecoration(labelText: 'Message', hintText: 'Write the notification message here...')),
            SizedBox(height: 12.h),
            SwitchListTile(
              value: _isImportant,
              onChanged: (v) => setState(() => _isImportant = v),
              title: Text('Mark as Important', style: TextStyle(fontSize: 13.sp, fontFamily: 'Poppins', fontWeight: FontWeight.w600, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)),
              subtitle: Text('Shows popup when app opens', style: TextStyle(fontSize: 11.sp, fontFamily: 'Poppins', color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
              activeColor: AppColors.primary,
              contentPadding: EdgeInsets.zero,
            ),
            SizedBox(height: 20.h),
            CustomButton(text: 'Send to All Students', isLoading: _sending, onPressed: _send, icon: Icons.send_rounded),
          ],
        ),
      ),
    );
  }
}
