import 'package:blockchain_utils/helper/extensions/extensions.dart';
import 'package:on_chain/on_chain.dart';
import 'package:on_chain_swap/src/swap/constants/constants.dart';
import 'package:on_chain_swap/src/swap/types/types.dart';

class ThorSwapConstants {
  static final AbiFunctionFragment depositWithExpiry = AbiFunctionFragment.fromJson(
    {
      "inputs": [
        {"internalType": "address payable", "name": "vault", "type": "address"},
        {"internalType": "address", "name": "asset", "type": "address"},
        {"internalType": "uint256", "name": "amount", "type": "uint256"},
        {"internalType": "string", "name": "memo", "type": "string"},
        {"internalType": "uint256", "name": "expiration", "type": "uint256"}
      ],
      "name": "depositWithExpiry",
      "outputs": [],
      "stateMutability": "payable",
      "type": "function"
    },
  );
  static final List<BaseSwapAsset> assets = <BaseSwapAsset>[
    avaxAvax,
    avaxSol,
    avaxUsdc,
    avaxUsdt,
    baseCbbtc,
    baseEth,
    baseUsdc,
    bchBch,
    bscBnb,
    bscTwt,
    bscUsdc,
    bscUsdt,
    btcBtc,
    dogeDoge,
    ethAave,
    ethDai,
    ethDpi,
    ethEth,
    ethFox,
    ethGusd,
    ethLink,
    ethLusd,
    ethSnx,
    ethTgt,
    ethThor,
    ethUsdc,
    ethUsdp,
    ethUsdt,
    ethVthor,
    ethWbtc,
    ethXrune,
    ethYfi,
    // gaiaAtom,
    ltcLtc,
    solSol,
    trx,
    trxUsdc,
    xrp,
    bscBtcb,
    bscBusd,
    bscEth,
    baseVVV,
    // thorRuji,
    // thorTcy,
  ].immutable;

  static const ETHSwapAsset avaxAvax = ETHSwapAsset(
      symbol: "AVAX",
      providerIdentifier: "AVAX.AVAX",
      decimal: 18,
      network: SwapConstants.avalanche,
      provider: SwapConstants.thorchainProvider,
      logoUrl:
          "https://coin-images.coingecko.com/coins/images/12559/large/Avalanche_Circle_RedWhite_Trans.png?1696512369",
      coingeckoId: "avalanche-2",
      fullName: "Avalanche");

  /// aprove
  static final ETHSwapAsset avaxSol = ETHSwapAsset(
      symbol: "SOL",
      providerIdentifier: "AVAX.SOL-0XFE6B19286885A4F7F55ADAD09C3CD1F906D2478F",
      decimal: 9,
      network: SwapConstants.avalanche,
      provider: SwapConstants.thorchainProvider,
      logoUrl:
          "https://coin-images.coingecko.com/coins/images/22876/large/SOL_wh_small.png?1696522175",
      coingeckoId: "sol-wormhole",
      contractAddress: ETHAddress("0xFE6B19286885A4F7F55ADAD09C3CD1F906D2478F"),
      fullName: "SOL (Wormhole)");

  /// prove
  static final ETHSwapAsset avaxUsdc = ETHSwapAsset(
      symbol: "USDC",
      providerIdentifier: "AVAX.USDC-0XB97EF9EF8734C71904D8002F8B6BC66DD9C48A6E",
      decimal: 6,
      network: SwapConstants.avalanche,
      provider: SwapConstants.thorchainProvider,
      logoUrl:
          "https://coin-images.coingecko.com/coins/images/6319/large/usdc.png?1696506694",
      coingeckoId: "usd-coin",
      contractAddress: ETHAddress("0xB97EF9Ef8734C71904D8002F8B6BC66DD9C48A6E"),
      fullName: "USDC");

