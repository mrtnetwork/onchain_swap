import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:on_chain_bridge/models/models.dart';
import 'package:on_chain_swap/on_chain_swap.dart';
import 'package:onchain_swap_example/app/constants/cbor_tags.dart';
import 'package:onchain_swap_example/app/euqatable/equatable.dart';
import 'package:onchain_swap_example/app/serialization/cbor/cbor.dart';
import 'package:onchain_swap_example/marketcap/prices/currency.dart';

class APPSetting with CborSerializable, Equatable {
  APPSetting._(
      {required this.appColor,
      required this.appBrightness,
      required this.currency,
      required this.config,
      required this.chainType,
      required List<SwapServiceProvider> swapProviders,
      this.size})
      : swapProviders = swapProviders.immutable;
  final String? appColor;
  final String? appBrightness;
  final Currency currency;
  final PlatformConfig config;
  final WidgetRect? size;
  final List<SwapServiceProvider> swapProviders;
  final ChainType chainType;

  bool get supportBarcodeScanner => config.hasBarcodeScanner;

  APPSetting copyWith(
      {String? appColor,
      String? appBrightness,
      Currency? currency,
      WidgetRect? size,
      List<SwapServiceProvider>? swapProviders,
      ChainType? chainType}) {
    return APPSetting._(
        appColor: appColor ?? this.appColor,
        appBrightness: appBrightness ?? this.appBrightness,
        currency: currency ?? this.currency,
        config: config,
        size: size ?? this.size,
        swapProviders: swapProviders ?? this.swapProviders,
        chainType: chainType ?? this.chainType);
  }

  factory APPSetting.deserialize(
      {String? cborHex, List<int>? cborBytes, required PlatformConfig config}) {
    try {
      final CborListValue cbor = CborSerializable.cborTagValue(
          hex: cborHex,
          cborBytes: cborBytes,
          tags: APPSerializationConst.appSettingTag);
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
      final chainType = ChainType.fromValue(cbor.elementAs(5));
      return APPSetting._(
          appColor: colorHex,
          appBrightness: brightnessName,
          currency: currency,
          config: config,
          size: rect,
          swapProviders: providers,
          chainType: chainType);
    } catch (_) {
      return APPSetting._(
          appColor: null,
          appBrightness: null,
          currency: Currency.USD,
          config: config,
          swapProviders: SwapConstants.supportProviders,
          chainType: ChainType.mainnet);
    }
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborSerializable.fromDynamic([
          appColor,
          appBrightness,
          currency.name,
          size?.toString(),
          CborListValue.definite(
              swapProviders.map((e) => CborStringValue(e.identifier)).toList()),
          chainType.name,
        ]),
        APPSerializationConst.appSettingTag);
  }

  @override
  List get variabels => [
        appColor,
        appBrightness,
        currency,
        config,
        size,
        swapProviders,
        chainType
      ];
}
