import 'dart:js_interop';

import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:cosmos_sdk/cosmos_sdk.dart';
import 'package:on_chain/on_chain.dart';
import 'package:on_chain_bridge/web/api/core/js.dart';
import 'package:on_chain_swap/on_chain_swap.dart';
import 'package:onchain_swap_example/app/error/exception.dart';
import 'package:onchain_swap_example/app/utils/method.dart';
import 'package:onchain_swap_example/app/utils/numbers/numbers.dart';
import 'package:onchain_swap_example/web3/core/wallet.dart';
import 'package:onchain_swap_example/web3/cross/web/types/js/account.dart';
import 'package:onchain_swap_example/web3/cross/web/types/js/bitcoin.dart';
import 'package:onchain_swap_example/web3/cross/web/types/js/cosmos.dart';
import 'package:onchain_swap_example/web3/cross/web/types/js/substrate.dart';
import 'package:onchain_swap_example/web3/cross/web/types/types.dart';
import 'package:onchain_swap_example/web3/cross/web/utils/utils.dart';
import 'package:onchain_swap_example/web3/utils/utils.dart';
import 'package:polkadot_dart/polkadot_dart.dart';

mixin JSWeb3WalletWalletStandard<NETWORK extends SwapNetwork, ADDRESS,
        JSADDRESS extends JSWalletStandardAccount>
    on JSWeb3Wallet<NETWORK, ADDRESS, JSADDRESS> {
  JSWalletStandardConnectFeature get connectStandard;
  JSWalletStandard<JSADDRESS> get wallet;
  JSWalletStandardFeatures get features;
  JSFunction? _disconnectCallback;
  List<JSWeb3WalletAccount<ADDRESS, JSADDRESS>> _filterAccounts(
      List<JSADDRESS> accounts);
  void _onEvents(JSWalletStandardChangeEvents<JSADDRESS> event) {
    final accounts = event.accounts_;
    if (accounts != null) {
      final chainAccount = _filterAccounts(accounts);
      updateAccounts(chainAccount);
    }
  }

  @override
  void listenOnEvents() {
    final event = features.events;
    if (event != null && event.on_ != null) {
      _disconnectCallback = event.on('change'.toJS, _onEvents.toJS);
    }
  }

  @override
  void disposeEvents() {
    final disconnect = _disconnectCallback;
    if (disconnect != null) {
      _disconnectCallback = null;
      disconnect.callAsFunction(disconnect);
    }
  }

  ///    } on JSError catch (e) {
  @override
  Future<bool> connect({bool silent = false}) async {
    try {
      final existAccounts = _filterAccounts(wallet.accounts_ ?? []);
      if (existAccounts.isNotEmpty) {
        updateStatus(Web3WalletStatus.connect);
        updateAccounts(existAccounts);
        return true;
      }
      if (silent) return false;

      final accounts = await connectStandard.connect<JSADDRESS>().toDart;
      updateStatus(Web3WalletStatus.connect);
      updateAccounts(_filterAccounts(accounts.accounts_));
      return true;
    } on JSError catch (e) {
      throw AppException(e.message ?? e.toString());
    } catch (e) {
      rethrow;
    }
  }
}

