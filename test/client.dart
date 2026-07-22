import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:cosmos_sdk/cosmos_sdk.dart';
import 'package:http/http.dart' as http;

/// "https://gateway.liquify.com/chain/thorchain_api/thorchain"
/// tor new url
class ThorClient with ThorNodeServiceProvider {
  final String url;
  const ThorClient(this.url);
  @override
  Future<ThorNodeServiceResponse> doRequest(ThorNodeRequestDetails params,
      {Duration? timeout}) async {
    final client = http.Client();
    try {
      final uri = params.encodeUrl(url);
      final response = switch (params.requestMethod) {
        RequestMethod.get => await client.get(uri,
            headers: {...params.headers}).timeout(timeout ?? const Duration(seconds: 60)),
        _ => await client
            .post(uri, headers: {...params.headers}, body: params.encodeBody())
            .timeout(timeout ?? const Duration(seconds: 60))
      };
      return params.toResponse(
        response.bodyBytes,
        statusCode: response.statusCode,
      );
    } finally {
      client.close();
    }
  }
}
