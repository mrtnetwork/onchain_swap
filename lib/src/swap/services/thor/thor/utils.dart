import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:on_chain_swap/src/swap/services/thor/thor/route.dart' show ThorSwapRoute;
import 'package:on_chain_swap/src/swap/types/types.dart';
import 'package:cosmos_sdk/cosmos_sdk.dart';

class ThorSwapUtils {
  static String abbreviateFuzzy(String asset, {bool short = true}) {
    final parts = asset.split('.');
    if (parts.length != 2) return asset;
    final chain = parts[0];
    final symbolParts = parts[1].split('-');
    final ticker = symbolParts[0];
    final address = symbolParts.length > 1 ? symbolParts[1] : '';
    if (address.isEmpty || short) {
      return "$chain.$ticker";
    }
    return '$chain.$ticker-${address.substring(address.length - 3)}';
  }

  static double ceilBpsToDouble(int bps) {
    return (((bps + 99) ~/ 100) * 100) / 100;
  }

  static String buildMemo(ThorSwapRoute route, String destination) {
    final interval = route.interval;
    String assetIdentifier = route.quote.destinationAsset.providerIdentifier;
    if (route.quote.destinationAsset.isContract) {
      assetIdentifier = abbreviateFuzzy(assetIdentifier, short: true);
    }
    if (route.tolerance == 0 && interval == null) {
      return "=:$assetIdentifier:$destination";
    }
    BigInt worstAmount = BigInt.zero;
    if (route.tolerance != 0) {
      final amount = calculateWorstCaseAmount(
          expectedAmount: route.expectedAmount, tolerancePercent: route.tolerance);
      worstAmount = toThorUnit(amount.amount, amount.decimals);
    }
    if (interval == null) {
      return "=:$assetIdentifier:$destination:$worstAmount";
    }
    return "=:$assetIdentifier:$destination:$worstAmount/$interval/0";
  }

  static SwapAmount calculateWorstCaseAmount({
    required SwapAmount expectedAmount,
    required double tolerancePercent,
  }) {
    // 0.5% => 50 bps
    final toleranceBps = (tolerancePercent * 100).ceil();

    final numerator = BigInt.from(10000 - toleranceBps);
    final denominator = BigInt.from(10000);

    final worst = (expectedAmount.amount * numerator) ~/ denominator;

    return SwapAmount.fromBigInt(
      worst,
      expectedAmount.decimals,
    );
  }

  static List<SwapFee> buildQuoteFee(
      {required ThoreNodeQouteSwapFeeResponse fees, BaseSwapAsset? asset}) {
    if (asset == null) return [];
    final liquidity = BigintUtils.tryParse(fees.liquidity) ?? BigInt.zero;
    final outbound = BigintUtils.tryParse(fees.outbound) ?? BigInt.zero;
    final affiliate = BigintUtils.tryParse(fees.affiliate) ?? BigInt.zero;
    return [
      if (liquidity > BigInt.zero)
        SwapFee(
            token: asset,
            amount: toNativeAmountFromThor(asset: asset, amount: liquidity),
            type: SwapFeeType.liquidity.name,
            asset: asset.symbol),
      if (outbound > BigInt.zero)
        SwapFee(
            token: asset,
            amount: toNativeAmountFromThor(asset: asset, amount: outbound),
            type: SwapFeeType.outbound.name,
            asset: asset.symbol),
      if (affiliate > BigInt.zero)
        SwapFee(
            token: asset,
            amount: toNativeAmountFromThor(asset: asset, amount: affiliate),
            type: SwapFeeType.affiliate.name,
            asset: asset.symbol),
    ];
  }

  static BigInt toThorUnit(BigInt amount, int decimals) {
    if (decimals == 8) return amount;

    if (decimals > 8) {
      return amount ~/ BigInt.from(10).pow(decimals - 8);
    }

    return amount * BigInt.from(10).pow(8 - decimals);
  }

  static BigInt toThorUnitFromInput(
      {required BaseSwapAsset asset, required String amount}) {
    if (asset.decimal == 8) {
      return SwapAmount.fromString(amount, 8).amount;
    }
    final decodePrice = SwapAmount.fromString(amount, asset.decimal);
    return SwapAmount.fromBigInt(toThorUnit(decodePrice.amount, asset.decimal), 8).amount;
  }

  static SwapAmount toNativeAmountFromThor({
    required BaseSwapAsset asset,
    required BigInt amount,
  }) {
    if (asset.decimal == 8) {
      return SwapAmount.fromBigInt(amount, 8);
    }

    if (asset.decimal > 8) {
      return SwapAmount.fromBigInt(
        amount * BigInt.from(10).pow(asset.decimal - 8),
        asset.decimal,
      );
    }

    return SwapAmount.fromBigInt(
      amount ~/ BigInt.from(10).pow(8 - asset.decimal),
      asset.decimal,
    );
  }

  static SwapAmount? totalFee(List<SwapFee> fees) {
    final token = fees.firstOrNull?.token;
    if (token == null) return null;
    BigInt total = BigInt.zero;
    for (final fee in fees) {
      if (fee.amount case SwapAmount(:final amount) when fee.token == token) {
        total += amount;
      } else {
        return null;
      }
    }
    return SwapAmount.fromBigInt(total, token.decimal);
  }
}
