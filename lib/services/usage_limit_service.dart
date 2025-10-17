import 'package:shared_preferences/shared_preferences.dart';
import 'user_service.dart';
import 'package:flutter/foundation.dart';

class UsageLimitService {
  static const String _prefKeyLastReset = 'usage_last_reset_date';
  static const String _prefKeySwapCount = 'usage_swap_count';
  
  static const int proUserDailyLimit = 20;

  static Future<bool> canProcessSwap() async {
    final userService = UserService();
    
    if (!userService.isPremium) {
      debugPrint('✅ FREE user - unlimited swaps with ads');
      return true;
    }

    await _resetIfNewDay();
    
    final prefs = await SharedPreferences.getInstance();
    final currentCount = prefs.getInt(_prefKeySwapCount) ?? 0;
    
    if (currentCount >= proUserDailyLimit) {
      debugPrint('❌ PRO user daily limit reached: $currentCount/$proUserDailyLimit');
      return false;
    }
    
    debugPrint('✅ PRO user can swap: $currentCount/$proUserDailyLimit');
    return true;
  }

  static Future<void> incrementSwapCount() async {
    final userService = UserService();
    
    if (!userService.isPremium) {
      return;
    }

    await _resetIfNewDay();
    
    final prefs = await SharedPreferences.getInstance();
    final currentCount = prefs.getInt(_prefKeySwapCount) ?? 0;
    final newCount = currentCount + 1;
    await prefs.setInt(_prefKeySwapCount, newCount);
    
    debugPrint('📊 PRO user swap count incremented: $newCount/$proUserDailyLimit');
  }

  static Future<int> getRemainingSwaps() async {
    final userService = UserService();
    
    if (!userService.isPremium) {
      return -1;
    }

    await _resetIfNewDay();
    
    final prefs = await SharedPreferences.getInstance();
    final currentCount = prefs.getInt(_prefKeySwapCount) ?? 0;
    final remaining = proUserDailyLimit - currentCount;
    
    return remaining > 0 ? remaining : 0;
  }

  static Future<void> _resetIfNewDay() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    final lastReset = prefs.getString(_prefKeyLastReset);
    
    if (lastReset != today) {
      await prefs.setString(_prefKeyLastReset, today);
      await prefs.setInt(_prefKeySwapCount, 0);
      debugPrint('🔄 Usage counter reset for new day: $today');
    }
  }

  static Future<void> clearUsageData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefKeyLastReset);
    await prefs.remove(_prefKeySwapCount);
    debugPrint('🗑️ Usage data cleared');
  }
}
