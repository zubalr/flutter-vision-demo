import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/analysis_result.dart';
import '../models/app_state.dart';
import '../../core/constants/app_constants.dart';

/// Gemini service for image analysis
class GeminiService {
  GenerativeModel? _model;
  ApiState _state = ApiState.uninitialized;
  String? _errorMessage;
  String? _apiKey;

  // Getters
  ApiState get state => _state;
  String? get errorMessage => _errorMessage;
  bool get isReady => _state == ApiState.ready && _model != null;

  /// Initialize the Gemini service
  Future<bool> initialize() async {
    try {
      _setState(ApiState.initializing);

      await dotenv.load();
      _apiKey = dotenv.env['GOOGLE_API_KEY'];

      if (_apiKey == null || _apiKey!.isEmpty) {
        _setError(AppConstants.apiKeyNotFound);
        return false;
      }

      _model = GenerativeModel(
        model: AppConstants.geminiModel,
        apiKey: _apiKey!,
      );

      _setState(ApiState.ready);
      return true;
    } catch (e) {
      _setError('Failed to initialize Gemini API: $e');
      return false;
    }
  }

  /// Analyze an image and return analysis result
  Future<AnalysisResult?> analyzeImage(
    Uint8List imageBytes, {
    String? customPrompt,
  }) async {
    if (!isReady) {
      _setError('Gemini service not ready');
      return null;
    }

    try {
      _setState(ApiState.processing);

      final prompt = customPrompt ?? AppConstants.defaultAnalysisPrompt;

      final response = await _model!.generateContent([
        Content.multi([
          TextPart(prompt),
          DataPart('image/jpeg', imageBytes),
        ]),
      ]);

      final analysisResult = _parseResponse(response.text ?? '');

      _setState(ApiState.ready);
      return analysisResult;
    } catch (e) {
      _setError('Analysis failed: $e');
      return null;
    }
  }

  /// Parse Gemini response into AnalysisResult
  AnalysisResult _parseResponse(String responseText) {
    try {
      // Try to parse as JSON first
      final jsonData = json.decode(responseText);
      return AnalysisResult.fromJson(jsonData);
    } catch (e) {
      // If JSON parsing fails, create a basic result with the text
      return AnalysisResult(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        timestamp: DateTime.now(),
        objects: [],
        sceneDescription: responseText,
        contextualInformation: null,
        overallConfidence: null,
        metadata: {
          'raw_response': responseText,
          'parsing_method': 'fallback',
        },
      );
    }
  }

  /// Get analysis configuration
  Map<String, dynamic> getConfiguration() {
    return {
      'model': AppConstants.geminiModel,
      'state': _state.toString(),
      'has_api_key': _apiKey != null,
      'is_ready': isReady,
    };
  }

  void _setState(ApiState newState) {
    _state = newState;
    if (newState != ApiState.error) {
      _errorMessage = null;
    }
  }

  void _setError(String message) {
    _errorMessage = message;
    _state = ApiState.error;
  }
}
