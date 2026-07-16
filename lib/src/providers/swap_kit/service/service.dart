import 'package:blockchain_utils/service/models/params.dart';
import 'package:on_chain_swap/src/providers/swap_kit/core/core/core.dart';

typedef SwapKitServiceResponse = BaseServiceResponse;

mixin SwapKitServiceProvider
    implements
        IServiceProvider<SwapKitRequestDetails, BaseGRPCServiceRequestParams> {
  @override
  Future<SwapKitServiceResponse> doRequest(SwapKitRequestDetails params,
      {Duration? timeout});

  @override
  Future<BaseServiceSubscribtionResponse> doSubscribtionRequest(
      {required SwapKitRequestDetails params,
      required BaseServiceSubscribtionRequest<dynamic, dynamic,
              BaseSubscribtionEvent<dynamic>, SwapKitRequestDetails>
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
