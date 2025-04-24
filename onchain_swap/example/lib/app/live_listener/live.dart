import 'package:example/app/types/types.dart';

abstract class _Live<T> extends LiveListenable<T> {
  @override
  String toString() => value.toString();

  @override
  bool operator ==(Object o) {
    if (o is T) return value == o;
    if (o is LiveListenable<T>) return value == o.value;
    return false;
  }

  @override
  int get hashCode => value.hashCode;

  @override
  set value(T val) {
    super.value = val;
  }

  _Live(super.initial);
}

class Live<T> extends _Live<T> {
  Live(super.initial);
}

mixin _LiveListenable {
  final Set<DynamicVoid> _noneIdsListeners = {};

  void addListener(DynamicVoid callBack) {
    _noneIdsListeners.add(callBack);
  }

  void removeListener(DynamicVoid callBack) {
    _noneIdsListeners.remove(callBack);
  }

  void notify() {
    for (final i in [..._noneIdsListeners]) {
      i();
    }
  }
}

class LiveListenable<T> with _LiveListenable {
  LiveListenable(T val) : _value = val;

  static DynamicVoid? listener;

  static void _addListener(_LiveListenable listen) {
    final listenable = listener;
    if (listenable != null) {
      listen.addListener(listenable);
    }
  }

  void dispose() {
    _noneIdsListeners.clear();
  }

  T _value;

  T get value {
    _addListener(this);
    return _value;
  }

  set value(T newValue) {
    if (_value == newValue) return;
    _value = newValue;
    notify();
  }
}
