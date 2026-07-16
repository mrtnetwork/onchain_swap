import 'package:on_chain_swap/src/providers/cf/core/core.dart';

import 'package:blockchain_utils/service/models/params.dart';

typedef CfServiceResponse = BaseServiceResponse;

mixin CfServiceProvider
    implements
        IServiceProvider<CfRequestDetails, BaseGRPCServiceRequestParams> {
  @override
  Future<CfServiceResponse> doRequest(CfRequestDetails params,
      {Duration? timeout});

  @override
  Future<BaseServiceSubscribtionResponse> doSubscribtionRequest(
      {required CfRequestDetails params,
      required BaseServiceSubscribtionRequest<dynamic, dynamic,
              BaseSubscribtionEvent<dynamic>, CfRequestDetails>
          request,
      Duration? timeout}) {
    throw UnsupportedError(
      "Subscribtion requests are not supported by this service.",
    );
  }

  @override
  Future<List<int>> doGrpcRequest(BaseGRPCServiceRequestParams params,
      {Duration? timeout}) {
    throw UnsupportedError("gRPC requests are not supported by this service.");
  }

  @override
  Stream<List<int>> doGrpcRequestStream(BaseGRPCServiceRequestParams params,
      {Duration? timeout}) {
    throw UnsupportedError("gRPC requests are not supported by this service.");
  }

  @override
  Future<Stream<List<int>>> doGrpcRequestStreamAsync(
      BaseGRPCServiceRequestParams params,
      {Duration? timeout}) {
    throw UnsupportedError("gRPC requests are not supported by this service.");
  }
}
