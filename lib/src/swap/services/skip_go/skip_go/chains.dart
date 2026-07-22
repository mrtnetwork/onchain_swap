import 'package:on_chain_swap/src/exception/exception.dart';
import 'package:on_chain_swap/src/providers/skip_go/models/types/types.dart';
import 'package:on_chain_swap/src/swap/types/types.dart';

class SkipGoSwapAsset extends BaseSwapAsset {
  final SkipGoApiAsset asset;

  const SkipGoSwapAsset({
    required super.symbol,
    required super.providerIdentifier,
    required this.asset,
    required super.decimal,
    required super.network,
    required super.provider,
  }) : super(type: SwapAssetType.native);

  @override
  String? get coingeckoId => asset.coingeckoId;

  @override
  String? get logoUrl => asset.logoUri;

  @override
  String get identifier => throw const DartOnChainSwapPluginException("Unsupported api.");
}
