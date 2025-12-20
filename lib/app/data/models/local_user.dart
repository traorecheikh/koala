import 'package:isar_plus/isar_plus.dart';
import 'package:hive_ce/hive.dart';
import 'package:koaa/app/services/isar_service.dart';

part 'local_user.g.dart';

@Collection()
@HiveType(typeId: 0)
class LocalUser {
  @Id()
  @HiveField(7)
  String id;

  @HiveField(0)
  String fullName;

  @HiveField(1)
  double salary;

  @HiveField(2)
  int payday; // Day of the month

  @HiveField(3)
  int age;

  @HiveField(4)
  String budgetingType;

  /// Date when the user first launched the app (for catch-up flow)
  @HiveField(5)
  DateTime? firstLaunchDate;

  /// Whether the user has completed the initial spending catch-up flow
  @HiveField(6)
  bool hasCompletedCatchUp;

  LocalUser({
    this.id = '',
    required this.fullName,
    required this.salary,
    required this.payday,
    required this.age,
    required this.budgetingType,
    this.firstLaunchDate,
    this.hasCompletedCatchUp = false,
  });

  /// Save this user to Isar
  Future<void> save() async {
    await IsarService.saveUser(this);
  }

  /// Delete this user from Isar
  Future<void> delete() async {
    await IsarService.deleteUser();
  }

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'salary': salary,
      'payday': payday,
      'age': age,
      'budgetingType': budgetingType,
      'firstLaunchDate': firstLaunchDate?.toIso8601String(),
      'hasCompletedCatchUp': hasCompletedCatchUp,
      'id': id,
    };
  }

  factory LocalUser.fromJson(Map<String, dynamic> json) {
    return LocalUser(
      fullName: json['fullName'],
      salary: json['salary'],
      payday: json['payday'],
      age: json['age'],
      budgetingType: json['budgetingType'],
      firstLaunchDate: json['firstLaunchDate'] != null
          ? DateTime.parse(json['firstLaunchDate'])
          : null,
      hasCompletedCatchUp: json['hasCompletedCatchUp'] ?? false,
      id: json['id'],
    );
  }
}
