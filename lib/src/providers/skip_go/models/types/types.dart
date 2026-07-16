import 'package:blockchain_utils/utils/utils.dart';
import 'package:on_chain_swap/src/exception/exception.dart';

abstract class SkipGoApiResponse {
  Map<String, dynamic> toJson();
  const SkipGoApiResponse();
}

abstract class SkipGoApiRequestParam {
  Map<String, dynamic> toJson();
}

enum SkipGoApiChainType {
  cosmos,
  evm,
  svm;

  static SkipGoApiChainType fromName(String? name) {
    return values.firstWhere(
      (e) => e.name == name,
      orElse: () {
        throw DartOnChainSwapPluginException("Invalid client chain type.",
            details: {"type": name});
      },
    );
  }
}

class SkipGoApiChainResponse implements SkipGoApiResponse {
  /// Name of the chain
  final String chainName;

  /// Chain-id of the chain
  final String chainId;

  /// Whether the PFM module is enabled on the chain
  final bool pfmEnabled;

  final String? cosmosSdkVersion;

  /// Supported cosmos modules
  final SkipGoApiCosmosModuleSupport? cosmosModuleSupport;

  /// Whether the chain supports IBC memos
  final bool supportMemo;

  /// chain logo URI
  final String? logoUri;

  /// Bech32 prefix of the chain
  final String bech32Prefix;

  /// Fee assets of the chain
  /// Asset used to pay gas fees and the recommended price tiers.
  /// Assets and gas price recommendations are sourced from the keplr chain registry
  final List<SkipGoApiFeeAsset> feeAssets;

  /// Type of chain, e.g. "cosmos" or "evm"
  final SkipGoApiChainType chainType;

  /// IBC capabilities of the chain
  final SkipGoApiIbcCapabilities ibcCapabilities;

  /// Whether the chain is a testnet
  final bool isTestnet;

  /// User friendly name of the chain
  final String prettyName;
  const SkipGoApiChainResponse(
      {required this.chainName,
      required this.chainId,
      required this.pfmEnabled,
      this.cosmosSdkVersion,
      required this.cosmosModuleSupport,
      required this.supportMemo,
      required this.logoUri,
      required this.bech32Prefix,
      required this.feeAssets,
      required this.chainType,
      required this.ibcCapabilities,
      required this.isTestnet,
      required this.prettyName});

  factory SkipGoApiChainResponse.fromJson(Map<String, dynamic> json) {
    return SkipGoApiChainResponse(
        chainName: json.valueAs("chain_name"),
        chainId: json.valueAs("chain_id"),
        pfmEnabled: json.valueAs("pfm_enabled"),
        cosmosModuleSupport: SkipGoApiCosmosModuleSupport.fromJson(
            json.valueEnsureAsMap<String, dynamic>("cosmos_module_support")),
        supportMemo: json.valueAs("supports_memo"),
        logoUri: json.valueAs("logo_uri"),
        bech32Prefix: json.valueAs("bech32_prefix"),
        feeAssets: json
                .valueAsList<List<Map<String, dynamic>>?>("fee_assets")
                ?.map((e) => SkipGoApiFeeAsset.fomJson(e))
                .toList() ??
            [],
        chainType: SkipGoApiChainType.fromName(json.valueAs("chain_type")),
        ibcCapabilities: SkipGoApiIbcCapabilities.fromJson(
            json.valueEnsureAsMap<String, dynamic>("ibc_capabilities")),
        isTestnet: json.valueAs("is_testnet"),
        prettyName: json.valueAs("pretty_name"),
        cosmosSdkVersion: json.valueAs("cosmosSdkVersion"));
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "chain_name": chainName,
      "chain_id": chainId,
      "pfm_enabled": pfmEnabled,
      "cosmos_module_support": cosmosModuleSupport?.toJson(),
      "supports_memo": supportMemo,
      "logo_uri": logoUri,
      "bech32_prefix": bech32Prefix,
      "fee_assets": feeAssets.map((e) => e.toJson()).toList(),
      "chain_type": chainType.name,
      "ibc_capabilities": ibcCapabilities.toJson(),
      "is_testnet": isTestnet,
      "pretty_name": prettyName,
      "cosmosSdkVersion": cosmosSdkVersion
    };
  }
}

class SkipGoApiCosmosModuleSupport implements SkipGoApiResponse {
  final bool authz;
  final bool feegrant;
  const SkipGoApiCosmosModuleSupport(
      {required this.authz, required this.feegrant});
  factory SkipGoApiCosmosModuleSupport.fromJson(Map<String, dynamic> json) {
    return SkipGoApiCosmosModuleSupport(
        feegrant: json.valueAs("feegrant"), authz: json.valueAs("authz"));
  }

  @override
  Map<String, dynamic> toJson() {
    return {"feegrant": feegrant, "authz": authz};
  }
}

class SkipGoApiModuleVersionInfo implements SkipGoApiResponse {
  final String path;
  final String version;
  final String sum;
  const SkipGoApiModuleVersionInfo(
      {required this.path, required this.version, required this.sum});
  factory SkipGoApiModuleVersionInfo.fromJson(Map<String, dynamic> json) {
    return SkipGoApiModuleVersionInfo(
        path: json.valueAs("path"),
        version: json.valueAs("version"),
        sum: json.valueAs("sum"));
  }

  @override
  Map<String, dynamic> toJson() {
    return {"path": path, "version": version, "sum": sum};
  }
}

class SkipGoApiGasPriceInfo implements SkipGoApiResponse {
  final String low;
  final String average;
  final String high;
  const SkipGoApiGasPriceInfo(
      {required this.low, required this.average, required this.high});
  factory SkipGoApiGasPriceInfo.fromJson(Map<String, dynamic> json) {
    return SkipGoApiGasPriceInfo(
        low: json.valueAs("low"),
        average: json.valueAs("average"),
        high: json.valueAs("high"));
  }

  @override
  Map<String, dynamic> toJson() {
    return {"low": low, "average": average, "high": high};
  }
}

class SkipGoApiIbcCapabilities implements SkipGoApiResponse {
  /// Whether the packet forwarding middleware module is supported
  final bool cosmosPfm;

  /// Whether the ibc hooks module is supported
  final bool cosmosIbcHooks;

  /// Whether the chain supports IBC memos
  final bool cosmosMemo;

  /// Whether the autopilot module is supported
  final bool cosmosAutopilot;
  const SkipGoApiIbcCapabilities(
      {required this.cosmosPfm,
      required this.cosmosIbcHooks,
      required this.cosmosMemo,
      required this.cosmosAutopilot});
  factory SkipGoApiIbcCapabilities.fromJson(Map<String, dynamic> json) {
    return SkipGoApiIbcCapabilities(
        cosmosPfm: json.valueAs("cosmos_pfm"),
        cosmosAutopilot: json.valueAs("cosmos_autopilot"),
        cosmosIbcHooks: json.valueAs("cosmos_ibc_hooks"),
        cosmosMemo: json.valueAs("cosmos_memo"));
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "cosmos_pfm": cosmosPfm,
      "cosmos_autopilot": cosmosAutopilot,
      "cosmos_ibc_hooks": cosmosIbcHooks,
      "cosmos_memo": cosmosMemo
    };
  }
}

class SkipGoApiFeeAsset implements SkipGoApiResponse {
  final String denom;
  final SkipGoApiGasPriceInfo? gasPrice;
  const SkipGoApiFeeAsset({required this.denom, required this.gasPrice});
  factory SkipGoApiFeeAsset.fomJson(Map<String, dynamic> json) {
    return SkipGoApiFeeAsset(
        denom: json.valueAs("denom"),
        gasPrice: json.valueTo<SkipGoApiGasPriceInfo?, Map<String, dynamic>>(
            key: "gas_price", parse: SkipGoApiGasPriceInfo.fromJson));
  }

  @override
  Map<String, dynamic> toJson() {
    return {"denom": denom, "gas_price": gasPrice?.toJson()};
  }
}

class SkipGoApiBridge implements SkipGoApiResponse {
  final SkipGoApiBridgeType id;
  final String name;
  final String logoUri;
  const SkipGoApiBridge(
      {required this.id, required this.name, required this.logoUri});
  factory SkipGoApiBridge.fromJson(Map<String, dynamic> json) {
    return SkipGoApiBridge(
        id: SkipGoApiBridgeType.fromName(json.valueAs("id")),
        name: json.valueAs("name"),
        logoUri: json.valueAs("logo_uri"));
  }

  @override
  Map<String, dynamic> toJson() {
    return {"id": id.name, "name": name, "logo_uri": logoUri};
  }
}

enum SkipGoApiBridgeType {
  ibc("IBC"),
  axelar("AXELAR"),
  cctp("CCTP"),
  hyperlane("HYPERLANE"),
  opinit("OPINIT"),
  goFast("GO_FAST"),
  stargate("STARGATE");

  final String name;
  const SkipGoApiBridgeType(this.name);
  static SkipGoApiBridgeType fromName(String? name) {
    return values.firstWhere(
      (e) => e.name == name,
      orElse: () {
        throw DartOnChainSwapPluginException("Invalid bridge type.",
            details: {"type": name});
      },
    );
  }
}

class SkipGoApiBalancesParams implements SkipGoApiRequestParam {
  final String chain;
  final String address;
  final List<String> denoms;
  const SkipGoApiBalancesParams(
      {required this.chain, required this.address, required this.denoms});

  @override
  Map<String, dynamic> toJson() {
    return {
      chain: {"address": address, "denoms": denoms}
    };
  }
}

class SkipGoApiSmartSwapOptionsParams implements SkipGoApiRequestParam {
  final bool splitRoutes;
  final bool evmSwaps;
  const SkipGoApiSmartSwapOptionsParams(
      {required this.splitRoutes, required this.evmSwaps});

  @override
  Map<String, dynamic> toJson() {
    return {"split_routes": splitRoutes, "evm_swaps": evmSwaps};
  }
}

class SkipGoApiError implements SkipGoApiResponse {
  final String message;
  const SkipGoApiError(this.message);
  factory SkipGoApiError.fromJson(Map<String, dynamic> json) {
    return SkipGoApiError(json.valueAs("message"));
  }

  @override
  Map<String, dynamic> toJson() {
    return {"message": message};
  }
}

class SkipGoApiBalanceDenom implements SkipGoApiResponse {
  final String amount;
  final int? decimals;
  final String formattedAmount;
  final String? price;
  final String? valueUsd;
  final SkipGoApiError? error;
  const SkipGoApiBalanceDenom(
      {required this.amount,
      required this.decimals,
      required this.formattedAmount,
      required this.price,
      required this.valueUsd,
      required this.error});
  factory SkipGoApiBalanceDenom.fromJson(Map<String, dynamic> json) {
    return SkipGoApiBalanceDenom(
        amount: json.valueAs("amount"),
        decimals: json.valueAs("decimals"),
        formattedAmount: json.valueAs("formatted_amount"),
        price: json.valueAs("price"),
        valueUsd: json.valueAs("value_usd"),
        error: json.valueTo<SkipGoApiError?, Map<String, dynamic>>(
            key: "error", parse: SkipGoApiError.fromJson));
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "amount": amount,
      "decimals": decimals,
      "formatted_amount": formattedAmount,
      "price": price,
      "value_usd": valueUsd,
      "error": error?.toJson()
    };
  }
}

class SkipGoApiBalanceDemons implements SkipGoApiResponse {
  final Map<String, SkipGoApiBalanceDenom> denoms;
  const SkipGoApiBalanceDemons(this.denoms);
  factory SkipGoApiBalanceDemons.fromJson(Map<String, dynamic> json) {
    return SkipGoApiBalanceDemons(json
        .valueEnsureAsMap<String, dynamic>("denoms")
        .map((k, v) => MapEntry<String, SkipGoApiBalanceDenom>(
            k, SkipGoApiBalanceDenom.fromJson(v))));
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "denoms": denoms
          .map((k, v) => MapEntry<String, Map<String, dynamic>>(k, v.toJson()))
    };
  }
}

class SkipGoApiBalanceChains implements SkipGoApiResponse {
  final Map<String, SkipGoApiBalanceDemons> chains;
  const SkipGoApiBalanceChains(this.chains);
  factory SkipGoApiBalanceChains.fromJson(Map<String, dynamic> json) {
    return SkipGoApiBalanceChains(json
        .valueEnsureAsMap<String, dynamic>("chains")
        .map((k, v) => MapEntry<String, SkipGoApiBalanceDemons>(
            k, SkipGoApiBalanceDemons.fromJson(v))));
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "chains": chains
          .map((k, v) => MapEntry<String, Map<String, dynamic>>(k, v.toJson()))
    };
  }
}

class SkipGoApiVenue implements SkipGoApiResponse {
  /// Chain ID of the swap venue
  final String chainId;

  /// Name of the swap venue
  final String name;
  final String? logoUri;
  const SkipGoApiVenue(
      {required this.chainId, required this.name, this.logoUri});
  factory SkipGoApiVenue.fromJson(Map<String, dynamic> json) {
    return SkipGoApiVenue(
        chainId: json.valueAs("chain_id"),
        name: json.valueAs("name"),
        logoUri: json.valueAs("logo_uri"));
  }

  @override
  Map<String, dynamic> toJson() {
    return {"chain_id": chainId, "name": name, "logo_uri": logoUri};
  }
}

class SkipGoApiAsset implements SkipGoApiResponse {
  /// Denom of the asset
  final String denom;

  /// Chain-id of the asset
  final String chainId;

  /// Coingecko id of the asset
  final String? coingeckoId;

  /// Number of decimals used for amounts of the asset
  final int? decimals;

  /// Description of the asse
  final String? description;

  /// Indicates whether asset is a CW20 token
  final bool? isCw20;

  /// Indicates whether asset is an EVM token
  final bool? isEvm;

  /// Indicates whether asset is an SVM token
  final bool? isSvm;

  /// URI pointing to an image of the logo of the asset
  final String? logoUri;

  /// Name of the asset
  final String? name;

  /// Chain-id of the origin of the asset. If this is an ibc denom,
  /// this is the chain-id of the asset that the ibc token represents
  final String originChainId;

  /// Denom of the origin of the asset. If this is an ibc denom,
  /// this is the original denom that the ibc token represents
  final String originDenom;

  /// Recommended symbol of the asset used to differentiate
  /// between bridged assets with the same symbol,
  /// e.g. USDC.axl for Axelar USDC and USDC.grv for Gravity USDC
  final String? recommendedSymbol;

  /// Symbol of the asset, e.g. ATOM for uatom
  final String? symbol;

  /// Address of the contract for the asset, e.g. if it is a CW20 or ERC20 token
  final String? tokenContract;

  /// The forward slash delimited sequence of ibc ports and channels that can be traversed to unwind an ibc token to its origin asset.
  final String trace;

