import 'dart:async';
import 'package:on_chain/on_chain.dart';
import 'package:on_chain_swap/src/swap/transaction/client/core/client.dart';
import 'package:on_chain_swap/src/exception/exception.dart';
import 'package:on_chain_swap/src/swap/types/types.dart';
import 'package:on_chain_swap/src/swap/transaction/types/types.dart';

class SwapSolanaClient implements BaseSwapSolanaClient {
  String? _genesis;
  final SolanaProvider provider;
  final SwapSolanaNetwork network;
  SwapSolanaClient({required this.provider, required this.network});
  static Future<SwapSolanaClient> check(
      {required SolanaProvider provider, required SwapSolanaNetwork network}) async {
    final client = SwapSolanaClient(provider: provider, network: network);
    if (!(await client.initSwapClient())) {
      throw const DartOnChainSwapPluginException(
          "The Genesis Hash is not compatible with the current network.");
    }
    return client;
  }

  @override
  Future<String> getGenesis() async {
    if (_genesis != null) return _genesis!;
    _genesis = await provider.request(SolanaRequestGetGenesisHash());
    return _genesis!;
  }

  @override
  Future<SolanaAccountInfo?> getAccountInfo(SolAddress address) async {
    final info = await provider.request(SolanaRequestGetAccountInfo(account: address));
    return info;
  }

  @override
  Future<BigInt> getBalance(SolAddress address) async {
    final account = await getAccountInfo(address);
    return account?.lamports ?? BigInt.zero;
  }

  @override
  Future<SimulateTranasctionResponse> simulate(
      {required SolanaTransaction transaction,
      SolAddress? account,
      bool replaceRecentBlockhash = true,
      bool sigVerify = false,
      Commitment? commitment = Commitment.processed,
      MinContextSlot? minContextSlot}) async {
    return await provider.request(
      SolanaRequestSimulateTransaction(
          encodedTransaction:
              transaction.serializeString(encoding: TransactionSerializeEncoding.base64),
          sigVerify: sigVerify,
          replaceRecentBlockhash: replaceRecentBlockhash,
          encoding: SolanaRequestEncoding.base64,
          commitment: Commitment.processed,
          minContextSlot: minContextSlot,
          accounts: account == null
              ? null
              : RPCAccountConfig(
                  addresses: [account], encoding: SolanaRequestEncoding.base64)),
    );
  }

  @override
  Future<SolAddress> getBlockHash() async {
    final blockHash = await provider.request(const SolanaRequestGetLatestBlockhash());
    return blockHash.blockhash;
  }

  @override
  Future<SignatureStatus?> getSignatureStatuses(String signature) async {
    final statuses = await provider
        .request(SolanaRequestGetSignatureStatuses(signatures: [signature]));
    return statuses.elementAt(0);
  }

  @override
  Future<TransactionConfirmationStatus> trackTransaction(
      {required String transactionId,
      Duration timeout = const Duration(minutes: 1),
      Duration periodicTimeOut = const Duration(seconds: 2)}) async {
    Timer? timer;
    try {
      final Completer<TransactionConfirmationStatus> completer =
          Completer<TransactionConfirmationStatus>();
      timer = Timer.periodic(periodicTimeOut, (t) async {
        final receipt = await getSignatureStatuses(transactionId);
        if (receipt != null) {
          if (receipt.err != null) {
            completer.completeError(DartOnChainSwapPluginException(
                "Solana transaction simulation failed with error: ${receipt.err}"));
          } else {
            final status = receipt.confirmationStatus;
            if (status == TransactionConfirmationStatus.finalized) {
              completer.complete(status);
            }
          }
        }
      });
      final receipt = await completer.future.timeout(timeout);
      return receipt;
    } on TimeoutException {
      throw const DartOnChainSwapPluginException(
          "transaction confirmation failed within the allotted timeout.");
    } finally {
      timer?.cancel();
      timer = null;
    }
  }

