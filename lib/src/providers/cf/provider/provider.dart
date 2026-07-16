import 'dart:async';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:on_chain_swap/src/providers/cf/core/core.dart';

class CfProvider<SERVICE extends IServiceProvider>
    implements IProvider<SERVICE, CfRequestDetails> {
  @override
  final SERVICE service;

  CfProvider(this.service);

  static SERVICERESPONSE _findError<SERVICERESPONSE>(
      {required BaseServiceResponse response,
      required CfRequestDetails params}) {
    if (response.type == ServiceResponseType.error) {
      final err = response.cast<BaseServiceErrorResponse>();
      if (!err.validate) {
        throw err.defaultError();
      }
      final Map<String, dynamic>? error = err.tryToJson();
      if (params.cfRequestType == CfRequestType.batchTrcp) {
        Map<String, dynamic>? errorData =
            StringUtils.tryToJson(error?["error"]);
        if (errorData?.containsKey("json") ?? false) {
          errorData = StringUtils.tryToJson(errorData!["json"]);
        }
        final String? message = errorData?["message"]?.toString();
        final int? code = IntUtils.tryParse(errorData?["code"]);
        final Map<String, dynamic>? data =
            StringUtils.tryToJson(errorData?["data"]);
        throw RPCError(
            message: message ??
                ServiceProviderUtils.getDefaultError(response.statusCode),
            errorCode: code,
            jsonRpcErrpr: data,
            request: params.toJson());
      }
      final message = error?["message"];

      throw RPCError(
          message: message is String
              ? message
              : ServiceProviderUtils.getDefaultError(response.statusCode),
          statusCode: response.statusCode,
          jsonRpcErrpr: error,
          // details: {"details": error?["details"]},
          errorCode: IntUtils.tryParse(error?["code"]));
    }
    final result = params.tryEncodingResponse<SERVICERESPONSE>(response);
    if (result != null && params.requestMethod == RequestMethod.get ||
        params.cfRequestType == CfRequestType.batchTrcp) {
      return ServiceProviderUtils.toResponse<SERVICERESPONSE>(
          object: result, params: params);
    }
    final jsonRpcResponse =
        ServiceProviderUtils.toResponse<Map<String, dynamic>>(
            object: result ??
                params.tryEncodingResponse(response,
                    encoding: ServiceReponseEncoding.map),
            params: params);

    final Map<String, dynamic>? error =
        StringUtils.tryToJson(jsonRpcResponse["error"]);
    if (error != null) {
      final message = error["message"];
      throw RPCError(
          message: message is String ? message : ServiceConst.defaultError,
          errorCode: IntUtils.tryParse(error["code"]),
          jsonRpcErrpr: error);
    }
    return ServiceProviderUtils.toResponse<SERVICERESPONSE>(
        object: jsonRpcResponse["result"], params: params);
  }

  int _id = 0;

  @override
  Future<RESULT> request<RESULT, SERVICERESPONSE>(
      IServiceRequest<RESULT, SERVICERESPONSE, CfRequestDetails> request,
      {Duration? timeout}) async {
    final r = await requestDynamic<RESULT, SERVICERESPONSE>(request,
        timeout: timeout);
    return request.onResonse(r);
  }

  @override
  Future<SERVICERESPONSE> requestDynamic<RESULT, SERVICERESPONSE>(
      IServiceRequest<RESULT, SERVICERESPONSE, CfRequestDetails> request,
      {Duration? timeout}) async {
    final params = request.buildRequest(_id++);
    if (params.requestMethod == RequestMethod.get ||
        params.cfRequestType == CfRequestType.batchTrcp) {
      final response = await service.doRequest(params, timeout: timeout);
      return _findError<SERVICERESPONSE>(params: params, response: response);
    }
    final response = await service.doRequest(params, timeout: timeout);
    return _findError<SERVICERESPONSE>(params: params, response: response);
  }
}
