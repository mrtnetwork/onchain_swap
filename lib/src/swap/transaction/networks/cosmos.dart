import 'package:blockchain_utils/signer/const/constants.dart';
import 'package:blockchain_utils/utils/numbers/rational/big_rational.dart';
import 'package:cosmos_sdk/cosmos_sdk.dart';
import 'package:on_chain_swap/src/exception/exception.dart';
import 'package:on_chain_swap/src/swap/transaction/transaction.dart';
import 'package:on_chain_swap/src/swap/types/types.dart';

enum SwapRouteCosmosTransactionStrategy { native }

class SwapRouteCosmosTransactionBuilder extends SwapRouteTransactionBuilder<
    CosmosBaseAddress,
    SwapCosmosNetwork,
    BaseSwapCosmosClient,
    Web3TransactionCosmos,
    Web3SignerCosmos,
    SwapRouteCosmosTransactionOperation> {
  SwapRouteCosmosTransactionBuilder(
      {required super.route, required super.params, required super.operations});
  @override
  Future<void> buildTransactions({
    required GETNETWORK<BaseSwapCosmosClient, SwapCosmosNetwork> client,
    required GETSIGNER<Web3SignerCosmos, CosmosBaseAddress> signer,
    required ONOPERATIONSTATUS stepsCallBack,
  }) async {
    for (final operation in operations) {
      stepsCallBack(TransactionOperationStep.client);
      final cosmosClient = await checkRouteAndClient(client, operation);
      stepsCallBack(TransactionOperationStep.generateTx);
      final signerInfo = await signer(operation.source);
      final signers = await signerInfo.signers();
      final transaction = await operation._buildTransactions(
          client: cosmosClient, signers: signers);
      stepsCallBack(TransactionOperationStep.signing);
      final signedTx = await signerInfo.signRaw(transaction);

      final txRaw = TxRaw(
          bodyBytes: signedTx.bodyBytes,
          authInfoBytes: signedTx.authBytes,
          signatures: [signedTx.signature]);
      stepsCallBack(TransactionOperationStep.broadcast);
      final txId = await cosmosClient.broadcastTransaction(txRaw.toBuffer());
      stepsCallBack(TransactionOperationStep.txHash, transactionHash: txId);
    }
  }
}

abstract class SwapRouteCosmosTransactionOperation
    extends SwapRouteTransactionOperation<SwapCosmosNetwork> {
  Future<Web3TransactionCosmos> _buildTransactions(
      {required BaseSwapCosmosClient client,
      required List<CosmosSpenderAddress> signers});
  final String? memo;
  final SwapRouteCosmosTransactionStrategy strategy;
  final CosmosBaseAddress source;
  final SwapAmount amount;
  const SwapRouteCosmosTransactionOperation(
      {required this.source,
      required this.amount,
      required super.network,
      required this.strategy,
      this.memo});
}

class SwapRouteCosmosNativeTransactionOperation
    extends SwapRouteCosmosTransactionOperation
    implements SwapRouteTransactionTransferDetails<SwapCosmosNetwork> {
  final CosmosBaseAddress destination;
  SwapRouteCosmosNativeTransactionOperation(
      {required super.amount,
      required super.source,
      required this.destination,
      required super.network,
      super.memo})
      : super(strategy: SwapRouteCosmosTransactionStrategy.native);

  @override
  Future<Web3TransactionCosmos> _buildTransactions(
      {required BaseSwapCosmosClient client,
      required List<CosmosSpenderAddress> signers}) async {
    final source = signers.firstWhere((e) => e.address == this.source,
        orElse: () => throw const DartOnChainSwapPluginException(
            "None of the connected accounts match the source address of the transaction."));
    final denom = client.chainInfo.native.denom;
    final feeToken = client.chainInfo.feeTokens[0];
    final balance = await client.getBalance(source.address);
    if (balance < amount.amount) {
      // throw SwapConstants.insufficientAccountBalance;
    }
    final chainId = await client.chainId();
    final txRequirement =
        await client.getSwapTransactionRequirment(source.address);
    final signerInfo = SignerInfo(
        publicKey: source.publicKey.toAny(),
        modeInfo: const ModeInfo(ModeInfoSignle(SignMode.signModeDirect)),
        sequence: txRequirement.account.sequence);
    AuthInfo authInfo = AuthInfo(
        signerInfos: [signerInfo],
        fee: Fee(
            amount: [Coin(denom: feeToken.denom, amount: BigInt.from(10000))]));
    final message = MsgSend(
        fromAddress: source.address,
        toAddress: destination,
        amount: [Coin(denom: denom, amount: amount.amount)]);
    final txbody = TXBody(messages: [message], memo: memo);
    final tx = Tx(body: txbody, authInfo: authInfo, signatures: [
      List<int>.filled(CryptoSignerConst.ecdsaSignatureLength, 0)
    ]);
    final simulate = await client.simulateTx(tx.toBuffer());
    final fixedFee = txRequirement.fixedNativeGas;
    Fee fee;
    if (fixedFee != null) {
      fee = Fee(amount: [
        Coin(denom: feeToken.denom, amount: fixedFee),
      ], gasLimit: simulate.gasInfo.gasUsed);
    } else {
      BigRational gasPrice = BigRational.parseDecimal("0.025");

      if (txRequirement.ethermintTxFee != null) {
        gasPrice = txRequirement.ethermintTxFee!;
      } else if (feeToken.averageGasPrice != null) {
        gasPrice =
            BigRational.parseDecimal(feeToken.averageGasPrice!.toString());
      }
      final gp = (BigRational(simulate.gasInfo.gasUsed) *
          BigRational.parseDecimal("1.4"));
      final feeAmount = (gp * gasPrice).ceil();
      fee = Fee(
          gasLimit: gp.toBigInt(),
          amount: [Coin(denom: feeToken.denom, amount: feeAmount.toBigInt())]);
    }
    authInfo = authInfo.copyWith(fee: fee);
    final signDoc = SignDoc(
        bodyBytes: txbody.toBuffer(),
        authInfoBytes: authInfo.toBuffer(),
        chainId: chainId,
        accountNumber: txRequirement.account.accountNumber);
    return Web3TransactionCosmos(signDoc: signDoc, source: source);
  }

  @override
  String get destinationAddress => destination.address;

  @override
  String get sourceAddress => source.address;

  @override
  final String? tokenAddress = null;
}