  const SkipGoApiAsset(
      {required this.denom,
      required this.chainId,
      required this.coingeckoId,
      required this.decimals,
      required this.description,
      required this.isCw20,
      required this.isEvm,
      required this.isSvm,
      required this.logoUri,
      required this.name,
      required this.originChainId,
      required this.originDenom,
      required this.recommendedSymbol,
      required this.symbol,
      required this.tokenContract,
      required this.trace});
  factory SkipGoApiAsset.fromJson(Map<String, dynamic> json) {
    return SkipGoApiAsset(
        denom: json.valueAs("denom"),
        chainId: json.valueAs("chain_id"),
        originDenom: json.valueAs("origin_denom"),
        originChainId: json.valueAs("origin_chain_id"),
        trace: json.valueAs("trace"),
        symbol: json.valueAs("symbol"),
        name: json.valueAs("name"),
        logoUri: json.valueAs("logo_uri"),
        decimals: json.valueAs("decimals"),
        coingeckoId: json.valueAs("coingecko_id"),
        description: json.valueAs("description"),
        recommendedSymbol: json.valueAs("recommended_symbol"),
        isCw20: json.valueAs("is_cw20"),
        isEvm: json.valueAs("is_evm"),
        isSvm: json.valueAs("is_svm"),
        tokenContract: json.valueAs("token_contract"));
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "denom": denom,
      "chain_id": chainId,
      "origin_denom": originDenom,
      "origin_chain_id": originChainId,
      "trace": trace,
      "symbol": symbol,
      "name": name,
      "logo_uri": logoUri,
      "decimals": decimals,
      "coingecko_id": coingeckoId,
      "description": description,
      "recommended_symbol": recommendedSymbol,
      "is_cw20": isCw20,
      "is_evm": isEvm,
      "is_svm": isSvm,
      "token_contract": tokenContract
    };
  }
}

class SkipGoApiAssets implements SkipGoApiResponse {
  final Map<String, List<SkipGoApiAsset>> assets;
  const SkipGoApiAssets(this.assets);
  factory SkipGoApiAssets.fromJson(Map<String, dynamic> json) {
    final chainIds = json.keys;
    Map<String, List<SkipGoApiAsset>> assets = {};
    for (final i in chainIds) {
      assets.addAll({
        i: json
            .valueEnsureAsMap<String, dynamic>(i)
            .valueEnsureAsList<Map<String, dynamic>>("assets")
            .map((e) => SkipGoApiAsset.fromJson(e))
            .toList()
      });
    }
    return SkipGoApiAssets(assets);
  }

  @override
  Map<String, dynamic> toJson() {
    return assets.map((k, v) => MapEntry<String, List<Map<String, dynamic>>>(
        k, v.map((e) => e.toJson()).toList()));
  }
}

enum SkipGoApiRouteOperationType {
  transfer("transfer"),
  bankSend("bank_send"),
  swap("swap"),
  axelarTransfer("axelar_transfer"),
  cctpTransfer("cctp_transfer"),
  hyperlaneTransfer("hyperlane_transfer"),
  evmSwap("evm_swap"),
  opInitTransfer("op_init_transfer"),
  goFastTransfer("go_fast_transfer"),
  stargateTransfer("stargate_transfer");

  final String key;
  const SkipGoApiRouteOperationType(this.key);
  static SkipGoApiRouteOperationType fromName(String? key) {
    return values.firstWhere(
      (e) => e.key == key,
      orElse: () {
        throw DartOnChainSwapPluginException("Invalid operation type.",
            details: {"key": key});
      },
    );
  }
}

abstract class SkipGoApiRouteOperation implements SkipGoApiResponse {
  const SkipGoApiRouteOperation(this.operationType);
  final SkipGoApiRouteOperationType operationType;
}

/// A cross-chain transfer
class SkipGoApiRouteOperationTransfer extends SkipGoApiRouteOperation {
  /// Chain-id on which the transfer is initiated
  final String fromChainId;

  /// Chain-id on which the transfer is received
  final String toChainId;

  /// Channel to use to initiate the transfer
  final String channel;

  /// Denom of the destionation asset of the transfer
  final String destDenom;

  /// Whether pfm is enabled on the chain where the transfer is initiated
  final bool pfmEnabled;

  /// Port to use to initiate the transfer
  final String port;

  /// Whether the transfer chain supports a memo
  final bool supportMemo;

  /// Denom of the input asset of the transfer
  final String denomIn;

  /// Denom of the output asset of the transfer
  final String denomOut;

  /// Amount of the fee asset to be paid valueAs the transfer fee if applicable.
  final String? feeAmount;

  /// Amount of the fee asset to be paid valueAs the transfer fee if applicable, converted to USD value
  final String? usdFeeAmount;

  /// Asset to be paid valueAs the transfer fee if applicable.
  final SkipGoApiAsset? feeAsset;

  /// Bridge Type
  final SkipGoApiBridgeType bridgeId;

  /// Indicates whether this transfer is relayed via Smart Relay
  final bool smartRelay;
  const SkipGoApiRouteOperationTransfer(
      {required this.fromChainId,
      required this.toChainId,
      required this.channel,
      required this.destDenom,
      required this.pfmEnabled,
      required this.port,
      required this.supportMemo,
      required this.denomIn,
      required this.denomOut,
      required this.feeAmount,
      required this.usdFeeAmount,
      required this.feeAsset,
      required this.bridgeId,
      required this.smartRelay})
      : super(SkipGoApiRouteOperationType.transfer);
  factory SkipGoApiRouteOperationTransfer.fromJson(Map<String, dynamic> json) {
    return SkipGoApiRouteOperationTransfer(
        fromChainId: json.valueAs("from_chain_id"),
        toChainId: json.valueAs("to_chain_id"),
        channel: json.valueAs("channel"),
        destDenom: json.valueAs("dest_denom"),
        pfmEnabled: json.valueAs("pfm_enabled"),
        port: json.valueAs("port"),
        supportMemo: json.valueAs("supports_memo"),
        denomIn: json.valueAs("denom_in"),
        denomOut: json.valueAs("denom_out"),
        feeAmount: json.valueAs("fee_amount"),
        usdFeeAmount: json.valueAs("usd_fee_amount"),
        feeAsset: json.valueTo<SkipGoApiAsset?, Map<String, dynamic>>(
            key: "fee_asset", parse: SkipGoApiAsset.fromJson),
        bridgeId: SkipGoApiBridgeType.fromName(json.valueAs("bridge_id")),
        smartRelay: json.valueAs("smart_relay"));
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "from_chain_id": fromChainId,
      "to_chain_id": toChainId,
      "channel": channel,
      "dest_denom": destDenom,
      "pfm_enabled": pfmEnabled,
      "port": port,
      "supports_memo": supportMemo,
      "denom_in": denomIn,
      "denom_out": denomOut,
      "fee_amount": feeAmount,
      "usd_fee_amount": usdFeeAmount,
      "fee_asset": feeAsset?.toJson(),
      "bridge_id": bridgeId.name,
      "smart_relay": smartRelay
    };
  }
}

class SkipGoApiSwap implements SkipGoApiResponse {
  /// Input denom of the swap
  final String denomIn;

  /// Output denom of the swap
  final String denomOut;

  /// Identifier of the pool to use for the swap
  final String pool;

  /// Optional dditional metadata a swap adapter may require
  final String? interface;
  const SkipGoApiSwap(
      {required this.denomIn,
      required this.denomOut,
      required this.pool,
      required this.interface});
  factory SkipGoApiSwap.fromJson(Map<String, dynamic> json) {
    return SkipGoApiSwap(
        denomIn: json.valueAs("denom_in"),
        denomOut: json.valueAs("denom_out"),
        pool: json.valueAs("pool"),
        interface: json.valueAs("interface"));
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "denom_in": denomIn,
      "denom_out": denomOut,
      "pool": pool,
      "interface": interface
    };
  }
}

enum SkipGoApiSwapType {
  swapIn("swap_in"),
  swapOut("swap_out"),
  smartSwapIn("smart_swap_in");

  const SkipGoApiSwapType(this.name);
  final String name;
  static SkipGoApiSwapType fromName(String? name) {
    return values.firstWhere(
      (e) => e.name == name,
      orElse: () {
        throw DartOnChainSwapPluginException("Invalid swap type.",
            details: {"type": name});
      },
    );
  }
}

abstract class SkipGoApiRouteOperationBaseSwap extends SkipGoApiResponse {
  final SkipGoApiSwapType type;
  const SkipGoApiRouteOperationBaseSwap(this.type);
}

/// Specification of a swap with an exact amount in
class SkipGoApiRouteOperaionSwapExactAmountIn
    extends SkipGoApiRouteOperationBaseSwap {
  /// Amount to swap in
  final String? swapAmountIn;

  /// Operations required to execute the swap
  /// Description of a single swap operation
  final List<SkipGoApiSwap> swapOperations;

  /// Swap venue that this swap should execute on
  final SkipGoApiVenue swapVenue;

  /// Price impact of the estimated swap, if present. Measured in percentage e.g. "0.5" is .5%
  final String? priceImpactPercent;
  const SkipGoApiRouteOperaionSwapExactAmountIn(
      {required this.swapAmountIn,
      required this.swapOperations,
      required this.swapVenue,
      required this.priceImpactPercent})
      : super(SkipGoApiSwapType.swapIn);
  factory SkipGoApiRouteOperaionSwapExactAmountIn.fromJson(
      Map<String, dynamic> json) {
    return SkipGoApiRouteOperaionSwapExactAmountIn(
        swapAmountIn: json.valueAs("swap_amount_in"),
        swapOperations: json
            .valueEnsureAsList<Map<String, dynamic>>("swap_operations")
            .map((e) => SkipGoApiSwap.fromJson(e))
            .toList(),
        swapVenue: SkipGoApiVenue.fromJson(
            json.valueEnsureAsMap<String, dynamic>("swap_venue")),
        priceImpactPercent: json.valueAs("price_impact_percent"));
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "price_impact_percent": priceImpactPercent,
      "swap_amount_in": swapAmountIn,
      "swap_operations": swapOperations.map((e) => e.toJson()).toList(),
      "swap_venue": swapVenue.toJson()
    };
  }
}

/// Specification of a swap with an exact amount out
class SkipGoApiRouteOperationSwapExactAmountOut
    extends SkipGoApiRouteOperationBaseSwap {
  /// Amount to get out of the swap
  final String? swapAmountOut;

  /// Operations required to execute the swap
  /// Description of a single swap operation
  final List<SkipGoApiSwap> swapOperations;

  /// Swap venue that this swap should execute on
  final SkipGoApiVenue swapVenue;

  /// Price impact of the estimated swap, if present. Measured in percentage e.g. "0.5" is .5%
  final String? priceImpactPercent;
  const SkipGoApiRouteOperationSwapExactAmountOut(
      {required this.swapAmountOut,
      required this.swapOperations,
      required this.swapVenue,
      required this.priceImpactPercent})
      : super(SkipGoApiSwapType.swapOut);
  factory SkipGoApiRouteOperationSwapExactAmountOut.fromJson(
      Map<String, dynamic> json) {
    return SkipGoApiRouteOperationSwapExactAmountOut(
        swapAmountOut: json.valueAs("swap_amount_out"),
        swapOperations: json
            .valueEnsureAsList<Map<String, dynamic>>("swap_operations")
            .map((e) => SkipGoApiSwap.fromJson(e))
            .toList(),
        swapVenue: SkipGoApiVenue.fromJson(
            json.valueEnsureAsMap<String, dynamic>("swap_venue")),
        priceImpactPercent: json.valueAs("price_impact_percent"));
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "price_impact_percent": priceImpactPercent,
      "swap_amount_out": swapAmountOut,
      "swap_operations": swapOperations.map((e) => e.toJson()).toList(),
      "swap_venue": swapVenue.toJson()
    };
  }
}

/// Routes to execute the swap
class SkipGoApiSwapRoute implements SkipGoApiResponse {
  /// Amount to swap in
  final String swapAmountIn;

  /// Denom in of the swap
  final String denomIn;

  /// Operations required to execute the swap route
  /// Description of a single swap operation
  final List<SkipGoApiSwap> swapOperations;
  const SkipGoApiSwapRoute(
      {required this.swapAmountIn,
      required this.denomIn,
      required this.swapOperations});
  factory SkipGoApiSwapRoute.fromJson(Map<String, dynamic> json) {
    return SkipGoApiSwapRoute(
        swapAmountIn: json.valueAs("swap_amount_in"),
        denomIn: json.valueAs("denom_in"),
        swapOperations: json
            .valueEnsureAsList<Map<String, dynamic>>("swap_operations")
            .map((e) => SkipGoApiSwap.fromJson(e))
            .toList());
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "swap_amount_in": swapAmountIn,
      "denom_in": denomIn,
      "swap_operations": swapOperations.map((e) => e.toJson()).toList()
    };
  }
}

/// Specification of a smart swap in operation
class SkipGoApiRouteOperationSwapSmartSwapIn
    extends SkipGoApiRouteOperationBaseSwap {
  /// Routes to execute the swap
  final List<SkipGoApiSwapRoute> swapRoutes;

  /// Swap venue that this swap should execute on
  final SkipGoApiVenue swapVenue;

  const SkipGoApiRouteOperationSwapSmartSwapIn(
      {required this.swapRoutes, required this.swapVenue})
      : super(SkipGoApiSwapType.smartSwapIn);
  factory SkipGoApiRouteOperationSwapSmartSwapIn.fromJson(
      Map<String, dynamic> json) {
    return SkipGoApiRouteOperationSwapSmartSwapIn(
        swapRoutes: json
            .valueEnsureAsList<Map<String, dynamic>>("swap_routes")
            .map((e) => SkipGoApiSwapRoute.fromJson(e))
            .toList(),
        swapVenue: SkipGoApiVenue.fromJson(
            json.valueEnsureAsMap<String, dynamic>("swap_venue")));
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "swap_routes": swapRoutes.map((e) => e.toJson()).toList(),
      "swap_venue": swapVenue.toJson()
    };
  }
}

class SkipGoApiRouteOperationSwap extends SkipGoApiRouteOperation {
  final SkipGoApiRouteOperationBaseSwap swap;

  /// Estimated total affiliate fee generated by the swap
  final String estimatedAffiliateFee;

  /// Chain ID that the swap will be executed on
  final String chainId;

  /// Chain ID that the swap will be executed on (alias for chain_id)
  final String fromChainId;

  /// Input denom of the swap
  final String denomIn;

  /// Output denom of the swap
  final String denomOut;

