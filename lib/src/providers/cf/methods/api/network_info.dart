import 'package:blockchain_utils/service/models/params.dart';
import 'package:on_chain_swap/src/providers/cf/core/core.dart';
import 'package:on_chain_swap/src/providers/cf/models/models/contract.dart';

class CfAPIRequestNetworkInfo
    extends CfAPIRequest<CfContractNetworkInfo, Map<String, dynamic>> {
  const CfAPIRequestNetworkInfo();
  @override
  Map<String, dynamic> get params {
    return {};
  }

  @override
  String get method => "networkInfo";

  @override
  CfContractNetworkInfo onResonse(Map<String, dynamic> result) {
    return CfContractNetworkInfo.fromJson(result);
  }

  @override
  RequestMethod get requestMethod => RequestMethod.get;
}
