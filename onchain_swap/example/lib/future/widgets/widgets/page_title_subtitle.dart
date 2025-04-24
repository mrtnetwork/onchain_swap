import 'package:example/future/state_managment/state_managment.dart';
import 'package:flutter/material.dart';
import 'widget_constant.dart';

class PageTitleSubtitle extends StatelessWidget {
  const PageTitleSubtitle(
      {super.key,
      required this.title,
      required this.body,
      this.subtitle,
      this.titleStyle});
  final String? title;
  final Widget body;
  final String? subtitle;
  final TextStyle? titleStyle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null)
          Text(title ?? "", style: titleStyle ?? context.textTheme.titleLarge),
        Padding(
          padding: title == null ? EdgeInsets.zero : WidgetConstant.padding10,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (subtitle != null)
                Text(
                  subtitle ?? "",
                  style: context.textTheme.labelLarge,
                ),
              Padding(
                padding: WidgetConstant.padding5,
                child: body,
              )
            ],
          ),
        ),
      ],
    );
  }
}
