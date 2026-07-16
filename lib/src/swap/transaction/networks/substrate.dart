import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:on_chain_swap/src/exception/exception.dart';
import 'package:on_chain_swap/src/swap/constants/constants.dart';
import 'package:on_chain_swap/src/swap/transaction/transaction.dart';
import 'package:on_chain_swap/src/swap/types/types.dart';
import 'package:polkadot_dart/polkadot_dart.dart';

enum SwapRouteSubstrateTransactionStrategy { native, assetHubAsset }

class SwapRouteSubstrateTransactionBuilder extends SwapRouteTransactionBuilder<
    SubstrateAddress,
    SwapSubstrateNetwork,
    BaseSwapSubstrateClient,
    Web3TransactionSubstrate,
    Web3SignerSubstrate,
    SwapRouteSubstrateTransactionOperation> {
  SwapRouteSubstrateTransactionBuilder(
      {required super.route, required super.params, required super.operations});

  @override
  Future<void> buildTransactions(
      {required CbGetRouteNetwork<BaseSwapSubstrateClient, SwapSubstrateNetwork>
          client,
      required CbGetSigner<Web3SignerSubstrate, SubstrateAddress> signer,
      required CbOnStatusChanged stepsCallBack}) async {
    for (final operation in operations) {
      stepsCallBack(TransactionOperationStep.client);
      final substrateClient = await checkRouteAndClient(client, operation);
      stepsCallBack(TransactionOperationStep.generateTx);
      final callData = await operation._buildTransactions(substrateClient);
      final extersinc = substrateClient.api.metadata.extrinsicInfo();
      if (extersinc.isEmpty) {
        throw const DartOnChainSwapPluginException(
            "Unsported metadata extersinc.");
      }
      final metadataWithProvider = substrateClient.metadataWitPorvider();
      final transaction =
          await SubstrateTransactionBuilder.buildTransactionStatic(
              owner: operation.source,
              calls: SubstrateTransactionSubmitableParams(calls: [
                SubstrateEncodedCallParams(
                    pallet: callData.pallet.name,
                    method: callData.type.method,
                    bytes: callData.encodeCall(
                        extrinsic: metadataWithProvider.metadata))
              ]),
              provider: metadataWithProvider);
      stepsCallBack(TransactionOperationStep.signing);
      final signerInfo = await signer(operation.source);
      final signers = await signerInfo.signers();
      signers.firstWhere((e) => e == operation.source,
          orElse: () => throw const DartOnChainSwapPluginException(
              "None of the connected accounts match the source address of the transaction."));
      final web3Tx = Web3TransactionSubstrate(transaction: transaction);
      final signature = await signerInfo.signTransaction(web3Tx);
      final extrinsic = await SubstrateTransactionBuilder.signTransactionStatic(
          payload: web3Tx.transaction,
          provider: metadataWithProvider,
          encodedSignature: BytesUtils.fromHexString(signature));
      stepsCallBack(TransactionOperationStep.broadcast);
      final result =
          await substrateClient.submitExtrinsicAndWatch(extrinsic: extrinsic);
      stepsCallBack(TransactionOperationStep.txHash,
          transactionHash: result.transactionHash);
    }
  }
}

abstract class SwapRouteSubstrateTransactionOperation
    extends SwapRouteTransactionOperation<SwapSubstrateNetwork> {
  final String? memo;
  final SubstrateAddress source;
  final SwapAmount amount;
  final SwapRouteSubstrateTransactionStrategy strategy;
  const SwapRouteSubstrateTransactionOperation(
      {required this.source,
      required this.amount,
      required super.network,
      required this.strategy,
      this.memo});
  Future<SubstrateLocalTransferCallPallet> _buildTransactions(
      BaseSwapSubstrateClient client);
}

class SwapRouteSubstrateNativeTransactionOperation
    extends SwapRouteSubstrateTransactionOperation
    implements SwapRouteTransactionTransferDetails<SwapSubstrateNetwork> {
  final SubstrateAddress destination;
  SwapRouteSubstrateNativeTransactionOperation(
      {required super.amount,
      required super.source,
      required this.destination,
      required super.network,
      super.memo})
      : super(strategy: SwapRouteSubstrateTransactionStrategy.native);

  @override
  Future<SubstrateLocalTransferCallPallet> _buildTransactions(
      BaseSwapSubstrateClient client) async {
    final balance = await client.getBalance(source);
    if (balance < amount.amount) {
      throw SwapConstants.insufficientTokenBalance;
    }

    return SubstrateNetworkControllerLocalAssetTransferBuilder
        .createLocalBalancesPalletTransfer(
            metadata: client.api.metadataWithExtrinsic(),
            destination: destination,
            amount: amount.amount,
            method: BalancesCallPalletMethod.transferKeepAlive);
  }

  @override
  String get destinationAddress => destination.address;

  @override
  String get sourceAddress => source.address;

  @override
  final String? tokenAddress = null;
}

class SwapRouteSubstrateAssetHubAssetTransactionOperation
    extends SwapRouteSubstrateTransactionOperation
    implements SwapRouteTransactionTransferDetails<SwapSubstrateNetwork> {
  final SubstrateAddress destination;
  final BigInt assetId;
  SwapRouteSubstrateAssetHubAssetTransactionOperation(
      {required super.amount,
      required super.source,
      required this.destination,
      required super.network,
      required this.assetId,
      super.memo})
      : super(strategy: SwapRouteSubstrateTransactionStrategy.assetHubAsset);

  Future<BigInt> getAssetBalance(BaseSwapSubstrateClient client) async {
    final balancesEntries = await SubstrateNetworkControllerAssetQueryHelper
        .getAssetsPalletAccountIdentifierBigInt(
            provider: client.metadataWitPorvider(),
            address: source,
            assetIds: [assetId]);
    final balanceEntry = balancesEntries.entries
        .firstWhereNullable((e) => e.key == assetId)
        ?.value;
    if (balanceEntry == null) return BigInt.zero;
    final balance = PolkadotAssetBalance.fromJson(balanceEntry);
    return balance.balance;
  }

  @override
  Future<SubstrateLocalTransferCallPallet> _buildTransactions(
      BaseSwapSubstrateClient client) async {
    final balance = await getAssetBalance(client);
    if (balance < amount.amount) {
      throw SwapConstants.insufficientTokenBalance;
    }
    final extersinc = client.api.metadata.extrinsicInfo();
    if (extersinc.isEmpty) {
      throw const DartOnChainSwapPluginException(
          "Unsported metadata extersinc.");
    }
    final extWithMetadata = client.api.metadataWithExtrinsic();
    return SubstrateNetworkControllerLocalAssetTransferBuilder
        .createLocalAssetPalletTransfer(
            metadata: extWithMetadata,
            assetId: assetId,
            target: destination,
            amount: amount.amount,
            method: AssetsCallPalletMethod.transferKeepAlive);
  }

  @override
  String get destinationAddress => destination.address;

  @override
  String get sourceAddress => source.address;

  @override
  final String? tokenAddress = null;
}
