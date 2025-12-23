// dart format off
// coverage:ignore-file

// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get counterAppBarTitle => 'Counter';

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
