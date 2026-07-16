import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:on_chain_swap/src/exception/exception.dart';
import 'package:on_chain_swap/src/swap/constants/constants.dart';
import 'package:on_chain_swap/src/swap/types/types.dart';
import 'package:cosmos_sdk/cosmos_sdk.dart';
import 'package:on_chain/on_chain.dart';
import 'package:polkadot_dart/polkadot_dart.dart';

class SwapUtils {
  static final List<int> _fakeAddressBytes =
      List.unmodifiable(List.filled(20, 12));
  static final String _fakeBitcoinAddressProgram =
      BytesUtils.toHexString(_fakeAddressBytes);
  static BigInt decodePrice(String price, int decimal,
      {bool validateDecimal = true}) {
    return decodePriceRational(price, decimal, validateDecimal: validateDecimal)
        .toBigInt();
  }

  static BigRational decodePriceRational(String price, int decimal,
      {bool validateDecimal = true}) {
    BigRational dec = BigRational.parseDecimal(price);
    BigRational decimals = BigRational(BigInt.from(10).pow(decimal));
    dec = dec * decimals;
    if (validateDecimal) {
      if (decimal == 0 && dec.isDecimal) {
        throw const DartOnChainSwapPluginException(
            "price should not be decimal with decimal zero");
      }
    }
    return dec;
  }

  static String encodePrice(BigInt price, int decimal, {int amoutDecimal = 5}) {
    if (amoutDecimal > decimal) {
      amoutDecimal = decimal;
    }
    final BigRational dec =
        BigRational(price) / BigRational(BigInt.from(10).pow(decimal));
    return dec.toDecimal(digits: amoutDecimal);
  }

  static SwapNetwork? findAssetNetwork(String chainId) {
    return SwapConstants.networks
        .firstWhereNullable((e) => e.identifier == chainId);
  }

  static String getFakeAddress(SwapNetwork network) {
    return switch (network.type) {
      SwapChainType.polkadot =>
        "13onmpE6zdBNiocF3CRaufAKbahEwXvyPUwX1MBsYATRNdyH",
      SwapChainType.ethereum =>
        ETHAddress.fromBytes(QuickCrypto.generateRandom(20)).address,
      SwapChainType.cosmos => Bech32Encoder.encode(
          (network as SwapCosmosNetwork).bech32, _fakeAddressBytes),
      SwapChainType.solana => "ErdeHDhHkJhNrGVJoiVVYGWuDTfF9sQ7XJdpwBg4sc6c",
      SwapChainType.bitcoin => BitcoinBaseAddress.fromProgram(
              addressProgram: _fakeBitcoinAddressProgram,
              type: P2pkhAddressType.p2pkh)
          .toAddress(network.cast<SwapBitcoinNetwork>().chain),
    };
  }

  static String checkOrGetFakeAddress(
      {required String? address, required SwapNetwork network}) {
    if (address == null) return getFakeAddress(network);
    return validateNetworkAddress(network, address);
  }

  static T toNetworkAddress<T>(SwapNetwork network, String address) {
    try {
      final dynamic networkAddress = switch (network.type) {
        SwapChainType.polkadot => SubstrateAddress(address,
            ss58Format: network.cast<SwapSubstrateNetwork>().ss58Format),
        SwapChainType.ethereum => ETHAddress(address),
        SwapChainType.cosmos => CosmosBaseAddress(address,
            forceHrp: network.cast<SwapCosmosNetwork>().bech32),
        SwapChainType.solana => SolAddress(address),
        SwapChainType.bitcoin => BitcoinNetworkAddress.parse(
            address: address,
            network: network.cast<SwapBitcoinNetwork>().chain),
      };
      if (networkAddress is! T) {
        throw DartOnChainSwapPluginException("Casting address failed.",
            details: {
              "expected": "$T",
              "type": networkAddress.runtimeType.toString()
            });
      }
      return networkAddress;
    } catch (e) {
      throw DartOnChainSwapPluginException(
          "Invalid address. '$address' is not a valid ${network.type.name} address.");
    }

    // return
  }

  static String validateNetworkAddress<T>(SwapNetwork network, String address) {
    try {
      final dynamic networkAddress = switch (network.type) {
        SwapChainType.polkadot => SubstrateAddress(address,
                ss58Format: network.cast<SwapSubstrateNetwork>().ss58Format)
            .address,
        SwapChainType.ethereum => ETHAddress(address).address,
        SwapChainType.cosmos => CosmosBaseAddress(address,
                forceHrp: network.cast<SwapCosmosNetwork>().bech32)
            .address,
        SwapChainType.solana => SolAddress(address).address,
        SwapChainType.bitcoin => BitcoinNetworkAddress.parse(
                address: address,
                network: network.cast<SwapBitcoinNetwork>().chain)
            .address,
      };
      return networkAddress;
    } catch (e) {
      throw DartOnChainSwapPluginException(
          "Invalid address. '$address' is not a valid ${network.type.name} address.");
    }

    // return
  }

  static DateTime secondsToDateTime(BigInt seconds) {
    final millisecondsSinceEpoch = seconds * BigInt.from(1000);
    return DateTime.fromMillisecondsSinceEpoch(millisecondsSinceEpoch.toInt());
  }

  static DateTime? unixSecondsToDateTime(BigInt? seconds) {
    if (seconds == null) return null;
    final miliSeconds = seconds * BigInt.from(1000);
    if (!miliSeconds.isValidInt) return null;
    return DateTime.fromMillisecondsSinceEpoch(miliSeconds.toInt());
  }

  static int secondsToMinutes(int sec) {
    return (sec / 60).ceil();
  }

  static Set<BaseSwapAsset> sortAssets(Set<BaseSwapAsset> assets) {
    final clone = assets.toList();
    clone.sort((a, b) {
      if (a.isNative && !b.isNative) return -1;
      if (!a.isNative && b.isNative) return 1;
      return a.providerIdentifier
          .toLowerCase()
          .compareTo(b.providerIdentifier.toLowerCase());
    });
    return clone.toImutableSet;
  }

  static double worstPercentageAmount(
      {required SwapAmount expected, required SwapAmount worst}) {
    final a = expected.rational;
    final b = worst.rational;
    final r = ((a - b) / a) * BigRational.from(100);
    return r.toDouble();
  }
}