  @override
  Future<String> sendTransaction(SolanaTransaction transaction,
      {int? maxRetries,
      bool skipPreflight = false,
      int? minContextSlot,
      Commitment? commitment,
      SolanaRequestEncoding encoding = SolanaRequestEncoding.base64}) async {
    return await provider.request(SolanaRequestSendTransaction(
        encodedTransaction: transaction.serializeString(
          encoding: encoding == SolanaRequestEncoding.base64
              ? TransactionSerializeEncoding.base64
              : TransactionSerializeEncoding.base58,
        ),
        encoding: encoding,
        skipPreflight: skipPreflight,
        maxRetries: maxRetries,
        commitment: skipPreflight ? Commitment.processed : commitment,
        minContextSlot:
            minContextSlot == null ? null : MinContextSlot(slot: minContextSlot)));
  }

  @override
  Future<SolanaTokenPDAInfo> getTokenAccountAddress(
      {required SolAddress account,
      required SolAddress mint,
      SolAddress? tokenProgramId}) async {
    if (tokenProgramId == null) {
      final mintAccount = await getAccountInfo(mint);
      if (mintAccount == null) {
        throw const DartOnChainSwapPluginException(
            "Invalid token address. mint account not found.");
      }
      tokenProgramId = mintAccount.owner;
      if (tokenProgramId != SPLTokenProgramConst.token2022ProgramId &&
          tokenProgramId != SPLTokenProgramConst.tokenProgramId) {
        throw DartOnChainSwapPluginException("Invalid mint account owner.",
            details: {"owner": tokenProgramId.address, "mint": mint.address});
      }
    }
    final pda = AssociatedTokenAccountProgramUtils.associatedTokenAccount(
        mint: mint,
        owner: account,
        tokenProgramId: tokenProgramId,
        allowOwnerOffCurve: true);
    return SolanaTokenPDAInfo(
        address: account, pdaAddress: pda.address, tokenProgramId: tokenProgramId);
  }

  @override
  Future<BigInt> getTokenBalance(
      {required SolAddress account,
      required SolAddress? mint,
      SolAddress? tokenProgramId}) async {
    if (mint == null) {
      throw const DartOnChainSwapPluginException(
          "Invalid asset. missing asset mint address.");
    }
    if (tokenProgramId == null) {
      final mintAccount = await getAccountInfo(mint);
      if (mintAccount == null) {
        throw const DartOnChainSwapPluginException(
            "Invalid token address. mint account not found.");
      }
      tokenProgramId = mintAccount.owner;
      if (tokenProgramId != SPLTokenProgramConst.token2022ProgramId &&
          tokenProgramId != SPLTokenProgramConst.tokenProgramId) {
        throw DartOnChainSwapPluginException("Invalid mint account owner.",
            details: {"owner": tokenProgramId.address, "mint": mint.address});
      }
    }
    final pda = AssociatedTokenAccountProgramUtils.associatedTokenAccount(
        mint: mint,
        owner: account,
        tokenProgramId: tokenProgramId,
        allowOwnerOffCurve: true);
    final balance =
        await provider.request(SolanaRPCGetTokenAccount(account: pda.address));
    return balance?.amount ?? BigInt.zero;
  }

  @override
  Future<bool> initSwapClient() async {
    final genesis = await getGenesis();
    return genesis == network.genesis;
  }

  Future<SwapSolanaAccountAssetBalance> getAccountsAssetBalance(
      SolanaSwapAsset asset, SolAddress account) async {
    return SwapSolanaAccountAssetBalance(
        address: account,
        balance: asset.isNative
            ? await getBalance(account)
            : await getTokenBalance(account: account, mint: asset.contractAddress),
        asset: asset);
  }

  @override
  Future<BigInt> getBlockHeight() async {
    final block = await provider
        .request(const SolanaRequestGetBlockHeight(commitment: Commitment.finalized));
    return BigInt.from(block);
  }
}
