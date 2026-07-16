import 'package:blockchain_utils/helper/extensions/extensions.dart';
import 'package:on_chain_swap/src/swap/constants/constants.dart';
import 'package:on_chain_swap/src/swap/transaction/transaction.dart';
import 'package:on_chain_swap/src/swap/types/types.dart';

enum TransactionOperationStep {
  client,
  generateTx,
  signing,
  broadcast,
  txHash,
  complete
}

typedef CbOnStatusChanged = void Function(TransactionOperationStep,
    {String? transactionHash});

abstract class SwapRouteTransactionBuilder<
    ADDRESS,
    NETWORK extends SwapNetwork,
    CLIENT extends SwapNetworkClient,
    TRANSACTION extends Web3Transaction,
    SIGNER extends Web3Signer,
    OPERATION extends SwapRouteTransactionOperation<NETWORK>> {
  SwapRouteTransactionBuilder(
      {required List<OPERATION> operations,
      required this.params,
      required this.route})
      : operations = operations.immutable;
  final List<OPERATION> operations;
  final SwapRoute route;
  final SwapRouteGeneralTransactionBuilderParam params;

  Future<CLIENT> checkRouteAndClient(
      CbGetRouteNetwork<CLIENT, NETWORK> onGetClient,
      OPERATION operation) async {
    final client = await onGetClient(operation.network);
    final init = await client.initSwapClient();
    if (!init) {
      throw SwapConstants.clientInitializationFailedException;
    }
    final expTime = params.expireTime;
    final expBlock = params.sourceExpireBlock;
    if (expTime != null && expTime.isBefore(DateTime.now())) {
      throw SwapConstants.routeExpiredException;
    }
    if (expBlock != null) {
      final currentHeight = await client.getBlockHeight();
      if (currentHeight != null && currentHeight > expBlock) {
        throw SwapConstants.routeExpiredException;
      }
    }
    return client;
  }

  Future<void> buildTransactions(
      {required CbGetRouteNetwork<CLIENT, NETWORK> client,
      required CbGetSigner<SIGNER, ADDRESS> signer,
      required CbOnStatusChanged stepsCallBack});
}

abstract class SwapRouteTransactionOperation<NETWORK> {
  final NETWORK network;
  const SwapRouteTransactionOperation({required this.network});
}

abstract class SwapRouteTransactionTransferDetails<NETWORK extends SwapNetwork>
    implements SwapRouteTransactionOperation<NETWORK> {
  @override
  abstract final NETWORK network;
  abstract final SwapAmount amount;
  abstract final String? memo;
  abstract final String sourceAddress;
  abstract final String destinationAddress;
  abstract final String? tokenAddress;
}

abstract class SwapRouteTransactionContractDetails<NETWORK extends SwapNetwork>
    implements SwapRouteTransactionOperation<NETWORK> {
  abstract final String sourceAddress;
  abstract final String contractAddress;
  abstract final String data;
  abstract final String functionName;
  abstract final SwapAmount? amount;
}
