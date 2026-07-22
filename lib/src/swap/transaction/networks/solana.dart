import 'package:on_chain/on_chain.dart';
import 'package:on_chain_swap/src/exception/exception.dart';
import 'package:on_chain_swap/src/swap/constants/constants.dart';
import 'package:on_chain_swap/src/swap/transaction/transaction.dart';
import 'package:on_chain_swap/src/swap/types/types.dart';

enum SwapRouteSolanaTransactionStrategy { native, token }

class SwapRouteSolanaTransactionBuilder extends SwapRouteTransactionBuilder<
    SolAddress,
    SwapSolanaNetwork,
    BaseSwapSolanaClient,
    Web3TransactionSolana,
    Web3SignerSolana,
    SwapRouteSolanaTransactionOperation> {
  final TransactionExcuteMode mode;
  SwapRouteSolanaTransactionBuilder(
      {required super.route,
      required super.params,
      required super.operations,
      this.mode = TransactionExcuteMode.serial});

  @override
  Future<void> buildTransactions({
    required CbGetRouteNetwork<BaseSwapSolanaClient, SwapSolanaNetwork> client,
    required CbGetSigner<Web3SignerSolana, SolAddress> signer,
    required CbOnStatusChanged stepsCallBack,
  }) async {
    for (final operation in operations) {
      stepsCallBack(TransactionOperationStep.client);
      final solanaClient = await checkRouteAndClient(client, operation);
      stepsCallBack(TransactionOperationStep.generateTx);
      final transaction = await operation._buildTransactions(solanaClient);
      stepsCallBack(TransactionOperationStep.signing);
      final signerInfo = await signer(operation.source);
      final signers = await signerInfo.signers();
      signers.firstWhere((e) => e == operation.source,
          orElse: () => throw const DartOnChainSwapPluginException(
              "None of the connected accounts match the source address of the transaction."));
      final tx = await signerInfo.signTransaction(transaction);
      stepsCallBack(TransactionOperationStep.broadcast);
      final txId = await solanaClient.sendTransaction(tx);
      stepsCallBack(TransactionOperationStep.txHash, transactionHash: txId);
      if (mode.isSerial) {
        await solanaClient.trackTransaction(transactionId: txId);
      }
    }
  }
}

abstract class SwapRouteSolanaTransactionOperation
    extends SwapRouteTransactionOperation<SwapSolanaNetwork> {
  Future<Web3TransactionSolana> _buildTransactions(BaseSwapSolanaClient client);
  // final String? memo;
  final SwapRouteSolanaTransactionStrategy strategy;
  final SolAddress source;
  final SwapAmount amount;
  const SwapRouteSolanaTransactionOperation(
      {required this.source,
      required this.amount,
      required super.network,
      required this.strategy});
}

class SwapRouteSolanaNativeTransactionOperation
    extends SwapRouteSolanaTransactionOperation
    implements SwapRouteTransactionTransferDetails<SwapSolanaNetwork> {
  final SolAddress destination;
  @override
  final String? memo;
  SwapRouteSolanaNativeTransactionOperation({
    required super.amount,
    required super.source,
    required this.destination,
    required super.network,
  })  : memo = null,
        super(strategy: SwapRouteSolanaTransactionStrategy.native);

  @override
  Future<Web3TransactionSolana> _buildTransactions(BaseSwapSolanaClient client) async {
    final account = await client.getAccountInfo(source);
    if (account == null) {
      throw const DartOnChainSwapPluginException("Source account not found.");
    }
    if (account.owner != SystemProgramConst.programId) {
      throw const DartOnChainSwapPluginException(
          "Invalid source account owner: the source account must be owned by the system program.");
    }
    if (account.lamports < amount.amount) {
      throw SwapConstants.insufficientAccountBalance;
    }
    final transfer = SystemProgram.transfer(
        layout: SystemTransferLayout(lamports: amount.amount),
        from: source,
        to: destination);
    final transaction = SolanaTransaction(
        payerKey: source,
        instructions: [transfer],
        recentBlockhash: SolAddress.defaultPubKey);
    final simulate = await client.simulate(transaction: transaction);
    if (simulate.err != null) {
      throw DartOnChainSwapPluginException(
          "Solana transaction simulation failed with error: ${simulate.err}");
    }
    final blockhash = await client.getBlockHash();
    final v0 = SolanaTransaction(
        payerKey: source,
        instructions: [transfer],
        recentBlockhash: blockhash,
        type: TransactionType.v0);
    final legacy = SolanaTransaction(
        payerKey: source,
        instructions: [transfer],
        recentBlockhash: blockhash,
        type: TransactionType.legacy);
    return Web3TransactionSolana(v0: v0, legacy: legacy, source: source);
  }

  @override
  String get destinationAddress => destination.address;

  @override
  String get sourceAddress => source.address;

  @override
  final String? tokenAddress = null;
}

