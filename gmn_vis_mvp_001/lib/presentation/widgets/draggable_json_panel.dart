import 'dart:convert';
import 'package:flutter/material.dart';
import '../../data/models/analysis_result.dart';

/// Draggable and resizable JSON output panel
class DraggableJsonPanel extends StatefulWidget {
  final AnalysisResult? result;
  final bool isAnalyzing;
  final String? errorMessage;

  const DraggableJsonPanel({
    super.key,
    this.result,
    this.isAnalyzing = false,
    this.errorMessage,
  });

  @override
  State<DraggableJsonPanel> createState() => _DraggableJsonPanelState();
}

class _DraggableJsonPanelState extends State<DraggableJsonPanel> {
  // Position and size state
  double _left = 20;
  double _top = 120;
  double _width = 400;
  double _height = 600;

  // Minimum and maximum constraints
  static const double _minWidth = 250;
  static const double _minHeight = 200;
  static const double _maxWidth = 600;
  static const double _maxHeight = 800;

  bool _isCollapsed = false;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    // Ensure panel stays within screen bounds with safety margins
    if (screenSize.width > 0 && screenSize.height > 0) {
      _left = _left.clamp(
          0.0, (screenSize.width - _width).clamp(0.0, screenSize.width));
      _top = _top.clamp(
          0.0,
          (screenSize.height - (_isCollapsed ? 50 : _height))
              .clamp(0.0, screenSize.height));
    }

    return Positioned(
      left: _left,
      top: _top,
      child: Container(
        width: _width,
        height: _isCollapsed ? 50 : _height,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.95),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: widget.isAnalyzing
                ? Colors.green
                : Colors.blue.withOpacity(0.7),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header with drag handle and controls
            _buildHeader(),
            // Content area (only shown when not collapsed)
            if (!_isCollapsed) ...[
              Expanded(child: _buildContent()),
              _buildResizeHandle(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return GestureDetector(
      onPanUpdate: (details) {
        setState(() {
          final screenSize = MediaQuery.of(context).size;
          if (screenSize.width > 0 && screenSize.height > 0) {
            _left = (_left + details.delta.dx).clamp(
                0.0, (screenSize.width - _width).clamp(0.0, screenSize.width));
            _top = (_top + details.delta.dy).clamp(
                0.0,
                (screenSize.height - (_isCollapsed ? 50 : _height))
                    .clamp(0.0, screenSize.height));
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: widget.isAnalyzing
              ? Colors.green.withOpacity(0.3)
              : Colors.blue.withOpacity(0.3),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft: _isCollapsed ? const Radius.circular(12) : Radius.zero,
            bottomRight: _isCollapsed ? const Radius.circular(12) : Radius.zero,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.drag_indicator,
              color: Colors.grey[300],
              size: 18,
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.data_object,
              color: widget.isAnalyzing ? Colors.green : Colors.blue,
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Live JSON (every 2s)',
                style: TextStyle(
                  color: widget.isAnalyzing ? Colors.green : Colors.blue,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (widget.isAnalyzing)
              const Padding(
                padding: EdgeInsets.only(right: 8),
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                  ),
                ),
              ),
            if (!_isCollapsed)
              Text(
                '${_width.round()}×${_height.round()}',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 11,
                ),
              ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                setState(() {
                  _isCollapsed = !_isCollapsed;
                });
              },
              child: Icon(
                _isCollapsed ? Icons.expand_more : Icons.expand_less,
                color: Colors.grey[300],
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status indicator
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: widget.errorMessage != null
                      ? Colors.red
                      : widget.isAnalyzing
                          ? Colors.green
                          : Colors.grey,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                widget.errorMessage != null
                    ? 'Error'
                    : widget.isAnalyzing
                        ? 'Analyzing...'
                        : 'Ready',
                style: TextStyle(
                  color: widget.errorMessage != null
                      ? Colors.red
                      : widget.isAnalyzing
                          ? Colors.green
                          : Colors.grey,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              if (widget.result != null)
                Text(
                  'Objects: ${widget.result!.objects.length}',
                  style: const TextStyle(
                    color: Colors.orange,
                    fontSize: 11,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          // JSON content
          Expanded(
            child: SingleChildScrollView(
              child: _buildJsonContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJsonContent() {
    if (widget.errorMessage != null) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          'Error: ${widget.errorMessage}',
          style: const TextStyle(
            color: Colors.red,
            fontSize: 11,
            fontFamily: 'monospace',
          ),
        ),
      );
    }

    if (widget.result == null) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text(
          'No analysis data yet.\n\nTap the play button to start continuous analysis.\n\nJSON output will appear here every 2 seconds.',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 11,
            fontFamily: 'monospace',
          ),
        ),
      );
    }

    // Create comprehensive JSON representation
    final jsonOutput = {
      'timestamp': widget.result!.timestamp.toIso8601String(),
      'analysis_id': widget.result!.id,
      'scene_description': widget.result!.sceneDescription,
      'objects': widget.result!.objects
          .map((obj) => {
                'id': obj.id,
                'name': obj.label,
                'confidence': obj.confidence,
                'description': obj.description,
                'bounding_box': {
                  'x': obj.boundingBox.x,
                  'y': obj.boundingBox.y,
                  'width': obj.boundingBox.width,
                  'height': obj.boundingBox.height,
                },
              })
          .toList(),
      'raw_gemini_response':
          widget.result!.contextualInformation ?? 'No response data',
      'total_objects_detected': widget.result!.objects.length,
      'analysis_status': 'success',
    };

    final jsonString = const JsonEncoder.withIndent('  ').convert(jsonOutput);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.green.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: SelectableText(
        jsonString,
        style: const TextStyle(
          color: Colors.green,
          fontSize: 10,
          fontFamily: 'monospace',
          height: 1.3,
        ),
      ),
    );
  }

  Widget _buildResizeHandle() {
    return GestureDetector(
      onPanUpdate: (details) {
        setState(() {
          _width = (_width + details.delta.dx).clamp(_minWidth, _maxWidth);
          _height = (_height + details.delta.dy).clamp(_minHeight, _maxHeight);

          // Ensure panel doesn't go off screen when resizing
          final screenSize = MediaQuery.of(context).size;
          if (screenSize.width > 0 && screenSize.height > 0) {
            _left = _left.clamp(
                0.0, (screenSize.width - _width).clamp(0.0, screenSize.width));
            _top = _top.clamp(0.0,
                (screenSize.height - _height).clamp(0.0, screenSize.height));
          }
        });
      },
      child: Container(
        width: double.infinity,
        height: 20,
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(12),
            bottomRight: Radius.circular(12),
          ),
        ),
        child: Center(
          child: Container(
            width: 30,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ),
    );
  }
}
