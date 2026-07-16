import 'package:blockchain_utils/utils/json/extension/json.dart';
import 'package:on_chain_swap/src/providers/skip_go/core/core/core.dart';
import 'package:on_chain_swap/src/providers/skip_go/core/core/methods.dart';
import 'package:on_chain_swap/src/providers/skip_go/models/types/types.dart';

/// Get supported assets. Optionally limit to
/// assets on a given chain and/or native assets.
class SkipGoApiRequestAssets
    extends SkipGoApiGetRequest<SkipGoApiAssets, Map<String, dynamic>> {
  /// Chain IDs to limit the response to, defaults to all chains if not provided
  final List<String>? chainIds;

  /// Whether to restrict assets to those native to their chain
  final bool? nativeOnly;

  /// Whether to include assets without metadata (symbol, name, logo_uri, etc.)
  final bool? includeNoMetadataAssets;

  /// Whether to include CW20 tokens
  final bool? includeCw20Assets;

  /// Whether to include EVM tokens
  final bool? includeEvmAssets;

  /// Whether to include SVM tokens
  final bool? includeSvmAssets;

  /// Whether to display only assets from testnets in the response
  final bool? onlyTestnets;
  SkipGoApiRequestAssets({
    this.onlyTestnets,
    this.chainIds,
    this.nativeOnly,
    this.includeNoMetadataAssets,
    this.includeCw20Assets,
    this.includeEvmAssets,
    this.includeSvmAssets,
  });
  @override
  String get method => SkipGoApiMethods.assets.url;

  @override
  Map<String, dynamic> get queryParameters => {
        "only_testnets": onlyTestnets,
        "chain_ids": chainIds,
        "native_only": nativeOnly,
        "include_no_metadata_assets": includeNoMetadataAssets,
        "include_cw20_assets": includeCw20Assets,
        "include_evm_assets": includeEvmAssets,
        "include_svm_assets": includeSvmAssets,
      };
  @override
  SkipGoApiAssets onResonse(Map<String, dynamic> result) {
    return SkipGoApiAssets.fromJson(
        result.valueEnsureAsMap<String, dynamic>("chain_to_assets_map"));
  }
}
