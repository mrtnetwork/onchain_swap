import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:on_chain_swap/on_chain_swap.dart';

class DartOnChainSwapPluginException extends IException {
  const DartOnChainSwapPluginException(super.message, {super.details});
  factory DartOnChainSwapPluginException.deserialize(
      {List<int>? bytes, CborObject? obj}) {
    final values = CborTagSerializable.decodeTaggedValue(
      identifier: OnChainSwapSerializationIdentifier.swapPluginError,
      cborBytes: bytes,
      cborObject: obj,
    );
    return DartOnChainSwapPluginException(
      values.rawValueAt(0),
      details: values.maybeRawMapAt<String, String?>(1),
    );
  }
  @override
  OnChainSwapSerializationIdentifier get serializationIdentifier =>
      OnChainSwapSerializationIdentifier.swapPluginError;

  @override
  BlockchainNetwork? get relatedNetwork => null;
}
