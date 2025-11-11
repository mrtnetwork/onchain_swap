import 'dart:async';

import 'package:blockchain_utils/utils/binary/utils.dart';
import 'package:on_chain_swap/src/exception/exception.dart';
import 'package:on_chain_swap/src/swap/transaction/client/core/client.dart';
import 'package:on_chain_swap/src/swap/transaction/types/types.dart';
import 'package:on_chain_swap/src/swap/types/types.dart';
import 'package:polkadot_dart/polkadot_dart.dart';

class SwapSubstrateClient implements BaseSwapSubstrateClient {
  final SubstrateProvider provider;
  final SwapSubstrateNetwork network;
  MetadataApi? _api;
  @override
  MetadataApi get api {
    final metadata = _api;
    if (metadata == null) {
      throw const DartOnChainSwapPluginException(
          "Client has not been initialized.");
    }
    return metadata;
  }

  static Future<SwapSubstrateClient> check(
      {required SubstrateProvider provider,
      required SwapSubstrateNetwork network}) async {
    final client = SwapSubstrateClient(provider: provider, network: network);
    await client.initSwapClient();
    return client;
  }

  SwapSubstrateClient({required this.provider, required this.network});

  @override
  Future<BigInt> getBalance(BaseSubstrateAddress address) async {
    final data = await SubstrateQuickStorageApi.system
        .accountWithDataFrame(api: api, rpc: provider, address: address);
    return data.data.free;
  }

  @override
  Future<SubstrateBlockHash> getFinalizBlock({int? atNumber}) async {
    final blockHash = await provider
        .request(const SubstrateRequestChainChainGetFinalizedHead());
    return SubstrateBlockHash.hash(blockHash);
  }

  @override
  Future<SubstrateBlockHash> getGenesis() async {
    final genesis = await provider
        .request(const SubstrateRequestChainGetBlockHash(number: 0));
    if (genesis == null) {
      throw const DartOnChainSwapPluginException(
          "Failed to fetch genesis block hash.");
    }
    return SubstrateBlockHash.hash(genesis);
  }

  @override
  Future<SubstrateHeaderResponse> getBlockHeader({String? atBlockHash}) async {
    final header = await provider
        .request(SubstrateRequestChainChainGetHeader(atBlockHash: atBlockHash));
    return header;
  }

  @override
  Future<SubstrateTransactionBlockRequirment>
      transactionBlockRequirment() async {
    final finalizeBlock = (await getFinalizBlock());
    final genesis = await getGenesis();
    final blockHash = finalizeBlock.toHex();

    final header = await getBlockHeader(atBlockHash: blockHash);
    return SubstrateTransactionBlockRequirment(
        blockNumber: header.number,
        era: header.toMortalEra(period: 155),
        blockHashBytes: finalizeBlock.bytes,
        genesisBlock: genesis);
  }

  @override
  Future<BigInt> getAccountNonce(SubstrateAddress address) async {
    final nonce = await SubstrateQuickStorageApi.system
        .nonce(api: api, rpc: provider, address: address);
    return nonce;
  }

  @override
  Future<String> sendTransaction(Extrinsic extrinsic) async {
    return await provider.request(
        SubstrateRequestAuthorSubmitExtrinsic(extrinsic.toHex(prefix: "0x")));
  }

  @override
  Future<SubtrateTransactionSubmitionResult> submitExtrinsicAndWatch(
      {required SubstrateSubmitableTransaction extrinsic,
      int maxRetryEachBlock = 25}) async {
    return SubstrateTransactionBuilder.submitExtrinsicAndWatchStaticAsync(
        extrinsic: extrinsic,
        provider: metadataWitPorvider(),
        maxRetryEachBlock: maxRetryEachBlock);
  }

  Future<MetadataApi> _init() async {
    final metadata = (await provider.request(
            const SubstrateRequestRuntimeMetadataGetMetadataAtVersion(15)))
        ?.toApi();
    if (metadata == null) {
      throw const DartOnChainSwapPluginException(
          "Unsuported substrate network metadata version.");
    }
    final client = SwapSubstrateClient(provider: provider, network: network);
    final genesis = await client.getGenesis();
    if (BytesUtils.bytesEqual(
        genesis.bytes, BytesUtils.fromHexString(network.genesis))) {
      return metadata;
    }
    throw const DartOnChainSwapPluginException(
        "Client has not been initialized.");
  }

  @override
  Future<bool> initSwapClient() async {
    _api ??= await _init();
    return true;
  }

  @override
  Future<SwapPolkadotAccountAssetBalance> getAccountsAssetBalance(
      PolkadotSwapAsset asset, BaseSubstrateAddress account) async {
    assert(asset.type.isNative, "Unsuported polkadot asset.");
    return SwapPolkadotAccountAssetBalance(
        address: account, balance: await getBalance(account), asset: asset);
  }

  @override
  Future<BigInt> getBlockHeight() async {
    final header = await getBlockHeader();
    return BigInt.from(header.number);
  }

  @override
  MetadataWithProvider metadataWitPorvider() {
    return MetadataWithProvider(
        provider: provider, metadata: api.metadataWithExtrinsic());
  }
}
