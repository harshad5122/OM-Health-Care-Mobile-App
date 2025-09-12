class ApiConstants {
  static const String BASE_URL =  "https://deca9579ae82.ngrok-free.app/api";

  // AUTH ROUTES
  static const String SIGNUP = "$BASE_URL/auth/signup";
  static const String SIGNIN = "$BASE_URL/auth/signin";
  static const String VERIFY_OTP = "$BASE_URL/auth/verify-otp";
  static const String CHANGE_PASSWORD = "$BASE_URL/auth/change-password";

  // USER ROUTES
  static const String GET_USER_PROFILE = "$BASE_URL/user/profile";
  static const String UPDATE_USER_PROFILE = "$BASE_URL/update/profile";
  static const String ADD_USER = "$BASE_URL/user/add";
  static const String GET_USER_BY_ID = "$BASE_URL/user";
  static const String EDIT_USER = "$BASE_URL/edit/user";
  static const String DELET_USER = "$BASE_URL/delete/user";

  //STAFF ROUTES
  static const String ADD_DOCTOR = "$BASE_URL/add/doctor";
  static const String GET_DOCTOR = "$BASE_URL/get/doctor";
  static const String GET_DOCTOR_BY_ID = "$BASE_URL/get/doctor";
  static const String EDIT_DOCTOR = "$BASE_URL/edit/doctor";
  static const String DELETE_DOCTOR = "$BASE_URL/delete/doctor";

  // MESSAGE ROUTES
  static const String GET_MESSAGE_LIST = "$BASE_URL/message/list";
  static const String UPLOAD_FILE = "$BASE_URL/file/upload";
  static const String GET_ALL_CHAT_USER = "$BASE_URL/chat/users";

  //USER LIST ROUTES
  static const String GET_USER_LIST = "$BASE_URL/user/list";
  static const String GET_STAFF_LIST = "$BASE_URL/staff/list";
  static const String GET_ADMIN_LIST = "$BASE_URL/admin/list";

}