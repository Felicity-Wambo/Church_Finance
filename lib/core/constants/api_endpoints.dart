class ApiEndpoints {
  // Change this based on your environment
 static const String baseUrl =
      'https://a345-102-0-12-202.ngrok-free.app/api/v1';

  // Auth
  static const String login = '$baseUrl/auth/login';
  static const String register = '$baseUrl/auth/register';
  static const String logout = '$baseUrl/auth/logout';
  static const String me = '$baseUrl/auth/me';

  // Dashboard
  static const String dashboardSummary = '$baseUrl/dashboard/summary';
  static const String dashboardChart = '$baseUrl/dashboard/chart';
  static const String recentTransactions = '$baseUrl/dashboard/recent';

  // Giving
  static const String givingProcess = '$baseUrl/giving/process';
  static const String givingHistory = '$baseUrl/giving/history';
  static const String givingSummary = '$baseUrl/giving/summary';

  // Pledge
  static const String pledge = '$baseUrl/pledge';
  static const String pledgeHistory = '$baseUrl/pledge/history';

  // Churches
  static const String churches = '$baseUrl/churches';

  // M-Pesa
  static const String mpesaStkPush = '$baseUrl/mpesa/stkpush';
static const String mpesaStatus = '/giving/mpesa/status';}