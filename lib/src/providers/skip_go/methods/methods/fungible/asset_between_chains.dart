import 'package:blockchain_utils/utils/utils.dart';
import 'package:on_chain_swap/src/providers/skip_go/core/core/core.dart';
import 'package:on_chain_swap/src/providers/skip_go/core/core/methods.dart';
import 'package:on_chain_swap/src/providers/skip_go/models/types/types.dart';

/// Given 2 chain IDs, returns a list of equivalent assets that can be transferred
class SkipGoApiRequestAssetsBetweenChains extends SkipGoApiPostRequest<
    List<SkipGoApiAssetBetweenChains>, Map<String, dynamic>> {
  /// Chain-id of the source chain
  final String sourceChainId;

  /// Chain-id of the destination chain
  final String destChainId;

  /// Whether to include assets without metadata (symbol, name, logo_uri, etc.)
  final bool? includeNoMetadataAssets;

  /// Whether to include CW20 tokens
  final bool? includeCW20Assets;

  /// Whether to include EVM tokens
  final bool? includeEVMAssets;

  /// Whether to include recommendations requiring multiple transactions to reach the destination
  final bool? allowMultiTx;

  SkipGoApiRequestAssetsBetweenChains(
      {required this.sourceChainId,
      required this.destChainId,
      this.includeNoMetadataAssets,
      this.includeCW20Assets,
      this.includeEVMAssets,
      this.allowMultiTx});
  @override
  String get method => SkipGoApiMethods.assetsBetweenChains.url;

  @override
  Map<String, dynamic> body() {
    return {
      "source_chain_id": sourceChainId,
      "dest_chain_id": destChainId,
      "include_no_metadata_assets": includeNoMetadataAssets,
      "include_cw20_assets": includeCW20Assets,
      "include_evm_assets": includeEVMAssets,
      "allow_multi_tx": allowMultiTx
    };
  }

  @override
  List<SkipGoApiAssetBetweenChains> onResonse(Map<String, dynamic> result) {
    return result
        .valueEnsureAsList<Map<String, dynamic>>("assets_between_chains")
        .map(SkipGoApiAssetBetweenChains.fromJson)
        .toList();
  }
}
