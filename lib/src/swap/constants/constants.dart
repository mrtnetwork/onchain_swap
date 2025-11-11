import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:blockchain_utils/bip/bip/conf/core/coin_conf.dart';
import 'package:blockchain_utils/helper/extensions/extensions.dart';
import 'package:on_chain_swap/src/exception/exception.dart';
import 'package:on_chain_swap/src/swap/services/swap_kit/swap_kit/types.dart';
import 'package:on_chain_swap/src/swap/types/types.dart';
import 'package:polkadot_dart/polkadot_dart.dart';

class SwapConstants {
  static const routeExpiredException = DartOnChainSwapPluginException(
      "Swap route has expired and cannot be executed.");

  static const clientInitializationFailedException =
      DartOnChainSwapPluginException("Network client initialization failed.");

  static const insufficientAccountBalance =
      DartOnChainSwapPluginException("Insufficient account balance.");

  static const insufficientTokenBalance =
      DartOnChainSwapPluginException("Insufficient token balance.");

  static const List<SwapNetwork> networks = [
    arbitrum,
    bitcoin,
    ethereum,
    polkadot,
    solana,
    avalanche,
    base,
    bsc,
    bitcoinCash,
    dogecoin,
    litecoin,
    thorchain,
    dash,
    kujira,
    mayachain,
    gaia,
    // cosmos
  ];
  static const List<SwapServiceProvider> supportProviders = [
    chainflip,
    mayaProvider,
    thorchainProvider,
    oneInch
  ];
  static const List<SwapServiceProvider> testnetProviders = [chainflip];

  static const chainflip = SwapServiceProvider(
      name: "Chainflip Cross-Chain Swaps",
      identifier: "CHAINFLIP",
      logoUrl:
          "https://coin-images.coingecko.com/coins/images/25576/large/kdt_AgmT_400x400.png?1696524709",
      url: null,
      crossChain: true,
      service: SwapServiceType.chainFlip);
  static const mayaProvider = SwapServiceProvider(
      name: "MayaChain Cross-Chain Liquidity",
      identifier: "MAYACHAIN",
      logoUrl:
          "https://coin-images.coingecko.com/coins/images/29996/large/cacao.png?1696528920",
      url: null,
      crossChain: true,
      service: SwapServiceType.maya);
  static const skipGo = SwapServiceProvider(
      name: "Skip GO",
      identifier: "skip_go",
      logoUrl: null,
      url: null,
      crossChain: true,
      service: SwapServiceType.skipGo);
  static const thorchainProvider = SwapServiceProvider(
      name: "Thorchain Decentralized Liquidity",
      identifier: "THORCHAIN",
      logoUrl:
          "https://coin-images.coingecko.com/coins/images/6595/large/Rune200x200.png?1696506946",
      url: null,
      crossChain: true,
      service: SwapServiceType.thor);
  static const oneInch = SwapKitSwapServiceProvider(
      name: "1inch Aggregator",
      identifier: "ONEINCH",
      logoUrl:
          "https://coin-images.coingecko.com/coins/images/13469/large/1inch-token.png?1696513230",
      url: null,
      crossChain: false);

  static const arbitrum = SwapEthereumNetwork(
      name: "Arbitrum",
      identifier: "42161",
      explorerTxUrl: "https://arbiscan.io/tx/#txid",
      explorerAddressUrl: "https://arbiscan.io/address/#address",
      logoUrl:
          "https://coin-images.coingecko.com/coins/images/16547/large/arb.jpg?1721358242");

  static const bitcoin = SwapBitcoinNetwork(
      name: "Bitcoin",
      identifier: "bitcoin",
      chain: BitcoinNetwork.mainnet,
      explorerTxUrl: "https://live.blockcypher.com/btc/tx/#txid/",
      explorerAddressUrl: "https://live.blockcypher.com/btc/address/#address/",
      genesis:
          "000000000019d6689c085ae165831e934ff763ae46a2a6c172b3f1b60a8ce26f",
      logoUrl:
          "https://coin-images.coingecko.com/coins/images/1/large/bitcoin.png?1696501400");

  static const ethereum = SwapEthereumNetwork(
      name: "Ethereum",
      identifier: "1",
      explorerTxUrl: "https://etherscan.io/tx/#txid",
      explorerAddressUrl: "https://etherscan.io/address/#address",
      logoUrl:
          "https://coin-images.coingecko.com/coins/images/279/large/ethereum.png?1696501628");

  static const polkadot = SwapSubstrateNetwork(
      name: "Polkadot",
      identifier: "polkadot",
      explorerAddressUrl: "https://polkadot.subscan.io/account/#address",
      explorerTxUrl: "https://polkadot.subscan.io/extrinsic/#txid",
      ss58Format: SS58Const.polkadot,
      genesis:
          "91b171bb158e2d3848fa23a9f1c25182fb8e20313b2c1eb49219da7a70ce90c3",
      logoUrl:
          "https://coin-images.coingecko.com/coins/images/12171/large/polkadot.png?1696512008");

