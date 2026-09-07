import 'package:equatable/equatable.dart';

class ActionLog extends Equatable {
  const ActionLog({
    required this.route,
    required this.occurredAt,
    this.previousRoute,
    this.params,
    this.platform,
    this.osVersion,
  });

  final String route;
  final DateTime occurredAt;
  final String? previousRoute;
  final Map<String, String>? params;
  final String? platform;
  final String? osVersion;

  @override
  List<Object?> get props => [
    route,
    occurredAt,
    previousRoute,
    params,
    platform,
    osVersion,
  ];
}
