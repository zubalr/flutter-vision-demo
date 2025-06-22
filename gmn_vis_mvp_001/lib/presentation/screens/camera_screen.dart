import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../../data/controllers/vision_controller.dart';
import '../../data/models/app_state.dart';
import '../../data/models/analysis_result.dart';
import '../widgets/detection_overlay.dart';
import '../widgets/analysis_info_panel.dart';
import '../widgets/draggable_json_panel.dart';
import '../../core/constants/app_constants.dart';

/// Modern camera screen with vision analysis
class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver {
  late final VisionController _controller;
  bool _showAnalysisPanel = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller = VisionController();
    _initializeController();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive) {
      _controller.stopAnalysis();
    }
  }

  Future<void> _initializeController() async {
    await _controller.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: StreamBuilder<AppState>(
        stream: _controller.appStateStream,
        initialData: _controller.appState,
        builder: (context, snapshot) {
          final appState = snapshot.data ?? AppState.initial;

          switch (appState) {
            case AppState.loading:
              return _buildLoadingView();
            case AppState.error:
              return _buildErrorView();
            case AppState.ready:
              return _buildCameraView();
            default:
              return _buildLoadingView();
          }
        },
      ),
    );
  }

  Widget _buildLoadingView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.white),
          SizedBox(height: 16),
          Text(
            'Initializing camera and AI services...',
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              _controller.errorMessage ?? 'An unknown error occurred',
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                await _controller.initialize();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraView() {
    if (_controller.cameraService.controller == null) {
      return _buildLoadingView();
    }

    return FutureBuilder<void>(
      future: _controller.cameraService.controller!.initialize(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return _buildCameraPreview();
        } else if (snapshot.hasError) {
          return _buildErrorView();
        } else {
          return _buildLoadingView();
        }
      },
    );
  }

  Widget _buildCameraPreview() {
    final controller = _controller.cameraService.controller!;
    final previewSize = controller.value.previewSize ?? const Size(1, 1);
    final aspectRatio = previewSize.width / previewSize.height;

    return Stack(
      fit: StackFit.expand,
      children: [
        // Camera preview
        Center(
          child: AspectRatio(
            aspectRatio: aspectRatio,
            child: CameraPreview(controller),
          ),
        ),

        // Detection overlay
        StreamBuilder<AnalysisResult?>(
          stream: _controller.resultStream,
          builder: (context, snapshot) {
            final result = snapshot.data;
            if (result != null && result.objects.isNotEmpty) {
              return CustomPaint(
                painter: DetectionOverlayPainter(
                  objects: result.objects,
                  previewSize: previewSize,
                ),
                size: Size.infinite,
              );
            }
            return const SizedBox.shrink();
          },
        ),

        // Top app bar
        _buildTopAppBar(),

        // JSON output panel
        StreamBuilder<AnalysisResult?>(
          stream: _controller.resultStream,
          builder: (context, resultSnapshot) {
            return StreamBuilder<AnalysisState>(
              stream: _controller.analysisStateStream,
              builder: (context, stateSnapshot) {
                return StreamBuilder<String?>(
                  stream: _controller.errorStream,
                  builder: (context, errorSnapshot) {
                    return DraggableJsonPanel(
                      result: resultSnapshot.data,
                      isAnalyzing:
                          stateSnapshot.data == AnalysisState.analyzing,
                      errorMessage: errorSnapshot.data,
                    );
                  },
                );
              },
            );
          },
        ),

        // Analysis info panel
        if (_showAnalysisPanel) _buildAnalysisPanel(),

        // Bottom controls
        _buildBottomControls(),
      ],
    );
  }

  Widget _buildTopAppBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top,
          left: AppConstants.defaultPadding,
          right: AppConstants.defaultPadding,
          bottom: AppConstants.defaultPadding,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withValues(alpha: 0.7),
              Colors.transparent,
            ],
          ),
        ),
        child: Row(
          children: [
            const Text(
              AppConstants.appName,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            IconButton(
              onPressed: () {
                setState(() {
                  _showAnalysisPanel = !_showAnalysisPanel;
                });
              },
              icon: Icon(
                _showAnalysisPanel ? Icons.info : Icons.info_outline,
                color: Colors.white,
              ),
            ),
            if (_controller.cameraService.cameras.length > 1)
              IconButton(
                onPressed: () async {
                  await _controller.switchCamera();
                },
                icon: const Icon(
                  Icons.flip_camera_ios,
                  color: Colors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisPanel() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        margin: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 60,
        ),
        child: StreamBuilder<AnalysisResult?>(
          stream: _controller.resultStream,
          builder: (context, resultSnapshot) {
            return StreamBuilder<AnalysisState>(
              stream: _controller.analysisStateStream,
              builder: (context, stateSnapshot) {
                return StreamBuilder<String?>(
                  stream: _controller.errorStream,
                  builder: (context, errorSnapshot) {
                    return AnalysisInfoPanel(
                      result: resultSnapshot.data,
                      isAnalyzing:
                          stateSnapshot.data == AnalysisState.analyzing,
                      errorMessage: errorSnapshot.data,
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.only(
          left: AppConstants.defaultPadding,
          right: AppConstants.defaultPadding,
          bottom: MediaQuery.of(context).padding.bottom +
              AppConstants.defaultPadding,
          top: AppConstants.defaultPadding,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Colors.black.withValues(alpha: 0.7),
              Colors.transparent,
            ],
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Single capture button
            FloatingActionButton(
              heroTag: 'capture',
              onPressed: () async {
                await _controller.captureAndAnalyze();
              },
              backgroundColor: Colors.white,
              child: const Icon(
                Icons.camera_alt,
                color: Colors.black,
              ),
            ),

            // Start/Stop continuous analysis
            StreamBuilder<AnalysisState>(
              stream: _controller.analysisStateStream,
              builder: (context, snapshot) {
                final isAnalyzing = snapshot.data == AnalysisState.analyzing;

                return FloatingActionButton(
                  heroTag: 'analysis',
                  onPressed: () async {
                    if (isAnalyzing) {
                      _controller.stopAnalysis();
                    } else {
                      await _controller.startAnalysis();
                    }
                  },
                  backgroundColor: isAnalyzing
                      ? Colors.red.withValues(alpha: 0.9)
                      : Colors.blue.withValues(alpha: 0.9),
                  child: Icon(
                    isAnalyzing ? Icons.stop : Icons.play_arrow,
                    color: Colors.white,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
