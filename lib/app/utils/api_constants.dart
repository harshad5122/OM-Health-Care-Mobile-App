class ApiConstants {
  static const String BASE_URL =  "https://8b1e9a0b0370.ngrok-free.app/api";

  // AUTH ROUTES
  static const String SIGNUP = "$BASE_URL/auth/signup";
  static const String SIGNIN = "$BASE_URL/auth/signin";
  static const String VERIFY_OTP = "$BASE_URL/auth/verify-otp";
  static const String CHANGE_PASSWORD = "$BASE_URL/auth/change-password";

  // USER ROUTES
  static const String GET_USER_PROFILE = "$BASE_URL/user/profile";
  static const String UPDATE_USER_PROFILE = "$BASE_URL/update/profile";
  static const String ADD_USER = "$BASE_URL/user/add";

  //STAFF ROUTES
  static const String ADD_DOCTOR = "$BASE_URL/add/doctor";

  // MESSAGE ROUTES
  static const String GET_MESSAGE_LIST = "$BASE_URL/message/list";
  static const String UPLOAD_FILE = "$BASE_URL/file/upload";

}