  /// prove
  static final ETHSwapAsset avaxUsdt = ETHSwapAsset(
      symbol: "USDT",
      providerIdentifier: "AVAX.USDT-0X9702230A8EA53601F5CD2DC00FDBC13D4DF4A8C7",
      decimal: 6,
      network: SwapConstants.avalanche,
      provider: SwapConstants.thorchainProvider,
      logoUrl:
          "https://coin-images.coingecko.com/coins/images/325/large/Tether.png?1696501661",
      coingeckoId: "tether",
      contractAddress: ETHAddress("0x9702230A8EA53601F5CD2DC00FDBC13D4DF4A8C7"),
      fullName: "Tether");

  /// aprove
  static final ETHSwapAsset baseCbbtc = ETHSwapAsset(
      symbol: "CBBTC",
      providerIdentifier: "BASE.CBBTC-0XCBB7C0000AB88B473B1F5AFD9EF808440EED33BF",
      decimal: 8,
      network: SwapConstants.base,
      provider: SwapConstants.thorchainProvider,
      logoUrl:
          "https://coin-images.coingecko.com/coins/images/40143/large/cbbtc.webp?1726136727",
      coingeckoId: "coinbase-wrapped-btc",
      contractAddress: ETHAddress("0xCBB7C0000AB88B473B1F5AFD9EF808440EED33BF"),
      fullName: "Coinbase Wrapped BTC");
  static const ETHSwapAsset baseEth = ETHSwapAsset(
      symbol: "ETH",
      providerIdentifier: "BASE.ETH",
      decimal: 18,
      network: SwapConstants.base,
      provider: SwapConstants.thorchainProvider,
      logoUrl:
          "https://coin-images.coingecko.com/coins/images/279/large/ethereum.png?1696501628",
      coingeckoId: "ethereum",
      fullName: "Ethereum");

  /// aprove
  static final ETHSwapAsset baseUsdc = ETHSwapAsset(
      symbol: "USDC",
      providerIdentifier: "BASE.USDC-0X833589FCD6EDB6E08F4C7C32D4F71B54BDA02913",
      decimal: 6,
      network: SwapConstants.base,
      provider: SwapConstants.thorchainProvider,
      logoUrl:
          "https://coin-images.coingecko.com/coins/images/6319/large/usdc.png?1696506694",
      coingeckoId: "usd-coin",
      contractAddress: ETHAddress("0x833589FCD6EDB6E08F4C7C32D4F71B54BDA02913"),
      fullName: "USDC");
  static const BitcoinSwapAsset bchBch = BitcoinSwapAsset(
      symbol: "BCH",
      providerIdentifier: "BCH.BCH",
      decimal: 8,
      network: SwapConstants.bitcoinCash,
      provider: SwapConstants.thorchainProvider,
      logoUrl:
          "https://coin-images.coingecko.com/coins/images/780/large/bitcoin-cash-circle.png?1696501932",
      coingeckoId: "bitcoin-cash",
      fullName: "Bitcoin Cash");
  static const ETHSwapAsset bscBnb = ETHSwapAsset(
      symbol: "BNB",
      providerIdentifier: "BSC.BNB",
      decimal: 18,
      network: SwapConstants.bsc,
      provider: SwapConstants.thorchainProvider,
      logoUrl:
          "https://coin-images.coingecko.com/coins/images/825/large/bnb-icon2_2x.png?1696501970",
      coingeckoId: "binancecoin",
      fullName: "BNB");

  /// aprove
  static final ETHSwapAsset bscTwt = ETHSwapAsset(
      symbol: "TWT",
      providerIdentifier: "BSC.TWT-0X4B0F1812E5DF2A09796481FF14017E6005508003",
      decimal: 18,
      network: SwapConstants.bsc,
      provider: SwapConstants.thorchainProvider,
      logoUrl:
          "https://coin-images.coingecko.com/coins/images/11085/large/Trust.png?1696511026",
      coingeckoId: "trust-wallet-token",
      contractAddress: ETHAddress("0x4B0F1812E5DF2A09796481FF14017E6005508003"),
      fullName: "Trust Wallet");

