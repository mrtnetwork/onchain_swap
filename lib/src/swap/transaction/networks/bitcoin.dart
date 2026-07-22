import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:on_chain_swap/src/exception/exception.dart';
import 'package:on_chain_swap/src/swap/constants/constants.dart';
import 'package:on_chain_swap/src/swap/transaction/transaction.dart';
import 'package:on_chain_swap/src/swap/types/types.dart';

enum SwapRouteBitcoinTransactionStrategy { native }

class SwapRouteBitcoinTransactionBuilder extends SwapRouteTransactionBuilder<
    BitcoinNetworkAddress,
    SwapBitcoinNetwork,
    BaseSwapBitcoinClient,
    Web3TransactionBitcoin,
    Web3SignerBitcoin,
    SwapRouteBitcoinTransactionOperation> {
  SwapRouteBitcoinTransactionBuilder(
      {required super.route, required super.params, required super.operations});

  @override
  Future<void> buildTransactions({
    required CbGetRouteNetwork<BaseSwapBitcoinClient, SwapBitcoinNetwork> client,
    required CbGetSigner<Web3SignerBitcoin, BitcoinNetworkAddress> signer,
    required CbOnStatusChanged stepsCallBack,
  }) async {
    for (final operation in operations) {
      stepsCallBack(TransactionOperationStep.client);
      final bitcoinClient = await checkRouteAndClient(client, operation);
      stepsCallBack(TransactionOperationStep.generateTx);
      final signerInfo = await signer(operation.source);
      final sources = await signerInfo.signers();
      final transaction = await operation._buildTransactions(bitcoinClient, sources);
      switch (signerInfo.signingSchames) {
        case BitcoinSigningScheme.psbt:
          stepsCallBack(TransactionOperationStep.signing);
          final psbt = await signerInfo.signPsbt(transaction);
          final psbtBuilder = PsbtBuilder.fromBase64(psbt);
          final finalTx = psbtBuilder.finalizeAll();
          stepsCallBack(TransactionOperationStep.broadcast);
          final txId = await bitcoinClient.sendTransaction(finalTx);
          stepsCallBack(TransactionOperationStep.txHash, transactionHash: txId);
          break;
        case BitcoinSigningScheme.sendPayment:
          stepsCallBack(TransactionOperationStep.broadcast);
          final txId = await signerInfo.sendPayment(transaction);
          stepsCallBack(TransactionOperationStep.txHash, transactionHash: txId);
          break;
      }
    }
    stepsCallBack(TransactionOperationStep.complete);
  }
}

abstract class SwapRouteBitcoinTransactionOperation
    extends SwapRouteTransactionOperation<SwapBitcoinNetwork> {
  final String? memo;
  final SwapRouteBitcoinTransactionStrategy strategy;
  final BitcoinNetworkAddress source;

  final BitcoinNetworkAddress destination;
  // final List<BitcoinSpenderAddress> sources;
  final SwapAmount amount;

  Future<Web3TransactionBitcoin> _buildTransactions(
      BaseSwapBitcoinClient client, List<BitcoinSpenderAddress> sources);

  SwapRouteBitcoinTransactionOperation(
      {required this.destination,
      required this.amount,
      required super.network,
      required this.strategy,
      required this.source,
      this.memo});
}

class SwapRouteBitcoinNativeTransactionOperation
    extends SwapRouteBitcoinTransactionOperation
    implements SwapRouteTransactionTransferDetails<SwapBitcoinNetwork> {
  SwapRouteBitcoinNativeTransactionOperation(
      {required super.amount,
      required super.destination,
      required super.network,
      required super.source,
      super.memo})
      : super(strategy: SwapRouteBitcoinTransactionStrategy.native);

  @override
  Future<Web3TransactionBitcoin> _buildTransactions(
      BaseSwapBitcoinClient client, List<BitcoinSpenderAddress> sources) async {
    sources = sources.clone();
    final sourceAddress = sources.firstWhere((e) => e.address.address == source.address,
        orElse: () => throw const DartOnChainSwapPluginException(
            "None of the connected accounts match the source address of the transaction."));
    sources.sort((a, b) {
      if (a.address.address == source.address) return -1;
      if (b.address.address == source.address) return 1;
      return 0;
    });
    final utxos = await client.getAccountsUtxos(sources);
    final balance = utxos.fold<BigInt>(BigInt.zero, (p, c) => p + c.utxo.value);
    if (balance < amount.amount) {
      throw SwapConstants.insufficientAccountBalance;
    }
    if (!utxos.any((e) => e.scriptPubKey == source.baseAddress.toScriptPubKey())) {
      throw const DartOnChainSwapPluginException(
          "Source account not found. It must contribute at least one UTXO to the transaction.");
    }
    final feeRate = await client.estimateFeePerByte(network);
    final psbt = PsbtBuilderV0.create();
    psbt.addUtxos(utxos);
    psbt.addOutput(
        PsbtTransactionOutput(amount: amount.amount, address: destination.baseAddress));
    psbt.addOutput(PsbtTransactionOutput(
        amount: BigInt.zero, address: sources[0].address.baseAddress));
    if (memo != null) {
      final memoBytes = StringUtils.encode(memo!);
      psbt.addOutput(PsbtTransactionOutput(
          amount: BigInt.zero,
          scriptPubKey: BitcoinScriptUtils.buildOpReturn([memoBytes])));
    }

    /// 1674
    final size = psbt.getUnSafeTransactionSize();
    final fee = (BigRational.from(size) * feeRate).ceil().toBigInt();
    final total = fee + amount.amount;
    if (total > balance) {
      throw SwapConstants.insufficientAccountBalance;
    }
    final change = balance - total;
    if (change == BigInt.zero) {
      psbt.removeOutput(1);
    } else {
      psbt.updateOutput(1,
          PsbtTransactionOutput(amount: change, address: sources[0].address.baseAddress));
    }
    return Web3TransactionBitcoin(source: sourceAddress, psbt: psbt.toBase64(), outputs: [
      Web3TransactionBitcoinOutputs(
          address: destination.address,
          script: destination.baseAddress.toScriptPubKey(),
          value: amount.amount),
      if (memo != null)
        Web3TransactionBitcoinOutputs(
            value: BigInt.zero,
            script: BitcoinScriptUtils.buildOpReturn([StringUtils.encode(memo!)]))
    ]);
  }

  @override
  String get destinationAddress => destination.address;

  @override
  String get sourceAddress => source.address;

  @override
  final String? tokenAddress = null;
}
