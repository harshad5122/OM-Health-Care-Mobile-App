class ApiConstants {
  static const String BASE_URL =  "https://4ab3be639dde.ngrok-free.app/api";


  // AUTH ROUTES
  static const String SIGNUP = "$BASE_URL/auth/signup";
  static const String SIGNIN = "$BASE_URL/auth/signin";
  static const String CHANGE_PASSWORD = "$BASE_URL/auth/change-password";

  // USER ROUTES
  static const String GET_USER_PROFILE = "$BASE_URL/user/profile";
  static const String UPDATE_USER_PROFILE = "$BASE_URL/update/profile";
  static const String ADD_USER = "$BASE_URL/user/add";

  //STAFF ROUTES
  static const String ADD_DOCTOR = "$BASE_URL/add/doctor";

}