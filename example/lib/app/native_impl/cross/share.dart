import 'package:on_chain_bridge/platform_interface.dart';
import 'package:onchain_swap_example/app/native_impl/core/core.dart';

mixin ShareImpl {
  static Future<bool> shareFile(String path, String fileName,
      {String? text, String? subject, FileMimeTypes? mimeType}) async {
    if (PlatformInterface.isWindows) {
      return await AppNativeMethods.platform.launchUri(path);
    }

    return await AppNativeMethods.platform.share(Share.file(path, fileName,
        subject: subject, text: text, mimeType: mimeType));
  }
}
