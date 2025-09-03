import 'package:get/get.dart';
import '../modules/auth/views/login_view.dart';
import '../modules/auth/views/signup_view.dart';
import '../modules/auth/bindings/auth_binding.dart';
import '../screens/dashboard.dart';
import '../screens/profile.dart';
import 'app_routes.dart';

class AppPages {
  static final pages = [
    GetPage(name: AppRoutes.login, page: () => LoginView(),),
    GetPage(name: AppRoutes.signup, page: () => SignupView(),),
    GetPage(name: AppRoutes.dashboard, page: () => DashboardPage(),),
    GetPage(name: AppRoutes.profile, page: () => ProfilePage(),),
  ];
}
