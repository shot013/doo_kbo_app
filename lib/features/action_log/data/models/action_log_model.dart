import '../../domain/entities/action_log.dart';

final class ActionLogModel extends ActionLog {
  const ActionLogModel({
    required super.route,
    required super.occurredAt,
    super.previousRoute,
    super.params,
    super.platform,
    super.osVersion,
  });

  factory ActionLogModel.fromJson(Map<String, dynamic> json) {
    final params = json['params'] as Map<String, dynamic>?;
    return ActionLogModel(
      route: json['route'] as String,
      occurredAt: DateTime.parse(json['occurredAt'] as String),
      previousRoute: json['previousRoute'] as String?,
      params: params?.map((key, value) => MapEntry(key, value as String)),
      platform: json['platform'] as String?,
      osVersion: json['osVersion'] as String?,
    );
  }

  factory ActionLogModel.fromEntity(ActionLog log) {
    return ActionLogModel(
      route: log.route,
      occurredAt: log.occurredAt,
      previousRoute: log.previousRoute,
      params: log.params,
      platform: log.platform,
      osVersion: log.osVersion,
    );
  }

  Map<String, dynamic> toJson() => {
    'route': route,
    'occurredAt': occurredAt.toIso8601String(),
    'previousRoute': ?previousRoute,
    'params': ?params,
    'platform': ?platform,
    'osVersion': ?osVersion,
  };
}