  static const solana = SwapSolanaNetwork(
      name: "Solana",
      identifier: "solana",
      genesis: "5eykt4UsFv8P8NJdTREpY1vzqKqZKvdpKuc147dw2N9d",
      explorerTxUrl: "https://explorer.solana.com/tx/#txid",
      explorerAddressUrl: "https://explorer.solana.com/address/#address",
      logoUrl:
          "https://coin-images.coingecko.com/coins/images/4128/large/solana.png?1718769756");

  static const avalanche = SwapEthereumNetwork(
      name: "Avalanche C-Chain",
      identifier: "43114",
      explorerTxUrl: "https://subnets.avax.network/c-chain/tx/#txid",
      explorerAddressUrl:
          "https://subnets.avax.network/c-chain/address/#address",
      logoUrl:
          "https://coin-images.coingecko.com/coins/images/12559/large/Avalanche_Circle_RedWhite_Trans.png?1696512369");

  static const base = SwapEthereumNetwork(
    name: "Base",
    identifier: "8453",
    logoUrl: null,
    explorerTxUrl: "https://basescan.org/tx/#txid",
    explorerAddressUrl: "https://basescan.org/address/#address",
  );

  static const bsc = SwapEthereumNetwork(
      name: "Binance Smart Chain",
      identifier: "56",
      explorerTxUrl: "https://bscscan.com/tx/#txid",
      explorerAddressUrl: "https://bscscan.com/address/#address",
      logoUrl:
          "https://coin-images.coingecko.com/coins/images/825/large/bnb-icon2_2x.png?1696501970");

  static const bitcoinCash = SwapBitcoinNetwork(
      name: "Bitcoin Cash",
      identifier: "bitcoincash",
      chain: BitcoinCashNetwork.mainnet,
      explorerAddressUrl: "https://bch.loping.net/address/#address",
      explorerTxUrl: "https://bch.loping.net/tx/#txid",
      genesis:
          "000000000019d6689c085ae165831e934ff763ae46a2a6c172b3f1b60a8ce26f",
      logoUrl:
          "https://coin-images.coingecko.com/coins/images/780/large/bitcoin-cash-circle.png?1696501932");

  static const kujira = SwapCosmosNetwork(
    name: "Kujira",
    identifier: "kaiyo-1",
    bech32: "kujira",
    explorerAddressUrl:
        "https://finder.kujira.network/kaiyo-1/address/#address",
    explorerTxUrl: "https://finder.kujira.network/kaiyo-1/tx/#txid",
    logoUrl:
        "https://coin-images.coingecko.com/coins/images/20685/large/kuji-200x200.png?1696520085",
  );

  static const gaia = SwapCosmosNetwork(
      name: "GAIA",
      identifier: "cosmoshub-4",
      explorerTxUrl: "https://ping.pub/cosmos/tx/#txid",
      explorerAddressUrl: "https://ping.pub/cosmos/account/#address",
      bech32: "cosmos",
      logoUrl:
          "https://coin-images.coingecko.com/coins/images/1481/large/cosmos_hub.png?1696502525");
  static const dogecoin = SwapBitcoinNetwork(
      name: "Dogecoin",
      identifier: "dogecoin",
      chain: DogecoinNetwork.mainnet,
      explorerTxUrl: "https://live.blockcypher.com/doge/tx/#txid/",
      explorerAddressUrl: "https://live.blockcypher.com/doge/address/#address/",
      genesis:
          "1a91e3dace36e2be3bf030a65679fe821aa1d6ef92e7c9902eb318182c355691",
      logoUrl:
          "https://coin-images.coingecko.com/coins/images/5/large/dogecoin.png?1696501409");

  static const litecoin = SwapBitcoinNetwork(
      name: "Litecoin",
      identifier: "litecoin",
      chain: LitecoinNetwork.mainnet,
      explorerTxUrl: "https://live.blockcypher.com/ltc/tx/#txid/",
      explorerAddressUrl: "https://live.blockcypher.com/ltc/address/#address/",
      genesis:
          "12a765e31ffd4059bada1e25190f6e98c99d9714d334efa41a195a7e7e04bfe2",
      logoUrl:
          "https://coin-images.coingecko.com/coins/images/2/large/litecoin.png?1696501400");

  static const thorchain = SwapCosmosNetwork(
      name: "Thorchain",
      identifier: "thorchain-1",
      explorerAddressUrl: "https://www.thorscanner.org/address/#address",
      explorerTxUrl: "https://www.thorscanner.org/tx/#txid",
      bech32: "thor",
      logoUrl: null);

