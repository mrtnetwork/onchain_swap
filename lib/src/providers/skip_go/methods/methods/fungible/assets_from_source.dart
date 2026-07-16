import 'package:blockchain_utils/utils/json/extension/json.dart';
import 'package:on_chain_swap/src/providers/skip_go/core/core/core.dart';
import 'package:on_chain_swap/src/providers/skip_go/core/core/methods.dart';
import 'package:on_chain_swap/src/providers/skip_go/models/types/types.dart';

/// Get assets that can be reached from a source via transfers
/// under different conditions (e.g. single vs multiple txs)
class SkipGoApiRequestAssetsFromSource
    extends SkipGoApiPostRequest<SkipGoApiAssets, Map<String, dynamic>> {
  /// Denom of the source asset
  final String sourceAssetDenom;

  /// Chain-id of the source asset
  final String sourceAssetChainId;

  /// Whether to include recommendations requiring multiple transactions to reach the destination
  final bool? allowMultiTx;

  /// Whether to include CW20 tokens
  final bool? includeCw20Assets;
  SkipGoApiRequestAssetsFromSource({
    required this.sourceAssetDenom,
    required this.sourceAssetChainId,
    this.allowMultiTx,
    this.includeCw20Assets,
  });
  @override
  String get method => SkipGoApiMethods.assetsFromSource.url;

  @override
  Map<String, dynamic> body() {
    return {
      "source_asset_denom": sourceAssetDenom,
      "source_asset_chain_id": sourceAssetChainId,
      "allow_multi_tx": allowMultiTx,
      "include_cw20_assets": includeCw20Assets,
    };
  }

  @override
  SkipGoApiAssets onResonse(Map<String, dynamic> result) {
    return SkipGoApiAssets.fromJson(
        result.valueEnsureAsMap<String, dynamic>("dest_assets"));
  }
}
