/// App constants
class AppConstants {
  static const String appName = 'Vision Demo';
  static const String appVersion = '1.0.0';

  // API Constants
  static const String geminiModel = 'gemini-pro-vision';
  static const String defaultAnalysisPrompt =
      'Analyze this image and identify objects, people, and scene context. Provide a detailed description of what you see.';

  // Camera Constants
  static const int defaultCaptureIntervalMs = 1500;
  static const int minCaptureIntervalMs = 500;
  static const int maxCaptureIntervalMs = 5000;

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;

  // Error Messages
  static const String cameraPermissionDenied =
      'Camera permission is required to use this feature';
  static const String noCamerasFound = 'No cameras found on this device';
  static const String apiKeyNotFound =
      'Gemini API key not found. Please check your .env file';
  static const String cameraInitializationFailed =
      'Failed to initialize camera';
  static const String analysisError = 'Failed to analyze image';
}
