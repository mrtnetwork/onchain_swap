import 'package:on_chain/on_chain.dart';
import 'package:on_chain_swap/src/swap/constants/constants.dart';
import 'package:on_chain_swap/src/swap/types/types.dart';

class MayaSwapConstants {
  static final List<BaseSwapAsset> assets = [
    arbArb,
    arbDai,
    arbEth,
    arbGld,
    arbLeo,
    arbLink,
    arbPepe,
    arbTgt,
    arbUsdc,
    arbUsdt,
    arbWbtc,
    arbWsteth,
    arbYum,
    btcBtc,
    dashDash,
    ethEth,
    ethPepe,
    ethUsdc,
    ethUsdt,
    ethWsteth,
    // kujiKuji,
    // kujiUsk,
    // thorRune,
    ada,
    zcash,
    // maya,
    ethMoca
  ];

  static final ETHSwapAsset arbArb = ETHSwapAsset(
      symbol: "ARB",
      providerIdentifier: "ARB.ARB-0X912CE59144191C1204E64559FE8253A0E49E6548",
      decimal: 18,
      network: SwapConstants.arbitrum,
      provider: SwapConstants.mayaProvider,
      logoUrl:
          "https://coin-images.coingecko.com/coins/images/16547/large/arb.jpg?1721358242",
      coingeckoId: "arbitrum",
      contractAddress: ETHAddress("0x912CE59144191C1204E64559FE8253A0E49E6548"),
      fullName: "Arbitrum");
  static final ETHSwapAsset arbDai = ETHSwapAsset(
      symbol: "DAI",
      providerIdentifier: "ARB.DAI-0XDA10009CBD5D07DD0CECC66161FC93D7C9000DA1",
      decimal: 18,
      network: SwapConstants.arbitrum,
      provider: SwapConstants.mayaProvider,
      logoUrl:
          "https://coin-images.coingecko.com/coins/images/39790/large/dai.png?1724111653",
      coingeckoId: "makerdao-arbitrum-bridged-dai-arbitrum-one",
      contractAddress: ETHAddress("0xDA10009CBD5D07DD0CECC66161FC93D7C9000DA1"),
      fullName: "MakerDAO Arbitrum Bridged DAI (Arbitrum One)");
  static const ETHSwapAsset arbEth = ETHSwapAsset(
      symbol: "ETH",
      providerIdentifier: "ARB.ETH",
      decimal: 18,
      network: SwapConstants.arbitrum,
      provider: SwapConstants.mayaProvider,
      logoUrl:
          "https://coin-images.coingecko.com/coins/images/279/large/ethereum.png?1696501628",
      coingeckoId: "ethereum",
      fullName: "Ethereum");
  static final ETHSwapAsset arbGld = ETHSwapAsset(
      symbol: "GLD",
      providerIdentifier: "ARB.GLD-0XAFD091F140C21770F4E5D53D26B2859AE97555AA",
      decimal: 18,
      network: SwapConstants.arbitrum,
      provider: SwapConstants.mayaProvider,
      logoUrl: null,
      coingeckoId: null,
      contractAddress: ETHAddress("0xAFD091F140C21770F4E5D53D26B2859AE97555AA"),
      fullName: "Mayan Gold");
  static final ETHSwapAsset arbLeo = ETHSwapAsset(
      symbol: "LEO",
      providerIdentifier: "ARB.LEO-0X93864D81175095DD93360FFA2A529B8642F76A6E",
      decimal: 3,
      network: SwapConstants.arbitrum,
      provider: SwapConstants.mayaProvider,
      logoUrl: null,
      coingeckoId: null,
      contractAddress: ETHAddress("0x93864D81175095DD93360FFA2A529B8642F76A6E"),
      fullName: "Leo");
  static final ETHSwapAsset arbLink = ETHSwapAsset(
      symbol: "LINK",
      providerIdentifier: "ARB.LINK-0XF97F4DF75117A78C1A5A0DBB814AF92458539FB4",
      decimal: 18,
      network: SwapConstants.arbitrum,
      provider: SwapConstants.mayaProvider,
      logoUrl:
          "https://coin-images.coingecko.com/coins/images/877/large/chainlink-new-logo.png?1696502009",
      coingeckoId: "chainlink",
      contractAddress: ETHAddress("0xF97F4DF75117A78C1A5A0DBB814AF92458539FB4"),
      fullName: "Chainlink");
  static final ETHSwapAsset arbPepe = ETHSwapAsset(
      symbol: "PEPE",
      providerIdentifier: "ARB.PEPE-0X25D887CE7A35172C62FEBFD67A1856F20FAEBB00",
      decimal: 18,
      network: SwapConstants.arbitrum,
      provider: SwapConstants.mayaProvider,
      logoUrl:
          "https://coin-images.coingecko.com/coins/images/29850/large/pepe-token.jpeg?1696528776",
      coingeckoId: "pepe",
      contractAddress: ETHAddress("0x25D887CE7A35172C62FEBFD67A1856F20FAEBB00"),
      fullName: "Pepe");
  static final ETHSwapAsset arbTgt = ETHSwapAsset(
      symbol: "TGT",
      providerIdentifier: "ARB.TGT-0X429FED88F10285E61B12BDF00848315FBDFCC341",
      decimal: 18,
      network: SwapConstants.arbitrum,
      provider: SwapConstants.mayaProvider,
      logoUrl:
          "https://coin-images.coingecko.com/coins/images/21843/large/tgt_logo.png?1696521198",
      coingeckoId: "thorwallet",
      contractAddress: ETHAddress("0x429FED88F10285E61B12BDF00848315FBDFCC341"),
      fullName: "THORWallet DEX");
  static final ETHSwapAsset arbUsdc = ETHSwapAsset(
      symbol: "USDC",
      providerIdentifier: "ARB.USDC-0XAF88D065E77C8CC2239327C5EDB3A432268E5831",
      decimal: 6,
      network: SwapConstants.arbitrum,
      provider: SwapConstants.mayaProvider,
      logoUrl:
          "https://coin-images.coingecko.com/coins/images/6319/large/usdc.png?1696506694",
      coingeckoId: "usd-coin",
      contractAddress: ETHAddress("0xAF88D065E77C8CC2239327C5EDB3A432268E5831"),
      fullName: "USDC");
  static final ETHSwapAsset arbUsdt = ETHSwapAsset(
      symbol: "USDT",
      providerIdentifier: "ARB.USDT-0XFD086BC7CD5C481DCC9C85EBE478A1C0B69FCBB9",
      decimal: 6,
      network: SwapConstants.arbitrum,
      provider: SwapConstants.mayaProvider,
      logoUrl:
          "https://coin-images.coingecko.com/coins/images/35073/large/logo.png?1707292836",
      coingeckoId: "arbitrum-bridged-usdt-arbitrum",
      contractAddress: ETHAddress("0xFD086BC7CD5C481DCC9C85EBE478A1C0B69FCBB9"),
      fullName: "Arbitrum Bridged USDT (Arbitrum)");
  static final ETHSwapAsset arbWbtc = ETHSwapAsset(
      symbol: "WBTC",
      providerIdentifier: "ARB.WBTC-0X2F2A2543B76A4166549F7AAB2E75BEF0AEFC5B0F",
      decimal: 18,
      network: SwapConstants.arbitrum,
      provider: SwapConstants.mayaProvider,
      logoUrl:
          "https://coin-images.coingecko.com/coins/images/39532/large/wbtc.png?1722810336",
      coingeckoId: "arbitrum-bridged-wbtc-arbitrum-one",
      contractAddress: ETHAddress("0x2F2A2543B76A4166549F7AAB2E75BEF0AEFC5B0F"),
      fullName: "Arbitrum Bridged WBTC (Arbitrum One)");
  static final ETHSwapAsset arbWsteth = ETHSwapAsset(
      symbol: "WSTETH",
      providerIdentifier: "ARB.WSTETH-0X5979D7B546E38E414F7E9822514BE443A4800529",
      decimal: 18,
      network: SwapConstants.arbitrum,
      provider: SwapConstants.mayaProvider,
      logoUrl:
          "https://coin-images.coingecko.com/coins/images/53102/large/arbitrum-bridged-wsteth-arbitrum.webp?1735227527",
      coingeckoId: "arbitrum-bridged-wsteth-arbitrum",
      contractAddress: ETHAddress("0x5979D7B546E38E414F7E9822514BE443A4800529"),
      fullName: "Arbitrum Bridged wstETH (Arbitrum)");
  static final ETHSwapAsset arbYum = ETHSwapAsset(
      symbol: "YUM",
      providerIdentifier: "ARB.YUM-0X9F41B34F42058A7B74672055A5FAE22C4B113FD1",
      decimal: 18,
      network: SwapConstants.arbitrum,
      provider: SwapConstants.mayaProvider,
      logoUrl:
          "https://coin-images.coingecko.com/coins/images/39116/large/yum.png?1720590184",
      coingeckoId: "yum",
      contractAddress: ETHAddress("0x9F41B34F42058A7B74672055A5FAE22C4B113FD1"),
      fullName: "Yum");
  static const BitcoinSwapAsset btcBtc = BitcoinSwapAsset(
      symbol: "BTC",
      providerIdentifier: "BTC.BTC",
      decimal: 8,
      network: SwapConstants.bitcoin,
      provider: SwapConstants.mayaProvider,
      logoUrl:
          "https://coin-images.coingecko.com/coins/images/1/large/bitcoin.png?1696501400",
      coingeckoId: "bitcoin",
      fullName: "Bitcoin");
  static const BitcoinSwapAsset dashDash = BitcoinSwapAsset(
      symbol: "DASH",
      providerIdentifier: "DASH.DASH",
      decimal: 8,
      network: SwapConstants.dash,
      provider: SwapConstants.mayaProvider,
      logoUrl:
          "https://coin-images.coingecko.com/coins/images/19/large/dash-logo.png?1696501423",
      coingeckoId: "dash",
      fullName: "Dash");
  static const ETHSwapAsset ethEth = ETHSwapAsset(
      symbol: "ETH",
      providerIdentifier: "ETH.ETH",
      decimal: 18,
      network: SwapConstants.ethereum,
      provider: SwapConstants.mayaProvider,
      logoUrl:
          "https://coin-images.coingecko.com/coins/images/279/large/ethereum.png?1696501628",
      coingeckoId: "ethereum",
      fullName: "Ethereum");
  static final ETHSwapAsset ethPepe = ETHSwapAsset(
      symbol: "PEPE",
      providerIdentifier: "ETH.PEPE-0x6982508145454CE325DDBE47A25D4EC3D2311933",
      decimal: 18,
      network: SwapConstants.ethereum,
      provider: SwapConstants.mayaProvider,
      logoUrl:
          "https://coin-images.coingecko.com/coins/images/29850/large/pepe-token.jpeg?1696528776",
      coingeckoId: "pepe",
      contractAddress: ETHAddress("0x6982508145454CE325DDBE47A25D4EC3D2311933"),
      fullName: "Pepe");
  static final ETHSwapAsset ethUsdc = ETHSwapAsset(
      symbol: "USDC",
      providerIdentifier: "ETH.USDC-0XA0B86991C6218B36C1D19D4A2E9EB0CE3606EB48",
      decimal: 6,
      network: SwapConstants.ethereum,
      provider: SwapConstants.mayaProvider,
      logoUrl:
          "https://coin-images.coingecko.com/coins/images/6319/large/usdc.png?1696506694",
      coingeckoId: "usd-coin",
      contractAddress: ETHAddress("0xA0B86991C6218B36C1D19D4A2E9EB0CE3606EB48"),
      fullName: "USDC");
  static final ETHSwapAsset ethUsdt = ETHSwapAsset(
      symbol: "USDT",
      providerIdentifier: "ETH.USDT-0XDAC17F958D2EE523A2206206994597C13D831EC7",
      decimal: 6,
      network: SwapConstants.ethereum,
      provider: SwapConstants.mayaProvider,
      logoUrl:
          "https://coin-images.coingecko.com/coins/images/325/large/Tether.png?1696501661",
      coingeckoId: "tether",
      contractAddress: ETHAddress("0xDAC17F958D2EE523A2206206994597C13D831EC7"),
      fullName: "Tether");
  static final ETHSwapAsset ethWsteth = ETHSwapAsset(
      symbol: "WSTETH",
      providerIdentifier: "ETH.WSTETH-0X7F39C581F595B53C5CB19BD0B3F8DA6C935E2CA0",
      decimal: 18,
      network: SwapConstants.ethereum,
      provider: SwapConstants.mayaProvider,
      logoUrl:
          "https://coin-images.coingecko.com/coins/images/18834/large/wstETH.png?1696518295",
      coingeckoId: "wrapped-steth",
      contractAddress: ETHAddress("0x7F39C581F595B53C5CB19BD0B3F8DA6C935E2CA0"),
      fullName: "Wrapped stETH");
  // static const CosmosSwapAsset kujiKuji = CosmosSwapAsset(
  //     symbol: "KUJI",
  //     providerIdentifier: "KUJI.KUJI",
  //     baseDenom: 'ukuji',
  //     network: SwapConstants.kujira,
  //     provider: SwapConstants.mayaProvider,
  //     logoUrl:
  //         "https://coin-images.coingecko.com/coins/images/20685/large/kuji-200x200.png?1696520085",
  //     coingeckoId: "kujira",
  //     fullName: "Kujira");
  // static const CosmosSwapAsset kujiUsk = CosmosSwapAsset(
  //     symbol: "USK",
  //     providerIdentifier: "KUJI.USK",
  //     network: SwapConstants.kujira,
  //     baseDenom:
  //         "factory/kujira1qk00h5atutpsv900x202pxx42npjr9thg58dnqpa72f2p7m2luase444a7/uusk",
  //     provider: SwapConstants.mayaProvider,
  //     logoUrl:
  //         "https://coin-images.coingecko.com/coins/images/27274/large/usk.png?1696526326",
  //     coingeckoId: "usk",
  //     fullName: "USK");
  // static const CosmosSwapAsset thorRune = CosmosSwapAsset(
  //     symbol: "RUNE",
  //     providerIdentifier: "THOR.RUNE",
  //     network: SwapConstants.thorchain,
  //     baseDenom: "rune",
  //     provider: SwapConstants.mayaProvider,
  //     logoUrl:
  //         "https://coin-images.coingecko.com/coins/images/6595/large/Rune200x200.png?1696506946",
  //     coingeckoId: "thorchain",
  //     fullName: "THORChain");

