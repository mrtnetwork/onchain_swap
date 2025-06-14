import 'package:onchain_swap_example/app/constants/constants.dart';
import 'package:onchain_swap_example/app/types/types.dart';
import 'package:onchain_swap_example/app/utils/method.dart';
import 'package:onchain_swap_example/app/utils/platform/utils.dart';
import 'package:onchain_swap_example/future/state_managment/state_managment.dart';
import 'package:flutter/material.dart';

class PasteTextIcon extends StatefulWidget {
  const PasteTextIcon(
      {required this.onPaste,
      required this.isSensitive,
      super.key,
      this.size,
      this.color});
  final StringVoid onPaste;
  final double? size;
  final Color? color;
  final bool isSensitive;

  @override
  State<PasteTextIcon> createState() => PasteTextIconState();
}

class PasteTextIconState extends State<PasteTextIcon>
    with SafeState<PasteTextIcon> {
  bool inPaste = false;
  void onTap() async {
    if (inPaste) return;
    inPaste = true;
    setState(() {});
    try {
      final data = await PlatformUtils.readClipboard();
      if (!mounted) return;
      final String txt = data ?? "";
      if (txt.isEmpty) {
        // if (context.mounted) {
        //   context.showAlert("clipboard_empty".tr);
        // }
        await Future.delayed(APPConst.milliseconds100);
        return;
      }
      widget.onPaste(txt);
      _resetClipoard(txt);
      await Future.delayed(APPConst.oneSecoundDuration);
    } finally {
      inPaste = false;
      updateState(() {});
    }
  }

  void _resetClipoard(String txt) {
    if (!widget.isSensitive) return;
    MethodUtils.after(() async {
      final data = await PlatformUtils.readClipboard();
      if (data != txt) return;
      PlatformUtils.writeClipboard('');
    }, duration: APPConst.tenSecoundDuration);
  }

  @override
  Widget build(BuildContext context) {
    final icon = Icon(
      inPaste ? Icons.check_circle : Icons.paste,
      size: widget.size,
      key: ValueKey<bool>(inPaste),
      color: widget.color,
    );
    return IconButton(
      onPressed: onTap,
      icon: AnimatedSwitcher(duration: APPConst.animationDuraion, child: icon),
    );
  }
}
