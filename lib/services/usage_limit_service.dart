import 'package:shared_preferences/shared_preferences.dart';
import 'user_service.dart';
import 'package:flutter/foundation.dart';

class UsageLimitService {
  static const String _prefKeyLastReset = 'usage_last_reset_date';
  static const String _prefKeySwapCount = 'usage_swap_count';
  static const String _prefKeyVideoSwapCount = 'usage_video_swap_count';
  
  static const int proUserDailyLimit = 20;

  static Future<bool> canProcessSwap() async {
    final userService = UserService();
    
    if (!userService.isPremiumUser) {
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
    
    if (!userService.isPremiumUser) {
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
    
    if (!userService.isPremiumUser) {
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
      await prefs.setInt(_prefKeyVideoSwapCount, 0);
      debugPrint('🔄 Usage counters reset for new day: $today');
    }
  }

  static Future<void> clearUsageData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefKeyLastReset);
    await prefs.remove(_prefKeySwapCount);
    await prefs.remove(_prefKeyVideoSwapCount);
    debugPrint('🗑️ Usage data cleared');
  }

  // Video Swap - Tier-based limits
  static int getVideoSwapDailyLimit(String tier) {
    switch (tier.toLowerCase()) {
      case 'lifetime':
        return 20;
      case 'yearly':
        return 10;
      case 'weekly':
        return 5;
      default:
        return 0; // Free users can't use video swap
    }
  }

  static Future<String> getCurrentTier() async {
    final userService = UserService();
    
    if (!userService.isPremiumUser) {
      return 'free';
    }
    
    // Check subscription tier (you may need to adjust based on your subscription system)
    // For now, defaulting to 'yearly' for premium users
    // You can enhance this to check actual subscription tier from RevenueCat
    return 'yearly';
  }

  static Future<bool> canProcessVideoSwap() async {
    final userService = UserService();
    
    // FREE users cannot use video swap (PRO-only feature)
    if (!userService.isPremiumUser) {
      debugPrint('❌ FREE user - video swap requires PRO subscription');
      return false;
    }

    await _resetIfNewDay();
    
    final tier = await getCurrentTier();
    final limit = getVideoSwapDailyLimit(tier);
    
    final prefs = await SharedPreferences.getInstance();
    final currentCount = prefs.getInt(_prefKeyVideoSwapCount) ?? 0;
    
    if (currentCount >= limit) {
      debugPrint('❌ Video swap limit reached: $currentCount/$limit (tier: $tier)');
      return false;
    }
    
    debugPrint('✅ Can process video swap: $currentCount/$limit (tier: $tier)');
    return true;
  }

  static Future<void> incrementVideoSwapCount() async {
    final userService = UserService();
    
    if (!userService.isPremiumUser) {
      return;
    }

    await _resetIfNewDay();
    
    final prefs = await SharedPreferences.getInstance();
    final currentCount = prefs.getInt(_prefKeyVideoSwapCount) ?? 0;
    final newCount = currentCount + 1;
    await prefs.setInt(_prefKeyVideoSwapCount, newCount);
    
    final tier = await getCurrentTier();
    final limit = getVideoSwapDailyLimit(tier);
    debugPrint('📊 Video swap count incremented: $newCount/$limit (tier: $tier)');
  }

  static Future<int> getRemainingVideoSwaps() async {
    final userService = UserService();
    
    if (!userService.isPremiumUser) {
      return 0;
    }

    await _resetIfNewDay();
    
    final tier = await getCurrentTier();
    final limit = getVideoSwapDailyLimit(tier);
    
    final prefs = await SharedPreferences.getInstance();
    final currentCount = prefs.getInt(_prefKeyVideoSwapCount) ?? 0;
    final remaining = limit - currentCount;
    
    return remaining > 0 ? remaining : 0;
  }
}