  /// aprove
  static final ETHSwapAsset bscUsdc = ETHSwapAsset(
      symbol: "USDC",
      providerIdentifier: "BSC.USDC-0X8AC76A51CC950D9822D68B83FE1AD97B32CD580D",
      decimal: 18,
      network: SwapConstants.bsc,
      provider: SwapConstants.thorchainProvider,
      logoUrl:
          "https://coin-images.coingecko.com/coins/images/35220/large/USDC.jpg?1707919050",
      coingeckoId: "binance-bridged-usdc-bnb-smart-chain",
      contractAddress: ETHAddress("0x8AC76A51CC950D9822D68B83FE1AD97B32CD580D"),
      fullName: "Binance Bridged USDC (BNB Smart Chain)");

  /// aprove
  static final ETHSwapAsset bscUsdt = ETHSwapAsset(
      symbol: "USDT",
      providerIdentifier: "BSC.USDT-0X55D398326F99059FF775485246999027B3197955",
      decimal: 18,
      network: SwapConstants.bsc,
      provider: SwapConstants.thorchainProvider,
      logoUrl:
          "https://coin-images.coingecko.com/coins/images/6319/large/usdc.png?1696506694",
      coingeckoId: null,
      contractAddress: ETHAddress("0x55D398326F99059FF775485246999027B3197955"),
      fullName: "Tether");
  static const BitcoinSwapAsset btcBtc = BitcoinSwapAsset(
      symbol: "BTC",
      providerIdentifier: "BTC.BTC",
      decimal: 8,
      network: SwapConstants.bitcoin,
      provider: SwapConstants.thorchainProvider,
      logoUrl:
          "https://coin-images.coingecko.com/coins/images/1/large/bitcoin.png?1696501400",
      coingeckoId: "bitcoin",
      fullName: "Bitcoin");
  static const BitcoinSwapAsset dogeDoge = BitcoinSwapAsset(
      symbol: "DOGE",
      providerIdentifier: "DOGE.DOGE",
      decimal: 8,
      network: SwapConstants.dogecoin,
      provider: SwapConstants.thorchainProvider,
      logoUrl:
          "https://coin-images.coingecko.com/coins/images/5/large/dogecoin.png?1696501409",
      coingeckoId: "dogecoin",
      fullName: "Dogecoin");

  /// aprove
  static final ETHSwapAsset ethAave = ETHSwapAsset(
      symbol: "AAVE",
      providerIdentifier: "ETH.AAVE-0X7FC66500C84A76AD7E9C93437BFC5AC33E2DDAE9",
      decimal: 18,
      network: SwapConstants.ethereum,
      provider: SwapConstants.thorchainProvider,
      logoUrl:
          "https://coin-images.coingecko.com/coins/images/12645/large/aave-token-round.png?1720472354",
      coingeckoId: "aave",
      contractAddress: ETHAddress("0x7FC66500C84A76AD7E9C93437BFC5AC33E2DDAE9"),
      fullName: "Aave");

  /// aprove
  static final ETHSwapAsset ethDai = ETHSwapAsset(
      symbol: "DAI",
      providerIdentifier: "ETH.DAI-0X6B175474E89094C44DA98B954EEDEAC495271D0F",
      decimal: 18,
      network: SwapConstants.ethereum,
      provider: SwapConstants.thorchainProvider,
      logoUrl:
          "https://coin-images.coingecko.com/coins/images/9956/large/Badge_Dai.png?1696509996",
      coingeckoId: "dai",
      contractAddress: ETHAddress("0x6B175474E89094C44DA98B954EEDEAC495271D0F"),
      fullName: "Dai");

  /// aprove
  static final ETHSwapAsset ethDpi = ETHSwapAsset(
      symbol: "DPI",
      providerIdentifier: "ETH.DPI-0X1494CA1F11D487C2BBE4543E90080AEBA4BA3C2B",
      decimal: 18,
      network: SwapConstants.ethereum,
      provider: SwapConstants.thorchainProvider,
      logoUrl:
          "https://coin-images.coingecko.com/coins/images/12465/large/defi_pulse_index_set.png?1696512284",
      coingeckoId: "defipulse-index",
      contractAddress: ETHAddress("0x1494CA1F11D487C2BBE4543E90080AEBA4BA3C2B"),
      fullName: "DeFi Pulse Index");
  static const ETHSwapAsset ethEth = ETHSwapAsset(
      symbol: "ETH",
      providerIdentifier: "ETH.ETH",
      decimal: 18,
      network: SwapConstants.ethereum,
      provider: SwapConstants.thorchainProvider,
      logoUrl:
          "https://coin-images.coingecko.com/coins/images/279/large/ethereum.png?1696501628",
      coingeckoId: "ethereum",
      fullName: "Ethereum");

