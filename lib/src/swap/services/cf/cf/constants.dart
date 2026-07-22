import 'package:blockchain_utils/helper/extensions/extensions.dart';
import 'package:on_chain/on_chain.dart';
import 'package:on_chain_swap/src/swap/constants/constants.dart';
import 'package:on_chain_swap/src/swap/types/types.dart';

class CfSwapConstants {
  static const String mainnetChannelUrl = "https://scan.chainflip.io/channels/#id";
  static const String testnetChannelUrl =
      "https://scan.perseverance.chainflip.io/channels/#id";

  static final List<BaseSwapAsset> assets = <BaseSwapAsset>[
    eth,
    ethFlip,
    ethUsdt,
    ethUsdc,
    dot,
    assetHubUsdc,
    assetHubUsdt,
    bticoin,
    arbEth,
    arbUsdc,
    sol,
    solUSDC,
    solUsdt,
    trx,
    trxUsdc
  ].immutable;

  static const ETHSwapAsset eth = ETHSwapAsset(
      symbol: "ETH",
      providerIdentifier: "ETH",
      decimal: 18,
      network: SwapConstants.ethereum,
      provider: SwapConstants.chainflip,
      logoUrl:
          "https://coin-images.coingecko.com/coins/images/279/large/ethereum.png?1696501628",
      coingeckoId: "ethereum",
      fullName: "Ethereum");
  static final ETHSwapAsset ethFlip = ETHSwapAsset(
      symbol: "FLIP",
      providerIdentifier: "FLIP",
      decimal: 18,
      network: SwapConstants.ethereum,
      provider: SwapConstants.chainflip,
      logoUrl:
          "https://coin-images.coingecko.com/coins/images/25576/large/kdt_AgmT_400x400.png?1696524709",
      coingeckoId: "SwapConstants.chainflip",
      contractAddress: ETHAddress("0x826180541412D574cf1336d22c0C0a287822678A"),
      fullName: "FLIP");
  static final ETHSwapAsset ethUsdt = ETHSwapAsset(
      symbol: "USDT",
      providerIdentifier: "USDT",
      decimal: 6,
      network: SwapConstants.ethereum,
      provider: SwapConstants.chainflip,
      contractAddress: ETHAddress("0xdAC17F958D2ee523a2206206994597C13D831ec7"),
      logoUrl:
          "https://coin-images.coingecko.com/coins/images/325/large/Tether.png?1696501661",
      coingeckoId: "tether",
      fullName: "Tether");

  static final ETHSwapAsset ethUsdc = ETHSwapAsset(
      symbol: "USDC",
      providerIdentifier: "USDC",
      decimal: 6,
      network: SwapConstants.ethereum,
      provider: SwapConstants.chainflip,
      logoUrl:
          "https://coin-images.coingecko.com/coins/images/6319/large/usdc.png?1696506694",
      coingeckoId: "usd-coin",
      contractAddress: ETHAddress("0xA0B86991C6218B36C1D19D4A2E9EB0CE3606EB48"),
      fullName: "USDC");
  static final PolkadotSwapAsset dot = PolkadotSwapAsset(
      symbol: "Dot",
      providerIdentifier: "DOT",
      decimal: 10,
      network: SwapConstants.assetHub,
      provider: SwapConstants.chainflip,
      logoUrl:
          "https://coin-images.coingecko.com/coins/images/12171/large/polkadot.png?1696512008",
      coingeckoId: "polkadot",
      fullName: "Polkadot");

  static final PolkadotSwapAsset assetHubUsdt = PolkadotSwapAsset(
      symbol: "USDT",
      providerIdentifier: "USDT",
      decimal: 6,
      network: SwapConstants.assetHub,
      provider: SwapConstants.chainflip,
      assetId: BigInt.from(1984),
      logoUrl:
          "https://coin-images.coingecko.com/coins/images/325/large/Tether.png?1696501661",
      coingeckoId: "tether",
      fullName: "Tether");

