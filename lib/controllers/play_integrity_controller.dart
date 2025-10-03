import 'dart:developer';
import 'package:driver/services/play_integrity_service.dart';
import 'package:get/get.dart';

class PlayIntegrityController extends GetxController {
  RxBool isIntegrityVerified = false.obs;
  RxBool isLoading = false.obs;
  RxString integrityStatus = 'Not verified'.obs;
  RxString lastToken = ''.obs;

  @override
  void onInit() {
    super.onInit();
    print('🔐 [Play Integrity Controller] Controller initialized');
    print('🔐 [Play Integrity Controller] Starting initial integrity check...');
    // Perform initial integrity check
    checkIntegrity();
  }

  /// Check device integrity
  Future<void> checkIntegrity() async {
    print('🔐 [Play Integrity Controller] Starting integrity check...');
    print('🔐 [Play Integrity Controller] Current loading state: ${isLoading.value}');
    
    isLoading.value = true;
    integrityStatus.value = 'Checking...';
    
    print('🔐 [Play Integrity Controller] Loading set to true, status: ${integrityStatus.value}');

    try {
      print('🔐 [Play Integrity Controller] Calling PlayIntegrityService.verifyDeviceIntegrity()...');
      final isVerified = await PlayIntegrityService.verifyDeviceIntegrity();
      print('🔐 [Play Integrity Controller] Verification result: $isVerified');
      
      isIntegrityVerified.value = isVerified;
      print('🔐 [Play Integrity Controller] Updated isIntegrityVerified: ${isIntegrityVerified.value}');
      
      if (isVerified) {
        integrityStatus.value = 'Verified';
        lastToken.value = PlayIntegrityService.lastIntegrityToken ?? '';
        print('🔐 [Play Integrity Controller] ✅ Integrity check successful');
        print('🔐 [Play Integrity Controller] Status: ${integrityStatus.value}');
        print('🔐 [Play Integrity Controller] Token length: ${lastToken.value.length}');
        log('Play Integrity: Device integrity verified successfully');
      } else {
        integrityStatus.value = 'Failed';
        print('🔐 [Play Integrity Controller] ❌ Integrity check failed');
        print('🔐 [Play Integrity Controller] Status: ${integrityStatus.value}');
        log('Play Integrity: Device integrity check failed');
      }
    } catch (e) {
      integrityStatus.value = 'Error: $e';
      print('🔐 [Play Integrity Controller] ❌ Integrity check failed with exception');
      print('🔐 [Play Integrity Controller] Error: $e');
      print('🔐 [Play Integrity Controller] Error type: ${e.runtimeType}');
      print('🔐 [Play Integrity Controller] Status: ${integrityStatus.value}');
      log('Play Integrity: Error during integrity check - $e');
    } finally {
      isLoading.value = false;
      print('🔐 [Play Integrity Controller] Loading set to false');
      print('🔐 [Play Integrity Controller] Final state - Loading: ${isLoading.value}, Verified: ${isIntegrityVerified.value}, Status: ${integrityStatus.value}');
    }
  }

  /// Refresh integrity token
  Future<void> refreshIntegrity() async {
    print('🔐 [Play Integrity Controller] Starting token refresh...');
    print('🔐 [Play Integrity Controller] Current loading state: ${isLoading.value}');
    
    isLoading.value = true;
    integrityStatus.value = 'Refreshing...';
    
    print('🔐 [Play Integrity Controller] Loading set to true, status: ${integrityStatus.value}');

    try {
      print('🔐 [Play Integrity Controller] Calling PlayIntegrityService.refreshIntegrityToken()...');
      final token = await PlayIntegrityService.refreshIntegrityToken();
      print('🔐 [Play Integrity Controller] Refresh result - Token: ${token != null ? "exists" : "null"}');
      
      if (token != null && token.isNotEmpty) {
        isIntegrityVerified.value = true;
        integrityStatus.value = 'Refreshed';
        lastToken.value = token;
        print('🔐 [Play Integrity Controller] ✅ Token refresh successful');
        print('🔐 [Play Integrity Controller] Status: ${integrityStatus.value}');
        print('🔐 [Play Integrity Controller] Token length: ${lastToken.value.length}');
        log('Play Integrity: Token refreshed successfully');
      } else {
        isIntegrityVerified.value = false;
        integrityStatus.value = 'Refresh failed';
        print('🔐 [Play Integrity Controller] ❌ Token refresh failed');
        print('🔐 [Play Integrity Controller] Status: ${integrityStatus.value}');
        log('Play Integrity: Token refresh failed');
      }
    } catch (e) {
      integrityStatus.value = 'Refresh error: $e';
      print('🔐 [Play Integrity Controller] ❌ Token refresh failed with exception');
      print('🔐 [Play Integrity Controller] Error: $e');
      print('🔐 [Play Integrity Controller] Error type: ${e.runtimeType}');
      print('🔐 [Play Integrity Controller] Status: ${integrityStatus.value}');
      log('Play Integrity: Error during token refresh - $e');
    } finally {
      isLoading.value = false;
      print('🔐 [Play Integrity Controller] Loading set to false');
      print('🔐 [Play Integrity Controller] Final state - Loading: ${isLoading.value}, Verified: ${isIntegrityVerified.value}, Status: ${integrityStatus.value}');
    }
  }

  /// Get current integrity token
  Future<String?> getCurrentToken() async {
    try {
      return await PlayIntegrityService.getIntegrityToken();
    } catch (e) {
      log('Play Integrity: Error getting current token - $e');
      return null;
    }
  }

  /// Verify integrity before sensitive operations
  Future<bool> verifyBeforeOperation(String operationName) async {
    print('🔐 [Play Integrity Controller] Verifying before operation: $operationName');
    log('Play Integrity: Verifying before operation: $operationName');
    
    print('🔐 [Play Integrity Controller] Calling PlayIntegrityService.verifyDeviceIntegrity()...');
    final isVerified = await PlayIntegrityService.verifyDeviceIntegrity();
    print('🔐 [Play Integrity Controller] Operation verification result: $isVerified');
    
    if (!isVerified) {
      print('🔐 [Play Integrity Controller] ❌ Operation blocked: $operationName');
      log('Play Integrity: Operation blocked - $operationName');
      // You can show a dialog or handle the failure here
      Get.snackbar(
        'Security Check Failed',
        'Device integrity verification failed. Please try again.',
        snackPosition: SnackPosition.TOP,
      );
    } else {
      print('🔐 [Play Integrity Controller] ✅ Operation allowed: $operationName');
    }
    
    return isVerified;
  }

  /// Check if integrity is currently valid
  bool get isCurrentlyVerified => PlayIntegrityService.isIntegrityVerified;

  /// Get the current status message
  String get currentStatus => integrityStatus.value;

  /// Get the last known token
  String get currentToken => lastToken.value;
} 