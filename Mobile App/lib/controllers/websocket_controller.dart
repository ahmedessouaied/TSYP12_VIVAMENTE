import 'dart:async';
import 'package:b_bot/Widgets/widgets.dart';
import 'package:b_bot/controllers/user_controller.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class SocketIOController {
  io.Socket? _socket;
  StreamController<String>? _messageController;
  bool _isConnected = false;

  // Singleton pattern
  static final SocketIOController _instance = SocketIOController._internal();
  factory SocketIOController() => _instance;
  SocketIOController._internal();

  Stream<String>? get messageStream => _messageController?.stream;
  bool get isConnected => _isConnected;

  Future<void> connect() async {
    if (_isConnected) return;

    try {
      // Initialize the Socket.IO client
      _socket = io.io(
        UserController().currentUser?.backendUrl ?? 'https://bbot.loca.lt/',
        io.OptionBuilder()
            .setTransports(['websocket'])
            .enableAutoConnect()
            .build(),
      );

      _messageController = StreamController<String>.broadcast();

      // Listen to connection events
      _socket!.onConnect((_) {
        print('Connected to the server');
        Fluttertoast.showToast(
          msg: 'Connected to the server',
          toastLength: Toast.LENGTH_SHORT,
        );
        _isConnected = true;
      });

      _socket!.onDisconnect((_) {
        print('Disconnected from the server');
        Fluttertoast.showToast(
          msg: 'Disconnected from the server',
          toastLength: Toast.LENGTH_SHORT,
        );
        _isConnected = false;
        reconnect();
      });

      _socket!.onError((data) {
        print('Socket.IO Error: $data');
        _isConnected = false;
      });

      // Listen to incoming messages
      _socket!.on('response', (data) {
        print(data);
        _messageController?.add(data['content']['response'].toString());
      });

      // Connect to the server
      _socket!.connect();
    } catch (e) {
      _isConnected = false;
      print('Connection error: $e');
      rethrow;
    }
  }

  Future<void> reconnect() async {
    await disconnect();
    await connect();
  }

  Future<void> disconnect() async {
    _socket?.disconnect();
    _socket = null;
    _isConnected = false;
  }

  void sendMessage(String message) {
    if (!_isConnected) return;
    _socket?.emit('message', message);
  }

  void sendBinaryData(List<int> data) {
    if (!_isConnected) return;
    _socket?.emit('binary', data);
  }
}
