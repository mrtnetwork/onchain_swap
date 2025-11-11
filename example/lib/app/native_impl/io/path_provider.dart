import 'dart:io';

import 'package:on_chain_bridge/platform_interface.dart';
import 'package:onchain_swap_example/app/constants/constants.dart';
import 'package:onchain_swap_example/app/native_impl/core/core.dart';

mixin PathProvider {
  static AppPath? _path;
  static Future<AppPath> getPaths() async {
    _path ??= await AppNativeMethods.platform.path(APPConst.applicationId);
    return _path!;
  }

  static String _join(String path, String name) {
    if (path.endsWith("/") || path.endsWith(r"\")) return "$path$name";
    if (PlatformInterface.isWindows) {
      return path + r'\' + name;
    }
    return "$path/$name";
  }

  static Future<String> toCacheDir(String fileName) async {
    final path = await getPaths();
    final dir = Directory(path.cache);
    return _join(dir.path, fileName);
  }
}
