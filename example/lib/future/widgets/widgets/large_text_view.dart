import 'package:onchain_swap_example/app/types/types.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:onchain_swap_example/future/state_managment/state_managment.dart';

import 'animated/widgets/animated_size.dart';

class LargeTextView extends StatefulWidget {
  const LargeTextView(
    this.text, {
    super.key,
    this.style,
    this.maxLine = 3,
    this.textAligen,
  });
  final List<String> text;
  final TextStyle? style;
  final int maxLine;
  final TextAlign? textAligen;
  @override
  State<LargeTextView> createState() => _LargeTextViewState();
}

class _LargeTextViewState extends State<LargeTextView> with SafeState {
  bool showMore = false;
  late String text = widget.text.join("\n");
  void onTap() {
    showMore = !showMore;
    setState(() {});
  }

  @override
  void didUpdateWidget(covariant LargeTextView oldWidget) {
    super.didUpdateWidget(oldWidget);
    final text = widget.text.join("\n");
    if (this.text != text) {
      this.text = text;
      updateState();
    }
  }

  @override
  Widget build(BuildContext context) {
    return APPAnimatedSize(
      isActive: showMore,
      onActive: (context) => _LargeTextWidget(
          text: text,
          onTap: onTap,
          showMore: showMore,
          maxLine: widget.maxLine,
          style: widget.style,
          textAligen: widget.textAligen),
      onDeactive: (context) => _LargeTextWidget(
          text: text,
          onTap: onTap,
          showMore: showMore,
          maxLine: widget.maxLine,
          style: widget.style,
          textAligen: widget.textAligen),
    );
  }
}

class _LargeTextWidget extends StatelessWidget {
  const _LargeTextWidget(
      {required this.text,
      this.style,
      this.textAligen,
      required this.onTap,
      required this.showMore,
      required this.maxLine});
  final String text;
  final TextStyle? style;
  final TextAlign? textAligen;
  final int maxLine;
  final bool showMore;
  final DynamicVoid onTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final span =
            TextSpan(text: text, style: style ?? context.textTheme.bodyMedium);
        final tp = TextPainter(
            text: span,
            textDirection: TextDirection.ltr,
            textAlign: textAligen ?? TextAlign.start);
        tp.layout(maxWidth: constraints.maxWidth);
        final List<ui.LineMetrics> lines = tp.computeLineMetrics();
        if (lines.length > maxLine && !showMore) {
          return InkWell(
            onTap: onTap,
            splashFactory: NoSplash.splashFactory,
            hoverColor: context.colors.transparent,
            child: Wrap(
              alignment: WrapAlignment.end,
              runAlignment: WrapAlignment.end,
              crossAxisAlignment: WrapCrossAlignment.end,
              children: [
                Text(
                  text,
                  maxLines: maxLine,
                  style: style,
                ),
                Text("read_more".tr,
                    style: context.textTheme.bodySmall
                        ?.copyWith(color: context.colors.tertiary))
              ],
            ),
          );
        }
        return GestureDetector(
            onTap: lines.length > maxLine ? onTap : null,
            child: Text(
              text,
              textAlign: textAligen,
              style: style,
            ));
      },
    );
  }
}
