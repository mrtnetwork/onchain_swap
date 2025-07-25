import 'package:onchain_swap_example/app/app.dart';
import 'package:onchain_swap_example/future/theme/theme.dart';
import 'package:flutter/material.dart';

extension Translate on String {
  static Map<String, Map<String, String>> get localization =>
      Localization.languages;
  static Locale get language => ThemeController.locale;
  String get tr => localization[language.languageCode]?[this] ?? this;

  String replaceOne(String replace) {
    return replaceAll("___1__", replace);
  }

  String replaceTwo(String replace) {
    return replaceAll("___2__", replace);
  }

  String replaceThere(String replace) {
    return replaceAll("___3__", replace);
  }

  String get camelCase {
    return StrUtils.toCamelCase(this);
  }

  String or(String or) => trim().isEmpty ? or : this;
  String? get nullOnEmpty => trim().isEmpty ? null : this;
  String get to3Digits => StrUtils.to3Digits(this, separator: ",");
}
