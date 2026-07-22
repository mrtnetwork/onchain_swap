import 'package:blockchain_utils/helper/extensions/extensions.dart';
import 'package:blockchain_utils/service/models/params.dart';
import 'package:on_chain_swap/src/providers/cf/core/core.dart';
import 'package:on_chain_swap/src/providers/cf/models/models.dart';

class CfAPIRequestOpenSwapDepositChannel
    extends CfAPIRequest<TRPCOpenDepositChannelResponse, Map<String, dynamic>> {
  final String? srcAddress;
  final String destAddress;
  final RPCFillOrKillParam fillOrKillParams;
  final CcmParams? ccmParams;
  final QuoteDetails quote;
  final bool? takeCommission;
  const CfAPIRequestOpenSwapDepositChannel(
      {required this.srcAddress,
      required this.destAddress,
      required this.fillOrKillParams,
      this.takeCommission,
      this.ccmParams,
      required this.quote});
  @override
  Map<String, dynamic> get params {
    return {
      "srcAsset": quote.srcAsset.toJson(),
      "destAsset": quote.destAsset.toJson(),
      "srcAddress": srcAddress,
      "destAddress": destAddress,
      "dcaParams": quote.type == QuoteType.dca ? quote.dcaParams?.toJson() : null,
      "fillOrKillParams": fillOrKillParams.toJson(),
      "maxBoostFeeBps": (quote is QuoteBoostedDetails)
          ? (quote as QuoteBoostedDetails).maxBoostFeeBps
          : null,
      "ccmParams": ccmParams?.toJson(),
      "amount": quote.depositAmount,
      "quote": quote.toJson()
    }.notNullValue;
  }

  @override
  String get method => "openSwapDepositChannel";

  @override
  TRPCOpenDepositChannelResponse onResonse(Map<String, dynamic> result) {
    return TRPCOpenDepositChannelResponse.fromJson(result);
  }

  @override
  RequestMethod get requestMethod => RequestMethod.post;
}