  static final PolkadotSwapAsset assetHubUsdc = PolkadotSwapAsset(
      symbol: "USDC",
      providerIdentifier: "USDC",
      decimal: 6,
      network: SwapConstants.assetHub,
      provider: SwapConstants.chainflip,
      assetId: BigInt.from(1337),
      logoUrl:
          "https://coin-images.coingecko.com/coins/images/6319/large/usdc.png?1696506694",
      coingeckoId: "usd-coin",
      fullName: "USDC");

  static const BitcoinSwapAsset bticoin = BitcoinSwapAsset(
      symbol: "BTC",
      providerIdentifier: "BTC",
      decimal: 8,
      network: SwapConstants.bitcoin,
      provider: SwapConstants.chainflip,
      logoUrl:
          "https://coin-images.coingecko.com/coins/images/1/large/bitcoin.png?1696501400",
      coingeckoId: "bitcoin",
      fullName: "Bitcoin");

  static const ETHSwapAsset arbEth = ETHSwapAsset(
      symbol: "ETH",
      providerIdentifier: "ETH",
      decimal: 18,
      network: SwapConstants.arbitrum,
      provider: SwapConstants.chainflip,
      logoUrl:
          "https://coin-images.coingecko.com/coins/images/279/large/ethereum.png?1696501628",
      coingeckoId: "ethereum",
      fullName: "Arbitrum ETH");
  static final ETHSwapAsset arbUsdc = ETHSwapAsset(
      symbol: "USDC",
      providerIdentifier: "USDC",
      decimal: 6,
      network: SwapConstants.arbitrum,
      provider: SwapConstants.chainflip,
      logoUrl:
          "https://coin-images.coingecko.com/coins/images/6319/large/usdc.png?1696506694",
      coingeckoId: "usd-coin",
      contractAddress: ETHAddress("0xAF88D065E77C8CC2239327C5EDB3A432268E5831"),
      fullName: "USDC");
  static const SolanaSwapAsset sol = SolanaSwapAsset(
      symbol: "SOL",
      providerIdentifier: "SOL",
      decimal: 9,
      network: SwapConstants.solana,
      provider: SwapConstants.chainflip,
      logoUrl:
          "https://coin-images.coingecko.com/coins/images/4128/large/solana.png?1718769756",
      coingeckoId: "solana",
      fullName: "Solana");
  static final SolanaSwapAsset solUSDC = SolanaSwapAsset(
      symbol: "USDC",
      providerIdentifier: "USDC",
      decimal: 6,
      network: SwapConstants.solana,
      provider: SwapConstants.chainflip,
      logoUrl:
          "https://coin-images.coingecko.com/coins/images/6319/large/usdc.png?1696506694",
      coingeckoId: null,
      contractAddress:
          SolAddress.uncheckCurve("EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v"),
      fullName: "USDC");
  static final SolanaSwapAsset solUsdt = SolanaSwapAsset(
      symbol: "USDT",
      providerIdentifier: "USDT",
      decimal: 6,
      network: SwapConstants.solana,
      provider: SwapConstants.chainflip,
      contractAddress:
          SolAddress.uncheckCurve("Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB"),
      logoUrl:
          "https://coin-images.coingecko.com/coins/images/325/large/Tether.png?1696501661",
      coingeckoId: "tether",
      fullName: "Tether");
  static const TronSwapAsset trx = TronSwapAsset(
      symbol: "TRX",
      providerIdentifier: "TRX",
      decimal: 6,
      network: SwapConstants.tron,
      provider: SwapConstants.chainflip,
      logoUrl:
          "https://coin-images.coingecko.com/coins/images/1094/large/photo_2026-04-13_09-59-16.png?1776048311",
      coingeckoId: "tron",
      fullName: "Trx");

  static final TronSwapAsset trxUsdc = TronSwapAsset(
      symbol: "USDT",
      providerIdentifier: "USDT",
      decimal: 6,
      network: SwapConstants.tron,
      provider: SwapConstants.chainflip,
      logoUrl:
          "https://coin-images.coingecko.com/coins/images/325/large/Tether.png?1696501661",
      coingeckoId: null,
      contractAddress: TronAddress("TR7NHqjeKQxGTCi8q8ZY4pL8otSzgjLj6t"),
      fullName: "USDT");
}

