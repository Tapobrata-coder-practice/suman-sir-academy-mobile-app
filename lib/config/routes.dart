// lib/config/routes.dart

import 'package:get/get.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/otp_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/courses/my_courses_screen.dart';
import '../screens/courses/course_detail_screen.dart';
import '../screens/live/live_class_screen.dart';
import '../screens/recorded/recorded_screen.dart';
import '../screens/recorded/video_player_screen.dart';
import '../screens/doubts/doubts_screen.dart';
import '../screens/about/about_screen.dart';
import '../screens/mocktest/mocktest_list_screen.dart';
import '../screens/mocktest/mcq_test_screen.dart';
import '../screens/mocktest/written_test_screen.dart';
import '../screens/mocktest/test_result_screen.dart';
import '../screens/demo/demo_classes_screen.dart';
import '../screens/payment/payment_screen.dart';
import '../screens/notifications/notifications_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/admin/admin_dashboard_screen.dart';
import '../screens/admin/courses/admin_courses_screen.dart';
import '../screens/admin/students/admin_students_screen.dart';
import '../screens/admin/notifications/admin_notifications_screen.dart';
import '../screens/admin/mocktests/admin_mocktests_screen.dart';
import '../screens/admin/batches/admin_batches_screen.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String otp = '/otp';
  static const String home = '/home';
  static const String myCourses = '/my-courses';
  static const String courseDetail = '/course-detail';
  static const String liveClass = '/live-class';
  static const String recorded = '/recorded';
  static const String videoPlayer = '/video-player';
  static const String doubts = '/doubts';
  static const String about = '/about';
  static const String mocktestList = '/mocktest-list';
  static const String mcqTest = '/mcq-test';
  static const String writtenTest = '/written-test';
  static const String testResult = '/test-result';
  static const String demo = '/demo';
  static const String payment = '/payment';
  static const String notifications = '/notifications';
  static const String profile = '/profile';
  static const String adminDashboard = '/admin-dashboard';
  static const String adminCourses = '/admin-courses';
  static const String adminStudents = '/admin-students';
  static const String adminNotifications = '/admin-notifications';
  static const String adminMocktests = '/admin-mocktests';
  static const String adminBatches = '/admin-batches';

  static List<GetPage> get pages => [
        GetPage(name: splash, page: () => const SplashScreen()),
        GetPage(name: login, page: () => const LoginScreen()),
        GetPage(name: otp, page: () => const OtpScreen()),
        GetPage(name: home, page: () => const HomeScreen()),
        GetPage(name: myCourses, page: () => const MyCoursesScreen()),
        GetPage(name: courseDetail, page: () => const CourseDetailScreen()),
        GetPage(name: liveClass, page: () => const LiveClassScreen()),
        GetPage(name: recorded, page: () => const RecordedScreen()),
        GetPage(name: videoPlayer, page: () => const VideoPlayerScreen()),
        GetPage(name: doubts, page: () => const DoubtsScreen()),
        GetPage(name: about, page: () => const AboutScreen()),
        GetPage(name: mocktestList, page: () => const MocktestListScreen()),
        GetPage(name: mcqTest, page: () => const McqTestScreen()),
        GetPage(name: writtenTest, page: () => const WrittenTestScreen()),
        GetPage(name: testResult, page: () => const TestResultScreen()),
        GetPage(name: demo, page: () => const DemoClassesScreen()),
        GetPage(name: payment, page: () => const PaymentScreen()),
        GetPage(name: notifications, page: () => const NotificationsScreen()),
        GetPage(name: profile, page: () => const ProfileScreen()),
        GetPage(name: adminDashboard, page: () => const AdminDashboardScreen()),
        GetPage(name: adminCourses, page: () => const AdminCoursesScreen()),
        GetPage(name: adminStudents, page: () => const AdminStudentsScreen()),
        GetPage(name: adminNotifications, page: () => const AdminNotificationsScreen()),
        GetPage(name: adminMocktests, page: () => const AdminMocktestsScreen()),
        GetPage(name: adminBatches, page: () => const AdminBatchesScreen()),
      ];
}
