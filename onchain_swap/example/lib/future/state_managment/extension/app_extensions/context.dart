import 'package:example/app/constants/state.dart';
import 'package:example/future/pages/swap/controller/controller.dart';
import 'package:example/future/state_managment/state_managment.dart';
import 'package:example/future/theme/theme.dart';
import 'package:example/future/widgets/custom_widgets.dart';
import 'package:flutter/material.dart';

extension CustomColorsSchame on ColorScheme {
  Color get disable => onSurface.wOpacity(0.38);
  Color get orange => Colors.orange;
  Color get green => Colors.green;
  Color get transparent => Colors.transparent;
}

extension QuickColor on Color {
  Color wOpacity(double opacity) {
    assert(opacity >= 0.0 && opacity <= 1.0);
    return withAlpha((255.0 * opacity).round());
  }

  TextStyle? titleLarge(BuildContext context) {
    return context.textTheme.titleLarge?.copyWith(color: this);
  }

  TextStyle? titleMedium(BuildContext context) {
    return context.textTheme.titleMedium?.copyWith(color: this);
  }

  TextStyle? bodyMedium(BuildContext context) {
    return context.textTheme.bodyMedium?.copyWith(color: this);
  }

  TextStyle? bodySmall(BuildContext context) {
    return context.textTheme.bodySmall?.copyWith(color: this);
  }

  TextStyle? lableLarge(BuildContext context) {
    return context.textTheme.labelLarge?.copyWith(color: this);
  }

  Color get opacity5 {
    return wOpacity(0.5);
  }

  Color get opacity1 {
    return wOpacity(0.1);
  }
}

extension QuickContextAccsess on BuildContext {
  T watch<T extends StateController>(String stateId) {
    return StateRepository.stateOf(this, stateId)!;
  }

  HomeStateController get mainController => watch(StateConst.main);
  T watchOrCreate<T extends StateController>(
      {required String stateId, required T Function() controller}) {
    return StateRepository.stateOfCreate(this, stateId, controller)!;
  }

  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => theme.textTheme;
  ColorScheme get colors => theme.colorScheme;
  Color get onPrimaryContainer => colors.onPrimaryContainer;
  Color get primaryContainer => colors.primaryContainer;
  TextTheme get onPrimaryTextTheme => ThemeController.onPrimary;
  TextTheme get primaryTextTheme => ThemeController.primary;
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  bool get hasFocus => FocusScope.of(this).hasFocus;
  bool get hasParentFocus => FocusScope.of(this).parent?.hasFocus ?? false;
  void mybePop() {
    if (mounted) Navigator.maybeOf(this);
  }

  void clearFocus() {
    if (mounted) {
      FocusScope.of(this).unfocus();
    }
  }

  Future<T?> to<T>(String? path, {dynamic argruments}) async {
    if (path == null) {
      showAlert('page_not_found'.tr);
      return null;
    }
    if (mounted) {
      final push = await Navigator.pushNamed(this, path, arguments: argruments);
      return (push as T?);
    }
    return null;
  }

  Future<T?> mybeTo<T>(String? path, {dynamic argruments}) async {
    if (path != null && mounted) {
      final push = await Navigator.pushNamed(this, path, arguments: argruments);
      return (push as T?);
    }
    return null;
  }

  Future<T?> toPage<T>(Widget page, {dynamic argruments}) async {
    if (mounted) {
      final push = await Navigator.push(
          this, MaterialPageRoute(builder: (context) => page));
      return (push as T?);
    }
    return null;
  }

  bool toSync(String path, {dynamic argruments}) {
    if (!mounted) return false;
    Navigator.pushNamed(this, path, arguments: argruments);
    return true;
  }

  Future<T?> offTo<T>(String path, {dynamic argruments}) async {
    if (mounted) {
      final push =
          Navigator.popAndPushNamed<T, T>(this, path, arguments: argruments);
      return push;
    }
    return null;
  }

