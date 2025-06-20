import 'package:onchain_swap_example/app/types/types.dart';
import 'package:onchain_swap_example/future/state_managment/state_managment.dart';
import 'package:flutter/material.dart';

import 'animated/widgets/animated_switcher.dart';
import 'container_with_border.dart';
import 'copy_icon_widget.dart';
import 'widget_constant.dart';

class SecureContentView extends StatelessWidget {
  const SecureContentView(
      {this.content,
      required this.show,
      required this.onTapShow,
      this.widgetContent,
      this.showButtonTitle,
      this.contentName,
      super.key});
  final String? content;
  final Widget? widgetContent;
  final bool show;
  final DynamicVoid onTapShow;
  final String? showButtonTitle;
  final String? contentName;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          alignment: Alignment.center,
          foregroundDecoration: show
              ? null
              : BoxDecoration(
                  color: context.colors.secondary,
                  borderRadius: WidgetConstant.border8),
          child: widgetContent ??
              ContainerWithBorder(
                  child: CopyTextIcon(
                isSensitive: true,
                dataToCopy: content!,
                widget: SelectableText(
                  content!,
                  minLines: 1,
                  maxLines: 8,
                ),
              )),
        ),
        Positioned.fill(
          child: APPAnimatedSwitcher(enable: show, widgets: {
            true: (context) => WidgetConstant.sizedBox,
            false: (context) => FilledButton.icon(
                onPressed: onTapShow,
                icon: const Icon(Icons.remove_red_eye),
                label: Text(showButtonTitle ?? "show_private_key".tr))
          }),
        )
      ],
    );
  }
}
