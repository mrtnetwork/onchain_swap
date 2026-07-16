import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:cosmos_sdk/cosmos_sdk.dart';
import 'package:cosmos_sdk/proto_messages/cosmos/auth/v1beta1/src/auth.dart';
import 'package:cosmos_sdk/proto_messages/cosmos/tx/v1beta1/src/tx.dart';
import 'package:on_chain/on_chain.dart'
    show ETHAddress, ETHTransactionType, SolanaTransaction, SolAddress;
import 'package:on_chain_swap/src/exception/exception.dart';
import 'package:on_chain_swap/src/swap/transaction/client/core/client.dart'
    show SwapNetworkClient;
import 'package:on_chain_swap/src/swap/transaction/signer/signer.dart';
import 'package:on_chain_swap/src/swap/types/types.dart';
import 'package:polkadot_dart/polkadot_dart.dart';

typedef CbGetRouteNetwork<CLIENT extends SwapNetworkClient,
        NETWORK extends SwapNetwork>
    = Future<CLIENT> Function(NETWORK network);
typedef CbGetSigner<SIGNER extends Web3Signer, ADDRESS> = Future<SIGNER>
    Function(ADDRESS signer);

abstract class Web3Transaction {
  const Web3Transaction();
}

enum TransactionExcuteMode {
  parallel,
  serial;

  bool get isSerial => this == serial;
}

class Web3TransactionEthereum extends Web3Transaction {
  final BigInt value;
  final ETHAddress to;
  final ETHAddress from;
  final String data;
  final BigInt? gasLimit;
  final ETHTransactionType? transactionType;
  final BigInt? maxPriorityFeePerGas;
  final BigInt? maxFeePerGas;
  final BigInt? chainId;
  final BigInt? gasPrice;
  Web3TransactionEthereum({
    required this.value,
    required this.to,
    required this.from,
    required this.data,
    required this.gasLimit,
    required this.transactionType,
    this.maxFeePerGas,
    this.maxPriorityFeePerGas,
    required this.chainId,
    required this.gasPrice,
  });
  factory Web3TransactionEthereum.fromJson(Map<String, dynamic> json) {
    return Web3TransactionEthereum(
        value: BigintUtils.parse(json["value"] ?? '0'),
        to: ETHAddress(json["to"]),
        from: ETHAddress(json["from"]),
        data: StringUtils.add0x(json.valueAs<String>('data').toLowerCase()),
        gasLimit: null,
        transactionType: null,
        chainId: json.valueAsBigInt('chainId'),
        gasPrice: BigintUtils.tryParse(json.valueAs("gasPrice")));
  }
}

class Web3TransactionSolana extends Web3Transaction {
  final SolanaTransaction legacy;
  final SolanaTransaction v0;
  final SolAddress source;

  List<int> get legacyTransactionBytes => legacy.serialize();
  List<int> get v0transactionBytes => v0.serialize();
  Web3TransactionSolana(
      {required this.legacy, required this.v0, required this.source});
}

class Web3TransactionBitcoinOutputs {
  final String? address;
  final Script script;
  final BigInt value;
  const Web3TransactionBitcoinOutputs(
      {this.address, required this.script, required this.value});
}

class Web3TransactionBitcoin extends Web3Transaction {
  final String psbt;
  final List<Web3TransactionBitcoinOutputs> outputs;
  final BitcoinSpenderAddress source;
  Web3TransactionBitcoin(
      {required this.psbt,
      required List<Web3TransactionBitcoinOutputs> outputs,
      required this.source})
      : outputs = outputs.immutable;
}

class Web3TransactionSubstrate extends Web3Transaction {
  final SubstrateSubmitableTransactionPayload transaction;
  final bool? withSignedTransaction;
  Map<String, dynamic> toJson() {
    return {
      "address": transaction.owner.address,
      "assetId": BytesUtils.tryToHexString(transaction.assetId, prefix: "0x"),
      "blockHash": transaction.block.blockHash.toHex(prefix: "0x"),
      "blockNumber": BytesUtils.toHexString(
          LayoutConst.u32be().serialize(transaction.block.blockNumber),
          prefix: '0x'),
      "era": transaction.block.era.toHex(prefix: "0x"),
      "genesisHash": StringUtils.add0x(transaction.genesisHash),
      "metadataHash":
          BytesUtils.tryToHexString(transaction.metadataHash, prefix: "0x"),
      "method": BytesUtils.toHexString(transaction.methodBytes, prefix: "0x"),
      "mode": 0,
      "nonce": BytesUtils.toHexString(
          LayoutConst.u32be().serialize(transaction.nonce.toInt()),
          prefix: '0x'),
      "specVersion": BytesUtils.toHexString(
          LayoutConst.u32be().serialize(transaction.specVersion),
          prefix: '0x'),
      "transactionVersion": BytesUtils.toHexString(
          LayoutConst.u32be().serialize(transaction.transactionVersion),
          prefix: '0x'),
      "version": transaction.builder.metadataFields.extrinsicInfo.version,
      "tip": "0x00000000000000000000000000000000",
      "signedExtensions": transaction
          .builder.metadataFields.extrinsicInfo.extrinsic
          .map((e) => e.name)
          .cast<String>()
          .toList()
    };
  }

