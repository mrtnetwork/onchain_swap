import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:blockchain_utils/utils/numbers/utils/bigint_utils.dart';
import 'package:on_chain/on_chain.dart';
import 'package:on_chain_swap/src/exception/exception.dart';
import 'package:on_chain_swap/src/providers/cf/models/models/backend.dart';
import 'package:on_chain_swap/src/providers/cf/models/models/rpc.dart';
import 'package:on_chain_swap/src/swap/transaction/transaction.dart';
import 'package:on_chain_swap/src/swap/types/types.dart';
import 'package:on_chain_swap/src/swap/utils/utils.dart' show SwapUtils;
import 'package:polkadot_dart/polkadot_dart.dart';

import 'utils.dart';

class CfQuoteSwapParams extends QuoteSwapParams<BaseSwapAsset> {
  CfQuoteSwapParams(
      {required super.sourceAsset,
      required super.destinationAsset,
      required super.amount,
      super.sourceAddress,
      super.destinationAddress});
}

class CfSwapRoute extends SwapRoute<CfQuoteSwapParams,
    SwapRouteCfGeneralTransactionBuilderParam> {
  final QuoteDetails route;

  CfSwapRoute(
      {required super.expireTime,
      required super.expectedAmount,
      required super.quote,
      required this.route,
      required super.estimateTime,
      required super.tolerance,
      required super.provider,
      required super.fees,
      required super.worstCaseAmount});

  @override
  CfSwapRoute updateTolerance(double tolerance) {
    return CfSwapRoute(
        expireTime: expireTime,
        expectedAmount: expectedAmount,
        quote: quote,
        worstCaseAmount: CfSwapUtils.calculateMinAmount(
            amount: BigintUtils.parse(route.egressAmount),
            tolerance: tolerance,
            destinationAsset: quote.destinationAsset),
        route: route,
        estimateTime: estimateTime,
        tolerance: tolerance,
        provider: provider,
        fees: fees);
  }

  @override
  SwapRouteTransactionBuilder txBuilder(
      SwapRouteCfGeneralTransactionBuilderParam params) {
    switch (quote.sourceAsset.network.type) {
      case SwapChainType.ethereum:
        final network = quote.sourceAsset.network.cast<SwapEthereumNetwork>();
        final ETHAddress source =
            SwapUtils.toNetworkAddress(network, params.sourceAddress);
        final ETHAddress destination =
            SwapUtils.toNetworkAddress(network, params.channel.depositAddress);
        if (quote.sourceAsset.isNative) {
          return SwapRouteEthereumTransactionBuilder(
              params: params,
              route: this,
              operations: [
                SwapRouteEthereumNativeTransactionOperation(
                    amount: quote.amount,
                    source: source,
                    destination: destination,
                    network: network)
              ]);
        }
        final contract = ETHAddress(quote.sourceAsset.identifier);
        return SwapRouteEthereumTransactionBuilder(
            route: this,
            params: params,
            operations: [
              SwapRouteEthereumSendTokenTransactionOperation(
                  contract: contract,
                  amount: quote.amount,
                  source: source,
                  destination: destination,
                  network: network)
            ]);

      case SwapChainType.solana:
        final network = quote.sourceAsset.network.cast<SwapSolanaNetwork>();
        final SolAddress source =
            SwapUtils.toNetworkAddress(network, params.sourceAddress);
        final SolAddress destination =
            SwapUtils.toNetworkAddress(network, params.channel.depositAddress);
        if (quote.sourceAsset.isNative) {
          return SwapRouteSolanaTransactionBuilder(
              route: this,
              params: params,
              operations: [
                SwapRouteSolanaNativeTransactionOperation(
                    amount: quote.amount,
                    source: source,
                    destination: destination,
                    network: network)
              ]);
        }
        final contact = SolAddress.uncheckCurve(quote.sourceAsset.identifier);
        return SwapRouteSolanaTransactionBuilder(
            route: this,
            params: params,
            operations: [
              SwapRouteSolanaSendTokenTransactionOperation(
                  amount: quote.amount,
                  source: source,
                  destination: destination,
                  network: network,
                  contract: contact)
            ]);

      case SwapChainType.polkadot:
        final asset = quote.sourceAsset.cast<PolkadotSwapAsset>();
        BigInt? assetId;
        if (asset.type == SwapAssetType.asset) {
          assetId = asset.assetId;
          if (assetId == null) {
            throw const DartOnChainSwapPluginException(
                "Missing polkadot asset id.");
          }
        }
        final network = asset.network.cast<SwapSubstrateNetwork>();
        final SubstrateAddress source =
            SwapUtils.toNetworkAddress(network, params.sourceAddress);
        final SubstrateAddress destination =
            SwapUtils.toNetworkAddress(network, params.channel.depositAddress);
        final SwapRouteSubstrateTransactionOperation operation =
            switch (assetId) {
          final BigInt id =>
            SwapRouteSubstrateAssetHubAssetTransactionOperation(
                amount: quote.amount,
                source: source,
                destination: destination,
                network: network,
                assetId: id),
          _ => SwapRouteSubstrateNativeTransactionOperation(
              amount: quote.amount,
              source: source,
              destination: destination,
              network: network)
        };
        return SwapRouteSubstrateTransactionBuilder(
            route: this, params: params, operations: [operation]);

      case SwapChainType.bitcoin:
        final network = quote.sourceAsset.network.cast<SwapBitcoinNetwork>();
        final BitcoinNetworkAddress destination =
            SwapUtils.toNetworkAddress(network, params.channel.depositAddress);
        final BitcoinNetworkAddress sourceAddress =
            SwapUtils.toNetworkAddress(network, params.sourceAddress);

        return SwapRouteBitcoinTransactionBuilder(
            route: this,
            params: params,
            operations: [
              SwapRouteBitcoinNativeTransactionOperation(
                  amount: quote.amount,
                  destination: destination,
                  network: network,
                  source: sourceAddress),
            ]);
      default:
        throw DartOnChainSwapPluginException(
            "Unsuported chainflip swap netwrk. ${quote.sourceAsset.network.name}");
    }
  }
}

class SwapRouteCfGeneralTransactionBuilderParam
    extends SwapRouteGeneralTransactionBuilderParam {
  final TRPCOpenDepositChannelResponse channel;
  final SwapNetwork destionationNetwork;
  SwapRouteCfGeneralTransactionBuilderParam(
      {required this.channel,
      required super.sourceAddress,
      required super.destinationAddress,
      required this.destionationNetwork,
      super.expireTime,
      required BigInt super.sourceExpireBlock});

  late final String channelUrl = CfSwapUtils.channelUrl(
      network: destionationNetwork, channelId: channel.id);
}
