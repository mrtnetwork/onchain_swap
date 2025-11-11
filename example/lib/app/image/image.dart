import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:onchain_swap_example/app/constants/cbor_tags.dart';
import 'package:onchain_swap_example/app/error/exception/app.dart';
import 'package:onchain_swap_example/app/euqatable/equatable.dart';
import 'package:onchain_swap_example/app/serialization/serialization.dart';
import 'package:onchain_swap_example/app/utils/string.dart';

// import 'package:mrt_wallet/app/core.dart';
typedef OnLoadUrl = Future<String> Function();
typedef OnLoadCacheKey = Future<String> Function();

enum ContentType {
  asset(0),
  memory(0),
  network(4),
  favIcon(5);

  final int value;
  const ContentType(this.value);

  static ContentType fromValue(int? value, {ContentType? defaultValue}) {
    return values.firstWhere((element) => element.value == value, orElse: () {
      if (defaultValue != null) return defaultValue;
      throw AppExceptionConst.dataVerificationFailed;
    });
  }
}

enum ImageType { svg, gpg, gift, unknown }

abstract class BaseAPPImage with CborSerializable, Equatable {
  final ContentType type;
  final ImageType imageType;
  const BaseAPPImage({required this.type, required this.imageType});
}

class APPImage extends BaseAPPImage {
  final String uri;
  const APPImage._(
      {required super.type,
      required this.uri,
      super.imageType = ImageType.unknown});
  APPImage.local(this.uri)
      : super(type: ContentType.asset, imageType: ImageType.gpg);

  static APPImage? network(String? imageUrl) {
    final validateUrl = StrUtils.validateUri(imageUrl);
    if (validateUrl == null) return null;
    return APPImage._(type: ContentType.network, uri: imageUrl!);
  }

  factory APPImage.faviIcon(String websiteUrl) {
    final host = Uri.tryParse(websiteUrl);
    String cacheKey = host?.host ?? "";
    if (cacheKey.isEmpty) {
      cacheKey = websiteUrl;
    }
    return APPImage._(type: ContentType.favIcon, uri: websiteUrl);
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.definite(
            <CborObject>[CborIntValue(type.value), CborStringValue(uri)]),
        APPSerializationConst.imageTag);
  }

  @override
  List get variabels => [type, uri];
}

class APPImageMemory extends BaseAPPImage {
  final List<int> bytes;
  APPImageMemory._({required List<int> bytes, ImageType? imageType})
      : bytes = bytes.asImmutableBytes,
        super(
            type: ContentType.memory,
            imageType: imageType ?? ImageType.unknown);
  static APPImageMemory? base64(String? base64, {ImageType? imageType}) {
    final toBytes = StringUtils.tryEncode(base64, type: StringEncoding.base64);
    if (toBytes == null) return null;
    return APPImageMemory._(bytes: toBytes, imageType: imageType);
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.definite(
            <CborObject>[CborIntValue(type.value), CborBytesValue(bytes)]),
        APPSerializationConst.imageTag);
  }

  @override
  List get variabels => [type, bytes];
}
