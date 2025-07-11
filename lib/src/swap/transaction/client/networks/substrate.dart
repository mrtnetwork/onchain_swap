import 'dart:async';
import 'package:blockchain_utils/utils/binary/utils.dart';
import 'package:on_chain_swap/src/swap/transaction/types/types.dart';
import 'package:polkadot_dart/polkadot_dart.dart';
import 'package:on_chain_swap/src/swap/transaction/client/core/client.dart';
import 'package:on_chain_swap/src/exception/exception.dart';
import 'package:on_chain_swap/src/swap/types/types.dart';

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
    final storage =
        await api.getDefaultAccountInfo(address: address, rpc: provider);
    return storage.data.free;
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
  Future<int> getAccountNonce(SubstrateAddress address) async {
    final storage = await api.getAccount(address: address, rpc: provider);
    return storage.nonce;
  }

  @override
  Future<String> sendTransaction(Extrinsic extrinsic) async {
    return await provider.request(
        SubstrateRequestAuthorSubmitExtrinsic(extrinsic.toHex(prefix: "0x")));
  }

  Future<SubtrateTransactionSubmitionResult?> _lockupBlock(
      {required int blockId,
      required String extrinsic,
      required String transactionHash}) async {
    final blockHash = await provider
        .request(SubstrateRequestChainGetBlockHash<String?>(number: blockId));
    if (blockHash == null) {
      throw TypeError();
    }
    try {
      final block = await provider
          .request(SubstrateRequestChainGetBlock(atBlockHash: blockHash));
      final index = block.block.extrinsics.indexOf(extrinsic);
      if (index < 0) return null;
      final events =
          await api.getSystemEvents(provider, atBlockHash: blockHash);
      return SubtrateTransactionSubmitionResult(
          events: events.where((e) => e.applyExtrinsic == index).toList(),
          block: blockHash,
          extrinsic: extrinsic,
          blockNumber: blockId,
          transactionHash: transactionHash);
    } catch (e) {
      throw DartOnChainSwapPluginException("Somthing wrong when parsing block",
          details: {"block": blockHash, "stack": e.toString()});
    }
  }

  Stream<SubtrateTransactionSubmitionResult> _findTransactionStream(
      {Duration retryInterval = const Duration(seconds: 4),
      required int blockId,
      required String extrinsic,
      required String transactionHash,
      int maxRetryEachBlock = 5,
      int blockCount = 20}) {
    final controller = StreamController<SubtrateTransactionSubmitionResult>();
    void closeController() {
      if (!controller.isClosed) {
        controller.close();
      }
    }

    void startFetching() async {
      int id = blockId;
      int retry = maxRetryEachBlock;
      int count = blockCount;
      while (!controller.isClosed) {
        try {
          final result = await _lockupBlock(
              blockId: id,
              extrinsic: extrinsic,
              transactionHash: transactionHash);
          id++;
          count--;
          retry = maxRetryEachBlock;
          if (result != null) {
            controller.add(result);
            closeController();
          } else if (count <= 0) {
            controller.addError(DartOnChainSwapPluginException(
                "Failed to fetch the block within the last $blockCount blocks."));
            closeController();
          }
        } on DartOnChainSwapPluginException catch (e) {
          controller.addError(e);
          controller.close();
        } catch (_) {
          retry--;
          if (retry <= 0) {
            controller.addError(const DartOnChainSwapPluginException(
                "Failed to fetch the transaction within the allotted time."));
            closeController();
          }
        }
        await Future.delayed(retryInterval);
      }
    }

    startFetching();
    return controller.stream.asBroadcastStream(onCancel: (e) {
      controller.close();
    });
  }

  @override
  Future<SubtrateTransactionSubmitionResult> submitExtrinsicAndWatch(
      {required Extrinsic extrinsic, int maxRetryEachBlock = 5}) async {
    final blockHeader =
        await provider.request(const SubstrateRequestChainChainGetHeader());
    final ext = extrinsic.toHex(prefix: "0x");
    final transactionHash =
        await provider.request(SubstrateRequestAuthorSubmitExtrinsic(ext));
    final completer = Completer<SubtrateTransactionSubmitionResult>();
    StreamSubscription<SubtrateTransactionSubmitionResult>? stream;
    try {
      stream = _findTransactionStream(
              blockId: blockHeader.number,
              extrinsic: ext,
              maxRetryEachBlock: maxRetryEachBlock,
              transactionHash: transactionHash)
          .listen(
              (e) async {
                completer.complete(e);
              },
              onDone: () {},
              onError: (e) {
                if (completer.isCompleted) return;
                if (e is DartOnChainSwapPluginException) {
                  completer.completeError(DartOnChainSwapPluginException(
                      e.message,
                      details: {"tx": transactionHash, ...e.details ?? {}}));
                } else {
                  completer.completeError(DartOnChainSwapPluginException(
                      "Failed to fetch the transaction. $transactionHash",
                      details: {"tx": transactionHash, "stack": e.toString()}));
                }
              });
      return await completer.future;
    } finally {
      stream?.cancel();
      stream = null;
    }
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
}
