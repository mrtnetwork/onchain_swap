import 'package:blockchain_utils/utils/utils.dart';
import 'package:on_chain_swap/src/exception/exception.dart';
import 'package:on_chain_swap/src/providers/cf/models/models/rpc.dart';

class AffiliateBroker {
  final String account;
  final int commissionBps;
  const AffiliateBroker({required this.account, required this.commissionBps});
  factory AffiliateBroker.fromJson(Map<String, dynamic> json) {
    return AffiliateBroker(
        account: json["account"], commissionBps: json["commissionBps"]);
  }
  Map<String, dynamic> toJson() {
    return {"account": account, "commissionBps": commissionBps};
  }
}

class ChainFlipFeeType {
  final String type;

  const ChainFlipFeeType._(this.type);

  static const ChainFlipFeeType network = ChainFlipFeeType._('NETWORK');
  static const ChainFlipFeeType ingress = ChainFlipFeeType._('INGRESS');
  static const ChainFlipFeeType egress = ChainFlipFeeType._('EGRESS');
  static const ChainFlipFeeType broker = ChainFlipFeeType._('BROKER');
  static const ChainFlipFeeType boost = ChainFlipFeeType._('BOOST');
  static const ChainFlipFeeType liquidity = ChainFlipFeeType._("LIQUIDITY");

  static List<ChainFlipFeeType> get values =>
      [network, ingress, egress, broker, boost, liquidity];

  static ChainFlipFeeType fromName(String? name) {
    return values.firstWhere((e) => e.type == name,
        orElse: () => throw DartOnChainSwapPluginException("fee type not found.",
            details: {"type": name}));
  }
}

abstract class ChainFlipFee {
  final ChainFlipFeeType type;
  final String chain;
  final String asset;
  final String amount;
  const ChainFlipFee(
      {required this.type,
      required this.chain,
      required this.asset,
      required this.amount});

  Map<String, dynamic> toJson() {
    return {"type": type.type, "chain": chain, "asset": asset, "amount": amount};
  }

  factory ChainFlipFee.fromJson(Map<String, dynamic> json) {
    final type = ChainFlipFeeType.fromName(json["type"]);
    switch (type) {
      case ChainFlipFeeType.liquidity:
        return ChainFlipPoolFee.fromJson(json);
      default:
        return ChainFlipSwapFee.fromJson(json);
    }
  }
}

class ChainFlipSwapFee extends ChainFlipFee {
  ChainFlipSwapFee._(
      {required super.type,
      required super.chain,
      required super.asset,
      required super.amount});
  factory ChainFlipSwapFee(
      {required ChainFlipFeeType type,
      required String chain,
      required String asset,
      required String amount}) {
    if (type == ChainFlipFeeType.liquidity) {
      throw DartOnChainSwapPluginException("Invalid swap Fee type.",
          details: {"type": type.type});
    }
    return ChainFlipSwapFee._(type: type, chain: chain, asset: asset, amount: amount);
  }
  // Converts JSON map to ChainFlipSwapFee instance
  factory ChainFlipSwapFee.fromJson(Map<String, dynamic> json) {
    return ChainFlipSwapFee(
      type: ChainFlipFeeType.fromName(json['type']),
      chain: json['chain'],
      asset: json['asset'],
      amount: json['amount'],
    );
  }
}

class ChainFlipPoolFee extends ChainFlipFee {
  ChainFlipPoolFee({required super.chain, required super.asset, required super.amount})
      : super(type: ChainFlipFeeType.liquidity);

  factory ChainFlipPoolFee.fromJson(Map<String, dynamic> json) {
    return ChainFlipPoolFee(
        chain: json['chain'], asset: json['asset'], amount: json['amount']);
  }
}

class SwapStateStatus {
  final String _state;

  const SwapStateStatus._(this._state);

  static const SwapStateStatus awaitingDeposit = SwapStateStatus._("AWAITING_DEPOSIT");
  static const SwapStateStatus depositReceived = SwapStateStatus._("DEPOSIT_RECEIVED");
  static const SwapStateStatus swapExecuted = SwapStateStatus._("SWAP_EXECUTED");
  static const SwapStateStatus egressScheduled = SwapStateStatus._("EGRESS_SCHEDULED");
  static const SwapStateStatus broadcastRequested =
      SwapStateStatus._("BROADCAST_REQUESTED");
  static const SwapStateStatus broadcasted = SwapStateStatus._("BROADCASTED");
  static const SwapStateStatus complete = SwapStateStatus._("COMPLETE");
  static const SwapStateStatus completed = SwapStateStatus._("COMPLETED");
  static const SwapStateStatus broadcastAborted = SwapStateStatus._("BROADCAST_ABORTED");
  static const SwapStateStatus failed = SwapStateStatus._("FAILED");
  static List<SwapStateStatus> get values => [
        awaitingDeposit,
        depositReceived,
        swapExecuted,
        egressScheduled,
        broadcastRequested,
        broadcasted,
        complete,
        completed,
        broadcastAborted,
        failed
      ];

  static SwapStateStatus fromName(String? name) {
    return values.firstWhere((e) => e._state == name,
        orElse: () => throw DartOnChainSwapPluginException("state not found $name"));
  }

  @override
  String toString() {
    return "SwapStateStatus.$_state";
  }
}

class ErrorDetails {
  final String name;
  final String message;

  const ErrorDetails(this.name, this.message);

  // Converts JSON map to ErrorDetails instance
  factory ErrorDetails.fromJson(Map<String, dynamic> json) {
    return ErrorDetails(
      json['name'],
      json['message'],
    );
  }

  // Converts ErrorDetails instance to JSON map
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'message': message,
    };
  }
}

abstract class EgressScheduled {
  final String egressType;
  final String swapId;
  final String depositAmount;
  final int? depositReceivedAt;
  final String? depositReceivedBlockIndex;
  final String egressAmount;
  final int egressScheduledAt;
  final String egressScheduledBlockIndex;
  const EgressScheduled(
      {required this.egressType,
      required this.swapId,
      required this.depositAmount,
      required this.depositReceivedAt,
      required this.depositReceivedBlockIndex,
      required this.egressAmount,
      required this.egressScheduledAt,
      required this.egressScheduledBlockIndex});
  // Add properties as needed, this is a placeholder for the example.
}

class SwapEgress extends EgressScheduled {
  final String? intermediateAmount;
  final int swapExecutedAt;
  final String swapExecutedBlockIndex;

  SwapEgress({
    required super.swapId,
    required super.depositAmount,
    required super.depositReceivedAt,
    required super.depositReceivedBlockIndex,
    required super.egressAmount,
    required super.egressScheduledAt,
    required super.egressScheduledBlockIndex,
    required this.swapExecutedAt,
    required this.swapExecutedBlockIndex,
    this.intermediateAmount,
  }) : super(
          egressType: 'SWAP',
        );

