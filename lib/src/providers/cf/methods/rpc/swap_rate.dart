import 'package:on_chain_swap/src/providers/cf/core/core.dart';
import 'package:on_chain_swap/src/providers/cf/models/models/rpc.dart';

class CfRPCRequestSwapRate
    extends CfRPCRequestParam<SwapRateResponse, Map<String, dynamic>> {
  final UncheckedAssetAndChain fromAsset;
  final UncheckedAssetAndChain toAsset;
  final String amount;
  const CfRPCRequestSwapRate(
      {required this.fromAsset, required this.toAsset, required this.amount});

  @override
  List get params => [fromAsset.toJson(), toAsset.toJson(), amount];

  @override
  String get method => "cf_swap_rate";

  @override
  SwapRateResponse onResonse(Map<String, dynamic> result) {
    return SwapRateResponse.fromJson(result);
  }
}
