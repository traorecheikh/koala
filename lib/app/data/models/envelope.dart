import 'package:isar_plus/isar_plus.dart';
import 'package:hive_ce/hive.dart';
import 'package:uuid/uuid.dart';
import 'package:koaa/app/services/isar_service.dart';

part 'envelope.g.dart';

@Collection()
@HiveType(typeId: 70)
class Envelope {
  @Id()
  @HiveField(0)
  String id;

  @Index()
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
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
    this.icon,
    this.color,
    required this.createdAt,
    this.targetDate,
  });

  /// Factory constructor for creating with auto-generated ID and timestamp
  factory Envelope.create({
    required String name,
    double targetAmount = 0.0,
    double currentAmount = 0.0,
    String? icon,
    String? color,
    DateTime? targetDate,
  }) {
    return Envelope(
      id: const Uuid().v4(),
      name: name,
      targetAmount: targetAmount,
      currentAmount: currentAmount,
      icon: icon,
      color: color,
      createdAt: DateTime.now(),
      targetDate: targetDate,
    );
  }

  /// Save this envelope to Isar
  Future<void> save() async {
    await IsarService.updateEnvelope(this);
  }

  /// Delete this envelope from Isar
  Future<void> delete() async {
    await IsarService.deleteEnvelope(id);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'icon': icon,
      'color': color,
      'createdAt': createdAt.toIso8601String(),
      'targetDate': targetDate?.toIso8601String(),
    };
  }

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