  // Converts JSON map to SwapEgress instance
  factory SwapEgress.fromJson(Map<String, dynamic> json) {
    return SwapEgress(
      swapId: json['swapId'],
      depositAmount: json['depositAmount'],
      depositReceivedAt: json['depositReceivedAt'],
      depositReceivedBlockIndex: json['depositReceivedBlockIndex'],
      egressAmount: json['egressAmount'],
      egressScheduledAt: json['egressScheduledAt'],
      egressScheduledBlockIndex: json['egressScheduledBlockIndex'],
      swapExecutedAt: json['swapExecutedAt'],
      swapExecutedBlockIndex: json['swapExecutedBlockIndex'],
      intermediateAmount:
          json['intermediateAmount'], // Nullable, no need for explicit null check
    );
  }

  // Converts SwapEgress instance to JSON map
  Map<String, dynamic> toJson() {
    return {
      'swapId': swapId,
      'depositAmount': depositAmount,
      'depositReceivedAt': depositReceivedAt,
      'depositReceivedBlockIndex': depositReceivedBlockIndex,
      'egressAmount': egressAmount,
      'egressScheduledAt': egressScheduledAt,
      'egressScheduledBlockIndex': egressScheduledBlockIndex,
      'swapExecutedAt': swapExecutedAt,
      'swapExecutedBlockIndex': swapExecutedBlockIndex,
      'intermediateAmount': intermediateAmount,
    };
  }
}

class RefundEgress extends EgressScheduled {
  RefundEgress({
    required super.swapId,
    required super.depositAmount,
    required super.depositReceivedAt,
    required super.depositReceivedBlockIndex,
    required super.egressAmount,
    required super.egressScheduledAt,
    required super.egressScheduledBlockIndex,
  }) : super(
          egressType: 'REFUND',
        );

  // Converts JSON map to RefundEgress instance
  factory RefundEgress.fromJson(Map<String, dynamic> json) {
    return RefundEgress(
      swapId: json['swapId'],
      depositAmount: json['depositAmount'],
      depositReceivedAt: json['depositReceivedAt'],
      depositReceivedBlockIndex: json['depositReceivedBlockIndex'],
      egressAmount: json['egressAmount'],
      egressScheduledAt: json['egressScheduledAt'],
      egressScheduledBlockIndex: json['egressScheduledBlockIndex'],
    );
  }

  // Converts RefundEgress instance to JSON map
  Map<String, dynamic> toJson() {
    return {
      'swapId': swapId,
      'depositAmount': depositAmount,
      'depositReceivedAt': depositReceivedAt,
      'depositReceivedBlockIndex': depositReceivedBlockIndex,
      'egressAmount': egressAmount,
      'egressScheduledAt': egressScheduledAt,
      'egressScheduledBlockIndex': egressScheduledBlockIndex,
    };
  }
}

abstract class SwapState {
  SwapStateStatus get state;

  factory SwapState.fromJson(Map<String, dynamic> json) {
    final state = SwapStateStatus.fromName(json["state"]);
    switch (state) {
      case SwapStateStatus.awaitingDeposit:
        return AwaitingDeposit.fromJson(json); // or some specific message
      case SwapStateStatus.depositReceived:
        return DepositReceived.fromJson(json);
      case SwapStateStatus.swapExecuted:
        return SwapExecuted.fromJson(json);
      case SwapStateStatus.egressScheduled:
        return EgressScheduledState.fromJson(json);
      case SwapStateStatus.broadcastRequested:
        return BroadcastRequested.fromJson(json);
      case SwapStateStatus.broadcasted:
        return Broadcasted.fromJson(json);
      case SwapStateStatus.complete:
      case SwapStateStatus.completed:
        return Complete.fromJson(json);
      case SwapStateStatus.broadcastAborted:
        return BroadcastAborted.fromJson(json);
      case SwapStateStatus.failed:
        switch (json["failure"]) {
          case "INGRESS_IGNORED":
            return FailedIngressIgnored.fromJson(json);
          case "EGRESS_IGNORED":
            return FailedEgressIgnored.fromJson(json);
          case "REFUND_EGRESS_IGNORED":
            return FailedRefundEgressIgnored.fromJson(json);
        }
        break;
      default:
    }
    throw const DartOnChainSwapPluginException("Swap state not found.");
  }
  Map<String, dynamic> toJson();
}

class AwaitingDeposit implements SwapState {
  final String? depositAmount;
  final int? depositTransactionConfirmations;
  const AwaitingDeposit({
    this.depositAmount,
    this.depositTransactionConfirmations,
  });
  factory AwaitingDeposit.fromJson(Map<String, dynamic> json) {
    return AwaitingDeposit(
      depositAmount: json['depositAmount'],
      depositTransactionConfirmations: json['depositTransactionConfirmations'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'depositAmount': depositAmount,
      'depositTransactionConfirmations': depositTransactionConfirmations,
    };
  }

  @override
  SwapStateStatus get state => SwapStateStatus.awaitingDeposit;
}

class DepositReceived implements SwapState {
  final String swapId;
  final String depositAmount;
  final int? depositReceivedAt;
  final String? depositReceivedBlockIndex;
  final int? depositBoostedAt;
  final String? depositBoostedBlockIndex;

  const DepositReceived({
    required this.swapId,
    required this.depositAmount,
    required this.depositReceivedAt,
    required this.depositReceivedBlockIndex,
    this.depositBoostedAt,
    this.depositBoostedBlockIndex,
  });
  factory DepositReceived.fromJson(Map<String, dynamic> json) {
    return DepositReceived(
      swapId: json['swapId'],
      depositAmount: json['depositAmount'],
      depositReceivedAt: json['depositReceivedAt'],
      depositReceivedBlockIndex: json['depositReceivedBlockIndex'],
      depositBoostedAt: json['depositBoostedAt'],
      depositBoostedBlockIndex: json['depositBoostedBlockIndex'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'swapId': swapId,
      'depositAmount': depositAmount,
      'depositReceivedAt': depositReceivedAt,
      'depositReceivedBlockIndex': depositReceivedBlockIndex,
      'depositBoostedAt': depositBoostedAt,
      'depositBoostedBlockIndex': depositBoostedBlockIndex,
    };
  }

  @override
  SwapStateStatus get state => SwapStateStatus.depositReceived;
}

class SwapExecuted implements SwapState {
  final String swapId;
  final String depositAmount;
  final int? depositReceivedAt;
  final String? depositReceivedBlockIndex;
  final String? intermediateAmount;
  final int swapExecutedAt;
  final String swapExecutedBlockIndex;

  const SwapExecuted({
    required this.swapId,
    required this.depositAmount,
    required this.depositReceivedAt,
    required this.depositReceivedBlockIndex,
    this.intermediateAmount,
    required this.swapExecutedAt,
    required this.swapExecutedBlockIndex,
  });
  factory SwapExecuted.fromJson(Map<String, dynamic> json) {
    return SwapExecuted(
      swapId: json['swapId'],
      depositAmount: json['depositAmount'],
      depositReceivedAt: json['depositReceivedAt'],
      depositReceivedBlockIndex: json['depositReceivedBlockIndex'],
      intermediateAmount: json['intermediateAmount'], // Nullable
      swapExecutedAt: json['swapExecutedAt'],
      swapExecutedBlockIndex: json['swapExecutedBlockIndex'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'swapId': swapId,
      'depositAmount': depositAmount,
      'depositReceivedAt': depositReceivedAt,
      'depositReceivedBlockIndex': depositReceivedBlockIndex,
      'intermediateAmount': intermediateAmount,
      'swapExecutedAt': swapExecutedAt,
      'swapExecutedBlockIndex': swapExecutedBlockIndex,
    };
  }

  @override
  SwapStateStatus get state => SwapStateStatus.swapExecuted;
}

class EgressScheduledState extends EgressScheduled implements SwapState {
  @override
  SwapStateStatus get state => SwapStateStatus.egressScheduled;

