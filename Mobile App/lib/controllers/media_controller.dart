import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:record/record.dart';
import 'package:image/image.dart' as img;

class MediaController {
  static final MediaController _instance = MediaController._internal();
  factory MediaController() => _instance;
  MediaController._internal();

  CameraController? _cameraController;
  final AudioRecorder _audioRecorder = AudioRecorder();
  Timer? _audioTimer;
  Timer? _cameraTimer;
  bool _isRecording = false;
  bool _isCameraActive = false;
  bool _isDisposed = false;

  Stream<Uint8List>? _audioStream;
  StreamController<File>? _imageStreamController;
  StreamSubscription? _audioSubscription;

  Function(String)? onAudioData;

  Stream<File>? get imageStream => _imageStreamController?.stream;
  bool get isRecording => _isRecording;
  bool get isCameraActive => _isCameraActive;
  final List<Uint8List> _audioBuffer = [];


  Future<void> initializeCamera() async {
    if (_isDisposed) return;

    final cameras = await availableCameras();
    if (cameras.isEmpty) return;

    _cameraController?.dispose();
    _cameraController = CameraController(
      cameras.last,
      ResolutionPreset.medium,
    );
    await _cameraController?.initialize();
  }

  Future<void> startCameraStream() async {
    if (_isCameraActive || _isDisposed) return;

    // Create a new StreamController if needed
    _imageStreamController ??= StreamController<File>.broadcast();

    await initializeCamera();
    _isCameraActive = true;

    _cameraTimer = Timer.periodic(const Duration(seconds: 10), (_) async {
      await captureAndProcessImage();
    });
  }

  Future<void> stopCameraStream() async {
    _cameraTimer?.cancel();
    _cameraTimer = null;
    _isCameraActive = false;
    await _cameraController?.dispose();
    _cameraController = null;
  }

  Future<void> captureAndProcessImage() async {
    if (_cameraController == null || _isDisposed || _imageStreamController == null) return;

    try {
      final XFile image = await _cameraController!.takePicture();
      final File originalFile = File(image.path);
      final Uint8List originalBytes = await originalFile.readAsBytes();

      final img.Image? decodedImage = img.decodeImage(originalBytes);
      if (decodedImage == null) return;

      final img.Image resizedImage = img.copyResize(
        decodedImage,
        width: 450,
      );

      final List<int> compressedBytes = img.encodeJpg(resizedImage, quality: 85);
      final File compressedFile = File('${image.path}_compressed.jpg');
      await compressedFile.writeAsBytes(compressedBytes);

      if (!_isDisposed && _imageStreamController != null) {
        _imageStreamController!.add(compressedFile);
      }
    } catch (e) {
      print('Error capturing image: $e');
    }
  }

  Future<void> startAudioRecording(Function(Map<String, dynamic>) onData) async {
    if (_isRecording || _isDisposed) return;

    if (await _audioRecorder.hasPermission()) {
      _isRecording = true;
      _audioBuffer.clear();

      _audioStream = await _audioRecorder.startStream(
        const RecordConfig(
          encoder: AudioEncoder.pcm16bits,
          sampleRate: 16000,
          numChannels: 1,
        ),
      );

      // Buffer the audio data
      _audioSubscription = _audioStream?.listen((data) {
        _audioBuffer.add(data);
      });

      // Send buffered data every second
      _audioTimer = Timer.periodic(const Duration(milliseconds: 1000), (_) {
        if (_audioBuffer.isEmpty) return;

        // Concatenate all buffered data
        final List<int> concatenated = _audioBuffer.expand((x) => x).toList();
        _audioBuffer.clear();

        // Create and send the message
        final message = {
          'type': 'audio',
          'data': base64Encode(concatenated),
          'format': 'pcm16',
          'sampleRate': 16000,
          'channels': 1
        };

        onData(message);
      });
    }
  }

  Future<void> stopAudioRecording() async {
    _isRecording = false;
    _audioTimer?.cancel();
    _audioTimer = null;
    await _audioSubscription?.cancel();
    _audioSubscription = null;
    await _audioRecorder.stop();
    _audioStream = null;
    _audioBuffer.clear();
  }

  void dispose() {
    _isDisposed = true;
    stopCameraStream();
    stopAudioRecording();
    _imageStreamController?.close();
    _imageStreamController = null;
    _audioRecorder.dispose();
    _audioSubscription?.cancel();
  }

  // Add this method to reinitialize the controller
  void reset() {
    _isDisposed = false;
    _imageStreamController = StreamController<File>.broadcast();
  }
}