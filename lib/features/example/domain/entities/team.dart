import 'package:equatable/equatable.dart';

class Team extends Equatable {
  const Team({required this.id, required this.name, required this.city});

  final String id;
  final String name;
  final String city;

  @override
  List<Object?> get props => [id, name, city];
}
