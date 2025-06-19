/// App state types
enum AppState {
  initial,
  loading,
  ready,
  error,
}

/// Camera state types
enum CameraState {
  uninitialized,
  initializing,
  ready,
  capturing,
  error,
  disposed,
}

/// Analysis state types
enum AnalysisState {
  idle,
  analyzing,
  completed,
  error,
}

/// API state types
enum ApiState {
  uninitialized,
  initializing,
  ready,
  processing,
  error,
}

/// Permission state types
enum PermissionState {
  unknown,
  granted,
  denied,
  permanentlyDenied,
}
