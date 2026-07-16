import 'package:blockchain_utils/utils/utils.dart';
import 'package:on_chain_swap/src/providers/skip_go/core/core/core.dart';
import 'package:on_chain_swap/src/providers/skip_go/core/core/methods.dart';

/// Requests tracking of a transaction that has already landed on-chain but was
/// not broadcast through the Skip Go API. The status of a tracked transaction
/// and subsequent IBC or Axelar transfers if routing assets cross
/// chain can be queried through the /status endpoint.
class SkipGoApiRequestTrack
    extends SkipGoApiPostRequest<String, Map<String, dynamic>> {
  /// Hex encoded hash of the transaction to track
  final String txHash;

  /// Chain ID of the transaction
  final String chainId;
  SkipGoApiRequestTrack({required this.txHash, required this.chainId});
  @override
  String get method => SkipGoApiMethods.track.url;

  @override
  Map<String, dynamic> body() {
    return {"tx_hash": txHash, "chain_id": chainId};
  }

  @override
  String onResonse(Map<String, dynamic> result) {
    return result.valueAs("tx_hash");
  }
}
