import 'package:example/app/utils/method.dart';
import 'package:example/future/state_managment/state_managment.dart';
import 'package:example/future/widgets/widgets/progress_bar/widgets/progress_widgets.dart';
import 'package:flutter/material.dart';
import 'page_progress.dart';
import 'stream_bottun.dart';
export 'page_progress.dart';
export 'progress_widgets.dart';
export 'stream_bottun.dart';

extension QuickAccsessStreamButtonStateState on GlobalKey<StreamWidgetState> {
  bool get inProgress => currentState?.isProgress ?? false;
  void error({String? message}) {
    currentState?.errorProgress(message: message);
  }

  void success() {
    currentState?.updateStream(StreamWidgetStatus.success);
  }

  void idle() {
    currentState?.updateStream(StreamWidgetStatus.idle);
  }

  void fromMethodResult(MethodResult result) {
    if (result.hasError) {
      error(message: result.error!.tr);
    } else {
      success();
    }
  }

  void process() {
    currentState?.updateStream(StreamWidgetStatus.progress);
  }
}

extension QuickAccsessPageProgressState on GlobalKey<PageProgressBaseState> {
  void progress([Widget? progressWidget]) {
    currentState?.updateStream(StreamWidgetStatus.progress,
        progressWidget: progressWidget);
  }

  void progressText(String text, {Widget? bottomWidget, Widget? icon}) {
    currentState?.updateStream(StreamWidgetStatus.progress,
        progressWidget: ProgressWithTextView(
          text: text,
          bottomWidget: bottomWidget,
          icon: icon,
        ));
  }

  void error([Widget? progressWidget]) {
    currentState?.updateStream(StreamWidgetStatus.error,
        progressWidget: progressWidget);
  }

  void backToIdle([Widget? progressWidget]) {
    currentState?.updateStream(StreamWidgetStatus.idle);
  }

  void errorText(String text,
      {bool backToIdle = true, bool showBackButton = false}) {
    currentState?.updateStream(StreamWidgetStatus.error,
        progressWidget: ErrorWithTextView(
          text: text,
          progressKey: showBackButton ? this : null,
        ),
        backToIdle: backToIdle);
  }

  PageProgressStatus? get status => currentState?.status;
  bool get isSuccess => currentState?.status == PageProgressStatus.success;
  bool get hasError => currentState?.status == PageProgressStatus.error;

  bool get inProgress => currentState?.status == PageProgressStatus.progress;

  void success({Widget? progressWidget, bool backToIdle = true}) {
    currentState?.updateStream(StreamWidgetStatus.success,
        progressWidget: progressWidget, backToIdle: backToIdle);
  }

  void successProgress({Widget? progressWidget, bool backToIdle = true}) {
    currentState?.updateStream(StreamWidgetStatus.success,
        progressWidget: progressWidget ?? const CircularProgressIndicator(),
        backToIdle: backToIdle);
  }

  void successText(String text, {bool backToIdle = true}) {
    currentState?.updateStream(StreamWidgetStatus.success,
        progressWidget: SuccessWithTextView(
          text: text,
        ),
        backToIdle: backToIdle);
  }
}
