import 'package:hive_ce/hive.dart';
import 'package:koaa/app/data/models/local_transaction.dart';

part 'category.g.dart';

@HiveType(typeId: 5)
class Category extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String icon;

  @HiveField(3)
  int colorValue; // Store color as int

  @HiveField(4)
  TransactionType type;

  @HiveField(5)
  bool isDefault;

  Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.colorValue,
    required this.type,
    this.isDefault = false,
  });
}
