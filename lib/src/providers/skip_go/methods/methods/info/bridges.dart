import 'package:blockchain_utils/utils/utils.dart';
import 'package:on_chain_swap/src/providers/skip_go/core/core/core.dart';
import 'package:on_chain_swap/src/providers/skip_go/core/core/methods.dart';
import 'package:on_chain_swap/src/providers/skip_go/models/types/types.dart';

/// Get all supported bridges
class SkipGoApiRequestBridges
    extends SkipGoApiGetRequest<List<SkipGoApiBridge>, Map<String, dynamic>> {
  @override
  String get method => SkipGoApiMethods.bridges.url;

  @override
  List<SkipGoApiBridge> onResonse(Map<String, dynamic> result) {
    return result
        .valueEnsureAsList<Map<String, dynamic>>("bridges")
        .map((e) => SkipGoApiBridge.fromJson(e))
        .toList();
  }
}
