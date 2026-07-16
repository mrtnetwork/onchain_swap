import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:blockchain_utils/exception/exceptions.dart';
import 'package:blockchain_utils/service/models/params.dart';
import 'package:on_chain_swap/src/providers/cf/provider.dart';
import 'package:on_chain_swap/src/providers/skip_go/provider.dart';
import 'package:on_chain_swap/src/providers/swap_kit/provider.dart';
import 'package:on_chain_swap/src/serialization/serialization.dart';

enum OnChainSwapProviderApi {
  chainFlip(0),
  skipGo(1),
  swapKit(2);

  final int value;
  const OnChainSwapProviderApi(this.value);
  static OnChainSwapProviderApi fromValue(int? value) {
    return values.firstWhere(
      (e) => e.value == value,
      orElse: () => throw ItemNotFoundException(name: 'OnChainSwapProviderApi'),
    );
  }
}

abstract class OnChainSwapRequestDetails extends BaseServiceRequestParams {
  final OnChainSwapProviderApi api;
  const OnChainSwapRequestDetails({
    required super.headers,
    required super.requestMethod,
    required super.requestID,
    required super.responseEncoding,
    super.bodyBytes,
    super.bodyString,
    required this.api,
    super.errorStatusCodes,
    super.path,
    super.successStatusCodes,
  }) : super();

  factory OnChainSwapRequestDetails.deserialize({
    List<int>? bytes,
    CborObject? obj,
  }) {
    final CborTagValue tag = CborTagSerializable.decode(
      cborBytes: bytes,
      cborObject: obj,
    );
    final decode = CborTagSerializable.decodeTaggedValue(
      cborObject: tag,
      identifier: OnChainSwapSerializationIdentifier.provider,
    );
    final api = OnChainSwapProviderApi.fromValue(decode.rawValueAt(0));
    return switch (api) {
      OnChainSwapProviderApi.chainFlip =>
        CfRequestDetails.deserialize(obj: tag),
      OnChainSwapProviderApi.skipGo =>
        SkipGoApiRequestDetails.deserialize(obj: tag),
      OnChainSwapProviderApi.swapKit =>
        SwapKitRequestDetails.deserialize(obj: tag),
    };
  }

  @override
  SerializationIdentifier get serializationIdentifier =>
      OnChainSwapSerializationIdentifier.provider;

  @override
  List<int>? encodeBody({ServiceProtocol protocol = ServiceProtocol.http}) {
    assert(!protocol.isGrpc, "Unsupported protocol.");
    return super.encodeBody(protocol: protocol);
  }
}
