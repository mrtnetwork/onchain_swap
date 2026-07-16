import 'package:blockchain_utils/helper/helper.dart';
import 'package:blockchain_utils/service/models/params.dart';
import 'package:on_chain_swap/src/swap/core/core.dart';
import 'package:on_chain_swap/src/swap/services/thor/thor/utils.dart';
import 'package:on_chain_swap/src/swap/types/types.dart';
import 'package:on_chain_swap/src/swap/utils/utils.dart';
import 'package:cosmos_sdk/cosmos_sdk.dart';
import 'constants.dart';
import 'route.dart';

class ThorSwapService extends SwapService<
    BaseSwapAsset,
    IProvider<IServiceProvider, ThorNodeRequestDetails>,
    ThorSwapRoute,
    ThorQuoteSwapParams> {
  ThorSwapService(
      {required super.provider, super.service = SwapServiceType.thor});

  @override
  Future<List<BaseSwapAsset>> loadAssets() async {
    return ThorSwapConstants.assets;
  }

  ThorNodeRequestSwapQuote _createRequest(ThorQuoteSwapParams params,
      {int? streamingInterval = 1}) {
    return ThorNodeRequestSwapQuote(
        fromAsset: params.sourceAsset.providerIdentifier,
        toAsset: params.destinationAsset.providerIdentifier,
        amount: ThorSwapUtils.toAmountFromInput(
                amount: params.amount.amountString, asset: params.sourceAsset)
            .amount,
        streamingInterval: streamingInterval,
        fromAddress: SwapUtils.getFakeAddress(params.sourceAsset.network),
        destination: SwapUtils.getFakeAddress(params.destinationAsset.network));
  }

  Future<ThorSwapRoute?> _quote(ThorQuoteSwapParams params,
      {int? streamingInterval}) async {
    final request =
        _createRequest(params, streamingInterval: streamingInterval);
    try {
      final e = await provider.request(request);
      final assets = await loadAssets();
      final feeAsset = assets
          .firstWhereNullable((i) => i.providerIdentifier == e.fees.asset);
      final bps = ThorSwapUtils.ceilBpsToDouble(e.fees.totalBps);
      return ThorSwapRoute(
          expireTime: SwapUtils.secondsToDateTime(e.expiry),
          expectedAmount: ThorSwapUtils.toAmountFromBigInt(
              amount: e.expectedAmountOut, asset: params.destinationAsset),
          worstCaseAmount: ThorSwapUtils.calculateWorstCaseAmount(
              expectedAmount: e.expectedAmountOut, tolranceBps: bps),
          quote: params,
          tolerance: bps,
          interval: streamingInterval,
          route: e,
          estimateTime: SwapUtils.secondsToMinutes(e.totalSwapSeconds),
          provider: params.sourceAsset.provider,
          fees: ThorSwapUtils.buildQuoteFee(fees: e.fees, asset: feeAsset));
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<ThorSwapRoute>> createRoutes(ThorQuoteSwapParams params) async {
    List<ThorSwapRoute> quotes = [];
    final q1 = await _quote(params);
    final q2 = await _quote(params, streamingInterval: 1);
    if (q1 != null) {
      quotes.add(q1);
    }
    if (q2 != null &&
        q2.route.expectedAmountOut != quotes.last.route.expectedAmountOut) {
      quotes.add(q2);
    }
    if (q2 != null) {
      if (q2.route.maxStreamingQuantity > 1) {
        final quantities = <int>{
          q2.route.maxStreamingQuantity ~/ 2,
          q2.route.maxStreamingQuantity
        };
        for (final i in quantities) {
          final r = await _quote(params, streamingInterval: i);
          if (r == null ||
              r.route.expectedAmountOut ==
                  quotes.last.route.expectedAmountOut) {
            break;
          } else {
            quotes.add(r);
          }
        }
      }
    }
    return quotes;
  }

  @override
  Map<SwapNetwork, Set<BaseSwapAsset>> getDestAssets(BaseSwapAsset asset) {
    final allAssets = ThorSwapConstants.assets;
    List<BaseSwapAsset> assets = [];
    if (asset.provider.service == service || allAssets.contains(asset)) {
      assets = allAssets.clone();
    }
    final Map<SwapNetwork, Set<BaseSwapAsset>> networkAssets = {};
    for (final i in assets) {
      networkAssets[i.network] ??= {};
      networkAssets[i.network]?.add(i);
    }
    return networkAssets;
  }
}
