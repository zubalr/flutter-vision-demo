/// Application constants
class AppConstants {
  static const String appName = 'Vision Demo';

  // API Constants
  static const String geminiModel = 'gemini-2.5-flash';
  static const String defaultAnalysisPrompt =
      '''Analyze this image and provide a structured JSON response with exactly this format. Do not include any text before or after the JSON:

{
  "scene_description": "Brief description of the overall scene",
  "total_objects": "number of objects detected",
  "objects": [
    {
      "id": "unique identifier for the object",
      "name": "object name",
      "confidence": 0.95,
      "location": "spatial description (e.g., 'top left', 'center', 'bottom right')",
      "details": "additional details about the object",
      "bounding_box": {
        "x": 100,
        "y": 150,
        "width": 200,
        "height": 120
      }
    }
  ],
  "context": "What is happening in this image"
}

Please identify all visible objects, people, and their locations in the image. Provide approximate bounding box coordinates (x, y, width, height) for each object where x,y is the top-left corner. Return only valid JSON without any markdown formatting.''';

  // Camera Constants
  static const int defaultCaptureIntervalMs =
      2000; // 2 seconds for live analysis
  static const int minCaptureIntervalMs = 500;
  static const int maxCaptureIntervalMs = 5000;

  // UI Constants
  static const double defaultPadding = 16.0;

  // Error Messages
  static const String cameraPermissionDenied =
      'Camera permission is required to use this feature';
  static const String noCamerasFound = 'No cameras found on this device';
  static const String apiKeyNotFound =
      'Gemini API key not found. Please check your .env file';
  static const String cameraInitializationFailed =
      'Failed to initialize camera';
  static const String analysisError = 'Failed to analyze image';
  static const String apiConnectionError =
      'Cannot connect to Gemini API. Please check your internet connection and API key';
  static const String unsupportedModelError =
      'Model not supported. Please use gemini-2.5-flash or gemini-2.5-pro';
}
