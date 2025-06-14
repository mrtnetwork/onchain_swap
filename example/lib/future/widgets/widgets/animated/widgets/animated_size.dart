import 'package:onchain_swap_example/app/constants/constants.dart';
import 'package:onchain_swap_example/future/state_managment/state_managment.dart';
import 'package:flutter/material.dart';

class APPAnimatedSize extends StatelessWidget {
  const APPAnimatedSize(
      {required this.isActive,
      required this.onActive,
      required this.onDeactive,
      this.duration = APPConst.animationDuraion,
      this.alignment = Alignment.topCenter,
      super.key});
  final bool isActive;
  final WidgetContextNullable onActive;
  final WidgetContextNullable onDeactive;
  final Duration duration;
  final Alignment alignment;
  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: duration,
      alignment: alignment,
      child: isActive ? onActive(context) : onDeactive(context),
    );
  }
}

class APPAnimated extends StatelessWidget {
  const APPAnimated(
      {required this.isActive,
      required this.onActive,
      required this.onDeactive,
      this.duration = APPConst.animationDuraion,
      this.alignment = Alignment.topCenter,
      super.key});
  final bool isActive;
  final WidgetContextNullable onActive;
  final WidgetContextNullable onDeactive;
  final Duration duration;
  final Alignment alignment;
  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration,
      child: isActive ? onActive(context) : onDeactive(context),
    );
  }
}