  EgressScheduledState(
      {required super.egressType,
      required super.swapId,
      required super.depositAmount,
      required super.depositReceivedAt,
      required super.depositReceivedBlockIndex,
      required super.egressAmount,
      required super.egressScheduledAt,
      required super.egressScheduledBlockIndex});

  // Converts JSON map to EgressScheduledState instance
  factory EgressScheduledState.fromJson(Map<String, dynamic> json) {
    return EgressScheduledState(
      egressType: json['egressType'],
      swapId: json['swapId'],
      depositAmount: json['depositAmount'],
      depositReceivedAt: json['depositReceivedAt'],
      depositReceivedBlockIndex: json['depositReceivedBlockIndex'],
      egressAmount: json['egressAmount'],
      egressScheduledAt: json['egressScheduledAt'],
      egressScheduledBlockIndex: json['egressScheduledBlockIndex'],
    );
  }

  // Converts EgressScheduledState instance to JSON map
  @override
  Map<String, dynamic> toJson() {
    return {
      'egressType': egressType,
      'swapId': swapId,
      'depositAmount': depositAmount,
      'depositReceivedAt': depositReceivedAt,
      'depositReceivedBlockIndex': depositReceivedBlockIndex,
      'egressAmount': egressAmount,
      'egressScheduledAt': egressScheduledAt,
      'egressScheduledBlockIndex': egressScheduledBlockIndex,
    };
  }
}

class BroadcastRequested extends EgressScheduled implements SwapState {
  final int broadcastRequestedAt;
  final String broadcastRequestedBlockIndex;

  BroadcastRequested(
      {required this.broadcastRequestedAt,
      required this.broadcastRequestedBlockIndex,
      required super.egressType,
      required super.swapId,
      required super.depositAmount,
      required super.depositReceivedAt,
      required super.depositReceivedBlockIndex,
      required super.egressAmount,
      required super.egressScheduledAt,
      required super.egressScheduledBlockIndex});
  factory BroadcastRequested.fromJson(Map<String, dynamic> json) {
    return BroadcastRequested(
      broadcastRequestedAt: json['broadcastRequestedAt'],
      broadcastRequestedBlockIndex: json['broadcastRequestedBlockIndex'],
      egressType: json['egressType'],
      swapId: json['swapId'],
      depositAmount: json['depositAmount'],
      depositReceivedAt: json['depositReceivedAt'],
      depositReceivedBlockIndex: json['depositReceivedBlockIndex'],
      egressAmount: json['egressAmount'],
      egressScheduledAt: json['egressScheduledAt'],
      egressScheduledBlockIndex: json['egressScheduledBlockIndex'],
    );
  }

  // Converts BroadcastRequested instance to JSON map
  @override
  Map<String, dynamic> toJson() {
    return {
      'broadcastRequestedAt': broadcastRequestedAt,
      'broadcastRequestedBlockIndex': broadcastRequestedBlockIndex,
      'egressType': egressType,
      'swapId': swapId,
      'depositAmount': depositAmount,
      'depositReceivedAt': depositReceivedAt,
      'depositReceivedBlockIndex': depositReceivedBlockIndex,
      'egressAmount': egressAmount,
      'egressScheduledAt': egressScheduledAt,
      'egressScheduledBlockIndex': egressScheduledBlockIndex,
    };
  }

  @override
  SwapStateStatus get state => SwapStateStatus.broadcastRequested;
}

class Broadcasted extends EgressScheduled implements SwapState {
  final int broadcastRequestedAt;
  final String broadcastRequestedBlockIndex;
  final String broadcastTransactionRef;

  @override
  SwapStateStatus get state => SwapStateStatus.broadcasted;

  Broadcasted({
    required super.egressType,
    required super.swapId,
    required super.depositAmount,
    required super.depositReceivedAt,
    required super.depositReceivedBlockIndex,
    required super.egressAmount,
    required super.egressScheduledAt,
    required super.egressScheduledBlockIndex,
    required this.broadcastRequestedAt,
    required this.broadcastRequestedBlockIndex,
    required this.broadcastTransactionRef,
  });
  factory Broadcasted.fromJson(Map<String, dynamic> json) {
    return Broadcasted(
      egressType: json['egressType'],
      swapId: json['swapId'],
      depositAmount: json['depositAmount'],
      depositReceivedAt: json['depositReceivedAt'],
      depositReceivedBlockIndex: json['depositReceivedBlockIndex'],
      egressAmount: json['egressAmount'],
      egressScheduledAt: json['egressScheduledAt'],
      egressScheduledBlockIndex: json['egressScheduledBlockIndex'],
      broadcastRequestedAt: json['broadcastRequestedAt'],
      broadcastRequestedBlockIndex: json['broadcastRequestedBlockIndex'],
      broadcastTransactionRef: json['broadcastTransactionRef'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'egressType': egressType,
      'swapId': swapId,
      'depositAmount': depositAmount,
      'depositReceivedAt': depositReceivedAt,
      'depositReceivedBlockIndex': depositReceivedBlockIndex,
      'egressAmount': egressAmount,
      'egressScheduledAt': egressScheduledAt,
      'egressScheduledBlockIndex': egressScheduledBlockIndex,
      'broadcastRequestedAt': broadcastRequestedAt,
      'broadcastRequestedBlockIndex': broadcastRequestedBlockIndex,
      'broadcastTransactionRef': broadcastTransactionRef,
      'state': state,
    };
  }
}

class Complete extends EgressScheduled implements SwapState {
  final int broadcastRequestedAt;
  final String broadcastRequestedBlockIndex;
  final String broadcastTransactionRef;
  final int broadcastSucceededAt;
  final String broadcastSucceededBlockIndex;

  @override
  SwapStateStatus get state => SwapStateStatus.complete;

  const Complete({
    required super.egressType,
    required super.swapId,
    required super.depositAmount,
    required super.depositReceivedAt,
    required super.depositReceivedBlockIndex,
    required super.egressAmount,
    required super.egressScheduledAt,
    required super.egressScheduledBlockIndex,
    required this.broadcastRequestedAt,
    required this.broadcastRequestedBlockIndex,
    required this.broadcastTransactionRef,
    required this.broadcastSucceededAt,
    required this.broadcastSucceededBlockIndex,
  });