  factory Web3TransactionSubstrate({
    required SubstrateSubmitableTransactionPayload transaction,
  }) {
    return Web3TransactionSubstrate._(
        withSignedTransaction: false, transaction: transaction);
  }

  Web3TransactionSubstrate._(
      {required this.transaction, this.withSignedTransaction});
}

class Web3TransactionCosmos extends Web3Transaction {
  final SignDoc signDoc;
  final CosmosSpenderAddress source;
  const Web3TransactionCosmos({required this.signDoc, required this.source});
}

class BitcoinSpenderAddress {
  final BitcoinNetworkAddress address;
  final Script? p2shreedemScript;
  final Script? witnessScript;
  final List<int>? taprootInternal;
  BitcoinSpenderAddress._(
      {required this.address,
      required this.p2shreedemScript,
      required this.witnessScript,
      required List<int>? taprootInternal})
      : taprootInternal = taprootInternal?.asImmutableBytes;
  factory BitcoinSpenderAddress(
      {required BitcoinNetworkAddress address,
      Script? p2shreedemScript,
      Script? witnessScript,
      List<int>? taprootInternal}) {
    BitcoinBaseAddress currentAddress = address.baseAddress;
    final type = address.type;
    bool isP2shSegwit = type.isP2sh && witnessScript != null;
    bool isWitness = type == SegwitAddressType.p2wsh;
    final addressScript = address.baseAddress.toScriptPubKey();
    if (type.isP2sh) {
      if (p2shreedemScript == null) {
        throw const DartOnChainSwapPluginException(
            "Missing p2sh redeem script.");
      }
      P2shAddress p2shAddress;
      if (witnessScript != null) {
        final addr = P2wshAddress.fromScript(script: witnessScript);
        p2shAddress = P2shAddress.fromScript(
            script: addr.toScriptPubKey(), type: P2shAddressType.p2wshInP2sh);
        if (p2shAddress.toScriptPubKey() != currentAddress.toScriptPubKey()) {
          throw const DartOnChainSwapPluginException(
              "Invalid p2sh redeem script.");
        }
      } else {
        if (BitcoinScriptUtils.isP2wsh(p2shreedemScript)) {
          throw const DartOnChainSwapPluginException(
              "Missing nested segwit p2sh witness script.");
        }
        bool isP2wpkh = BitcoinScriptUtils.isP2wpkh(p2shreedemScript);
        p2shAddress = P2shAddress.fromScript(
            script: p2shreedemScript,
            type: isP2wpkh
                ? P2shAddressType.p2wpkhInP2sh
                : P2shAddressType.p2pkInP2sh);
      }
      if (addressScript != p2shAddress.toScriptPubKey()) {
        throw const DartOnChainSwapPluginException(
            "Invalid p2sh or witness script.");
      }
      currentAddress = p2shAddress;
    } else if (isWitness) {
      if (witnessScript == null) {
        throw const DartOnChainSwapPluginException(
            "Missing p2wsh witness script.");
      }
      final addr = P2wshAddress.fromScript(script: witnessScript);
      if (addr.toScriptPubKey() != addressScript) {
        throw const DartOnChainSwapPluginException(
            "Invalid p2wsh witness script.");
      }
    } else if (type.isP2tr) {
      if (taprootInternal == null) {
        throw const DartOnChainSwapPluginException(
            "Missing taproot internal key.");
      }
      if (taprootInternal.length != EcdsaKeysConst.pointCoordByteLen) {
        throw const DartOnChainSwapPluginException(
            "Invalid taproot internal key.");
      }
      final addr = P2trAddress.fromInternalKey(internalKey: taprootInternal);
      if (addr.toScriptPubKey() != addressScript) {
        throw const DartOnChainSwapPluginException(
            "Invalid taproot internal key.");
      }
    }
    return BitcoinSpenderAddress._(
        address: BitcoinNetworkAddress.fromBaseAddress(
            address: currentAddress, network: address.network),
        p2shreedemScript: type.isP2sh ? p2shreedemScript : null,
        witnessScript:
            type.isP2sh || isP2shSegwit || isWitness ? witnessScript : null,
        taprootInternal: type.isP2tr ? taprootInternal : null);
  }
}

