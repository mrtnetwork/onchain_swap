import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:blockchain_utils/utils/string/string.dart';
import 'package:on_chain_swap/src/exception/exception.dart';
import 'package:on_chain_swap/src/swap/transaction/transaction.dart';
import 'package:on_chain_swap/src/swap/types/types.dart';
import 'package:zcash_dart/zcash.dart';

enum SwapRouteZcashTransactionStrategy { native }

class SwapRouteZcashTransactionBuilder extends SwapRouteTransactionBuilder<
    ZcashAddress,
    SwapZcashNetwork,
    BaseSwapZcashClient,
    Web3TransactionZcash,
    Web3SignerZcash,
    SwapRouteZcashTransactionOperation> {
  SwapRouteZcashTransactionBuilder(
      {required super.route, required super.params, required super.operations});

  @override
  Future<void> buildTransactions({
    required CbGetRouteNetwork<BaseSwapZcashClient, SwapZcashNetwork> client,
    required CbGetSigner<Web3SignerZcash, ZcashAddress> signer,
    required CbOnStatusChanged stepsCallBack,
  }) async {
    for (final operation in operations) {
      stepsCallBack(TransactionOperationStep.client);
      final tronClient = await checkRouteAndClient(client, operation);
      stepsCallBack(TransactionOperationStep.generateTx);
      final transaction = await operation._buildTransactions(tronClient);
      if (transaction == null) continue;
      stepsCallBack(TransactionOperationStep.signing);
      final signerInfo = await signer(transaction.source);
      final signers = await signerInfo.signers();
      signers.firstWhere((e) => e == operation.source,
          orElse: () => throw const DartOnChainSwapPluginException(
              "None of the connected accounts match the source address of the transaction."));
      stepsCallBack(TransactionOperationStep.broadcast);
      final txId = await signerInfo.excuteTransaction(transaction);
      stepsCallBack(TransactionOperationStep.txHash, transactionHash: txId);
    }
  }
}

abstract class SwapRouteZcashTransactionOperation
    extends SwapRouteTransactionOperation<SwapZcashNetwork> {
  final String? memo;
  final SwapRouteZcashTransactionStrategy strategy;
  final ZcashAddress source;
  const SwapRouteZcashTransactionOperation(
      {required super.network, required this.strategy, required this.source, this.memo});

  Future<Web3TransactionZcash?> _buildTransactions(BaseSwapZcashClient client);
}

class SwapRouteZcashNativeTransactionOperation extends SwapRouteZcashTransactionOperation
    implements SwapRouteTransactionTransferDetails<SwapZcashNetwork> {
  final ZcashAddress destination;
  @override
  final SwapAmount amount;
  SwapRouteZcashNativeTransactionOperation(
      {required this.amount,
      required super.source,
      required this.destination,
      required super.network,
      super.memo})
      : super(strategy: SwapRouteZcashTransactionStrategy.native);

  @override
  Future<Web3TransactionZcash> _buildTransactions(BaseSwapZcashClient client) async {
    final memo = switch (this.memo) {
      null => null,
      String memo => BitcoinScriptUtils.buildOpReturn([StringUtils.toBytes(memo)]),
    };
    final transparentAddress = destination.tryToTransparentAddreses();
    if (transparentAddress == null) {
      throw const DartOnChainSwapPluginException(
          "Invalid zcash destination address protocol.");
    }

    return Web3TransactionZcash(destinations: [
      ZcashSwapTransparentDestination(
          amount: amount.amount, destination: transparentAddress)
    ], transparentMemos: [
      if (memo != null) memo
    ], source: source);
  }

  @override
  String get destinationAddress => destination.address;

  @override
  String get sourceAddress => source.address;

  @override
  final String? tokenAddress = null;
}