  factory Complete.fromJson(Map<String, dynamic> json) {
    return Complete(
      egressType: json['egressType'],
      swapId: json['swapId'],
      depositAmount: json['depositAmount'],
      depositReceivedAt: json['depositReceivedAt'],
      depositReceivedBlockIndex: json['depositReceivedBlockIndex'],
      egressAmount: json['egressAmount'],
      egressScheduledAt: json['egressScheduledAt'],
      egressScheduledBlockIndex: json['egressScheduledBlockIndex'],
      broadcastRequestedAt: json['broadcastRequestedAt'],
      broadcastRequestedBlockIndex: json['broadcastRequestedBlockIndex'],
      broadcastTransactionRef: json['broadcastTransactionRef'],
      broadcastSucceededAt: json['broadcastSucceededAt'],
      broadcastSucceededBlockIndex: json['broadcastSucceededBlockIndex'],
    );
  }

  // Converts Complete instance to JSON map
  @override
  Map<String, dynamic> toJson() {
    return {
      'egressType': egressType,
      'swapId': swapId,
      'depositAmount': depositAmount,
      'depositReceivedAt': depositReceivedAt,
      'depositReceivedBlockIndex': depositReceivedBlockIndex,
      'egressAmount': egressAmount,
      'egressScheduledAt': egressScheduledAt,
      'egressScheduledBlockIndex': egressScheduledBlockIndex,
      'broadcastRequestedAt': broadcastRequestedAt,
      'broadcastRequestedBlockIndex': broadcastRequestedBlockIndex,
      'broadcastTransactionRef': broadcastTransactionRef,
      'broadcastSucceededAt': broadcastSucceededAt,
      'broadcastSucceededBlockIndex': broadcastSucceededBlockIndex,
      'state': state, // Include the state in the JSON
    };
  }
}

class BroadcastAborted extends EgressScheduled implements SwapState {
  final int broadcastRequestedAt;
  final String broadcastRequestedBlockIndex;
  final int broadcastAbortedAt;
  final String broadcastAbortedBlockIndex;

  @override
  SwapStateStatus get state => SwapStateStatus.broadcastAborted;

  BroadcastAborted({
    required super.egressType,
    required super.swapId,
    required super.depositAmount,
    required super.depositReceivedAt,
    required super.depositReceivedBlockIndex,
    required super.egressAmount,
    required super.egressScheduledAt,
    required super.egressScheduledBlockIndex,
    required this.broadcastRequestedAt,
    required this.broadcastRequestedBlockIndex,
    required this.broadcastAbortedAt,
    required this.broadcastAbortedBlockIndex,
  });

  // Converts JSON map to BroadcastAborted instance
  factory BroadcastAborted.fromJson(Map<String, dynamic> json) {
    return BroadcastAborted(
      egressType: json['egressType'],
      swapId: json['swapId'],
      depositAmount: json['depositAmount'],
      depositReceivedAt: json['depositReceivedAt'],
      depositReceivedBlockIndex: json['depositReceivedBlockIndex'],
      egressAmount: json['egressAmount'],
      egressScheduledAt: json['egressScheduledAt'],
      egressScheduledBlockIndex: json['egressScheduledBlockIndex'],
      broadcastRequestedAt: json['broadcastRequestedAt'],
      broadcastRequestedBlockIndex: json['broadcastRequestedBlockIndex'],
      broadcastAbortedAt: json['broadcastAbortedAt'],
      broadcastAbortedBlockIndex: json['broadcastAbortedBlockIndex'],
    );
  }

  // Converts BroadcastAborted instance to JSON map
  @override
  Map<String, dynamic> toJson() {
    return {
      'egressType': egressType,
      'swapId': swapId,
      'depositAmount': depositAmount,
      'depositReceivedAt': depositReceivedAt,
      'depositReceivedBlockIndex': depositReceivedBlockIndex,
      'egressAmount': egressAmount,
      'egressScheduledAt': egressScheduledAt,
      'egressScheduledBlockIndex': egressScheduledBlockIndex,
      'broadcastRequestedAt': broadcastRequestedAt,
      'broadcastRequestedBlockIndex': broadcastRequestedBlockIndex,
      'broadcastAbortedAt': broadcastAbortedAt,
      'broadcastAbortedBlockIndex': broadcastAbortedBlockIndex,
      'state': state, // Include the state in the JSON
    };
  }
}

class FailedIngressIgnored implements SwapState {
  final String failure = 'INGRESS_IGNORED';
  final ErrorDetails error;
  final String depositAmount;
  final int failedAt;
  final String failedBlockIndex;

  @override
  SwapStateStatus get state => SwapStateStatus.failed;

  const FailedIngressIgnored({
    required this.error,
    required this.depositAmount,
    required this.failedAt,
    required this.failedBlockIndex,
  });
  // Converts JSON map to FailedIngressIgnored instance
  factory FailedIngressIgnored.fromJson(Map<String, dynamic> json) {
    return FailedIngressIgnored(
      error: ErrorDetails.fromJson(json['error'] as Map<String, dynamic>),
      depositAmount: json['depositAmount'],
      failedAt: json['failedAt'],
      failedBlockIndex: json['failedBlockIndex'],
    );
  }

  // Converts FailedIngressIgnored instance to JSON map
  @override
  Map<String, dynamic> toJson() {
    return {
      'failure': failure, // Include the failure in the JSON
      'error': error.toJson(), // Convert ErrorDetails to JSON
      'depositAmount': depositAmount,
      'failedAt': failedAt,
      'failedBlockIndex': failedBlockIndex,
      'state': state, // Include the state in the JSON
    };
  }
}

class FailedEgressIgnored implements SwapState {
  final String failure = 'EGRESS_IGNORED';
  final ErrorDetails error;
  final String swapId;
  final String depositAmount;
  final int? depositReceivedAt;
  final String? depositReceivedBlockIndex;
  final String? intermediateAmount;
  final int swapExecutedAt;
  final String swapExecutedBlockIndex;
  final String ignoredEgressAmount;
  final int egressIgnoredAt;
  final String egressIgnoredBlockIndex;

  @override
  SwapStateStatus get state => SwapStateStatus.failed;

  const FailedEgressIgnored({
    required this.error,
    required this.swapId,
    required this.depositAmount,
    required this.depositReceivedAt,
    required this.depositReceivedBlockIndex,
    this.intermediateAmount,
    required this.swapExecutedAt,
    required this.swapExecutedBlockIndex,
    required this.ignoredEgressAmount,
    required this.egressIgnoredAt,
    required this.egressIgnoredBlockIndex,
  });
  // Converts JSON map to FailedEgressIgnored instance
  factory FailedEgressIgnored.fromJson(Map<String, dynamic> json) {
    return FailedEgressIgnored(
      error: ErrorDetails.fromJson(json['error'] as Map<String, dynamic>),
      swapId: json['swapId'],
      depositAmount: json['depositAmount'],
      depositReceivedAt: json['depositReceivedAt'],
      depositReceivedBlockIndex: json['depositReceivedBlockIndex'],
      intermediateAmount: json['intermediateAmount'],
      swapExecutedAt: json['swapExecutedAt'],
      swapExecutedBlockIndex: json['swapExecutedBlockIndex'],
      ignoredEgressAmount: json['ignoredEgressAmount'],
      egressIgnoredAt: json['egressIgnoredAt'],
      egressIgnoredBlockIndex: json['egressIgnoredBlockIndex'],
    );
  }

