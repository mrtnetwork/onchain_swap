import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:on_chain_bridge/platform_interface.dart';
import 'package:onchain_swap_example/app/constants/constants.dart';
import 'package:onchain_swap_example/app/constants/state.dart';
import 'package:onchain_swap_example/app/constants/storage_key.dart';
import 'package:onchain_swap_example/app/logging/logging.dart';
import 'package:onchain_swap_example/app/models/models/setting.dart';
import 'package:onchain_swap_example/future/pages/swap/controller/controller.dart';
import 'package:onchain_swap_example/future/router/router.dart';
import 'package:onchain_swap_example/future/widgets/widgets/scroll_behavior.dart';

import 'future/state_managment/state_managment.dart';
import 'future/theme/theme.dart';

Future<HomeStateController> _readSetting() async {
  final config = await PlatformInterface.instance.init(APPConst.applicationId);
  final query =
      await PlatformInterface.instance.readDb(APPDatabaseConst.appSettingQuery);
  final settings =
      APPSetting.deserialize(config: config, cborBytes: query?.data);
  final stateController = HomeStateController(appSetting: settings);
  await stateController.initSwap();
  return stateController;
}

void main() async {
  runZonedGuarded(_runApplication, (error, stack) {
    APPLogging.error("Guarded $error $stack");
  });
}

void _runApplication() async {
  WidgetsFlutterBinding.ensureInitialized();
  final setting = await _readSetting();
  ThemeController.fromAppSetting(setting.appSetting);

  runApp(StateRepository(child: OnChainSwap(setting)));
}

class OnChainSwap extends StatelessWidget {
  final HomeStateController controller;
  const OnChainSwap(this.controller, {super.key});

  @override
  Widget build(BuildContext context) {
    return MrtViewBuilder<HomeStateController>(
      controller: () => controller,
      removable: false,
      stateId: StateConst.main,
      repositoryId: StateConst.main,
      builder: (m) {
        final appPlatform = PlatformInterface.appPlatform;
        return MaterialApp(
            scaffoldMessengerKey: StateRepository.messengerKey(context),
            title: APPConst.name,
            scrollBehavior: AppScrollBehavior(platform: appPlatform),
            builder: (context, child) {
              ThemeController.updatePrimary(context.theme);
              return MediaQuery(
                  data: context.mediaQuery.copyWith(
                      textScaler: context.mediaQuery.textScaler
                          .clamp(maxScaleFactor: 1.4)),
                  child: child!);
            },
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            theme: ThemeController.appTheme,
            darkTheme: ThemeController.appTheme,
            locale: ThemeController.locale,
            onGenerateRoute: PageRouter.onGenerateRoute,
            initialRoute: PageRouter.home,
            navigatorObservers: [MyRouteObserver()],
            showSemanticsDebugger: false,
            debugShowCheckedModeBanner: false,
            color: ThemeController.appTheme.colorScheme.primary,
            navigatorKey: StateRepository.navigatorKey(context));
      },
    );
  }
}

class MyRouteObserver extends RouteObserver<PageRoute<dynamic>> {}
