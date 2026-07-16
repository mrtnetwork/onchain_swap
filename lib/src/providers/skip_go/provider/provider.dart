import 'package:blockchain_utils/exception/exceptions.dart';
import 'package:blockchain_utils/service/service.dart';
import 'package:blockchain_utils/utils/utils.dart';
import 'package:on_chain_swap/src/providers/skip_go/provider.dart';

class SkipGoApiProvider<SERVICE extends IServiceProvider>
    implements IProvider<SERVICE, SkipGoApiRequestDetails> {
  @override
  final SERVICE service;

  SkipGoApiProvider(this.service);

  static SERVICERESPONSE _findError<SERVICERESPONSE>(
      {required BaseServiceResponse response,
      required SkipGoApiRequestDetails params}) {
    if (response.type == ServiceResponseType.error) {
      final err = response.cast<BaseServiceErrorResponse>();
      if (!err.validate) {
        throw err.defaultError();
      }
      final Map<String, dynamic>? error = err.tryToJson();
      final String message = error?["message"] ??
          ServiceProviderUtils.getDefaultError(response.statusCode);
      throw RPCError(
          message: message,
          statusCode: response.statusCode,
          jsonRpcErrpr: error,
          errorCode: IntUtils.tryParse(error?["code"]));
    }
    return params.toEncodingResponse<SERVICERESPONSE>(response);
  }

  int _id = 0;

  @override
  Future<RESULT> request<RESULT, SERVICERESPONSE>(
      IServiceRequest<RESULT, SERVICERESPONSE, SkipGoApiRequestDetails> request,
      {Duration? timeout}) async {
    final r = await requestDynamic<RESULT, SERVICERESPONSE>(request,
        timeout: timeout);
    return request.onResonse(r);
  }

  @override
  Future<SERVICERESPONSE> requestDynamic<RESULT, SERVICERESPONSE>(
      IServiceRequest<RESULT, SERVICERESPONSE, SkipGoApiRequestDetails> request,
      {Duration? timeout}) async {
    final params = request.buildRequest(_id++);
    final response = await service.doRequest(params, timeout: timeout);
    return _findError(params: params, response: response);
  }
}
