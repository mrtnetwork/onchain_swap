import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:on_chain/on_chain.dart';
import 'package:on_chain_swap/src/exception/exception.dart';
import 'package:on_chain_swap/src/swap/services/services.dart';
import 'package:on_chain_swap/src/swap/transaction/core/transaction.dart';
import 'package:on_chain_swap/src/swap/utils/utils.dart';
import 'package:on_chain_swap/src/utils/equatable.dart';

enum SwapServiceType { skipGo, chainFlip, thor, maya, swapKit }

enum SwapChainType {
  ethereum,
  bitcoin,
  polkadot,
  solana,
  cosmos,
  tron,
  xrp,
  ada,
  zcash;
}

// enum SolanaChainType {
//   mainnet,
//   testnet,
//   devnet;

//   static SolanaChainType fromName(String? name) {
//     return SolanaChainType.values.firstWhere((e) => e.name == name,
//         orElse: () =>
//             throw DartOnChainSwapPluginException("Invalid solana chain name."));
//   }
// }

enum SwapFeeType {
  inbound("Inbound"),
  network("Network"),
  affiliate("Affiliate"),
  outbound("Outbound"),
  liquidity("Liquidity");

  final String name;
  const SwapFeeType(this.name);
}

abstract class BaseSwapServiceApiParams {
  final List<SwapServiceType> services;
  BaseSwapServiceApiParams(List<SwapServiceType> services)
      : services = services.immutable;
  Future<CfSwapService?> loadChainFlipService();
  Future<MayaSwapService?> loadMayaService();
  Future<SkipGoSwapService?> loadSkipGoService();
  Future<SwapKitSwapService?> loadSwapKitService();
  Future<ThorSwapService?> loadThorService();
}

abstract class SwapRoute<QUOTE extends QuoteSwapParams,
    PARAMS extends SwapRouteGeneralTransactionBuilderParam> {
  final DateTime? expireTime;
  final SwapAmount expectedAmount;
  final SwapAmount worstCaseAmount;
  final double worstPercentage;
  final QUOTE quote;
  final int estimateTime;
  final SwapServiceProvider provider;
  final List<SwapFee> fees;
  final double tolerance;
  bool get supportTolerance => true;
  SwapRoute(
      {required this.expireTime,
      required this.expectedAmount,
      required this.quote,
      required this.estimateTime,
      required this.provider,
      required this.fees,
      required this.tolerance,
      required this.worstCaseAmount})
      : worstPercentage = SwapUtils.worstPercentageAmount(
            expected: expectedAmount, worst: worstCaseAmount);

  SwapRouteTransactionBuilder txBuilder(PARAMS params);

  SwapRoute updateTolerance(double tolerance);
}

class RouteOrError {
  final SwapServiceProvider provider;
  final SwapRoute? route;
  final Object? error;
  const RouteOrError._({required this.provider, this.route, this.error});
  factory RouteOrError.error(
      {required SwapServiceProvider provider, required Object error}) {
    return RouteOrError._(provider: provider, error: error);
  }
  factory RouteOrError.route(
      {required SwapServiceProvider provider, required SwapRoute route}) {
    return RouteOrError._(provider: provider, route: route);
  }
  bool get hasRoute => route != null;
}

abstract class QuoteSwapParams<SWAPASSET extends BaseSwapAsset> {
  final SWAPASSET sourceAsset;
  final SWAPASSET destinationAsset;
  final SwapAmount amount;
  final String? sourceAddress;
  final String? destinationAddress;
  const QuoteSwapParams(
      {required this.sourceAsset,
      required this.destinationAsset,
      required this.amount,
      required this.sourceAddress,
      required this.destinationAddress});
}

abstract class SwapNetwork with Equatable {
  final SwapChainType type;
  final ChainType chainType;
  final String name;
  final String? logoUrl;
  final String identifier;
  final String? explorerTxUrl;
  final String? explorerAddressUrl;
  String? txUrl(String txId) {
    return explorerTxUrl?.replaceFirst("#txid", txId);
  }

  String? addressUrl(String address) {
    return explorerAddressUrl?.replaceFirst("#address", address);
  }

  bool isThorchainOrMaya() {
    final List<String> thorchainIdentifiers = ["thorchain-1", "mayachain-mainnet-v1"];
    return thorchainIdentifiers.contains(identifier);
  }

  Map<String, dynamic> toJson() {
    return {
      "type": type.name,
      "chainType": chainType.name,
      "name": name,
      "logoUrl": logoUrl,
      "identifier": identifier
    };
  }