  static const AdaSwapAsset ada = AdaSwapAsset(
      symbol: "ADA",
      providerIdentifier: "ADA.ADA",
      decimal: 6,
      network: SwapConstants.ada,
      provider: SwapConstants.mayaProvider,
      logoUrl:
          "https://coin-images.coingecko.com/coins/images/975/large/cardano.png?1696502090",
      coingeckoId: "cardano",
      fullName: "Cardano");

  static const ZcashSwapAsset zcash = ZcashSwapAsset(
      symbol: "Zec",
      providerIdentifier: "ZEC.ZEC",
      decimal: 8,
      network: SwapConstants.zcash,
      provider: SwapConstants.mayaProvider,
      logoUrl:
          "https://coin-images.coingecko.com/coins/images/486/large/circle-zcash-color.png?1696501740",
      coingeckoId: "zcash",
      fullName: "Zcash");

  // static const CosmosSwapAsset maya = CosmosSwapAsset(
  //     symbol: "MAYA",
  //     providerIdentifier: "MAYA.MAYA",
  //     network: SwapConstants.mayachain,
  //     baseDenom: "maya",
  //     provider: SwapConstants.mayaProvider,
  //     logoUrl:
  //         "https://raw.githubusercontent.com/cosmos/chain-registry/master/mayachain/images/maya.png",
  //     fullName: "MAYA");

