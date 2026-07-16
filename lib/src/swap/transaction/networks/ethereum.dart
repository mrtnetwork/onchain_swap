import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:on_chain/ethereum/ethereum.dart';
import 'package:on_chain/on_chain.dart' show AbiFunctionFragment;
import 'package:on_chain_swap/src/exception/exception.dart';
import 'package:on_chain_swap/src/swap/constants/constants.dart';
import 'package:on_chain_swap/src/swap/transaction/transaction.dart';
import 'package:on_chain_swap/src/swap/types/types.dart';

enum SwapRouteEthereumTransactionStrategy {
  native,
  token,
  aprove,
  callContract
}

class SwapRouteEthereumTransactionBuilder extends SwapRouteTransactionBuilder<
    ETHAddress,
    SwapEthereumNetwork,
    BaseSwapEthereumClient,
    Web3TransactionEthereum,
    Web3SignerEthereum,
    SwapRouteEthereumTransactionOperation> {
  final TransactionExcuteMode mode;
  SwapRouteEthereumTransactionBuilder(
      {required super.route,
      required super.params,
      required super.operations,
      this.mode = TransactionExcuteMode.serial});

  @override
  Future<void> buildTransactions({
    required CbGetRouteNetwork<BaseSwapEthereumClient, SwapEthereumNetwork>
        client,
    required CbGetSigner<Web3SignerEthereum, ETHAddress> signer,
    required CbOnStatusChanged stepsCallBack,
  }) async {
    for (final operation in operations) {
      stepsCallBack(TransactionOperationStep.client);
      final ethereumClient = await checkRouteAndClient(client, operation);
      stepsCallBack(TransactionOperationStep.generateTx);
      final transaction = await operation._buildTransactions(ethereumClient);
      if (transaction == null) continue;
      stepsCallBack(TransactionOperationStep.signing);
      final signerInfo = await signer(transaction.from);
      final signers = await signerInfo.signers();
      signers.firstWhere((e) => e == operation.source,
          orElse: () => throw const DartOnChainSwapPluginException(
              "None of the connected accounts match the source address of the transaction."));
      stepsCallBack(TransactionOperationStep.broadcast);
      final transactionId = await signerInfo.excuteTransaction(transaction);
      stepsCallBack(TransactionOperationStep.txHash,
          transactionHash: transactionId);
      if (mode.isSerial) {
        await ethereumClient.trackTransaction(transactionId: transactionId);
      }
    }
  }
}

abstract class SwapRouteEthereumTransactionOperation
    extends SwapRouteTransactionOperation<SwapEthereumNetwork> {
  final String? memo;
  final SwapRouteEthereumTransactionStrategy strategy;
  final ETHAddress source;
  const SwapRouteEthereumTransactionOperation(
      {required super.network,
      required this.strategy,
      required this.source,
      this.memo});
  ETHTransactionType? _txType(BigInt chainId) {
    return switch (chainId.toString()) {
      '1' || "42161" || "8453" || "43114" => ETHTransactionType.eip1559,
      "56" => ETHTransactionType.legacy,
      _ => null
    };
  }

  Future<Web3TransactionEthereum?> _buildTransactions(
      BaseSwapEthereumClient client);
}

class SwapRouteEthereumNativeTransactionOperation
    extends SwapRouteEthereumTransactionOperation
    implements SwapRouteTransactionTransferDetails<SwapEthereumNetwork> {
  final ETHAddress destination;
  @override
  final SwapAmount amount;
  SwapRouteEthereumNativeTransactionOperation(
      {required this.amount,
      required super.source,
      required this.destination,
      required super.network,
      super.memo})
      : super(strategy: SwapRouteEthereumTransactionStrategy.native);

  @override
  Future<Web3TransactionEthereum> _buildTransactions(
      BaseSwapEthereumClient client) async {
    final balance = await client.getBalance(source);
    if (balance < amount.amount) {
      throw SwapConstants.insufficientAccountBalance;
    }
    final transactionBuilder = ETHTransactionBuilder(
        from: source,
        to: destination,
        value: amount.amount,
        chainId: network.chainId,
        transactionType: _txType(network.chainId),
        data: StringUtils.tryEncode(memo));
    await transactionBuilder.autoFill(client.provider);
    return Web3TransactionEthereum(
        value: amount.amount,
        to: destination,
        from: source,
        data: BytesUtils.toHexString(
            memo == null ? [] : StringUtils.encode(memo!),
            prefix: '0x'),
        gasLimit: transactionBuilder.gasLimit!,
        transactionType: transactionBuilder.type!,
        chainId: network.chainId,
        gasPrice: transactionBuilder.gasPrice);
  }

  @override
  String get destinationAddress => destination.address;

  @override
  String get sourceAddress => source.address;

  @override
  final String? tokenAddress = null;
}