class SwapRouteSolanaSendTokenTransactionOperation
    extends SwapRouteSolanaTransactionOperation
    implements SwapRouteTransactionTransferDetails<SwapSolanaNetwork> {
  final SolAddress contract;
  final SolAddress destination;
  SwapRouteSolanaSendTokenTransactionOperation(
      {required super.amount,
      required super.source,
      required this.destination,
      required super.network,
      required this.contract})
      : super(strategy: SwapRouteSolanaTransactionStrategy.token);

  @override
  Future<Web3TransactionSolana> _buildTransactions(BaseSwapSolanaClient client) async {
    final account = await client.getAccountInfo(source);
    if (account == null) {
      throw const DartOnChainSwapPluginException("Source account not found.");
    }
    if (account.owner != SystemProgramConst.programId) {
      throw const DartOnChainSwapPluginException(
          "Invalid source account owner: the source account must be owned by the system program.");
    }
    final tokenBalance = await client.getTokenBalance(account: source, mint: contract);
    if (tokenBalance < amount.amount) {
      throw SwapConstants.insufficientAccountBalance;
    }
    final destinationPdaInfo =
        await client.getTokenAccountAddress(account: destination, mint: contract);

    final ownerPda = AssociatedTokenAccountProgramUtils.associatedTokenAccount(
        mint: contract, owner: source, tokenProgramId: destinationPdaInfo.tokenProgramId);

    final destinationInfo = await client.getAccountInfo(destinationPdaInfo.pdaAddress);
    TransactionInstruction? ascAccout;
    if (destinationInfo == null) {
      ascAccout = AssociatedTokenAccountProgram.associatedTokenAccount(
          payer: source,
          associatedToken: destinationPdaInfo.pdaAddress,
          owner: destination,
          mint: contract,
          tokenProgramId: destinationPdaInfo.tokenProgramId);
    }

    final transfer = SPLTokenProgram.transfer(
        layout: SPLTokenTransferLayout(amount: amount.amount),
        owner: source,
        source: ownerPda.address,
        programId: destinationPdaInfo.tokenProgramId,
        destination: destinationPdaInfo.pdaAddress);
    final List<TransactionInstruction> instructions = [
      if (ascAccout != null) ascAccout,
      transfer
    ];
    final transaction = SolanaTransaction(
        payerKey: source,
        instructions: instructions,
        recentBlockhash: SolAddress.defaultPubKey);
    final simulate = await client.simulate(transaction: transaction);
    if (simulate.err != null) {
      throw DartOnChainSwapPluginException(
          "Solana transaction simulation failed with error: ${simulate.err}");
    }
    final blockhash = await client.getBlockHash();
    final v0 = SolanaTransaction(
        payerKey: source,
        instructions: instructions,
        recentBlockhash: blockhash,
        type: TransactionType.v0);
    final legacy = SolanaTransaction(
        payerKey: source,
        instructions: instructions,
        recentBlockhash: blockhash,
        type: TransactionType.legacy);
    return Web3TransactionSolana(v0: v0, legacy: legacy, source: source);
  }

  @override
  String get destinationAddress => destination.address;

  @override
  String? get memo => null;

  @override
  String get sourceAddress => source.address;

  @override
  String get tokenAddress => contract.address;
}
