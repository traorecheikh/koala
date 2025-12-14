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
  }) : id = id ?? const Uuid().v4();

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
    
    if (frequency == Frequency.monthly) {
      // Helper to get clamped date
      DateTime getClampedDate(int year, int month, int day) {
        final daysInMonth = DateTime(year, month + 1, 0).day;
        final clampedDay = (day > daysInMonth) ? daysInMonth : day;
        return DateTime(year, month, clampedDay);
      }

      // Check current month (in case last generated was early in the month)
      DateTime candidate = getClampedDate(lastGeneratedDate.year, lastGeneratedDate.month, dayOfMonth);
      if (candidate.isAfter(lastGeneratedDate)) return candidate;

      // Check next month
      return getClampedDate(lastGeneratedDate.year, lastGeneratedDate.month + 1, dayOfMonth);
    }
    
    return lastGeneratedDate.add(const Duration(days: 1));
  }

  bool isDue(DateTime date) {
    if (frequency == Frequency.daily) return true;
    if (frequency == Frequency.weekly) return daysOfWeek.contains(date.weekday);
    if (frequency == Frequency.monthly) return date.day == dayOfMonth;
    return false;
  }
}

