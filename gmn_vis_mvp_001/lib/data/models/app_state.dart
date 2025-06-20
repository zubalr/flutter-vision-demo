/// Application state enumeration
enum AppState {
  initial,
  loading,
  ready,
  error,
}

/// Camera state enumeration
enum CameraState {
  uninitialized,
  initializing,
  ready,
  capturing,
  error,
  disposed,
}

/// Analysis state enumeration
enum AnalysisState {
  idle,
  analyzing,
  completed,
  error,
}

/// API state enumeration
enum ApiState {
  uninitialized,
  initializing,
  ready,
  processing,
  error,
}

/// Permission state enumeration
enum PermissionState {
  unknown,
  granted,
  denied,
  permanentlyDenied,
}