  void showAlert(String message) {
    final sc = StateRepository.messengerKey(this);
    SnackBar snackBar;
    snackBar = createSnackAlert(
      message: message,
      theme: theme,
      onTap: () {
        sc.currentState?.clearSnackBars();
      },
    );
    sc.currentState?.showSnackBar(snackBar);
  }

  void showError(String message) {
    final sc = StateRepository.messengerKey(this);
    SnackBar snackBar;
    snackBar = SnackBar(
      // action: SnackBarAction(label: '', onPressed: onPressed),
      content: Text(
        message,
        style: textTheme.bodyMedium?.copyWith(color: colors.onError),
      ),
      backgroundColor: colors.error,
    );
    sc.currentState?.showSnackBar(snackBar);
  }

  Future<T?> openSliverBottomSheet<T>(String label,
      {
      // double maxExtend = 1,
      Widget? child,
      // double? initialExtend,
      BodyBuilder? bodyBuilder,
      List<Widget> Function(BuildContext context)? appbarActions,
      List<Widget> slivers = const [],
      bool centerContent = true}) async {
    // if (minExtent > maxExtend) {
    //   minExtent = maxExtend;
    // }
    if (!mounted) return null;
    return await showModalBottomSheet<T>(
      context: this,
      constraints: const BoxConstraints(maxWidth: 900),
      builder: (context) => AppBottomSheet(
        label: label,
        body: bodyBuilder,
        actions: appbarActions?.call(context) ?? [],
        minExtent: 0.8,
        maxExtend: 1.0,
        centerContent: centerContent,
        slivers: slivers,
        initiaalExtend: 0.9,
        child: child,
      ),
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
    );
  }

  Future<T?> openSliverDialog<T>({
    required String label,
    List<Widget> Function(BuildContext)? actions,
    WidgetContext? widget,
    WidgetContext? sliver,
    double? maxWidth,
  }) async {
    return await showAdaptiveDialog(
      context: this,
      useRootNavigator: true,
      barrierDismissible: true,
      builder: (context) {
        return DialogView(
          title: label,
          maxWidth: maxWidth,
          actions: actions?.call(context) ?? const [],
          widget: widget?.call(context),
          sliver: sliver?.call(context),
        );
      },
    );
  }

  Future<T?> openDialogPage<T>({
    required String label,
    WidgetContext? child,
    List<Widget> Function(BuildContext)? actions,
    Widget? fullWidget,
  }) async {
    return await showAdaptiveDialog(
      context: this,
      useRootNavigator: true,
      barrierDismissible: true,
      builder: (context) {
        return fullWidget ??
            DialogView(
                title: label,
                actions: actions?.call(context) ?? const [],
                child: child?.call(context) ?? WidgetConstant.sizedBox);
      },
    );
  }

  void pop<T>([T? result]) {
    if (mounted) {
      Navigator.of(this).pop(result);
    }
  }

  void opoA<T>([T? result]) {
    if (mounted) {
      Navigator.of(this).pop(result);
    }
  }

  T? getNullArgruments<T>() {
    final args = ModalRoute.of(this)?.settings.arguments;
    if (args == null) return null;
    if (args.runtimeType != T) {
      return null;
    }
    return args as T?;
  }

  T getArgruments<T>() {
    final args = ModalRoute.of(this)?.settings.arguments;
    if (args == null) {
      throw StateError("argruments not found");
    }

    return args as T;
  }

  dynamic getDynamicArgs() {
    final args = ModalRoute.of(this)?.settings.arguments;
    if (args == null) {
      throw StateError("argruments not found");
    }

    return args;
  }

  void popToHome() {
    Navigator.of(this).popUntil((route) {
      return route.isFirst;
    });
  }

  BuildContext? get scaffoldContext =>
      StateRepository.scaffoldKey(this).currentContext;

  GlobalKey<ScaffoldState> get scaffoldKey => StateRepository.scaffoldKey(this);

  GlobalKey<NavigatorState> get navigatorKey =>
      StateRepository.navigatorKey(this);
  ModalRoute? route() {
    return ModalRoute.of(this);
  }
}
