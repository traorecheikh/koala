import 'package:hive_ce/hive.dart';

part 'job.g.dart';

@HiveType(typeId: 10)
enum PaymentFrequency {
  @HiveField(0)
  weekly,

  @HiveField(1)
  biweekly,

  @HiveField(2)
  monthly,
}

extension PaymentFrequencyExtension on PaymentFrequency {
  String get displayName {
    switch (this) {
      case PaymentFrequency.weekly:
        return 'Hebdomadaire';
      case PaymentFrequency.biweekly:
        return 'Bi-hebdomadaire';
      case PaymentFrequency.monthly:
        return 'Mensuel';
    }
  }

  int get paymentsPerMonth {
    switch (this) {
      case PaymentFrequency.weekly:
        return 4;
      case PaymentFrequency.biweekly:
        return 2;
      case PaymentFrequency.monthly:
        return 1;
    }
  }
}

@HiveType(typeId: 9)
class Job extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  double amount;

  @HiveField(3)
  PaymentFrequency frequency;

  @HiveField(4)
  DateTime paymentDate;

  @HiveField(5)
  bool isActive;

  @HiveField(6)
  DateTime createdAt;

  Job({
    required this.id,
    required this.name,
    required this.amount,
    required this.frequency,
    required this.paymentDate,
    this.isActive = true,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  double get monthlyIncome => amount * frequency.paymentsPerMonth;

  Job copyWith({
    String? id,
    String? name,
    double? amount,
    PaymentFrequency? frequency,
    DateTime? paymentDate,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return Job(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      frequency: frequency ?? this.frequency,
      paymentDate: paymentDate ?? this.paymentDate,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
