import 'package:on_chain_swap/src/exception/exception.dart';
import 'package:on_chain_swap/src/providers/skip_go/models/types/types.dart';
import 'package:on_chain_swap/src/swap/transaction/client/core/client.dart';
import 'package:on_chain_swap/src/swap/transaction/core/transaction.dart';
import 'package:on_chain_swap/src/swap/transaction/signer/signer.dart';
import 'package:on_chain_swap/src/swap/transaction/types/types.dart';
import 'package:on_chain_swap/src/swap/types/types.dart';

import 'chains.dart';

class SkipGoQuoteSwapParams extends QuoteSwapParams<SkipGoSwapAsset> {
  final bool allowMultiTx;
  final bool goFast;
  final bool smartRelay;
  final bool unsafe;
  SkipGoQuoteSwapParams(
      {required super.sourceAsset,
      required super.destinationAsset,
      required super.amount,
      super.sourceAddress,
      super.destinationAddress,
      this.goFast = true,
      this.smartRelay = true,
      this.allowMultiTx = false,
      this.unsafe = false});
}

class SkipGoSwapRoute
    extends SwapRoute<SkipGoQuoteSwapParams, SwapRouteGeneralTransactionBuilderParam> {
  final SkipGoApiRoute route;

  SkipGoSwapRoute(
      {required super.expireTime,
      required super.expectedAmount,
      required super.quote,
      required this.route,
      required super.estimateTime,
      required super.provider,
      required super.fees,
      required super.tolerance,
      required super.worstCaseAmount});

  @override
  SwapRoute<QuoteSwapParams<BaseSwapAsset>, SwapRouteGeneralTransactionBuilderParam>
      updateTolerance(double tolerance) {
    throw const DartOnChainSwapPluginException("Unsupported api.");
  }

  @override
  SwapRouteTransactionBuilder<
          dynamic,
          SwapNetwork,
          SwapNetworkClient<BaseSwapAsset, dynamic,
              SwapAccountAssetBalance<BaseSwapAsset, dynamic, Object>>,
          Web3Transaction,
          Web3Signer<dynamic>,
          SwapRouteTransactionOperation<SwapNetwork>>
      txBuilder(SwapRouteGeneralTransactionBuilderParam params) {
    throw const DartOnChainSwapPluginException("Unsupported api.");
  }
}