  /// Swap venues that the swap will route through
  /// A venue on which swaps can be exceuted
  final List<SkipGoApiVenue> swapVenues;
  const SkipGoApiRouteOperationSwap(
      {required this.swap,
      required this.estimatedAffiliateFee,
      required this.chainId,
      required this.fromChainId,
      required this.denomIn,
      required this.denomOut,
      required this.swapVenues})
      : super(SkipGoApiRouteOperationType.swap);
  factory SkipGoApiRouteOperationSwap.fromJson(Map<String, dynamic> json) {
    return SkipGoApiRouteOperationSwap(
        swap: json.oneOf<SkipGoApiRouteOperationBaseSwap, Map<String, dynamic>>(
            keys: SkipGoApiSwapType.values.map((e) => e.name).toList(),
            parse: (key, e) {
              final type = SkipGoApiSwapType.fromName(key);
              return switch (type) {
                SkipGoApiSwapType.swapIn =>
                  SkipGoApiRouteOperaionSwapExactAmountIn.fromJson(e),
                SkipGoApiSwapType.swapOut =>
                  SkipGoApiRouteOperationSwapExactAmountOut.fromJson(e),
                SkipGoApiSwapType.smartSwapIn =>
                  SkipGoApiRouteOperationSwapSmartSwapIn.fromJson(e),
              };
            }),
        estimatedAffiliateFee: json.valueAs("estimated_affiliate_fee"),
        chainId: json.valueAs("chain_id"),
        fromChainId: json.valueAs("from_chain_id"),
        denomIn: json.valueAs("denom_in"),
        denomOut: json.valueAs("denom_out"),
        swapVenues: json
            .valueEnsureAsList<Map<String, dynamic>>("swap_venues")
            .map((e) => SkipGoApiVenue.fromJson(e))
            .toList());
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      swap.type.name: swap.toJson(),
      "estimated_affiliate_fee": estimatedAffiliateFee,
      "chain_id": chainId,
      "from_chain_id": fromChainId,
      "denom_in": denomIn,
      "denom_out": denomOut,
      "swap_venues": swapVenues.map((e) => e.toJson()).toList()
    };
  }
}

class SkipGoApiRouteOperationAxelarTransfer extends SkipGoApiRouteOperation {
  /// Axelar-name of the asset to bridge
  final String asset;

  /// Amount of the fee asset to be paid valueAs the Axelar bridge fee. This is denominated in the fee asset.
  final String feeAmount;

  /// Name for source chain of the bridge transaction used on Axelar
  final SkipGoApiAsset feeAsset;

  /// Name for source chain of the bridge transaction used on Axelar
  final String fromChain;

  /// Canonical chain-id of the source chain of the bridge transaction
  final String fromChainId;

  /// Whether the source and destination chains are both testnets
  final bool isTestnet;

  /// Whether to unwrap the asset at the destination chain (from ERC-20 to native)
  final bool shouldUnwarp;

  /// Name for destination chain of the bridge transaction used on Axelar
  final String toChain;

  /// Canonical chain-id of the destination chain of the bridge transaction
  final String toChainId;

  /// Denom of the input asset
  final String denomIn;

  /// Denom of the output asset
  final String denomOut;

  /// Amount of the fee asset to be paid valueAs the Axelar bridge fee, converted to USD value
  final String usdFeeAmount;

  /// A cross-chain transfer
  final SkipGoApiRouteOperationTransfer? ibcTransferToAxelar;
  final SkipGoApiBridgeType bridgeId;

  /// Indicates whether this transfer is relayed via Smart Relay
  final bool smartRelay;
  const SkipGoApiRouteOperationAxelarTransfer(
      {required this.asset,
      required this.feeAmount,
      required this.feeAsset,
      required this.fromChain,
      required this.fromChainId,
      required this.isTestnet,
      required this.shouldUnwarp,
      required this.toChain,
      required this.toChainId,
      required this.denomIn,
      required this.denomOut,
      required this.usdFeeAmount,
      required this.ibcTransferToAxelar,
      required this.bridgeId,
      required this.smartRelay})
      : super(SkipGoApiRouteOperationType.axelarTransfer);
  factory SkipGoApiRouteOperationAxelarTransfer.fromJson(
      Map<String, dynamic> json) {
    return SkipGoApiRouteOperationAxelarTransfer(
        asset: json.valueAs("asset"),
        feeAmount: json.valueAs("fee_amount"),
        feeAsset: SkipGoApiAsset.fromJson(json.valueAs("fee_asset")),
        fromChain: json.valueAs("from_chain"),
        fromChainId: json.valueAs("from_chain_id"),
        isTestnet: json.valueAs("is_testnet"),
        shouldUnwarp: json.valueAs("should_unwrap"),
        toChain: json.valueAs("to_chain"),
        toChainId: json.valueAs("to_chain_id"),
        denomIn: json.valueAs("denom_in"),
        denomOut: json.valueAs("denom_out"),
        usdFeeAmount: json.valueAs("usd_fee_amount"),
        ibcTransferToAxelar: json
            .valueTo<SkipGoApiRouteOperationTransfer?, Map<String, dynamic>>(
                key: "ibc_transfer_to_axelar",
                parse: SkipGoApiRouteOperationTransfer.fromJson),
        bridgeId: SkipGoApiBridgeType.fromName(json.valueAs("bridge_id")),
        smartRelay: json.valueAs("smart_relay"));
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "asset": asset,
      "fee_amount": feeAmount,
      "fee_asset": feeAsset.toJson(),
      "from_chain": fromChain,
      "from_chain_id": fromChainId,
      "is_testnet": isTestnet,
      "should_unwrap": shouldUnwarp,
      "to_chain": toChain,
      "to_chain_id": toChainId,
      "denom_in": denomIn,
      "denom_out": denomOut,
      "usd_fee_amount": usdFeeAmount,
      "ibc_transfer_to_axelar": ibcTransferToAxelar?.toJson(),
      "bridge_id": bridgeId.name,
      "smart_relay": smartRelay
    };
  }
}

class SkipGoApiRouteOperationBankSend extends SkipGoApiRouteOperation {
  /// Chain-id of the chain that the transaction is intended for
  final String chainId;

  /// Denom of the asset to send
  final String denom;

  const SkipGoApiRouteOperationBankSend(
      {required this.chainId, required this.denom})
      : super(SkipGoApiRouteOperationType.bankSend);
  factory SkipGoApiRouteOperationBankSend.fromJson(Map<String, dynamic> json) {
    return SkipGoApiRouteOperationBankSend(
        chainId: json.valueAs("chain_id"), denom: json.valueAs("denom"));
  }

  @override
  Map<String, dynamic> toJson() {
    return {"chain_id": chainId, "denom": denom};
  }
}

/// Details about the fee paid for Smart Relaying
class SkipGoApiSmartRelayFeeQuote implements SkipGoApiResponse {
  /// The USDC fee amount
  final String feeAmount;

  /// The fee asset denomination
  final String feeDenom;

  /// The address the fee should be sent to
  final String? feePaymentAddress;

  /// Address of the relayer
  final String relayerAddress;

  /// Expiration time of the fee quote
  final String expiration;

  const SkipGoApiSmartRelayFeeQuote(
      {required this.feeAmount,
      required this.feeDenom,
      required this.feePaymentAddress,
      required this.relayerAddress,
      required this.expiration});
  factory SkipGoApiSmartRelayFeeQuote.fromJson(Map<String, dynamic> json) {
    return SkipGoApiSmartRelayFeeQuote(
        feeAmount: json.valueAs("fee_amount"),
        feeDenom: json.valueAs("fee_denom"),
        feePaymentAddress: json.valueAs("fee_payment_address"),
        relayerAddress: json.valueAs("relayer_address"),
        expiration: json.valueAs("expiration"));
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "fee_amount": feeAmount,
      "fee_denom": feeDenom,
      "fee_payment_address": feePaymentAddress,
      "relayer_address": relayerAddress,
      "expiration": expiration
    };
  }
}

class SkipGoApiRouteOperationCCTPTransfer extends SkipGoApiRouteOperation {
  /// Canonical chain-id of the source chain of the bridge transaction
  final String fromChainId;

  /// Canonical chain-id of the destination chain of the bridge transaction
  final String toChainId;

  /// Name of the asset to bridge. It will be the erc-20 contract address for EVM chains and uusdc for Noble.
  final String burnToken;

  /// Denom of the input asset
  final String denomIn;

  /// Denom of the output asset
  final String denomOut;
  final SkipGoApiBridgeType bridgeId;

  /// Indicates whether this transfer is relayed via Smart Relay
  final bool smartRelay;

  /// Details about the fee paid for Smart Relaying
  final SkipGoApiSmartRelayFeeQuote? smartRelayFeeQuote;

  const SkipGoApiRouteOperationCCTPTransfer(
      {required this.fromChainId,
      required this.toChainId,
      required this.burnToken,
      required this.denomIn,
      required this.denomOut,
      required this.bridgeId,
      required this.smartRelay,
      required this.smartRelayFeeQuote})
      : super(SkipGoApiRouteOperationType.cctpTransfer);
  factory SkipGoApiRouteOperationCCTPTransfer.fromJson(
      Map<String, dynamic> json) {
    return SkipGoApiRouteOperationCCTPTransfer(
        fromChainId: json.valueAs("from_chain_id"),
        toChainId: json.valueAs("to_chain_id"),
        burnToken: json.valueAs("burn_token"),
        denomIn: json.valueAs("denom_in"),
        denomOut: json.valueAs("denom_out"),
        bridgeId: SkipGoApiBridgeType.fromName(json.valueAs("bridge_id")),
        smartRelay: json.valueAs("smart_relay"),
        smartRelayFeeQuote:
            json.valueTo<SkipGoApiSmartRelayFeeQuote?, Map<String, dynamic>>(
                key: "smart_relay_fee_quote",
                parse: SkipGoApiSmartRelayFeeQuote.fromJson));
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "from_chain_id": fromChainId,
      "to_chain_id": toChainId,
      "burn_token": burnToken,
      "denom_in": denomIn,
      "denom_out": denomOut,
      "bridge_id": bridgeId.name,
      "smart_relay": smartRelay,
      "smart_relay_fee_quote": smartRelayFeeQuote?.toJson()
    };
  }
}

class SkipGoApiRouteOperationHyperlaneTransfer extends SkipGoApiRouteOperation {
  /// Canonical chain-id of the source chain of the bridge transaction
  final String fromChainId;

  /// Canonical chain-id of the destination chain of the bridge transaction
  final String toChainId;

  /// Denom of the input asset
  final String denomIn;

  /// Denom of the output asset
  final String denomOut;

  /// Contract address of the hyperlane warp route contract that initiates the transfer
  final String hyperLaneContractAddress;

  /// Amount of the fee asset to be paid valueAs the Hyperlane bridge fee. This is denominated in the fee asset.
  final String feeAmount;
  final SkipGoApiAsset feeAsset;

  /// Amount of the fee asset to be paid valueAs the Hyperlane bridge fee, converted to USD value
  final String? usdFeeAmount;
  final SkipGoApiBridgeType bridgeId;

  /// Indicates whether this transfer is relayed via Smart Relay
  final bool smartRelay;

  const SkipGoApiRouteOperationHyperlaneTransfer(
      {required this.fromChainId,
      required this.toChainId,
      required this.denomIn,
      required this.denomOut,
      required this.hyperLaneContractAddress,
      required this.feeAmount,
      required this.feeAsset,
      required this.usdFeeAmount,
      required this.bridgeId,
      required this.smartRelay})
      : super(SkipGoApiRouteOperationType.hyperlaneTransfer);
  factory SkipGoApiRouteOperationHyperlaneTransfer.fromJson(
      Map<String, dynamic> json) {
    return SkipGoApiRouteOperationHyperlaneTransfer(
        fromChainId: json.valueAs("from_chain_id"),
        toChainId: json.valueAs("to_chain_id"),
        denomIn: json.valueAs("denom_in"),
        denomOut: json.valueAs("denom_out"),
        hyperLaneContractAddress: json.valueAs("hyperlane_contract_address"),
        feeAmount: json.valueAs("fee_amount"),
        feeAsset: SkipGoApiAsset.fromJson(json.valueAs("fee_asset")),
        usdFeeAmount: json.valueAs("usd_fee_amount"),
        bridgeId: SkipGoApiBridgeType.fromName(json.valueAs("bridge_id")),
        smartRelay: json.valueAs("smart_relay"));
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "from_chain_id": fromChainId,
      "to_chain_id": toChainId,
      "denom_in": denomIn,
      "denom_out": denomOut,
      "hyperlane_contract_address": hyperLaneContractAddress,
      "fee_amount": feeAmount,
      "fee_asset": feeAsset.toJson(),
      "usd_fee_amount": usdFeeAmount,
      "bridge_id": bridgeId.name,
      "smart_relay": smartRelay
    };
  }
}

class SkipGoApiRouteOperationEVMSwap extends SkipGoApiRouteOperation {
  /// Address of the input token. Empty string if native token.
  final String inputToken;

  /// Amount of the input token
  final String amountIn;

  /// Calldata for the swap
  final String swapCallData;

  /// Amount of the output token
  final String amoutOut;

  /// Chain-id for the swap
  final String fromChainId;

  /// Denom of the input asset
  final String denomIn;

  /// Denom of the output asset
  final String denomOut;

  /// Venues used for the swap
  /// A venue on which swaps can be exceuted
  final List<SkipGoApiVenue> swapVenues;

  const SkipGoApiRouteOperationEVMSwap(
      {required this.inputToken,
      required this.amountIn,
      required this.swapCallData,
      required this.amoutOut,
      required this.fromChainId,
      required this.denomIn,
      required this.denomOut,
      required this.swapVenues})
      : super(SkipGoApiRouteOperationType.evmSwap);
  factory SkipGoApiRouteOperationEVMSwap.fromJson(Map<String, dynamic> json) {
    return SkipGoApiRouteOperationEVMSwap(
        inputToken: json.valueAs("input_token"),
        amountIn: json.valueAs("amount_in"),
        amoutOut: json.valueAs("amount_out"),
        swapCallData: json.valueAs("swap_calldata"),
        fromChainId: json.valueAs("from_chain_id"),
        denomIn: json.valueAs("denom_in"),
        denomOut: json.valueAs("denom_out"),
        swapVenues: json
            .valueEnsureAsList<Map<String, dynamic>>("swap_venues")
            .map((e) => SkipGoApiVenue.fromJson(e))
            .toList());
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "from_chain_id": fromChainId,
      "input_token": inputToken,
      "denom_in": denomIn,
      "denom_out": denomOut,
      "swap_calldata": swapCallData,
      "swap_venues": swapVenues.map((e) => e.toJson()).toList(),
      "amount_in": amountIn,
      "amount_out": amoutOut,
    };
  }
}

class SkipGoApiRouteOperationOpInit extends SkipGoApiRouteOperation {
  /// Canonical chain-id of the source chain of the bridge transaction
  final String fromChainId;

  /// Canonical chain-id of the destination chain of the bridge transaction
  final String toChainId;

  /// Denom of the input asset
  final String denomIn;

  /// Denom of the output asset
  final String denomOut;

  /// Identifier used by the OPInit bridge to identify the L1-L2 pair the transfer occurs between
  final dynamic opInitBridgeId;

  final SkipGoApiBridgeType bridgeId;

  /// Indicates whether this transfer is relayed via Smart Relay
  final bool smartRelay;
  const SkipGoApiRouteOperationOpInit(
      {required this.fromChainId,
      required this.toChainId,
      required this.denomIn,
      required this.denomOut,
      required this.opInitBridgeId,
      required this.bridgeId,
      required this.smartRelay})
      : super(SkipGoApiRouteOperationType.opInitTransfer);
  factory SkipGoApiRouteOperationOpInit.fromJson(Map<String, dynamic> json) {
    return SkipGoApiRouteOperationOpInit(
        bridgeId: SkipGoApiBridgeType.fromName(json.valueAs("bridge_id")),
        opInitBridgeId: json.valueAs("op_init_bridge_id"),
        fromChainId: json.valueAs("from_chain_id"),
        denomIn: json.valueAs("denom_in"),
        denomOut: json.valueAs("denom_out"),
        smartRelay: json.valueAs("smart_relay"),
        toChainId: json.valueAs("to_chain_id"));
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "from_chain_id": fromChainId,
      "denom_in": denomIn,
      "denom_out": denomOut,
      "bridge_id": bridgeId.name,
      "op_init_bridge_id": opInitBridgeId,
      "smart_relay": smartRelay,
      "to_chain_id": toChainId
    };
  }
}

