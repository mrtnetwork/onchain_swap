import 'package:example/app/constants/constants.dart';
import 'package:example/app/utils/method.dart';
import 'package:example/future/state_managment/state_managment.dart';
import 'package:example/future/widgets/widgets/animated/animation.dart';
import 'package:example/future/widgets/widgets/constraints_box_view.dart';
import 'package:example/future/widgets/widgets/widget_constant.dart';
import 'package:flutter/material.dart';

import 'stream_bottun.dart';

typedef PageProgressStatus = StreamWidgetStatus;

abstract class PageProgressBaseState<T extends StatefulWidget> extends State<T>
    with SafeState {
  abstract PageProgressStatus _status;
  abstract Widget? _statusWidget;
  abstract final FuncWidgetContext child;
  Widget? get statusWidget => _statusWidget;
  Duration? get backToIdle;

  PageProgressStatus get status => _status;
  Widget? _child;

  void _listen(PageProgressStatus status) async {
    if (backToIdle == null) return;
    if (status == PageProgressStatus.progress ||
        status == PageProgressStatus.idle) {
      return;
    }
    await Future.delayed(backToIdle ?? Duration.zero);
    updateStream(PageProgressStatus.idle, progressWidget: null);
  }

  @override
  void dispose() {
    super.dispose();
    _statusWidget = null;
    _child = null;
  }

  void updateStream(PageProgressStatus status,
      {Widget? progressWidget, bool backToIdle = true}) {
    if (closed || !mounted) return;
    _status = status;
    _statusWidget = progressWidget;
    if (backToIdle) {
      _listen(status);
    }
    setState(() {});
  }

  @override
  void didUpdateWidget(covariant T oldWidget) {
    super.didUpdateWidget(oldWidget);
  }
}

class PageProgress extends StatefulWidget {
  const PageProgress(
      {super.key,
      required this.child,
      this.initialStatus = PageProgressStatus.idle,
      this.backToIdle,
      this.initialWidget});
  final PageProgressStatus initialStatus;
  final FuncWidgetContext child;
  final Duration? backToIdle;
  final Widget? initialWidget;

  @override
  State<PageProgress> createState() => PageProgressState();
}

class PageProgressState extends PageProgressBaseState<PageProgress> {
  @override
  late PageProgressStatus _status = widget.initialStatus;
  @override
  late Widget? _statusWidget = widget.initialWidget;
  @override
  Duration? get backToIdle => widget.backToIdle;

  @override
  void dispose() {
    super.dispose();
    _statusWidget = null;
  }

  @override
  Widget build(BuildContext context) {
    return APPAnimatedSwitcher(
      duration: APPConst.animationDuraion,
      enable: _status,
      widgets: {
        PageProgressStatus.idle: (c) => FutureBuilder(
              future: MethodUtils.after(() async => widget.child(c)),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: WidgetConstant.errorIconLarge);
                }
                if (snapshot.hasData) {
                  _child = snapshot.data!;
                }
                return _child ?? WidgetConstant.sizedBox;
              },
            ),
        PageProgressStatus.success: (c) => PageProgressChildWidget(
            _statusWidget ?? WidgetConstant.checkCircleLarge),
        PageProgressStatus.error: (c) => PageProgressChildWidget(
            _statusWidget ?? WidgetConstant.errorIconLarge),
        PageProgressStatus.progress: (c) => PageProgressChildWidget(
            _statusWidget ?? const CircularProgressIndicator()),
      },
    );
  }

  @override
  FuncWidgetContext get child => widget.child;
}

class PageProgressChildWidget extends StatelessWidget {
  const PageProgressChildWidget(this.statusWidget, {super.key});
  final Widget statusWidget;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ConstraintsBoxView(
            padding: WidgetConstant.paddingHorizontal20,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [statusWidget]),
          ),
        ),
      ],
    );
  }
}
