import 'dart:convert';
import 'package:flutter/material.dart';
import '../../data/models/analysis_result.dart';

/// Widget to display JSON analysis output in the UI corner
class JsonOutputPanel extends StatelessWidget {
  final AnalysisResult? result;
  final bool isAnalyzing;
  final String? errorMessage;

  const JsonOutputPanel({
    super.key,
    this.result,
    this.isAnalyzing = false,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 80,
      right: 16,
      child: Container(
        width: 320,
        height: 450,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.90),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isAnalyzing ? Colors.green : Colors.blue.withOpacity(0.5),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isAnalyzing
                    ? Colors.green.withOpacity(0.3)
                    : Colors.blue.withOpacity(0.2),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.data_object,
                    color: Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Live JSON Output (1s)',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  if (isAnalyzing)
                    Container(
                      width: 16,
                      height: 16,
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  else
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(12),
                child: _buildContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (errorMessage != null) {
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red.withOpacity(0.3)),
        ),
        child: Text(
          'Error: $errorMessage',
          style: const TextStyle(
            color: Colors.red,
            fontSize: 11,
            fontFamily: 'monospace',
          ),
        ),
      );
    }

    if (isAnalyzing && result == null) {
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.yellow.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.yellow.withOpacity(0.3)),
        ),
        child: const Column(
          children: [
            CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.yellow),
            ),
            SizedBox(height: 8),
            Text(
              'Analyzing frame...\nAwaiting JSON response...',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.yellow,
                fontSize: 11,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
      );
    }

    if (result == null) {
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.withOpacity(0.3)),
        ),
        child: const Text(
          'No analysis data yet.\n\nPress the blue play button to start continuous live analysis every second.\n\nJSON output with bounding box coordinates will appear here.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey,
            fontSize: 11,
            fontFamily: 'monospace',
          ),
        ),
      );
    }

    // Create enhanced JSON representation of the result
    final jsonOutput = {
      'timestamp': result!.timestamp.toIso8601String(),
      'analysis_id': result!.id,
      'scene_description': result!.sceneDescription,
      'objects': result!.objects
          .map((obj) => {
                'id': obj.id,
                'name': obj.label,
                'confidence': double.parse(obj.confidence.toStringAsFixed(3)),
                'location_description': obj.description,
                'bounding_box': {
                  'x': obj.boundingBox.x.toInt(),
                  'y': obj.boundingBox.y.toInt(),
                  'width': obj.boundingBox.width.toInt(),
                  'height': obj.boundingBox.height.toInt(),
                },
              })
          .toList(),
      'contextual_information': result!.contextualInformation ?? 'N/A',
      'total_objects_detected': result!.objects.length,
      'analysis_status': 'success',
    };

    final jsonString = const JsonEncoder.withIndent('  ').convert(jsonOutput);

    return SelectableText(
      jsonString,
      style: const TextStyle(
        color: Colors.greenAccent,
        fontSize: 10,
        fontFamily: 'monospace',
        height: 1.3,
      ),
    );
  }
}
