import 'package:on_chain/on_chain.dart';
import 'package:on_chain_swap/src/swap/transaction/transaction.dart';
import 'package:polkadot_dart/polkadot_dart.dart';
import 'package:xrpl_dart/xrpl_dart.dart';
import 'package:zcash_dart/zcash.dart';

abstract class Web3Signer<ADDRESS> {
  const Web3Signer();
  Future<List<ADDRESS>> signers();
}

abstract class Web3SignerEthereum implements Web3Signer<ETHAddress> {
  Future<String> excuteTransaction(Web3TransactionEthereum transaction);
}

abstract class Web3SignerTron implements Web3Signer<TronAddress> {
  Future<Transaction> signTransaction(Web3TransactionTron transaction);
}

abstract class Web3SignerXRP implements Web3Signer<XRPBaseAddress> {
  Future<String> sendTransaction(SubmittableTransaction transaction);
}

abstract class Web3SignerZcash implements Web3Signer<ZcashAddress> {
  Future<String> excuteTransaction(Web3TransactionZcash transaction);
}

abstract class Web3SignerSolana implements Web3Signer<SolAddress> {
  Future<SolanaTransaction> signTransaction(Web3TransactionSolana transaction);
}

enum BitcoinSigningScheme { psbt, sendPayment }

abstract class Web3SignerBitcoin implements Web3Signer<BitcoinSpenderAddress> {
  Future<String> signPsbt(Web3TransactionBitcoin transaction);
  Future<String> sendPayment(Web3TransactionBitcoin transaction);
  BitcoinSigningScheme get signingSchames;
}

abstract class Web3SignerSubstrate implements Web3Signer<BaseSubstrateAddress> {
  Future<String> signTransaction(Web3TransactionSubstrate transaction);
}

abstract class Web3SignerCosmos implements Web3Signer<CosmosSpenderAddress> {
  Future<CosmosSignResponse> signRaw(Web3TransactionCosmos transaction);
  List<CosmosSigningScheme> get signingSchames;
}
