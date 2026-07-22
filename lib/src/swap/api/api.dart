import 'package:blockchain_utils/helper/helper.dart';
import 'package:blockchain_utils/utils/numbers/utils/bigint_utils.dart';
import 'package:on_chain_swap/src/swap/core/core.dart';
import 'package:on_chain_swap/src/swap/services/services.dart';
import 'package:on_chain_swap/src/swap/transaction/transaction.dart';
import 'package:on_chain_swap/src/swap/types/types.dart';
import 'package:on_chain_swap/src/swap/utils/utils.dart';

class SwapServiceApi {
  final Map<SwapServiceType, SwapService> _services;
  SwapServiceApi(Map<SwapServiceType, SwapService> services)
      : _services = services.immutable;
  Map<SwapServiceType, SwapService> get services => _services;
  static Future<SwapServiceApi> loadApi(BaseSwapServiceApiParams params) async {
    Map<SwapServiceType, SwapService> services = {};
    for (final s in params.services) {
      final SwapService? service = switch (s) {
        SwapServiceType.chainFlip => await params.loadChainFlipService(),
        SwapServiceType.maya => await params.loadMayaService(),
        SwapServiceType.thor => await params.loadThorService(),
        SwapServiceType.skipGo => await params.loadSkipGoService(),
        SwapServiceType.swapKit => await params.loadSwapKitService(),
      };
      if (service == null) continue;
      services[s] = service;
    }
    return SwapServiceApi(services);
  }

  final Map<SwapServiceType, Set<BaseSwapAsset>> _localAssets = {};

  Future<Map<SwapNetwork, Set<BaseSwapAsset>>> getSourceAssets(
      {bool skipServiceWhenFailed = true}) async {
    List<BaseSwapAsset> allAssets = [];
    for (final i in _services.entries) {
      try {
        final assets = await i.value.loadAssets();
        allAssets.addAll(assets);
        _localAssets[i.key] = assets.toImutableSet;
      } catch (_) {
        if (skipServiceWhenFailed) continue;
        rethrow;
      }
    }
    final Map<SwapNetwork, Set<BaseSwapAsset>> networkAssets = {};
    for (final i in allAssets) {
      networkAssets[i.network] ??= {};
      networkAssets[i.network]?.add(i);
    }
    return networkAssets.map((k, v) => MapEntry(k, SwapUtils.sortAssets(v)));
  }

  Map<SwapNetwork, Set<BaseSwapAsset>> getDestAssets(BaseSwapAsset asset) {
    final Map<SwapNetwork, Set<BaseSwapAsset>> networkAssets = {};
    for (final i in _services.values) {
      final assets = i.getDestAssets(asset);
      for (final entry in assets.entries) {
        networkAssets.update(entry.key, (e) => {...e, ...entry.value},
            ifAbsent: () => entry.value);
      }
    }
    return networkAssets.map((k, v) => MapEntry(k, SwapUtils.sortAssets(v)));
  }

  QuoteSwapParams<ASSET> createQuoteParams<ASSET extends BaseSwapAsset>(
      {required ASSET sourceAsset,
      required ASSET destAsset,
      required String amountIn,
      String? sourceAddress,
      String? destinationAddress}) {
    final amount = SwapAmount.fromString(amountIn, sourceAsset.decimal);
    return switch (sourceAsset.provider.service) {
      SwapServiceType.chainFlip => CfQuoteSwapParams(
          sourceAsset: sourceAsset.cast(),
          destinationAsset: destAsset.cast(),
          sourceAddress: sourceAddress,
          destinationAddress: destinationAddress,
          amount: amount),
      SwapServiceType.thor || SwapServiceType.maya => ThorQuoteSwapParams(
          sourceAsset: sourceAsset.cast(),
          destinationAsset: destAsset.cast(),
          sourceAddress: sourceAddress,
          destinationAddress: destinationAddress,
          amount: amount),
      SwapServiceType.skipGo => SkipGoQuoteSwapParams(
          sourceAsset: sourceAsset.cast(),
          destinationAsset: destAsset.cast(),
          sourceAddress: sourceAddress,
          destinationAddress: destinationAddress,
          amount: amount),
      SwapServiceType.swapKit => SwapKitQuoteSwapParams(
          sourceAsset: sourceAsset.cast(),
          destinationAsset: destAsset.cast(),
          sourceAddress: sourceAddress,
          destinationAddress: destinationAddress,
          amount: amount),
    } as QuoteSwapParams<ASSET>;
  }

  Future<List<RouteOrError>> findRoute<ASSET extends BaseSwapAsset>({
    required ASSET sourceAsset,
    required ASSET destinationAsset,
    required String amountIn,
    String? sourceAddress,
    String? destinationAddress,
  }) async {
    List<RouteOrError> routes = [];
    for (final i in _localAssets.entries) {
      final sAsset = i.value.firstWhereNullable((e) => e == sourceAsset);
      final destAsset = i.value.firstWhereNullable((e) => e == destinationAsset);
      final service = _services[i.key];
      if (sAsset == null || destAsset == null || service == null) {
        continue;
      }
      final params = createQuoteParams(
          sourceAsset: sAsset,
          destAsset: destAsset,
          amountIn: amountIn,
          sourceAddress: sourceAddress,
          destinationAddress: destinationAddress);
      try {
        final serviceRoutes = await service.createRoutes(params);
        routes.addAll(serviceRoutes
            .map((e) => RouteOrError.route(provider: sAsset.provider, route: e)));
      } catch (err) {
        routes.add(RouteOrError.error(provider: sAsset.provider, error: err));
      }
    }
    return routes;
  }

  Future<SwapRouteTransactionBuilder> builSwapTransaction({
    required String sourceAddress,
    required String destinationAddress,
    required SwapRoute swapRoute,
  }) async {
    final service = swapRoute.quote.sourceAsset.provider.service;
    SwapRouteGeneralTransactionBuilderParam params;
    if (service == SwapServiceType.chainFlip) {
      final cfRoute = swapRoute as CfSwapRoute;
      final swapService = _services[service]! as CfSwapService;
      final channel = await swapService.openDepositChannel(
        sourceAddress: sourceAddress,
        destinationAddress: destinationAddress,
        route: cfRoute,
        tolerance: cfRoute.tolerance,
      );
      params = SwapRouteCfGeneralTransactionBuilderParam(
          channel: channel,
          sourceAddress: sourceAddress,
          destinationAddress: destinationAddress,
          destionationNetwork: swapRoute.quote.destinationAsset.network,
          expireTime:
              DateTime.fromMillisecondsSinceEpoch(channel.estimatedExpiryTime.toInt()),
          sourceExpireBlock: BigintUtils.parse(channel.srcChainExpiryBlock));
    } else {
      params = SwapRouteGeneralTransactionBuilderParam(
          sourceAddress: sourceAddress,
          destinationAddress: destinationAddress,
          expireTime: swapRoute.expireTime);
    }
    return swapRoute.txBuilder(params);
  }
}
