/// Detected object model
class DetectedObject {
  final String id;
  final String label;
  final double confidence;
  final BoundingBox boundingBox;
  final String? description;

  const DetectedObject({
    required this.id,
    required this.label,
    required this.confidence,
    required this.boundingBox,
    this.description,
  });

  factory DetectedObject.fromJson(Map<String, dynamic> json) {
    return DetectedObject(
      id: json['id']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      boundingBox: BoundingBox.fromJson(json['bbox'] ?? {}),
      description: json['description']?.toString(),
    );
  }
}

/// Bounding box model for detected objects
class BoundingBox {
  final double x;
  final double y;
  final double width;
  final double height;

  const BoundingBox({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  factory BoundingBox.fromJson(Map<String, dynamic> json) {
    return BoundingBox(
      x: (json['x'] as num?)?.toDouble() ?? 0.0,
      y: (json['y'] as num?)?.toDouble() ?? 0.0,
      width: (json['width'] as num?)?.toDouble() ?? 0.0,
      height: (json['height'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
