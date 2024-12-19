import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../controllers/media_controller.dart';
import '../controllers/user_controller.dart';
import '../controllers/websocket_controller.dart';
import '../structures/structs.dart';
import '../widgets/widgets.dart';
import '../widgets/butter_fly_animation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

class ChatBotPage extends StatefulWidget {
  const ChatBotPage({super.key});
  @override
  State<ChatBotPage> createState() => _ChatBotPageState();
}

class _ChatBotPageState extends State<ChatBotPage> with TickerProviderStateMixin {
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final SocketIOController _wsController = SocketIOController();
  final MediaController _mediaController = MediaController();
  late List<ButterflyAnimation> butterflies;

  @override
  void initState() {
    super.initState();
    _mediaController.reset(); // Reset the media controller

    _initializeControllers();
    _setupButterflies();
    _requestPermissions();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('B-BOT🤖'),
        backgroundColor: theme.primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () => _showBackendUrlDialog(context),
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: MessageList(
                  messages: _messages,
                  scrollController: _scrollController,
                ),
              ),
              ChatInput(
                onSendMessage: _handleSendMessage,
                onToggleAudio: _handleToggleAudio,
                onToggleCamera: _handleToggleCamera,
                isRecording: _mediaController.isRecording,
                isCameraActive: _mediaController.isCameraActive,
              ),
            ],
          ),
          ...butterflies.map((butterfly) => butterfly.build(context)),
        ],
      ),
    );
  }

  void _initializeControllers() async {
    await _wsController.connect();
    _wsController.messageStream?.listen(_handleIncomingMessage);

    _mediaController.imageStream?.listen(_handleCapturedImage);
  }

  void _handleIncomingMessage(String message) {
    setState(() {
      print('Incoming message:');
      _messages.add(ChatMessage(
        message: message,
        isUser: false,
      ));
    });
    _scrollToBottom();
  }

  void _handleToggleAudio() async {
    if (_mediaController.isRecording) {
      await _mediaController.stopAudioRecording();
    } else {
      await _mediaController.startAudioRecording((audioMessage) {
        // Send the audio data through the websocket
        _wsController.sendMessage(jsonEncode(audioMessage));
      });
    }
  }

  void _handleToggleCamera() async {
    setState(() {});
    if (!_mediaController.isCameraActive) {
      await _mediaController.startCameraStream();
    } else {
      await _mediaController.stopCameraStream();
    }
  }

  void _setupButterflies() {
    butterflies = [
      ButterflyAnimation(
        butterfly: 0,
        size: 30,
        verticalOffset: 0.3,
        speed: 1.0,
      ),
      ButterflyAnimation(
        butterfly: 0,
        size: 40,
        verticalOffset: 0.5,
        speed: 0.8,
      ),
      ButterflyAnimation(
        butterfly: 0,
        size: 25,
        verticalOffset: 0.2,
        speed: 1.2,
      ),
    ];

    for (var butterfly in butterflies) {
      butterfly.initialize(this);
    }
  }

  void _handleCapturedImage(File image) {
    setState(() {
      _messages.add(ChatMessage(
        message: 'Image captured',
        isUser: true,
        imageUrl: image.path,
      ));
    });

    // Send image via WebSocket
    image.readAsBytes().then((bytes) {
      final base64Image = base64Encode(bytes);
      _wsController.sendMessage(jsonEncode({
        'type': 'image',
        'data': base64Image,
      }));
    });

    _scrollToBottom();
  }

  Future<void> _requestPermissions() async {
    await [
      Permission.storage,
      Permission.camera,
    ].request();
  }

  void _handleSendMessage(String text) {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(message: text, isUser: true));
    });

    //_sendHttpRequest(text);

    _wsController.sendMessage(jsonEncode({
      'type': 'text',
      'data': text,
    }));

    _scrollToBottom();
  }

  Future<void> _sendHttpRequest(String text) async {
    final backendUrl = UserController().currentUser?.backendUrl;
    if (backendUrl != null) {
      final response = await http.post(
        Uri.parse("https://bbot.loca.lt/api/generate"),
        body: jsonEncode({
          "model": "hf.co/Hamatoysin/EMBS-G",
          'prompt': text,
          "stream": false
        }),
        headers: {'Content-Type': 'application/json'},
      );
      print(response.body);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final message = data['response'];
        setState(() {
          _messages.add(ChatMessage(message: message, isUser: false));
        });
        _scrollToBottom();
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showBackendUrlDialog(BuildContext context) {
    final TextEditingController urlController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter Backend URL'),
          content: TextField(
            controller: urlController,
            decoration: InputDecoration(hintText: "Backend URL"),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Save'),
              onPressed: () async {
                String backendUrl = urlController.text.trim();
                if (backendUrl.isNotEmpty) {
                  User? user = UserController().currentUser ;
                  if (user != null) {
                    // Save the backend URL to Firestore
                    await _firestore.collection('users').doc(user.uid).set({
                      'backendUrl': backendUrl,
                    }, SetOptions(merge: true));

                    UserController().reloadUser();

                    Navigator.of(context).pop();
                    showSnackBar(context, "URL saved successfully");
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _mediaController.dispose();
    _wsController.disconnect();
    _scrollController.dispose();
    for (var butterfly in butterflies) {
      butterfly.dispose();
    }
    super.dispose();
  }
}