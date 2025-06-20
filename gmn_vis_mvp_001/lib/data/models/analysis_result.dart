import 'detected_object.dart';

/// Analysis result model
class AnalysisResult {
  final String id;
  final DateTime timestamp;
  final List<DetectedObject> objects;
  final String sceneDescription;
  final String? contextualInformation;

  const AnalysisResult({
    required this.id,
    required this.timestamp,
    required this.objects,
    required this.sceneDescription,
    this.contextualInformation,
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
    );
  }
}