class SkipGoApiGoFastFee implements SkipGoApiResponse {
  final SkipGoApiAsset feeAsset;
  final String bpsFee;
  final String bpsFeeAmount;
  final String bpsFeeUsd;
  final String sourceChainFeeAmount;
  final String sourceChainFeeUsd;
  final String destinationChainFeeAmount;
  final String destinationChainFeeUsd;

  const SkipGoApiGoFastFee(
      {required this.feeAsset,
      required this.bpsFee,
      required this.bpsFeeAmount,
      required this.bpsFeeUsd,
      required this.sourceChainFeeAmount,
      required this.sourceChainFeeUsd,
      required this.destinationChainFeeAmount,
      required this.destinationChainFeeUsd});
  factory SkipGoApiGoFastFee.fromJson(Map<String, dynamic> json) {
    return SkipGoApiGoFastFee(
        feeAsset: SkipGoApiAsset.fromJson(json.valueAs("fee_asset")),
        bpsFee: json.valueAs("bps_fee"),
        bpsFeeAmount: json.valueAs("bps_fee_amount"),
        bpsFeeUsd: json.valueAs("bps_fee_usd"),
        sourceChainFeeAmount: json.valueAs("source_chain_fee_amount"),
        destinationChainFeeAmount: json.valueAs("destination_chain_fee_amount"),
        destinationChainFeeUsd: json.valueAs("destination_chain_fee_usd"),
        sourceChainFeeUsd: json.valueAs("source_chain_fee_usd"));
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "fee_asset": feeAsset.toJson(),
      "bps_fee": bpsFee,
      "bps_fee_amount": bpsFeeAmount,
      "bps_fee_usd": bpsFeeUsd,
      "source_chain_fee_amount": sourceChainFeeAmount,
      "destination_chain_fee_usd": destinationChainFeeUsd,
      "source_chain_fee_usd": sourceChainFeeUsd,
      "destination_chain_fee_amount": destinationChainFeeAmount
    };
  }
}

class SkipGoApiRouteOperationGoFastTransfer extends SkipGoApiRouteOperation {
  final String fromChainId;
  final String toChainId;
  final SkipGoApiGoFastFee fee;
  final SkipGoApiBridgeType bridgeId;
  final String denomIn;
  final String denomOut;
  final String sourceDomain;
  final String destinationDomain;
  const SkipGoApiRouteOperationGoFastTransfer({
    required this.fromChainId,
    required this.toChainId,
    required this.denomIn,
    required this.denomOut,
    required this.bridgeId,
    required this.destinationDomain,
    required this.fee,
    required this.sourceDomain,
  }) : super(SkipGoApiRouteOperationType.goFastTransfer);
  factory SkipGoApiRouteOperationGoFastTransfer.fromJson(
      Map<String, dynamic> json) {
    return SkipGoApiRouteOperationGoFastTransfer(
        bridgeId: SkipGoApiBridgeType.fromName(json.valueAs("bridge_id")),
        fromChainId: json.valueAs("from_chain_id"),
        denomIn: json.valueAs("denom_in"),
        denomOut: json.valueAs("denom_out"),
        toChainId: json.valueAs("to_chain_id"),
        destinationDomain: json.valueAs("destination_domain"),
        fee: SkipGoApiGoFastFee.fromJson(
            json.valueEnsureAsMap<String, dynamic>("fee")),
        sourceDomain: json.valueAs("source_domain"));
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "from_chain_id": fromChainId,
      "denom_in": denomIn,
      "denom_out": denomOut,
      "bridge_id": bridgeId.name,
      "destination_domain": destinationDomain,
      "source_domain": sourceDomain,
      "to_chain_id": toChainId,
      "fee": fee.toJson()
    };
  }
}

class SkipGoApiRouteOperationStargateTransfer extends SkipGoApiRouteOperation {
  final String fromChainId;
  final String toChainId;
  final String denomIn;
  final String denomOut;
  final String poolAddress;
  final int destinationEndpointId;
  final SkipGoApiAsset oftFeeAsset;
  final String oftFeeAmount;
  final String oftFeeAmountUsd;
  final SkipGoApiAsset messagingFeeAsset;
  final String messagingFeeAmount;
  final String messagingFeeAmountUsd;
  final SkipGoApiBridgeType bridgeId;

  const SkipGoApiRouteOperationStargateTransfer({
    required this.fromChainId,
    required this.toChainId,
    required this.denomIn,
    required this.denomOut,
    required this.poolAddress,
    required this.destinationEndpointId,
    required this.oftFeeAsset,
    required this.oftFeeAmount,
    required this.oftFeeAmountUsd,
    required this.messagingFeeAsset,
    required this.messagingFeeAmount,
    required this.messagingFeeAmountUsd,
    required this.bridgeId,
  }) : super(SkipGoApiRouteOperationType.stargateTransfer);
  factory SkipGoApiRouteOperationStargateTransfer.fromJson(
      Map<String, dynamic> json) {
    return SkipGoApiRouteOperationStargateTransfer(
        fromChainId: json.valueAs("from_chain_id"),
        denomIn: json.valueAs("denom_in"),
        denomOut: json.valueAs("denom_out"),
        toChainId: json.valueAs("to_chain_id"),
        destinationEndpointId: json.valueAs("destination_endpoint_id"),
        oftFeeAsset: SkipGoApiAsset.fromJson(
            json.valueEnsureAsMap<String, dynamic>("oft_fee_asset")),
        messagingFeeAmount: json.valueAs("messaging_fee_amount"),
        messagingFeeAmountUsd: json.valueAs("messaging_fee_amount_usd"),
        messagingFeeAsset: SkipGoApiAsset.fromJson(
            json.valueEnsureAsMap<String, dynamic>("messaging_fee_asset")),
        oftFeeAmount: json.valueAs("oft_fee_amount"),
        oftFeeAmountUsd: json.valueAs("oft_fee_amount_usd"),
        poolAddress: json.valueAs("pool_address"),
        bridgeId: SkipGoApiBridgeType.fromName(json.valueAs("bridge_id")));
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "from_chain_id": fromChainId,
      "denom_in": denomIn,
      "denom_out": denomOut,
      "bridge_id": bridgeId.name,
      "destination_endpoint_id": destinationEndpointId,
      "oft_fee_asset": oftFeeAsset.toJson(),
      "messaging_fee_amount": messagingFeeAmount,
      "messaging_fee_asset": messagingFeeAsset.toJson(),
      "messaging_fee_amount_usd": messagingFeeAmountUsd,
      "oft_fee_amount": oftFeeAmount,
      "oft_fee_amount_usd": oftFeeAmountUsd,
      "pool_address": poolAddress,
      "to_chain_id": toChainId
    };
  }
}

class SkipGoApiOperation extends SkipGoApiResponse {
  final SkipGoApiRouteOperation operation;

  /// Index of the tx returned from Msgs that executes this operation
  final int txIndex;

  /// Amount of input asset to this operation
  final String amountIn;

  /// Amount of output asset from this operation
  final String amountOut;
  const SkipGoApiOperation(
      {required this.operation,
      required this.txIndex,
      required this.amountIn,
      required this.amountOut});
  factory SkipGoApiOperation.fromJson(Map<String, dynamic> json) {
    return SkipGoApiOperation(
        operation: json.oneOf<SkipGoApiRouteOperation, Map<String, dynamic>>(
          keys: SkipGoApiRouteOperationType.values.map((e) => e.key).toList(),
          parse: (key, e) {
            final type = SkipGoApiRouteOperationType.fromName(key);
            return switch (type) {
              SkipGoApiRouteOperationType.transfer =>
                SkipGoApiRouteOperationTransfer.fromJson(e),
              SkipGoApiRouteOperationType.axelarTransfer =>
                SkipGoApiRouteOperationAxelarTransfer.fromJson(e),
              SkipGoApiRouteOperationType.swap =>
                SkipGoApiRouteOperationSwap.fromJson(e),
              SkipGoApiRouteOperationType.bankSend =>
                SkipGoApiRouteOperationBankSend.fromJson(e),
              SkipGoApiRouteOperationType.cctpTransfer =>
                SkipGoApiRouteOperationCCTPTransfer.fromJson(e),
              SkipGoApiRouteOperationType.evmSwap =>
                SkipGoApiRouteOperationEVMSwap.fromJson(e),
              SkipGoApiRouteOperationType.stargateTransfer =>
                SkipGoApiRouteOperationStargateTransfer.fromJson(e),
              SkipGoApiRouteOperationType.opInitTransfer =>
                SkipGoApiRouteOperationOpInit.fromJson(e),
              SkipGoApiRouteOperationType.hyperlaneTransfer =>
                SkipGoApiRouteOperationHyperlaneTransfer.fromJson(e),
              SkipGoApiRouteOperationType.goFastTransfer =>
                SkipGoApiRouteOperationGoFastTransfer.fromJson(e),
            };
          },
        ),
        txIndex: json.valueAs("tx_index"),
        amountIn: json.valueAs("amount_in"),
        amountOut: json.valueAs("amount_out"));
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      operation.operationType.key: operation.toJson(),
      "tx_index": txIndex,
      "amount_in": amountIn,
      "amount_out": amountOut
    };
  }
}

enum SkipGoApiRouteWarningType {
  lowInfoWarning("LOW_INFO_WARNING"),
  badPriceWarning("BAD_PRICE_WARNING");

  final String name;
  const SkipGoApiRouteWarningType(this.name);
  static SkipGoApiRouteWarningType fromName(String? name) {
    return values.firstWhere(
      (e) => e.name == name,
      orElse: () {
        throw DartOnChainSwapPluginException("Invalid route warning type.",
            details: {"type": name});
      },
    );
  }
}

class SkipGoApiRouteWarning extends SkipGoApiResponse {
  final SkipGoApiRouteWarningType type;
  final String message;
  const SkipGoApiRouteWarning({required this.type, required this.message});
  factory SkipGoApiRouteWarning.fromJson(Map<String, dynamic> json) {
    return SkipGoApiRouteWarning(
        type: SkipGoApiRouteWarningType.fromName(json.valueAs("type")),
        message: json.valueAs("message"));
  }

  @override
  Map<String, dynamic> toJson() {
    return {"type": type.name, "message": message};
  }
}

class SkipGoApiRouteEstimatedFee extends SkipGoApiResponse {
  final String feeType;
  final SkipGoApiBridgeType bridgeId;

  /// Amount of the fee asset to be paid
  final String amount;

  /// The value of the fee in USD
  final String usdAmount;
  final SkipGoApiAsset originAsset;

  /// Chain ID of the chain where fees are collected
  final String chainId;

  /// The index of the transaction in the list of transactions required to execute the transfer where fees are paid
  final int txIndex;

  /// The index of the operation in the returned operations list which incurs the fee
  final int? operationIndex;

  const SkipGoApiRouteEstimatedFee(
      {required this.feeType,
      required this.bridgeId,
      required this.amount,
      required this.usdAmount,
      required this.originAsset,
      required this.chainId,
      required this.txIndex,
      required this.operationIndex});
  factory SkipGoApiRouteEstimatedFee.fromJson(Map<String, dynamic> json) {
    return SkipGoApiRouteEstimatedFee(
        amount: json.valueAs("amount"),
        bridgeId: SkipGoApiBridgeType.fromName(json.valueAs("bridge_id")),
        chainId: json.valueAs("chain_id"),
        feeType: json.valueAs("fee_type"),
        operationIndex: json.valueAs("operation_index"),
        originAsset: SkipGoApiAsset.fromJson(json.valueAs("origin_asset")),
        txIndex: json.valueAs("tx_index"),
        usdAmount: json.valueAs("usd_amount"));
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "amount": amount,
      "bridge_id": bridgeId.name,
      "fee_type": feeType,
      "chain_id": chainId,
      "operation_index": operationIndex,
      "origin_asset": originAsset.toJson(),
      "usd_amount": usdAmount,
      "tx_index": txIndex
    };
  }
}

class SkipGoApiRoute extends SkipGoApiResponse {
  /// Amount of source asset to be transferred or swapped
  final String amountIn;

  /// Amount of destination asset out
  final String amountOut;

  /// Chain-ids of all chains of the transfer or swap, in order of usage by operations in the route
  final List<String> chainIds;

  /// All chain-ids that require an address to be provided for, in order of usage by operations in the route
  final dynamic requiredChainAddresses;

  /// Chain-id of the destination asset
  final String destAssetChainId;

  /// Denom of the destination asset
  final String destAssetDenom;

  /// Whether this route performs a swap
  final bool doesSwap;

  /// Amount of destination asset out, if a swap is performed
  final String? estimatedAmountOut;

  /// Array of operations required to perform the transfer or swap
  final List<SkipGoApiOperation> operations;

  /// Chain-id of the source asset
  final String sourceAssetChainId;

  /// Denom of the source asset
  final String sourceAssetDenom;

  /// Swap venue on which the swap is performed, if a swap is performed
  final SkipGoApiVenue? swapVenue;

  /// Number of transactions required to perform the transfer or swap
  final int txsRequired;

  /// Amount of the source denom, converted to USD value
  final String? usdAmountIn;

  /// Amount of the destination denom expected to be received, converted to USD value
  final String? usdAmountOut;

  /// Price impact of the estimated swap, if present. Measured in percentage e.g. "0.5" is .5%
  final String? swapPriceImpactPercent;

  /// Indicates if the route is unsafe due to poor execution price or if safety
  /// cannot be determined due to lack of pricing information
  final SkipGoApiRouteWarning? warning;

  /// Indicates fees incurred in the execution of the transfer
  final List<SkipGoApiRouteEstimatedFee> estimatedFees;

