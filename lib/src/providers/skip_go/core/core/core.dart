import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:blockchain_utils/helper/extensions/extensions.dart';
import 'package:blockchain_utils/service/service.dart';
import 'package:blockchain_utils/utils/utils.dart';
import 'package:on_chain_swap/src/providers/skip_go/constatns/constants.dart';
import 'package:on_chain_swap/src/providers/types/types.dart';
import 'package:on_chain_swap/src/serialization/serialization.dart';

abstract class SkipGoApiRequest<RESULT, RESPONSE>
    extends BaseServiceRequest<RESULT, RESPONSE, SkipGoApiRequestDetails> {
  const SkipGoApiRequest();
  abstract final String method;
  @override
  RequestMethod get requestMethod;
}

abstract class SkipGoApiPostRequest<RESULT, RESPONSE>
    extends SkipGoApiRequest<RESULT, RESPONSE> {
  const SkipGoApiPostRequest();
  @override
  RequestMethod get requestMethod => RequestMethod.post;
  Map<String, dynamic> body();

  @override
  SkipGoApiRequestDetails buildRequest(int requestID) {
    return SkipGoApiRequestDetails(
        requestID: requestID,
        path: method,
        headers: ServiceConst.defaultPostHeaders,
        responseEncoding: ServiceReponseEncoding.map,
        requestMethod: requestMethod,
        bodyString: StringUtils.fromJson(body()));
  }
}

abstract class SkipGoApiGetRequest<RESULT, RESPONSE>
    extends SkipGoApiRequest<RESULT, RESPONSE> {
  const SkipGoApiGetRequest();
  @override
  RequestMethod get requestMethod => RequestMethod.get;
  Map<String, dynamic> get queryParameters => {};
  Map<String, String>? get headers => null;

  @override
  SkipGoApiRequestDetails buildRequest(int requestID) {
    final Map<String, dynamic> query = {};
    for (final i in queryParameters.entries) {
      final key = i.key;
      final value = i.value;
      if (value == null) continue;
      if (value is List) {
        if (value.isEmpty) continue;
        query[key] = value.map((e) => e.toString()).toList();
      } else {
        query[key] = value.toString();
      }
    }
    final uri = Uri(path: method, queryParameters: query);
    return SkipGoApiRequestDetails(
        requestID: requestID,
        path: uri.normalizePath().toString(),
        headers: headers ?? const {},
        responseEncoding: ServiceReponseEncoding.map,
        requestMethod: requestMethod);
  }
}

class SkipGoApiRequestDetails extends OnChainSwapRequestDetails {
  const SkipGoApiRequestDetails({
    required super.requestID,
    required super.requestMethod,
    super.path,
    required super.responseEncoding,
    super.successStatusCodes = SkipGoApiConstants.successStatusCodes,
    super.errorStatusCodes = SkipGoApiConstants.errorStatusCodes,
    required super.headers,
    super.bodyBytes,
    super.bodyString,
  }) : super(api: OnChainSwapProviderApi.skipGo);
  factory SkipGoApiRequestDetails.deserialize({
    List<int>? bytes,
    CborObject? obj,
  }) {
    final values = CborTagSerializable.decodeTaggedValue(
      identifier: OnChainSwapSerializationIdentifier.provider,
      cborBytes: bytes,
      cborObject: obj,
    );
    return SkipGoApiRequestDetails(
        headers: values
            .mapAt<CborStringValue, CborStringValue>(1)
            .map((k, v) => MapEntry(k.value, v.value)),
        errorStatusCodes:
            values.listAt<CborIntValue>(2).map((e) => e.value).toList().emptyAsNull,
        successStatusCodes:
            values.listAt<CborIntValue>(3).map((e) => e.value).toList().emptyAsNull,
        path: values.rawValueAt(4),
        requestMethod: RequestMethod.fromValue(values.rawValueAt(5)),
        responseEncoding: ServiceReponseEncoding.fromValue(values.rawValueAt(6)),
        bodyBytes: values.rawValueAt(7),
        bodyString: values.rawValueAt(8),
        requestID: values.rawValueAt(9));
  }
  SkipGoApiRequestDetails copyWith(
      {int? requestID,
      Map<String, String>? headers,
      List<int>? bodyBytes,
      String? bodyString,
      ServiceReponseEncoding? responseEncoding,
      RequestMethod? requestMethod,
      String? path,
      List<int>? errorStatusCodes,
      List<int>? successStatusCodes}) {
    return SkipGoApiRequestDetails(
        requestID: requestID ?? this.requestID,
        headers: headers ?? this.headers,
        responseEncoding: responseEncoding ?? this.responseEncoding,
        bodyString: bodyString ?? this.bodyString,
        bodyBytes: bodyBytes ?? this.bodyBytes,
        requestMethod: requestMethod ?? this.requestMethod,
        path: path ?? this.path,
        errorStatusCodes: errorStatusCodes ?? this.errorStatusCodes,
        successStatusCodes: successStatusCodes ?? this.successStatusCodes);
  }

  @override
  Uri encodeUrl(String uri) {
    if (uri.endsWith('/')) {
      uri = uri.substring(0, uri.length - 1);
    }
    final finalUrl = '$uri${path ?? ''}';
    return Uri.parse(finalUrl);
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'path': path,
      'body': bodyString ?? BytesUtils.tryToHexString(bodyBytes),
      'type': requestMethod.name,
    };
  }

  @override
  List<CborObject?> get serializationItems => [
        api.value.toCbor(),
        CborMapValue.definite(
          headers.map((k, v) => MapEntry(CborStringValue(k), CborStringValue(v))),
        ),
        CborTagSerializable.listFromDynamic(
          errorStatusCodes?.map((e) => CborIntValue(e)).toList() ?? [],
        ),
        CborTagSerializable.listFromDynamic(
          successStatusCodes?.map((e) => CborIntValue(e)).toList() ?? [],
        ),
        path?.toCbor(),
        requestMethod.value.toCbor(),
        responseEncoding.value.toCbor(),
        bodyBytes?.toCborBytes(),
        bodyString?.toCbor(),
        requestID.toCbor(),
      ];
}