  // Converts FailedEgressIgnored instance to JSON map
  @override
  Map<String, dynamic> toJson() {
    return {
      'failure': failure, // Include the failure in the JSON
      'error': error.toJson(), // Convert ErrorDetails to JSON
      'swapId': swapId,
      'depositAmount': depositAmount,
      'depositReceivedAt': depositReceivedAt,
      'depositReceivedBlockIndex': depositReceivedBlockIndex,
      'intermediateAmount': intermediateAmount,
      'swapExecutedAt': swapExecutedAt,
      'swapExecutedBlockIndex': swapExecutedBlockIndex,
      'ignoredEgressAmount': ignoredEgressAmount,
      'egressIgnoredAt': egressIgnoredAt,
      'egressIgnoredBlockIndex': egressIgnoredBlockIndex,
      'state': state,
    };
  }
}

class FailedRefundEgressIgnored implements SwapState {
  final String failure = 'REFUND_EGRESS_IGNORED';
  final ErrorDetails error;
  final String swapId;
  final String depositAmount;
  final int? depositReceivedAt;
  final String? depositReceivedBlockIndex;
  final String ignoredEgressAmount;
  final int egressIgnoredAt;
  final String egressIgnoredBlockIndex;

  @override
  SwapStateStatus get state => SwapStateStatus.failed;

  const FailedRefundEgressIgnored({
    required this.error,
    required this.swapId,
    required this.depositAmount,
    required this.depositReceivedAt,
    required this.depositReceivedBlockIndex,
    required this.ignoredEgressAmount,
    required this.egressIgnoredAt,
    required this.egressIgnoredBlockIndex,
  });
  factory FailedRefundEgressIgnored.fromJson(Map<String, dynamic> json) {
    return FailedRefundEgressIgnored(
      error: ErrorDetails.fromJson(json['error'] as Map<String, dynamic>),
      swapId: json['swapId'],
      depositAmount: json['depositAmount'],
      depositReceivedAt: json['depositReceivedAt'],
      depositReceivedBlockIndex: json['depositReceivedBlockIndex'],
      ignoredEgressAmount: json['ignoredEgressAmount'],
      egressIgnoredAt: json['egressIgnoredAt'],
      egressIgnoredBlockIndex: json['egressIgnoredBlockIndex'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'failure': failure,
      'error': error.toJson(),
      'swapId': swapId,
      'depositAmount': depositAmount,
      'depositReceivedAt': depositReceivedAt,
      'depositReceivedBlockIndex': depositReceivedBlockIndex,
      'ignoredEgressAmount': ignoredEgressAmount,
      'egressIgnoredAt': egressIgnoredAt,
      'egressIgnoredBlockIndex': egressIgnoredBlockIndex,
      'state': state,
    };
  }
}

class SwapStatusResponseCommonFields {
  final String destAddress;
  final String? ccmDepositReceivedBlockIndex;
  final CcmParams? ccmParams;
  final List<ChainFlipFee> feesPaid;
  final num? estimatedDefaultDurationSeconds;
  final int? srcChainRequiredBlockConfirmations;
  final String? depositTransactionRef;
  final int? swapScheduledAt;
  final String? swapScheduledBlockIndex;
  final int? lastStatechainUpdateAt;
  final String? asset;
  final String? chain;

  final String? depositTransactionHash; // Optional field

  final CcmParams? ccmMetadata; // Optional field

  const SwapStatusResponseCommonFields({
    required this.destAddress,
    this.ccmDepositReceivedBlockIndex,
    this.ccmParams,
    this.asset,
    this.chain,
    required this.feesPaid,
    this.estimatedDefaultDurationSeconds,
    this.srcChainRequiredBlockConfirmations,
    this.depositTransactionRef,
    this.swapScheduledAt,
    this.swapScheduledBlockIndex,
    this.lastStatechainUpdateAt,
    this.depositTransactionHash,
    this.ccmMetadata,
  });

  // Converts JSON map to SwapStatusResponseCommonFields instance
  factory SwapStatusResponseCommonFields.fromJson(Map<String, dynamic> json) {
    return SwapStatusResponseCommonFields(
        destAddress: json['destAddress'],
        ccmDepositReceivedBlockIndex: json['ccmDepositReceivedBlockIndex'],
        ccmParams: json['ccmParams'] != null
            ? CcmParams.fromJson(json['ccmParams'] as Map<String, dynamic>)
            : null,
        feesPaid: (json['feesPaid'] as List?)
                ?.map((fee) => ChainFlipFee.fromJson(fee as Map<String, dynamic>))
                .toList() ??
            [],
        estimatedDefaultDurationSeconds:
            json.valueAsNum("estimatedDefaultDurationSeconds"),
        srcChainRequiredBlockConfirmations: json['srcChainRequiredBlockConfirmations'],
        depositTransactionRef: json['depositTransactionRef'],
        swapScheduledAt: json['swapScheduledAt'],
        swapScheduledBlockIndex: json['swapScheduledBlockIndex'],
        lastStatechainUpdateAt: json['lastStatechainUpdateAt'],
        depositTransactionHash: json['depositTransactionHash'],
        ccmMetadata: json['ccmMetadata'] != null
            ? CcmParams.fromJson(json['ccmMetadata'] as Map<String, dynamic>)
            : null,
        asset: json['asset'],
        chain: json['chain']);
  }

  Map<String, dynamic> toJson() {
    return {
      'destAddress': destAddress,
      'ccmDepositReceivedBlockIndex': ccmDepositReceivedBlockIndex,
      'ccmParams': ccmParams?.toJson(), // Convert CcmParams to JSON
      'feesPaid':
          feesPaid.map((fee) => fee.toJson()).toList(), // Convert List<SwapFee> to JSON
      'estimatedDefaultDurationSeconds': estimatedDefaultDurationSeconds,
      'srcChainRequiredBlockConfirmations': srcChainRequiredBlockConfirmations,
      'depositTransactionRef': depositTransactionRef,
      'swapScheduledAt': swapScheduledAt,
      'swapScheduledBlockIndex': swapScheduledBlockIndex,
      'lastStatechainUpdateAt': lastStatechainUpdateAt,
      'depositTransactionHash': depositTransactionHash,
      'ccmMetadata': ccmMetadata?.toJson(), // Convert CcmParams to JSON
    };
  }
}

class CcmParams {
  final String gasBudget;
  final String message;
  final String? additionalData;
  const CcmParams(
      {required this.additionalData, required this.gasBudget, required this.message});
  factory CcmParams.fromJson(Map<String, dynamic> json) {
    return CcmParams(
        additionalData: json["cfParameters"] ?? json["additionalData"],
        gasBudget: json["gasBudget"],
        message: json["message"]);
  }
  Map<String, dynamic> toJson() {
    return {"gasBudget": gasBudget, "message": message, "additionalData": additionalData};
  }
}

class DepositAddressFields extends SwapStatusResponseCommonFields {
  final String? depositAddress;
  final int? depositChannelCreatedAt;
  final int? depositChannelBrokerCommissionBps;
  final String? expectedDepositAmount; // Optional field
  final String depositChannelExpiryBlock;
  final int estimatedDepositChannelExpiryTime;
  final bool isDepositChannelExpired;
  final bool depositChannelOpenedThroughBackend;
  final List<DepositChannelAffiliateBroker>?
      depositChannelAffiliateBrokers; // Optional list
  final int depositChannelMaxBoostFeeBps;
  final int? effectiveBoostFeeBps; // Optional field
  final int? boostSkippedAt; // Optional field
  final String? boostSkippedBlockIndex; // Optional field
  final FillOrKillParams? fillOrKillParams;