  /// The estimated time in seconds for the route to execute
  final int estimatedRouteDurationSeconds;
  const SkipGoApiRoute(
      {required this.amountIn,
      required this.amountOut,
      required this.chainIds,
      required this.requiredChainAddresses,
      required this.destAssetChainId,
      required this.destAssetDenom,
      required this.doesSwap,
      required this.estimatedAmountOut,
      required this.operations,
      required this.sourceAssetChainId,
      required this.sourceAssetDenom,
      required this.swapVenue,
      required this.txsRequired,
      required this.usdAmountIn,
      required this.usdAmountOut,
      required this.swapPriceImpactPercent,
      required this.warning,
      required this.estimatedFees,
      required this.estimatedRouteDurationSeconds});
  factory SkipGoApiRoute.fromJson(Map<String, dynamic> json) {
    return SkipGoApiRoute(
        amountIn: json.valueAs("amount_in"),
        amountOut: json.valueAs("amount_out"),
        chainIds: json.valueEnsureAsList<String>("chain_ids"),
        requiredChainAddresses: json.valueAs("required_chain_addresses"),
        destAssetChainId: json.valueAs("dest_asset_chain_id"),
        destAssetDenom: json.valueAs("dest_asset_denom"),
        doesSwap: json.valueAs("does_swap"),
        estimatedAmountOut: json.valueAs("estimated_amount_out"),
        operations: json
            .valueEnsureAsList<Map<String, dynamic>>("operations")
            .map((e) => SkipGoApiOperation.fromJson(e))
            .toList(),
        sourceAssetChainId: json.valueAs("source_asset_chain_id"),
        sourceAssetDenom: json.valueAs("source_asset_denom"),
        swapVenue: json.valueTo<SkipGoApiVenue?, Map<String, dynamic>>(
            key: "swap_venue", parse: SkipGoApiVenue.fromJson),
        txsRequired: json.valueAs("txs_required"),
        usdAmountIn: json.valueAs("usd_amount_in"),
        usdAmountOut: json.valueAs("usd_amount_out"),
        swapPriceImpactPercent: json.valueAs("swap_price_impact_percent"),
        warning: json.valueTo<SkipGoApiRouteWarning?, Map<String, dynamic>>(
            key: "warning", parse: SkipGoApiRouteWarning.fromJson),
        estimatedFees: json
            .valueEnsureAsList<Map<String, dynamic>>("estimated_fees")
            .map((e) => SkipGoApiRouteEstimatedFee.fromJson(e))
            .toList(),
        estimatedRouteDurationSeconds:
            json.valueAs("estimated_route_duration_seconds"));
  }
  @override
  Map<String, dynamic> toJson() {
    return {
      "amount_in": amountIn,
      "amount_out": amountOut,
      "chain_ids": chainIds,
      "required_chain_addresses": requiredChainAddresses,
      "dest_asset_chain_id": destAssetChainId,
      "dest_asset_denom": destAssetDenom,
      "does_swap": doesSwap,
      "estimated_amount_out": estimatedAmountOut,
      "operations": operations.map((e) => e.toJson()).toList(),
      "source_asset_chain_id": sourceAssetChainId,
      "source_asset_denom": sourceAssetDenom,
      "swap_venue": swapVenue?.toJson(),
      "txs_required": txsRequired,
      "usd_amount_in": usdAmountIn,
      "usd_amount_out": usdAmountOut,
      "swap_price_impact_percent": swapPriceImpactPercent,
      "warning": warning?.toJson(),
      "estimated_fees": estimatedFees.map((e) => e.toJson()).toList(),
      "estimated_route_duration_seconds": estimatedRouteDurationSeconds,
    };
  }
}

enum SkipGoApiMessageType {
  multiChainMessage("multi_chain_msg"),
  evmTx("evm_tx"),
  svmTx("svm_tx");

  final String key;
  const SkipGoApiMessageType(this.key);
  static SkipGoApiMessageType fromName(String? name) {
    return values.firstWhere(
      (e) => e.key == name,
      orElse: () {
        throw DartOnChainSwapPluginException("Invalid message type.",
            details: {"type": name});
      },
    );
  }
}

enum SkipGoApiTxType {
  cosmosTx("cosmos_tx"),
  evmTx("evm_tx"),
  svmTx("svm_tx");

  final String key;
  const SkipGoApiTxType(this.key);
  static SkipGoApiTxType fromName(String? name) {
    return values.firstWhere(
      (e) => e.key == name,
      orElse: () {
        throw DartOnChainSwapPluginException("Invalid Tx type.",
            details: {"type": name});
      },
    );
  }
}

abstract class SkipGoApiMessage extends SkipGoApiResponse {
  final SkipGoApiMessageType messageType;
  const SkipGoApiMessage(this.messageType);
  factory SkipGoApiMessage.fromJson(Map<String, dynamic> json) {
    return json.oneOf<SkipGoApiMessage, Map<String, dynamic>>(
      keys: SkipGoApiMessageType.values.map((e) => e.key).toList(),
      parse: (key, e) {
        final type = SkipGoApiMessageType.fromName(key);
        return switch (type) {
          SkipGoApiMessageType.evmTx => SkipGoApiMessageEVMTx.fromJson(e),
          SkipGoApiMessageType.svmTx => SkipGoApiMessageSVMTx.fromJson(e),
          SkipGoApiMessageType.multiChainMessage =>
            SkipGoApiMessageMultiChainMessage.fromJson(e),
        };
      },
    );
  }
}

class SkipGoApiERC20Approvals extends SkipGoApiResponse {
  /// Amount of the approval
  final String amount;

  /// Address of the spender
  final String spender;

  /// Address of the ERC20 token contract
  final String tokenContract;
  const SkipGoApiERC20Approvals(
      {required this.amount,
      required this.spender,
      required this.tokenContract});
  factory SkipGoApiERC20Approvals.fromJson(Map<String, dynamic> json) {
    return SkipGoApiERC20Approvals(
        amount: json.valueAs("amount"),
        spender: json.valueAs("spender"),
        tokenContract: json.valueAs("token_contract"));
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "amount": amount,
      "spender": spender,
      "token_contract": tokenContract
    };
  }
}

class SkipGoApiMessageEVMTx extends SkipGoApiMessage implements SkipGoApiTx {
  /// Chain-id of the chain that the transaction is intended for
  final String chainId;

  /// Data of the transaction
  final String data;

  /// ERC20 approvals required for the transaction
  /// An ERC20 token contract approval
  final List<SkipGoApiERC20Approvals> requiredErc20Approvals;

  /// The address of the wallet that will sign this transaction
  final String signerAddress;

  /// Address of the recipient of the transaction
  final String to;

  /// Amount of the transaction
  final String value;
  const SkipGoApiMessageEVMTx(
      {required this.chainId,
      required this.data,
      required this.requiredErc20Approvals,
      required this.signerAddress,
      required this.to,
      required this.value})
      : super(SkipGoApiMessageType.evmTx);
  factory SkipGoApiMessageEVMTx.fromJson(Map<String, dynamic> json) {
    return SkipGoApiMessageEVMTx(
        chainId: json.valueAs("chain_id"),
        data: json.valueAs("data"),
        requiredErc20Approvals: json
            .valueEnsureAsList<Map<String, dynamic>>("required_erc20_approvals")
            .map((e) => SkipGoApiERC20Approvals.fromJson(e))
            .toList(),
        signerAddress: json.valueAs("signer_address"),
        to: json.valueAs("to"),
        value: json.valueAs("value"));
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "chain_id": chainId,
      "data": data,
      "required_erc20_approvals":
          requiredErc20Approvals.map((e) => e.toJson()).toList(),
      "signer_address": signerAddress,
      "to": to,
      "value": value
    };
  }

  @override
  SkipGoApiTxType get txType => SkipGoApiTxType.evmTx;
}

class SkipGoApiMessageMultiChainMessage extends SkipGoApiMessage {
  /// Chain-id of the chain that the transaction containing the message is intended for
  final String chainId;

  /// JSON string of the message
  final String msg;

  /// TypeUrl of the message
  final String msgTypeUrl;

  /// Path of chain-ids that the message is intended to interact with
  final List<String> path;
  const SkipGoApiMessageMultiChainMessage(
      {required this.chainId,
      required this.msg,
      required this.msgTypeUrl,
      required this.path})
      : super(SkipGoApiMessageType.multiChainMessage);
  factory SkipGoApiMessageMultiChainMessage.fromJson(
      Map<String, dynamic> json) {
    return SkipGoApiMessageMultiChainMessage(
        chainId: json.valueAs("chain_id"),
        msg: json.valueAs("msg"),
        msgTypeUrl: json.valueAs("msg_type_url"),
        path: json.valueEnsureAsList<String>("path"));
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "chain_id": chainId,
      "msg": msg,
      "msg_type_url": msgTypeUrl,
      "path": path
    };
  }
}

class SkipGoApiMessageSVMTx extends SkipGoApiMessage implements SkipGoApiTx {
  /// Chain-id of the chain that the transaction is intended for
  final String chainId;

  /// Base64 encoded unsigned or partially signed transaction
  final String tx;

  /// The address of the wallet that will sign this transaction
  final String signerAddress;

  const SkipGoApiMessageSVMTx(
      {required this.chainId, required this.tx, required this.signerAddress})
      : super(SkipGoApiMessageType.evmTx);
  factory SkipGoApiMessageSVMTx.fromJson(Map<String, dynamic> json) {
    return SkipGoApiMessageSVMTx(
        chainId: json.valueAs("chain_id"),
        tx: json.valueAs("tx"),
        signerAddress: json.valueAs("signer_address"));
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "chain_id": chainId,
      "tx": tx,
      "signer_address": signerAddress,
    };
  }

  @override
  SkipGoApiTxType get txType => SkipGoApiTxType.svmTx;
}

class SkipGoApiCosmosTxMessage extends SkipGoApiResponse {
  /// JSON string of the message
  final String msg;

  /// TypeUrl of the message
  final String msgTypeUrl;

  const SkipGoApiCosmosTxMessage({required this.msg, required this.msgTypeUrl});
  factory SkipGoApiCosmosTxMessage.fromJson(Map<String, dynamic> json) {
    return SkipGoApiCosmosTxMessage(
        msg: json.valueAs("msg"), msgTypeUrl: json.valueAs("msg_type_url"));
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "msg": msg,
      "msg_type_url": msgTypeUrl,
    };
  }
}

abstract class SkipGoApiTx implements SkipGoApiResponse {
  final SkipGoApiTxType txType;
  const SkipGoApiTx(this.txType);
  factory SkipGoApiTx.fromJson(Map<String, dynamic> json) {
    return json.oneOf<SkipGoApiTx, Map<String, dynamic>>(
      keys: SkipGoApiTxType.values.map((e) => e.key).toList(),
      parse: (key, e) {
        final type = SkipGoApiTxType.fromName(key);
        return switch (type) {
          SkipGoApiTxType.evmTx => SkipGoApiMessageEVMTx.fromJson(e),
          SkipGoApiTxType.svmTx => SkipGoApiMessageSVMTx.fromJson(e),
          SkipGoApiTxType.cosmosTx => SkipGoApiCosmosTx.fromJson(e)
        };
      },
    );
  }
}

class SkipGoApiCosmosTx implements SkipGoApiTx {
  /// Chain-id of the chain that the transaction is intended for
  final String chainId;

  /// Path of chain-ids that the message is intended to interact with
  final List<String> path;

  /// The address of the wallet that will sign this transaction
  final String signerAddress;

  /// The messages that should be included in the transaction. The ordering must be adhered to.
  /// A message in a cosmos transaction
  final List<SkipGoApiCosmosTxMessage> msgs;

  const SkipGoApiCosmosTx(
      {required this.chainId,
      required this.path,
      required this.signerAddress,
      required this.msgs});
  factory SkipGoApiCosmosTx.fromJson(Map<String, dynamic> json) {
    return SkipGoApiCosmosTx(
        chainId: json.valueAs("chain_id"),
        path: json.valueEnsureAsList<String>("path"),
        msgs: json
            .valueEnsureAsList<Map<String, dynamic>>("msgs")
            .map((e) => SkipGoApiCosmosTxMessage.fromJson(e))
            .toList(),
        signerAddress: json.valueAs("signer_address"));
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "chain_id": chainId,
      "path": path,
      "msgs": msgs.map((e) => e.toJson()).toList(),
      "signer_address": signerAddress
    };
  }

  @override
  SkipGoApiTxType get txType => SkipGoApiTxType.cosmosTx;
}

abstract class SkipGoApiPostRouteHandler implements SkipGoApiRequestParam {
  const SkipGoApiPostRouteHandler();
}

class SkipGoApiPostRouteHandlerWasmMsg extends SkipGoApiPostRouteHandler {
  /// Address of the contract to execute the message on
  final String contractAddress;

  /// JSON string of the message
  final String msg;
  const SkipGoApiPostRouteHandlerWasmMsg(
      {required this.contractAddress, required this.msg});

  @override
  Map<String, dynamic> toJson() {
    return {"contract_address": contractAddress, "msg": msg};
  }
}

enum SkipGoApiPostRouteHandlerAutpilotMsgAction {
  liquidStake("LIQUID_STAKE"),
  claim("CLAIM");

  final String name;
  const SkipGoApiPostRouteHandlerAutpilotMsgAction(this.name);
}

class SkipGoApiPostRouteHandlerAutpilotMsg extends SkipGoApiPostRouteHandler {
  final SkipGoApiPostRouteHandlerAutpilotMsgAction action;

  final String receiver;
  const SkipGoApiPostRouteHandlerAutpilotMsg(
      {required this.action, required this.receiver});

  @override
  Map<String, dynamic> toJson() {
    return {"action": action.name, "receiver": receiver};
  }
}

class SkipGoApiAffiliates implements SkipGoApiRequestParam {
  /// Address to which to pay the fee
  final String address;

  /// Bps fee to pay to the affiliate
  final String basisPointsFee;
  const SkipGoApiAffiliates(
      {required this.address, required this.basisPointsFee});

  @override
  Map<String, dynamic> toJson() {
    return {"address": address, "basis_points_fee": basisPointsFee};
  }
}

class SkipGoApiChainAffiliates implements SkipGoApiRequestParam {
  final List<SkipGoApiAffiliates> affiliates;
  const SkipGoApiChainAffiliates(this.affiliates);

  @override
  Map<String, dynamic> toJson() {
    return {"affiliates": affiliates.map((e) => e.toJson()).toList()};
  }
}

enum SkipGoApiMsgWarningType {
  insufficientGasAtDestEoa("INSUFFICIENT_GAS_AT_DEST_EOA"),
  insufficientGasAtIntermediate("INSUFFICIENT_GAS_AT_INTERMEDIATE");

  final String name;
  const SkipGoApiMsgWarningType(this.name);
  static SkipGoApiMsgWarningType fromName(String? name) {
    return values.firstWhere(
      (e) => e.name == name,
      orElse: () {
        throw DartOnChainSwapPluginException("Invalid MSG Warning type.",
            details: {"type": name});
      },
    );
  }
}

class SkipGoApiMsgWarning extends SkipGoApiResponse {
  final SkipGoApiMsgWarningType type;
  final String message;
  const SkipGoApiMsgWarning({required this.type, required this.message});
  factory SkipGoApiMsgWarning.fromJson(Map<String, dynamic> json) {
    return SkipGoApiMsgWarning(
        type: SkipGoApiMsgWarningType.fromName(json.valueAs("type")),
        message: json.valueAs("message"));
  }
  @override
  Map<String, dynamic> toJson() {
    return {"type": type.name, "message": message};
  }
}

class SkipGoApiMsgs extends SkipGoApiResponse {
  final List<SkipGoApiMessage> msgs;
  final List<SkipGoApiTx> txs;

  /// Indicates fees incurred in the execution of the transfer
  final List<SkipGoApiRouteEstimatedFee> estimatedFees;
  final SkipGoApiMsgWarning? warning;

