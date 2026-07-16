import 'package:blockchain_utils/utils/utils.dart';
import 'package:on_chain_swap/src/providers/cf/core/core.dart';
import 'package:on_chain_swap/src/providers/cf/models/models.dart';

class CfTRPCRequestOpenSwapDepositChannel extends CfTRPCRequest<
    TRPCOpenDepositChannelResponse, Map<String, dynamic>> {
  final String? srcAddress;
  final String destAddress;
  final RPCFillOrKillParam fillOrKillParams;
  final CcmParams? ccmParams;
  final QuoteDetails quote;
  const CfTRPCRequestOpenSwapDepositChannel(
      {required this.srcAddress,
      required this.destAddress,
      required this.fillOrKillParams,
      this.ccmParams,
      required this.quote});
  @override
  Map<String, dynamic> get params {
    return {
      "json": {
        "srcAsset": quote.srcAsset.asset,
        "srcChain": quote.srcAsset.chain,
        "destAsset": quote.destAsset.asset,
        "destChain": quote.destAsset.chain,
        "srcAddress": srcAddress,
        "destAddress": destAddress,
        "dcaParams":
            quote.type == QuoteType.dca ? quote.dcaParams?.toJson() : null,
        "fillOrKillParams": fillOrKillParams.toJson(),
        "maxBoostFeeBps": (quote is QuoteBoostedDetails)
            ? (quote as QuoteBoostedDetails).maxBoostFeeBps
            : null,
        "ccmParams": ccmParams?.toJson(),
        "amount": quote.depositAmount,
        "quote": quote.toJson()
      },
      "meta": {
        "values": {
          "srcAddress": ["undefined"],
          "dcaParams": ["undefined"],
          "maxBoostFeeBps": ["undefined"],
          "ccmParams": ["undefined"]
        }
      }
    };
  }

  @override
  String get method => "openSwapDepositChannel";

  @override
  TRPCOpenDepositChannelResponse onResonse(Map<String, dynamic> result) {
    return TRPCOpenDepositChannelResponse.fromJson(result
        .valueEnsureAsMap<String, dynamic>("result")
        .valueEnsureAsMap<String, dynamic>("data")
        .valueEnsureAsMap<String, dynamic>("json"));
  }
}
