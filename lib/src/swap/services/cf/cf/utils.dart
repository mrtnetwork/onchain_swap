import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:on_chain_swap/src/exception/exception.dart';
import 'package:on_chain_swap/src/swap/types/types.dart';
import 'constants.dart';

class CfSwapUtils {
  static String channelUrl({required SwapNetwork network, required String channelId}) {
    switch (network.chainType) {
      case ChainType.mainnet:
        return CfSwapConstants.mainnetChannelUrl.replaceFirst("#id", channelId);
      case ChainType.testnet:
        return CfSwapConstants.testnetChannelUrl.replaceFirst("#id", channelId);
    }
  }

  static String calculateMinPrice(
      {required String estimatedPrice,
      required num tolerance,
      required BaseSwapAsset destinationAsset}) {
    final r = tolerance.toDouble();
    if (r.isNegative || r > 100) {
      throw const DartOnChainSwapPluginException(
          "Invalid tolerance. tolerance must be between 0 and 100");
    }
    final toleranceBig = BigRational.parseDecimal(r.toString());
    BigRational price = BigRational.parseDecimal(estimatedPrice);
    final est = (BigRational.from(100) - toleranceBig) / BigRational.from(100);
    price = price * est;
    return price.toDecimal(digits: destinationAsset.decimal);
  }

  static SwapAmount calculateMinAmount(
      {required BigInt amount,
      required num tolerance,
      required BaseSwapAsset destinationAsset}) {
    final r = tolerance.toDouble();
    if (r.isNegative || r > 100) {
      throw const DartOnChainSwapPluginException(
          "Invalid tolerance. tolerance must be between 0 and 100");
    }
    final toleranceBig = BigRational.parseDecimal(r.toString());
    BigRational price = BigRational(amount);
    final est = (BigRational.from(100) - toleranceBig) / BigRational.from(100);
    price = price * est;
    return SwapAmount.fromBigInt(price.toBigInt(), destinationAsset.decimal);
  }

  static String calculateMinX128Price(
      {required String minPrice,
      required BaseSwapAsset source,
      required BaseSwapAsset dest}) {
    BigRational big = BigRational.parseDecimal(minPrice);
    big = big * BigRational(BigInt.from(2).pow(128));
    final decimals = dest.decimal - source.decimal;
    if (decimals.isNegative) {
      final x128Price = big / BigRational(BigInt.from(10).pow(decimals.abs()));
      return x128Price.ceil().toString();
    }
    final x128Price = big * BigRational(BigInt.from(10).pow(decimals));
    return x128Price.ceil().toString();
  }
}