  const SwapNetwork(
      {required this.name,
      required this.chainType,
      this.logoUrl,
      required this.identifier,
      required this.type,
      required this.explorerTxUrl,
      required this.explorerAddressUrl});

  T cast<T extends SwapNetwork>() {
    if (this is! T) {
      throw DartOnChainSwapPluginException("Casting network failed.",
          details: {"expected": "$T", "type": runtimeType.toString()});
    }
    return this as T;
  }
}

enum SwapAssetType {
  native,
  contract,
  asset;

  bool get isContract => this == contract;
  bool get isNative => this == native;
}

abstract class BaseSwapAsset with Equatable {
  bool get isContract => type.isContract;
  bool get isNative => type.isNative;
  final String symbol;
  final String? fullName;
  final String providerIdentifier;
  final int decimal;
  final SwapNetwork network;
  final SwapServiceProvider provider;
  final String? logoUrl;
  final String? coingeckoId;
  final SwapAssetType type;
  abstract final String identifier;
  String? assetUrl() {
    if (!isContract) return null;
    return network.addressUrl(identifier);
  }

  const BaseSwapAsset({
    required this.symbol,
    this.fullName,
    required this.providerIdentifier,
    required this.decimal,
    required this.network,
    required this.provider,
    required this.type,
    this.logoUrl,
    this.coingeckoId,
  });
  BigInt toAmount(String amount) {
    return BigInt.zero;
  }

  T cast<T extends BaseSwapAsset>() {
    if (this is! T) {
      throw DartOnChainSwapPluginException("Casting Asset failed.",
          details: {"expected": "$T", "type": runtimeType.toString()});
    }
    return this as T;
  }

  @override
  List get variabels => [network, identifier];
}

class ETHSwapAsset extends BaseSwapAsset {
  final ETHAddress? contractAddress;
  const ETHSwapAsset(
      {required super.symbol,
      required super.providerIdentifier,
      required super.decimal,
      required super.network,
      required super.provider,
      super.coingeckoId,
      this.contractAddress,
      super.fullName,
      super.logoUrl})
      : super(
            type:
                contractAddress == null ? SwapAssetType.native : SwapAssetType.contract);

  @override
  String get identifier => contractAddress?.address ?? network.identifier;
}

class SolanaSwapAsset extends BaseSwapAsset {
  final SolAddress? contractAddress;
  const SolanaSwapAsset(
      {required super.symbol,
      required super.providerIdentifier,
      required super.decimal,
      required super.network,
      required super.provider,
      super.coingeckoId,
      this.contractAddress,
      super.fullName,
      super.logoUrl})
      : super(
            type:
                contractAddress == null ? SwapAssetType.native : SwapAssetType.contract);

  @override
  String get identifier => contractAddress?.address ?? network.identifier;
}

class TronSwapAsset extends BaseSwapAsset {
  final TronAddress? contractAddress;
  const TronSwapAsset(
      {required super.symbol,
      required super.providerIdentifier,
      required super.decimal,
      required super.network,
      required super.provider,
      super.coingeckoId,
      this.contractAddress,
      super.fullName,
      super.logoUrl})
      : super(
            type:
                contractAddress == null ? SwapAssetType.native : SwapAssetType.contract);

  @override
  String get identifier => contractAddress?.address ?? network.identifier;
}

class XRPSwapAsset extends BaseSwapAsset {
  const XRPSwapAsset(
      {required super.symbol,
      required super.providerIdentifier,
      required super.decimal,
      required super.network,
      required super.provider,
      super.coingeckoId,
      super.fullName,
      super.logoUrl})
      : super(type: SwapAssetType.native);

  @override
  String get identifier => network.identifier;
}

class CosmosSwapAsset extends BaseSwapAsset {
  final String baseDenom;
  const CosmosSwapAsset(
      {required super.symbol,
      required super.providerIdentifier,
      required super.network,
      required super.provider,
      super.coingeckoId,
      required this.baseDenom,
      super.fullName,
      super.logoUrl})
      : super(type: SwapAssetType.contract, decimal: 0);

  @override
  String get identifier => baseDenom;
}

class AdaSwapAsset extends BaseSwapAsset {
  const AdaSwapAsset(
      {required super.symbol,
      required super.providerIdentifier,
      required super.decimal,
      required super.network,
      required super.provider,
      super.coingeckoId,
      super.fullName,
      super.logoUrl})
      : super(type: SwapAssetType.native);

