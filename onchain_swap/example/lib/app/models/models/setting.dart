import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:blockchain_utils/helper/helper.dart';
import 'package:blockchain_utils/utils/utils.dart';
import 'package:example/app/constants/cbor_tags.dart';
import 'package:example/app/serialization/cbor/cbor.dart';
import 'package:example/marketcap/prices/currency.dart';
import 'package:mrt_native_support/models/models.dart';
import 'package:onchain_swap/onchain_swap.dart';

class APPSetting with CborSerializable {
  APPSetting._(
      {required this.appColor,
      required this.appBrightness,
      required this.currency,
      required this.config,
      required List<SwapServiceProvider> swapProviders,
      this.size})
      : swapProviders = swapProviders.immutable;
  final String? appColor;
  final String? appBrightness;
  final Currency currency;
  final MRTAPPConfig config;
  final WidgetRect? size;
  final List<SwapServiceProvider> swapProviders;

  bool get supportBarcodeScanner => config.hasBarcodeScanner;

  APPSetting copyWith(
      {String? appColor,
      String? appBrightness,
      Currency? currency,
      WidgetRect? size,
      List<SwapServiceProvider>? swapProviders}) {
    return APPSetting._(
        appColor: appColor ?? this.appColor,
        appBrightness: appBrightness ?? this.appBrightness,
        currency: currency ?? this.currency,
        config: config,
        size: size ?? this.size,
        swapProviders: swapProviders ?? this.swapProviders);
  }

  factory APPSetting.fromHex(String? cborHex, MRTAPPConfig config) {
    try {
      final CborListValue cbor = CborSerializable.decodeCborTags(
          BytesUtils.fromHexString(cborHex!),
          null,
          APPSerializationConst.appSettingTag);
      final String? colorHex = cbor.elementAs(0);
      final String? brightnessName = cbor.elementAs(1);
      final Currency currency =
          Currency.fromName(cbor.elementAs(2)) ?? Currency.USD;
      WidgetRect? rect = WidgetRect.fromString(cbor.elementAs(3));
      List<SwapServiceProvider> providers = cbor
          .elementAsListOf<CborStringValue>(4)
          .map((e) => SwapConstants.findProvider(e.value))
          .whereType<SwapServiceProvider>()
          .toList();
      if (providers.isEmpty) {
        providers = SwapConstants.supportProviders;
      }
      return APPSetting._(
          appColor: colorHex,
          appBrightness: brightnessName,
          currency: currency,
          config: config,
          size: rect,
          swapProviders: providers);
    } catch (_) {
      return APPSetting._(
          appColor: null,
          appBrightness: null,
          currency: Currency.USD,
          config: config,
          swapProviders: SwapConstants.supportProviders);
    }
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          appColor,
          appBrightness,
          currency.name,
          size?.toString(),
          CborListValue.fixedLength(
              swapProviders.map((e) => CborStringValue(e.identifier)).toList())
        ]),
        APPSerializationConst.appSettingTag);
  }
}
