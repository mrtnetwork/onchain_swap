import 'package:blockchain_utils/helper/extensions/extensions.dart';
import 'package:blockchain_utils/utils/binary/utils.dart';
import 'package:blockchain_utils/utils/string/string.dart';
import 'package:on_chain/solidity/contract/fragments.dart';
import 'package:on_chain/tron/tron.dart';
import 'package:on_chain_swap/src/exception/exception.dart';
import 'package:on_chain_swap/src/swap/constants/constants.dart';
import 'package:on_chain_swap/src/swap/transaction/transaction.dart';
import 'package:on_chain_swap/src/swap/types/types.dart';

enum SwapRouteTronTransactionStrategy { native, token, aprove, callContract }

class SwapRouteTronTransactionBuilder extends SwapRouteTransactionBuilder<
    TronAddress,
    SwapTronNetwork,
    BaseSwapTronClient,
    Web3TransactionTron,
    Web3SignerTron,
    SwapRouteTronTransactionOperation> {
  final TransactionExcuteMode mode;
  SwapRouteTronTransactionBuilder(
      {required super.route,
      required super.params,
      required super.operations,
      this.mode = TransactionExcuteMode.serial});

  @override
  Future<void> buildTransactions({
    required CbGetRouteNetwork<BaseSwapTronClient, SwapTronNetwork> client,
    required CbGetSigner<Web3SignerTron, TronAddress> signer,
    required CbOnStatusChanged stepsCallBack,
  }) async {
    for (final operation in operations) {
      stepsCallBack(TransactionOperationStep.client);
      final tronClient = await checkRouteAndClient(client, operation);
      stepsCallBack(TransactionOperationStep.generateTx);
      final transaction = await operation._buildTransactions(tronClient);
      if (transaction == null) continue;
      stepsCallBack(TransactionOperationStep.signing);
      final signerInfo = await signer(transaction.transaction.rawData.ownerAddress);
      final signers = await signerInfo.signers();
      signers.firstWhere((e) => e == operation.source,
          orElse: () => throw const DartOnChainSwapPluginException(
              "None of the connected accounts match the source address of the transaction."));
      stepsCallBack(TransactionOperationStep.broadcast);
      final signedTx = await signerInfo.signTransaction(transaction);

      final txId = await tronClient.sendTransaction(signedTx.toHex);
      if (!txId.result) {
        throw DartOnChainSwapPluginException(
            txId.message ?? "Transaction submission failed.");
      }
      stepsCallBack(TransactionOperationStep.txHash, transactionHash: txId.txid);
      if (mode.isSerial) {
        final result = await tronClient.trackTransaction(transactionId: txId.txid);
        if (!result.isSuccess) {
          throw const DartOnChainSwapPluginException("Transaction confirmation failed.");
        }
      }
    }
  }
}

abstract class SwapRouteTronTransactionOperation
    extends SwapRouteTransactionOperation<SwapTronNetwork> {
  final String? memo;
  final SwapRouteTronTransactionStrategy strategy;
  final TronAddress source;
  const SwapRouteTronTransactionOperation(
      {required super.network, required this.strategy, required this.source, this.memo});

  Future<Web3TransactionTron?> _buildTransactions(BaseSwapTronClient client);

  Future<Web3TransactionTron> createTransaction({
    required TronBaseContract contract,
    required BaseSwapTronClient client,
  }) async {
    final permissionId =
        await client.getAccountPermissionId(address: source, contract: contract);
    final transactionContract = TransactionContract(
        type: contract.contractType,
        permissionId: permissionId,
        parameter: Any(typeUrl: contract.typeURL, value: contract));
    final blockData =
        await client.transactionBlockRequirment(expiration: const Duration(minutes: 10));
    TransactionRaw transaction = TransactionRaw(
        data: switch (memo) { null => null, String memo => StringUtils.encode(memo) },
        refBlockBytes: blockData.refBlockBytes,
        refBlockHash: blockData.refBlockHash,
        expiration: blockData.expiration,
        contract: [transactionContract],
        timestamp: blockData.timestamp);
    if (contract.contractType == TransactionContractType.triggerSmartContract) {
      transaction = transaction.copyWith(feeLimit: BigInt.from(15000000000));
      final feeLimit = await client.getTransactionFeeLimit(transaction);
      transaction = transaction.copyWith(feeLimit: feeLimit);
    }
    return Web3TransactionTron(
        transaction: Transaction(rawData: transaction, signature: []));
  }
}

