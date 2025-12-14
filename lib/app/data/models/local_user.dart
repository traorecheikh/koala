
import 'package:hive_ce/hive.dart';

part 'local_user.g.dart';

@HiveType(typeId: 0)
class LocalUser extends HiveObject {
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

  LocalUser({
    required this.fullName,
    required this.salary,
    required this.payday,
    required this.age,
    required this.budgetingType,
  });
}

