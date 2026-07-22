import 'package:blockchain_utils/utils/binary/utils.dart';
import 'package:blockchain_utils/utils/string/string.dart';
import 'package:on_chain_swap/src/exception/exception.dart';
import 'package:on_chain_swap/src/swap/constants/constants.dart';
import 'package:on_chain_swap/src/swap/transaction/transaction.dart';
import 'package:on_chain_swap/src/swap/types/types.dart';
import 'package:xrpl_dart/xrpl_dart.dart';

enum SwapRouteXRPTransactionStrategy { native }

class SwapRouteXRPTransactionBuilder extends SwapRouteTransactionBuilder<
    XRPBaseAddress,
    SwapXRPNetwork,
    BaseSwapXRPClient,
    Web3TransactionXRP,
    Web3SignerXRP,
    SwapRouteXRPTransactionOperation> {
  final TransactionExcuteMode mode;
  SwapRouteXRPTransactionBuilder(
      {required super.route,
      required super.params,
      required super.operations,
      this.mode = TransactionExcuteMode.serial});

  @override
  Future<void> buildTransactions({
    required CbGetRouteNetwork<BaseSwapXRPClient, SwapXRPNetwork> client,
    required CbGetSigner<Web3SignerXRP, XRPBaseAddress> signer,
    required CbOnStatusChanged stepsCallBack,
  }) async {
    for (final operation in operations) {
      stepsCallBack(TransactionOperationStep.client);
      final tronClient = await checkRouteAndClient(client, operation);
      stepsCallBack(TransactionOperationStep.generateTx);
      final transaction = await operation._buildTransactions(tronClient);
      if (transaction == null) continue;
      stepsCallBack(TransactionOperationStep.signing);
      final signerInfo = await signer(transaction.account);
      final signers = await signerInfo.signers();
      signers.firstWhere((e) => e == operation.source,
          orElse: () => throw const DartOnChainSwapPluginException(
              "None of the connected accounts match the source address of the transaction."));
      stepsCallBack(TransactionOperationStep.broadcast);
      final txId = await signerInfo.sendTransaction(transaction.transaction);
      stepsCallBack(TransactionOperationStep.txHash, transactionHash: txId);
    }
  }
}

abstract class SwapRouteXRPTransactionOperation
    extends SwapRouteTransactionOperation<SwapXRPNetwork> {
  final String? memo;
  final SwapRouteXRPTransactionStrategy strategy;
  final XRPBaseAddress source;
  const SwapRouteXRPTransactionOperation(
      {required super.network, required this.strategy, required this.source, this.memo});

  Future<Web3TransactionXRP?> _buildTransactions(BaseSwapXRPClient client);
}

class SwapRouteXRPNativeTransactionOperation extends SwapRouteXRPTransactionOperation
    implements SwapRouteTransactionTransferDetails<SwapXRPNetwork> {
  final XRPBaseAddress destination;
  @override
  final SwapAmount amount;
  SwapRouteXRPNativeTransactionOperation(
      {required this.amount,
      required super.source,
      required this.destination,
      required super.network,
      super.memo})
      : super(strategy: SwapRouteXRPTransactionStrategy.native);

  @override
  Future<Web3TransactionXRP> _buildTransactions(BaseSwapXRPClient client) async {
    final balance = await client.getAccountBalance(source);
    if (balance < amount.amount) {
      throw SwapConstants.insufficientAccountBalance;
    }
    final memo = switch (this.memo) {
      null => null,
      String memo => XRPLMemo(
          memoData: StringUtils.isHexBytes(memo)
              ? memo
              : BytesUtils.toHexString(StringUtils.encode(memo))),
    };
    SubmittableTransaction payment = Payment(
        destination: destination.address,
        destinationTag: destination.tag,
        memos: memo == null ? null : [memo],
        amount: XRPAmount(amount.amount),
        account: source.address,
        sourceTag: source.tag,
        fee: BigInt.zero,
        flags: [0]);
    payment = await client.filledTransactionRequirment(payment);
    payment = await client.simulateTransactionFee(payment);
    return Web3TransactionXRP(transaction: payment, account: source);
  }

  @override
  String get destinationAddress => destination.address;

  @override
  String get sourceAddress => source.address;

  @override
  final String? tokenAddress = null;
}
