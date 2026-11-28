/// 저장소 전체(`{"schemaVersion": n, "records": [...]}`)의 버전 변환.
///
/// 형식이 바뀌면 [currentSchemaVersion]을 올리고 [attendanceMigrations]에
/// `이전 버전 → 다음 버전` 변환을 추가한다. 앱 시작 때 저장소를 읽으며 변환하고
/// 바로 새 버전으로 다시 저장한다 (정책서 6.3).
library;

const currentSchemaVersion = 1;

typedef AttendanceMigration =
    Map<String, dynamic> Function(Map<String, dynamic> storage);

/// key: 변환 전 버전. 예: `1: (s) => ...`는 1 → 2.
const Map<int, AttendanceMigration> attendanceMigrations = {};

/// 앱이 아는 것보다 새 버전의 저장소 (앱을 이전 버전으로 되돌린 경우 등).
/// 덮어쓰면 데이터를 잃으므로 읽기만 막고 저장도 하지 않는다.
class UnsupportedAttendanceSchema implements Exception {
  const UnsupportedAttendanceSchema(this.version);

  final int version;
}

/// [storage]를 [targetVersion]까지 변환한다. 이미 그 버전이면 그대로.
Map<String, dynamic> migrateAttendanceStorage(
  Map<String, dynamic> storage, {
  int targetVersion = currentSchemaVersion,
  Map<int, AttendanceMigration> migrations = attendanceMigrations,
}) {
  var version = storage['schemaVersion'] as int? ?? 1;
  if (version > targetVersion) throw UnsupportedAttendanceSchema(version);
  var migrated = storage;
  while (version < targetVersion) {
    final migration = migrations[version];
    if (migration == null) throw UnsupportedAttendanceSchema(version);
    migrated = Map<String, dynamic>.of(migration(migrated));
    version++;
    migrated['schemaVersion'] = version;
  }
  return migrated;
}
