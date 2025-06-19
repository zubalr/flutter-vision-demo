# 🚀 Quick Setup Guide

## Step 1: Environment Setup

```bash
# 1. Copy environment template
cp .env.example .env

# 2. Edit .env file and add your Gemini API key
# Get your key from: https://makersuite.google.com/app/apikey
```

Your `.env` file should look like:

```
GOOGLE_API_KEY=AIzaSy...your_actual_api_key_here
FRAME_CAPTURE_INTERVAL_MS=1500
```

## Step 2: Install Dependencies

```bash
flutter pub get
```

## Step 3: Run the App

```bash
flutter run
```

## 🎯 Features to Test

1. **Camera Permission**: Grant camera access when prompted
2. **Single Analysis**: Tap the white camera button
3. **Continuous Analysis**: Tap the blue "Analyze" button
4. **View Results**: Tap the info icon (top right)
5. **Switch Camera**: Tap the flip icon (if multiple cameras available)

## 🛠️ Troubleshooting

### No Camera Access

- Check device permissions
- Restart app after granting permission

### API Errors

- Verify API key in `.env` file
- Check Google AI Studio quotas
- Ensure internet connectivity

### Build Issues

```bash
flutter clean
flutter pub get
flutter run
```

## 📱 App Structure Overview

- **Modern Architecture**: Clean separation of concerns
- **Reactive UI**: Stream-based state management
- **Error Handling**: Comprehensive error management
- **Performance**: Optimized for smooth real-time analysis
- **Accessibility**: Material 3 design principles

Ready to go! 🎉
