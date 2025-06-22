import 'dart:async';
import 'dart:typed_data';
import 'dart:math' as math;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/analysis_result.dart';
import '../models/app_state.dart';
import '../services/camera_service.dart';
import '../services/gemini_service.dart';
import '../../core/constants/app_constants.dart';

/// Main controller for the vision analysis app
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
      print(
          'Debug: Cannot start analysis - app state: $_appState, analysis state: $_analysisState');
      return;
    }

    print('Debug: Starting continuous analysis...');
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
      print('Debug: Services not ready for analysis, app state: $_appState');
      return; // Don't set error for continuous analysis
    }

    try {
      // Check if this is continuous analysis or single shot
      final isContinuousAnalysis = _analysisState == AnalysisState.analyzing;

      // For single shot analysis, set analyzing state
      if (!isContinuousAnalysis) {
        _setAnalysisState(AnalysisState.analyzing);
      }

      // Capture frame
      final imageBytes = await _cameraService.captureFrame();
      if (imageBytes == null) {
        print('Debug: Failed to capture frame: ${_cameraService.errorMessage}');
        if (!isContinuousAnalysis) {
          _setAnalysisState(AnalysisState.idle);
        }
        return;
      }

      _lastCapturedFrame = imageBytes;

      // Analyze frame
      final result = await _geminiService.analyzeImage(imageBytes);
      if (result == null) {
        print('Debug: Analysis returned null, continuing...');
        if (!isContinuousAnalysis) {
          _setAnalysisState(AnalysisState.idle);
        }
        return;
      }

      _lastResult = result;
      _resultController.add(result);

      // Set completed state for single shot analysis
      if (!isContinuousAnalysis) {
        _setAnalysisState(AnalysisState.completed);
      }

      print(
          'Debug: Analysis completed successfully - scene: ${result.sceneDescription.substring(0, math.min(50, result.sceneDescription.length))}..., objects: ${result.objects.length}');
    } catch (e) {
      print('Debug: Analysis failed: $e');
      if (_analysisState != AnalysisState.analyzing) {
        _setAnalysisState(AnalysisState.idle);
      }
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
      // Only trigger analysis if we're in continuous analyzing mode
      if (_analysisState == AnalysisState.analyzing) {
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
