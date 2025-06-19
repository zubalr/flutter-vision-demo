import 'detected_object.dart';

/// Analysis result model
class AnalysisResult {
  final String id;
  final DateTime timestamp;
  final List<DetectedObject> objects;
  final String sceneDescription;
  final String? contextualInformation;
  final double? overallConfidence;
  final Map<String, dynamic>? metadata;

  const AnalysisResult({
    required this.id,
    required this.timestamp,
    required this.objects,
    required this.sceneDescription,
    this.contextualInformation,
    this.overallConfidence,
    this.metadata,
  });

  factory AnalysisResult.fromJson(Map<String, dynamic> json) {
    return AnalysisResult(
      id: json['id']?.toString() ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      timestamp: json['timestamp'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['timestamp'])
          : DateTime.now(),
      objects: (json['objects'] as List<dynamic>?)
              ?.map((e) => DetectedObject.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      sceneDescription: json['scene_description']?.toString() ??
          json['scene_context']?.toString() ??
          '',
      contextualInformation: json['contextual_information']?.toString(),
      overallConfidence: (json['overall_confidence'] as num?)?.toDouble(),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'objects': objects.map((e) => e.toJson()).toList(),
      'scene_description': sceneDescription,
      if (contextualInformation != null)
        'contextual_information': contextualInformation,
      if (overallConfidence != null) 'overall_confidence': overallConfidence,
      if (metadata != null) 'metadata': metadata,
    };
  }

  /// Creates a copy of this analysis result with the given fields replaced with new values
  AnalysisResult copyWith({
    String? id,
    DateTime? timestamp,
    List<DetectedObject>? objects,
    String? sceneDescription,
    String? contextualInformation,
    double? overallConfidence,
    Map<String, dynamic>? metadata,
  }) {
    return AnalysisResult(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      objects: objects ?? this.objects,
      sceneDescription: sceneDescription ?? this.sceneDescription,
      contextualInformation:
          contextualInformation ?? this.contextualInformation,
      overallConfidence: overallConfidence ?? this.overallConfidence,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AnalysisResult &&
        other.id == id &&
        other.timestamp == timestamp &&
        other.sceneDescription == sceneDescription &&
        other.contextualInformation == contextualInformation &&
        other.overallConfidence == overallConfidence;
  }

  @override
  int get hashCode {
    return Object.hash(id, timestamp, sceneDescription, contextualInformation,
        overallConfidence);
  }

  @override
  String toString() {
    return 'AnalysisResult(id: $id, timestamp: $timestamp, objects: ${objects.length}, sceneDescription: $sceneDescription)';
  }
}
