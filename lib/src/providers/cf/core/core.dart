import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:on_chain_swap/src/exception/exception.dart';
import 'package:on_chain_swap/src/providers/cf/constants/constants.dart';
import 'package:on_chain_swap/src/providers/cf/utils/utils.dart';
import 'package:on_chain_swap/src/providers/types/types.dart';
import 'package:on_chain_swap/src/serialization/serialization.dart';

enum CfRequestType {
  backend(0),
  rpc(1),
  batchTrcp(2);

  final int value;
  const CfRequestType(this.value);
  static CfRequestType fromValue(int? value) {
    return values.firstWhere(
      (e) => e.value == value,
      orElse: () => throw ItemNotFoundException(name: 'CfRequestType'),
    );
  }
}

abstract class CfRequestParam<RESULT, RESPONSE>
    extends BaseServiceRequest<RESULT, RESPONSE, CfRequestDetails> {
  CfRequestType get cfRequestType => CfRequestType.backend;
  const CfRequestParam();
}

abstract class CfBackendRequestParam<RESULT, RESPONSE>
    extends CfRequestParam<RESULT, RESPONSE> {
  const CfBackendRequestParam();
  @override
  CfRequestType get cfRequestType => CfRequestType.backend;
  abstract final String method;
  List<String> get pathParameters => [];
  Map<String, dynamic>? get queryParameters => null;

  @override
  RESULT onResonse(RESPONSE result) {
    return result as RESULT;
  }

  @override
  RequestMethod get requestMethod => RequestMethod.get;
  @override
  CfRequestDetails buildRequest(int v) {
    final pathParams = ChainFlipProviderUtils.extractParams(method);
    if (pathParams.length != pathParameters.length) {
      throw DartOnChainSwapPluginException("Invalid Path Parameters.", details: {
        "pathParams": pathParameters.join(","),
        "ExceptedPathParametersLength": pathParams.length.toString()
      });
    }
    String params = method;
    for (int i = 0; i < pathParams.length; i++) {
      params = params.replaceFirst(pathParams[i], pathParameters[i]);
    }
    final queryParams = Map<String, dynamic>.from(queryParameters ?? {});
    if (queryParams.isNotEmpty) {
      params = Uri(path: params, queryParameters: queryParams).normalizePath().toString();
    }
    return CfRequestDetails(
      requestID: v,
      responseEncoding: ServiceReponseEncoding.fromType<RESPONSE>(),
      path: params,
      requestMethod: requestMethod,
      cfRequestType: cfRequestType,
      method: method,
    );
  }
}

abstract class CfRPCRequestParam<RESULT, RESPONSE>
    extends CfRequestParam<RESULT, RESPONSE> {
  const CfRPCRequestParam();

  @override
  CfRequestType get cfRequestType => CfRequestType.rpc;
  abstract final String method;
  List<dynamic> get params => [];
  final Map<String, String>? headers = null;
  @override
  RequestMethod get requestMethod => RequestMethod.post;
  @override
  CfRequestDetails buildRequest(int requestID) {
    return CfRequestDetails(
      requestID: requestID,
      headers: headers ?? ServiceConst.defaultPostHeaders,
      path: method,
      requestMethod: RequestMethod.post,
      responseEncoding: ServiceReponseEncoding.map,
      bodyString: StringUtils.fromJson(ServiceProviderUtils.buildJsonRPCParams(
          requestId: requestID, method: method, params: params)),
      cfRequestType: cfRequestType,
      method: method,
    );
  }
}

abstract class CfTRPCRequest<RESULT, RESPONSE> extends CfRequestParam<RESULT, RESPONSE> {
  const CfTRPCRequest();
  abstract final String method;

  @override
  CfRequestType get cfRequestType => CfRequestType.batchTrcp;
  Map<String, dynamic> get params => {};
  Map<String, dynamic>? get queryParameters => null;
  final Map<String, String>? headers = null;
  @override
  RequestMethod get requestMethod => RequestMethod.post;
  @override
  CfRequestDetails buildRequest(int requestID) {
    String pathParameters = "/trpc/$method";
    final queryParams = Map<String, dynamic>.from(queryParameters ?? {});
    if (queryParams.isNotEmpty) {
      pathParameters = Uri(path: pathParameters, queryParameters: queryParams)
          .normalizePath()
          .toString();
    }
    return CfRequestDetails(
        requestID: requestID,
        headers: headers ?? ServiceConst.defaultPostHeaders,
        path: pathParameters,
        requestMethod: RequestMethod.post,
        bodyString: StringUtils.fromJson(params),
        cfRequestType: cfRequestType,
        responseEncoding: ServiceReponseEncoding.fromType<RESPONSE>(),
        method: method,
        errorStatusCodes: CfProviderConst.trpcErrorStatusCodes);
  }
}

