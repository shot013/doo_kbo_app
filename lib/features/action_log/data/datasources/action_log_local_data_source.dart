import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/action_log_model.dart';

/// 아직 서버로 보내지 못한 행동 로그를 기기에 영속화한다. flush 주기(1분)가
/// 되기 전에 앱이 종료되더라도 로그가 사라지지 않도록, 이동이 기록될 때마다
/// 바로 여기 쓰고, 서버 전송에 성공했을 때만 지운다.
abstract interface class ActionLogLocalDataSource {
  Future<void> append(ActionLogModel log);

  Future<List<ActionLogModel>> readAll();

  Future<void> clear();
}

class ActionLogLocalDataSourceImpl implements ActionLogLocalDataSource {
  const ActionLogLocalDataSourceImpl(this._preferences);

  final SharedPreferences _preferences;

  static const _storageKey = 'action_log_pending_logs';

  @override
  Future<void> append(ActionLogModel log) async {
    final logs = await readAll()
      ..add(log);
    await _write(logs);
  }

  @override
  Future<List<ActionLogModel>> readAll() async {
    final raw = _preferences.getString(_storageKey);
    if (raw == null || raw.isEmpty) {
      return [];
    }
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((json) => ActionLogModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> clear() => _preferences.remove(_storageKey);

  Future<void> _write(List<ActionLogModel> logs) {
    final encoded = jsonEncode(logs.map((log) => log.toJson()).toList());
    return _preferences.setString(_storageKey, encoded);
  }
}
