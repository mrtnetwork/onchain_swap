import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:blockchain_utils/utils/numbers/rational/big_rational.dart';
import 'package:cosmos_sdk/cosmos_sdk.dart';
import 'package:on_chain/on_chain.dart';
import 'package:on_chain/solidity/address/core.dart';
import 'package:on_chain_swap/src/swap/swap.dart';
import 'package:polkadot_dart/polkadot_dart.dart';

abstract class SwapNetworkClient<ASSET extends BaseSwapAsset, ADDRESS,
    BALANCE extends SwapAccountAssetBalance> {
  Future<bool> initSwapClient();
  Future<BALANCE> getAccountsAssetBalance(ASSET asset, ADDRESS account);
  Future<BigInt?> getBlockHeight();
}

abstract class BaseSwapBitcoinClient
    implements
        SwapNetworkClient<BitcoinSwapAsset, BitcoinBaseAddress,
            SwapBitcoinAccountAssetBalance> {
  Future<BigRational> estimateFeePerByte(SwapBitcoinNetwork network);
  Future<BigInt> getBalance(BitcoinBaseAddress address);
  Future<String> sendTransaction(String transaction);
  Future<List<PsbtUtxo>> getAccountsUtxos(
      List<BitcoinSpenderAddress> addresses);
  Future<String> genesisHash();
}

abstract class BaseSwapEthereumClient
    implements
        SwapNetworkClient<ETHSwapAsset, ETHAddress,
            SwapEthereumAccountAssetBalance> {
  EthereumProvider get provider;
  Future<BigInt> getBalance(ETHAddress address);
  Future<BigInt> getChainId();
  Future<BigInt> getAllowance(
      {required ETHAddress contract,
      required ETHAddress owner,
      required ETHAddress spender});
  Future<BigInt> getTokenBalance(
      {required SolidityAddress address, required SolidityAddress contract});
  Future<TransactionReceipt> trackTransaction(
      {required String transactionId,
      Duration timeout = const Duration(minutes: 5),
      Duration periodicTimeOut = const Duration(seconds: 3)});
}

abstract class BaseSwapCosmosClient
    implements
        SwapNetworkClient<CosmosSwapAsset, CosmosBaseAddress,
            SwapCosmosAccountAssetBalance> {
  CosmosSwapNetworkReuirment get chainInfo;
  Future<String> chainId();
  Future<List<Coin>> getAddressCoins(CosmosBaseAddress address);
  Future<BaseAccount> getAccount(CosmosBaseAddress address);
  Future<SimulateResponse> simulateTx(List<int> txBytes);
  Future<BigInt> getBalance(CosmosBaseAddress address, {String? denom});
  Future<String> broadcastTransaction(List<int> txRaw);
  Future<ThorNodeNetworkConstants> getThorNodeConstants();
  Future<bool> isEthermint();
  Future<BigRational> getEthermintBaseFee();
  Future<CosmosSwapTransactionRequirment> getSwapTransactionRequirment(
      CosmosBaseAddress address);
}

abstract class BaseSwapSolanaClient
    implements
        SwapNetworkClient<SolanaSwapAsset, SolAddress,
            SwapSolanaAccountAssetBalance> {
  Future<String> getGenesis();
  Future<SolanaAccountInfo?> getAccountInfo(SolAddress address);
  Future<BigInt> getBalance(SolAddress address);
  Future<BigInt> getTokenBalance(
      {required SolAddress account,
      required SolAddress mint,
      SolAddress? tokenProgramId});
  Future<SimulateTranasctionResponse> simulate(
      {required SolanaTransaction transaction,
      SolAddress? account,
      bool replaceRecentBlockhash = true,
      bool sigVerify = false,
      Commitment? commitment = Commitment.processed,
      MinContextSlot? minContextSlot});
  Future<SolAddress> getBlockHash();
  Future<SignatureStatus?> getSignatureStatuses(String signature);
  Future<TransactionConfirmationStatus> trackTransaction(
      {required String transactionId,
      Duration timeout = const Duration(minutes: 1),
      Duration periodicTimeOut = const Duration(seconds: 2)});
  Future<String> sendTransaction(SolanaTransaction transaction,
      {int? maxRetries,
      bool skipPreflight = false,
      int? minContextSlot,
      Commitment? commitment,
      SolanaRequestEncoding encoding = SolanaRequestEncoding.base64});
  Future<SolanaTokenPDAInfo> getTokenAccountAddress(
      {required SolAddress account,
      required SolAddress mint,
      SolAddress? tokenProgramId});
}

abstract class BaseSwapSubstrateClient
    implements
        SwapNetworkClient<PolkadotSwapAsset, BaseSubstrateAddress,
            SwapPolkadotAccountAssetBalance> {
  MetadataApi get api;
  MetadataWithProvider metadataWitPorvider();
  Future<BigInt> getBalance(SubstrateAddress address);
  Future<SubstrateBlockHash> getFinalizBlock({int? atNumber});
  Future<SubstrateBlockHash> getGenesis();
  Future<SubstrateHeaderResponse> getBlockHeader({String? atBlockHash});
  Future<SubstrateTransactionBlockRequirment> transactionBlockRequirment();
  Future<BigInt> getAccountNonce(SubstrateAddress address);
  Future<String> sendTransaction(Extrinsic extrinsic);
  Future<SubtrateTransactionSubmitionResult> submitExtrinsicAndWatch(
      {required SubstrateSubmitableTransaction extrinsic,
      int maxRetryEachBlock = 5});
}