  /// aprove
  static final ETHSwapAsset ethFox = ETHSwapAsset(
      symbol: "FOX",
      providerIdentifier: "ETH.FOX-0XC770EEFAD204B5180DF6A14EE197D99D808EE52D",
      decimal: 18,
      network: SwapConstants.ethereum,
      provider: SwapConstants.thorchainProvider,
      logoUrl:
          "https://coin-images.coingecko.com/coins/images/9988/large/fox_token.png?1728373561",
      coingeckoId: "shapeshift-fox-token",
      contractAddress: ETHAddress("0xC770EEFAD204B5180DF6A14EE197D99D808EE52D"),
      fullName: "ShapeShift FOX");

  /// aprove
  static final ETHSwapAsset ethGusd = ETHSwapAsset(
      symbol: "GUSD",
      providerIdentifier: "ETH.GUSD-0X056FD409E1D7A124BD7017459DFEA2F387B6D5CD",
      decimal: 2,
      network: SwapConstants.ethereum,
      provider: SwapConstants.thorchainProvider,
      logoUrl:
          "https://coin-images.coingecko.com/coins/images/5992/large/gemini-dollar-gusd.png?1696506408",
      coingeckoId: "gemini-dollar",
      contractAddress: ETHAddress("0x056FD409E1D7A124BD7017459DFEA2F387B6D5CD"),
      fullName: "Gemini Dollar");

  /// aprove
  static final ETHSwapAsset ethLink = ETHSwapAsset(
      symbol: "LINK",
      providerIdentifier: "ETH.LINK-0X514910771AF9CA656AF840DFF83E8264ECF986CA",
      decimal: 18,
      network: SwapConstants.ethereum,
      provider: SwapConstants.thorchainProvider,
      logoUrl:
          "https://coin-images.coingecko.com/coins/images/877/large/chainlink-new-logo.png?1696502009",
      coingeckoId: "chainlink",
      contractAddress: ETHAddress("0x514910771AF9CA656AF840DFF83E8264ECF986CA"),
      fullName: "Chainlink");

  /// aprove
  static final ETHSwapAsset ethLusd = ETHSwapAsset(
      symbol: "LUSD",
      providerIdentifier: "ETH.LUSD-0X5F98805A4E8BE255A32880FDEC7F6728C6568BA0",
      decimal: 18,
      network: SwapConstants.ethereum,
      provider: SwapConstants.thorchainProvider,
      logoUrl:
          "https://coin-images.coingecko.com/coins/images/14666/large/Group_3.png?1696514341",
      coingeckoId: "liquity-usd",
      contractAddress: ETHAddress("0x5F98805A4E8BE255A32880FDEC7F6728C6568BA0"),
      fullName: "Liquity USD");

  /// approve
  static final ETHSwapAsset ethSnx = ETHSwapAsset(
      symbol: "SNX",
      providerIdentifier: "ETH.SNX-0XC011A73EE8576FB46F5E1C5751CA3B9FE0AF2A6F",
      decimal: 18,
      network: SwapConstants.ethereum,
      provider: SwapConstants.thorchainProvider,
      logoUrl:
          "https://coin-images.coingecko.com/coins/images/3406/large/SNX.png?1696504103",
      coingeckoId: "havven",
      contractAddress: ETHAddress("0xC011A73EE8576FB46F5E1C5751CA3B9FE0AF2A6F"),
      fullName: "Synthetix Network");

  /// approve
  static final ETHSwapAsset ethTgt = ETHSwapAsset(
      symbol: "TGT",
      providerIdentifier: "ETH.TGT-0X108A850856DB3F85D0269A2693D896B394C80325",
      decimal: 18,
      network: SwapConstants.ethereum,
      provider: SwapConstants.thorchainProvider,
      logoUrl:
          "https://coin-images.coingecko.com/coins/images/21843/large/tgt_logo.png?1696521198",
      coingeckoId: "thorwallet",
      contractAddress: ETHAddress("0x108A850856DB3F85D0269A2693D896B394C80325"),
      fullName: "THORWallet DEX");