  static const dash = SwapBitcoinNetwork(
      name: "Dash",
      identifier: "dash",
      chain: DashNetwork.mainnet,
      explorerTxUrl: "https://live.blockcypher.com/dash/tx/#txid/",
      explorerAddressUrl: "https://live.blockcypher.com/dash/address/#address/",
      genesis:
          "00000ffd590b1485b3caadc19b22e6379c733355108f107a430458cdf3407ab6",
      logoUrl:
          "https://coin-images.coingecko.com/coins/images/19/large/dash-logo.png?1696501423");

  static const mayachain = SwapCosmosNetwork(
      name: "MayaChain",
      identifier: "mayachain-mainnet-v1",
      explorerTxUrl: "https://www.mayascan.org/tx/#txid",
      explorerAddressUrl: "https://www.mayascan.org/address/#address",
      bech32: "maya",
      logoUrl: null);

  static SwapServiceProvider? findProvider(String provider) {
    return supportProviders.firstWhereNullable((e) => e.identifier == provider);
  }

  static const ethereumTestnet = SwapEthereumNetwork(
      name: "Ethereum",
      identifier: "11155111",
      explorerTxUrl: "https://etherscan.io/tx/#txid",
      explorerAddressUrl: "https://etherscan.io/address/#address",
      chainType: ChainType.testnet,
      logoUrl:
          "https://coin-images.coingecko.com/coins/images/279/large/ethereum.png?1696501628");
  static const arbTestnet = SwapEthereumNetwork(
      name: "Arbitrum",
      identifier: "421614",
      explorerTxUrl: "https://arbiscan.io/tx/#txid",
      explorerAddressUrl: "https://arbiscan.io/address/#address",
      chainType: ChainType.testnet,
      logoUrl:
          "https://coin-images.coingecko.com/coins/images/16547/large/arb.jpg?1721358242");
  static const solanaDevnet = SwapSolanaNetwork(
      name: "Solana",
      identifier: "solana",
      genesis: "EtWTRABZaYq6iMfeYKouRu166VU2xqa1wcaWoxPkrZBG",
      // chain: SolanaChainType.testnet,
      explorerTxUrl: "https://explorer.solana.com/tx/#txid",
      explorerAddressUrl: "https://explorer.solana.com/address/#address",
      chainType: ChainType.testnet,
      logoUrl:
          "https://coin-images.coingecko.com/coins/images/4128/large/solana.png?1718769756");

  static const bitcoinTestnet = SwapBitcoinNetwork(
      name: "Bitcoin",
      identifier: "bitcoin",
      chain: BitcoinNetwork.testnet,
      explorerTxUrl: "https://live.blockcypher.com/btc/tx/#txid/",
      explorerAddressUrl: "https://live.blockcypher.com/btc/address/#address/",
      genesis:
          "000000000933ea01ad0ee984209779baaec3ced90fa3f408719526f8d77f4943",
      chainType: ChainType.testnet,
      logoUrl:
          "https://coin-images.coingecko.com/coins/images/1/large/bitcoin.png?1696501400");

  // static const polkadotTestnetChainFlip = SwapSubstrateNetwork(
  //     name: "Polkadot",
  //     identifier: "polkadot",
  //     explorerAddressUrl: "https://polkadot.subscan.io/account/#address",
  //     explorerTxUrl: "https://polkadot.subscan.io/extrinsic/#txid",
  //     ss58Format: SS58Const.polkadot,
  //     chainType: ChainType.testnet,
  //     genesis:
  //         "e566d149729892a803c3c4b1e652f09445926234d956a0f166be4d4dea91f536",
  //     logoUrl:
  //         "https://coin-images.coingecko.com/coins/images/12171/large/polkadot.png?1696512008");

  static const assetHubTestnet = SwapSubstrateNetwork(
      name: "Assethub",
      identifier: "assethub",
      explorerAddressUrl: "https://polkadot.subscan.io/account/#address",
      explorerTxUrl: "https://polkadot.subscan.io/extrinsic/#txid",
      ss58Format: SS58Const.polkadot,
      chainType: ChainType.testnet,
      genesis:
          "4fb7a1b11ba4a38827cf211b3effc87971413e4a9fd79c6bcc2c633383496832",
      logoUrl:
          "https://coin-images.coingecko.com/coins/images/12171/large/polkadot.png?1696512008");
  static const assetHub = SwapSubstrateNetwork(
      name: "Assethub",
      identifier: "assethub",
      explorerAddressUrl:
          "https://polkadot.js.org/apps/?rpc=wss://assethub.perseverance.chainflip.io",
      explorerTxUrl:
          "https://polkadot.js.org/apps/?rpc=wss://assethub.perseverance.chainflip.io",
      ss58Format: SS58Const.polkadot,
      genesis:
          "68d56f15f85d3136970ec16946040bc1752654e906147f7e43e9d539d7c3de2f",
      logoUrl:
          "https://coin-images.coingecko.com/coins/images/12171/large/polkadot.png?1696512008");
}
