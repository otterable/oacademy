// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a de locale. All the
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
  String get localeName => 'de';

  static String m0(error) => "Anmeldung fehlgeschlagen: ${error}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "addCategory":
            MessageLookupByLibrary.simpleMessage("Kategorie hinzufügen"),
        "appTitle": MessageLookupByLibrary.simpleMessage("SpeachMe"),
        "assign": MessageLookupByLibrary.simpleMessage("Zuweisen"),
        "assignToCategory":
            MessageLookupByLibrary.simpleMessage("Zu Kategorie zuweisen"),
        "cancel": MessageLookupByLibrary.simpleMessage("Abbrechen"),
        "categories": MessageLookupByLibrary.simpleMessage("Kategorien"),
        "create": MessageLookupByLibrary.simpleMessage("Erstellen"),
        "createCategory":
            MessageLookupByLibrary.simpleMessage("Neue Kategorie erstellen"),
        "delete": MessageLookupByLibrary.simpleMessage("Löschen"),
        "deleteCategory":
            MessageLookupByLibrary.simpleMessage("Kategorie löschen"),
        "description": MessageLookupByLibrary.simpleMessage(
            "Stimmungskompass Wissensdatenbank"),
        "login": MessageLookupByLibrary.simpleMessage("Anmelden"),
        "loginFailed": m0,
        "loginWithGoogle":
            MessageLookupByLibrary.simpleMessage("Mit Google anmelden"),
        "noFileSelected":
            MessageLookupByLibrary.simpleMessage("Keine Datei ausgewählt."),
        "searchHint":
            MessageLookupByLibrary.simpleMessage("Präsentationen suchen..."),
        "selectCategory":
            MessageLookupByLibrary.simpleMessage("Kategorie auswählen"),
        "signInCanceled":
            MessageLookupByLibrary.simpleMessage("Anmeldung abgebrochen."),
        "stimmungskompassDescription": MessageLookupByLibrary.simpleMessage(
            "Stimmungskompass Wissensdatenbank"),
        "unauthorizedAccess":
            MessageLookupByLibrary.simpleMessage("Unbefugter Zugriff!"),
        "uploadFailed":
            MessageLookupByLibrary.simpleMessage("Upload fehlgeschlagen!"),
        "uploadPresentation":
            MessageLookupByLibrary.simpleMessage("Präsentation hochladen"),
        "uploadSuccessful":
            MessageLookupByLibrary.simpleMessage("Upload erfolgreich!")
      };
}
