// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `SpeachMe`
  String get appTitle {
    return Intl.message(
      'SpeachMe',
      name: 'appTitle',
      desc: '',
      args: [],
    );
  }

  /// `Login`
  String get login {
    return Intl.message(
      'Login',
      name: 'login',
      desc: '',
      args: [],
    );
  }

  /// `Login with Google`
  String get loginWithGoogle {
    return Intl.message(
      'Login with Google',
      name: 'loginWithGoogle',
      desc: '',
      args: [],
    );
  }

  /// `Stimmungskompass knowledge database`
  String get description {
    return Intl.message(
      'Stimmungskompass knowledge database',
      name: 'description',
      desc: '',
      args: [],
    );
  }

  /// `Search presentations...`
  String get searchHint {
    return Intl.message(
      'Search presentations...',
      name: 'searchHint',
      desc: '',
      args: [],
    );
  }

  /// `Unauthorized access!`
  String get unauthorizedAccess {
    return Intl.message(
      'Unauthorized access!',
      name: 'unauthorizedAccess',
      desc: '',
      args: [],
    );
  }

  /// `Sign-in canceled.`
  String get signInCanceled {
    return Intl.message(
      'Sign-in canceled.',
      name: 'signInCanceled',
      desc: '',
      args: [],
    );
  }

  /// `Login failed: {error}`
  String loginFailed(String error) {
    return Intl.message(
      'Login failed: $error',
      name: 'loginFailed',
      desc: '',
      args: [error],
    );
  }

  /// `Upload Presentation`
  String get uploadPresentation {
    return Intl.message(
      'Upload Presentation',
      name: 'uploadPresentation',
      desc: '',
      args: [],
    );
  }

  /// `Upload successful!`
  String get uploadSuccessful {
    return Intl.message(
      'Upload successful!',
      name: 'uploadSuccessful',
      desc: '',
      args: [],
    );
  }

  /// `Upload failed!`
  String get uploadFailed {
    return Intl.message(
      'Upload failed!',
      name: 'uploadFailed',
      desc: '',
      args: [],
    );
  }

  /// `No file selected.`
  String get noFileSelected {
    return Intl.message(
      'No file selected.',
      name: 'noFileSelected',
      desc: '',
      args: [],
    );
  }

  /// `Categories`
  String get categories {
    return Intl.message(
      'Categories',
      name: 'categories',
      desc: '',
      args: [],
    );
  }

  /// `Add Category`
  String get addCategory {
    return Intl.message(
      'Add Category',
      name: 'addCategory',
      desc: '',
      args: [],
    );
  }

  /// `Create New Category`
  String get createCategory {
    return Intl.message(
      'Create New Category',
      name: 'createCategory',
      desc: '',
      args: [],
    );
  }

  /// `Delete Category`
  String get deleteCategory {
    return Intl.message(
      'Delete Category',
      name: 'deleteCategory',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get cancel {
    return Intl.message(
      'Cancel',
      name: 'cancel',
      desc: '',
      args: [],
    );
  }

  /// `Create`
  String get create {
    return Intl.message(
      'Create',
      name: 'create',
      desc: '',
      args: [],
    );
  }

  /// `Delete`
  String get delete {
    return Intl.message(
      'Delete',
      name: 'delete',
      desc: '',
      args: [],
    );
  }

  /// `Assign to Category`
  String get assignToCategory {
    return Intl.message(
      'Assign to Category',
      name: 'assignToCategory',
      desc: '',
      args: [],
    );
  }

  /// `Select Category`
  String get selectCategory {
    return Intl.message(
      'Select Category',
      name: 'selectCategory',
      desc: '',
      args: [],
    );
  }

  /// `Assign`
  String get assign {
    return Intl.message(
      'Assign',
      name: 'assign',
      desc: '',
      args: [],
    );
  }

  /// `Stimmungskompass knowledge database`
  String get stimmungskompassDescription {
    return Intl.message(
      'Stimmungskompass knowledge database',
      name: 'stimmungskompassDescription',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'de'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
