import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class AppPreferences {
  static const String _keyPreferredLanguage = 'preferredLanguage';
  static const String _keyThemeMode = 'themeMode';
  static const String _keyNotificationsEnabled = 'notificationsEnabled';

  final SharedPreferences _prefs;

  AppPreferences(this._prefs);

  // Preferred Language
  Future<bool> setPreferredLanguage(String language) async {
    try {
      return await _prefs.setString(_keyPreferredLanguage, language);
    } catch (e) {
      return false;
    }
  }

  String getPreferredLanguage() {
    try {
      return _prefs.getString(_keyPreferredLanguage) ?? 'en';
    } catch (e) {
      return 'en';
    }
  }

  // Theme Mode (dark or light)
  Future<bool> setThemeMode(String themeMode) async {
    try {
      return await _prefs.setString(_keyThemeMode, themeMode);
    } catch (e) {
      return false;
    }
  }

  String getThemeMode() {
    try {
      return _prefs.getString(_keyThemeMode) ?? 'light';
    } catch (e) {
      return 'light';
    }
  }

  // Notifications Enabled
  Future<bool> setNotificationsEnabled(bool isEnabled) async {
    try {
      return await _prefs.setBool(_keyNotificationsEnabled, isEnabled);
    } catch (e) {
      return false;
    }
  }

  bool getNotificationsEnabled() {
    try {
      return _prefs.getBool(_keyNotificationsEnabled) ?? true;
    } catch (e) {
      return true;
    }
  }

  Future<void> initDefaults() async {
    if (!_prefs.containsKey(_keyPreferredLanguage)) {
      final String systemLanguage = await getSystemLanguage();
      await setPreferredLanguage(systemLanguage);
    }
    if (!_prefs.containsKey(_keyThemeMode)) {
      final String systemTheme = getSystemTheme();
      await setThemeMode(systemTheme);
    }
    if (!_prefs.containsKey(_keyNotificationsEnabled)) {
      await setNotificationsEnabled(true);
    }
  }

  Future<String> getSystemLanguage() async {
    try {
      final String systemLocale = Platform.localeName.split('_')[0];
      if (["ar", "fr", "en", "tn"].contains(systemLocale)) return systemLocale;
      return systemLocale;
    } catch (e) {
      return 'en';
    }
  }

  String getSystemTheme() {
    try {
      final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
      return brightness == Brightness.dark ? 'dark' : 'light';
    } catch (e) {
      return 'light';
    }
  }

  // Helper method to clear all preferences (for testing or reset functionality)
  Future<bool> clearAllPreferences() async {
    try {
      return await _prefs.clear();
    } catch (e) {
      return false;
    }
  }
}