import 'package:blockchain_utils/exception/exceptions.dart';
import 'package:blockchain_utils/service/service.dart';
import 'package:blockchain_utils/utils/utils.dart';
import 'package:on_chain_swap/src/providers/swap_kit/core/core/core.dart';

class SwapKitProvider<SERVICE extends IServiceProvider>
    implements IProvider<SERVICE, SwapKitRequestDetails> {
  @override
  final SERVICE service;

  SwapKitProvider(this.service);

  static SERVICERESPONSE _findError<SERVICERESPONSE>(
      {required BaseServiceResponse response,
      required SwapKitRequestDetails params}) {
    if (response.type == ServiceResponseType.error) {
      final err = response.cast<BaseServiceErrorResponse>();
      if (!err.validate) throw err.defaultError();
      final Map<String, dynamic>? error = err.tryToJson();
      final message = error?["message"];
      throw RPCError(
          message: message is String
              ? message
              : ServiceProviderUtils.getDefaultError(response.statusCode),
          statusCode: response.statusCode,
          jsonRpcErrpr: error,
          errorCode: IntUtils.tryParse(error?["code"]));
    }
    return params.toEncodingResponse(response);
  }

  int _id = 0;

  @override
  Future<RESULT> request<RESULT, SERVICERESPONSE>(
      IServiceRequest<RESULT, SERVICERESPONSE, SwapKitRequestDetails> request,
      {Duration? timeout}) async {
    final r = await requestDynamic<RESULT, SERVICERESPONSE>(request,
        timeout: timeout);
    return request.onResonse(r);
  }

  @override
  Future<SERVICERESPONSE> requestDynamic<RESULT, SERVICERESPONSE>(
      IServiceRequest<RESULT, SERVICERESPONSE, SwapKitRequestDetails> request,
      {Duration? timeout}) async {
    final params = request.buildRequest(_id++);
    final response = await service.doRequest(params, timeout: timeout);
    return _findError<SERVICERESPONSE>(params: params, response: response);
  }
}
