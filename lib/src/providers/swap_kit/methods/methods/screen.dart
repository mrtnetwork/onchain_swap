import 'package:blockchain_utils/utils/utils.dart';
import 'package:on_chain_swap/src/providers/swap_kit/core/core.dart';
import 'package:on_chain_swap/src/providers/swap_kit/models/types.dart';

class SwapKitRequestScreen
    extends SwapKitPostRequest<bool, Map<String, dynamic>> {
  final List<SwipKitScreenParams> addresses;
  const SwapKitRequestScreen(this.addresses);
  @override
  String get method => SwapKitMethods.screen.url;

  @override
  bool onResonse(Map<String, dynamic> result) {
    return result.valueAs("confirm");
  }

  @override
  Map<String, dynamic> body() {
    if (addresses.length == 1) {
      return {
        "addresses": addresses.first.address,
        "chains": addresses.first.chain
      };
    }
    return {
      "addresses": addresses.map((e) => e.address).toList(),
      "chains": addresses.map((e) => e.chain).toList(),
    };
  }
}