  static final ETHSwapAsset ethMoca = ETHSwapAsset(
      symbol: "MOCA",
      providerIdentifier: "ETH.MOCA-0X53312F85BBA24C8CB99CFFC13BF82420157230D3",
      decimal: 18,
      network: SwapConstants.ethereum,
      provider: SwapConstants.mayaProvider,
      logoUrl: null,
      contractAddress: ETHAddress("0x53312F85Bba24C8cb99CFFc13BF82420157230d3"),
      fullName: "Moca");
}

// class MayaTestnetSwapConstants {
//   static const AdaSwapAsset ada = AdaSwapAsset(
//       symbol: "ADA",
//       providerIdentifier: "ADA.ADA",
//       decimal: 6,
//       network: SwapConstants.adaTestnet,
//       provider: SwapConstants.mayaProvider,
//       logoUrl:
//           "https://coin-images.coingecko.com/coins/images/975/large/cardano.png?1696502090",
//       coingeckoId: "cardano",
//       fullName: "Cardano");

//   static const AdaSwapAsset zcash = AdaSwapAsset(
//       symbol: "Zec",
//       providerIdentifier: "ZEC.ZEC",
//       decimal: 8,
//       network: SwapConstants.zcashTestnet,
//       provider: SwapConstants.mayaProvider,
//       logoUrl:
//           "https://coin-images.coingecko.com/coins/images/486/large/circle-zcash-color.png?1696501740",
//       coingeckoId: "zcash",
//       fullName: "Zcash");

//   static const CosmosSwapAsset maya = CosmosSwapAsset(
//       symbol: "MAYA",
//       providerIdentifier: "MAYA.MAYA",
//       decimal: 4,
//       network: SwapConstants.mayaStagenet,
//       denom: "maya",
//       provider: SwapConstants.mayaProvider,
//       logoUrl:
//           "https://raw.githubusercontent.com/cosmos/chain-registry/master/mayachain/images/maya.png",
//       fullName: "MAYA");
// }