abstract class CfAPIRequest<RESULT, RESPONSE> extends CfRequestParam<RESULT, RESPONSE> {
  const CfAPIRequest();
  abstract final String method;

  @override
  CfRequestType get cfRequestType => CfRequestType.batchTrcp;
  Map<String, dynamic> get params => {};
  Map<String, dynamic>? get queryParameters => null;
  final Map<String, String>? headers = null;
  @override
  RequestMethod get requestMethod => RequestMethod.post;
  @override
  CfRequestDetails buildRequest(int requestID) {
    String pathParameters = "/api/$method";
    final queryParams = Map<String, dynamic>.from(queryParameters ?? {});
    if (queryParams.isNotEmpty) {
      pathParameters = Uri(path: pathParameters, queryParameters: queryParams)
          .normalizePath()
          .toString();
    }
    return CfRequestDetails(
        requestID: requestID,
        headers: headers ?? ServiceConst.defaultPostHeaders,
        path: pathParameters,
        requestMethod: requestMethod,
        bodyString: StringUtils.fromJson(params),
        cfRequestType: cfRequestType,
        responseEncoding: ServiceReponseEncoding.fromType<RESPONSE>(),
        method: method,
        errorStatusCodes: CfProviderConst.trpcErrorStatusCodes);
  }
}

class CfRequestDetails extends OnChainSwapRequestDetails {
  final CfRequestType cfRequestType;
  final String method;
  const CfRequestDetails({
    required super.requestID,
    required this.method,
    required super.requestMethod,
    required this.cfRequestType,
    super.path,
    required super.responseEncoding,
    super.errorStatusCodes,
    super.headers = const {},
    super.bodyBytes,
    super.bodyString,
  }) : super(api: OnChainSwapProviderApi.chainFlip);
  factory CfRequestDetails.deserialize({
    List<int>? bytes,
    CborObject? obj,
  }) {
    final values = CborTagSerializable.decodeTaggedValue(
      identifier: OnChainSwapSerializationIdentifier.provider,
      cborBytes: bytes,
      cborObject: obj,
    );
    return CfRequestDetails(
        headers: values
            .mapAt<CborStringValue, CborStringValue>(1)
            .map((k, v) => MapEntry(k.value, v.value)),
        errorStatusCodes:
            values.listAt<CborIntValue>(2).map((e) => e.value).toList().emptyAsNull,
        path: values.rawValueAt(3),
        requestMethod: RequestMethod.fromValue(values.rawValueAt(4)),
        responseEncoding: ServiceReponseEncoding.fromValue(values.rawValueAt(5)),
        bodyBytes: values.rawValueAt(6),
        bodyString: values.rawValueAt(7),
        requestID: values.rawValueAt(8),
        method: values.rawValueAt(9),
        cfRequestType: CfRequestType.fromValue(values.rawValueAt(10)));
  }
  CfRequestDetails copyWith(
      {int? requestID,
      Map<String, String>? headers,
      List<int>? bodyBytes,
      String? bodyString,
      ServiceReponseEncoding? responseEncoding,
      String? method,
      RequestMethod? requestMethod,
      String? path,
      CfRequestType? cfRequestType,
      List<int>? errorStatusCodes}) {
    return CfRequestDetails(
        requestID: requestID ?? this.requestID,
        headers: headers ?? this.headers,
        responseEncoding: responseEncoding ?? this.responseEncoding,
        bodyString: bodyString ?? this.bodyString,
        bodyBytes: bodyBytes ?? this.bodyBytes,
        method: method ?? this.method,
        requestMethod: requestMethod ?? this.requestMethod,
        path: path ?? this.path,
        cfRequestType: cfRequestType ?? this.cfRequestType,
        errorStatusCodes: errorStatusCodes ?? this.errorStatusCodes);
  }

  @override
  Uri encodeUrl(String uri, {String? brokerUrl}) {
    if (path == "broker_requestSwapDepositAddress") {
      if (brokerUrl == null) {
        throw const DartOnChainSwapPluginException(
            "broker_requestSwapDepositAddress required broker url.");
      }
      uri = brokerUrl;
    }
    String url = uri;
    if (url.endsWith("/")) {
      url = url.substring(0, url.length - 1);
    }
    if (cfRequestType == CfRequestType.rpc) {
      return Uri.parse("$url/");
    }

    return Uri.parse("$url${path ?? ''}");
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'body': bodyString ?? BytesUtils.tryToHexString(bodyBytes),
      "method": method,
      "path": path,
      "type": requestMethod.name,
      "cfRequestType": requestMethod.name
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
        path?.toCbor(),
        requestMethod.value.toCbor(),
        responseEncoding.value.toCbor(),
        bodyBytes?.toCborBytes(),
        bodyString?.toCbor(),
        requestID.toCbor(),
        method.toCbor(),
        cfRequestType.value.toCbor()
      ];
}
