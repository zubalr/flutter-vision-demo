import 'dart:typed_data';
import 'package:camera/camera.dart';
import '../models/app_state.dart';
import '../../core/constants/app_constants.dart';

/// Camera service for handling camera operations
class CameraService {
  CameraController? _controller;
  CameraState _state = CameraState.uninitialized;
  String? _errorMessage;
  List<CameraDescription> _availableCameras = [];

  // Getters
  CameraController? get controller => _controller;
  CameraState get state => _state;
  String? get errorMessage => _errorMessage;
  List<CameraDescription> get cameras => _availableCameras;
  bool get isReady => _state == CameraState.ready && _controller != null;

  /// Initialize the camera service
  Future<bool> initialize() async {
    try {
      _setState(CameraState.initializing);
      
      final cameras = await availableCameras();
      _availableCameras = cameras;
      
      if (_availableCameras.isEmpty) {
        _setError(AppConstants.noCamerasFound);
        return false;
      }

      // Select back camera if available, otherwise use first camera
      final camera = _availableCameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => _availableCameras.first,
      );

      _controller = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _controller!.initialize();
      _setState(CameraState.ready);
      return true;
    } on CameraException catch (e) {
      _setError('Camera error: ${e.description}');
      return false;
    } catch (e) {
      _setError(AppConstants.cameraInitializationFailed);
      return false;
    }
  }

  /// Capture a frame from the camera
  Future<Uint8List?> captureFrame() async {
    if (!isReady) {
      _setError('Camera not ready for capture');
      return null;
    }

    try {
      _setState(CameraState.capturing);
      
      final XFile file = await _controller!.takePicture();
      final bytes = await file.readAsBytes();
      
      _setState(CameraState.ready);
      return bytes;
    } catch (e) {
      _setError('Failed to capture frame: $e');
      return null;
    }
  }

  /// Switch between available cameras
  Future<bool> switchCamera() async {
    if (_availableCameras.length < 2) return false;

    try {
      final currentCamera = _controller?.description;
      final currentIndex = _availableCameras.indexOf(currentCamera!);
      final nextIndex = (currentIndex + 1) % _availableCameras.length;
      final nextCamera = _availableCameras[nextIndex];

      await dispose();
      
      _controller = CameraController(
        nextCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _controller!.initialize();
      _setState(CameraState.ready);
      return true;
    } catch (e) {
      _setError('Failed to switch camera: $e');
      return false;
    }
  }

  /// Dispose of camera resources
  Future<void> dispose() async {
    try {
      await _controller?.dispose();
      _controller = null;
      _setState(CameraState.disposed);
    } catch (e) {
      _setError('Failed to dispose camera: $e');
    }
  }

  void _setState(CameraState newState) {
    _state = newState;
    if (newState != CameraState.error) {
      _errorMessage = null;
    }
  }

  void _setError(String message) {
    _errorMessage = message;
    _state = CameraState.error;
  }
}
