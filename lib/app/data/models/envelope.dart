import 'package:hive_ce/hive.dart';
import 'package:uuid/uuid.dart';

part 'envelope.g.dart';

@HiveType(typeId: 70)
class Envelope extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  double targetAmount;

  @HiveField(3)
  double currentAmount;

  @HiveField(4)
  String? icon;

  @HiveField(5)
  String? color; // Hex string

  @HiveField(6)
  DateTime createdAt;

  @HiveField(7)
  DateTime? targetDate;

  Envelope({
    String? id,
    required this.name,
    this.targetAmount = 0.0,
    this.currentAmount = 0.0,
    this.icon,
    this.color,
    DateTime? createdAt,
    this.targetDate,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  Envelope copyWith({
    String? name,
    double? targetAmount,
    double? currentAmount,
    String? icon,
    String? color,
    DateTime? targetDate,
  }) {
    return Envelope(
      id: id,
      name: name ?? this.name,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      createdAt: createdAt,
      targetDate: targetDate ?? this.targetDate,
    );
  }
}
