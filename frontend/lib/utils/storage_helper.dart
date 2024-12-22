// lib/utils/storage_helper.dart

import 'dart:html' as html;  // for web localStorage
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';

/// A helper that stores the 'adminToken' in localStorage (Web)
/// or in SharedPreferences (Mobile/Desktop).
class StorageHelper {
  static const String tokenKey = 'adminToken';

  /// Save the token
  static Future<void> saveToken(String? token) async {
    if (kIsWeb) {
      // On the web
      if (token == null) {
        html.window.localStorage.remove(tokenKey);
      } else {
        html.window.localStorage[tokenKey] = token;
      }
    } else {
      // On mobile/desktop
      final prefs = await SharedPreferences.getInstance();
      if (token == null) {
        await prefs.remove(tokenKey);
      } else {
        await prefs.setString(tokenKey, token);
      }
    }
  }

  /// Retrieve the token
  static Future<String?> getToken() async {
    if (kIsWeb) {
      return html.window.localStorage[tokenKey];
    } else {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(tokenKey);
    }
  }
}