  const SkipGoApiMsgs({
    required this.msgs,
    required this.txs,
    required this.estimatedFees,
    required this.warning,
  });
  factory SkipGoApiMsgs.fromJson(Map<String, dynamic> json) {
    return SkipGoApiMsgs(
        msgs: json
            .valueEnsureAsList<Map<String, dynamic>>("msgs")
            .map((e) => SkipGoApiMessage.fromJson(e))
            .toList(),
        txs: json
            .valueEnsureAsList<Map<String, dynamic>>("txs")
            .map((e) => SkipGoApiTx.fromJson(e))
            .toList(),
        estimatedFees: json
            .valueEnsureAsList<Map<String, dynamic>>("estimated_fees")
            .map((e) => SkipGoApiRouteEstimatedFee.fromJson(e))
            .toList(),
        warning: json.valueTo<SkipGoApiMsgWarning?, Map<String, dynamic>>(
            key: "warning", parse: SkipGoApiMsgWarning.fromJson));
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "msgs": msgs.map((e) => e.toJson()).toList(),
      "txs": txs.map((e) => e.toJson()).toList(),
      "estimated_fees": estimatedFees.map((e) => e.toJson()).toList(),
      "warning": warning?.toJson()
    };
  }
}

class SkipGoApiSmartSwapOptions implements SkipGoApiRequestParam {
  /// Indicates whether the swap can be split into multiple swap routes
  final bool splitRoutes;

  /// Indicates whether to include routes that swap on EVM chains
  final bool evmSwaps;
  const SkipGoApiSmartSwapOptions(
      {required this.splitRoutes, required this.evmSwaps});

  @override
  Map<String, dynamic> toJson() {
    return {"split_routes": splitRoutes, "evm_swaps": evmSwaps};
  }
}

class SkipGoApiMsgsDirect extends SkipGoApiResponse {
  final List<SkipGoApiMessage> msgs;
  final List<SkipGoApiTx> txs;

  final SkipGoApiRoute route;
  final SkipGoApiMsgWarning? warning;

  const SkipGoApiMsgsDirect({
    required this.msgs,
    required this.txs,
    required this.route,
    required this.warning,
  });
  factory SkipGoApiMsgsDirect.fromJson(Map<String, dynamic> json) {
    return SkipGoApiMsgsDirect(
        msgs: json
            .valueEnsureAsList<Map<String, dynamic>>("msgs")
            .map((e) => SkipGoApiMessage.fromJson(e))
            .toList(),
        txs: json
            .valueEnsureAsList<Map<String, dynamic>>("msgs")
            .map((e) => SkipGoApiTx.fromJson(e))
            .toList(),
        route: SkipGoApiRoute.fromJson(
            json.valueEnsureAsMap<String, dynamic>("route")),
        warning: json.valueTo<SkipGoApiMsgWarning?, Map<String, dynamic>>(
            key: "warning", parse: SkipGoApiMsgWarning.fromJson));
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "msgs": msgs.map((e) => e.toJson()).toList(),
      "txs": txs.map((e) => e.toJson()).toList(),
      "route": route.toJson(),
      "warning": warning?.toJson()
    };
  }
}

class SkipGoApiIbcOriginAssetParam implements SkipGoApiRequestParam {
  /// Denom of the asset
  final String denom;

  /// Chain-id of the asset
  final String chainId;
  const SkipGoApiIbcOriginAssetParam(
      {required this.chainId, required this.denom});

  @override
  Map<String, dynamic> toJson() {
    return {"denom": denom, "chain_id": chainId};
  }
}

class SkipGoApiIbcOriginAsset implements SkipGoApiRequestParam {
  final SkipGoApiAsset? asset;
  final SkipGoApiError? error;
  const SkipGoApiIbcOriginAsset({required this.asset, required this.error});
  factory SkipGoApiIbcOriginAsset.fromJson(Map<String, dynamic> json) {
    return SkipGoApiIbcOriginAsset(
        asset: json.valueTo<SkipGoApiAsset?, Map<String, dynamic>>(
            key: "asset", parse: SkipGoApiAsset.fromJson),
        error: json.valueTo<SkipGoApiError?, Map<String, dynamic>>(
            key: "error", parse: SkipGoApiError.fromJson));
  }

  @override
  Map<String, dynamic> toJson() {
    return {"asset": asset?.toJson(), "error": error?.toJson()};
  }
}

class SkipGoApiAssetBetweenChains implements SkipGoApiRequestParam {
  final SkipGoApiAsset assetOnSource;
  final SkipGoApiAsset assetOnDest;

  /// Number of transactions required to transfer the asset
  final int txsRequired;

  /// Bridges that are used to transfer the asset
  final List<SkipGoApiBridgeType> bridges;
  const SkipGoApiAssetBetweenChains(
      {required this.assetOnSource,
      required this.assetOnDest,
      required this.txsRequired,
      required this.bridges});
  factory SkipGoApiAssetBetweenChains.fromJson(Map<String, dynamic> json) {
    return SkipGoApiAssetBetweenChains(
      assetOnDest: SkipGoApiAsset.fromJson(json.valueAs("asset_on_source")),
      assetOnSource: SkipGoApiAsset.fromJson(json.valueAs("asset_on_dest")),
      txsRequired: json.valueAs("txs_required"),
      bridges: json
          .valueEnsureAsList<String>("bridges")
          .map(SkipGoApiBridgeType.fromName)
          .toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "asset_on_source": assetOnSource.toJson(),
      "asset_on_dest": assetOnDest.toJson(),
      "txs_required": txsRequired,
      "bridges": bridges.map((e) => e.name).toList()
    };
  }
}

enum SkipGoApiTransactionState {
  /// The initial transaction has been submitted to Skip Go API but not observed on chain yet
  stateSubmitted("STATE_SUBMITTED"),

  /// The initial transaction has been observed on chain, and there are still pending actions
  statePending("STATE_PENDING"),

  /// The route has completed successfully and the user has their tokens on the destination. (indicated by
  stateCompletedSuccess("STATE_COMPLETED_SUCCESS"),

  /// The route errored somewhere and the user has their tokens unlocked in one of their wallets.
  /// Their tokens are either on the source chain, an intermediate chain,
  /// or the destination chain but valueAs the wrong asset.
  /// (Again, transfer_asset_release indicates where the tokens are)
  stateCompletedError("STATE_COMPLETED_ERROR"),

  /// Tracking for the transaction has been abandoned.
  /// This happens if the cross-chain sequence of actions
  /// stalls for more than 10 minutes or if the initial
  /// transaction does not get observed in a block for 5 minutes
  stateAbandoned("STATE_ABANDONED"),

  /// The overall transaction will fail, pending error propagation
  statePendingError("STATE_PENDING_ERROR");

  final String status;
  const SkipGoApiTransactionState(this.status);

  static SkipGoApiTransactionState fromName(String? status) {
    return values.firstWhere(
      (e) => e.status == status,
      orElse: () {
        throw DartOnChainSwapPluginException("Invalid transaction status.",
            details: {"status": status});
      },
    );
  }
}

class SkipGoApiNextBlockingTransfer implements SkipGoApiResponse {
  /// The index of the entry in the transfer_sequence field that the transfer is blocked on.
  final int transferSequenceIndex;
  const SkipGoApiNextBlockingTransfer(this.transferSequenceIndex);
  factory SkipGoApiNextBlockingTransfer.fromJson(Map<String, dynamic> json) {
    return SkipGoApiNextBlockingTransfer(
        json.valueAs("transfer_sequence_index"));
  }

  @override
  Map<String, dynamic> toJson() {
    return {"transfer_sequence_index": transferSequenceIndex};
  }
}

class SkipGoApiTransferAssetRelease implements SkipGoApiResponse {
  /// The chain ID of the chain that the transfer asset is released on.
  final String chainId;

  /// The denom of the asset that is released.
  final String denom;

  /// Indicates whether assets have been released and are accessible. The assets may still be in transit.
  final dynamic released;
  final String? amount;
  const SkipGoApiTransferAssetRelease(
      {required this.chainId,
      required this.denom,
      required this.released,
      required this.amount});
  factory SkipGoApiTransferAssetRelease.fromJson(Map<String, dynamic> json) {
    return SkipGoApiTransferAssetRelease(
        chainId: json.valueAs("chain_id"),
        denom: json.valueAs("denom"),
        released: json.valueAs("released"),
        amount: json.valueAs("amount"));
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "chain_id": chainId,
      "denom": denom,
      "released": released,
      "amount": amount
    };
  }
}

class SkipGoApiChainTransaction implements SkipGoApiResponse {
  /// Chain ID the packet event occurs on
  final String chainId;

  /// Hash of the transaction the packet event occurred in
  final String txHash;

  /// Link to the transaction on block explorer
  final String explorerLink;
  const SkipGoApiChainTransaction(
      {required this.chainId,
      required this.txHash,
      required this.explorerLink});
  factory SkipGoApiChainTransaction.fromJson(Map<String, dynamic> json) {
    return SkipGoApiChainTransaction(
        chainId: json.valueAs("chain_id"),
        txHash: json.valueAs("tx_hash"),
        explorerLink: json.valueAs("explorer_link"));
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "chain_id": chainId,
      "explorer_link": explorerLink,
      "tx_hash": txHash
    };
  }
}

enum SkipGoApiPacketErrorType {
  packetErrorUnknow("PACKET_ERROR_UNKNOWN"),
  packetErrorAcknowledgement("PACKET_ERROR_ACKNOWLEDGEMENT"),
  packetErrorTimeout("PACKET_ERROR_TIMEOUT");

  final String type;
  const SkipGoApiPacketErrorType(this.type);

  static SkipGoApiPacketErrorType fromName(String? type) {
    return values.firstWhere(
      (e) => e.type == type,
      orElse: () {
        throw DartOnChainSwapPluginException("Invalid Packet Error type.",
            details: {"type": type});
      },
    );
  }
}

class SkipGoApiPacketError implements SkipGoApiResponse {
  final SkipGoApiPacketErrorType type;

  /// Error message
  final String message;
  final dynamic details;
  const SkipGoApiPacketError(
      {required this.type, required this.message, required this.details});
  factory SkipGoApiPacketError.fromJson(Map<String, dynamic> json) {
    return SkipGoApiPacketError(
        type: SkipGoApiPacketErrorType.fromName(json.valueAs("type")),
        message: json.valueAs("message"),
        details: json.valueAs("details"));
  }
  @override
  Map<String, dynamic> toJson() {
    return {"type": type.name, "message": message, "details": details};
  }
}

class SkipGoApiPacket implements SkipGoApiResponse {
  final SkipGoApiChainTransaction? acknowledgeTx;
  final SkipGoApiChainTransaction? receiveTx;
  final SkipGoApiChainTransaction? sendTx;
  final SkipGoApiChainTransaction? timeoutTx;
  final SkipGoApiPacketError? error;
  const SkipGoApiPacket(
      {required this.acknowledgeTx,
      required this.receiveTx,
      required this.sendTx,
      required this.timeoutTx,
      required this.error});
  factory SkipGoApiPacket.fromJson(Map<String, dynamic> json) {
    return SkipGoApiPacket(
      acknowledgeTx:
          json.valueTo<SkipGoApiChainTransaction?, Map<String, dynamic>>(
              key: "acknowledge_tx", parse: SkipGoApiChainTransaction.fromJson),
      receiveTx: json.valueTo<SkipGoApiChainTransaction?, Map<String, dynamic>>(
          key: "receive_tx", parse: SkipGoApiChainTransaction.fromJson),
      sendTx: json.valueTo<SkipGoApiChainTransaction?, Map<String, dynamic>>(
          key: "send_tx", parse: SkipGoApiChainTransaction.fromJson),
      timeoutTx: json.valueTo<SkipGoApiChainTransaction?, Map<String, dynamic>>(
          key: "timeout_tx", parse: SkipGoApiChainTransaction.fromJson),
      error: json.valueTo<SkipGoApiPacketError?, Map<String, dynamic>>(
          key: "error", parse: SkipGoApiPacketError.fromJson),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "acknowledge_tx": acknowledgeTx?.toJson(),
      "receive_tx": receiveTx?.toJson(),
      "send_tx": sendTx?.toJson(),
      "timeout_tx": timeoutTx?.toJson(),
      "error": error?.toJson()
    };
  }
}

enum SkipGoApiTransferState {
  /// Transfer state is not known.
  trasnferUnkown("TRANSFER_UNKNOWN"),

  /// The send packet for the transfer has been committed and the transfer is pending.
  transferPending("TRANSFER_PENDING"),

  /// The transfer packet has been received by the destination chain.
  /// It can still fail and revert if it is part of a multi-hop PFM transfer.
  transferReceived("TRANSFER_RECEIVED"),

  /// The transfer has been successfully completed and will not revert.
  transferSuccess("TRANSFER_SUCCESS"),

  /// The transfer has failed.
  transferFailure("TRANSFER_FAILURE");

  final String state;
  const SkipGoApiTransferState(this.state);

  static SkipGoApiTransferState fromName(String? state) {
    return values.firstWhere(
      (e) => e.state == state,
      orElse: () {
        throw DartOnChainSwapPluginException("Invalid transfer state.",
            details: {"state": state});
      },
    );
  }
}

abstract class SkipGoApiBaseTransfer implements SkipGoApiResponse {
  final SkipGoApiTransferType transferType;
  const SkipGoApiBaseTransfer(this.transferType);
  factory SkipGoApiBaseTransfer.fromJson(Map<String, dynamic> json) {
    return json.oneOf<SkipGoApiBaseTransfer, Map<String, dynamic>>(
      keys: SkipGoApiTransferType.values.map((e) => e.key).toList(),
      parse: (key, e) {
        final type = SkipGoApiTransferType.fromName(key);
        return switch (type) {
          SkipGoApiTransferType.ibcTransfer => SkipGoApiIbcTransfer.fromJson(e),
          SkipGoApiTransferType.axelarTransfer =>
            SkipGoApiAxelarTransfer.fromJson(e),
          SkipGoApiTransferType.cctpTransfer =>
            SkipGoApiCCTPTransfer.fromJson(e),
          SkipGoApiTransferType.hyperlaneTransfer =>
            SkipGoApiHyperlaneTransfer.fromJson(e),
          SkipGoApiTransferType.opInitTransfer =>
            SkipGoApiOpInitTransfer.fromJson(e),
          SkipGoApiTransferType.stargateTransfer =>
            SkipGoApiStargateTransfer.fromJson(e),
          SkipGoApiTransferType.goFastTransfer =>
            SkipGoApiGoFastTransfer.fromJson(e)
        };
      },
    );
  }
}

class SkipGoApiIbcTransfer extends SkipGoApiBaseTransfer {
  /// Chain ID of the destination chain
  final String toChainId;

  final SkipGoApiPacket packetTxes;

  /// Chain ID of the source chain
  final String fromChainId;

  /// Transfer state:
  final SkipGoApiTransferState state;
  const SkipGoApiIbcTransfer(
      {required this.toChainId,
      required this.packetTxes,
      required this.fromChainId,
      required this.state})
      : super(SkipGoApiTransferType.ibcTransfer);

