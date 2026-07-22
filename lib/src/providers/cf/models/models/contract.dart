import 'package:blockchain_utils/utils/utils.dart';

class CfContractNetworkInfo {
  final List<CfContractNetworkAssetInfo> assets;
  final num cfBrokerCommissionBps;

  const CfContractNetworkInfo({
    required this.assets,
    required this.cfBrokerCommissionBps,
  });

  factory CfContractNetworkInfo.fromJson(Map<String, dynamic> json) {
    return CfContractNetworkInfo(
      assets: (json.valueEnsureAsList<Map<String, dynamic>>("assets"))
          .map((e) => CfContractNetworkAssetInfo.fromJson(e))
          .toList(),
      cfBrokerCommissionBps: json.valueAsNum("cfBrokerCommissionBps"),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'assets': assets.map((e) => e.toJson()).toList(),
      'cfBrokerCommissionBps': cfBrokerCommissionBps,
    };
  }
}

class CfContractNetworkAssetInfo {
  final String asset;
  final bool vaultSwapDepositsEnabled;
  final bool depositChannelDepositsEnabled;
  final bool depositChannelCreationEnabled;
  final bool egressEnabled;
  final bool boostDepositsEnabled;
  final bool livePriceProtectionEnabled;

  const CfContractNetworkAssetInfo({
    required this.asset,
    required this.vaultSwapDepositsEnabled,
    required this.depositChannelDepositsEnabled,
    required this.depositChannelCreationEnabled,
    required this.egressEnabled,
    required this.boostDepositsEnabled,
    required this.livePriceProtectionEnabled,
  });

  factory CfContractNetworkAssetInfo.fromJson(Map<String, dynamic> json) {
    return CfContractNetworkAssetInfo(
      asset: json.valueAs("asset"),
      vaultSwapDepositsEnabled: json.valueAs("vaultSwapDepositsEnabled"),
      depositChannelDepositsEnabled: json.valueAs("depositChannelDepositsEnabled"),
      depositChannelCreationEnabled: json.valueAs("depositChannelCreationEnabled"),
      egressEnabled: json.valueAs("egressEnabled"),
      boostDepositsEnabled: json.valueAs("boostDepositsEnabled"),
      livePriceProtectionEnabled: json.valueAs("livePriceProtectionEnabled"),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'asset': asset,
      'vaultSwapDepositsEnabled': vaultSwapDepositsEnabled,
      'depositChannelDepositsEnabled': depositChannelDepositsEnabled,
      'depositChannelCreationEnabled': depositChannelCreationEnabled,
      'egressEnabled': egressEnabled,
      'boostDepositsEnabled': boostDepositsEnabled,
      'livePriceProtectionEnabled': livePriceProtectionEnabled,
    };
  }
}