  /// approve
  static final ETHSwapAsset ethThor = ETHSwapAsset(
      symbol: "THOR",
      providerIdentifier: "ETH.THOR-0XA5F2211B9B8170F694421F2046281775E8468044",
      decimal: 18,
      network: SwapConstants.ethereum,
      provider: SwapConstants.thorchainProvider,
      logoUrl:
          "https://coin-images.coingecko.com/coins/images/19292/large/THORSwap_Logo-removebg-preview.png?1696518735",
      coingeckoId: "thorswap",
      contractAddress: ETHAddress("0xA5F2211B9B8170F694421F2046281775E8468044"),
      fullName: "THORSwap");

  /// approve
  static final ETHSwapAsset ethUsdc = ETHSwapAsset(
      symbol: "USDC",
      providerIdentifier: "ETH.USDC-0XA0B86991C6218B36C1D19D4A2E9EB0CE3606EB48",
      decimal: 6,
      network: SwapConstants.ethereum,
      provider: SwapConstants.thorchainProvider,
      logoUrl:
          "https://coin-images.coingecko.com/coins/images/6319/large/usdc.png?1696506694",
      coingeckoId: "usd-coin",
      contractAddress: ETHAddress("0xA0B86991C6218B36C1D19D4A2E9EB0CE3606EB48"),
      fullName: "USDC");

  /// approve
  static final ETHSwapAsset ethUsdp = ETHSwapAsset(
      symbol: "USDP",
      providerIdentifier: "ETH.USDP-0X8E870D67F660D95D5BE530380D0EC0BD388289E1",
      decimal: 18,
      network: SwapConstants.ethereum,
      provider: SwapConstants.thorchainProvider,
      logoUrl:
          "https://coin-images.coingecko.com/coins/images/6013/large/Pax_Dollar.png?1696506427",
      coingeckoId: "paxos-standard",
      contractAddress: ETHAddress("0x8E870D67F660D95D5BE530380D0EC0BD388289E1"),
      fullName: "Pax Dollar");

  /// approve
  static final ETHSwapAsset ethUsdt = ETHSwapAsset(
      symbol: "USDT",
      providerIdentifier: "ETH.USDT-0XDAC17F958D2EE523A2206206994597C13D831EC7",
      decimal: 6,
      network: SwapConstants.ethereum,
      provider: SwapConstants.thorchainProvider,
      logoUrl:
          "https://coin-images.coingecko.com/coins/images/325/large/Tether.png?1696501661",
      coingeckoId: "tether",
      contractAddress: ETHAddress("0xDAC17F958D2EE523A2206206994597C13D831EC7"),
      fullName: "Tether");

  /// approve
  static final ETHSwapAsset ethVthor = ETHSwapAsset(
      symbol: "VTHOR",
      providerIdentifier: "ETH.VTHOR-0X815C23ECA83261B6EC689B60CC4A58B54BC24D8D",
      decimal: 18,
      network: SwapConstants.ethereum,
      provider: SwapConstants.thorchainProvider,
      contractAddress: ETHAddress("0x815C23ECA83261B6EC689B60CC4A58B54BC24D8D"),
      fullName: "vTHOR");

  /// approve
  static final ETHSwapAsset ethWbtc = ETHSwapAsset(
      symbol: "WBTC",
      providerIdentifier: "ETH.WBTC-0X2260FAC5E5542A773AA44FBCFEDF7C193BC2C599",
      decimal: 8,
      network: SwapConstants.ethereum,
      provider: SwapConstants.thorchainProvider,
      logoUrl:
          "https://coin-images.coingecko.com/coins/images/7598/large/wrapped_bitcoin_wbtc.png?1696507857",
      coingeckoId: "wrapped-bitcoin",
      contractAddress: ETHAddress("0x2260FAC5E5542A773AA44FBCFEDF7C193BC2C599"),
      fullName: "Wrapped Bitcoin");

