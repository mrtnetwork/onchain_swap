import 'package:blockchain_utils/utils/utils.dart';
import 'package:on_chain/on_chain.dart';
import 'package:on_chain_swap/src/on_chain_swap_base.dart';
import 'package:on_chain_swap/src/swap/transaction/const/abis/one_inch_agg.dart';

class SwapKitSwapUtils {
  static SwapRouteEthereumCallContractTransactionOperation parseEthSwapData(
      {required Map<String, dynamic> jsonTx, required SwapEthereumNetwork network}) {
    final ethTx = Web3TransactionEthereum.fromJson(jsonTx);
    final contract = ethTx.to;
    final source = ethTx.from;
    switch (contract.address) {
      case EthereumAbiConst.oneInchAggregationV6:
        final abi = ContractABI.fromJson(oneInchAggregationRouterV6);
        final dataBytes = BytesUtils.fromHexString(ethTx.data);
        final func = abi.findFunctionFromSelector(dataBytes);
        if (func == null) {
          throw const DartAptosPluginException(
              "Invalid input data. No matching function found on 1inch router.");
        }
        return SwapRouteEthereumCallContractTransactionOperation(
            network: network,
            contract: contract,
            method: func,
            source: source,
            params: func.decodeInput(dataBytes),
            data: ethTx.data,
            value: ethTx.value);
      default:
        throw const DartOnChainSwapPluginException("Unsuported contract.");
    }
  }
}
