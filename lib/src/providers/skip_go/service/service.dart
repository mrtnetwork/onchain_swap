import 'package:blockchain_utils/service/models/params.dart';
import 'package:on_chain_swap/src/providers/skip_go/core/core/core.dart';

typedef SkipGoApiServiceResponse = BaseServiceResponse;

mixin SkipGoApiServiceProvider
    implements
        IServiceProvider<SkipGoApiRequestDetails,
            BaseGRPCServiceRequestParams> {
  @override
  Future<SkipGoApiServiceResponse> doRequest(SkipGoApiRequestDetails params,
      {Duration? timeout});

  @override
  Future<BaseServiceSubscribtionResponse> doSubscribtionRequest(
      {required SkipGoApiRequestDetails params,
      required BaseServiceSubscribtionRequest<dynamic, dynamic,
              BaseSubscribtionEvent<dynamic>, SkipGoApiRequestDetails>
          request,
      Duration? timeout}) {
    throw UnsupportedError(
      "Subscribtion requests are not supported by this service.",
    );
  }

  @override
  Future<List<int>> doGrpcRequest(
    BaseGRPCServiceRequestParams params, {
    Duration? timeout,
  }) {
    throw UnsupportedError("gRPC requests are not supported by this service.");
  }

  @override
  Stream<List<int>> doGrpcRequestStream(
    BaseGRPCServiceRequestParams params, {
    Duration? timeout,
  }) {
    throw UnsupportedError("gRPC requests are not supported by this service.");
  }

  @override
  Future<Stream<List<int>>> doGrpcRequestStreamAsync(
    BaseGRPCServiceRequestParams params, {
    Duration? timeout,
  }) {
    throw UnsupportedError("gRPC requests are not supported by this service.");
  }
}
