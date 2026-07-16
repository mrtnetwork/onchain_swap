import 'package:blockchain_utils/service/models/params.dart';
import 'package:on_chain_swap/src/exception/exception.dart';
import 'package:on_chain_swap/src/providers/skip_go/provider.dart';
import 'package:on_chain_swap/src/swap/constants/constants.dart';
import 'package:on_chain_swap/src/swap/core/core.dart';
import 'package:on_chain_swap/src/swap/services/skip_go/skip_go/chains.dart';
import 'package:on_chain_swap/src/swap/types/types.dart';
import 'package:cosmos_sdk/cosmos_sdk.dart';
import 'route.dart';

class SkipGoSwapService extends SwapService<
    SkipGoSwapAsset,
    IProvider<IServiceProvider, SkipGoApiRequestDetails>,
    SkipGoSwapRoute,
    SkipGoQuoteSwapParams> {
  Map<String, SwapNetwork>? _supportedNetworks;
  List<SkipGoSwapAsset>? _assets;
  SkipGoSwapService(
      {required super.provider,
      ChainRegistryProvider? chainRegistryProvider,
      List<SwapNetwork>? supportedNetworks})
      : _supportedNetworks = supportedNetworks == null
            ? null
            : {for (final i in supportedNetworks) i.identifier: i},
        super(service: SwapServiceType.skipGo);

  Future<Map<String, SwapNetwork>> _loadNetworks() async {
    if (_supportedNetworks != null) return _supportedNetworks!;
    final chains = await provider
        .request(SkipGoApiRequestChains(includeEVM: true, includeSVM: true));
    List<SwapNetwork> supportedNetworks = chains
        .map((e) => switch (e.chainType) {
              SkipGoApiChainType.cosmos => SwapCosmosNetwork(
                  name: e.prettyName,
                  identifier: e.chainId,
                  bech32: e.bech32Prefix,
                  explorerAddressUrl: null,
                  explorerTxUrl: null,
                  // denom: e.chainId,
                  logoUrl: e.logoUri),
              SkipGoApiChainType.evm => SwapEthereumNetwork(
                  name: e.prettyName,
                  identifier: e.chainId,
                  explorerAddressUrl: null,
                  explorerTxUrl: null,
                  logoUrl: e.logoUri),
              SkipGoApiChainType.svm => SwapSolanaNetwork(
                  name: e.prettyName,
                  identifier: e.chainId,
                  explorerAddressUrl: null,
                  explorerTxUrl: null,
                  genesis: '',
                  logoUrl: e.logoUri),
            })
        .toList();
    _supportedNetworks = {for (final i in supportedNetworks) i.identifier: i};
    return _supportedNetworks!;
  }

  @override
  Future<List<SkipGoSwapAsset>> loadAssets() async {
    if (_assets != null) return _assets!;
    final networks = await _loadNetworks();
    final assets = await provider.request(SkipGoApiRequestAssets(
        includeEvmAssets: true,
        includeCw20Assets: true,
        includeSvmAssets: true,
        includeNoMetadataAssets: false));
    List<SkipGoSwapAsset> supportedAssets = [];
    for (final i in assets.assets.entries) {
      if (!networks.containsKey(i.key)) {
        continue;
      }
      for (final a in i.value) {
        if (a.decimals == null) {
          continue;
        }
        supportedAssets.add(SkipGoSwapAsset(
            symbol: a.symbol ?? a.name ?? a.denom,
            providerIdentifier: a.denom,
            asset: a,
            decimal: a.decimals!,
            network: networks[i.key]!,
            provider: SwapConstants.skipGo));
      }
    }
    _assets = supportedAssets;
    return _assets!;
  }

  @override
  Future<List<SkipGoSwapRoute>> createRoutes(
      SkipGoQuoteSwapParams params) async {
    throw const DartOnChainSwapPluginException("Unsupported api.");
    // final quote = await provider.request(SkipGoApiRequestRoute.givenIn(
    //     sourceAssetDenom: params.sourceAsset.asset.denom,
    //     sourceAssetChainId: params.sourceAsset.asset.chainId,
    //     destAssetDenom: params.destinationAsset.asset.denom,
    //     destAssetChainId: params.destinationAsset.asset.chainId,
    //     amountIn: params.amount.amount.toString()));
    // return [
    //   SkipGoSwapRoute(
    //       expire: quote.,
    //       expectedAmount: SwapAmount.fromBigInt(
    //           BigintUtils.parse(quote.amountOut),
    //           params.destinationAsset.decimal),
    //       quote: params,
    //       tolerance: 0.0,
    //       route: quote,
    //       estimateTime:
    //           SwapUtils.secondsToMinutes(quote.estimatedRouteDurationSeconds),
    //       // totalSlippageBps: quote.swapPriceImpactPercent,
    //       provider: params.sourceAsset.provider,
    //       fees: quote.estimatedFees
    //           .map((e) {
    //             if (!_supportedNetworks!.containsKey(e.chainId) ||
    //                 e.originAsset.decimals == null) return null;
    //             final feeAsset = _assets!.firstWhere(
    //               (asset) =>
    //                   asset.asset.chainId == e.chainId &&
    //                   asset.asset.denom == e.originAsset.denom,
    //               orElse: () {
    //                 // if (e.originAsset.decimals == null) return null;
    //                 return SkipGoSwapAsset(
    //                     symbol: e.originAsset.symbol ??
    //                         e.originAsset.name ??
    //                         e.originAsset.denom,
    //                     providerIdentifier: e.originAsset.denom,
    //                     asset: e.originAsset,
    //                     decimal: e.originAsset.decimals!,
    //                     network: _supportedNetworks![e.chainId]!,
    //                     provider: params.sourceAsset.provider);
    //               },
    //             );
    //             return SwapFee(
    //                 token: feeAsset,
    //                 amount: SwapAmount.fromBigInt(
    //                     BigintUtils.parse(e.amount), feeAsset.decimal),
    //                 type: e.feeType,
    //                 asset: e.originAsset.symbol ??
    //                     e.originAsset.name ??
    //                     e.originAsset.denom);
    //           })
    //           .whereType<SwapFee>()
    //           .toList())
    // ];
  }

  @override
  Map<SwapNetwork, Set<BaseSwapAsset>> getDestAssets(BaseSwapAsset asset) {
    throw const DartOnChainSwapPluginException("Unsupported api.");
  }
}
