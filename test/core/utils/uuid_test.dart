import 'package:flutter_test/flutter_test.dart';
import 'package:jikgwan/core/utils/uuid.dart';

void main() {
  test('generates distinct RFC 4122 version 4 UUIDs', () {
    final pattern = RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
    );
    final ids = {for (var i = 0; i < 100; i++) generateUuidV4()};

    expect(ids, hasLength(100));
    expect(ids.every(pattern.hasMatch), isTrue);
  });
}
