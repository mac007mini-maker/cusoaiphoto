import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '/services/user_service.dart';

/// RevenueCat service for In-App Purchases
/// Handles subscription management, product loading, and purchase flow
class RevenueCatService {
  static final RevenueCatService _instance = RevenueCatService._internal();
  factory RevenueCatService() => _instance;
  RevenueCatService._internal();

  bool _isInitialized = false;
  Offerings? _currentOfferings;

  // RevenueCat API Keys (from environment or hardcoded for testing)
  // Project ID: projb4face67 | Offering ID: ofrng1c5b1a3712
  static const String _testApiKey = 'test_OvwtrjRddtWRHgmNdZgxCTiYLYX';
  static const String _prodApiKeyAndroid = String.fromEnvironment(
    'REVENUECAT_ANDROID_KEY',
    defaultValue: _testApiKey,
  );
  static const String _prodApiKeyIOS = String.fromEnvironment(
    'REVENUECAT_IOS_KEY',
    defaultValue: _testApiKey,
  );

  /// Initialize RevenueCat SDK
  Future<void> initialize() async {
    if (_isInitialized) {
      debugPrint('⚠️ RevenueCat already initialized');
      return;
    }

    // Skip on web - mark as initialized to prevent API calls
    if (kIsWeb) {
      debugPrint('⚠️ RevenueCat not supported on web');
      _isInitialized = true;
      return;
    }

    try {

      // Configure RevenueCat
      final String apiKey = defaultTargetPlatform == TargetPlatform.iOS
          ? _prodApiKeyIOS
          : _prodApiKeyAndroid;

      debugPrint('🛒 Initializing RevenueCat with key: ${apiKey.substring(0, 10)}...');

      await Purchases.configure(
        PurchasesConfiguration(apiKey),
      );

      // Set attributes for analytics
      await Purchases.setAttributes({
        'platform': defaultTargetPlatform.toString(),
      });

      _isInitialized = true;
      debugPrint('✅ RevenueCat initialized successfully');

      // Load offerings
      await _loadOfferings();
    } catch (e) {
      debugPrint('❌ RevenueCat initialization error: $e');
      _isInitialized = false;
    }
  }

  /// Load available offerings from RevenueCat
  Future<void> _loadOfferings() async {
    try {
      _currentOfferings = await Purchases.getOfferings();
      
      if (_currentOfferings?.current != null) {
        final packages = _currentOfferings!.current!.availablePackages;
        debugPrint('✅ RevenueCat offerings loaded: ${packages.length} packages');
        
        for (var package in packages) {
          debugPrint('   - ${package.storeProduct.identifier}: ${package.storeProduct.priceString}');
        }
      } else {
        debugPrint('⚠️ No current offering available');
      }
    } catch (e) {
      debugPrint('❌ Error loading offerings: $e');
    }
  }

  /// Get current offerings
  Future<Offerings?> getOfferings() async {
    if (!_isInitialized) {
      await initialize();
    }

    // Return null on web
    if (kIsWeb) {
      return null;
    }

    // Refresh offerings
    try {
      _currentOfferings = await Purchases.getOfferings();
      return _currentOfferings;
    } catch (e) {
      debugPrint('❌ Error getting offerings: $e');
      return _currentOfferings; // Return cached if refresh fails
    }
  }

  /// Get subscription packages (Weekly, Yearly, Lifetime)
  Future<List<Package>> getSubscriptionPackages() async {
    final offerings = await getOfferings();
    
    if (offerings?.current == null) {
      debugPrint('⚠️ No offerings available');
      debugPrint('💡 TIP: To fix this on iOS:');
      debugPrint('   1. Open Xcode → Product → Scheme → Edit Scheme');
      debugPrint('   2. Run → Options → StoreKit Configuration → Select Configuration.storekit');
      debugPrint('   3. Clean build and re-run');
      debugPrint('💡 TIP: To fix this on Android:');
      debugPrint('   1. Setup products in Google Play Console');
      debugPrint('   2. Link RevenueCat to Google Play');
      debugPrint('   3. Add product IDs to RevenueCat dashboard');
      return [];
    }

    final packages = offerings!.current!.availablePackages;
    
    // Debug: Print all packages
    debugPrint('📦 Available packages (${packages.length}):');
    for (var pkg in packages) {
      debugPrint('   - ${pkg.identifier}: ${pkg.storeProduct.priceString} (${pkg.packageType})');
    }
    
    // Sort packages: Lifetime → Yearly → Weekly
    packages.sort((a, b) {
      final aType = a.packageType;
      final bType = b.packageType;
      
      // Lifetime first
      if (aType == PackageType.lifetime) return -1;
      if (bType == PackageType.lifetime) return 1;
      
      // Annual second
      if (aType == PackageType.annual) return -1;
      if (bType == PackageType.annual) return 1;
      
      // Weekly third
      if (aType == PackageType.weekly) return -1;
      if (bType == PackageType.weekly) return 1;
      
      return 0;
    });

    return packages;
  }