  @override
  String get identifier => network.identifier;
}

class ZcashSwapAsset extends BaseSwapAsset {
  const ZcashSwapAsset(
      {required super.symbol,
      required super.providerIdentifier,
      required super.decimal,
      required super.network,
      required super.provider,
      super.coingeckoId,
      super.fullName,
      super.logoUrl})
      : super(type: SwapAssetType.native);

  @override
  String get identifier => network.identifier;
}

class BitcoinSwapAsset extends BaseSwapAsset {
  @override
  String get identifier => network.identifier;
  const BitcoinSwapAsset(
      {required super.symbol,
      required super.providerIdentifier,
      required super.decimal,
      required super.network,
      required super.provider,
      super.coingeckoId,
      super.fullName,
      super.logoUrl})
      : super(type: SwapAssetType.native);
}

class PolkadotSwapAsset extends BaseSwapAsset {
  final BigInt? assetId;
  @override
  String get identifier => assetId?.toString() ?? network.identifier;
  PolkadotSwapAsset(
      {required super.symbol,
      required super.providerIdentifier,
      required super.decimal,
      required super.network,
      required super.provider,
      this.assetId,
      super.coingeckoId,
      super.fullName,
      super.logoUrl})
      : super(type: assetId == null ? SwapAssetType.native : SwapAssetType.asset);
}

abstract class BaseSwapAmount with Equatable {
  final String amountString;
  const BaseSwapAmount({required this.amountString});
}

class ViewSwapAmount extends BaseSwapAmount {
  const ViewSwapAmount({required super.amountString});

  @override
  List<dynamic> get variabels => [amountString];
}

class SwapAmount extends BaseSwapAmount {
  final BigInt amount;
  final int decimals;

  bool get isZero => amount == BigInt.zero;
  BigRational get rational => BigRational(amount);
  SwapAmount._(
      {required this.amount, required super.amountString, required this.decimals});
  factory SwapAmount.fromString(String amount, int decimals) {
    final converter = AmountConverter(decimals: decimals, displayPrecision: decimals);
    return SwapAmount._(
        amount: converter.toUnit(amount), amountString: amount, decimals: decimals);
  }
  factory SwapAmount.fromBigInt(BigInt amount, int decimals, {int? amoutDecimal}) {
    final converter =
        AmountConverter(decimals: decimals, displayPrecision: amoutDecimal ?? decimals);
    return SwapAmount._(
        amount: amount, amountString: converter.toAmount(amount), decimals: decimals);
  }

  // SwapAmount operator -(SwapAmount other) {
  //   assert(other.decimals == decimals);
  //   return SwapAmount.fromBigInt(amount - other.amount, decimals);
  // }

  // SwapAmount operator +(SwapAmount other) {
  //   assert(other.decimals == decimals);
  //   return SwapAmount.fromBigInt(amount + other.amount, decimals);
  // }

  @override
  List get variabels => [amount, decimals];
  @override
  String toString() {
    return amountString;
  }
}

class SwapEthereumNetwork extends SwapNetwork {
  BigInt get chainId => BigInt.parse(identifier);

  const SwapEthereumNetwork({
    required super.name,
    required super.identifier,
    super.chainType = ChainType.mainnet,
    required super.logoUrl,
    required super.explorerTxUrl,
    required super.explorerAddressUrl,
  }) : super(type: SwapChainType.ethereum);

  @override
  List get variabels => [identifier, type];
}

class SwapBitcoinNetwork extends SwapNetwork {
  final BasedUtxoNetwork chain;
  final String genesis;
  const SwapBitcoinNetwork({
    required super.name,
    required super.identifier,
    required this.chain,
    required this.genesis,
    super.chainType = ChainType.mainnet,
    required super.logoUrl,
    required super.explorerTxUrl,
    required super.explorerAddressUrl,
  }) : super(type: SwapChainType.bitcoin);

  @override
  Map<String, dynamic> toJson() {
    return {...super.toJson(), "chain": chain.name};
  }

  @override
  List get variabels => [chain, type];
}

class SwapSolanaNetwork extends SwapNetwork {
  // final SolanaChainType chain;
  final String genesis;
  const SwapSolanaNetwork({
    required super.name,
    required super.identifier,
    // required this.chain,
    required this.genesis,
    required super.explorerTxUrl,
    required super.explorerAddressUrl,
    super.chainType = ChainType.mainnet,
    required super.logoUrl,
  }) : super(type: SwapChainType.solana);
  // @override
  // Map<String, dynamic> toJson() {
  //   return {...super.toJson(), "chain": chain.name};
  // }

