import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:onchain_swap_example/api/services/socket/core/socket_provider.dart';
import 'package:onchain_swap_example/app/http/models/auth.dart';
import 'package:onchain_swap_example/app/serialization/serialization.dart';

class ServiceInfo with CborSerializable {
  final String url;
  final ProviderAuthenticated? authenticated;
  final ServiceProtocol protocol;
  const ServiceInfo(
      {required this.url, required this.protocol, this.authenticated});
  factory ServiceInfo.deserialize(
      {List<int>? bytes, CborTagValue? obj, String? cborHex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: obj,
        hex: cborHex,
        tags: CborConst.serviceInfo);
    return ServiceInfo(
        url: values.elementAs(0),
        protocol: ServiceProtocol.fromID(values.elementAs(1)),
        authenticated: values.elemetMybeAs<ProviderAuthenticated, CborTagValue>(
            2, (e) => ProviderAuthenticated.deserialize(obj: e)));
  }
  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.definite(<CborObject>[
          CborStringValue(url),
          CborIntValue(protocol.id),
          authenticated?.toCbor() ?? CborNullValue()
        ]),
        CborConst.serviceInfo);
  }
}
