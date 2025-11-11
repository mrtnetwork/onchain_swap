import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:blockchain_utils/utils/utils.dart';
import 'package:onchain_swap_example/app/error/exception/app.dart';

mixin CborSerializable {
  CborTagValue toCbor();
  static CborListValue fromDynamic(List<dynamic> objects) {
    return CborListValue.definite(
        objects.map((e) => CborObject.fromDynamic(e)).toList());
  }

  static CborTagValue toTagValue<T extends CborObject>(List<int> bytes,
      {List<int>? tags}) {
    final cbor = CborObject.fromCbor(bytes);
    if (cbor is! CborTagValue) {
      throw AppExceptionConst.invalidSerializationData;
    }
    if (tags != null && !BytesUtils.bytesEqual(cbor.tags, tags)) {
      throw AppExceptionConst.invalidSerializationData;
    }
    return cbor;
  }

  static T decodeCborTags<T extends CborObject>(
      List<int>? cborBytes, CborObject? object, List<int>? tags) {
    assert(cborBytes != null || object != null,
        "cbor bytes or cbor object must not be null");

    final cbor = object ?? CborObject.fromCbor(cborBytes!);

    return validateCbor(cbor, tags);
  }

  static CborListValue cborTagValue(
      {List<int>? cborBytes,
      CborObject? object,
      String? hex,
      List<int>? tags}) {
    assert(cborBytes != null || object != null || hex != null,
        "cbor bytes or cbor object must not be null");
    if (object == null) {
      cborBytes ??= BytesUtils.tryFromHexString(hex);
      if (cborBytes == null) {
        throw AppExceptionConst.invalidSerializationData;
      }
      object = CborObject.fromCbor(cborBytes);
    }

    return validateCbor(object, tags);
  }

  static T validateCbor<T extends CborObject>(
      CborObject cbor, List<int>? tags) {
    if (cbor is! CborTagValue || cbor.value is! T) {
      throw AppExceptionConst.invalidSerializationData;
    }
    if (tags != null && !BytesUtils.bytesEqual(cbor.tags, tags)) {
      throw AppExceptionConst.invalidSerializationData;
    }
    return cbor.value as T;
  }

  static T decode<T extends CborObject>(
      {List<int>? cborBytes, CborObject? object, String? hex}) {
    try {
      if (object == null) {
        cborBytes ??= BytesUtils.tryFromHexString(hex);
        if (cborBytes == null) {
          throw AppExceptionConst.invalidSerializationData;
        }
        object = CborObject.fromCbor(cborBytes);
      }
      if (object is! T) {
        throw AppException.invalidArgruments(["$T" "${object.runtimeType}"]);
      }
      return object;
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppExceptionConst.dataVerificationFailed;
    }
  }
}
typedef OnKeyValue<T> = T Function(CborObject);

extension ExtractCborMap on CborMapValue {
  Map<K, V> generateMap<K, V>(OnKeyValue<K> onKey, OnKeyValue<V> onValue) {
    final Map<CborObject, CborObject> cborMap = value.cast();
    final entrries = cborMap.entries
        .map((e) => MapEntry<K, V>(onKey(e.key), onValue(e.value)));
    return Map<K, V>.fromEntries(entrries);
  }
}

extension ExtractCborList on CborListValue {
  bool isA<T extends CborObject>(int index) {
    if (index > value.length - 1) {
      if (null is T) return true;
      return false;
    }
    return value[index] is T;
  }

  // T elementAt<T>(int index) {
  //   if (index > value.length - 1) return null as T;
  //   final cborValue = value[index];
  //   final dynamic v;
  //   if (T == CborMapValue) {
  //     if (cborValue is CborMapValue) {
  //       return cborValue as T;
  //     }
  //     return null as T;
  //   }
  //   if (cborValue is CborObject) {
  //     v = cborValue.value;
  //   } else {
  //     v = cborValue;
  //   }
  //   if (v is! T) return null as T;
  //   return v;
  // }

  List<T> elementAsListOf<T extends CborObject>(int index) {
    try {
      return (value[index] as CborListValue).value.cast<T>();
    } catch (e) {
      throw AppExceptionConst.invalidSerializationData;
    }
  }

  T elementAs<T>(int index) {
    if (index > value.length - 1) {
      if (null is T) return null as T;
      throw AppExceptionConst.invalidSerializationData;
    }
    try {
      final CborObject cborValue = value[index];
      if (null is T && cborValue == const CborNullValue()) {
        return null as T;
      }
      if (cborValue.value is T) {
        return cborValue.value as T;
      }
      return cborValue as T;
    } catch (e) {
      throw AppExceptionConst.invalidSerializationData;
    }
  }

  E? elemetMybeAs<E, T>(int index, E Function(T) onValue) {
    if (index > value.length - 1) {
      return null;
    }
    try {
      final CborObject cborValue = value[index];
      if (cborValue == const CborNullValue()) {
        return null;
      }
      if (cborValue is T) {
        return onValue(cborValue as T);
      }
      return onValue(cborValue.value as T);
    } catch (e) {
      throw AppExceptionConst.invalidSerializationData;
    }
  }

  // List<T> cast<T>() {
  //   return [for (int i = 0; i < value.length; i++) elementAt<T>(i)];
  // }

  List<T> castValue<T>() {
    return [for (int i = 0; i < value.length; i++) elementAs<T>(i)];
  }

  CborTagValue? getCborTag(int index) {
    if (index > value.length - 1) return null;
    final cborValue = value[index];
    if (cborValue is CborTagValue) return cborValue;
    if (cborValue.value is CborTagValue) return cborValue.value;
    return null;
  }

  /// Gets the value at the specified [index] in the [CborListValue].
  ///
  /// If [index] is out of bounds and [T] is nullable, returns null. Otherwise, throws a [AppException].
  T getElement<T extends CborObject?>(int index) {
    if (index >= value.length) {
      if (null is T) return null as T;
      throw AppExceptionConst.invalidSerializationData;
    }
    final CborObject obj = value.elementAt(index);
    if (null is T && obj == const CborNullValue()) {
      return null as T;
    }
    if (obj is T) return obj as T;
    throw AppExceptionConst.invalidSerializationData;
  }
}

extension QuickCbor on CborTagValue {
  /// Converts the value of the [CborObject] to the specified type [E] using the provided function [toe].
  ///
  /// Throws a [AppException] if the value cannot be converted to type [T].
  E to<E, T extends CborObject>(E Function(CborObject e) toe) {
    if (this is T) {
      return toe(this as T);
    }
    if (value is! T) {
      throw AppExceptionConst.invalidSerializationData;
    }
    return toe(value as T);
  }
}

// extension QuickCborTag on CborTagValue {
//   CborListValue get getList {
//     if (value is! CborListValue) {
//       throw AppExceptionConst.invalidSerializationData;
//     }
//     return value;
//   }

//   T valueAs<T extends CborObject>() {
//     if (value is! T) {
//       throw AppExceptionConst.invalidSerializationData;
//     }
//     return value;
//   }
// }
