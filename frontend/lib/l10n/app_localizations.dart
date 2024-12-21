// lib/l10n/app_localizations.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../generated/intl/messages_all.dart';

class AppLocalizations {
  static Future<AppLocalizations> load(Locale locale) async {
    final String name =
        locale.countryCode?.isEmpty ?? false ? locale.languageCode : locale.toString();
    final String localeName = Intl.canonicalizedLocale(name);

    await initializeMessages(localeName);
    Intl.defaultLocale = localeName;
    return AppLocalizations();
  }

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  // Add your localized strings here

  // General
  String get appTitle => Intl.message('Academy', name: 'appTitle');

  String get login => Intl.message('Login', name: 'login');

  String get loginWithGoogle => Intl.message('Login with Google', name: 'loginWithGoogle');

  String get unauthorizedAccess => Intl.message('Unauthorized access!', name: 'unauthorizedAccess');

  String get signInCanceled => Intl.message('Sign-in canceled.', name: 'signInCanceled');

  String loginFailed(Object error) => Intl.message('Login failed: $error', name: 'loginFailed', args: [error]);

  // Upload
  String get uploadPresentation => Intl.message('Upload Presentation', name: 'uploadPresentation');

  String get uploadSuccessful => Intl.message('Upload successful!', name: 'uploadSuccessful');

  String get uploadFailed => Intl.message('Upload failed!', name: 'uploadFailed');

  String get noFileSelected => Intl.message('No file selected.', name: 'noFileSelected');

  // Categories
  String get categories => Intl.message('Categories', name: 'categories');

  String get addCategory => Intl.message('Add Category', name: 'addCategory');

  String get createCategory => Intl.message('Create New Category', name: 'createCategory');

  String get deleteCategory => Intl.message('Delete Category', name: 'deleteCategory');

  String get confirmDeleteCategory => Intl.message('Are you sure you want to delete', name: 'confirmDeleteCategory');

  String get cancel => Intl.message('Cancel', name: 'cancel');

  String get create => Intl.message('Create', name: 'create');

  String get delete => Intl.message('Delete', name: 'delete');

  String get assignToCategory => Intl.message('Assign to Category', name: 'assignToCategory');

  String get selectCategory => Intl.message('Select Category', name: 'selectCategory');

  String get assign => Intl.message('Assign', name: 'assign');

  // Dashboard
  String get stimmungskompassDescription => Intl.message('Stimmungskompass knowledge database', name: 'stimmungskompassDescription');

  String get searchHint => Intl.message('Search presentations...', name: 'searchHint');

  String get uploadedOn => Intl.message('Uploaded on', name: 'uploadedOn');

  // Additional messages (if any)
  // Add any other messages used in your code here

}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['en', 'de'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) =>
      AppLocalizations.load(locale);

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