  factory SkipGoApiIbcTransfer.fromJson(Map<String, dynamic> json) {
    return SkipGoApiIbcTransfer(
        toChainId: json.valueAs("to_chain_id"),
        packetTxes: SkipGoApiPacket.fromJson(
            json.valueEnsureAsMap<String, dynamic>("packet_txs")),
        fromChainId: json.valueAs("from_chain_id"),
        state: SkipGoApiTransferState.fromName(json.valueAs("state")));
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "to_chain_id": toChainId,
      "packet_txs": packetTxes.toJson(),
      "from_chain_id": fromChainId,
      "state": state.state
    };
  }
}

enum SkipGoApiAxelarTransactionType {
  /// GMP contract call with token transfer type
  contractCallWithTokenTxs("AXELAR_TRANSFER_CONTRACT_CALL_WITH_TOKEN"),

  /// Send token transfer type
  sendTokenTxs("AXELAR_TRANSFER_SEND_TOKEN");

  final String type;
  const SkipGoApiAxelarTransactionType(this.type);

  static SkipGoApiAxelarTransactionType fromName(String? type) {
    return values.firstWhere(
      (e) => e.type == type,
      orElse: () {
        throw DartOnChainSwapPluginException("Invalid axelar transfer type.",
            details: {"state": type});
      },
    );
  }
}

enum SkipGoApiAxelarTransferState {
  /// Unknown error
  trasnferUnkown("AXELAR_TRANSFER_UNKNOWN"),

  /// Axelar transfer is pending confirmation
  transferPendingConfirmation("AXELAR_TRANSFER_PENDING_CONFIRMATION"),

  /// Axelar transfer is pending receipt at destination
  transferPendingReceipt("AXELAR_TRANSFER_PENDING_RECEIPT"),

  /// Axelar transfer succeeded and assets have been received.
  transferSuccess("AXELAR_TRANSFER_SUCCESS"),

  /// Axelar transfer failed
  transferFailure("AXELAR_TRANSFER_FAILUR");

  final String state;
  const SkipGoApiAxelarTransferState(this.state);

  static SkipGoApiAxelarTransferState fromName(String? state) {
    return values.firstWhere(
      (e) => e.state == state,
      orElse: () {
        throw DartOnChainSwapPluginException("Invalid transfer state.",
            details: {"state": state});
      },
    );
  }
}

enum SkipGoApiAxelarContractCallWithTokenErrorType {
  /// Error occurred during the execute transaction
  contractCallWithToken("CONTRACT_CALL_WITH_TOKEN_EXECUTION_ERROR");

  final String error;
  const SkipGoApiAxelarContractCallWithTokenErrorType(this.error);

  static SkipGoApiAxelarContractCallWithTokenErrorType fromName(String? error) {
    return values.firstWhere(
      (e) => e.error == error,
      orElse: () {
        throw DartOnChainSwapPluginException(
            "Invalid axelar call contract error type.",
            details: {"error": error});
      },
    );
  }
}

class SkipGoApiAxelarContractCallWithTokenError implements SkipGoApiResponse {
  /// ContractCallWithToken errors
  final SkipGoApiAxelarContractCallWithTokenErrorType type;

  /// Error message
  final String message;

  const SkipGoApiAxelarContractCallWithTokenError(
      {required this.type, required this.message});

  factory SkipGoApiAxelarContractCallWithTokenError.fromJson(
      Map<String, dynamic> json) {
    return SkipGoApiAxelarContractCallWithTokenError(
        message: json.valueAs("message"),
        type: SkipGoApiAxelarContractCallWithTokenErrorType.fromName(
            json.valueAs("type")));
  }

  @override
  Map<String, dynamic> toJson() {
    return {"message": message, "type": type.error};
  }
}

abstract class SkipGoApiAxelarBaseTransaction extends SkipGoApiResponse {
  final SkipGoApiAxelarTransactionType transactionType;
  const SkipGoApiAxelarBaseTransaction(this.transactionType);
}

class SkipGoApiAxelarContractCallWithTokenTransaction
    extends SkipGoApiAxelarBaseTransaction {
  final SkipGoApiChainTransaction? approveTx;
  final SkipGoApiChainTransaction? confirmTx;
  final SkipGoApiChainTransaction? sendTx;
  final SkipGoApiChainTransaction? executeTx;
  final SkipGoApiChainTransaction? gasPaidTx;
  final SkipGoApiAxelarContractCallWithTokenError? error;
  const SkipGoApiAxelarContractCallWithTokenTransaction(
      {required this.approveTx,
      required this.confirmTx,
      required this.sendTx,
      required this.executeTx,
      required this.error,
      required this.gasPaidTx})
      : super(SkipGoApiAxelarTransactionType.contractCallWithTokenTxs);
  factory SkipGoApiAxelarContractCallWithTokenTransaction.fromJson(
      Map<String, dynamic> json) {
    return SkipGoApiAxelarContractCallWithTokenTransaction(
      approveTx: json.valueTo<SkipGoApiChainTransaction?, Map<String, dynamic>>(
          key: "approve_tx", parse: SkipGoApiChainTransaction.fromJson),
      gasPaidTx: json.valueTo<SkipGoApiChainTransaction?, Map<String, dynamic>>(
          key: "gas_paid_tx", parse: SkipGoApiChainTransaction.fromJson),
      confirmTx: json.valueTo<SkipGoApiChainTransaction?, Map<String, dynamic>>(
          key: "confirm_tx", parse: SkipGoApiChainTransaction.fromJson),
      sendTx: json.valueTo<SkipGoApiChainTransaction?, Map<String, dynamic>>(
          key: "send_tx", parse: SkipGoApiChainTransaction.fromJson),
      executeTx: json.valueTo<SkipGoApiChainTransaction?, Map<String, dynamic>>(
          key: "execute_tx", parse: SkipGoApiChainTransaction.fromJson),
      error: json.valueTo<SkipGoApiAxelarContractCallWithTokenError?,
              Map<String, dynamic>>(
          key: "error",
          parse: SkipGoApiAxelarContractCallWithTokenError.fromJson),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "approve_tx": approveTx?.toJson(),
      "confirm_tx": confirmTx?.toJson(),
      "send_tx": sendTx?.toJson(),
      "execute_tx": executeTx?.toJson(),
      "gas_paid_tx": gasPaidTx?.toJson(),
      "error": error?.toJson()
    };
  }
}

enum SkipGoApiAxelarSendTokenErrorType {
  /// Error occurred during the execute transaction
  sendTokenExcutionError("SEND_TOKEN_EXECUTION_ERROR");

  final String error;
  const SkipGoApiAxelarSendTokenErrorType(this.error);

  static SkipGoApiAxelarSendTokenErrorType fromName(String? error) {
    return values.firstWhere(
      (e) => e.error == error,
      orElse: () {
        throw DartOnChainSwapPluginException(
            "Invalid axelar send token execution error type.",
            details: {"error": error});
      },
    );
  }
}

class SkipGoApiAxelarSendTokenError implements SkipGoApiResponse {
  /// ContractCallWithToken errors
  final SkipGoApiAxelarSendTokenErrorType type;

  /// Error message
  final String message;

  const SkipGoApiAxelarSendTokenError(
      {required this.type, required this.message});

  factory SkipGoApiAxelarSendTokenError.fromJson(Map<String, dynamic> json) {
    return SkipGoApiAxelarSendTokenError(
        message: json.valueAs("message"),
        type: SkipGoApiAxelarSendTokenErrorType.fromName(json.valueAs("type")));
  }

  @override
  Map<String, dynamic> toJson() {
    return {"message": message, "type": type.error};
  }
}

class SkipGoApiAxelarSendTokenTransaction
    extends SkipGoApiAxelarBaseTransaction {
  final SkipGoApiChainTransaction? confirmTx;
  final SkipGoApiChainTransaction? sendTx;
  final SkipGoApiChainTransaction? executeTx;
  final SkipGoApiAxelarSendTokenError? error;
  const SkipGoApiAxelarSendTokenTransaction(
      {required this.confirmTx,
      required this.sendTx,
      required this.executeTx,
      required this.error})
      : super(SkipGoApiAxelarTransactionType.sendTokenTxs);
  factory SkipGoApiAxelarSendTokenTransaction.fromJson(
      Map<String, dynamic> json) {
    return SkipGoApiAxelarSendTokenTransaction(
      confirmTx: json.valueTo<SkipGoApiChainTransaction?, Map<String, dynamic>>(
          key: "confirm_tx", parse: SkipGoApiChainTransaction.fromJson),
      sendTx: json.valueTo<SkipGoApiChainTransaction?, Map<String, dynamic>>(
          key: "send_tx", parse: SkipGoApiChainTransaction.fromJson),
      executeTx: json.valueTo<SkipGoApiChainTransaction?, Map<String, dynamic>>(
          key: "execute_tx", parse: SkipGoApiChainTransaction.fromJson),
      error: json.valueTo<SkipGoApiAxelarSendTokenError?, Map<String, dynamic>>(
          key: "error", parse: SkipGoApiAxelarSendTokenError.fromJson),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "confirm_tx": confirmTx?.toJson(),
      "send_tx": sendTx?.toJson(),
      "execute_tx": executeTx?.toJson(),
      "error": error?.toJson()
    };
  }
}

class SkipGoApiAxelarTransfer extends SkipGoApiBaseTransfer {
  /// Link to the transaction on the Axelar Scan explorer
  final String axelarScanLink;

  /// Chain ID of the destination chain
  final String toChainId;

  /// Chain ID of the source chain
  final String fromChainId;

  /// Axelar transfer state
  final SkipGoApiAxelarTransferState state;

  final SkipGoApiAxelarBaseTransaction txs;

  /// Axelar transfer type
  final SkipGoApiAxelarTransactionType type;

  const SkipGoApiAxelarTransfer(
      {required this.toChainId,
      required this.axelarScanLink,
      required this.fromChainId,
      required this.state,
      required this.txs,
      required this.type})
      : super(SkipGoApiTransferType.axelarTransfer);

  factory SkipGoApiAxelarTransfer.fromJson(Map<String, dynamic> json) {
    final type = SkipGoApiAxelarTransactionType.fromName(json.valueAs("type"));
    return SkipGoApiAxelarTransfer(
      toChainId: json.valueAs("to_chain_id"),
      type: type,
      axelarScanLink: json.valueAs("axelar_scan_link"),
      txs: switch (type) {
        SkipGoApiAxelarTransactionType.contractCallWithTokenTxs =>
          SkipGoApiAxelarContractCallWithTokenTransaction.fromJson(
              json.valueAs("txs")),
        SkipGoApiAxelarTransactionType.sendTokenTxs =>
          SkipGoApiAxelarSendTokenTransaction.fromJson(json.valueAs("txs")),
      },
      fromChainId: json.valueAs("from_chain_id"),
      state: SkipGoApiAxelarTransferState.fromName(json.valueAs("state")),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "to_chain_id": toChainId,
      "txs": txs.toJson(),
      "from_chain_id": fromChainId,
      "state": state.state,
      "axelar_scan_link": axelarScanLink,
      "type": type.type
    };
  }
}

class SkipGoApiCCTPTransaction extends SkipGoApiResponse {
  final SkipGoApiChainTransaction? receiveTx;
  final SkipGoApiChainTransaction? sendTx;
  const SkipGoApiCCTPTransaction(
      {required this.receiveTx, required this.sendTx});
  factory SkipGoApiCCTPTransaction.fromJson(Map<String, dynamic> json) {
    return SkipGoApiCCTPTransaction(
      receiveTx: json.valueTo<SkipGoApiChainTransaction?, Map<String, dynamic>>(
          key: "receive_tx", parse: SkipGoApiChainTransaction.fromJson),
      sendTx: json.valueTo<SkipGoApiChainTransaction?, Map<String, dynamic>>(
          key: "send_tx", parse: SkipGoApiChainTransaction.fromJson),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {"receive_tx": receiveTx?.toJson(), "send_tx": sendTx?.toJson()};
  }
}

enum SkipGoApiCCTPTransferState {
  /// Unknown error
  trasnferUnkown("CCTP_TRANSFER_UNKNOWN"),

  /// The burn transaction on the source chain has executed
  transferSent("CCTP_TRANSFER_SENT"),

  /// CCTP transfer is pending confirmation by the cctp attestation api
  transferPendingConfirmation("CCTP_TRANSFER_PENDING_CONFIRMATION"),

  /// CCTP transfer has been confirmed by the cctp attestation api.
  transferConfirmed("CCTP_TRANSFER_CONFIRMED"),

  /// CCTP transfer has been received at the destination chain
  transferReceived("CCTP_TRANSFER_RECEIVED");

  final String state;
  const SkipGoApiCCTPTransferState(this.state);

  static SkipGoApiCCTPTransferState fromName(String? state) {
    return values.firstWhere(
      (e) => e.state == state,
      orElse: () {
        throw DartOnChainSwapPluginException("Invalid cctp transfer state.",
            details: {"state": state});
      },
    );
  }
}

class SkipGoApiCCTPTransfer extends SkipGoApiBaseTransfer {
  /// Chain ID of the destination chain
  final String toChainId;

  /// Chain ID of the source chain
  final String fromChainId;

  /// Axelar transfer state
  final SkipGoApiCCTPTransferState state;

  final SkipGoApiCCTPTransaction txs;

  const SkipGoApiCCTPTransfer({
    required this.toChainId,
    required this.fromChainId,
    required this.state,
    required this.txs,
  }) : super(SkipGoApiTransferType.cctpTransfer);

  factory SkipGoApiCCTPTransfer.fromJson(Map<String, dynamic> json) {
    return SkipGoApiCCTPTransfer(
      toChainId: json.valueAs("to_chain_id"),
      txs: SkipGoApiCCTPTransaction.fromJson(json.valueAs("txs")),
      fromChainId: json.valueAs("from_chain_id"),
      state: SkipGoApiCCTPTransferState.fromName(json.valueAs("state")),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "to_chain_id": toChainId,
      "txs": txs.toJson(),
      "from_chain_id": fromChainId,
      "state": state.state,
    };
  }
}

class SkipGoApiHyperlaneTransaction extends SkipGoApiResponse {
  final SkipGoApiChainTransaction? receiveTx;
  final SkipGoApiChainTransaction? sendTx;
  const SkipGoApiHyperlaneTransaction(
      {required this.receiveTx, required this.sendTx});
  factory SkipGoApiHyperlaneTransaction.fromJson(Map<String, dynamic> json) {
    return SkipGoApiHyperlaneTransaction(
      receiveTx: json.valueTo<SkipGoApiChainTransaction?, Map<String, dynamic>>(
          key: "receive_tx", parse: SkipGoApiChainTransaction.fromJson),
      sendTx: json.valueTo<SkipGoApiChainTransaction?, Map<String, dynamic>>(
          key: "send_tx", parse: SkipGoApiChainTransaction.fromJson),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {"receive_tx": receiveTx?.toJson(), "send_tx": sendTx?.toJson()};
  }
}

enum SkipGoApiHyperlaneTransferState {
  /// Unknown error
  trasnferUnkown("HYPERLANE_TRANSFER_UNKNOWN"),

  /// The Hyperlane transfer transaction on the source chain has executed
  transferSent("HYPERLANE_TRANSFER_SENT"),

