import 'package:example/api/services/http/http.dart';
import 'package:onchain_swap/onchain_swap.dart';

class SkipGoHTTPService extends HTTPService
    implements SkipGoApiServiceProvider {
  SkipGoHTTPService(
      {required super.service,
      super.defaultTimeOut = const Duration(seconds: 30),
      super.requestTimeout});

  @override
  Future<SkipGoApiServiceResponse<T>> doRequest<T>(
      SkipGoApiRequestDetails params,
      {Duration? timeout}) async {
    return await serviceRequest<T>(params, allowStatus: [200]);
  }
}
