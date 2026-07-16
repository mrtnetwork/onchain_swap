import 'package:blockchain_utils/exception/exceptions.dart';
import 'package:on_chain_swap/src/exception/exception.dart';
import 'package:on_chain_swap/src/providers/cf/models/models/backend.dart';
import 'package:on_chain_swap/src/providers/cf/models/models/rpc.dart';

class Failure {
  final int failedAt;
  final String failedBlockIndex;
  final String mode;
  final Reason reason;

  Failure({
    required this.failedAt,
    required this.failedBlockIndex,
    required this.mode,
    required this.reason,
  });

  factory Failure.fromJson(Map<String, dynamic> json) {
    return Failure(
      failedAt: json['failedAt'],
      failedBlockIndex: json['failedBlockIndex'],
      mode: json['mode'],
      reason: Reason.fromJson(json['reason']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'failedAt': failedAt,
      'failedBlockIndex': failedBlockIndex,
      'mode': mode,
      'reason': reason.toJson(),
    };
  }
}

class Reason {
  final String code;
  final String message;

  Reason({
    required this.code,
    required this.message,
  });

  factory Reason.fromJson(Map<String, dynamic> json) {
    return Reason(
      code: json['code'],
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'message': message,
    };
  }
}

class Boost {
  final int maxBoostFeeBps;
  final int? effectiveBoostFeeBps;
  final int? boostedAt;
  final String? boostedBlockIndex;
  final int? skippedAt;
  final String? skippedBlockIndex;

  Boost({
    required this.maxBoostFeeBps,
    this.effectiveBoostFeeBps,
    this.boostedAt,
    this.boostedBlockIndex,
    this.skippedAt,
    this.skippedBlockIndex,
  });

  factory Boost.fromJson(Map<String, dynamic> json) {
    return Boost(
      maxBoostFeeBps: json['maxBoostFeeBps'],
      effectiveBoostFeeBps: json['effectiveBoostFeeBps'],
      boostedAt: json['boostedAt'],
      boostedBlockIndex: json['boostedBlockIndex'],
      skippedAt: json['skippedAt'],
      skippedBlockIndex: json['skippedBlockIndex'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'maxBoostFeeBps': maxBoostFeeBps,
      'effectiveBoostFeeBps': effectiveBoostFeeBps,
      'boostedAt': boostedAt,
      'boostedBlockIndex': boostedBlockIndex,
      'skippedAt': skippedAt,
      'skippedBlockIndex': skippedBlockIndex,
    };
  }
}

class DepositChannelFields {
  final String id;
  final int createdAt;
  final int brokerCommissionBps;
  final String depositAddress;
  final String srcChainExpiryBlock;
  final int estimatedExpiryTime;
  final String? expectedDepositAmount;
  final bool isExpired;
  final bool openedThroughBackend;
  final List<AffiliateBroker> affiliateBrokers;
  final FillOrKillParams? fillOrKillParams;
  final DCAParams? dcaParams;

  DepositChannelFields({
    required this.id,
    required this.createdAt,
    required this.brokerCommissionBps,
    required this.depositAddress,
    required this.srcChainExpiryBlock,
    required this.estimatedExpiryTime,
    this.expectedDepositAmount,
    required this.isExpired,
    required this.openedThroughBackend,
    required this.affiliateBrokers,
    this.fillOrKillParams,
    this.dcaParams,
  });