class CfTestnetSwapConstants {
  static const String mainnetChannelUrl = "https://scan.chainflip.io/channels/#id";
  static const String testnetChannelUrl =
      "https://scan.perseverance.chainflip.io/channels/#id";

  static final List<BaseSwapAsset> assets = <BaseSwapAsset>[
    eth,
    ethFlip,
    ethUsdt,
    ethUsdc,
    dot,
    bticoin,
    arbEth,
    arbUsdc,
    sol,
    solUSDC,
    assetHubUsdc,
    assetHubUsdt,
    trx,
    trxUsdc
  ].immutable;

  static const ETHSwapAsset eth = ETHSwapAsset(
      symbol: "ETH",
      providerIdentifier: "ETH",
      decimal: 18,
      network: SwapConstants.ethereumTestnet,
      provider: SwapConstants.chainflip,
      logoUrl:
          "https://coin-images.coingecko.com/coins/images/279/large/ethereum.png?1696501628",
      coingeckoId: "ethereum",
      fullName: "Ethereum");
  static final ETHSwapAsset ethFlip = ETHSwapAsset(
      symbol: "FLIP",
      providerIdentifier: "FLIP",
      decimal: 18,
      network: SwapConstants.ethereumTestnet,
      provider: SwapConstants.chainflip,
      logoUrl:
          "https://coin-images.coingecko.com/coins/images/25576/large/kdt_AgmT_400x400.png?1696524709",
      coingeckoId: "SwapConstants.chainflip",
      contractAddress: ETHAddress("0xdC27c60956cB065D19F08bb69a707E37b36d8086"),
      fullName: "FLIP");
  static final ETHSwapAsset ethUsdt = ETHSwapAsset(
      symbol: "USDT",
      providerIdentifier: "USDT",
      decimal: 6,
      network: SwapConstants.ethereumTestnet,
      provider: SwapConstants.chainflip,
      contractAddress: ETHAddress("0x27CEA6Eb8a21Aae05Eb29C91c5CA10592892F584"),
      logoUrl:
          "https://coin-images.coingecko.com/coins/images/325/large/Tether.png?1696501661",
      coingeckoId: "tether",
      fullName: "Tether");

  static final ETHSwapAsset ethUsdc = ETHSwapAsset(
      symbol: "USDC",
      providerIdentifier: "USDC",
      decimal: 6,
      network: SwapConstants.ethereumTestnet,
      provider: SwapConstants.chainflip,
      logoUrl:
          "https://coin-images.coingecko.com/coins/images/6319/large/usdc.png?1696506694",
      coingeckoId: "usd-coin",
      contractAddress: ETHAddress("0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238"),
      fullName: "USDC");
  static final PolkadotSwapAsset dot = PolkadotSwapAsset(
      symbol: "Dot",
      providerIdentifier: "DOT",
      decimal: 10,
      network: SwapConstants.assetHubTestnet,
      provider: SwapConstants.chainflip,
      logoUrl:
          "https://coin-images.coingecko.com/coins/images/12171/large/polkadot.png?1696512008",
      coingeckoId: "polkadot",
      fullName: "Polkadot");
  static const BitcoinSwapAsset bticoin = BitcoinSwapAsset(
      symbol: "BTC",
      providerIdentifier: "BTC",
      decimal: 8,
      network: SwapConstants.bitcoinTestnet,
      provider: SwapConstants.chainflip,
      logoUrl:
          "https://coin-images.coingecko.com/coins/images/1/large/bitcoin.png?1696501400",
      coingeckoId: "bitcoin",
      fullName: "Bitcoin");

