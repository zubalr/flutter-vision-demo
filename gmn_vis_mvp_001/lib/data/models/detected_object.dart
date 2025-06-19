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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'confidence': confidence,
      'bbox': boundingBox.toJson(),
      if (description != null) 'description': description,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DetectedObject &&
        other.id == id &&
        other.label == label &&
        other.confidence == confidence &&
        other.boundingBox == boundingBox &&
        other.description == description;
  }

  @override
  int get hashCode {
    return Object.hash(id, label, confidence, boundingBox, description);
  }

  @override
  String toString() {
    return 'DetectedObject(id: $id, label: $label, confidence: $confidence, boundingBox: $boundingBox, description: $description)';
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
      width: (json['w'] as num?)?.toDouble() ?? 0.0,
      height: (json['h'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'x': x,
      'y': y,
      'w': width,
      'h': height,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BoundingBox &&
        other.x == x &&
        other.y == y &&
        other.width == width &&
        other.height == height;
  }

  @override
  int get hashCode {
    return Object.hash(x, y, width, height);
  }

  @override
  String toString() {
    return 'BoundingBox(x: $x, y: $y, width: $width, height: $height)';
  }
}
