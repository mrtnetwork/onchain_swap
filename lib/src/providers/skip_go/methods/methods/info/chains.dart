import 'package:blockchain_utils/utils/utils.dart';
import 'package:on_chain_swap/src/providers/skip_go/core/core/core.dart';
import 'package:on_chain_swap/src/providers/skip_go/core/core/methods.dart';
import 'package:on_chain_swap/src/providers/skip_go/models/types/types.dart';

/// Get all supported chains along with additional data useful for
/// building applications + frontends that interface with them
/// (e.g. logo URI, IBC capabilities, fee assets, bech32 prefix, etc…)
class SkipGoApiRequestChains extends SkipGoApiGetRequest<
    List<SkipGoApiChainResponse>, Map<String, dynamic>> {
  /// Whether to include EVM chains in the response
  final bool? includeEVM;

  /// Whether to include SVM chains in the response
  final bool? includeSVM;

  /// Whether to display only testnets in the response
  final bool? onlyTestnets;

  /// Chain IDs to limit the response to, defaults to all chains if not provided
  final List<String>? chainIds;
  SkipGoApiRequestChains(
      {this.includeEVM, this.includeSVM, this.onlyTestnets, this.chainIds});
  @override
  String get method => SkipGoApiMethods.chains.url;

  @override
  Map<String, dynamic> get queryParameters => {
        "chain_ids": chainIds,
        "include_evm": includeEVM,
        "include_svm": includeSVM,
        "only_testnets": onlyTestnets
      };
  @override
  List<SkipGoApiChainResponse> onResonse(Map<String, dynamic> result) {
    return result
        .valueEnsureAsList<Map<String, dynamic>>("chains")
        .map((e) => SkipGoApiChainResponse.fromJson(e))
        .toList();
  }
}
