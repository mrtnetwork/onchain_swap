import 'package:on_chain_swap/src/swap/transaction/client/core/client.dart';
import 'package:on_chain_swap/src/exception/exception.dart';
import 'package:on_chain_swap/src/swap/transaction/types/types.dart';
import 'package:cosmos_sdk/cosmos_sdk.dart';
import 'package:on_chain_swap/src/swap/types/types.dart';

class SwapCosmosClient
    with CosmosQuickServiceApi
    implements BaseSwapCosmosClient {
  @override
  final CosmosProvider provider;
  final SwapCosmosNetwork network;
  @override
  final List<CosmosProviderApi> supportedApis;

  String? _chainId;
  static const Map<String, String> forked = {
    "thorchain-1": "https://thornode.ninerealms.com/thorchain/constants",
    "mayachain-mainnet-v1":
        "https://mayanode.mayachain.info/mayachain/constants"
  };
  final CosmosSdkChain? networkInfo;
  SwapCosmosClient(
      {required this.provider,
      required this.network,
      required this.networkInfo,
      required this.supportedApis});

  @override
  Future<String> chainId({Duration? timeout}) async {
    String? chainId = _chainId;
    if (chainId != null) return chainId;
    chainId = _chainId = await super.chainId(timeout: timeout);
    return chainId;
  }

  static Future<SwapCosmosClient> check(
      {required CosmosProvider provider,
      required SwapCosmosNetwork network,
      required CosmosSdkChain? chainInfo,
      required List<CosmosProviderApi> supportedApi}) async {
    final client = SwapCosmosClient(
        provider: provider,
        network: network,
        networkInfo: chainInfo,
        supportedApis: supportedApi);
    if (!(await client.initSwapClient())) {
      throw const DartOnChainSwapPluginException(
          "The Chain ID is not compatible with the current network.");
    }

    return client;
  }

  @override
  Future<ThorNodeNetworkConstants> getThorNodeConstants() async {
    throw UnimplementedError();
  }

  @override
  Future<CosmosSwapTransactionRequirment> getSwapTransactionRequirment(
      CosmosBaseAddress address) async {
    final cosmosAccount = await getAccount(address);
    BigInt? fixedFee;
    if (forked.containsKey(network.identifier)) {
      final networkConst = await getThorNodeConstants();
      fixedFee = BigInt.from(networkConst.nativeTransactionFee);
    }
    final ethermintTxFee = await getEthereumBaseFee();
    return CosmosSwapTransactionRequirment(
        account: cosmosAccount,
        fixedNativeGas: fixedFee,
        ethermintTxFee: ethermintTxFee);
  }

  @override
  CosmosSwapNetworkReuirment get chainInfo {
    if (networkInfo == null) {
      throw const DartOnChainSwapPluginException(
          "Missing cosmos chain information.");
    }
    return CosmosSwapNetworkReuirment(
        native: networkInfo!.native, feeTokens: networkInfo!.fees);
  }

  @override
  Future<bool> initSwapClient() async {
    final chainId = await this.chainId();
    return chainId == network.identifier;
  }

  @override
  Future<SwapCosmosAccountAssetBalance> getAccountsAssetBalance(
    CosmosSwapAsset asset,
    CosmosBaseAddress account,
  ) async {
    return SwapCosmosAccountAssetBalance(
      address: account,
      balance: await getBalance(account, asset.denom),
      asset: asset,
    );
  }
}
