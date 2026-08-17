import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final class ForegroundStyleInformation extends DefaultStyleInformation {
  final String value;
  final String image;
  const ForegroundStyleInformation({required this.value,required this.image}) : super(false, false);
}
