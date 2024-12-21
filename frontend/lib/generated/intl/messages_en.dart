// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en';

  static String m0(error) => "Login failed: ${error}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "addCategory": MessageLookupByLibrary.simpleMessage("Add Category"),
        "appTitle": MessageLookupByLibrary.simpleMessage("SpeachMe"),
        "assign": MessageLookupByLibrary.simpleMessage("Assign"),
        "assignToCategory":
            MessageLookupByLibrary.simpleMessage("Assign to Category"),
        "cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
        "categories": MessageLookupByLibrary.simpleMessage("Categories"),
        "create": MessageLookupByLibrary.simpleMessage("Create"),
        "createCategory":
            MessageLookupByLibrary.simpleMessage("Create New Category"),
        "delete": MessageLookupByLibrary.simpleMessage("Delete"),
        "deleteCategory":
            MessageLookupByLibrary.simpleMessage("Delete Category"),
        "description": MessageLookupByLibrary.simpleMessage(
            "Stimmungskompass knowledge database"),
        "login": MessageLookupByLibrary.simpleMessage("Login"),
        "loginFailed": m0,
        "loginWithGoogle":
            MessageLookupByLibrary.simpleMessage("Login with Google"),
        "noFileSelected":
            MessageLookupByLibrary.simpleMessage("No file selected."),
        "searchHint":
            MessageLookupByLibrary.simpleMessage("Search presentations..."),
        "selectCategory":
            MessageLookupByLibrary.simpleMessage("Select Category"),
        "signInCanceled":
            MessageLookupByLibrary.simpleMessage("Sign-in canceled."),
        "stimmungskompassDescription": MessageLookupByLibrary.simpleMessage(
            "Stimmungskompass knowledge database"),
        "unauthorizedAccess":
            MessageLookupByLibrary.simpleMessage("Unauthorized access!"),
        "uploadFailed": MessageLookupByLibrary.simpleMessage("Upload failed!"),
        "uploadPresentation":
            MessageLookupByLibrary.simpleMessage("Upload Presentation"),
        "uploadSuccessful":
            MessageLookupByLibrary.simpleMessage("Upload successful!")
      };
}