  /// approve
  static final ETHSwapAsset ethXrune = ETHSwapAsset(
      symbol: "XRUNE",
      providerIdentifier: "ETH.XRUNE-0X69FA0FEE221AD11012BAB0FDB45D444D3D2CE71C",
      decimal: 18,
      network: SwapConstants.ethereum,
      provider: SwapConstants.thorchainProvider,
      logoUrl:
          "https://coin-images.coingecko.com/coins/images/16835/large/thorstarter.jpg?1696516403",
      coingeckoId: "thorstarter",
      contractAddress: ETHAddress("0x69FA0FEE221AD11012BAB0FDB45D444D3D2CE71C"),
      fullName: "Thorstarter");

  /// aprove
  static final ETHSwapAsset ethYfi = ETHSwapAsset(
      symbol: "YFI",
      providerIdentifier: "ETH.YFI-0X0BC529C00C6401AEF6D220BE8C6EA1667F6AD93E",
      decimal: 18,
      network: SwapConstants.ethereum,
      provider: SwapConstants.thorchainProvider,
      logoUrl:
          "https://coin-images.coingecko.com/coins/images/11849/large/yearn.jpg?1696511720",
      coingeckoId: "yearn-finance",
      contractAddress: ETHAddress("0x0BC529C00C6401AEF6D220BE8C6EA1667F6AD93E"),
      fullName: "yearn.finance");
  // static const CosmosSwapAsset gaiaAtom = CosmosSwapAsset(
  //     symbol: "ATOM",
  //     providerIdentifier: "GAIA.ATOM",
  //     network: SwapConstants.gaia,
  //     baseDenom: 'uatom',
  //     provider: SwapConstants.thorchainProvider,
  //     logoUrl:
  //         "https://coin-images.coingecko.com/coins/images/1481/large/cosmos_hub.png?1696502525",
  //     coingeckoId: "cosmos",
  //     fullName: "Cosmos Hub");
  static const BitcoinSwapAsset ltcLtc = BitcoinSwapAsset(
      symbol: "LTC",
      providerIdentifier: "LTC.LTC",
      decimal: 8,
      network: SwapConstants.litecoin,
      provider: SwapConstants.thorchainProvider,
      logoUrl:
          "https://coin-images.coingecko.com/coins/images/2/large/litecoin.png?1696501400",
      coingeckoId: "litecoin",
      fullName: "Litecoin");

  //// new

  static const SolanaSwapAsset solSol = SolanaSwapAsset(
      symbol: "SOL",
      providerIdentifier: "SOL.SOL",
      decimal: 9,
      network: SwapConstants.solana,
      provider: SwapConstants.thorchainProvider,
      logoUrl:
          "https://coin-images.coingecko.com/coins/images/4128/large/solana.png?1718769756",
      coingeckoId: "solana",
      fullName: "Solana");

  static const TronSwapAsset trx = TronSwapAsset(
      symbol: "TRX",
      providerIdentifier: "TRON.TRX",
      decimal: 6,
      network: SwapConstants.tron,
      provider: SwapConstants.thorchainProvider,
      logoUrl:
          "https://coin-images.coingecko.com/coins/images/1094/large/photo_2026-04-13_09-59-16.png?1776048311",
      coingeckoId: "tron",
      fullName: "Trx");
  static final TronSwapAsset trxUsdc = TronSwapAsset(
      symbol: "USDT",
      providerIdentifier: "TRON.USDT-TR7NHQJEKQXGTCI8Q8ZY4PL8OTSZGJLJ6T",
      decimal: 6,
      network: SwapConstants.tron,
      provider: SwapConstants.thorchainProvider,
      logoUrl:
          "https://coin-images.coingecko.com/coins/images/325/large/Tether.png?1696501661",
      coingeckoId: "tether",
      contractAddress: TronAddress("TR7NHqjeKQxGTCi8q8ZY4pL8otSzgjLj6t"),
      fullName: "USDT");

