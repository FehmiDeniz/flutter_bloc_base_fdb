// ignore_for_file: unused_element

class ImageConstants {
  static ImageConstants? _instance;
  static ImageConstants get instance {
    _instance ??= ImageConstants._init();
    return _instance!;
  }

  ImageConstants._init();

  // Base, brand‑free placeholder assets
  final String loginLogo = "images/logo/app_logo".toSVG;

  final String splashLogo = "images/splash/splash".toPNG;
}

extension _ImageConstantsExtension on String {
  String get toPNG => 'assets/$this.png';
  String get upperPNG => 'assets/$this.PNG';
  String get toJPEG => 'assets/$this.jpeg';
  String get toJSON => 'assets/$this.json';
  String get toSVG => 'assets/$this.svg';
  String get toGif => 'assets/$this.gif';
}

extension NetworkImageConstants on String {
  String get svgFormat => 'assets/images/icons/$this';
}
