import 'package:blockchain_utils/cbor/serialization/cbor/tag.dart';

/// 13000
enum OnChainSwapSerializationIdentifier implements SerializationIdentifier {
  provider(13000),
  swapPluginError(13001);

  @override
  final int id;
  const OnChainSwapSerializationIdentifier(this.id);

  @override
  bool isValid(int? tag) {
    return id == tag;
  }
}
