import 'package:on_chain_swap/src/providers/cf/core/core.dart';
import 'package:on_chain_swap/src/providers/cf/models/models/rpc.dart';

class CfRPCRequestPoolDepth
    extends CfRPCRequestParam<PoolDepth?, Map<String, dynamic>?> {
  final AssetAndChain fromAsset;
  final AssetAndChain toAsset;
  final TickRangeParams tickRange;
  const CfRPCRequestPoolDepth(
      {required this.fromAsset,
      required this.toAsset,
      required this.tickRange});

  @override
  List get params => [fromAsset.toJson(), toAsset.toJson(), tickRange.toJson()];

  @override
  String get method => "cf_pool_depth";

  @override
  PoolDepth? onResonse(Map<String, dynamic>? result) {
    if (result == null) return null;
    return PoolDepth.fromJson(result);
  }
}
