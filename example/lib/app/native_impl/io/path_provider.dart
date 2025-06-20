import 'dart:io';
import 'package:onchain_swap_example/app/native_impl/core/core.dart';
import 'package:on_chain_bridge/models/path/path.dart';
import 'package:on_chain_bridge/platform_interface.dart';

mixin PathProvider {
  static AppPath? _path;
  static Future<AppPath> getPaths() async {
    _path ??= await AppNativeMethods.platform.path();
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

  static Future<String> toDocumentDir(String fileName) async {
    final path = await getPaths();
    final dir = Directory(path.document);

    return "${dir.path}/$fileName";
  }
}
