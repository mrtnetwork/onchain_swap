import 'package:example/app/types/types.dart';
import 'package:example/future/state_managment/state_managment.dart';
import 'package:example/future/widgets/widgets/widget_constant.dart';
import 'package:flutter/material.dart';

class AppListTile extends StatelessWidget {
  const AppListTile(
      {super.key,
      this.title,
      this.subtitle,
      this.trailing,
      this.leading,
      this.onTap,
      this.contentPadding,
      this.tileColor,
      this.enabled = true,
      this.selected = false,
      this.disabled = false,
      this.maxLine = 2});
  final Widget? title;
  final Widget? subtitle;
  final Widget? trailing;
  final Widget? leading;
  final DynamicVoid? onTap;
  final EdgeInsetsGeometry? contentPadding;
  final Color? tileColor;
  final bool enabled;
  final bool selected;
  final bool disabled;
  final int maxLine;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: title == null
          ? null
          : DefaultTextStyle(
              style: context.textTheme.labelLarge!, child: title!),
      subtitle: subtitle == null
          ? null
          : DefaultTextStyle(
              style: context.textTheme.bodyMedium!,
              maxLines: maxLine,
              overflow: TextOverflow.ellipsis,
              child: subtitle!,
            ),
      trailing: trailing,
      leading: leading,
      onTap: onTap,
      contentPadding: contentPadding,
      tileColor: tileColor,
      enabled: enabled,
      selected: selected,
    );
  }
}

class AppCheckListTile extends StatelessWidget {
  const AppCheckListTile(
      {super.key,
      this.onChanged,
      required this.value,
      this.title,
      this.subtitle,
      this.contentPadding,
      this.maxLine = 2});
  final int? maxLine;
  final NullBoolVoid? onChanged;
  final bool value;
  final Widget? title;
  final Widget? subtitle;
  final EdgeInsets? contentPadding;
  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      onChanged: onChanged,
      value: value,
      contentPadding: contentPadding,
      title: title == null
          ? null
          : DefaultTextStyle(
              style: context.textTheme.labelLarge!, child: title!),
      subtitle: subtitle == null
          ? null
          : DefaultTextStyle(
              style: context.textTheme.bodyMedium!,
              maxLines: maxLine,
              overflow: TextOverflow.ellipsis,
              child: subtitle!,
            ),
    );
  }
}

class AppRadioListTile<T> extends StatelessWidget {
  const AppRadioListTile(
      {super.key,
      required this.groupValue,
      this.onChanged,
      required this.value,
      this.title,
      this.subtitle});
  final void Function(T? value)? onChanged;
  final T value;
  final Widget? title;
  final Widget? subtitle;
  final T? groupValue;
  @override
  Widget build(BuildContext context) {
    return RadioListTile<T>(
      onChanged: onChanged,
      groupValue: groupValue,
      value: value,
      title: title == null
          ? null
          : DefaultTextStyle(
              style: context.textTheme.labelLarge!, child: title!),
      subtitle: subtitle == null
          ? null
          : DefaultTextStyle(
              style: context.textTheme.bodyMedium!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              child: subtitle!,
            ),
    );
  }
}

class AppSwitchListTile extends StatelessWidget {
  const AppSwitchListTile(
      {super.key,
      this.onChanged,
      required this.value,
      this.title,
      this.subtitle,
      this.maxLine = 2,
      this.contentPadding});
  final NullBoolVoid? onChanged;
  final bool value;
  final Widget? title;
  final Widget? subtitle;
  final int? maxLine;
  final EdgeInsets? contentPadding;
  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      onChanged: onChanged,
      contentPadding: contentPadding,
      value: value,
      title: title == null
          ? null
          : DefaultTextStyle(
              style: context.textTheme.bodyMedium!
                  .copyWith(fontWeight: FontWeight.bold),
              child: title!),
      subtitle: subtitle == null
          ? null
          : DefaultTextStyle(
              style: context.textTheme.bodyMedium!,
              maxLines: maxLine,
              overflow: TextOverflow.ellipsis,
              child: subtitle!,
            ),
    );
  }
}

class APPExpansionListTile extends StatelessWidget {
  const APPExpansionListTile(
      {required this.title,
      this.expandedCrossAxisAlignment,
      this.subtitle,
      this.trailing,
      this.children = const <Widget>[],
      this.tilePadding,
      this.onExpansionChanged,
      this.color,
      this.reverse,
      this.radius,
      this.initiallyExpanded = false,
      super.key});
  final Widget title;
  final Widget? subtitle;
  final Widget? trailing;
  final List<Widget> children;
  final EdgeInsetsGeometry? tilePadding;
  final BoolVoid? onExpansionChanged;
  final Color? color;
  final Color? reverse;
  final BorderRadius? radius;
  final bool initiallyExpanded;
  final CrossAxisAlignment? expandedCrossAxisAlignment;
  @override
  Widget build(BuildContext context) {
    final border = radius ?? WidgetConstant.border8;
    return ExpansionTile(
        initiallyExpanded: initiallyExpanded,
        shape: RoundedRectangleBorder(borderRadius: border),
        collapsedShape: RoundedRectangleBorder(borderRadius: border),
        backgroundColor: color ?? context.primaryContainer,
        collapsedBackgroundColor: color ?? context.primaryContainer,
        tilePadding: tilePadding,
        collapsedIconColor: reverse ?? context.onPrimaryContainer,
        iconColor: reverse ?? context.onPrimaryContainer,
        title: title,
        subtitle: subtitle,
        trailing: trailing,
        expandedCrossAxisAlignment: expandedCrossAxisAlignment,
        onExpansionChanged: onExpansionChanged,
        children: children);
  }
}

class APPCheckBox extends StatelessWidget {
  const APPCheckBox(
      {super.key,
      this.ignoring = false,
      this.color,
      this.value,
      this.onChanged,
      this.activePress = true,
      this.backgroundColor});
  final bool ignoring;
  final Color? color;
  final Color? backgroundColor;
  final bool? value;
  final NullBoolVoid? onChanged;
  final bool activePress;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: ignoring,
      child: Checkbox(
        fillColor: backgroundColor == null
            ? null
            : WidgetStatePropertyAll(backgroundColor),
        checkColor: color,
        activeColor: backgroundColor,
        value: value,
        onChanged: activePress ? onChanged : null,
      ),
    );
  }
}
