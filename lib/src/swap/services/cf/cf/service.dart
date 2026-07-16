import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:on_chain_swap/src/exception/exception.dart';
import 'package:on_chain_swap/src/providers/cf/provider.dart';
import 'package:on_chain_swap/src/swap/constants/constants.dart';
import 'package:on_chain_swap/src/swap/core/core.dart';
import 'package:on_chain_swap/src/swap/services/services.dart';
import 'package:on_chain_swap/src/swap/types/types.dart';
import 'package:on_chain_swap/src/swap/utils/utils.dart';

class CfSwapService extends SwapService<
    BaseSwapAsset,
    IProvider<IServiceProvider, CfRequestDetails>,
    CfSwapRoute,
    CfQuoteSwapParams> {
  final ChainType chainType;
  CfSwapService({required super.provider, this.chainType = ChainType.mainnet})
      : super(service: SwapServiceType.chainFlip);

  List<BaseSwapAsset> _loadAssets() {
    if (chainType.isMainnet) {
      return CfSwapConstants.assets;
    }

    return CfTestnetSwapConstants.assets;
  }

  @override
  Future<List<BaseSwapAsset>> loadAssets() async {
    return _loadAssets();
  }

  @override
  Future<List<CfSwapRoute>> createRoutes(CfQuoteSwapParams params) async {
    final quote = await provider.request(CfBackendRequestQuoteV2(
        srcChain: params.sourceAsset.network.name,
        srcAsset: params.sourceAsset.providerIdentifier,
        destChain: params.destinationAsset.network.name,
        destAsset: params.destinationAsset.providerIdentifier,
        amount: params.amount.amount.toString(),
        isVaultSwap: false,
        dcaEnabled: true));
    final assets = _loadAssets();
    final List<QuoteDetails> quotes = [
      ...quote,
      ...quote.map((e) => e.boostQuote).where((e) => e != null).cast()
    ];
    return quotes.map((e) {
      return CfSwapRoute(
          expireTime: DateTime.now().add(const Duration(hours: 23)),
          expectedAmount: SwapAmount.fromBigInt(
              BigintUtils.parse(e.egressAmount),
              params.destinationAsset.decimal),
          worstCaseAmount: CfSwapUtils.calculateMinAmount(
              amount: BigintUtils.parse(e.egressAmount),
              tolerance: e.recommendedSlippageTolerancePercent,
              destinationAsset: params.destinationAsset),
          quote: params,
          route: e,
          estimateTime:
              SwapUtils.secondsToMinutes(e.estimatedDurationSeconds.toInt()),
          tolerance: e.recommendedSlippageTolerancePercent.toDouble(),
          provider: SwapConstants.chainflip,
          fees: e.includedFees.map((e) {
            final feeAsset = assets.firstWhere((i) =>
                i.providerIdentifier == e.asset && i.network.name == e.chain);
            return SwapFee(
                token: assets.firstWhere((i) =>
                    i.providerIdentifier == e.asset &&
                    i.network.name == e.chain),
                amount: SwapAmount.fromBigInt(
                    BigintUtils.parse(e.amount), feeAsset.decimal),
                type: e.type.type,
                asset: e.asset);
          }).toList());
    }).toList();
  }

  Future<TRPCOpenDepositChannelResponse> openDepositChannel({
    required String sourceAddress,
    required String destinationAddress,
    required CfSwapRoute route,
    int retryDurationBlocks = 50,
    double? tolerance,
    String? minPrice,
  }) async {
    if (minPrice != null && tolerance != null) {
      throw const DartOnChainSwapPluginException(
          "Invalid input: Provide either 'tolerance' or 'minPrice', not both.");
    }

    if (minPrice == null && tolerance == null) {
      throw const DartOnChainSwapPluginException(
          "Missing input: Either 'tolerance' or 'minPrice' must be provided.");
    }
    minPrice ??= CfSwapUtils.calculateMinPrice(
        estimatedPrice: route.route.estimatedPrice,
        tolerance: tolerance!,
        destinationAsset: route.quote.destinationAsset);
    return provider.request(_CfTRPCRequestOpenSwapDepositChannel(
        srcAddress: sourceAddress,
        destAddress: destinationAddress,
        fillOrKillParams: RPCFillOrKillX128Price(
            refundAddress: sourceAddress,
            retryDurationBlocks: retryDurationBlocks,
            minPriceX128: CfSwapUtils.calculateMinX128Price(
                minPrice: minPrice,
                source: route.quote.sourceAsset,
                dest: route.quote.destinationAsset)),
        quote: route.route));
  }

  @override
  Map<SwapNetwork, Set<BaseSwapAsset>> getDestAssets(BaseSwapAsset asset) {
    final allAssets = _loadAssets();
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

class _CfTRPCRequestOpenSwapDepositChannel extends CfTRPCRequest<
    TRPCOpenDepositChannelResponse, Map<String, dynamic>> {
  final String? srcAddress;
  final String destAddress;
  final RPCFillOrKillParam fillOrKillParams;
  final QuoteDetails quote;
  const _CfTRPCRequestOpenSwapDepositChannel(
      {required this.srcAddress,
      required this.destAddress,
      required this.fillOrKillParams,
      required this.quote});
  @override
  Map<String, dynamic> get params {
    return {
      "json": {
        "srcAsset": quote.srcAsset.asset,
        "srcChain": quote.srcAsset.chain,
        "destAsset": quote.destAsset.asset,
        "destChain": quote.destAsset.chain,
        "srcAddress": null,
        "destAddress": destAddress,
        "dcaParams":
            quote.type == QuoteType.dca ? quote.dcaParams?.toJson() : null,
        "fillOrKillParams": fillOrKillParams.toJson(),
        "maxBoostFeeBps": (quote is QuoteBoostedDetails)
            ? (quote as QuoteBoostedDetails).maxBoostFeeBps
            : null,
        "ccmParams": null,
        "amount": quote.depositAmount,
        "quote": quote.toJson(),
        "takeCommission": true,
      },
      "meta": {
        "values": {
          "srcAddress": ["undefined"],
          "dcaParams": ["undefined"],
          "maxBoostFeeBps": ["undefined"],
          "ccmParams": ["undefined"]
        }
      }
    };
  }

  @override
  String get method => "openSwapDepositChannel";

  @override
  TRPCOpenDepositChannelResponse onResonse(Map<String, dynamic> result) {
    return TRPCOpenDepositChannelResponse.fromJson(result
        .valueEnsureAsMap<String, dynamic>("result")
        .valueEnsureAsMap<String, dynamic>("data")
        .valueEnsureAsMap<String, dynamic>("json"));
  }
}
