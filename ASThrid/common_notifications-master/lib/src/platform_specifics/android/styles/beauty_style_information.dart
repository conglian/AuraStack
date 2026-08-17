import 'default_style_information.dart';

class BeautyStyleInformation extends DefaultStyleInformation {
  const BeautyStyleInformation(
      {this.title = "", this.body = "", this.image = "", this.button = "", this.appIcon = ""})
      : super(false, false);

  final String title;
  final String body;
  final String image;
  final String button;
  final String appIcon;
}
