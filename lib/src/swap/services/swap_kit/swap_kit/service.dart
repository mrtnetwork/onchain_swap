import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:on_chain/on_chain.dart';
import 'package:on_chain_swap/src/exception/exception.dart';
import 'package:on_chain_swap/src/providers/providers.dart';
import 'package:on_chain_swap/src/swap/core/core.dart';
import 'package:on_chain_swap/src/swap/services/swap_kit/swap_kit/types.dart'
    show SwapKitSwapServiceProvider;
import 'package:on_chain_swap/src/swap/services/swap_kit/swap_kit/utils.dart';
import 'package:on_chain_swap/src/swap/types/types.dart';
import 'package:on_chain_swap/src/swap/utils/utils.dart';

import 'route.dart';

class SwapKitSwapService extends SwapService<
    BaseSwapAsset,
    IProvider<IServiceProvider, SwapKitRequestDetails>,
    SwapKitSwapRoute,
    SwapKitQuoteSwapParams> {
  final List<SwapKitSwapServiceProvider> providers;
  SwapKitSwapService(
      {required super.provider, required List<SwapKitSwapServiceProvider> providers})
      : providers = providers.immutable,
        super(service: SwapServiceType.swapKit);

  List<BaseSwapAsset> _assets = [];

  Future<List<BaseSwapAsset>> _loadAssets(SwapKitSwapServiceProvider provider) async {
    final tokens = await this.provider.request(SwapKitRequestTokens(provider.identifier));
    final List<BaseSwapAsset> supportedTokens = [];
    for (final i in tokens.tokens) {
      final network = SwapUtils.findAssetNetwork(i.chainId);
      if (network == null || network.type != SwapChainType.ethereum) {
        continue;
      }
      BaseSwapAsset asset;
      if (i.address != null) {
        asset = ETHSwapAsset(
            symbol: i.ticker,
            providerIdentifier: i.identifier,
            coingeckoId: i.coingeckoId,
            logoUrl: i.logoURI,
            decimal: i.decimals,
            network: network,
            provider: provider,
            fullName: i.name,
            contractAddress: ETHAddress(i.address!));
      } else {
        switch (network.type) {
          case SwapChainType.ethereum:
            asset = ETHSwapAsset(
                symbol: i.ticker,
                providerIdentifier: i.identifier,
                coingeckoId: i.coingeckoId,
                logoUrl: i.logoURI,
                decimal: i.decimals,
                network: network,
                provider: provider,
                fullName: i.name);
            break;
          default:
            throw DartOnChainSwapPluginException("Unknown swap assets.",
                details: {"network": network.name});
        }
      }
      supportedTokens.add(asset);
    }
    return supportedTokens;
  }

  Future<List<SwapKitProviderInfo>> getProviders(String provider) async {
    final providers = await this.provider.request(SwapKitRequestProviders());
    return providers;
  }

  @override
  Future<List<BaseSwapAsset>> loadAssets() async {
    if (_assets.isNotEmpty) return _assets.clone();
    List<BaseSwapAsset> allAssets = [];
    for (final i in providers) {
      try {
        final assets = await _loadAssets(i);
        allAssets.addAll(assets);
      } catch (_) {}
    }
    _assets = allAssets;
    return _assets.clone();
  }

  @override
  Future<List<SwapKitSwapRoute>> createRoutes(SwapKitQuoteSwapParams params) async {
    if (params.sourceAsset.network != params.destinationAsset.network) {
      throw const DartOnChainSwapPluginException(
          "Mismatch between source and destination networks.");
    }
    final network = params.sourceAsset.network;
    final sourceAddress =
        SwapUtils.checkOrGetFakeAddress(address: params.sourceAddress, network: network);
    final destinationAddress = SwapUtils.checkOrGetFakeAddress(
        address: params.destinationAddress, network: network);
    final quote = await provider.request(SwapKitRequestQuote(
        sellAsset: params.sourceAsset.providerIdentifier,
        buyAsset: params.destinationAsset.providerIdentifier,
        providers: [params.sourceAsset.provider.identifier],
        includeTx: true,
        sellAmount: params.amount.amountString,
        sourceAddress: sourceAddress,
        destinationAddress: destinationAddress));
    return quote.routes.map((e) {
      final transaction = SwapKitSwapUtils.parseEthSwapData(
          jsonTx: e.tx, network: params.sourceAsset.network.cast());
      double? estimateTime = e.estimateTime?.total.toDouble();
      if (estimateTime != null) {
        estimateTime = estimateTime / 60;
      }
      return SwapKitSwapRoute(
          route: e,
          transaction: transaction,
          expectedAmount:
              SwapAmount.fromString(e.expectedBuyAmount, params.destinationAsset.decimal),
          worstCaseAmount: SwapAmount.fromString(
              e.expectedBuyAmountMaxSlippage, params.destinationAsset.decimal),
          quote: params.copyWith(
              sourceAddress: sourceAddress, destinationAddress: destinationAddress),
          provider: params.sourceAsset.provider,
          tolerance: 0.0,
          expireTime: SwapUtils.unixSecondsToDateTime(BigintUtils.tryParse(e.expiration)),
          estimateTime: estimateTime?.ceil() ?? 0,
          fees: e.fees.map((e) {
            final asset =
                _assets.firstWhereNullable((i) => i.providerIdentifier == e.asset);
            return SwapFee(
                token: asset,
                amount: asset == null
                    ? ViewSwapAmount(amountString: e.amount)
                    : SwapAmount.fromString(e.amount, asset.decimal),
                type: e.type,
                asset: e.asset);
          }).toList());
    }).toList();
  }

  @override
  Map<SwapNetwork, Set<BaseSwapAsset>> getDestAssets(BaseSwapAsset asset) {
    List<BaseSwapAsset> assets = [];

    if (_assets.contains(asset)) {
      final currentAsset = _assets.firstWhereNullable((e) => e == asset);
      if (currentAsset != null) {
        if (currentAsset.type.isNative) {
          assets = _assets.where((e) => e.network == asset.network).toList();
        } else {
          assets = _assets
              .where((e) =>
                  e.network == asset.network &&
                  (e.type.isNative || e.provider == asset.provider))
              .toList();
        }
      }
    }
    final Map<SwapNetwork, Set<BaseSwapAsset>> networkAssets = {};
    for (final i in assets) {
      networkAssets[i.network] ??= {};
      networkAssets[i.network]?.add(i);
    }
    return networkAssets;
  }
}
