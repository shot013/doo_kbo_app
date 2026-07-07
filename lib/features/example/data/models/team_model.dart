import '../../domain/entities/team.dart';

final class TeamModel extends Team {
  const TeamModel({
    required super.id,
    required super.name,
    required super.city,
  });

  factory TeamModel.fromJson(Map<String, dynamic> json) {
    return TeamModel(
      id: json['id'] as String,
      name: json['name'] as String,
      city: json['city'] as String,
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'city': city};
}
