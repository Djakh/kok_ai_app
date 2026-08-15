import 'package:flutter_test/flutter_test.dart';
import 'package:kok_ai_app/features/tree_registration/data/dto/tree_dto_mapper.dart';
import 'package:kok_ai_app/features/tree_registration/domain/entities/tree_models.dart';

void main() {
  test('analysis DTO maps nullable normalized provider data', () {
    final analysis = TreeDtoMapper.analysis({
      'id': 'analysis-1',
      'provider': 'kindwise_plant_id',
      'analyzed_at': '2026-08-15T10:00:00Z',
      'candidates': [
        {
          'id': 'species-1',
          'scientific_name': 'Platanus orientalis',
          'confidence': 1.7,
          'common_name': null,
        },
      ],
    });

    expect(analysis.id, 'analysis-1');
    expect(analysis.providerName, 'kindwise_plant_id');
    expect(analysis.candidates.single.commonName, isNull);
    expect(analysis.candidates.single.confidence, 1);
    expect(analysis.health, isNull);
  });

  test('unknown enums fall back safely', () {
    expect(
      TreePhotoType.fromApi('future_photo_type'),
      TreePhotoType.additional,
    );
    expect(LocationQuality.fromApi('future_quality'), LocationQuality.poor);
  });

  test('tree DTO separates health from registration status', () {
    final tree = TreeDtoMapper.tree({
      'id': 'tree-1',
      'registered_at': '2026-08-15T10:00:00Z',
      'location': {
        'latitude': 41.3,
        'longitude': 69.2,
        'horizontal_accuracy_meters': 6.2,
        'quality': 'acceptable',
      },
      'identification': {
        'common_name': 'Oriental plane',
        'scientific_name': 'Platanus orientalis',
        'source': 'user_confirmed_ai',
      },
    });

    expect(tree.displayName, 'Oriental plane');
    expect(tree.health, isNull);
    expect(tree.location.quality, LocationQuality.acceptable);
  });

  test('full detail retains typed photos and authorization metadata', () {
    final tree = TreeDtoMapper.tree({
      'id': 'tree-1',
      'nickname': null,
      'registered_at': '2026-08-15T10:00:00Z',
      'last_scanned_at': null,
      'primary_image_url': null,
      'photos': [
        {'type': 'whole_tree', 'url': 'https://media.example/whole.jpg'},
        {'type': 'leaf', 'url': 'https://media.example/leaf.jpg'},
      ],
      'location': {
        'latitude': 41.3,
        'longitude': 69.2,
        'horizontal_accuracy_meters': 6.2,
        'quality': 'future_quality',
      },
      'identification': {
        'common_name': null,
        'scientific_name': null,
        'ai_confidence': null,
        'ai_provider': null,
        'source': 'future_source',
        'description': null,
      },
      'health': null,
      'owner_id': 'owner-1',
      'notes': 'Private note',
      'visibility': 'future_visibility',
    });

    expect(tree.nickname, isNull);
    expect(tree.photos.map((item) => item.type), ['whole_tree', 'leaf']);
    expect(tree.primaryImageUrl, 'https://media.example/whole.jpg');
    expect(tree.ownerId, 'owner-1');
    expect(tree.notes, 'Private note');
    expect(tree.visibility, 'future_visibility');
    expect(tree.identificationSource, 'future_source');
    expect(tree.location.quality, LocationQuality.poor);
  });

  test('malformed candidate never invents a species name', () {
    expect(
      () => TreeDtoMapper.analysis({
        'id': 'analysis-1',
        'provider': 'kindwise_plant_id',
        'candidates': [
          {'id': 'candidate-1', 'scientific_name': null, 'confidence': .4},
        ],
      }),
      throwsFormatException,
    );
  });
}
