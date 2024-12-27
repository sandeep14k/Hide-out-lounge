import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferenceHelper {
  static String userIdKey = "USERKEY";
  static String userNameKey = "USERNAMEKEY";
  static String userEmailKey = "USEREMAILKEY";
  static String userWalletKey = "USERWALLETKEY";
  static String _imageKey = 'image_url';
  static const String _addressesKey = 'saved_addresses';

  /// Fetch saved addresses
  static Future<List<String>?> getSavedAddresses() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_addressesKey);
  }

  /// Save a new address
  static Future<void> saveAddress(String address) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> currentAddresses = prefs.getStringList(_addressesKey) ?? [];
    currentAddresses.add(address);
    await prefs.setStringList(_addressesKey, currentAddresses);
  }

  /// Clear all addresses (optional utility)
  static Future<void> clearAddresses() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_addressesKey);
  }

  Future<bool> saveUserId(String getUserId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(userIdKey, getUserId);
  }

  Future<void> saveImageUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_imageKey, url);
  }

  Future<bool> saveUserName(String getUserName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(userNameKey, getUserName);
  }

  Future<bool> saveUserEmail(String getUserEmail) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(userEmailKey, getUserEmail);
  }

  Future<bool> saveUserWallet(String getUserWallet) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(userWalletKey, getUserWallet);
  }

  Future<String?> getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(userIdKey);
  }

  Future<String?> getImageUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_imageKey);
  }

  Future<String?> getUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(userNameKey);
  }

  Future<String?> getUserEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(userEmailKey);
  }

  Future<String?> getUserWallet() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(userWalletKey);
  }
}