  const DepositAddressFields({
    required this.depositAddress,
    required this.depositChannelCreatedAt,
    required this.depositChannelBrokerCommissionBps,
    this.expectedDepositAmount,
    required this.depositChannelExpiryBlock,
    required this.estimatedDepositChannelExpiryTime,
    required this.isDepositChannelExpired,
    required this.depositChannelOpenedThroughBackend,
    this.depositChannelAffiliateBrokers,
    required this.depositChannelMaxBoostFeeBps,
    this.effectiveBoostFeeBps,
    this.boostSkippedAt,
    this.boostSkippedBlockIndex,
    required this.fillOrKillParams,
    required super.destAddress,
    super.ccmDepositReceivedBlockIndex,
    super.ccmParams,
    required super.feesPaid,
    super.estimatedDefaultDurationSeconds,
    super.srcChainRequiredBlockConfirmations,
    super.depositTransactionRef,
    super.swapScheduledAt,
    super.swapScheduledBlockIndex,
    super.lastStatechainUpdateAt,
    super.depositTransactionHash,
    super.asset,
    super.chain,
    super.ccmMetadata,
  });

  // Converts JSON map to DepositAddressFields instance
  factory DepositAddressFields.fromJson(Map<String, dynamic> json) {
    return DepositAddressFields(
        depositAddress: json['depositAddress'],
        depositChannelCreatedAt: json['depositChannelCreatedAt'],
        depositChannelBrokerCommissionBps: json['depositChannelBrokerCommissionBps'],
        expectedDepositAmount: json['expectedDepositAmount'],
        depositChannelExpiryBlock: json['depositChannelExpiryBlock'],
        estimatedDepositChannelExpiryTime: json['estimatedDepositChannelExpiryTime'],
        isDepositChannelExpired: json['isDepositChannelExpired'] as bool,
        depositChannelOpenedThroughBackend:
            json['depositChannelOpenedThroughBackend'] as bool,
        depositChannelAffiliateBrokers: (json['depositChannelAffiliateBrokers']
                as List<dynamic>?)
            ?.map((broker) =>
                DepositChannelAffiliateBroker.fromJson(broker as Map<String, dynamic>))
            .toList(),
        depositChannelMaxBoostFeeBps: json['depositChannelMaxBoostFeeBps'],
        effectiveBoostFeeBps: json['effectiveBoostFeeBps'],
        boostSkippedAt: json['boostSkippedAt'],
        boostSkippedBlockIndex: json['boostSkippedBlockIndex'],
        fillOrKillParams: json['fillOrKillParams'] == null
            ? null
            : FillOrKillParams.fromJson(json['fillOrKillParams'] as Map<String, dynamic>),
        destAddress: json['destAddress'],
        ccmDepositReceivedBlockIndex: json['ccmDepositReceivedBlockIndex'],
        ccmParams: json['ccmParams'] != null
            ? CcmParams.fromJson(json['ccmParams'] as Map<String, dynamic>)
            : null,
        feesPaid: (json['feesPaid'] as List<dynamic>)
            .map((fee) => ChainFlipFee.fromJson(fee as Map<String, dynamic>))
            .toList(),
        estimatedDefaultDurationSeconds: json['estimatedDefaultDurationSeconds'],
        srcChainRequiredBlockConfirmations: json['srcChainRequiredBlockConfirmations'],
        depositTransactionRef: json['depositTransactionRef'],
        swapScheduledAt: json['swapScheduledAt'],
        swapScheduledBlockIndex: json['swapScheduledBlockIndex'],
        lastStatechainUpdateAt: json['lastStatechainUpdateAt'],
        depositTransactionHash: json['depositTransactionHash'],
        ccmMetadata: json['ccmMetadata'] != null
            ? CcmParams.fromJson(json['ccmMetadata'] as Map<String, dynamic>)
            : null,
        chain: json["chain"],
        asset: json["asset"]);
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'depositAddress': depositAddress,
      'depositChannelCreatedAt': depositChannelCreatedAt,
      'depositChannelBrokerCommissionBps': depositChannelBrokerCommissionBps,
      'expectedDepositAmount': expectedDepositAmount,
      'depositChannelExpiryBlock': depositChannelExpiryBlock,
      'estimatedDepositChannelExpiryTime': estimatedDepositChannelExpiryTime,
      'isDepositChannelExpired': isDepositChannelExpired,
      'depositChannelOpenedThroughBackend': depositChannelOpenedThroughBackend,
      'depositChannelAffiliateBrokers':
          depositChannelAffiliateBrokers?.map((broker) => broker.toJson()).toList(),
      'depositChannelMaxBoostFeeBps': depositChannelMaxBoostFeeBps,
      'effectiveBoostFeeBps': effectiveBoostFeeBps,
      'boostSkippedAt': boostSkippedAt,
      'boostSkippedBlockIndex': boostSkippedBlockIndex,
      'fillOrKillParams': fillOrKillParams?.toJson(), // Convert FillOrKillParams to JSON
      // Include fields from the superclass as well
      'destAddress': destAddress,
      'ccmDepositReceivedBlockIndex': ccmDepositReceivedBlockIndex,
      'ccmParams': ccmParams?.toJson(), // Convert CcmParams to JSON
      'feesPaid':
          feesPaid.map((fee) => fee.toJson()).toList(), // Convert List<SwapFee> to JSON
      'estimatedDefaultDurationSeconds': estimatedDefaultDurationSeconds,
      'srcChainRequiredBlockConfirmations': srcChainRequiredBlockConfirmations,
      'depositTransactionRef': depositTransactionRef,
      'swapScheduledAt': swapScheduledAt,
      'swapScheduledBlockIndex': swapScheduledBlockIndex,
      'lastStatechainUpdateAt': lastStatechainUpdateAt,
      'depositTransactionHash': depositTransactionHash,
      'ccmMetadata': ccmMetadata?.toJson(), // Convert CcmParams to JSON
    };
  }
}

class DepositChannelAffiliateBroker {
  final String account;
  final int commissionBps;

  const DepositChannelAffiliateBroker({
    required this.account,
    required this.commissionBps,
  });

  factory DepositChannelAffiliateBroker.fromJson(Map<String, dynamic> json) {
    return DepositChannelAffiliateBroker(
      account: json['account'],
      commissionBps: json['commissionBps'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'account': account,
      'commissionBps': commissionBps,
    };
  }
}

class FailedVaultSwapStatusResponse extends DepositAddressFields {
  final String depositAmount;
  final ErrorDetails error;
  final int failedAt;
  final String failedBlockIndex;
  final String failure;
  final String srcAsset;
  final String srcChain;

