class ApiConfig {
  static const String baseUrl = 'https://newstg.peacepay.me';
  static const String apiVersion = 'v1';
  static const String apiBaseUrl = '$baseUrl/api/$apiVersion';
  
  // Endpoints
  static const String login = '/user/login';
  static const String logout = '/user/logout';
  static const String register = '/user/register';
  static const String verifyEmailOtp = '/user/email/otp/verify';
  static const String verifySmsOtp = '/user/sms/otp/verify';
  static const String resendEmailOtp = '/user/email/resend/code';
  static const String resendSmsOtp = '/user/sms/resend/code';
  static const String forgotPasswordSendOtp = '/user/forgot/password/send/mobile/otp';
  static const String forgotPasswordVerify = '/user/forgot/password/verify';
  static const String forgotPasswordReset = '/user/forgot/password/reset';
  
  static const String profile = '/user/profile';
  static const String profileUpdate = '/user/profile/update';
  static const String passwordUpdate = '/user/profile/password/update';
  static const String deleteAccount = '/user/profile/delete/account';
  
  static const String dashboard = '/user/dashboard';
  static const String transactions = '/user/transactions';
  static const String addMoney = '/user/add-money/submit';
  static const String moneyOut = '/user/money-out/submit';
  static const String transfer = '/user/transfer/submit';
  
  static const String peacelinks = '/user/peacelink';
  static const String peacelinkCreate = '/user/peacelink/create';
  
  static const String kycInputFields = '/user/kyc/input-fields';
  static const String kycSubmit = '/user/kyc/submit';
  
  static const String notifications = '/user/notifications';
  
  static const String health = '/api/health';
  
  // PIN endpoints
  static const String pinSetup = '/user/pin/setup';
  static const String pinVerify = '/user/pin/verify';
  static const String pinReset = '/user/pin/reset';
  
  // Role endpoints
  static const String roles = '/user/roles';
  static const String switchRole = '/user/roles/switch';
  static const String registerMerchant = '/user/roles/register/merchant';
  static const String registerDsp = '/user/roles/register/dsp';
  
  // Merchant endpoints
  static const String merchantDashboard = '/merchant/dashboard';
  static const String merchantPeacelinks = '/merchant/peacelinks';
  static const String merchantPolicies = '/merchant/policies';
  
  // DSP endpoints
  static const String dspDashboard = '/dsp/dashboard';
  static const String dspDeliveries = '/dsp/deliveries';
  
  // Disputes
  static const String disputes = '/user/disputes';
}