  factory DepositChannelFields.fromJson(Map<String, dynamic> json) {
    return DepositChannelFields(
      id: json['id'],
      createdAt: json['createdAt'],
      brokerCommissionBps: json['brokerCommissionBps'],
      depositAddress: json['depositAddress'],
      srcChainExpiryBlock: json['srcChainExpiryBlock'],
      estimatedExpiryTime: json['estimatedExpiryTime'],
      expectedDepositAmount: json['expectedDepositAmount'],
      isExpired: json['isExpired'],
      openedThroughBackend: json['openedThroughBackend'],
      affiliateBrokers: (json['affiliateBrokers'] as List)
          .map((e) => AffiliateBroker.fromJson(e))
          .toList(),
      fillOrKillParams: json['fillOrKillParams'] != null
          ? FillOrKillParams.fromJson(json['fillOrKillParams'])
          : null,
      dcaParams: json['dcaParams'] != null
          ? DCAParams.fromJson(json['dcaParams'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': createdAt,
      'brokerCommissionBps': brokerCommissionBps,
      'depositAddress': depositAddress,
      'srcChainExpiryBlock': srcChainExpiryBlock,
      'estimatedExpiryTime': estimatedExpiryTime,
      'expectedDepositAmount': expectedDepositAmount,
      'isExpired': isExpired,
      'openedThroughBackend': openedThroughBackend,
      'affiliateBrokers': affiliateBrokers.map((e) => e.toJson()).toList(),
      'fillOrKillParams': fillOrKillParams?.toJson(),
      'dcaParams': dcaParams?.toJson(),
    };
  }
}

class DepositFields {
  final String amount;
  final String? txRef;
  final int? txConfirmations;
  final int? witnessedAt;
  final String? witnessedBlockIndex;
  final Failure? failure;
  final int? failedAt;
  final String? failedBlockIndex;

  DepositFields({
    required this.amount,
    this.txRef,
    this.txConfirmations,
    this.witnessedAt,
    this.witnessedBlockIndex,
    this.failure,
    this.failedAt,
    this.failedBlockIndex,
  });

  factory DepositFields.fromJson(Map<String, dynamic> json) {
    return DepositFields(
      amount: json['amount'],
      txRef: json['txRef'],
      txConfirmations: json['txConfirmations'],
      witnessedAt: json['witnessedAt'],
      witnessedBlockIndex: json['witnessedBlockIndex'],
      failure:
          json['failure'] != null ? Failure.fromJson(json['failure']) : null,
      failedAt: json['failedAt'],
      failedBlockIndex: json['failedBlockIndex'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'txRef': txRef,
      'txConfirmations': txConfirmations,
      'witnessedAt': witnessedAt,
      'witnessedBlockIndex': witnessedBlockIndex,
      'failure': failure?.toJson(),
      'failedAt': failedAt,
      'failedBlockIndex': failedBlockIndex,
    };
  }
}

class ChunkInfo {
  final String inputAmount;
  final String? intermediateAmount;
  final String? outputAmount;
  final int scheduledAt;
  final String scheduledBlockIndex;
  final int? executedAt;
  final String? executedBlockIndex;
  final int retryCount;

  ChunkInfo({
    required this.inputAmount,
    this.intermediateAmount,
    this.outputAmount,
    required this.scheduledAt,
    required this.scheduledBlockIndex,
    this.executedAt,
    this.executedBlockIndex,
    required this.retryCount,
  });

  factory ChunkInfo.fromJson(Map<String, dynamic> json) {
    return ChunkInfo(
      inputAmount: json['inputAmount'],
      intermediateAmount: json['intermediateAmount'],
      outputAmount: json['outputAmount'],
      scheduledAt: json['scheduledAt'],
      scheduledBlockIndex: json['scheduledBlockIndex'],
      executedAt: json['executedAt'],
      executedBlockIndex: json['executedBlockIndex'],
      retryCount: json['retryCount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'inputAmount': inputAmount,
      'intermediateAmount': intermediateAmount,
      'outputAmount': outputAmount,
      'scheduledAt': scheduledAt,
      'scheduledBlockIndex': scheduledBlockIndex,
      'executedAt': executedAt,
      'executedBlockIndex': executedBlockIndex,
      'retryCount': retryCount,
    };
  }
}

class DcaInfo {
  final ChunkInfo? lastExecutedChunk;
  final ChunkInfo? currentChunk;
  final int executedChunks;
  final int remainingChunks;

  DcaInfo({
    this.lastExecutedChunk,
    this.currentChunk,
    required this.executedChunks,
    required this.remainingChunks,
  });

  factory DcaInfo.fromJson(Map<String, dynamic> json) {
    return DcaInfo(
      lastExecutedChunk: json['lastExecutedChunk'] != null
          ? ChunkInfo.fromJson(json['lastExecutedChunk'])
          : null,
      currentChunk: json['currentChunk'] != null
          ? ChunkInfo.fromJson(json['currentChunk'])
          : null,
      executedChunks: json['executedChunks'],
      remainingChunks: json['remainingChunks'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lastExecutedChunk': lastExecutedChunk?.toJson(),
      'currentChunk': currentChunk?.toJson(),
      'executedChunks': executedChunks,
      'remainingChunks': remainingChunks,
    };
  }
}

class SwapFields {
  final String originalInputAmount;
  final String remainingInputAmount;
  final String swappedInputAmount;
  final String swappedIntermediateAmount;
  final String swappedOutputAmount;
  final ChunkInfo? regular;
  final DcaInfo? dca;

  SwapFields({
    required this.originalInputAmount,
    required this.remainingInputAmount,
    required this.swappedInputAmount,
    required this.swappedIntermediateAmount,
    required this.swappedOutputAmount,
    this.regular,
    this.dca,
  });

  factory SwapFields.fromJson(Map<String, dynamic> json) {
    return SwapFields(
      originalInputAmount: json['originalInputAmount'],
      remainingInputAmount: json['remainingInputAmount'],
      swappedInputAmount: json['swappedInputAmount'],
      swappedIntermediateAmount: json['swappedIntermediateAmount'],
      swappedOutputAmount: json['swappedOutputAmount'],
      regular:
          json['regular'] != null ? ChunkInfo.fromJson(json['regular']) : null,
      dca: json['dca'] != null ? DcaInfo.fromJson(json['dca']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'originalInputAmount': originalInputAmount,
      'remainingInputAmount': remainingInputAmount,
      'swappedInputAmount': swappedInputAmount,
      'swappedIntermediateAmount': swappedIntermediateAmount,
      'swappedOutputAmount': swappedOutputAmount,
      'regular': regular?.toJson(),
      'dca': dca?.toJson(),
    };
  }
}

class EgressFields {
  final String amount;
  final int? scheduledAt;
  final String? scheduledBlockIndex;
  final String? txRef;
  final int? witnessedAt;
  final String? witnessedBlockIndex;
  final Failure? failure;
  final int? failedAt;
  final String? failedBlockIndex;

  EgressFields({
    required this.amount,
    this.scheduledAt,
    this.scheduledBlockIndex,
    this.txRef,
    this.witnessedAt,
    this.witnessedBlockIndex,
    this.failure,
    this.failedAt,
    this.failedBlockIndex,
  });

  factory EgressFields.fromJson(Map<String, dynamic> json) {
    return EgressFields(
      amount: json['amount'],
      scheduledAt: json['scheduledAt'],
      scheduledBlockIndex: json['scheduledBlockIndex'],
      txRef: json['txRef'],
      witnessedAt: json['witnessedAt'],
      witnessedBlockIndex: json['witnessedBlockIndex'],
      failure:
          json['failure'] != null ? Failure.fromJson(json['failure']) : null,
      failedAt: json['failedAt'],
      failedBlockIndex: json['failedBlockIndex'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'scheduledAt': scheduledAt,
      'scheduledBlockIndex': scheduledBlockIndex,
      'txRef': txRef,
      'witnessedAt': witnessedAt,
      'witnessedBlockIndex': witnessedBlockIndex,
      'failure': failure?.toJson(),
      'failedAt': failedAt,
      'failedBlockIndex': failedBlockIndex,
    };
  }
}

class SwapStatusResponseCommonFields {
  final String swapId;
  final String destAddress;
  final DepositChannelFields? depositChannel;
  final CcmParams? ccmParams;
  final Boost? boost;
  final num? estimatedDurationSeconds;
  final int? srcChainRequiredBlockConfirmations;
  final List<ChainFlipFee> fees;
  final int? lastStatechainUpdateAt;

  const SwapStatusResponseCommonFields({
    required this.swapId,
    required this.destAddress,
    this.depositChannel,
    this.ccmParams,
    this.boost,
    this.estimatedDurationSeconds,
    this.srcChainRequiredBlockConfirmations,
    required this.fees,
    this.lastStatechainUpdateAt,
  });

  factory SwapStatusResponseCommonFields.fromJson(Map<String, dynamic> json) {
    return SwapStatusResponseCommonFields(
      swapId: json['swapId'],
      destAddress: json['destAddress'],
      depositChannel: json['depositChannel'] != null
          ? DepositChannelFields.fromJson(json['depositChannel'])
          : null,
      ccmParams: json['ccmParams'] != null
          ? CcmParams.fromJson(json['ccmParams'])
          : null,
      boost: json['boost'] != null ? Boost.fromJson(json['boost']) : null,
      estimatedDurationSeconds: json['estimatedDurationSeconds'],
      srcChainRequiredBlockConfirmations:
          json['srcChainRequiredBlockConfirmations'],
      fees:
          (json['fees'] as List).map((e) => ChainFlipFee.fromJson(e)).toList(),
      lastStatechainUpdateAt: json['lastStatechainUpdateAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'swapId': swapId,
      'destAddress': destAddress,
      'depositChannel': depositChannel?.toJson(),
      'ccmParams': ccmParams?.toJson(),
      'boost': boost?.toJson(),
      'estimatedDurationSeconds': estimatedDurationSeconds,
      'srcChainRequiredBlockConfirmations': srcChainRequiredBlockConfirmations,
      'fees': fees.map((e) => e.toJson()).toList(),
      'lastStatechainUpdateAt': lastStatechainUpdateAt,
    };
  }
}

class Waiting extends SwapStatusResponseCommonFields
    implements SwapStatusResponseV2 {
  const Waiting({
    required super.swapId,
    required super.destAddress,
    required DepositChannelFields super.depositChannel,
    required this.state,
    super.ccmParams,
    super.boost,
    super.estimatedDurationSeconds,
    super.srcChainRequiredBlockConfirmations,
    required super.fees,
    super.lastStatechainUpdateAt,
  }) : super();

  factory Waiting.fromJson(Map<String, dynamic> json) {
    return Waiting(
        swapId: json['swapId'],
        destAddress: json['destAddress'],
        depositChannel: DepositChannelFields.fromJson(json['depositChannel']),
        ccmParams: json['ccmParams'] != null
            ? CcmParams.fromJson(json['ccmParams'])
            : null,
        boost: json['boost'] != null ? Boost.fromJson(json['boost']) : null,
        estimatedDurationSeconds: json['estimatedDurationSeconds'],
        srcChainRequiredBlockConfirmations:
            json['srcChainRequiredBlockConfirmations'],
        fees: (json['fees'] as List)
            .map((e) => ChainFlipFee.fromJson(e))
            .toList(),
        lastStatechainUpdateAt: json['lastStatechainUpdateAt'],
        state: json["state"]);
  }

  @override
  Map<String, dynamic> toJson() {
    final data = super.toJson();
    data['depositChannel'] = depositChannel?.toJson();
    return data;
  }

  @override
  final String state;

  @override
  T cast<T extends SwapStatusResponseV2>() {
    if (this is T) {
      return this as T;
    }
    throw CastFailedException<T>();
  }
}

class Receiving extends SwapStatusResponseCommonFields
    implements SwapStatusResponseV2 {
  final DepositFields deposit;

  @override
  final String state;

  Receiving({
    required super.swapId,
    required super.destAddress,
    required this.deposit,
    required this.state,
    super.depositChannel,
    super.ccmParams,
    super.boost,
    super.estimatedDurationSeconds,
    super.srcChainRequiredBlockConfirmations,
    required super.fees,
    super.lastStatechainUpdateAt,
  });

  factory Receiving.fromJson(Map<String, dynamic> json) {
    return Receiving(
      swapId: json['swapId'],
      destAddress: json['destAddress'],
      deposit: DepositFields.fromJson(json['deposit']),
      state: json["state"],
      depositChannel: json['depositChannel'] != null
          ? DepositChannelFields.fromJson(json['depositChannel'])
          : null,
      ccmParams: json['ccmParams'] != null
          ? CcmParams.fromJson(json['ccmParams'])
          : null,
      boost: json['boost'] != null ? Boost.fromJson(json['boost']) : null,
      estimatedDurationSeconds: json['estimatedDurationSeconds'],
      srcChainRequiredBlockConfirmations:
          json['srcChainRequiredBlockConfirmations'],
      fees:
          (json['fees'] as List).map((e) => ChainFlipFee.fromJson(e)).toList(),
      lastStatechainUpdateAt: json['lastStatechainUpdateAt'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final data = super.toJson();
    data['deposit'] = deposit.toJson();
    return data;
  }

  @override
  T cast<T extends SwapStatusResponseV2>() {
    if (this is T) {
      return this as T;
    }
    throw CastFailedException<T>();
  }
}

class Swapping extends Receiving {
  final SwapFields swap;

  Swapping({
    required super.swapId,
    required super.destAddress,
    required super.deposit,
    required this.swap,
    required super.state,
    super.depositChannel,
    super.ccmParams,
    super.boost,
    super.estimatedDurationSeconds,
    super.srcChainRequiredBlockConfirmations,
    required super.fees,
    super.lastStatechainUpdateAt,
  });

  factory Swapping.fromJson(Map<String, dynamic> json) {
    return Swapping(
      swapId: json['swapId'],
      destAddress: json['destAddress'],
      deposit: DepositFields.fromJson(json['deposit']),
      swap: SwapFields.fromJson(json['swap']),
      state: json["state"],
      depositChannel: json['depositChannel'] != null
          ? DepositChannelFields.fromJson(json['depositChannel'])
          : null,
      ccmParams: json['ccmParams'] != null
          ? CcmParams.fromJson(json['ccmParams'])
          : null,
      boost: json['boost'] != null ? Boost.fromJson(json['boost']) : null,
      estimatedDurationSeconds: json['estimatedDurationSeconds'],
      srcChainRequiredBlockConfirmations:
          json['srcChainRequiredBlockConfirmations'],
      fees:
          (json['fees'] as List).map((e) => ChainFlipFee.fromJson(e)).toList(),
      lastStatechainUpdateAt: json['lastStatechainUpdateAt'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final data = super.toJson();
    data['swap'] = swap.toJson();
    return data;
  }
}

class Sending extends Receiving {
  final SwapFields swap;
  final EgressFields? swapEgress;
  final EgressFields? refundEgress;

  Sending({
    required super.swapId,
    required super.destAddress,
    required super.deposit,
    required this.swap,
    required super.state,
    this.swapEgress,
    this.refundEgress,
    super.depositChannel,
    super.ccmParams,
    super.boost,
    super.estimatedDurationSeconds,
    super.srcChainRequiredBlockConfirmations,
    required super.fees,
    super.lastStatechainUpdateAt,
  });

  factory Sending.fromJson(Map<String, dynamic> json) {
    return Sending(
        swapId: json['swapId'],
        destAddress: json['destAddress'],
        deposit: DepositFields.fromJson(json['deposit']),
        swap: SwapFields.fromJson(json['swap']),
        swapEgress: json['swapEgress'] != null
            ? EgressFields.fromJson(json['swapEgress'])
            : null,
        refundEgress: json['refundEgress'] != null
            ? EgressFields.fromJson(json['refundEgress'])
            : null,
        depositChannel: json['depositChannel'] != null
            ? DepositChannelFields.fromJson(json['depositChannel'])
            : null,
        ccmParams: json['ccmParams'] != null
            ? CcmParams.fromJson(json['ccmParams'])
            : null,
        boost: json['boost'] != null ? Boost.fromJson(json['boost']) : null,
        estimatedDurationSeconds: json['estimatedDurationSeconds'],
        srcChainRequiredBlockConfirmations:
            json['srcChainRequiredBlockConfirmations'],
        fees: (json['fees'] as List)
            .map((e) => ChainFlipFee.fromJson(e))
            .toList(),
        lastStatechainUpdateAt: json['lastStatechainUpdateAt'],
        state: json["state"]);
  }

  @override
  Map<String, dynamic> toJson() {
    final data = super.toJson();
    data['swap'] = swap.toJson();
    data['swapEgress'] = swapEgress?.toJson();
    data['refundEgress'] = refundEgress?.toJson();
    return data;
  }
}

abstract class SwapStatusResponseV2 {
  abstract final String state;
  factory SwapStatusResponseV2.fromJson(Map<String, dynamic> json) {
    final state = json["state"];
    switch (state) {
      case "WAITING":
        return Waiting.fromJson(json);
      case "RECEIVING":
        return Receiving.fromJson(json);
      case "SWAPPING":
        return Swapping.fromJson(json);
      case "SENDING":
      case "SENT":
      case "COMPLETED":
      case "FAILED":
        return Sending.fromJson(json);
      default:
        throw DartOnChainSwapPluginException("Invalid swap version 2 state",
            details: {"state": state});
    }
  }
  Map<String, dynamic> toJson();

  T cast<T extends SwapStatusResponseV2>() {
    if (this is! T) {
      throw DartOnChainSwapPluginException(
          "SwapStatusResponseV2 casting failed.",
          details: {"excepted": "$T", "type": runtimeType.toString()});
    }
    return this as T;
  }
}
