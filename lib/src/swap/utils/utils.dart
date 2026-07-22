import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:on_chain_swap/src/exception/exception.dart';
import 'package:on_chain_swap/src/swap/constants/constants.dart';
import 'package:on_chain_swap/src/swap/types/types.dart';
import 'package:cosmos_sdk/cosmos_sdk.dart';
import 'package:on_chain/on_chain.dart';
import 'package:polkadot_dart/polkadot_dart.dart';
import 'package:xrpl_dart/xrpl_dart.dart';
import 'package:zcash_dart/zcash.dart';

class SwapUtils {
  static final List<int> _fakeAddressBytes = List.unmodifiable(List.filled(20, 12));
  static final String _fakeBitcoinAddressProgram =
      BytesUtils.toHexString(_fakeAddressBytes);

  static SwapNetwork? findAssetNetwork(String chainId) {
    return SwapConstants.networks.firstWhereNullable((e) => e.identifier == chainId);
  }

  static String getFakeAddress(SwapNetwork network) {
    return switch (network.type) {
      SwapChainType.polkadot => "13onmpE6zdBNiocF3CRaufAKbahEwXvyPUwX1MBsYATRNdyH",
      SwapChainType.ethereum =>
        ETHAddress.fromBytes(QuickCrypto.generateRandom(20)).address,
      SwapChainType.cosmos =>
        Bech32Encoder.encode((network as SwapCosmosNetwork).bech32, _fakeAddressBytes),
      SwapChainType.solana => "ErdeHDhHkJhNrGVJoiVVYGWuDTfF9sQ7XJdpwBg4sc6c",
      SwapChainType.bitcoin => BitcoinBaseAddress.fromProgram(
              addressProgram: _fakeBitcoinAddressProgram, type: P2pkhAddressType.p2pkh)
          .toAddress(network.cast<SwapBitcoinNetwork>().chain),
      SwapChainType.tron => "TUge3PRXmvPYUrPNG4Xp7nLQTYrrgXjmLL",
      SwapChainType.xrp => "rPBk5cVfav22xc8VWDc4hwhqkGUZ28Mq8c",
      SwapChainType.ada => switch (network.chainType) {
          ChainType.testnet =>
            "addr_test1qqlcpyrvjrelaahg0vmjfcmp9vrfzu7enpuqdx32scp08jksf5ec8d9jnhdjw0jnq3cf3ad89xsc3z6h89ycxggs3neqss6zg6",
          ChainType.mainnet =>
            "addr1q8lkhu0symp74utj2t5vvpu648nufx3gjxm7ypksa96v8cfjqzgyeq74awqr7ujk9d6n82qm7mev7twunvxld8qv9thst9udgc",
        },
      SwapChainType.zcash => switch (network.chainType) {
          ChainType.testnet =>
            "utest1ws70zzrvxeyvyvxeeqa82v9zlr79jnalhtpsqax7573myutc9rkmwnytg3qk5k0yhvtngsrk0c64g9quukjp6s9jxkepkfhq30q95y4q4hftfvpsu5lvrey7fa9enqje4v2w9q07cc5h20qpsedf4hhh4wklvjrtg8pvme3z8wzx890shthzw3x6ljc0s8auzuy9wuh7t8df7tudwe3",
          ChainType.mainnet =>
            "u1yt8552e4czndcu48nk72s66hcjf2vua8l2pvh4dtykxkc2qjxwrpcyqf4rzuld64pe289hjsunnn7fl6535wd90zjdrnumk7r7wymh9fv5pt5vh63g6l92y3z7z979nxw2tjmuvmwdenpflgl486gxu0zfcvajfre6f8ydad95ata4wjrp8sackz3p33sm235dyuqgf4g6j728s2mqj",
        },
    };
  }

  static String checkOrGetFakeAddress(
      {required String? address, required SwapNetwork network}) {
    if (address == null) return getFakeAddress(network);
    return validateNetworkAddress(network, address);
  }

  static T toNetworkAddress<T extends IAddress>(SwapNetwork network, String address) {
    try {
      final IAddress networkAddress = switch (network.type) {
        SwapChainType.polkadot => SubstrateAddress(address,
            ss58Format: network.cast<SwapSubstrateNetwork>().ss58Format),
        SwapChainType.ethereum => ETHAddress(address),
        SwapChainType.cosmos =>
          CosmosBaseAddress(address, forceHrp: network.cast<SwapCosmosNetwork>().bech32),
        SwapChainType.solana => SolAddress(address),
        SwapChainType.bitcoin => BitcoinNetworkAddress.parse(
            address: address, network: network.cast<SwapBitcoinNetwork>().chain),
        SwapChainType.tron => TronAddress(address),
        SwapChainType.xrp => XRPBaseAddress(address, chainType: network.chainType),
        SwapChainType.ada => ADAAddress.fromAddress(address,
            network: switch (network.chainType) {
              ChainType.testnet => ADANetwork.testnetPreprod,
              ChainType.mainnet => ADANetwork.mainnet,
            }),
        SwapChainType.zcash => ZcashAddress(address,
            network: switch (network.chainType) {
              ChainType.testnet => ZcashNetwork.testnet,
              ChainType.mainnet => ZcashNetwork.mainnet,
            }),
      };
      if (networkAddress is! T) {
        throw DartOnChainSwapPluginException("Casting address failed.",
            details: {"expected": "$T", "type": networkAddress.runtimeType.toString()});
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
      final iAddress = toNetworkAddress(network, address);
      return iAddress.address;
    } on DartOnChainSwapPluginException {
      rethrow;
    } catch (e) {
      throw DartOnChainSwapPluginException(
          "Invalid address. '$address' is not a valid ${network.type.name} address.");
    }
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

  // static double worstPercentageAmount(
  //     {required SwapAmount expected, required SwapAmount worst}) {
  //   final a = BigRational.parseDecimal(expected.amountString);
  //   final b = BigRational.parseDecimal(worst.amountString);
  //   final r = ((a - b) / a) * BigRational.from(100);
  //   return r.toDouble();
  // }
  static double worstPercentageAmount({
    required SwapAmount expected,
    required SwapAmount worst,
  }) {
    assert(expected.decimals == worst.decimals, "${expected.decimals}/${worst.decimals}");

    final diff = expected.amount - worst.amount;

    return (diff.toDouble() / expected.amount.toDouble()) * 100;
  }
}