  const FailedVaultSwapStatusResponse({
    required this.depositAmount,
    required super.destAddress,
    required this.error,
    required this.failedAt,
    required this.failedBlockIndex,
    required this.failure,
    required this.srcAsset,
    required this.srcChain,
    required super.depositAddress,
    required super.depositChannelCreatedAt,
    required super.depositChannelBrokerCommissionBps,
    super.expectedDepositAmount,
    required super.depositChannelExpiryBlock,
    required super.estimatedDepositChannelExpiryTime,
    required super.isDepositChannelExpired,
    required super.depositChannelOpenedThroughBackend,
    required String asset,
    required String chain,
    super.depositChannelAffiliateBrokers,
    required super.depositChannelMaxBoostFeeBps,
    super.effectiveBoostFeeBps,
    super.boostSkippedAt,
    super.boostSkippedBlockIndex,
    required FillOrKillParams super.fillOrKillParams,
    super.ccmDepositReceivedBlockIndex,
    super.ccmParams,
    required List<ChainFlipSwapFee> super.feesPaid,
    super.estimatedDefaultDurationSeconds,
    super.srcChainRequiredBlockConfirmations,
    super.depositTransactionRef,
    super.swapScheduledAt,
    super.swapScheduledBlockIndex,
    super.lastStatechainUpdateAt,
    super.depositTransactionHash,
    super.ccmMetadata,
  });

  factory FailedVaultSwapStatusResponse.fromJson(Map<String, dynamic> json) {
    return FailedVaultSwapStatusResponse(
      depositAmount: json['depositAmount'],
      destAddress: json['destAddress'],
      error: ErrorDetails.fromJson(json['error']),
      failedAt: json['failedAt'],
      failedBlockIndex: json['failedBlockIndex'],
      failure: json['failure'],
      feesPaid: [],
      chain: json["chain"],
      asset: json["asset"],
      srcAsset: json['srcAsset'],
      srcChain: json['srcChain'],
      ccmDepositReceivedBlockIndex: json['ccmDepositReceivedBlockIndex'],
      ccmParams: json['ccmParams'] != null
          ? CcmParams.fromJson(json['ccmParams'] as Map<String, dynamic>)
          : null,
      estimatedDefaultDurationSeconds: json['estimatedDefaultDurationSeconds'],
      srcChainRequiredBlockConfirmations: json['srcChainRequiredBlockConfirmations'],
      depositTransactionRef: json['depositTransactionRef'],
      swapScheduledAt: json['swapScheduledAt'],
      swapScheduledBlockIndex: json['swapScheduledBlockIndex'],
      lastStatechainUpdateAt: json['lastStatechainUpdateAt'],
      depositTransactionHash: json['depositTransactionHash'],
      ccmMetadata: json['ccmMetadata'] != null
          ? CcmParams.fromJson(json['ccmMetadata'] as Map<String, dynamic>)
          : null,
      depositAddress: json['depositAddress'],
      depositChannelCreatedAt: json['depositChannelCreatedAt'],
      depositChannelBrokerCommissionBps: json['depositChannelBrokerCommissionBps'],
      expectedDepositAmount: json['expectedDepositAmount'],
      depositChannelExpiryBlock: json['depositChannelExpiryBlock'],
      estimatedDepositChannelExpiryTime: json['estimatedDepositChannelExpiryTime'],
      isDepositChannelExpired: json['isDepositChannelExpired'] as bool,
      depositChannelOpenedThroughBackend:
          json['depositChannelOpenedThroughBackend'] as bool,
      depositChannelAffiliateBrokers:
          (json['depositChannelAffiliateBrokers'] as List<dynamic>?)
              ?.map((broker) =>
                  DepositChannelAffiliateBroker.fromJson(broker as Map<String, dynamic>))
              .toList(),
      depositChannelMaxBoostFeeBps: json['depositChannelMaxBoostFeeBps'],
      effectiveBoostFeeBps: json['effectiveBoostFeeBps'],
      boostSkippedAt: json['boostSkippedAt'],
      boostSkippedBlockIndex: json['boostSkippedBlockIndex'],
      fillOrKillParams:
          FillOrKillParams.fromJson(json['fillOrKillParams'] as Map<String, dynamic>),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'depositAmount': depositAmount,
      'destAddress': destAddress,
      'error': {
        'name': error.name,
        'message': error.message,
      },
      'failedAt': failedAt,
      'failedBlockIndex': failedBlockIndex,
      'failure': failure,
      'feesPaid': feesPaid,
      'srcAsset': srcAsset,
      'srcChain': srcChain,
      'ccmDepositReceivedBlockIndex': ccmDepositReceivedBlockIndex,
      'ccmParams': ccmParams?.toJson(),
      'estimatedDefaultDurationSeconds': estimatedDefaultDurationSeconds,
      'srcChainRequiredBlockConfirmations': srcChainRequiredBlockConfirmations,
      'depositTransactionRef': depositTransactionRef,
      'swapScheduledAt': swapScheduledAt,
      'swapScheduledBlockIndex': swapScheduledBlockIndex,
      'lastStatechainUpdateAt': lastStatechainUpdateAt,
      'depositTransactionHash': depositTransactionHash,
      'ccmMetadata': ccmMetadata?.toJson(),
    };
  }
}

class VaultSwapResponse {
  final DepositAddressFields deposit;
  final SwapState state;
  const VaultSwapResponse({required this.deposit, required this.state});
  factory VaultSwapResponse.fromJson(Map<String, dynamic> json) {
    return VaultSwapResponse(
        deposit: DepositAddressFields.fromJson(json), state: SwapState.fromJson(json));
  }
}

class VaultSwapResponse2 {
  final SwapStatusResponseCommonFields deposit;
  final SwapState state;
  const VaultSwapResponse2({required this.deposit, required this.state});
  factory VaultSwapResponse2.fromJson(Map<String, dynamic> json) {
    return VaultSwapResponse2(
        deposit: SwapStatusResponseCommonFields.fromJson(json),
        state: SwapState.fromJson(json));
  }
}

class QuoteType {
  final String name;
  const QuoteType._(this.name);
  static const QuoteType regular = QuoteType._("REGULAR");
  static const QuoteType dca = QuoteType._("DCA");
  static List<QuoteType> get values => [regular, dca];
  static QuoteType fromName(String? name) {
    return values.firstWhere(
      (e) => e.name == name,
      orElse: () => throw DartOnChainSwapPluginException("Quote type not found.",
          details: {"type": name}),
    );
  }
}

class QuoteEstimatedDurationsInfo {
  final num deposit;
  final num swap;
  final num egress;
  const QuoteEstimatedDurationsInfo(
      {required this.deposit, required this.swap, required this.egress});
  factory QuoteEstimatedDurationsInfo.fromJson(Map<String, dynamic> json) {
    return QuoteEstimatedDurationsInfo(
        deposit: json.valueAsNum("deposit"),
        swap: json.valueAsNum("swap"),
        egress: json.valueAsNum("egress"));
  }
  Map<String, dynamic> toJson() {
    return {"deposit": deposit, "swap": swap, "egress": egress};
  }
}

class QuoteDetails {
  final String? intermediateAmount;
  final num recommendedSlippageTolerancePercent;
  final String egressAmount;
  final String depositAmount;
  final List<ChainFlipSwapFee> includedFees;
  final List<PoolInfo> poolInfo;
  final bool? lowLiquidityWarning;
  final num estimatedDurationSeconds;
  final String estimatedPrice;
  final QuoteType type;
  final DCAParams? dcaParams;
  final QuoteEstimatedDurationsInfo estimatedDurationsSeconds;
  final UncheckedAssetAndChain srcAsset;
  final UncheckedAssetAndChain destAsset;
  final bool isVaultSwap;