class SwapRouteTronNativeTransactionOperation extends SwapRouteTronTransactionOperation
    implements SwapRouteTransactionTransferDetails<SwapTronNetwork> {
  final TronAddress destination;
  @override
  final SwapAmount amount;
  SwapRouteTronNativeTransactionOperation(
      {required this.amount,
      required super.source,
      required this.destination,
      required super.network,
      super.memo})
      : super(strategy: SwapRouteTronTransactionStrategy.native);

  @override
  Future<Web3TransactionTron> _buildTransactions(BaseSwapTronClient client) async {
    final balance = await client.getBalance(source);
    if (balance < amount.amount) {
      throw SwapConstants.insufficientAccountBalance;
    }
    final contract = TransferContract(
        ownerAddress: source, toAddress: destination, amount: amount.amount);
    return await createTransaction(contract: contract, client: client);
  }

  @override
  String get destinationAddress => destination.address;

  @override
  String get sourceAddress => source.address;

  @override
  final String? tokenAddress = null;
}

class SwapRouteTronSendTokenTransactionOperation extends SwapRouteTronTransactionOperation
    implements SwapRouteTransactionTransferDetails<SwapTronNetwork> {
  final TronAddress contract;
  final TronAddress destination;
  @override
  final SwapAmount amount;
  SwapRouteTronSendTokenTransactionOperation(
      {required this.amount,
      required super.source,
      required this.destination,
      required super.network,
      required this.contract,
      super.memo})
      : super(strategy: SwapRouteTronTransactionStrategy.token);
  @override
  Future<Web3TransactionTron> _buildTransactions(BaseSwapTronClient client) async {
    final tokenBalance = await client.getTrc20TokenBalance(
        address: source, contractAddress: this.contract);
    if (tokenBalance < amount.amount) {
      throw SwapConstants.insufficientTokenBalance;
    }
    final encodeParams =
        EthereumAbiConst.transferFragment.encode([destination, amount.amount]);
    final contract = TriggerSmartContract(
      ownerAddress: source,
      contractAddress: this.contract,
      data: encodeParams,
    );
    return await createTransaction(contract: contract, client: client);
  }

  @override
  String get destinationAddress => destination.address;

  @override
  String get sourceAddress => source.address;

  @override
  String get tokenAddress => contract.address;
}

class SwapRouteTronAproveTransactionOperation extends SwapRouteTronTransactionOperation
    implements SwapRouteTransactionContractDetails<SwapTronNetwork> {
  final TronAddress contract;
  final TronAddress spender;
  @override
  final SwapAmount amount;
  @override
  final String data;
  @override
  final String functionName;
  SwapRouteTronAproveTransactionOperation({
    required this.amount,
    required super.source,
    required this.spender,
    required super.network,
    required this.contract,
  })  : functionName = EthereumAbiConst.approve.name,
        data = BytesUtils.toHexString(
            EthereumAbiConst.approve.encode([spender, amount.amount]),
            prefix: "0x"),
        super(strategy: SwapRouteTronTransactionStrategy.aprove);

  @override
  String get sourceAddress => source.address;
  @override
  String get contractAddress => contract.address;
  @override
  Future<Web3TransactionTron?> _buildTransactions(BaseSwapTronClient client) async {
    final tokenBalance = await client.getTrc20TokenBalance(
        address: source, contractAddress: this.contract);
    if (tokenBalance < amount.amount) {
      throw SwapConstants.insufficientTokenBalance;
    }
    final allowance = await client.getAllowance(
        contract: this.contract, owner: source, spender: spender);
    if (allowance >= amount.amount) return null;
    final contract = TriggerSmartContract(
      ownerAddress: source,
      contractAddress: this.contract,
      data: BytesUtils.fromHexString(data),
    );
    return await createTransaction(contract: contract, client: client);
  }
}

class SwapRouteTronCallContractTransactionOperation
    extends SwapRouteTronTransactionOperation
    implements SwapRouteTransactionContractDetails<SwapTronNetwork> {
  final TronAddress contract;
  final AbiFunctionFragment method;
  final List<dynamic> params;
  final BigInt? value;
  @override
  final String data;

  @override
  final SwapAmount? amount = null;

  @override
  String get contractAddress => contract.address;

  @override
  String get functionName => method.name;

  @override
  String get sourceAddress => source.address;

  SwapRouteTronCallContractTransactionOperation(
      {required super.network,
      required this.contract,
      required this.method,
      required super.source,
      this.value,
      String? data,
      required List<dynamic> params})
      : params = params.immutable,
        data = data ?? BytesUtils.toHexString(method.encode(params), prefix: '0x'),
        super(strategy: SwapRouteTronTransactionStrategy.callContract);

  @override
  Future<Web3TransactionTron?> _buildTransactions(BaseSwapTronClient client) async {
    final contract = TriggerSmartContract(
        ownerAddress: source,
        callValue: value,
        contractAddress: this.contract,
        data: BytesUtils.fromHexString(data));
    return await createTransaction(contract: contract, client: client);
  }
}
