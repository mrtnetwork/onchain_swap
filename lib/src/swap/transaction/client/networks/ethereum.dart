import 'dart:async';
import 'package:on_chain/solidity/address/core.dart';
import 'package:on_chain_swap/src/swap/transaction/const/const.dart';
import 'package:on_chain/ethereum/ethereum.dart';
import 'package:on_chain_swap/src/swap/transaction/client/core/client.dart';
import 'package:on_chain_swap/src/exception/exception.dart';
import 'package:on_chain_swap/src/swap/transaction/types/types.dart';
import 'package:on_chain_swap/src/swap/types/types.dart';

class SwapEthereumClient implements BaseSwapEthereumClient {
  @override
  final EthereumProvider provider;
  final SwapEthereumNetwork network;
  BigInt? _chainId;
  SwapEthereumClient({required this.provider, required this.network});
  static Future<SwapEthereumClient> check({
    required EthereumProvider provider,
    required SwapEthereumNetwork network,
  }) async {
    final client = SwapEthereumClient(provider: provider, network: network);
    if (!(await client.initSwapClient())) {
      throw const DartOnChainSwapPluginException(
          "The Chain ID is not compatible with the current network.");
    }
    return SwapEthereumClient(provider: provider, network: network);
  }

  @override
  Future<BigInt> getBalance(ETHAddress address) async {
    return await provider.request(EthereumRequestGetBalance(address: address.address));
  }

  @override
  Future<BigInt> getChainId() async {
    if (_chainId != null) return _chainId!;
    _chainId = await provider.request(EthereumRequestGetChainId());
    return _chainId!;
  }

  @override
  Future<BigInt> getAllowance(
      {required ETHAddress contract,
      required ETHAddress owner,
      required ETHAddress spender}) async {
    final function = EthereumAbiConst.getAllowance;
    final result = await provider.request(EthereumRequestCall.fromMethod(
        contractAddress: contract.address, function: function, params: [owner, spender]));
    return (result as List)[0];
  }

  @override
  Future<BigInt> getTokenBalance(
      {required SolidityAddress address, required SolidityAddress? contract}) async {
    if (contract == null) {
      throw const DartOnChainSwapPluginException("missing token contract address.");
    }
    final function = EthereumAbiConst.erc20BalaceFragment;
    final result = await provider.request(EthereumRequestFunctionCall(
        contractAddress: contract.toSolidityHex(),
        function: function,
        params: [address]));
    return result[0];
  }

  @override
  Future<TransactionReceipt> trackTransaction(
      {required String transactionId,
      Duration timeout = const Duration(minutes: 5),
      Duration periodicTimeOut = const Duration(seconds: 3)}) async {
    Timer? timer;
    try {
      final Completer<TransactionReceipt> completer = Completer<TransactionReceipt>();
      timer = Timer.periodic(periodicTimeOut, (t) async {
        final receipt = await provider
            .request(EthereumRequestGetTransactionReceipt(transactionHash: transactionId))
            .catchError((e, s) {
          return null;
        });
        if (receipt != null && !completer.isCompleted) {
          completer.complete(receipt);
        }
      });
      final receipt = await completer.future.timeout(timeout);
      return receipt;
    } on TimeoutException {
      throw const DartOnChainSwapPluginException(
          "transaction confirmation failed within the allotted timeout.");
    } finally {
      timer?.cancel();
      timer = null;
    }
  }

  @override
  Future<bool> initSwapClient() async {
    final chainId = await getChainId();
    return chainId == network.chainId;
  }

  Future<SwapEthereumAccountAssetBalance> getAccountsAssetBalance(
      ETHSwapAsset asset, ETHAddress account) async {
    return SwapEthereumAccountAssetBalance(
        address: account,
        balance: asset.isNative
            ? await getBalance(account)
            : await getTokenBalance(address: account, contract: asset.contractAddress),
        asset: asset);
  }

  @override
  Future<BigInt?> getBlockHeight() async {
    final block = await provider.request(EthereumRequestGetBlockNumber());
    return BigInt.from(block);
  }
}