  static const XRPSwapAsset xrp = XRPSwapAsset(
      symbol: "XRP",
      providerIdentifier: "XRP.XRP",
      provider: SwapConstants.thorchainProvider,
      decimal: 6,
      network: SwapConstants.xrp,
      logoUrl:
          "https://coin-images.coingecko.com/coins/images/44/large/xrp-symbol-white-128.png?1696501442",
      coingeckoId: "ripple",
      fullName: "Ripple");

  static final ETHSwapAsset bscBtcb = ETHSwapAsset(
      symbol: "BTCB",
      providerIdentifier: "BSC.BTCB-0X7130D2A12B9BCBFAE4F2634D864A1EE1CE3EAD9C",
      decimal: 18,
      network: SwapConstants.bsc,
      provider: SwapConstants.thorchainProvider,
      contractAddress: ETHAddress("0x7130d2a12b9bcbfae4f2634d864a1ee1ce3ead9c"),
      logoUrl:
          "https://coin-images.coingecko.com/coins/images/1/large/bitcoin.png?1696501400",
      coingeckoId: null,
      fullName: "Binance-Peg BTCB Token (BTCB)");

  static final ETHSwapAsset bscBusd = ETHSwapAsset(
      symbol: "BUSD",
      providerIdentifier: "BSC.BUSD-0XE9E7CEA3DEDCA5984780BAFC599BD69ADD087D56",
      decimal: 18,
      network: SwapConstants.bsc,
      provider: SwapConstants.thorchainProvider,
      contractAddress: ETHAddress("0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56"),
      logoUrl:
          "https://coin-images.coingecko.com/coins/images/31273/large/new_binance-peg-busd.png?1696530096",
      coingeckoId: "binance-peg-busd",
      fullName: "Binance-Peg BUSD Token (BUSD)");

  static final ETHSwapAsset bscEth = ETHSwapAsset(
      symbol: "ETH",
      providerIdentifier: "BSC.ETH-0X2170ED0880AC9A755FD29B2688956BD959F933F8",
      decimal: 18,
      network: SwapConstants.bsc,
      provider: SwapConstants.thorchainProvider,
      contractAddress: ETHAddress("0x2170Ed0880ac9A755fd29B2688956BD959F933F8"),
      logoUrl:
          "https://coin-images.coingecko.com/coins/images/279/large/ethereum.png?1696501628",
      coingeckoId: "ethereum",
      fullName: "Binance-Peg Ethereum Token (ETH)");

  static final ETHSwapAsset baseVVV = ETHSwapAsset(
      symbol: "VVV",
      providerIdentifier: "BASE.VVV-0XACFE6019ED1A7DC6F7B508C02D1B04EC88CC21BF",
      decimal: 18,
      network: SwapConstants.base,
      provider: SwapConstants.thorchainProvider,
      logoUrl:
          "https://coin-images.coingecko.com/coins/images/54023/large/VVV_Token_Transparent.png?1741856877",
      coingeckoId: "venice-token",
      contractAddress: ETHAddress("0xacfE6019Ed1A7Dc6f7B508C02d1b04ec88cC21bf"),
      fullName: "Venice Token (VVV)");

  // static const CosmosSwapAsset thorRuji = CosmosSwapAsset(
  //     symbol: "RUJI",
  //     providerIdentifier: "THOR.RUJI",
  //     network: SwapConstants.thorchain,
  //     baseDenom: 'x/ruji',
  //     provider: SwapConstants.thorchainProvider,
  //     logoUrl:
  //         "https://coin-images.coingecko.com/coins/images/55372/large/RUJI_180x180.png?1745666342",
  //     coingeckoId: "rujira",
  //     fullName: "Rujira");

  // static const CosmosSwapAsset thorTcy = CosmosSwapAsset(
  //     symbol: "TCY",
  //     providerIdentifier: "THOR.TCY",
  //     network: SwapConstants.thorchain,
  //     baseDenom: 'tcy',
  //     provider: SwapConstants.thorchainProvider,
  //     logoUrl:
  //         "https://coin-images.coingecko.com/coins/images/55539/large/THORChain_TCY_Token.png?1782452361",
  //     coingeckoId: "tcy",
  //     fullName: "THORChain Yield");
}