class JSWeb3WalletWalletStandardEthereum extends JSWeb3Wallet<
        SwapEthereumNetwork, ETHAddress, JSWalletStandardAccount>
    with
        JSWeb3WalletWalletStandard<SwapEthereumNetwork, ETHAddress,
            JSWalletStandardAccount>
    implements
        Web3SignerEthereum {
  @override
  final JSWalletStandard wallet;
  @override
  final JSWalletStandardFeatures features;
  final EthereumWalletAdapterSendTransactionFeature signTxFeature;
  @override
  final JSWalletStandardConnectFeature connectStandard;

  JSWeb3WalletWalletStandardEthereum(
      {required super.walletName,
      required super.icon,
      required this.wallet,
      required super.network,
      required this.features,
      required this.signTxFeature,
      required this.connectStandard})
      : super(protocol: Web3WalletProtocol.walletStandard);
  static JSWeb3WalletWalletStandardEthereum? fromJs(
      {required JSWalletStandard wallet,
      required SwapEthereumNetwork network}) {
    final features = wallet.features;
    final request = features?.ethereumSendTransaction;
    final connect = features?.standardConnect;
    if (!wallet.isMrtWallet ||
        features == null ||
        request == null ||
        connect == null ||
        request.sendTransaction_ == null ||
        !wallet.hasSupportNetwork('ethereum')) {
      return null;
    }
    return JSWeb3WalletWalletStandardEthereum(
        walletName: wallet.name,
        icon: Web3WalletUtils.parseWalletImage(wallet.icon),
        wallet: wallet,
        network: network,
        connectStandard: connect,
        features: features,
        signTxFeature: request);
  }

  @override
  List<JSWeb3WalletAccount<ETHAddress, JSWalletStandardAccount>>
      _filterAccounts(List<JSWalletStandardAccount> accounts) {
    final jsAccounts = accounts
        .where((e) => e.isForChain('ethereum:${network.chainId}'))
        .toList();
    return jsAccounts
        .map((e) {
          final address =
              MethodUtils.nullOnException(() => ETHAddress(e.address));
          if (address == null) return null;
          return JSWeb3WalletAccount<ETHAddress, JSWalletStandardAccount>(
              address: address, addressStr: address.toString(), jsAddress: e);
        })
        .whereType<JSWeb3WalletAccount<ETHAddress, JSWalletStandardAccount>>()
        .toList();
  }

  @override
  Future<String> excuteTransaction(Web3TransactionEthereum transaction) async {
    try {
      final signer = accounts.firstWhere(
        (e) => e.address == transaction.from,
        orElse: () => throw AppException("signer_not_found_in_wallet_accounts"),
      );
      final jsTx = JSEthereumTransactionParams(
          chainId: transaction.chainId?.toRadix16,
          data: transaction.data,
          from: transaction.from.address,
          to: transaction.to.address,
          gasLimit: transaction.gasLimit?.toRadix16,
          gasPrice: transaction.gasPrice?.toRadix16,
          maxFeePerGas: transaction.maxFeePerGas?.toRadix16,
          maxPriorityFeePerGas: transaction.maxPriorityFeePerGas?.toRadix16,
          value: transaction.value.toRadix16,
          type: transaction.transactionType?.prefix.toRadix16);
      final params = EthereumWalletStandardTransactionParams(
          account: signer.jsAddress, transaction: jsTx);
      final txID = await signTxFeature.sendTransaction(params).toDart;
      return txID.txId;
    } on JSError catch (e) {
      throw AppException(e.message ?? e.toString());
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<ETHAddress>> signers() async {
    return selectedAddresses.map((e) => e.address).toList();
  }
}

class JSWeb3WalletEIP1193Ethereum
    extends JSWeb3Wallet<SwapEthereumNetwork, ETHAddress, String>
    implements Web3SignerEthereum {
  final JSEIP1193 wallet;
  BigInt? _chainId;
  BigInt? get chainId => _chainId;
  JSWeb3WalletEIP1193Ethereum(
      {required this.wallet,
      required super.walletName,
      required super.icon,
      required super.network})
      : super(protocol: Web3WalletProtocol.eip1193);

  void _listenOnChainId(String? chainId) {
    _chainId = BigintUtils.tryParse(chainId);
    updateAccounts(accounts);
  }

  void _listenAccountChanged(JSArray<JSString> accounts) {
    updateAccounts(_toWalletAccounts(accounts));
  }

  late final JSFunction _listenOnChainIdJs = _listenOnChainId.toJS;
  late final JSFunction _listenAccountChangedJS = _listenAccountChanged.toJS;

  static JSWeb3WalletEIP1193Ethereum? fromJs(
      {required JSEIP1193 wallet, required SwapEthereumNetwork network}) {
    if (!wallet.isEIP1193()) {
      return null;
    }
    return JSWeb3WalletEIP1193Ethereum(
        walletName: wallet.getName(),
        icon: Web3WalletUtils.parseWalletImage(wallet.icon),
        wallet: wallet,
        network: network);
  }

  Future<BigInt?> getChainId() async {
    try {
      final chainId = await wallet
          .request<JSString>(JSEIP1193RequestParams(method: 'eth_chainId'))
          .toDart;
      return BigintUtils.tryParse(chainId.toDart);
    } on JSError catch (e) {
      throw AppException(e.message ?? e.toString());
    } catch (e) {
      rethrow;
    }
  }

  @override
  void updateAccounts(List<JSWeb3WalletAccount<ETHAddress, String>> accounts) {
    setAccounts(accounts);
    if (accounts.isEmpty) {
      updateStatus(Web3WalletStatus.noAccount);
    } else {
      if (chainId == network.chainId) {
        updateStatus(Web3WalletStatus.connect);
      } else {
        updateStatus(Web3WalletStatus.wrongNetwork);
      }
    }
  }

  Future<List<JSWeb3WalletAccount<ETHAddress, String>>> ethAccounts() async {
    try {
      final jsAccounts = await wallet
          .request<JSArray<JSString>>(
              JSEIP1193RequestParams(method: 'eth_accounts'))
          .toDart;
      return _toWalletAccounts(jsAccounts);
    } catch (e) {
      return [];
    }
  }

  List<JSWeb3WalletAccount<ETHAddress, String>> _toWalletAccounts(
      JSArray<JSString> accounts) {
    final walletAccounts = accounts.toDart.map((e) => e.toDart).map((e) {
      final addr = MethodUtils.nullOnException(() => ETHAddress(e));
      if (addr == null) return null;
      return JSWeb3WalletAccount<ETHAddress, String>(
          address: addr, addressStr: addr.address, jsAddress: e);
    });
    return walletAccounts
        .whereType<JSWeb3WalletAccount<ETHAddress, String>>()
        .toList();
  }

  @override
  Future<bool> connect({bool silent = false}) async {
    try {
      final ethAccounts = await this.ethAccounts();
      final selectedAddress = wallet.selectedAddress;
      final addr =
          MethodUtils.nullOnException(() => ETHAddress(selectedAddress!));
      if (silent) {
        if (addr == null && ethAccounts.isEmpty) return false;
        _chainId ??= await getChainId();
        if (ethAccounts.isNotEmpty) {
          updateAccounts(ethAccounts);
        } else {
          updateAccounts([
            JSWeb3WalletAccount<ETHAddress, String>(
                address: addr!,
                addressStr: addr.address,
                jsAddress: selectedAddress!)
          ]);
        }

        return true;
      }
      final jsAccounts = await wallet
          .request<JSArray<JSString>>(
              JSEIP1193RequestParams(method: 'eth_requestAccounts'))
          .toDart;
      updateAccounts(_toWalletAccounts(jsAccounts));
      return true;
    } on JSError catch (e) {
      throw AppException(e.message ?? e.toString());
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<String> excuteTransaction(Web3TransactionEthereum transaction) async {
    try {
      accounts.firstWhere(
        (e) => e.address == transaction.from,
        orElse: () => throw AppException("signer_not_found_in_wallet_accounts"),
      );
      if (transaction.chainId != network.chainId) {
        throw AppException("incorrect_wallet_transaction_chainid");
      }
      final jsTx = JSEthereumTransactionParams(
          chainId: transaction.chainId?.toRadix16,
          data: transaction.data,
          from: transaction.from.address,
          to: transaction.to.address,
          gasLimit: transaction.gasLimit?.toRadix16,
          gasPrice: transaction.gasPrice?.toRadix16,
          maxFeePerGas: transaction.maxFeePerGas?.toRadix16,
          maxPriorityFeePerGas: transaction.maxPriorityFeePerGas?.toRadix16,
          value: transaction.value.toRadix16,
          type: transaction.transactionType?.prefix.toRadix16);
      final params = JSEIP1193RequestParams(
          method: 'eth_signTreansaction', params: [jsTx].toJS);
      final txId = await wallet.request<JSString>(params).toDart;
      return txId.toDart;
    } on JSError catch (e) {
      throw AppException(e.message ?? e.toString());
    } catch (e) {
      rethrow;
    }
  }

  @override
  void listenOnEvents() {
    super.listenOnEvents();
    if (wallet.on_ != null) {
      wallet.on('accountsChanged', _listenAccountChangedJS);
      wallet.on('chainChanged', _listenOnChainIdJs);
    }
  }

  @override
  void disposeEvents() {
    super.disposeEvents();
    if (wallet.removeListener_ != null) {
      wallet.removeListener('accountsChanged', _listenAccountChangedJS);
      wallet.removeListener('chainChanged', _listenOnChainIdJs);
    }
  }

  @override
  Future<List<ETHAddress>> signers() async {
    return selectedAddresses.map((e) => e.address).toList();
  }
}

class JSWeb3WalletEIP6963Ethereum extends JSWeb3WalletEIP1193Ethereum {
  JSWeb3WalletEIP6963Ethereum(
      {required super.walletName,
      required super.wallet,
      required super.icon,
      required super.network});
  static JSWeb3WalletEIP1193Ethereum? fromJs(
      {required JSEIP6963 wallet, required SwapEthereumNetwork network}) {
    if (!wallet.isEIP6963()) {
      return null;
    }
    return JSWeb3WalletEIP1193Ethereum(
        walletName: wallet.getName(),
        icon: Web3WalletUtils.parseWalletImage(wallet.info?.icon),
        wallet: wallet.provider!,
        network: network);
  }
}

class JSWeb3WalletWalletStandardSolana
    extends JSWeb3Wallet<SwapSolanaNetwork, SolAddress, JSWalletStandardAccount>
    with
        JSWeb3WalletWalletStandard<SwapSolanaNetwork, SolAddress,
            JSWalletStandardAccount>
    implements
        Web3SignerSolana {
  @override
  final JSWalletStandard wallet;
  @override
  final JSWalletStandardFeatures features;
  @override
  final JSWalletStandardConnectFeature connectStandard;
  final SolanaWalletAdapterSolanaSignTransactionFeature signTransactionFeature;
  JSWeb3WalletWalletStandardSolana(
      {required super.walletName,
      required super.icon,
      required this.wallet,
      required super.network,
      required this.features,
      required this.signTransactionFeature,
      required this.connectStandard})
      : super(protocol: Web3WalletProtocol.walletStandard);

  static JSWeb3WalletWalletStandardSolana? fromJs(
      {required JSWalletStandard wallet, required SwapSolanaNetwork network}) {
    final features = wallet.features;
    final signFeature = features?.solanaSignTransaction;
    final connect = features?.standardConnect;
    if (features == null ||
        signFeature == null ||
        connect == null ||
        signFeature.signTransaction_ == null ||
        !wallet.hasSupportNetwork('solana')) {
      return null;
    }
    return JSWeb3WalletWalletStandardSolana(
        walletName: wallet.name,
        icon: Web3WalletUtils.parseWalletImage(wallet.icon),
        wallet: wallet,
        network: network,
        connectStandard: connect,
        features: features,
        signTransactionFeature: signFeature);
  }

  @override
  Future<SolanaTransaction> signTransaction(
      Web3TransactionSolana transaction) async {
    try {
      final signer = accounts.firstWhere(
        (e) => e.address == transaction.source,
        orElse: () => throw AppException("signer_not_found_in_wallet_accounts"),
      );
      final version =
          signTransactionFeature.getSupportVersion() ?? TransactionType.v0;
      final param = JSSolanaSignTransactionParams(
          account: signer.jsAddress,
          transaction: switch (version) {
            TransactionType.v0 =>
              APPJSUint8Array.fromList(transaction.v0.serialize()),
            TransactionType.legacy =>
              APPJSUint8Array.fromList(transaction.legacy.serialize()),
            _ => throw UnimplementedError()
          });

      final r =
          await signTransactionFeature.signTransaction([param].toJS).toDart;
      final toArray = JSWalletUtils.toList(r);
      if (toArray.isEmpty) {
        throw AppException("unexpected_signing_transaction_response");
      }
      final signature = MethodUtils.nullOnException(() => JSOBJ
          .as<SolanaSignTransactionOutput>(
              object: toArray[0], keys: ['signedTransaction'])
          ?.signedTransaction
          .toListInt());

      if (signature == null) {
        throw AppException("unexpected_signing_transaction_response");
      }
      return SolanaTransaction.deserialize(signature);
    } on JSError catch (e) {
      throw AppException(e.message ?? e.toString());
    } catch (e) {
      rethrow;
    }
  }

  @override
  List<JSWeb3WalletAccount<SolAddress, JSWalletStandardAccount>>
      _filterAccounts(List<JSWalletStandardAccount> accounts) {
    final identifier =
        'solana:${network.chainType.isMainnet ? 'mainnet' : 'devnet'}';
    final jsAccounts = accounts.where((e) => e.isForChain(identifier)).toList();
    return jsAccounts
        .map((e) {
          final address =
              MethodUtils.nullOnException(() => SolAddress(e.address));
          if (address == null) return null;
          return JSWeb3WalletAccount<SolAddress, JSWalletStandardAccount>(
              address: address, addressStr: address.address, jsAddress: e);
        })
        .whereType<JSWeb3WalletAccount<SolAddress, JSWalletStandardAccount>>()
        .toList();
  }

  @override
  Future<List<SolAddress>> signers() async {
    return selectedAddresses.map((e) => e.address).toList();
  }
}

class JSWeb3WalletWalletStandardSubstrate extends JSWeb3Wallet<
        SwapSubstrateNetwork,
        SubstrateAddress,
        JSWalletStandardSubstrateAccount>
    with
        JSWeb3WalletWalletStandard<SwapSubstrateNetwork, SubstrateAddress,
            JSWalletStandardSubstrateAccount>
    implements
        Web3SignerSubstrate {
  @override
  final JSWalletStandard<JSWalletStandardSubstrateAccount> wallet;
  @override
  final JSWalletStandardFeatures features;
  @override
  final JSWalletStandardConnectFeature connectStandard;
  final SubstrateWalletAdapterSubstrateSignTransactionFeature
      signTransactionFeature;
  JSWeb3WalletWalletStandardSubstrate(
      {required super.walletName,
      required super.icon,
      required this.wallet,
      required super.network,
      required this.features,
      required this.signTransactionFeature,
      required this.connectStandard})
      : super(protocol: Web3WalletProtocol.walletStandard);

  static JSWeb3WalletWalletStandardSubstrate? fromJs(
      {required JSWalletStandard wallet,
      required SwapSubstrateNetwork network}) {
    final features = wallet.features;
    final signFeature = features?.substrateSignTransaction;
    final connect = features?.standardConnect;
    if (!wallet.isMrtWallet ||
        features == null ||
        signFeature == null ||
        connect == null ||
        signFeature.signTransaction_ == null ||
        !wallet.hasSupportNetwork('substrate')) {
      return null;
    }
    if (signFeature.signTransaction_ == null) {
      return null;
    }
    return JSWeb3WalletWalletStandardSubstrate(
        walletName: wallet.name,
        icon: Web3WalletUtils.parseWalletImage(wallet.icon),
        wallet: wallet as JSWalletStandard<JSWalletStandardSubstrateAccount>,
        network: network,
        features: features,
        signTransactionFeature: signFeature,
        connectStandard: connect);
  }

  @override
  Future<String> signTransaction(Web3TransactionSubstrate transaction) async {
    try {
      final toJson = transaction.toJson();
      final jsTx = JSSubstrateTransaction(
          address: toJson.valueAs("address"),
          assetId: toJson.valueAs("assetId"),
          blockHash: toJson.valueAs("blockHash"),
          blockNumber: toJson.valueAs("blockNumber"),
          era: toJson.valueAs("era"),
          genesisHash: toJson.valueAs("genesisHash"),
          metadataHash: toJson.valueAs("metadataHash"),
          method: toJson.valueAs("method"),
          mode: toJson.valueAs("mode"),
          nonce: toJson.valueAs("nonce"),
          signedExtensions: toJson
              .valueEnsureAsList<String>("signedExtensions")
              .map((e) => e.toJS)
              .toList()
              .toJS,
          specVersion: toJson.valueAs("specVersion"),
          tip: toJson.valueAs("tip"),
          transactionVersion: toJson.valueAs("transactionVersion"),
          version: toJson.valueAs("version"),
          withSignedTransaction: transaction.withSignedTransaction);
      final signature =
          await signTransactionFeature.signTransaction(jsTx).toDart;
      return signature.signature;
    } on JSError catch (e) {
      throw AppException(e.message ?? e.toString());
    } catch (e) {
      rethrow;
    }
  }

  @override
  List<JSWeb3WalletAccount<SubstrateAddress, JSWalletStandardSubstrateAccount>>
      _filterAccounts(List<JSWalletStandardSubstrateAccount> accounts) {
    final jsAccounts = accounts
        .where((e) => e.isForChain(
            'substrate:${StringUtils.add0x(network.genesis.toLowerCase())}'))
        .toList();
    return jsAccounts
        .map((e) {
          final address =
              MethodUtils.nullOnException(() => SubstrateAddress(e.address));
          if (address == null) return null;
          return JSWeb3WalletAccount<SubstrateAddress,
                  JSWalletStandardSubstrateAccount>(
              address: address, addressStr: address.toString(), jsAddress: e);
        })
        .whereType<
            JSWeb3WalletAccount<SubstrateAddress,
                JSWalletStandardSubstrateAccount>>()
        .toList();
  }

  @override
  Future<List<SubstrateAddress>> signers() async {
    return selectedAddresses.map((e) => e.address).toList();
  }
}

class JSWeb3WalletWalletStandardCosmos extends JSWeb3Wallet<SwapCosmosNetwork,
        CosmosSpenderAddress, JSWalletStandardCosmosAccount>
    with
        JSWeb3WalletWalletStandard<SwapCosmosNetwork, CosmosSpenderAddress,
            JSWalletStandardCosmosAccount>
    implements
        Web3SignerCosmos {
  @override
  final JSWalletStandard<JSWalletStandardCosmosAccount> wallet;
  @override
  final JSWalletStandardFeatures features;
  @override
  final JSWalletStandardConnectFeature connectStandard;
  final CosmosWalletAdapterStandardSignTransactionFeature
      signTransactionFeature;
  static JSWeb3WalletWalletStandardCosmos? fromJs(
      {required JSWalletStandard wallet, required SwapCosmosNetwork network}) {
    final features = wallet.features;
    final signFeature = features?.cosmosSignTransaction;
    final connect = features?.standardConnect;
    if (!wallet.isMrtWallet ||
        features == null ||
        signFeature == null ||
        connect == null ||
        !wallet.hasSupportNetwork('cosmos') ||
        signFeature.signTransaction_ == null) {
      return null;
    }
    return JSWeb3WalletWalletStandardCosmos(
        walletName: wallet.name,
        icon: Web3WalletUtils.parseWalletImage(wallet.icon),
        wallet: wallet as JSWalletStandard<JSWalletStandardCosmosAccount>,
        network: network,
        features: features,
        signTransactionFeature: signFeature,
        connectStandard: connect);
  }

  JSWeb3WalletWalletStandardCosmos(
      {required super.walletName,
      required super.icon,
      required this.wallet,
      required super.network,
      required this.features,
      required this.connectStandard,
      required this.signTransactionFeature})
      : super(protocol: Web3WalletProtocol.walletStandard);

  @override
  List<JSWeb3WalletAccount<CosmosSpenderAddress, JSWalletStandardCosmosAccount>>
      _filterAccounts(List<JSWalletStandardCosmosAccount> accounts) {
    final jsAccounts = accounts
        .where((e) => e.isForChain('cosmos:${network.identifier}'))
        .toList();
    return jsAccounts
        .map((e) {
          final address = MethodUtils.nullOnException(
              () => CosmosBaseAddress(e.address, forceHrp: network.bech32));
          final pubKey = MethodUtils.nullOnException(() =>
              CosmosPublicKey.fromBytes(
                  keyBytes: e.publicKey!.toListInt(),
                  algorithm: CosmosKeysAlgs.fromName(e.algo!)));
          if (address == null || pubKey == null) return null;
          final addr =
              CosmosSpenderAddress(address: address, publicKey: pubKey);
          return JSWeb3WalletAccount<CosmosSpenderAddress,
                  JSWalletStandardCosmosAccount>(
              address: addr, addressStr: address.address, jsAddress: e);
        })
        .whereType<
            JSWeb3WalletAccount<CosmosSpenderAddress,
                JSWalletStandardCosmosAccount>>()
        .toList();
  }

  @override
  Future<CosmosSignResponse> signRaw(Web3TransactionCosmos transaction) async {
    try {
      final signer = accounts.firstWhere(
        (e) => e.address == transaction.source,
        orElse: () => throw AppException("signer_not_found_in_wallet_accounts"),
      );
      if (transaction.signDoc.chainId != network.identifier) {
        throw AppException("incorrect_wallet_transaction_chainid");
      }
      final params = JSCosmosSendOrSignTransactionParams(
          account: signer.jsAddress,
          transaction:
              APPJSUint8Array.fromList(transaction.signDoc.toBuffer()));
      final signature =
          await signTransactionFeature.signTransaction(params).toDart;
      final response = MethodUtils.nullOnException(() => CosmosSignResponse(
          authBytes: signature.signed.authInfoBytes!.toListInt(),
          bodyBytes: signature.signed.bodyBytes!.toListInt(),
          signature: StringUtils.encode(signature.signature.signature,
              type: StringEncoding.base64)));
      if (response == null) {
        throw AppException("unexpected_signing_transaction_response");
      }
      return response;
    } on JSError catch (e) {
      throw AppException(e.message ?? e.toString());
    } catch (e) {
      rethrow;
    }
  }

  @override
  List<CosmosSigningScheme> get signingSchames => [CosmosSigningScheme.direct];

  @override
  Future<List<CosmosSpenderAddress>> signers() async {
    return selectedAddresses.map((e) => e.address).toList();
  }
}

class JSWeb3WalletWalletStandardBitcoin extends JSWeb3Wallet<SwapBitcoinNetwork,
        BitcoinSpenderAddress, JSWalletStandardBitcoinAccount>
    with
        JSWeb3WalletWalletStandard<SwapBitcoinNetwork, BitcoinSpenderAddress,
            JSWalletStandardBitcoinAccount>
    implements
        Web3SignerBitcoin {
  @override
  bool get allowMultiSelect => true;
  @override
  final JSWalletStandardConnectFeature connectStandard;
  @override
  final JSWalletStandard<JSWalletStandardBitcoinAccount> wallet;
  @override
  final JSWalletStandardFeatures features;
  final JSWalletStandardBitcoinSignTransactionFeature signTransactionFeature;
  JSWeb3WalletWalletStandardBitcoin(
      {required super.walletName,
      required super.icon,
      required this.wallet,
      required super.network,
      required this.features,
      required this.signTransactionFeature,
      required this.connectStandard})
      : super(protocol: Web3WalletProtocol.walletStandard);
  static JSWeb3WalletWalletStandardBitcoin? fromJs(
      {required JSWalletStandard wallet, required SwapBitcoinNetwork network}) {
    final features = wallet.features;
    final signFeature = features?.bitcoinSignTransaction;
    final connect = features?.standardConnect;
    if (!wallet.isMrtWallet ||
        features == null ||
        connect == null ||
        signFeature == null ||
        signFeature.signTransaction_ == null ||
        !wallet.hasSupportNetwork(network.identifier)) {
      return null;
    }
    return JSWeb3WalletWalletStandardBitcoin(
        walletName: wallet.name,
        icon: Web3WalletUtils.parseWalletImage(wallet.icon),
        wallet: wallet as JSWalletStandard<JSWalletStandardBitcoinAccount>,
        network: network,
        features: features,
        signTransactionFeature: signFeature,
        connectStandard: connect);
  }

  @override
  List<
      JSWeb3WalletAccount<BitcoinSpenderAddress,
          JSWalletStandardBitcoinAccount>> _filterAccounts(
      List<JSWalletStandardBitcoinAccount> accounts) {
    final String identifier =
        '${network.identifier}:${network.chainType.isMainnet ? 'mainnet' : 'testnet'}';
    final jsAccounts = accounts.where((e) => e.isForChain(identifier)).toList();
    final addresses = jsAccounts
        .map((e) {
          final bitcoinAddress = MethodUtils.nullOnException(() =>
              BitcoinNetworkAddress.parse(
                  address: e.address, network: network.chain));
          if (bitcoinAddress == null) return null;
          final p2shreedemScript = MethodUtils.nullOnException(() =>
              Script.deserialize(
                  bytes: BytesUtils.fromHexString(e.redeemScript!)));
          final witnessScript = MethodUtils.nullOnException(() =>
              Script.deserialize(
                  bytes: BytesUtils.fromHexString(e.witnessScript!)));

          final pubkey = MethodUtils.nullOnException(
              () => ECPublic.fromBytes(e.publicKey!.toListInt()));
          final address = MethodUtils.nullOnException(() =>
              BitcoinSpenderAddress(
                  address: bitcoinAddress,
                  p2shreedemScript: p2shreedemScript,
                  witnessScript: witnessScript,
                  taprootInternal:
                      bitcoinAddress.type.isP2tr ? pubkey?.toXOnly() : null));
          if (address == null) return null;
          return JSWeb3WalletAccount<BitcoinSpenderAddress,
                  JSWalletStandardBitcoinAccount>(
              address: address,
              addressStr: address.address.toAddress(),
              jsAddress: e);
        })
        .whereType<
            JSWeb3WalletAccount<BitcoinSpenderAddress,
                JSWalletStandardBitcoinAccount>>()
        .toList();

    return addresses;
  }

  @override
  Future<String> signPsbt(Web3TransactionBitcoin transaction) async {
    try {
      selectedAddresses.firstWhere((e) => e.address == transaction.source,
          orElse: () =>
              throw AppException("signer_not_found_in_wallet_accounts"));
      final params = JSBitcoinSignTransactionParams(
          accounts: selectedAddresses.map((e) => e.jsAddress).toList().toJS,
          psbt: transaction.psbt);
      final signature =
          await signTransactionFeature.signTransaction(params).toDart;
      return signature.psbt;
    } on JSError catch (e) {
      throw AppException(e.message ?? e.toString());
    } catch (e) {
      rethrow;
    }
  }

  @override
  BitcoinSigningScheme get signingSchames => BitcoinSigningScheme.psbt;

  @override
  Future<List<BitcoinSpenderAddress>> signers() async {
    return selectedAddresses.map((e) => e.address).toList();
  }

  @override
  Future<String> sendPayment(Web3TransactionBitcoin transaction) {
    throw UnimplementedError();
  }
}
