import 'package:flutter/material.dart';
import '../../data/models/detected_object.dart';

/// Custom painter for drawing detection overlays on camera preview
class DetectionOverlayPainter extends CustomPainter {
  final List<DetectedObject> objects;
  final Size previewSize;
  final double opacity;

  const DetectionOverlayPainter({
    required this.objects,
    required this.previewSize,
    this.opacity = 0.7,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (objects.isEmpty) return;

    final scaleX = size.width / previewSize.width;
    final scaleY = size.height / previewSize.height;

    for (final object in objects) {
      _drawBoundingBox(canvas, object, scaleX, scaleY);
      _drawLabel(canvas, object, scaleX, scaleY);
    }
  }

  void _drawBoundingBox(
    Canvas canvas,
    DetectedObject object,
    double scaleX,
    double scaleY,
  ) {
    final rect = Rect.fromLTWH(
      object.boundingBox.x * scaleX,
      object.boundingBox.y * scaleY,
      object.boundingBox.width * scaleX,
      object.boundingBox.height * scaleY,
    );

    final paint = Paint()
      ..color = _getColorForLabel(object.label).withValues(alpha: opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    canvas.drawRect(rect, paint);
  }

  void _drawLabel(
    Canvas canvas,
    DetectedObject object,
    double scaleX,
    double scaleY,
  ) {
    final label = '${object.label} (${(object.confidence * 100).toInt()}%)';

    final textSpan = TextSpan(
      text: label,
      style: TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.bold,
        shadows: [
          Shadow(
            offset: const Offset(1, 1),
            blurRadius: 2,
            color: Colors.black.withValues(alpha: 0.8),
          ),
        ],
      ),
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    )..layout();

    final labelX = object.boundingBox.x * scaleX;
    final labelY = (object.boundingBox.y * scaleY) - textPainter.height - 4;

    // Draw background for label
    final backgroundRect = Rect.fromLTWH(
      labelX - 4,
      labelY - 2,
      textPainter.width + 8,
      textPainter.height + 4,
    );

    final backgroundPaint = Paint()
      ..color = _getColorForLabel(object.label).withValues(alpha: 0.8);

    canvas.drawRect(backgroundRect, backgroundPaint);

    // Draw text
    textPainter.paint(canvas, Offset(labelX, labelY));
  }

  Color _getColorForLabel(String label) {
    // Generate consistent colors for different labels
    final hash = label.hashCode;
    final colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.cyan,
      Colors.pink,
      Colors.amber,
      Colors.indigo,
      Colors.teal,
    ];

    return colors[hash.abs() % colors.length];
  }

  @override
  bool shouldRepaint(covariant DetectionOverlayPainter oldDelegate) {
    return objects != oldDelegate.objects ||
        previewSize != oldDelegate.previewSize ||
        opacity != oldDelegate.opacity;
  }
}
