import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:blockchain_utils/crypto/quick_crypto.dart';
import 'package:blockchain_utils/utils/utils.dart';
import 'package:on_chain_swap/src/exception/exception.dart';
import 'package:on_chain_swap/src/swap/transaction/client/core/client.dart';
import 'package:on_chain_swap/src/swap/transaction/types/types.dart';
import 'package:on_chain_swap/src/swap/types/types.dart';

class _BitcoinClientConst {
  static final BigRational testnetFeeRate = BigRational.parseDecimal('1.1');
}

class SwapBitcoinClient implements BaseSwapBitcoinClient {
  final BitcoinProvider provider;
  final SwapBitcoinNetwork network;
  String? _genesis;
  SwapBitcoinClient({required this.provider, required this.network});

  static Future<SwapBitcoinClient> check(
      {required BitcoinProvider provider,
      required SwapBitcoinNetwork network}) async {
    final client = SwapBitcoinClient(provider: provider, network: network);
    if (!(await client.initSwapClient())) {
      throw const DartOnChainSwapPluginException(
          "The Genesis Hash is not compatible with the current network.");
    }
    return client;
  }

  @override
  Future<BigRational> estimateFeePerByte(SwapBitcoinNetwork network) async {
    final fee = await provider.request(ElectrumRequestEstimateFee());
    if (fee == null) {
      if (!network.chainType.isMainnet) {
        return _BitcoinClientConst.testnetFeeRate;
      }
      throw const DartOnChainSwapPluginException(
          "Failed to fetch network fee rate.");
    }
    return BigRational(fee) / BigRational.from(1024);
  }

  @override
  Future<BigInt> getBalance(BitcoinBaseAddress address) async {
    final utxos = await provider.request(
        ElectrumRequestScriptHashListUnspent(scriptHash: address.pubKeyHash()));
    return utxos.fold<BigInt>(BigInt.zero, (a, b) => a + b.value);
  }

  @override
  Future<String> sendTransaction(BtcTransaction transaction) async {
    final bytes = transaction.serialize();
    final result = await provider
        .request(ElectrumRequestBroadCastTransaction(transactionRaw: bytes));
    if (StringUtils.isHexBytes(result,
        lengthInBytes: QuickCrypto.sha256DigestSize)) {
      return result;
    }
    return transaction.txId();
  }

  @override
  Future<List<PsbtUtxo>> getAccountsUtxos(
      List<BitcoinSpenderAddress> addresses) async {
    final utxos = await _getAccountsUtxo(addresses);
    return utxos.where((e) {
      final height = e.utxo.blockHeight;
      return height > 0;
    }).toList();
  }

  Future<List<PsbtUtxo>> _getAccountsUtxo(
      List<BitcoinSpenderAddress> addresses) async {
    final utxos = await Future.wait(addresses.map((e) async {
      return await provider.request(ElectrumRequestScriptHashListUnspent(
          scriptHash: e.address.baseAddress.pubKeyHash()));
    }));
    final utxoss = List.generate(utxos.length, (i) async {
      final request = addresses[i];
      final accountUtxos = utxos[i];
      final er = await Future.wait(accountUtxos
          .map(
              (e) => provider.request(ElectrumRequestGetRawTransaction(e.txId)))
          .toList());
      return List.generate(
        accountUtxos.length,
        (index) {
          return PsbtUtxo(
              utxo: accountUtxos[index].toUtxo(request.address.type),
              p2shRedeemScript: request.p2shreedemScript,
              p2wshWitnessScript: request.witnessScript,
              tx: er[index],
              scriptPubKey: request.address.baseAddress.toScriptPubKey(),
              xOnlyOrInternalPubKey: request.taprootInternal);
        },
      );
    });
    final e = await Future.wait(utxoss);
    return e.expand((e) => e).toList();
  }

  @override
  Future<String> genesisHash() async {
    if (_genesis != null) return _genesis!;
    final header = await provider
        .request(ElectrumRequestBlockHeader(startHeight: 0, cpHeight: 0));
    _genesis = BytesUtils.toHexString(
        QuickCrypto.sha256DoubleHash(BytesUtils.fromHexString(header))
            .reversed
            .toList());
    return _genesis!;
  }

  @override
  Future<bool> initSwapClient() async {
    final genesis = await genesisHash();
    return genesis == StringUtils.strip0x(network.genesis.toLowerCase());
  }

  @override
  Future<SwapBitcoinAccountAssetBalance> getAccountsAssetBalance(
      BitcoinSwapAsset asset, BitcoinBaseAddress account) async {
    return SwapBitcoinAccountAssetBalance(
        address: account, balance: await getBalance(account), asset: asset);
  }

  @override
  Future<BigInt?> getBlockHeight() async {
    final block = await provider.request(ElectrumRequestHeaderSubscribe());
    return BigInt.from(block.block);
  }
}
