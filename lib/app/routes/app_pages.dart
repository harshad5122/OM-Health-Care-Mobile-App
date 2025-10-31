import 'package:get/get.dart';
import 'package:om_health_care_app/app/modules/appointment/views/appointment_view.dart';
import 'package:om_health_care_app/app/modules/appointment/views/booking_calendar_view.dart';
import 'package:om_health_care_app/app/modules/appointment/views/patient_appointment_page.dart';
import 'package:om_health_care_app/app/modules/auth/views/change_password.dart';
import 'package:om_health_care_app/app/modules/leave/view/leave_management_page.dart';
import 'package:om_health_care_app/app/modules/leave/view/leave_record_page.dart';
import 'package:om_health_care_app/app/modules/message/view/chat_page.dart';
import 'package:om_health_care_app/app/modules/message/view/create_broadcast_page.dart';
import 'package:om_health_care_app/app/modules/message/view/message_user_list.dart';
import 'package:om_health_care_app/app/screens/add_doctor.dart';
import 'package:om_health_care_app/app/screens/add_user.dart';
import 'package:om_health_care_app/app/screens/leave_page.dart';
import 'package:om_health_care_app/app/screens/members.dart';
import 'package:om_health_care_app/app/screens/patients_page.dart';
import 'package:om_health_care_app/app/screens/splash_screen.dart';
import '../modules/appointment/controller/appointment_controller.dart';
import '../modules/auth/views/login_view.dart';
import '../modules/auth/views/signup_view.dart';
import '../screens/appointment_page.dart';
import '../screens/dashboard.dart';
import '../screens/notification_page.dart';
import '../screens/profile.dart';
import 'app_routes.dart';

class AppPages {
  static final pages = [
    GetPage(name: AppRoutes.login, page: () => LoginView(),),
    GetPage(name: AppRoutes.splash, page: () => SplashScreen(),),
    GetPage(name: AppRoutes.signup, page: () => SignupView(),),
    GetPage(name: AppRoutes.dashboard, page: () => DashboardPage(),),
    GetPage(name: AppRoutes.profile, page: () => ProfilePage(),),
    GetPage(name: AppRoutes.notification, page: () => NotificationPage(),),
    GetPage(name: AppRoutes.addDoctor, page: () => AddDoctorPage(),),
    GetPage(name: AppRoutes.addUser, page: () => AddUserPage(),),
    GetPage(name: AppRoutes.changePassword, page: () => ChangePasswordView(),),
    GetPage(name: AppRoutes.messageUserList, page: () => MessageUserList(),),
    GetPage(name: AppRoutes.chat, page: () => ChatPage(name: Get.arguments['name'], receiverId: Get.arguments['receiverId'],isBroadcast: Get.arguments['isBroadcast'] ?? false),),
    GetPage(name: AppRoutes.member, page: () => MembersPage(),),
    GetPage(name: AppRoutes.appointment, page: () => AppointmentView(),),
    GetPage(name: AppRoutes.patient_appointment, page: () => PatientAppointmentsPage(),),
    GetPage(name: AppRoutes.leave_management, page: () => LeaveManagementPage(),),
    GetPage(name: AppRoutes.leave_record, page: () => LeaveRecordPage(),),
    GetPage(name: AppRoutes.create_broadcast, page: () => CreateBroadcastPage(),),
    GetPage(name: AppRoutes.appointment_page, page: () => AppointmentPage(),),
    GetPage(name: AppRoutes.leave_page, page: () => LeavePage(),),
    GetPage(name: AppRoutes.patients_page, page: () => PatientsPage(),),
    GetPage(name: AppRoutes.booking_appointment, page: () => BookingCalenderView(),binding: BindingsBuilder(() {
      Get.put(AppointmentController());
    }),),
  ];
}
