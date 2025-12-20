import 'package:isar_plus/isar_plus.dart';
import 'package:hive_ce/hive.dart';
import 'package:koaa/app/data/models/local_transaction.dart';
import 'package:koaa/app/services/isar_service.dart';

part 'category.g.dart';

@Collection()
@HiveType(typeId: 5)
class Category {
  // UUID as primary ID (follows LocalTransaction pattern)
  @Id()
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

  /// Save this category to Isar
  Future<void> save() async {
    IsarService.updateCategory(this);
  }

  /// Delete this category from Isar
  Future<void> delete() async {
    IsarService.deleteCategory(id);
  }
}
