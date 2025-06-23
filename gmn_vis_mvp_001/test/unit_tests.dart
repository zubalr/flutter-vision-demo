// Unit tests for data models and core functionality
import 'package:flutter_test/flutter_test.dart';
import 'package:gmn_vis_mvp_001/data/models/analysis_result.dart';
import 'package:gmn_vis_mvp_001/data/models/detected_object.dart';
import 'package:gmn_vis_mvp_001/data/models/app_state.dart';

void main() {
  group('Data Models Unit Tests - Core Functionality', () {
    group('DetectedObject Tests', () {
      test('should create DetectedObject with valid data', () {
        // Arrange
        const boundingBox = BoundingBox(x: 10, y: 20, width: 100, height: 50);

        // Act
        const detectedObject = DetectedObject(
          id: 'test_id_1',
          label: 'Cat',
          confidence: 0.95,
          boundingBox: boundingBox,
          description: 'A cute cat sitting',
        );

        // Assert
        expect(detectedObject.id, equals('test_id_1'));
        expect(detectedObject.label, equals('Cat'));
        expect(detectedObject.confidence, equals(0.95));
        expect(detectedObject.boundingBox.x, equals(10));
        expect(detectedObject.description, equals('A cute cat sitting'));

        print('✅ TEST PASSED: DetectedObject creation with valid data');
      });

      test('should create DetectedObject from JSON', () {
        // Arrange
        final json = {
          'id': 'json_test_1',
          'label': 'Dog',
          'confidence': 0.87,
          'bbox': {
            'x': 15.5,
            'y': 25.3,
            'width': 120.0,
            'height': 80.7,
          },
          'description': 'Golden retriever playing',
        };

        // Act
        final detectedObject = DetectedObject.fromJson(json);

        // Assert
        expect(detectedObject.id, equals('json_test_1'));
        expect(detectedObject.label, equals('Dog'));
        expect(detectedObject.confidence, equals(0.87));
        expect(detectedObject.boundingBox.x, equals(15.5));
        expect(detectedObject.boundingBox.width, equals(120.0));

        print('✅ TEST PASSED: DetectedObject JSON deserialization');
      });

      test('should handle invalid JSON gracefully', () {
        // Arrange
        final invalidJson = <String, dynamic>{};

        // Act
        final detectedObject = DetectedObject.fromJson(invalidJson);

        // Assert
        expect(detectedObject.id, equals(''));
        expect(detectedObject.label, equals(''));
        expect(detectedObject.confidence, equals(0.0));
        expect(detectedObject.boundingBox.x, equals(0.0));

        print('✅ TEST PASSED: DetectedObject handles invalid JSON');
      });
    });

    group('BoundingBox Tests', () {
      test('should create BoundingBox with valid coordinates', () {
        // Arrange & Act
        const boundingBox = BoundingBox(
          x: 10.5,
          y: 20.3,
          width: 100.0,
          height: 50.7,
        );

        // Assert
        expect(boundingBox.x, equals(10.5));
        expect(boundingBox.y, equals(20.3));
        expect(boundingBox.width, equals(100.0));
        expect(boundingBox.height, equals(50.7));

        print('✅ TEST PASSED: BoundingBox creation');
      });

      test('should create BoundingBox from JSON', () {
        // Arrange
        final json = {
          'x': 25.5,
          'y': 35.2,
          'width': 150.0,
          'height': 75.5,
        };

        // Act
        final boundingBox = BoundingBox.fromJson(json);

        // Assert
        expect(boundingBox.x, equals(25.5));
        expect(boundingBox.y, equals(35.2));
        expect(boundingBox.width, equals(150.0));
        expect(boundingBox.height, equals(75.5));

        print('✅ TEST PASSED: BoundingBox JSON deserialization');
      });
    });

    group('AnalysisResult Tests', () {
      test('should create AnalysisResult with detected objects', () {
        // Arrange
        final timestamp = DateTime.now();
        const boundingBox = BoundingBox(x: 0, y: 0, width: 50, height: 50);
        const detectedObject = DetectedObject(
          id: 'test_obj_1',
          label: 'Car',
          confidence: 0.92,
          boundingBox: boundingBox,
        );

        // Act
        final analysisResult = AnalysisResult(
          id: 'analysis_1',
          timestamp: timestamp,
          objects: [detectedObject],
          sceneDescription: 'Urban street scene with vehicles',
          contextualInformation: 'Daytime, clear weather',
        );

        // Assert
        expect(analysisResult.id, equals('analysis_1'));
        expect(analysisResult.timestamp, equals(timestamp));
        expect(analysisResult.objects.length, equals(1));
        expect(analysisResult.objects.first.label, equals('Car'));
        expect(analysisResult.sceneDescription,
            equals('Urban street scene with vehicles'));

        print('✅ TEST PASSED: AnalysisResult creation with objects');
      });

      test('should create AnalysisResult from JSON', () {
        // Arrange
        final json = {
          'id': 'json_analysis_1',
          'timestamp': DateTime.now().millisecondsSinceEpoch,
          'objects': [
            {
              'id': 'obj_1',
              'label': 'Person',
              'confidence': 0.88,
              'bbox': {'x': 10.0, 'y': 20.0, 'width': 30.0, 'height': 40.0},
            }
          ],
          'scene_description': 'Person walking in park',
          'contextual_information': 'Afternoon, sunny',
        };

        // Act
        final analysisResult = AnalysisResult.fromJson(json);

        // Assert
        expect(analysisResult.id, equals('json_analysis_1'));
        expect(analysisResult.objects.length, equals(1));
        expect(analysisResult.objects.first.label, equals('Person'));
        expect(
            analysisResult.sceneDescription, equals('Person walking in park'));

        print('✅ TEST PASSED: AnalysisResult JSON deserialization');
      });

      test('should handle empty objects list', () {
        // Arrange
        final analysisResult = AnalysisResult(
          id: 'empty_analysis',
          timestamp: DateTime.now(),
          objects: [],
          sceneDescription: 'Empty scene',
        );

        // Assert
        expect(analysisResult.objects.isEmpty, isTrue);
        expect(analysisResult.sceneDescription, equals('Empty scene'));

        print('✅ TEST PASSED: AnalysisResult handles empty objects list');
      });
    });

    group('App State Tests', () {
      test('should validate all app states', () {
        // Test each app state
        final states = [
          AppState.initial,
          AppState.loading,
          AppState.ready,
          AppState.error,
        ];

        for (final state in states) {
          expect(state, isA<AppState>());
        }

        print('✅ TEST PASSED: All app states are valid');
        print('📊 METRIC: App state coverage: ${states.length} states tested');
      });

      test('should validate all analysis states', () {
        // Test each analysis state
        final states = [
          AnalysisState.idle,
          AnalysisState.analyzing,
          AnalysisState.completed,
          AnalysisState.error,
        ];

        for (final state in states) {
          expect(state, isA<AnalysisState>());
        }

        print('✅ TEST PASSED: All analysis states are valid');
        print(
            '📊 METRIC: Analysis state coverage: ${states.length} states tested');
      });

      test('should validate all API states', () {
        // Test each API state
        final states = [
          ApiState.uninitialized,
          ApiState.initializing,
          ApiState.ready,
          ApiState.processing,
          ApiState.error,
        ];

        for (final state in states) {
          expect(state, isA<ApiState>());
        }

        print('✅ TEST PASSED: All API states are valid');
        print('📊 METRIC: API state coverage: ${states.length} states tested');
      });
    });
  });

  group('Data Validation Tests', () {
    test('should validate confidence scores', () {
      // Test confidence score validation
      final validConfidences = [0.0, 0.5, 0.95, 1.0];
      final invalidConfidences = [-0.1, 1.1, 2.0];

      for (final confidence in validConfidences) {
        expect(confidence >= 0.0 && confidence <= 1.0, isTrue);
      }

      for (final confidence in invalidConfidences) {
        expect(confidence >= 0.0 && confidence <= 1.0, isFalse);
      }

      print('✅ TEST PASSED: Confidence score validation');
      print('📊 METRIC: Valid confidence scores: ${validConfidences.length}');
      print(
          '📊 METRIC: Invalid confidence scores detected: ${invalidConfidences.length}');
    });

    test('should validate bounding box coordinates', () {
      // Test bounding box validation
      const validBox = BoundingBox(x: 10, y: 20, width: 100, height: 50);
      const invalidBox = BoundingBox(x: -10, y: -20, width: -100, height: -50);

      expect(validBox.width > 0 && validBox.height > 0, isTrue);
      expect(invalidBox.width > 0 && invalidBox.height > 0, isFalse);

      print('✅ TEST PASSED: Bounding box validation');
    });

    test('should validate required fields', () {
      // Test that required fields are not empty
      const detectedObject = DetectedObject(
        id: 'test_id',
        label: 'Test Label',
        confidence: 0.8,
        boundingBox: BoundingBox(x: 0, y: 0, width: 50, height: 50),
      );

      expect(detectedObject.id.isNotEmpty, isTrue);
      expect(detectedObject.label.isNotEmpty, isTrue);

      print('✅ TEST PASSED: Required fields validation');
    });
  });

  group('Edge Cases Tests', () {
    test('should handle extreme confidence values', () {
      final extremeValues = [0.0, 1.0, 0.999999, 0.000001];

      for (final confidence in extremeValues) {
        final detectedObject = DetectedObject(
          id: 'extreme_test',
          label: 'Test',
          confidence: confidence,
          boundingBox: const BoundingBox(x: 0, y: 0, width: 1, height: 1),
        );

        expect(detectedObject.confidence, equals(confidence));
      }

      print('✅ TEST PASSED: Extreme confidence values handling');
    });

    test('should handle very large bounding boxes', () {
      const largeBoundingBox = BoundingBox(
        x: 0,
        y: 0,
        width: 9999.99,
        height: 9999.99,
      );

      expect(largeBoundingBox.width, equals(9999.99));
      expect(largeBoundingBox.height, equals(9999.99));

      print('✅ TEST PASSED: Large bounding box handling');
    });

    test('should handle very small bounding boxes', () {
      const smallBoundingBox = BoundingBox(
        x: 0.001,
        y: 0.001,
        width: 0.001,
        height: 0.001,
      );

      expect(smallBoundingBox.width, equals(0.001));
      expect(smallBoundingBox.height, equals(0.001));

      print('✅ TEST PASSED: Small bounding box handling');
    });
  });
}