  /// The Hyperlane transfer failed
  transferFailed("HYPERLANE_TRANSFER_FAILED"),

  /// The Hyperlane transfer has been received at the destination chain
  transferReceived("HYPERLANE_TRANSFER_RECEIVED");

  final String state;
  const SkipGoApiHyperlaneTransferState(this.state);

  static SkipGoApiHyperlaneTransferState fromName(String? state) {
    return values.firstWhere(
      (e) => e.state == state,
      orElse: () {
        throw DartOnChainSwapPluginException(
            "Invalid hyperlane transfer state.",
            details: {"state": state});
      },
    );
  }
}

class SkipGoApiHyperlaneTransfer extends SkipGoApiBaseTransfer {
  /// Chain ID of the destination chain
  final String toChainId;

  /// Chain ID of the source chain
  final String fromChainId;

  /// Axelar transfer state
  final SkipGoApiHyperlaneTransferState state;

  final SkipGoApiHyperlaneTransaction txs;

  const SkipGoApiHyperlaneTransfer({
    required this.toChainId,
    required this.fromChainId,
    required this.state,
    required this.txs,
  }) : super(SkipGoApiTransferType.hyperlaneTransfer);

  factory SkipGoApiHyperlaneTransfer.fromJson(Map<String, dynamic> json) {
    return SkipGoApiHyperlaneTransfer(
      toChainId: json.valueAs("to_chain_id"),
      txs: SkipGoApiHyperlaneTransaction.fromJson(json.valueAs("txs")),
      fromChainId: json.valueAs("from_chain_id"),
      state: SkipGoApiHyperlaneTransferState.fromName(json.valueAs("state")),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "to_chain_id": toChainId,
      "txs": txs.toJson(),
      "from_chain_id": fromChainId,
      "state": state.state,
    };
  }
}

class SkipGoApiOpInitTransaction extends SkipGoApiResponse {
  final SkipGoApiChainTransaction? receiveTx;
  final SkipGoApiChainTransaction? sendTx;
  const SkipGoApiOpInitTransaction(
      {required this.receiveTx, required this.sendTx});
  factory SkipGoApiOpInitTransaction.fromJson(Map<String, dynamic> json) {
    return SkipGoApiOpInitTransaction(
      receiveTx: json.valueTo<SkipGoApiChainTransaction?, Map<String, dynamic>>(
          key: "receive_tx", parse: SkipGoApiChainTransaction.fromJson),
      sendTx: json.valueTo<SkipGoApiChainTransaction?, Map<String, dynamic>>(
          key: "send_tx", parse: SkipGoApiChainTransaction.fromJson),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {"receive_tx": receiveTx?.toJson(), "send_tx": sendTx?.toJson()};
  }
}

enum SkipGoApiOpInitTransferState {
  /// Unknown error
  trasnferUnkown("OPINIT_TRANSFER_UNKNOWN"),

  ///  The deposit transaction on the source chain has executed
  transferSent("OPINIT_TRANSFER_SENT"),

  /// OPInit transfer has been received at the destination chain
  transferReceived("OPINIT_TRANSFER_RECEIVED");

  final String state;
  const SkipGoApiOpInitTransferState(this.state);

  static SkipGoApiOpInitTransferState fromName(String? state) {
    return values.firstWhere(
      (e) => e.state == state,
      orElse: () {
        throw DartOnChainSwapPluginException("Invalid opinit transfer state.",
            details: {"state": state});
      },
    );
  }
}

class SkipGoApiOpInitTransfer extends SkipGoApiBaseTransfer {
  /// Chain ID of the destination chain
  final String toChainId;

  /// Chain ID of the source chain
  final String fromChainId;

  /// Axelar transfer state
  final SkipGoApiOpInitTransferState state;

  final SkipGoApiOpInitTransaction txs;

  const SkipGoApiOpInitTransfer({
    required this.toChainId,
    required this.fromChainId,
    required this.state,
    required this.txs,
  }) : super(SkipGoApiTransferType.cctpTransfer);

  factory SkipGoApiOpInitTransfer.fromJson(Map<String, dynamic> json) {
    return SkipGoApiOpInitTransfer(
      toChainId: json.valueAs("to_chain_id"),
      txs: SkipGoApiOpInitTransaction.fromJson(json.valueAs("txs")),
      fromChainId: json.valueAs("from_chain_id"),
      state: SkipGoApiOpInitTransferState.fromName(json.valueAs("state")),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "to_chain_id": toChainId,
      "txs": txs.toJson(),
      "from_chain_id": fromChainId,
      "state": state.state,
    };
  }
}

class SkipGoApiGoFastTransaction implements SkipGoApiResponse {
  final SkipGoApiChainTransaction? orderSubmitedTx;
  final SkipGoApiChainTransaction? orderFilledTx;
  final SkipGoApiChainTransaction? orderRefundedTx;
  final SkipGoApiChainTransaction? orderTimeoutTx;
  const SkipGoApiGoFastTransaction(
      {required this.orderSubmitedTx,
      required this.orderFilledTx,
      required this.orderRefundedTx,
      required this.orderTimeoutTx});
  factory SkipGoApiGoFastTransaction.fromJson(Map<String, dynamic> json) {
    return SkipGoApiGoFastTransaction(
      orderSubmitedTx:
          json.valueTo<SkipGoApiChainTransaction?, Map<String, dynamic>>(
              key: "order_submitted_tx",
              parse: SkipGoApiChainTransaction.fromJson),
      orderFilledTx:
          json.valueTo<SkipGoApiChainTransaction?, Map<String, dynamic>>(
              key: "order_filled_tx",
              parse: SkipGoApiChainTransaction.fromJson),
      orderRefundedTx:
          json.valueTo<SkipGoApiChainTransaction?, Map<String, dynamic>>(
              key: "order_refunded_tx",
              parse: SkipGoApiChainTransaction.fromJson),
      orderTimeoutTx:
          json.valueTo<SkipGoApiChainTransaction?, Map<String, dynamic>>(
              key: "order_timeout_tx",
              parse: SkipGoApiChainTransaction.fromJson),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "order_submitted_tx": orderSubmitedTx?.toJson(),
      "order_filled_tx": orderFilledTx?.toJson(),
      "order_refunded_tx": orderRefundedTx?.toJson(),
      "order_timeout_tx": orderTimeoutTx?.toJson()
    };
  }
}

enum SkipGoApiGoFastTransferState {
  /// Unknown error
  trasnferUnkown("GO_FAST_TRANSFER_UNKNOWN"),

  transferSent("GO_FAST_TRANSFER_SENT"),

  transferPostActionFailed("GO_FAST_POST_ACTION_FAILED"),

  transferTimeout("GO_FAST_TRANSFER_TIMEOUT"),

  transferFilled("GO_FAST_TRANSFER_FILLED"),
  transferRefunded("GO_FAST_TRANSFER_REFUNDED");

  final String state;
  const SkipGoApiGoFastTransferState(this.state);

  static SkipGoApiGoFastTransferState fromName(String? state) {
    return values.firstWhere(
      (e) => e.state == state,
      orElse: () {
        throw DartOnChainSwapPluginException("Invalid go fast transfer state.",
            details: {"state": state});
      },
    );
  }
}

class SkipGoApiGoFastTransfer extends SkipGoApiBaseTransfer {
  /// Chain ID of the destination chain
  final String toChainId;

  /// Chain ID of the source chain
  final String fromChainId;

  /// Axelar transfer state
  final SkipGoApiGoFastTransferState state;

  final SkipGoApiGoFastTransaction txs;

  final String? errorMessage;

  const SkipGoApiGoFastTransfer({
    required this.toChainId,
    required this.fromChainId,
    required this.state,
    required this.txs,
    required this.errorMessage,
  }) : super(SkipGoApiTransferType.goFastTransfer);

  factory SkipGoApiGoFastTransfer.fromJson(Map<String, dynamic> json) {
    return SkipGoApiGoFastTransfer(
        toChainId: json.valueAs("to_chain_id"),
        txs: SkipGoApiGoFastTransaction.fromJson(json.valueAs("txs")),
        fromChainId: json.valueAs("from_chain_id"),
        state: SkipGoApiGoFastTransferState.fromName(json.valueAs("state")),
        errorMessage: json.valueAs("error_message"));
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "to_chain_id": toChainId,
      "txs": txs.toJson(),
      "from_chain_id": fromChainId,
      "state": state.state,
      "error_message": errorMessage
    };
  }
}

class SkipGoApiStargateTransaction implements SkipGoApiResponse {
  final SkipGoApiChainTransaction? sendTx;
  final SkipGoApiChainTransaction? receivedTx;
  final SkipGoApiChainTransaction? errorTx;
  const SkipGoApiStargateTransaction(
      {required this.sendTx, required this.receivedTx, required this.errorTx});
  factory SkipGoApiStargateTransaction.fromJson(Map<String, dynamic> json) {
    return SkipGoApiStargateTransaction(
      sendTx: json.valueTo<SkipGoApiChainTransaction?, Map<String, dynamic>>(
          key: "send_tx", parse: SkipGoApiChainTransaction.fromJson),
      receivedTx:
          json.valueTo<SkipGoApiChainTransaction?, Map<String, dynamic>>(
              key: "receive_tx", parse: SkipGoApiChainTransaction.fromJson),
      errorTx: json.valueTo<SkipGoApiChainTransaction?, Map<String, dynamic>>(
          key: "error_tx", parse: SkipGoApiChainTransaction.fromJson),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "send_tx": sendTx?.toJson(),
      "receive_tx": receivedTx?.toJson(),
      "error_tx": errorTx?.toJson()
    };
  }
}

enum SkipGoApiStargateTransferState {
  /// Unknown error
  trasnferUnkown("STARGATE_TRANSFER_UNKNOWN"),

  transferSent("STARGATE_TRANSFER_SENT"),

  transferReceived("STARGATE_TRANSFER_RECEIVED"),

  transferTimeout("STARGATE_TRANSFER_FAILED");

  final String state;
  const SkipGoApiStargateTransferState(this.state);

  static SkipGoApiStargateTransferState fromName(String? state) {
    return values.firstWhere(
      (e) => e.state == state,
      orElse: () {
        throw DartOnChainSwapPluginException("Invalid stargate transfer state.",
            details: {"state": state});
      },
    );
  }
}

class SkipGoApiStargateTransfer extends SkipGoApiBaseTransfer {
  /// Chain ID of the destination chain
  final String toChainId;

  /// Chain ID of the source chain
  final String fromChainId;

  /// Axelar transfer state
  final SkipGoApiStargateTransferState state;

  final SkipGoApiStargateTransaction txs;

  const SkipGoApiStargateTransfer(
      {required this.toChainId,
      required this.fromChainId,
      required this.state,
      required this.txs})
      : super(SkipGoApiTransferType.stargateTransfer);

  factory SkipGoApiStargateTransfer.fromJson(Map<String, dynamic> json) {
    return SkipGoApiStargateTransfer(
        toChainId: json.valueAs("to_chain_id"),
        txs: SkipGoApiStargateTransaction.fromJson(json.valueAs("txs")),
        fromChainId: json.valueAs("from_chain_id"),
        state: SkipGoApiStargateTransferState.fromName(json.valueAs("state")));
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "to_chain_id": toChainId,
      "txs": txs.toJson(),
      "from_chain_id": fromChainId,
      "state": state.state
    };
  }
}

enum SkipGoApiTransferType {
  ibcTransfer("ibc_transfer"),
  axelarTransfer("axelar_transfer"),
  cctpTransfer("cctp_transfer"),
  hyperlaneTransfer("hyperlane_transfer"),
  opInitTransfer("op_init_transfer"),
  goFastTransfer("go_fast_transfer"),
  stargateTransfer("stargate_transfer");

  const SkipGoApiTransferType(this.key);

  final String key;
  static SkipGoApiTransferType fromName(String? name) {
    return values.firstWhere(
      (e) => e.key == name,
      orElse: () {
        throw DartOnChainSwapPluginException("Invalid transfer type.",
            details: {"type": name});
      },
    );
  }
}

enum SkipGoApiTransferErrorType {
  errorUnknown("STATUS_ERROR_UNKNOWN"),
  errorTransactionExcution("STATUS_ERROR_TRANSACTION_EXECUTION"),
  errorIndexing("STATUS_ERROR_INDEXING"),
  errorTransfer("STATUS_ERROR_TRANSFER");

  final String error;
  const SkipGoApiTransferErrorType(this.error);
  static SkipGoApiTransferErrorType fromName(String? error) {
    return values.firstWhere(
      (e) => e.error == error,
      orElse: () {
        throw DartOnChainSwapPluginException("Invalid transfer error type.",
            details: {"error": error});
      },
    );
  }
}

class SkipGoApiTransferError extends SkipGoApiResponse {
  final String message;
  final dynamic details;
  final SkipGoApiTransferErrorType type;
  const SkipGoApiTransferError(
      {required this.type, required this.message, required this.details});
  factory SkipGoApiTransferError.fromJson(Map<String, dynamic> json) {
    return SkipGoApiTransferError(
        type: SkipGoApiTransferErrorType.fromName(json.valueAs("type")),
        message: json.valueAs("message"),
        details: json.valueAs("details"));
  }

  @override
  Map<String, dynamic> toJson() {
    return {"type": type.name, "message": message, "details": details};
  }
}

class SkipGoApiTransfer extends SkipGoApiResponse {
  final SkipGoApiTransferError? error;
  final SkipGoApiNextBlockingTransfer? nextBlockingTransfer;
  final SkipGoApiTransactionState state;
  final SkipGoApiTransferAssetRelease? transferAssetRelease;
  final List<SkipGoApiBaseTransfer> transferSequence;
  const SkipGoApiTransfer(
      {required this.error,
      required this.nextBlockingTransfer,
      required this.state,
      required this.transferAssetRelease,
      required this.transferSequence});
  factory SkipGoApiTransfer.fromJson(Map<String, dynamic> json) {
    return SkipGoApiTransfer(
        error: json.valueTo<SkipGoApiTransferError?, Map<String, dynamic>>(
            key: "error", parse: SkipGoApiTransferError.fromJson),
        nextBlockingTransfer:
            json.valueTo<SkipGoApiNextBlockingTransfer?, Map<String, dynamic>>(
                key: "next_blocking_transfer",
                parse: SkipGoApiNextBlockingTransfer.fromJson),
        state: SkipGoApiTransactionState.fromName(json.valueAs("state")),
        transferAssetRelease:
            json.valueTo<SkipGoApiTransferAssetRelease?, Map<String, dynamic>>(
                key: "transfer_asset_release",
                parse: SkipGoApiTransferAssetRelease.fromJson),
        transferSequence: json
            .valueEnsureAsList<Map<String, dynamic>>("transfer_sequence")
            .map((e) => SkipGoApiBaseTransfer.fromJson(e))
            .toList());
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "error": error?.toJson(),
      "next_blocking_transfer": nextBlockingTransfer?.toJson(),
      "state": state.name,
      "transfer_asset_release": transferAssetRelease?.toJson(),
      "transfer_sequence": transferSequence
          .map((e) => {e.transferType.name: e.toJson()})
          .toList()
    };
  }
}