class SwapRouteEthereumSendTokenTransactionOperation
    extends SwapRouteEthereumTransactionOperation
    implements SwapRouteTransactionTransferDetails<SwapEthereumNetwork> {
  final ETHAddress contract;
  final ETHAddress destination;
  @override
  final SwapAmount amount;
  SwapRouteEthereumSendTokenTransactionOperation(
      {required this.amount,
      required super.source,
      required this.destination,
      required super.network,
      required this.contract})
      : super(strategy: SwapRouteEthereumTransactionStrategy.token);
  @override
  Future<Web3TransactionEthereum> _buildTransactions(
      BaseSwapEthereumClient client) async {
    final balance = await client.getBalance(source);
    if (balance == BigInt.zero) {
      throw SwapConstants.insufficientAccountBalance;
    }
    final tokenBalance =
        await client.getTokenBalance(address: source, contract: contract);
    if (tokenBalance < amount.amount) {
      throw SwapConstants.insufficientTokenBalance;
    }
    final encodeParams =
        EthereumAbiCons.transferFragment.encode([destination, amount.amount]);
    final transactionBuilder = ETHTransactionBuilder.contract(
        from: source,
        contractAddress: contract,
        function: EthereumAbiCons.transferFragment,
        functionParams: [destination, amount.amount],
        value: BigInt.zero,
        chainId: network.chainId,
        transactionType: _txType(network.chainId));
    await transactionBuilder.autoFill(client.provider);
    return Web3TransactionEthereum(
        value: BigInt.zero,
        to: contract,
        from: source,
        data: BytesUtils.toHexString(encodeParams, prefix: '0x'),
        gasLimit: transactionBuilder.gasLimit!,
        transactionType: transactionBuilder.type!,
        chainId: network.chainId,
        gasPrice: transactionBuilder.gasPrice);
  }

  @override
  String get destinationAddress => destination.address;

  @override
  String get sourceAddress => source.address;

  @override
  String get tokenAddress => contract.address;
}

class SwapRouteEthereumAproveTransactionOperation
    extends SwapRouteEthereumTransactionOperation
    implements SwapRouteTransactionContractDetails<SwapEthereumNetwork> {
  final ETHAddress contract;
  final ETHAddress spender;
  @override
  final SwapAmount amount;
  SwapRouteEthereumAproveTransactionOperation(
      {required this.amount,
      required super.source,
      required this.spender,
      required super.network,
      required this.contract})
      : functionName = EthereumAbiCons.approve.name,
        data = BytesUtils.toHexString(
            EthereumAbiCons.approve.encode([spender, amount.amount]),
            prefix: "0x"),
        super(strategy: SwapRouteEthereumTransactionStrategy.aprove);

  @override
  Future<Web3TransactionEthereum?> _buildTransactions(
      BaseSwapEthereumClient client) async {
    final balance = await client.getBalance(source);
    if (balance == BigInt.zero) {
      throw SwapConstants.insufficientAccountBalance;
    }
    final tokenBalance =
        await client.getTokenBalance(address: source, contract: contract);
    if (tokenBalance < amount.amount) {
      throw SwapConstants.insufficientTokenBalance;
    }
    final allowance = await client.getAllowance(
        contract: contract, owner: source, spender: spender);
    if (allowance >= amount.amount) return null;
    final transactionBuilder = ETHTransactionBuilder.contract(
        from: source,
        contractAddress: contract,
        function: EthereumAbiCons.approve,
        functionParams: [spender, amount.amount],
        value: BigInt.zero,
        chainId: network.chainId,
        transactionType: _txType(network.chainId));
    await transactionBuilder.autoFill(client.provider);
    return Web3TransactionEthereum(
        value: BigInt.zero,
        to: contract,
        from: source,
        data: data,
        gasLimit: transactionBuilder.gasLimit!,
        transactionType: transactionBuilder.type!,
        chainId: network.chainId,
        gasPrice: transactionBuilder.gasPrice);
  }

  @override
  String get contractAddress => contract.address;

  @override
  final String data;

  @override
  final String functionName;

  @override
  String get sourceAddress => source.address;
}

class SwapRouteEthereumCallContractTransactionOperation
    extends SwapRouteEthereumTransactionOperation
    implements SwapRouteTransactionContractDetails<SwapEthereumNetwork> {
  final ETHAddress contract;
  final AbiFunctionFragment method;
  final List<dynamic> params;
  final BigInt? value;

  SwapRouteEthereumCallContractTransactionOperation(
      {required super.network,
      required this.contract,
      required this.method,
      required super.source,
      this.value,
      String? data,
      required List<dynamic> params})
      : params = params.immutable,
        data =
            data ?? BytesUtils.toHexString(method.encode(params), prefix: '0x'),
        super(strategy: SwapRouteEthereumTransactionStrategy.callContract);
  @override
  Future<Web3TransactionEthereum?> _buildTransactions(
      BaseSwapEthereumClient client) async {
    final balance = await client.getBalance(source);
    if (balance == BigInt.zero) {
      throw SwapConstants.insufficientAccountBalance;
    }

    // final encodeParams = method.encode(params);
    final BigInt value = this.value ?? BigInt.zero;
    final transactionBuilder = ETHTransactionBuilder.contract(
        from: source,
        contractAddress: contract,
        function: method,
        functionParams: params,
        value: value,
        chainId: network.chainId,
        transactionType: _txType(network.chainId));
    await transactionBuilder.autoFill(client.provider);
    return Web3TransactionEthereum(
        value: value,
        to: contract,
        from: source,
        data: data,
        gasLimit: transactionBuilder.gasLimit!,
        transactionType: transactionBuilder.type!,
        chainId: network.chainId,
        gasPrice: transactionBuilder.gasPrice);
  }

  @override
  final SwapAmount? amount = null;

  @override
  String get contractAddress => contract.address;

  @override
  final String data;

  @override
  String get functionName => method.name;

  @override
  String get sourceAddress => source.address;
}
