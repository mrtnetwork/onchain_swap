import 'package:blockchain_utils/helper/extensions/extensions.dart';

class TronTransactionBlockRequirment {
  final List<int> refBlockBytes;
  final List<int> refBlockHash;
  final BigInt expiration;
  final BigInt timestamp;

  TronTransactionBlockRequirment({
    required List<int> refBlockBytes,
    required List<int> refBlockHash,
    required this.expiration,
    required this.timestamp,
  })  : refBlockBytes = refBlockBytes.asImmutableBytes,
        refBlockHash = refBlockHash.asImmutableBytes;
}
