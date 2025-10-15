import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  static const String _premiumKey = 'is_premium_user';
  bool _isPremium = false;

  bool get isPremiumUser => _isPremium;

  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isPremium = prefs.getBool(_premiumKey) ?? false;
      print('👤 User Service: Premium status = $_isPremium');
    } catch (e) {
      print('⚠️ User Service error: $e');
      _isPremium = false;
    }
  }

  Future<void> setPremiumStatus(bool isPremium) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_premiumKey, isPremium);
      _isPremium = isPremium;
      print('✅ Premium status updated: $_isPremium');
    } catch (e) {
      print('❌ Failed to update premium status: $e');
    }
  }
}
