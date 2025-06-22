import 'dart:convert';
import 'dart:typed_data';
import 'dart:math' as math;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/analysis_result.dart';
import '../models/app_state.dart';
import '../models/detected_object.dart';
import '../../core/constants/app_constants.dart';

/// Gemini AI service for image analysis
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
        print('Debug: API key not found in .env file');
        return false;
      }

      print('Debug: API key found, length: ${_apiKey!.length}');
      print('Debug: API key starts with: ${_apiKey!.substring(0, 10)}...');

      // Simplified configuration for text-only output
      _model = GenerativeModel(
        model: AppConstants.geminiModel,
        apiKey: _apiKey!,
        generationConfig: GenerationConfig(
          temperature: 0.4,
          topK: 32,
          topP: 1,
          maxOutputTokens: 2048,
        ),
      );

      print('Debug: Model created with ${AppConstants.geminiModel}');

      // Skip connection test for now - just set ready
      _setState(ApiState.ready);
      print('Debug: Gemini service initialized successfully');
      return true;
    } catch (e) {
      print('Debug: Initialization error: $e');
      _setError('Failed to initialize Gemini API: $e');
      return false;
    }
  }

  /// Analyze an image and return structured analysis result
  Future<AnalysisResult?> analyzeImage(
    Uint8List imageBytes, {
    String? customPrompt,
  }) async {
    // Skip if already processing to avoid queue buildup
    if (_state == ApiState.processing) {
      print('Debug: Analysis already in progress, skipping this request');
      return null;
    }

    if (!isReady) {
      print(
          'Debug: Service not ready, state: $_state, model: ${_model != null}');
      return null;
    }

    try {
      _setState(ApiState.processing);

      final prompt = customPrompt ?? AppConstants.defaultAnalysisPrompt;

      print(
          'Debug: Starting image analysis with prompt: ${prompt.substring(0, 50)}...');

      // Configure for structured output - using simpler approach
      final imageData = DataPart('image/jpeg', imageBytes);
      final textPart = TextPart(prompt);

      print(
          'Debug: About to call generateContent with ${imageBytes.length} bytes of image data');

      final response = await _model!.generateContent([
        Content.multi([textPart, imageData])
      ]);

      print('Debug: Received response from Gemini API');

      _setState(ApiState.ready); // Set ready immediately after API call

      if (response.text == null || response.text!.isEmpty) {
        print('Debug: Empty response received');
        return null;
      }

      print(
          'Debug: Received response: ${response.text!.substring(0, math.min(200, response.text!.length))}...');

      // Just return the raw response without trying to parse it
      final result = AnalysisResult(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        timestamp: DateTime.now(),
        objects: [], // No objects since we're not parsing
        sceneDescription: 'Raw Gemini Response (First 2000 chars)',
        contextualInformation: response.text!.length > 2000
            ? '${response.text!.substring(0, 2000)}...'
            : response.text!,
      );

      print(
          'Debug: Analysis completed successfully, service ready for next call');
      return result;
    } on GenerativeAIException catch (e) {
      _setState(ApiState.ready); // Always return to ready state
      // Handle specific Gemini API errors
      String errorMessage = 'Gemini API error: ${e.message}';
      if (e.message.contains('model')) {
        errorMessage = AppConstants.unsupportedModelError;
      } else if (e.message.contains('quota') || e.message.contains('limit')) {
        errorMessage = 'API quota exceeded. Please try again later.';
      } else if (e.message.contains('permission') ||
          e.message.contains('auth')) {
        errorMessage = 'API key is invalid or lacks permissions.';
      }
      print('Debug: API Exception: $errorMessage');
      return null;
    } catch (e) {
      _setState(ApiState.ready); // Always return to ready state
      print('Debug: Analysis error: $e');
      return null;
    }
  }

  /// Parse structured JSON response into AnalysisResult
  AnalysisResult _parseStructuredResponse(String responseText) {
    try {
      // More aggressive JSON cleaning
      String cleanJson = _cleanJsonResponse(responseText);

      print(
          'Debug: Attempting to parse cleaned JSON: ${cleanJson.substring(0, math.min(200, cleanJson.length))}...');

      final jsonData = json.decode(cleanJson);
      print('Debug: JSON parsing successful');

      // Extract objects from JSON
      List<DetectedObject> objects = [];
      if (jsonData['objects'] != null && jsonData['objects'] is List) {
        for (var obj in jsonData['objects']) {
          if (obj is Map<String, dynamic>) {
            // Parse bounding box from the object
            BoundingBox bbox;
            if (obj['bounding_box'] != null && obj['bounding_box'] is Map) {
              final bboxData = obj['bounding_box'] as Map<String, dynamic>;
              bbox = BoundingBox(
                x: (bboxData['x'] as num?)?.toDouble() ?? 0.0,
                y: (bboxData['y'] as num?)?.toDouble() ?? 0.0,
                width: (bboxData['width'] as num?)?.toDouble() ?? 100.0,
                height: (bboxData['height'] as num?)?.toDouble() ?? 100.0,
              );
            } else {
              // Fallback bounding box
              bbox = BoundingBox(x: 0, y: 0, width: 100, height: 100);
            }

            objects.add(DetectedObject(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              label: obj['name']?.toString() ?? 'Unknown',
              confidence: (obj['confidence'] is num)
                  ? obj['confidence'].toDouble()
                  : 0.5,
              boundingBox: bbox,
              description:
                  '${obj['details']?.toString() ?? ''} (${obj['location']?.toString() ?? 'unknown location'})',
            ));
          }
        }
      }

      final result = AnalysisResult(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        timestamp: DateTime.now(),
        objects: objects,
        sceneDescription:
            jsonData['scene_description']?.toString() ?? 'Unknown scene',
        contextualInformation: jsonData['context']?.toString(),
      );

      print('Debug: Parsed ${objects.length} objects from JSON response');
      return result;
    } catch (e) {
      print('Debug: JSON parsing failed: $e');
      print(
          'Debug: Raw response (first 1000 chars): ${responseText.substring(0, responseText.length > 1000 ? 1000 : responseText.length)}');

      // Return raw response without trying to parse it
      return AnalysisResult(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        timestamp: DateTime.now(),
        objects: [],
        sceneDescription: 'Raw Gemini Response',
        contextualInformation: responseText.length > 1000
            ? '${responseText.substring(0, 1000)}...'
            : responseText,
      );
    }
  }

  /// Test API connectivity with a simple text prompt
  Future<bool> testApiConnection() async {
    if (!isReady) {
      _setError('Gemini service not ready');
      return false;
    }

    try {
      final response = await _model!.generateContent([
        Content.text('Hello, respond with "API connection successful"'),
      ]);

      return response.text?.isNotEmpty == true;
    } catch (e) {
      _setError('API connection test failed: $e');
      return false;
    }
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

  /// Clean JSON response text to handle malformed JSON from Gemini
  String _cleanJsonResponse(String responseText) {
    // Remove markdown formatting
    String cleanJson = responseText.trim();
    if (cleanJson.startsWith('```json')) {
      cleanJson = cleanJson.substring(7);
    }
    if (cleanJson.endsWith('```')) {
      cleanJson = cleanJson.substring(0, cleanJson.length - 3);
    }
    cleanJson = cleanJson.trim();

    // Find the start and end of the JSON object
    int jsonStart = cleanJson.indexOf('{');
    if (jsonStart == -1) {
      throw FormatException('No JSON object found in response');
    }

    // Find the matching closing brace
    int braceCount = 0;
    int jsonEnd = -1;
    for (int i = jsonStart; i < cleanJson.length; i++) {
      if (cleanJson[i] == '{') {
        braceCount++;
      } else if (cleanJson[i] == '}') {
        braceCount--;
        if (braceCount == 0) {
          jsonEnd = i;
          break;
        }
      }
    }

    if (jsonEnd == -1) {
      throw FormatException('No matching closing brace found');
    }

    // Extract just the JSON part
    cleanJson = cleanJson.substring(jsonStart, jsonEnd + 1);

    // Fix common JSON formatting issues
    cleanJson = cleanJson
        .replaceAll('\n', ' ')
        .replaceAll('\r', ' ')
        .replaceAll('\t', ' ');

    // Remove multiple spaces
    cleanJson = cleanJson.replaceAll(RegExp(r'\s+'), ' ');

    // Fix trailing commas before closing braces/brackets
    cleanJson = cleanJson.replaceAll(RegExp(r',\s*}'), '}');
    cleanJson = cleanJson.replaceAll(RegExp(r',\s*]'), ']');

    return cleanJson;
  }
}
