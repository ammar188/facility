// dart format off
// coverage:ignore-file

// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get counterAppBarTitle => 'Contador';

  @override
  String get chatCenter => 'Chat Center';

  @override
  String get noMessages => 'No messages yet';

  @override
  String get somethingWentWrong => 'Something went wrong';

  @override
  String get messageHint => 'Type a message...';

  @override
  String get warning => 'Warning';
}
