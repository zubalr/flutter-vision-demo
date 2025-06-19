import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/analysis_result.dart';
import '../models/app_state.dart';
import '../services/camera_service.dart';
import '../services/gemini_service.dart';
import '../../core/constants/app_constants.dart';

/// Main controller for vision analysis
class VisionController {
  // Services
  final CameraService _cameraService = CameraService();
  final GeminiService _geminiService = GeminiService();

  // State
  AppState _appState = AppState.initial;
  AnalysisState _analysisState = AnalysisState.idle;
  Timer? _analysisTimer;
  Duration _captureInterval =
      const Duration(milliseconds: AppConstants.defaultCaptureIntervalMs);

  // Data
  AnalysisResult? _lastResult;
  Uint8List? _lastCapturedFrame;
  String? _errorMessage;

  // Stream controllers for reactive updates
  final StreamController<AppState> _appStateController =
      StreamController<AppState>.broadcast();
  final StreamController<AnalysisState> _analysisStateController =
      StreamController<AnalysisState>.broadcast();
  final StreamController<AnalysisResult?> _resultController =
      StreamController<AnalysisResult?>.broadcast();
  final StreamController<String?> _errorController =
      StreamController<String?>.broadcast();

  // Getters
  CameraService get cameraService => _cameraService;
  GeminiService get geminiService => _geminiService;
  AppState get appState => _appState;
  AnalysisState get analysisState => _analysisState;
  AnalysisResult? get lastResult => _lastResult;
  Uint8List? get lastCapturedFrame => _lastCapturedFrame;
  String? get errorMessage => _errorMessage;
  Duration get captureInterval => _captureInterval;

  // Streams
  Stream<AppState> get appStateStream => _appStateController.stream;
  Stream<AnalysisState> get analysisStateStream =>
      _analysisStateController.stream;
  Stream<AnalysisResult?> get resultStream => _resultController.stream;
  Stream<String?> get errorStream => _errorController.stream;

  // Computed properties
  bool get isReady => _appState == AppState.ready;
  bool get isAnalyzing => _analysisState == AnalysisState.analyzing;
  bool get canStartAnalysis => isReady && !isAnalyzing;

  /// Initialize the controller
  Future<bool> initialize() async {
    try {
      _setAppState(AppState.loading);

      // Load configuration
      await _loadConfiguration();

      // Initialize services
      final cameraInitialized = await _cameraService.initialize();
      if (!cameraInitialized) {
        _setError(
            _cameraService.errorMessage ?? 'Camera initialization failed');
        return false;
      }

      final geminiInitialized = await _geminiService.initialize();
      if (!geminiInitialized) {
        _setError(
            _geminiService.errorMessage ?? 'Gemini initialization failed');
        return false;
      }

      _setAppState(AppState.ready);
      return true;
    } catch (e) {
      _setError('Initialization failed: $e');
      return false;
    }
  }

  /// Start continuous analysis
  Future<void> startAnalysis() async {
    if (!canStartAnalysis) {
      _setError('Cannot start analysis in current state');
      return;
    }

    _setAnalysisState(AnalysisState.analyzing);
    _startAnalysisTimer();
  }

  /// Stop continuous analysis
  void stopAnalysis() {
    _analysisTimer?.cancel();
    _analysisTimer = null;
    _setAnalysisState(AnalysisState.idle);
  }

  /// Capture and analyze a single frame
  Future<void> captureAndAnalyze() async {
    if (!isReady) {
      _setError('Services not ready for analysis');
      return;
    }

    try {
      _setAnalysisState(AnalysisState.analyzing);

      // Capture frame
      final imageBytes = await _cameraService.captureFrame();
      if (imageBytes == null) {
        _setError(_cameraService.errorMessage ?? 'Failed to capture frame');
        _setAnalysisState(AnalysisState.error);
        return;
      }

      _lastCapturedFrame = imageBytes;

      // Analyze frame
      final result = await _geminiService.analyzeImage(imageBytes);
      if (result == null) {
        _setError(_geminiService.errorMessage ?? 'Failed to analyze image');
        _setAnalysisState(AnalysisState.error);
        return;
      }

      _lastResult = result;
      _resultController.add(result);
      _setAnalysisState(AnalysisState.completed);
    } catch (e) {
      _setError('Analysis failed: $e');
      _setAnalysisState(AnalysisState.error);
    }
  }

  /// Switch camera
  Future<bool> switchCamera() async {
    return await _cameraService.switchCamera();
  }

  /// Update capture interval
  void updateCaptureInterval(Duration interval) {
    if (interval.inMilliseconds < AppConstants.minCaptureIntervalMs ||
        interval.inMilliseconds > AppConstants.maxCaptureIntervalMs) {
      _setError('Invalid capture interval');
      return;
    }

    _captureInterval = interval;

    // Restart timer if currently analyzing
    if (isAnalyzing) {
      _startAnalysisTimer();
    }
  }

  /// Load configuration from environment
  Future<void> _loadConfiguration() async {
    try {
      await dotenv.load();
      final intervalMs = int.tryParse(dotenv.env['FRAME_CAPTURE_INTERVAL_MS'] ??
              AppConstants.defaultCaptureIntervalMs.toString()) ??
          AppConstants.defaultCaptureIntervalMs;

      _captureInterval = Duration(milliseconds: intervalMs);
    } catch (e) {
      // Use default values if loading fails
      _captureInterval =
          const Duration(milliseconds: AppConstants.defaultCaptureIntervalMs);
    }
  }

  /// Start the analysis timer
  void _startAnalysisTimer() {
    _analysisTimer?.cancel();
    _analysisTimer = Timer.periodic(_captureInterval, (_) async {
      if (isAnalyzing) {
        await captureAndAnalyze();
      }
    });
  }

  /// Set app state and notify listeners
  void _setAppState(AppState state) {
    _appState = state;
    _appStateController.add(state);

    if (state != AppState.error) {
      _clearError();
    }
  }

  /// Set analysis state and notify listeners
  void _setAnalysisState(AnalysisState state) {
    _analysisState = state;
    _analysisStateController.add(state);
  }

  /// Set error and notify listeners
  void _setError(String message) {
    _errorMessage = message;
    _errorController.add(message);

    if (_appState != AppState.error) {
      _setAppState(AppState.error);
    }
  }

  /// Clear error
  void _clearError() {
    _errorMessage = null;
    _errorController.add(null);
  }

  /// Dispose of resources
  Future<void> dispose() async {
    _analysisTimer?.cancel();
    await _cameraService.dispose();

    _appStateController.close();
    _analysisStateController.close();
    _resultController.close();
    _errorController.close();
  }
}
