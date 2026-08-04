import 'package:objectbox/objectbox.dart';

@Entity()
class Profile {
  @Id()
  int id = 0;

  String name;
  String avatarKey;
  int colorValue;
  int goalDailySessions;
  int goalWeeklySessions;
  String favoriteTablesSerialized;
  bool isArchived;
  @Property(type: PropertyType.date)
  DateTime? archivedAt;
  @Property(type: PropertyType.date)
  DateTime createdAt;
  @Property(type: PropertyType.date)
  DateTime updatedAt;

  Profile({
    this.id = 0,
    required this.name,
    required this.avatarKey,
    required this.colorValue,
    this.goalDailySessions = 1,
    this.goalWeeklySessions = 5,
    this.favoriteTablesSerialized = '',
    this.isArchived = false,
    this.archivedAt,
    @Property(type: PropertyType.date) DateTime? createdAt,
    @Property(type: PropertyType.date) DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  List<int> get favoriteTables {
    if (favoriteTablesSerialized.trim().isEmpty) {
      return <int>[];
    }

    return favoriteTablesSerialized
        .split(',')
        .map((value) => int.tryParse(value.trim()))
        .whereType<int>()
        .toList(growable: false);
  }

  set favoriteTables(List<int> values) {
    favoriteTablesSerialized = values.join(',');
    updatedAt = DateTime.now();
  }

  void archive([DateTime? at]) {
    isArchived = true;
    archivedAt = at ?? DateTime.now();
    updatedAt = archivedAt!;
  }

  void restore() {
    isArchived = false;
    archivedAt = null;
    updatedAt = DateTime.now();
  }
}