  const QuoteDetails({
    required this.intermediateAmount,
    required this.egressAmount,
    required this.includedFees,
    required this.poolInfo,
    this.lowLiquidityWarning,
    required this.estimatedDurationSeconds,
    required this.estimatedPrice,
    required this.type,
    required this.estimatedDurationsSeconds,
    required this.recommendedSlippageTolerancePercent,
    required this.srcAsset,
    required this.destAsset,
    required this.depositAmount,
    required this.isVaultSwap,
    this.dcaParams,
  });
  QuoteDetails.fromJson(Map<String, dynamic> json)
      : intermediateAmount = json.valueAs("intermediateAmount"),
        egressAmount = json.valueAs("egressAmount"),
        includedFees = json
            .valueEnsureAsList<Map<String, dynamic>>("includedFees")
            .map(ChainFlipSwapFee.fromJson)
            .toList(),
        poolInfo = json
            .valueEnsureAsList<Map<String, dynamic>>("poolInfo")
            .map(PoolInfo.fromJson)
            .toList(),
        lowLiquidityWarning = json.valueAs("lowLiquidityWarning"),
        estimatedDurationSeconds = json.valueAsNum("estimatedDurationSeconds"),
        estimatedPrice = json.valueAs("estimatedPrice"),
        type = QuoteType.fromName(json.valueAs("type")),
        dcaParams = json.valueTo<DCAParams?, Map<String, dynamic>>(
            key: "dcaParams", parse: DCAParams.fromJson),
        estimatedDurationsSeconds = QuoteEstimatedDurationsInfo.fromJson(
          json.valueEnsureAsMap<String, dynamic>("estimatedDurationsSeconds"),
        ),
        recommendedSlippageTolerancePercent =
            json.valueAsNum("recommendedSlippageTolerancePercent"),
        srcAsset = UncheckedAssetAndChain.fromJson(
            json.valueEnsureAsMap<String, dynamic>("srcAsset")),
        destAsset = UncheckedAssetAndChain.fromJson(
            json.valueEnsureAsMap<String, dynamic>("destAsset")),
        depositAmount = json.valueAs("depositAmount"),
        isVaultSwap = json.valueAs<bool?>("isVaultSwap") ?? false;

  // Method to convert QuoteDetails object to JSON
  Map<String, dynamic> toJson() {
    return {
      "srcAsset": srcAsset.toJson(),
      "destAsset": destAsset.toJson(),
      "isVaultSwap": isVaultSwap,
      "depositAmount": depositAmount,
      if (intermediateAmount != null) 'intermediateAmount': intermediateAmount,
      "recommendedSlippageTolerancePercent": recommendedSlippageTolerancePercent,
      'egressAmount': egressAmount,
      'includedFees': includedFees.map((fee) => fee.toJson()).toList(),
      'poolInfo': poolInfo.map((info) => info.toJson()).toList(),
      if (lowLiquidityWarning != null) 'lowLiquidityWarning': lowLiquidityWarning,
      'estimatedDurationSeconds': estimatedDurationSeconds,
      "estimatedDurationsSeconds": estimatedDurationsSeconds.toJson(),
      'estimatedPrice': estimatedPrice,
      'type': type.name,
      if (type == QuoteType.dca) 'dcaParams': dcaParams?.toJson(),
    };
  }
}

class QuoteBoostedDetails extends QuoteDetails {
  final int estimatedBoostFeeBps;
  final int maxBoostFeeBps;
  QuoteBoostedDetails(
      {required super.intermediateAmount,
      required super.egressAmount,
      required super.includedFees,
      required super.poolInfo,
      required super.estimatedDurationSeconds,
      required super.estimatedPrice,
      required super.type,
      required super.dcaParams,
      required super.estimatedDurationsSeconds,
      required super.lowLiquidityWarning,
      required this.maxBoostFeeBps,
      required this.estimatedBoostFeeBps,
      required super.recommendedSlippageTolerancePercent,
      required super.destAsset,
      required super.srcAsset,
      required super.depositAmount,
      required super.isVaultSwap});
  QuoteBoostedDetails.fromJson(super.json)
      : maxBoostFeeBps = json.valueAs("maxBoostFeeBps"),
        estimatedBoostFeeBps = json.valueAs("estimatedBoostFeeBps"),
        super.fromJson();
  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      "maxBoostFeeBps": maxBoostFeeBps,
      "estimatedBoostFeeBps": estimatedBoostFeeBps
    };
  }
}

class PoolInfo {
  final UncheckedAssetAndChain baseAsset;
  final UncheckedAssetAndChain quoteAsset;
  final ChainFlipPoolFee fee;

  const PoolInfo({
    required this.baseAsset,
    required this.quoteAsset,
    required this.fee,
  });

  factory PoolInfo.fromJson(Map<String, dynamic> json) {
    return PoolInfo(
      baseAsset: UncheckedAssetAndChain.fromJson(json['baseAsset']),
      quoteAsset: UncheckedAssetAndChain.fromJson(json['quoteAsset']),
      fee: ChainFlipPoolFee.fromJson(json['fee']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'baseAsset': baseAsset.toJson(),
      'quoteAsset': quoteAsset.toJson(),
      'fee': fee.toJson(),
    };
  }
}

class QuoteQueryResponse extends QuoteDetails {
  final QuoteBoostedDetails? boostQuote;

  QuoteQueryResponse(
      {required super.intermediateAmount,
      required super.egressAmount,
      required super.includedFees,
      required super.poolInfo,
      required super.estimatedDurationSeconds,
      required super.estimatedPrice,
      required super.type,
      required super.estimatedDurationsSeconds,
      required super.dcaParams,
      required super.lowLiquidityWarning,
      required super.recommendedSlippageTolerancePercent,
      required super.srcAsset,
      required super.destAsset,
      this.boostQuote,
      required super.depositAmount,
      required super.isVaultSwap});
  QuoteQueryResponse.fromJson(super.json)
      : boostQuote = json.valueTo<QuoteBoostedDetails?, Map<String, dynamic>>(
            key: "boostQuote", parse: QuoteBoostedDetails.fromJson),
        super.fromJson();
  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      if (boostQuote != null) "boostQuote": boostQuote?.toJson()
    };
  }
}
