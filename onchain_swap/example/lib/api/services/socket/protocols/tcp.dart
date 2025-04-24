import 'dart:async';
import 'dart:io';

import 'package:blockchain_utils/utils/utils.dart';
import 'package:example/api/services/socket/core/socket_provider.dart';
import 'package:example/app/synchronized/basic_lock.dart';
import 'package:example/app/utils/method.dart';

class TCPService extends BaseSocketService {
  TCPService({required super.service});
  final _lock = SynchronizedLock();
  Socket? _socket;
  SocketStatus _status = SocketStatus.disconnect;
  StreamSubscription<List<int>>? _subscription;
  @override
  bool get isConnected => _status == SocketStatus.connect;
  List<int> _toRequest(List<int> params) {
    return params + '\n'.codeUnits;
  }

  final Map<int, SocketRequestCompleter> _requests = {};

  void _add(List<int> message) {
    _socket?.add(message);
  }

  void _onClose() {
    _status = SocketStatus.disconnect;
    _socket?.close().catchError((e) => null);
    _subscription?.cancel().catchError((e) {});
    _subscription = null;
    _socket = null;
  }

  @override
  void disposeService() => _onClose();

  void _onMessge(List<int> event) {
    final Map<String, dynamic> decode =
        StringUtils.toJson(StringUtils.decode(event));
    if (decode.containsKey("id")) {
      final int id = int.parse(decode["id"]!.toString());
      final request = _requests.remove(id);
      request?.completer.complete(decode);
    }
  }

  @override
  Future<void> connect() async {
    await _lock.synchronized(() async {
      if (_status != SocketStatus.disconnect) return;
      final result = await MethodUtils.call(() async {
        final result = service.url.split(":");
        final socket = await Socket.connect(result.first, int.parse(result[1]));
        return socket;
      });
      if (result.hasResult) {
        _status = SocketStatus.connect;
        _socket = result.result;
        _subscription = _socket?.listen(_onMessge, onDone: _onClose);
      } else {
        _status = SocketStatus.disconnect;
      }
    });
  }

  Future<Map<String, dynamic>> post(
      SocketRequestCompleter message, Duration timeout) async {
    try {
      return providerCaller(() async {
        _requests[message.id] = message;
        _add(_toRequest(message.params));
        final result = await message.completer.future.timeout(timeout);
        return result;
      }, message);
    } finally {
      _requests.remove(message.id);
    }
  }

  @override
  ServiceProtocol get protocol => ServiceProtocol.tcp;
}
