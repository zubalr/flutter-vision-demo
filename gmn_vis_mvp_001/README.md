# gmn_vis_mvp_001

# Vision Demo App

A modern Flutter app that uses camera and Google's Gemini AI to analyze images in real-time.

## Features

- 📱 **Real-time Camera Preview**: High-quality camera feed with modern UI
- 🤖 **AI-Powered Analysis**: Uses Google's Gemini AI for image analysis
- 🎯 **Object Detection**: Detects and highlights objects in camera view
- 📊 **Live Analysis**: Continuous analysis with customizable intervals
- 🔄 **Multi-Camera Support**: Switch between front and back cameras
- 🎨 **Modern UI**: Clean, responsive design with Material 3
- 🌙 **Dark Mode**: Automatic light/dark theme switching
- 📝 **Detailed Results**: Scene descriptions and object information

## Architecture

This app follows a clean, modular architecture:

```
lib/
├── core/
│   ├── constants/          # App-wide constants
│   ├── theme/             # Theme configuration
│   └── utils/             # Utility functions
├── data/
│   ├── controllers/       # Business logic controllers
│   ├── models/           # Data models
│   └── services/         # External service integrations
└── presentation/
    ├── screens/          # UI screens
    └── widgets/          # Reusable UI components
```

## Setup

### Prerequisites

- Flutter SDK (latest version)
- Dart SDK
- Android Studio / Xcode for device testing
- Google AI Studio account (for Gemini API)

### Installation

1. **Clone the repository**

   ```bash
   git clone <repository-url>
   cd gmn_vis_mvp_001
   ```

2. **Install dependencies**

   ```bash
   flutter pub get
   ```

3. **Set up environment variables**

   - Copy `.env.example` to `.env`
   - Get your Gemini API key from [Google AI Studio](https://makersuite.google.com/app/apikey)
   - Add your API key to `.env`:
     ```
     GOOGLE_API_KEY=your_actual_api_key_here
     FRAME_CAPTURE_INTERVAL_MS=1500
     ```

4. **Run the app**
   ```bash
   flutter run
   ```

## Configuration

### Environment Variables

- `GOOGLE_API_KEY`: Your Gemini API key (required)
- `FRAME_CAPTURE_INTERVAL_MS`: Time between automatic captures (default: 1500ms)

### Customization

- **Capture Interval**: Modify in `.env` file or through app settings
- **Theme**: Automatically follows system theme preferences
- **Analysis Prompt**: Customize in `AppConstants.defaultAnalysisPrompt`

## Usage

1. **Grant Permissions**: Allow camera access when prompted
2. **Start Analysis**: Tap the blue "Analyze" button to start continuous analysis
3. **Single Capture**: Use the camera button for one-time analysis
4. **View Results**: Tap the info icon to see detailed analysis results
5. **Switch Camera**: Use the flip icon to switch between cameras

## API Integration

The app integrates with Google's Gemini Pro Vision model for:

- Object detection and classification
- Scene understanding and description
- Contextual information extraction

## Testing

Run tests with:

```bash
flutter test
```

For integration tests:

```bash
flutter drive --target=test_driver/app.dart
```

## Building

### Android

```bash
flutter build apk --release
```

### iOS

```bash
flutter build ios --release
```

## Troubleshooting

### Common Issues

1. **Camera Permission Denied**

   - Check device settings
   - Restart the app after granting permission

2. **API Key Issues**

   - Verify API key in `.env` file
   - Check Google AI Studio quota limits
   - Ensure API key has proper permissions

3. **Build Issues**
   - Run `flutter clean && flutter pub get`
   - Check Flutter version compatibility
   - Verify all dependencies are up to date

### Performance Tips

- Adjust capture interval based on device performance
- Close other camera apps before running
- Use release builds for better performance

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
