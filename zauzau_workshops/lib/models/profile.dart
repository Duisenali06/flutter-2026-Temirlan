import 'package:flutter/foundation.dart';

@immutable
class Profile {
  const Profile({required this.name, required this.group});

  const Profile.empty()
      : name = '',
        group = '';

  final String name;
  final String group;

  Profile copyWith({String? name, String? group}) =>
      Profile(name: name ?? this.name, group: group ?? this.group);

  @override
  bool operator ==(Object other) =>
      other is Profile && other.name == name && other.group == group;

  @override
  int get hashCode => Object.hash(name, group);
}