class CosmosSpenderAddress {
  final CosmosBaseAddress address;
  final CosmosPublicKey publicKey;
  const CosmosSpenderAddress({required this.address, required this.publicKey});
}

class CosmosSignResponse {
  final List<int> bodyBytes;
  final List<int> authBytes;
  final List<int> signature;
  CosmosSignResponse(
      {required List<int> bodyBytes,
      required List<int> authBytes,
      required List<int> signature})
      : signature = signature.asImmutableBytes,
        authBytes = authBytes.asImmutableBytes,
        bodyBytes = bodyBytes.asImmutableBytes;
}

enum CosmosSigningScheme { amino, direct }

class SolanaTokenPDAInfo {
  final SolAddress address;
  final SolAddress pdaAddress;
  final SolAddress tokenProgramId;
  const SolanaTokenPDAInfo(
      {required this.address,
      required this.pdaAddress,
      required this.tokenProgramId});
}

class SubstrateTransactionBlockRequirment {
  final int blockNumber;
  final List<int> blockHashBytes;
  final SubstrateBlockHash genesisBlock;
  final MortalEra era;
  SubstrateTransactionBlockRequirment(
      {required this.blockNumber,
      required this.era,
      required this.genesisBlock,
      required List<int> blockHashBytes})
      : blockHashBytes = blockHashBytes.asImmutableBytes;

  String get eraIndex => "Mortal${era.index}";
  int get eraValue => era.era;
}

class CosmosSwapTransactionRequirment {
  final BigInt? fixedNativeGas;
  final BaseAccount account;
  final BigRational? ethermintTxFee;
  CosmosSwapTransactionRequirment(
      {this.ethermintTxFee, this.fixedNativeGas, required this.account});
  CosmosSwapTransactionRequirment copyWith(
      {BigInt? fixedNativeGas,
      BaseAccount? account,
      BigRational? ethermintTxFee}) {
    return CosmosSwapTransactionRequirment(
        account: account ?? this.account,
        ethermintTxFee: ethermintTxFee ?? this.ethermintTxFee,
        fixedNativeGas: fixedNativeGas ?? this.fixedNativeGas);
  }
}

class CosmosSwapNetworkReuirment {
  final CosmosSdkAsset native;
  final List<CosmosSdkAsset> feeTokens;
  CosmosSwapNetworkReuirment._(
      {required this.native, required List<CosmosSdkAsset> feeTokens})
      : feeTokens = feeTokens.immutable;
  factory CosmosSwapNetworkReuirment(
      {required CosmosSdkAsset native,
      required List<CosmosSdkAsset> feeTokens}) {
    if (feeTokens.isEmpty) {
      throw const DartOnChainSwapPluginException(
          "At least one fee token required.");
    }
    return CosmosSwapNetworkReuirment._(native: native, feeTokens: feeTokens);
  }
}

abstract class SwapAccountAssetBalance<ASSET extends BaseSwapAsset, ADDRESS> {
  final ADDRESS address;
  final BigInt balance;
  final ASSET asset;
  const SwapAccountAssetBalance(
      {required this.address, required this.balance, required this.asset});
}

class SwapBitcoinAccountAssetBalance
    extends SwapAccountAssetBalance<BitcoinSwapAsset, BitcoinBaseAddress> {
  SwapBitcoinAccountAssetBalance(
      {required super.address, required super.balance, required super.asset});
}

class SwapEthereumAccountAssetBalance
    extends SwapAccountAssetBalance<ETHSwapAsset, ETHAddress> {
  SwapEthereumAccountAssetBalance(
      {required super.address, required super.balance, required super.asset});
}

class SwapSolanaAccountAssetBalance
    extends SwapAccountAssetBalance<SolanaSwapAsset, SolAddress> {
  SwapSolanaAccountAssetBalance(
      {required super.address, required super.balance, required super.asset});
}

class SwapCosmosAccountAssetBalance
    extends SwapAccountAssetBalance<CosmosSwapAsset, CosmosBaseAddress> {
  SwapCosmosAccountAssetBalance(
      {required super.address, required super.balance, required super.asset});
}

class SwapPolkadotAccountAssetBalance
    extends SwapAccountAssetBalance<PolkadotSwapAsset, BaseSubstrateAddress> {
  SwapPolkadotAccountAssetBalance(
      {required super.address, required super.balance, required super.asset});
}
