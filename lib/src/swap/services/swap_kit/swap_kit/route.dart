import 'package:on_chain/ethereum/src/address/evm_address.dart';
import 'package:on_chain_swap/src/on_chain_swap_base.dart'
    show DartOnChainSwapPluginException;
import 'package:on_chain_swap/src/providers/swap_kit/models/types/types.dart';
import 'package:on_chain_swap/src/swap/transaction/transaction.dart';
import 'package:on_chain_swap/src/swap/types/types.dart';
import 'package:on_chain_swap/src/swap/utils/utils.dart';

class SwapKitQuoteSwapParams extends QuoteSwapParams<BaseSwapAsset> {
  SwapKitQuoteSwapParams(
      {required super.sourceAsset,
      required super.destinationAsset,
      super.sourceAddress,
      super.destinationAddress,
      required super.amount});
  SwapKitQuoteSwapParams copyWith({
    BaseSwapAsset? sourceAsset,
    BaseSwapAsset? destinationAsset,
    SwapAmount? amount,
    String? sourceAddress,
    String? destinationAddress,
  }) {
    return SwapKitQuoteSwapParams(
        sourceAsset: sourceAsset ?? this.sourceAsset,
        destinationAsset: destinationAsset ?? this.destinationAsset,
        amount: amount ?? this.amount,
        destinationAddress: destinationAddress ?? this.destinationAddress,
        sourceAddress: sourceAddress ?? this.sourceAddress);
  }
}

class SwapKitSwapRoute
    extends SwapRoute<SwapKitQuoteSwapParams, SwapRouteGeneralTransactionBuilderParam> {
  final SwapKitRoute route;
  final SwapRouteEthereumCallContractTransactionOperation transaction;
  @override
  bool get supportTolerance => false;
  SwapKitSwapRoute(
      {required super.expireTime,
      required super.expectedAmount,
      required super.quote,
      required this.route,
      required super.estimateTime,
      required super.provider,
      required super.fees,
      required super.tolerance,
      required this.transaction,
      required super.worstCaseAmount});

  @override
  SwapRouteTransactionBuilder txBuilder(SwapRouteGeneralTransactionBuilderParam params) {
    switch (quote.sourceAsset.network.type) {
      case SwapChainType.ethereum:
        final network = quote.sourceAsset.network.cast<SwapEthereumNetwork>();
        final ETHAddress source =
            SwapUtils.toNetworkAddress(network, params.sourceAddress);
        final ETHAddress destination =
            SwapUtils.toNetworkAddress(network, params.destinationAddress);

        if (source.address != quote.sourceAddress ||
            destination.address != quote.destinationAddress ||
            transaction.source.address != quote.sourceAddress ||
            (source != destination &&
                !transaction.data
                    .contains(destination.address.substring(2).toLowerCase()))) {
          throw const DartOnChainSwapPluginException(
              "The provided address doesn't match the address in the swap quote.");
        }
        if (quote.sourceAsset.isNative) {
          return SwapRouteEthereumTransactionBuilder(
              params: params, route: this, operations: [transaction]);
        }
        final contract = ETHAddress(quote.sourceAsset.identifier);
        return SwapRouteEthereumTransactionBuilder(
            route: this,
            params: params,
            operations: [
              SwapRouteEthereumAproveTransactionOperation(
                  contract: contract,
                  amount: quote.amount,
                  source: source,
                  spender: transaction.contract,
                  network: network),
              transaction
            ]);

      default:
        throw DartOnChainSwapPluginException(
            "Unsuported network. ${quote.sourceAsset.network.name}");
    }
  }

  @override
  SwapRoute<QuoteSwapParams<BaseSwapAsset>, SwapRouteGeneralTransactionBuilderParam>
      updateTolerance(double tolerance) {
    throw const DartOnChainSwapPluginException("Unsupported api.");
  }
}
