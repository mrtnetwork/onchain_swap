import 'package:blockchain_utils/exception/exceptions.dart';
import 'package:blockchain_utils/service/service.dart';
import 'package:blockchain_utils/utils/utils.dart';
import 'package:on_chain_swap/src/providers/skip_go/provider.dart';

class SkipGoApiProvider implements BaseProvider<SkipGoApiRequestDetails> {
  final SkipGoApiServiceProvider rpc;

  SkipGoApiProvider(this.rpc);

  static SERVICERESPONSE _findError<SERVICERESPONSE>(
      {required BaseServiceResponse<Map<String, dynamic>> response,
      required SkipGoApiRequestDetails params}) {
    if (response.type == ServiceResponseType.error) {
      final Map<String, dynamic>? error =
          StringUtils.tryToJson(response.cast<ServiceErrorResponse>().error);
      final String message = error?["message"] ??
          ServiceConst.httpErrorMessages[response.statusCode] ??
          ServiceConst.defaultError;
      throw RPCError(
          message: message,
          details: {
            "statusCode": response.statusCode,
            "details": error?["details"]
          },
          errorCode: IntUtils.tryParse(error?["code"]));
    }
    final Map<String, dynamic> r = response.getResult(params);

    return ServiceProviderUtils.parseResponse(object: r, params: params);
  }

  int _id = 0;

  @override
  Future<RESULT> request<RESULT, SERVICERESPONSE>(
      BaseServiceRequest<RESULT, SERVICERESPONSE, SkipGoApiRequestDetails>
          request,
      {Duration? timeout}) async {
    final r = await requestDynamic(request, timeout: timeout);
    return request.onResonse(r);
  }

  @override
  Future<SERVICERESPONSE> requestDynamic<RESULT, SERVICERESPONSE>(
      BaseServiceRequest<RESULT, SERVICERESPONSE, SkipGoApiRequestDetails>
          request,
      {Duration? timeout}) async {
    final params = request.buildRequest(_id++);
    final response =
        await rpc.doRequest<Map<String, dynamic>>(params, timeout: timeout);
    return _findError(params: params, response: response);
  }
}
