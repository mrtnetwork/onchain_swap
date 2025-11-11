import 'package:onchain_swap_example/app/image/image.dart';

class APPConst {
  static const String name = "OnChain Swap";
  static final APPImage logo = APPImage.local("assets/image/mrt_wallet.png");
  static const Duration animationDuraion = Duration(milliseconds: 400);
  static const Duration milliseconds100 = Duration(milliseconds: 100);
  static const Duration oneSecoundDuration = Duration(seconds: 1);
  static const Duration twoSecoundDuration = Duration(seconds: 2);
  static const Duration tenSecoundDuration = Duration(seconds: 10);
  static const String homepage = 'https://github.com/mrtnetwork/onchain_swap';
  static const String applicationId = "com.mrtnetwork.on_chain_swap";
  static const double double80 = 80;
  static const double double40 = 40;
  static const double double20 = 20;
  static const double iconSize = 24;
  static const double largeIconSize = 80;
  static const double tooltipConstrainedWidth = 300;
  static const double dialogWidth = 650;
  static const double maxViewWidth = 650;
  static const double maxDialogHeight = 600;
  static const double maxTextFieldWidth = 400;
  static const double qrCodeWidth = 300;
  static const int maxNameLength = 20;
  static final RegExp accountNameRegExp = RegExp(r'^[^\n]{0,20}$');
  static final RegExp keyNameRegex = RegExp(r'^[^\n]{0,20}$');
  static final RegExp hex32Bytes = RegExp(r'^(0x)?[0-9a-fA-F]{64}$');
  static final hrpRegex = RegExp(r'^[a-z][a-z0-9]*$');
  static const double circleRadius25 = 25;
  static const double circleRadius10 = 10;
  static const double elevation = 2;
  static const double desktopAppWidth = 1200;
  static const double desktopAppHeight = 768;
  static const double naviationRailWidth = 80;
  static const String exampleBase58 = "sEd7FSsSXz9CGy....";
  static const String exampleBase32 = "GD2YLIOLNVQXNA....";
  static const String exampleHex = "0xa3f1df47";

  static const String exampleAuthenticatedHeader = "Authorization";
  static const String exampleAuthenticatedQuery = "api_key";
  static const String exampleDouble = "0.0025";

  static const String exampleAuthenticatedHeaderValue =
      "Basic QWxhZGRpbjpvcGVuIHNlc2FtZQ==";
  static const String exampleAuthenticatedQueryValue = "api_key";

  static const String exampleAuthenticatedDigestAuthRealm = "monero-rpc";
  static const String exampleChannelId = "channel-1441";
  static const int defaultDecimalPlaces = 8;

  static const int maximumHeaderValue = 400;

  static const double largeCircleRadius = 60;
}