  /// Purchase a package
  Future<PurchaseResult> purchasePackage(Package package) async {
    try {
      debugPrint('🛒 Attempting to purchase: ${package.storeProduct.identifier}');
      
      final customerInfo = await Purchases.purchasePackage(package);
      
      // Check if user has pro entitlement
      final isPro = customerInfo.entitlements.all['pro']?.isActive ?? false;
      
      if (isPro) {
        debugPrint('✅ Purchase successful! User is now premium.');
        
        // Update UserService
        await UserService().setPremiumStatus(true);
        
        return PurchaseResult(
          success: true,
          isPremium: true,
          customerInfo: customerInfo,
        );
      } else {
        debugPrint('⚠️ Purchase completed but no active entitlement');
        return PurchaseResult(
          success: false,
          isPremium: false,
          error: 'No active entitlement found',
        );
      }
    } on PlatformException catch (e) {
      final errorCode = PurchasesErrorHelper.getErrorCode(e);
      debugPrint('❌ Purchase error: ${errorCode.name} - ${e.message}');
      
      // User cancelled
      if (errorCode == PurchasesErrorCode.purchaseCancelledError) {
        return PurchaseResult(
          success: false,
          isPremium: false,
          error: 'Purchase cancelled',
          userCancelled: true,
        );
      }
      
      return PurchaseResult(
        success: false,
        isPremium: false,
        error: e.message ?? 'Purchase failed',
      );
    } catch (e) {
      debugPrint('❌ Unexpected purchase error: $e');
      return PurchaseResult(
        success: false,
        isPremium: false,
        error: e.toString(),
      );
    }
  }

  /// Restore previous purchases
  Future<PurchaseResult> restorePurchases() async {
    try {
      debugPrint('🔄 Restoring purchases...');
      
      final customerInfo = await Purchases.restorePurchases();
      
      final isPro = customerInfo.entitlements.all['pro']?.isActive ?? false;
      
      if (isPro) {
        debugPrint('✅ Purchases restored! User is premium.');
        
        // Update UserService
        await UserService().setPremiumStatus(true);
        
        return PurchaseResult(
          success: true,
          isPremium: true,
          customerInfo: customerInfo,
          message: 'Purchases restored successfully',
        );
      } else {
        debugPrint('⚠️ No active purchases found');
        
        // Update UserService
        await UserService().setPremiumStatus(false);
        
        return PurchaseResult(
          success: false,
          isPremium: false,
          message: 'No active purchases found',
        );
      }
    } catch (e) {
      debugPrint('❌ Restore purchases error: $e');
      return PurchaseResult(
        success: false,
        isPremium: false,
        error: 'Failed to restore purchases: $e',
      );
    }
  }

  /// Check current subscription status
  Future<bool> isPremiumUser() async {
    if (!_isInitialized) {
      await initialize();
    }

    // Return false on web (IAP not supported)
    if (kIsWeb) {
      return false;
    }

    try {
      final customerInfo = await Purchases.getCustomerInfo();
      final isPro = customerInfo.entitlements.all['pro']?.isActive ?? false;
      
      // Sync with UserService
      await UserService().setPremiumStatus(isPro);
      
      return isPro;
    } catch (e) {
      debugPrint('❌ Error checking premium status: $e');
      return false;
    }
  }

  /// Get customer info
  Future<CustomerInfo?> getCustomerInfo() async {
    // Return null on web
    if (kIsWeb) {
      return null;
    }

    try {
      return await Purchases.getCustomerInfo();
    } catch (e) {
      debugPrint('❌ Error getting customer info: $e');
      return null;
    }
  }

  bool get isInitialized => _isInitialized;
}

/// Purchase result model
class PurchaseResult {
  final bool success;
  final bool isPremium;
  final CustomerInfo? customerInfo;
  final String? error;
  final String? message;
  final bool userCancelled;

  PurchaseResult({
    required this.success,
    required this.isPremium,
    this.customerInfo,
    this.error,
    this.message,
    this.userCancelled = false,
  });
}
