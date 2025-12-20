import 'package:hive_ce/hive.dart';
import 'package:koaa/app/data/models/local_transaction.dart';
import 'package:uuid/uuid.dart';

part 'recurring_transaction.g.dart';

@HiveType(typeId: 3)
enum Frequency {
  @HiveField(0)
  daily,

  @HiveField(1)
  weekly,

  @HiveField(2)
  monthly,

  @HiveField(3)
  biWeekly,

  @HiveField(4)
  yearly,
}

@HiveType(typeId: 4)
class RecurringTransaction extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  double amount;

  @HiveField(2)
  String description;

  @HiveField(3)
  Frequency frequency;

  @HiveField(4)
  List<int> daysOfWeek; // 1 for Monday, 7 for Sunday

  @HiveField(5)
  int dayOfMonth; // For monthly recurrence

  @HiveField(6)
  DateTime lastGeneratedDate;

  @HiveField(7)
  TransactionCategory category;

  @HiveField(8)
  TransactionType type;

  @HiveField(9)
  String? categoryId;

  /// Optional end date for time-limited recurring transactions (null = infinite)
  @HiveField(10)
  DateTime? endDate;

  /// Whether this recurring transaction is active (can be manually stopped)
  @HiveField(11)
  bool isActive;

  /// When this recurring transaction was created (for history tracking)
  @HiveField(12)
  DateTime createdAt;

  // For compatibility with logic expecting startDate
  DateTime get startDate => createdAt;

  RecurringTransaction({
    String? id,
    required this.amount,
    required this.description,
    required this.frequency,
    this.daysOfWeek = const [],
    this.dayOfMonth = 1,
    required this.lastGeneratedDate,
    required this.category,
    required this.type,
    this.categoryId,
    this.endDate,
    this.isActive = true,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  /// Check if this recurring transaction is currently valid for generating
  bool get isCurrentlyValid {
    if (!isActive) return false;
    if (endDate != null && DateTime.now().isAfter(endDate!)) return false;
    return true;
  }

  DateTime get nextDueDate {
    if (frequency == Frequency.daily) {
      return lastGeneratedDate.add(const Duration(days: 1));
    }

    if (frequency == Frequency.weekly) {
      DateTime next = lastGeneratedDate.add(const Duration(days: 1));
      while (!daysOfWeek.contains(next.weekday)) {
        next = next.add(const Duration(days: 1));
      }
      return next;
    }

    if (frequency == Frequency.biWeekly) {
      return lastGeneratedDate.add(const Duration(days: 14));
    }

    if (frequency == Frequency.monthly) {
      // Robust end-of-month clamping logic
      DateTime getClampedDate(int year, int month, int day) {
        final daysInMonth = DateTime(year, month + 1, 0).day;
        final clampedDay = (day > daysInMonth) ? daysInMonth : day;
        return DateTime(year, month, clampedDay);
      }

      // Check current month (in case last generated was early in the month)
      // This handles cases where we might have missed a generation?
      // Actually standard logic is usually just +1 month.
      // But let's stick to the safer next month logic relative to lastGeneratedDate.

      DateTime candidate = getClampedDate(
          lastGeneratedDate.year, lastGeneratedDate.month + 1, dayOfMonth);

      return candidate;
    }

    if (frequency == Frequency.yearly) {
      // Handle leap years (Feb 29 -> Feb 28 in non-leap future year)
      final nextYear = lastGeneratedDate.year + 1;
      final isLeap =
          (nextYear % 4 == 0 && nextYear % 100 != 0) || (nextYear % 400 == 0);

      if (lastGeneratedDate.month == 2 &&
          lastGeneratedDate.day == 29 &&
          !isLeap) {
        return DateTime(nextYear, 2, 28);
      }
      return DateTime(nextYear, lastGeneratedDate.month, lastGeneratedDate.day);
    }

    // Default fallback
    return lastGeneratedDate.add(const Duration(days: 1));
  }

  bool isDue(DateTime date) {
    if (frequency == Frequency.daily) return true;
    if (frequency == Frequency.weekly) return daysOfWeek.contains(date.weekday);
    if (frequency == Frequency.biWeekly) {
      // Check if difference in days is multiple of 14 from start
      // optimizing to use lastGeneratedDate as anchor
      final diff = date.difference(lastGeneratedDate).inDays;
      return diff > 0 && diff % 14 == 0;
    }
    if (frequency == Frequency.monthly) return date.day == dayOfMonth;
    if (frequency == Frequency.yearly) {
      return date.month == lastGeneratedDate.month &&
          date.day == lastGeneratedDate.day;
    }
    return false;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'description': description,
      'frequency': frequency.index,
      'daysOfWeek': daysOfWeek,
      'dayOfMonth': dayOfMonth,
      'lastGeneratedDate': lastGeneratedDate.toIso8601String(),
      'category': category.index,
      'type': type.index,
      'categoryId': categoryId,
      'endDate': endDate?.toIso8601String(),
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory RecurringTransaction.fromJson(Map<String, dynamic> json) {
    return RecurringTransaction(
      id: json['id'],
      amount: json['amount'],
      description: json['description'],
      frequency: Frequency.values[json['frequency']],
      daysOfWeek: List<int>.from(json['daysOfWeek']),
      dayOfMonth: json['dayOfMonth'],
      lastGeneratedDate: DateTime.parse(json['lastGeneratedDate']),
      category: TransactionCategory.values[json['category']],
      type: TransactionType.values[json['type']],
      categoryId: json['categoryId'],
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      isActive: json['isActive'],
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }
}