  @override
  List get variabels => [chainType, type];
}

class SwapCosmosNetwork extends SwapNetwork {
  final String bech32;
  const SwapCosmosNetwork(
      {required super.name,
      required super.identifier,
      required this.bech32,
      required super.explorerTxUrl,
      required super.explorerAddressUrl,
      super.chainType = ChainType.mainnet,
      required super.logoUrl})
      : super(type: SwapChainType.cosmos);

  @override
  Map<String, dynamic> toJson() {
    return {...super.toJson(), "bech32": bech32};
  }

  @override
  List get variabels => [identifier, chainType, type];
}

class SwapSubstrateNetwork extends SwapNetwork {
  final int ss58Format;
  final String genesis;
  const SwapSubstrateNetwork({
    required super.name,
    required super.identifier,
    required this.ss58Format,
    required this.genesis,
    required super.explorerTxUrl,
    required super.explorerAddressUrl,
    super.chainType = ChainType.mainnet,
    required super.logoUrl,
  }) : super(type: SwapChainType.polkadot);

  @override
  List get variabels => [type, chainType, ss58Format];
}

class SwapTronNetwork extends SwapNetwork {
  final String genesis;
  const SwapTronNetwork({
    required super.name,
    required super.identifier,
    required this.genesis,
    required super.explorerTxUrl,
    required super.explorerAddressUrl,
    super.chainType = ChainType.mainnet,
    required super.logoUrl,
  }) : super(type: SwapChainType.tron);

  @override
  List get variabels => [type, chainType];
}

class SwapXRPNetwork extends SwapNetwork {
  final int networkId;
  const SwapXRPNetwork({
    required super.name,
    required super.identifier,
    required this.networkId,
    required super.explorerTxUrl,
    required super.explorerAddressUrl,
    super.chainType = ChainType.mainnet,
    required super.logoUrl,
  }) : super(type: SwapChainType.xrp);

  @override
  List get variabels => [type, chainType];
}

class SwapADANetwork extends SwapNetwork {
  final int protocolMagic;
  const SwapADANetwork({
    required super.name,
    required super.identifier,
    required this.protocolMagic,
    required super.explorerTxUrl,
    required super.explorerAddressUrl,
    super.chainType = ChainType.mainnet,
    required super.logoUrl,
  }) : super(type: SwapChainType.ada);

  @override
  List get variabels => [type, chainType];
}

class SwapZcashNetwork extends SwapNetwork {
  /// 764824073
  /// 000000000032935a403a29822df72549d9a201e08cfbd5b3c770bb0d66615247
  final String nu6BlockHash;
  const SwapZcashNetwork({
    required super.name,
    required super.identifier,
    required this.nu6BlockHash,
    required super.explorerTxUrl,
    required super.explorerAddressUrl,
    super.chainType = ChainType.mainnet,
    required super.logoUrl,
  }) : super(type: SwapChainType.zcash);

  @override
  List get variabels => [type, chainType];
}

class SwapServiceProvider with Equatable {
  final String name;
  final String identifier;
  final String? logoUrl;
  final String? url;
  final bool crossChain;
  final SwapServiceType service;
  const SwapServiceProvider(
      {required this.name,
      required this.identifier,
      required this.logoUrl,
      required this.url,
      required this.service,
      this.crossChain = false});

  @override
  List get variabels => [identifier, service];
}

class SwapFee {
  final String type;
  final BaseSwapAmount amount;
  final String asset;
  final BaseSwapAsset? token;
  const SwapFee(
      {required this.token,
      required this.amount,
      required this.type,
      required this.asset});
}

class SwapRouteGeneralTransactionBuilderParam {
  final String sourceAddress;
  final String destinationAddress;
  final DateTime? expireTime;
  final BigInt? sourceExpireBlock;

  SwapRouteGeneralTransactionBuilderParam(
      {required this.sourceAddress,
      required this.destinationAddress,
      this.expireTime,
      this.sourceExpireBlock});
  T cast<T extends SwapRouteGeneralTransactionBuilderParam>() {
    if (this is! T) {
      throw DartOnChainSwapPluginException("Casting network failed.",
          details: {"expected": "$T", "type": runtimeType.toString()});
    }
    return this as T;
  }
}