  static const ETHSwapAsset arbEth = ETHSwapAsset(
      symbol: "ETH",
      providerIdentifier: "ETH",
      decimal: 18,
      network: SwapConstants.arbTestnet,
      provider: SwapConstants.chainflip,
      logoUrl:
          "https://coin-images.coingecko.com/coins/images/279/large/ethereum.png?1696501628",
      coingeckoId: "ethereum",
      fullName: "Arbitrum ETH");
  static final ETHSwapAsset arbUsdc = ETHSwapAsset(
      symbol: "USDC",
      providerIdentifier: "USDC",
      decimal: 6,
      network: SwapConstants.arbTestnet,
      provider: SwapConstants.chainflip,
      logoUrl:
          "https://coin-images.coingecko.com/coins/images/6319/large/usdc.png?1696506694",
      coingeckoId: "usd-coin",
      contractAddress: ETHAddress("0x75faf114eafb1BDbe2F0316DF893fd58CE46AA4d"),
      fullName: "USDC");
  static const SolanaSwapAsset sol = SolanaSwapAsset(
      symbol: "SOL",
      providerIdentifier: "SOL",
      decimal: 9,
      network: SwapConstants.solanaDevnet,
      provider: SwapConstants.chainflip,
      logoUrl:
          "https://coin-images.coingecko.com/coins/images/4128/large/solana.png?1718769756",
      coingeckoId: "solana",
      fullName: "Solana");
  static final SolanaSwapAsset solUSDC = SolanaSwapAsset(
      symbol: "USDC",
      providerIdentifier: "USDC",
      decimal: 6,
      network: SwapConstants.solanaDevnet,
      provider: SwapConstants.chainflip,
      logoUrl:
          "https://coin-images.coingecko.com/coins/images/6319/large/usdc.png?1696506694",
      coingeckoId: null,
      contractAddress:
          SolAddress.uncheckCurve("4zMMC9srt5Ri5X14GAgXhaHii3GnPAEERYPJgZJDncDU"),
      fullName: "USDC");
  static final SolanaSwapAsset solUsdt = SolanaSwapAsset(
      symbol: "USDT",
      providerIdentifier: "USDT",
      decimal: 6,
      network: SwapConstants.solanaDevnet,
      provider: SwapConstants.chainflip,
      contractAddress:
          SolAddress.uncheckCurve("FvuqJYh8YeEmarW5qkSrYeEgzaTKktgL3vhgBy2Csy4o"),
      logoUrl:
          "https://coin-images.coingecko.com/coins/images/325/large/Tether.png?1696501661",
      coingeckoId: "tether",
      fullName: "Tether");
  static final PolkadotSwapAsset assetHubUsdt = PolkadotSwapAsset(
      symbol: "USDT",
      providerIdentifier: "USDT",
      decimal: 6,
      network: SwapConstants.assetHubTestnet,
      provider: SwapConstants.chainflip,
      assetId: BigInt.from(1984),
      logoUrl:
          "https://coin-images.coingecko.com/coins/images/325/large/Tether.png?1696501661",
      coingeckoId: "tether",
      fullName: "Tether");

  static final PolkadotSwapAsset assetHubUsdc = PolkadotSwapAsset(
      symbol: "USDC",
      providerIdentifier: "USDC",
      decimal: 6,
      network: SwapConstants.assetHubTestnet,
      provider: SwapConstants.chainflip,
      assetId: BigInt.from(1337),
      logoUrl:
          "https://coin-images.coingecko.com/coins/images/6319/large/usdc.png?1696506694",
      coingeckoId: "usd-coin",
      fullName: "USDC");

  static const TronSwapAsset trx = TronSwapAsset(
      symbol: "TRX",
      providerIdentifier: "TRX",
      decimal: 6,
      network: SwapConstants.tronNile,
      provider: SwapConstants.chainflip,
      logoUrl:
          "https://coin-images.coingecko.com/coins/images/1094/large/photo_2026-04-13_09-59-16.png?1776048311",
      coingeckoId: "tron",
      fullName: "Trx");

  static final TronSwapAsset trxUsdc = TronSwapAsset(
      symbol: "USDT",
      providerIdentifier: "USDT",
      decimal: 6,
      network: SwapConstants.tronNile,
      provider: SwapConstants.chainflip,
      logoUrl:
          "https://coin-images.coingecko.com/coins/images/325/large/Tether.png?1696501661",
      coingeckoId: null,
      contractAddress: TronAddress("TXYZopYRdj2D9XRtbG411XZZ3kM5VkAeBf"),
      fullName: "USDT");
}
