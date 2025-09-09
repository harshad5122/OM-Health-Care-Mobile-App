import 'package:get/get.dart';
import 'package:om_health_care_app/app/modules/auth/views/change_password.dart';
import 'package:om_health_care_app/app/modules/message/view/chat_page.dart';
import 'package:om_health_care_app/app/modules/message/view/message_user_list.dart';
import 'package:om_health_care_app/app/screens/add_doctor.dart';
import 'package:om_health_care_app/app/screens/add_user.dart';
import '../modules/auth/views/login_view.dart';
import '../modules/auth/views/signup_view.dart';
import '../screens/dashboard.dart';
import '../screens/profile.dart';
import 'app_routes.dart';

class AppPages {
  static final pages = [
    GetPage(name: AppRoutes.login, page: () => LoginView(),),
    GetPage(name: AppRoutes.signup, page: () => SignupView(),),
    GetPage(name: AppRoutes.dashboard, page: () => DashboardPage(),),
    GetPage(name: AppRoutes.profile, page: () => ProfilePage(),),
    GetPage(name: AppRoutes.addDoctor, page: () => AddDoctorPage(),),
    GetPage(name: AppRoutes.addUser, page: () => AddUserPage(),),
    GetPage(name: AppRoutes.changePassword, page: () => ChangePasswordView(),),
    GetPage(name: AppRoutes.messageUserList, page: () => MessageUserList(),),
    GetPage(name: AppRoutes.chat, page: () => ChatPage(name: Get.arguments['name'], receiverId: Get.arguments['receiverId'],),),
  ];
}
