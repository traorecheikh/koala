import 'package:hive_ce/hive.dart';
import 'package:uuid/uuid.dart';

part 'local_transaction.g.dart';

@HiveType(typeId: 1)
enum TransactionType {
  @HiveField(0)
  income,

  @HiveField(1)
  expense,
}

@HiveType(typeId: 7)
enum TransactionCategory {
  // Income categories
  @HiveField(0)
  salary,
  @HiveField(1)
  freelance,
  @HiveField(2)
  investment,
  @HiveField(3)
  business,
  @HiveField(4)
  gift,
  @HiveField(5)
  bonus,
  @HiveField(6)
  refund,
  @HiveField(7)
  rental,
  @HiveField(8)
  otherIncome,

  // Expense categories
  @HiveField(9)
  food,
  @HiveField(10)
  transport,
  @HiveField(11)
  shopping,
  @HiveField(12)
  entertainment,
  @HiveField(13)
  bills,
  @HiveField(14)
  health,
  @HiveField(15)
  education,
  @HiveField(16)
  rent,
  @HiveField(17)
  groceries,
  @HiveField(18)
  utilities,
  @HiveField(19)
  insurance,
  @HiveField(20)
  travel,
  @HiveField(21)
  clothing,
  @HiveField(22)
  fitness,
  @HiveField(23)
  beauty,
  @HiveField(24)
  gifts,
  @HiveField(25)
  charity,
  @HiveField(26)
  subscriptions,
  @HiveField(27)
  maintenance,
  @HiveField(28)
  otherExpense,
}

extension TransactionCategoryExtension on TransactionCategory {
  String get displayName {
    switch (this) {
      // Income
      case TransactionCategory.salary:
        return 'Salaire';
      case TransactionCategory.freelance:
        return 'Freelance';
      case TransactionCategory.investment:
        return 'Investissement';
      case TransactionCategory.business:
        return 'Business';
      case TransactionCategory.gift:
        return 'Cadeau Reçu';
      case TransactionCategory.bonus:
        return 'Bonus';
      case TransactionCategory.refund:
        return 'Remboursement';
      case TransactionCategory.rental:
        return 'Loyer Reçu';
      case TransactionCategory.otherIncome:
        return 'Autre Revenu';

      // Expenses
      case TransactionCategory.food:
        return 'Restaurant';
      case TransactionCategory.transport:
        return 'Transport';
      case TransactionCategory.shopping:
        return 'Shopping';
      case TransactionCategory.entertainment:
        return 'Divertissement';
      case TransactionCategory.bills:
        return 'Factures';
      case TransactionCategory.health:
        return 'Santé';
      case TransactionCategory.education:
        return 'Éducation';
      case TransactionCategory.rent:
        return 'Loyer';
      case TransactionCategory.groceries:
        return 'Courses';
      case TransactionCategory.utilities:
        return 'Services';
      case TransactionCategory.insurance:
        return 'Assurance';
      case TransactionCategory.travel:
        return 'Voyage';
      case TransactionCategory.clothing:
        return 'Vêtements';
      case TransactionCategory.fitness:
        return 'Fitness';
      case TransactionCategory.beauty:
        return 'Beauté';
      case TransactionCategory.gifts:
        return 'Cadeaux';
      case TransactionCategory.charity:
        return 'Charité';
      case TransactionCategory.subscriptions:
        return 'Abonnements';
      case TransactionCategory.maintenance:
        return 'Entretien';
      case TransactionCategory.otherExpense:
        return 'Autre Dépense';
    }
  }

  String get iconKey {
    switch (this) {
      // Income
      case TransactionCategory.salary:
        return 'salary';
      case TransactionCategory.freelance:
        return 'freelance';
      case TransactionCategory.investment:
        return 'investment';
      case TransactionCategory.business:
        return 'business';
      case TransactionCategory.gift:
        return 'gift';
      case TransactionCategory.bonus:
        return 'bonus';
      case TransactionCategory.refund:
        return 'refund';
      case TransactionCategory.rental:
        return 'rental';
      case TransactionCategory.otherIncome:
        return 'other';

      // Expenses
      case TransactionCategory.food:
        return 'restaurant';
      case TransactionCategory.transport:
        return 'transport';
      case TransactionCategory.shopping:
        return 'shopping';
      case TransactionCategory.entertainment:
        return 'entertainment';
      case TransactionCategory.bills:
        return 'bills';
      case TransactionCategory.health:
        return 'health';
      case TransactionCategory.education:
        return 'education';
      case TransactionCategory.rent:
        return 'rent';
      case TransactionCategory.groceries:
        return 'groceries';
      case TransactionCategory.utilities:
        return 'utilities';
      case TransactionCategory.insurance:
        return 'insurance';
      case TransactionCategory.travel:
        return 'travel';
      case TransactionCategory.clothing:
        return 'clothing';
      case TransactionCategory.fitness:
        return 'fitness';
      case TransactionCategory.beauty:
        return 'beauty';
      case TransactionCategory.gifts:
        return 'gift'; // Reused gift
      case TransactionCategory.charity:
        return 'charity';
      case TransactionCategory.subscriptions:
        return 'subscriptions';
      case TransactionCategory.maintenance:
        return 'maintenance';
      case TransactionCategory.otherExpense:
        return 'other';
    }
  }

  // Return the key directly for use with CategoryIcon
  String get icon => iconKey;

  // REMOVED: IconData get iconData => ...
  // We should stop using IconData directly for categories.

  bool get isIncome {
    return index <= TransactionCategory.otherIncome.index &&
        index >= TransactionCategory.salary.index;
  }

  static List<TransactionCategory> getByType(TransactionType type) {
    if (type == TransactionType.income) {
      return [
        TransactionCategory.salary,
        TransactionCategory.freelance,
        TransactionCategory.investment,
        TransactionCategory.business,
        TransactionCategory.gift,
        TransactionCategory.bonus,
        TransactionCategory.refund,
        TransactionCategory.rental,
        TransactionCategory.otherIncome,
      ];
    } else {
      return [
        TransactionCategory.food,
        TransactionCategory.transport,
        TransactionCategory.shopping,
        TransactionCategory.entertainment,
        TransactionCategory.bills,
        TransactionCategory.health,
        TransactionCategory.education,
        TransactionCategory.rent,
        TransactionCategory.groceries,
        TransactionCategory.utilities,
        TransactionCategory.insurance,
        TransactionCategory.travel,
        TransactionCategory.clothing,
        TransactionCategory.fitness,
        TransactionCategory.beauty,
        TransactionCategory.gifts,
        TransactionCategory.charity,
        TransactionCategory.subscriptions,
        TransactionCategory.maintenance,
        TransactionCategory.otherExpense,
      ];
    }
  }
}

@HiveType(typeId: 2)
class LocalTransaction extends HiveObject {
  @HiveField(0)
  double amount;

  @HiveField(1)
  String description;

  @HiveField(2)
  DateTime date;

  @HiveField(3)
  TransactionType type;

  @HiveField(4)
  bool isRecurring;

  @HiveField(5)
  TransactionCategory? category;

  @HiveField(6)
  String? categoryId;

  @HiveField(7)
  bool isHidden;

  @HiveField(8)
  final String id; // New field, new index

  @HiveField(9)
  String? linkedDebtId; // New field, new index

  @HiveField(10)
  String? linkedRecurringId; // Links back to original recurring transaction

  @HiveField(11)
  String? linkedJobId; // Links back to original job

  @HiveField(12)
  bool isCatchUp; // Flag for catch-up transactions to skip budget warnings

  LocalTransaction({
    String? id,
    required this.amount,
    required this.description,
    required this.date,
    required this.type,
    this.isRecurring = false,
    TransactionCategory? category,
    this.categoryId,
    this.isHidden = false,
    this.linkedDebtId,
    this.linkedRecurringId,
    this.linkedJobId,
    this.isCatchUp = false,
  })  : id = id ?? const Uuid().v4(),
        category = category ??
            (type == TransactionType.income
                ? TransactionCategory.otherIncome
                : TransactionCategory.otherExpense);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'description': description,
      'date': date.toIso8601String(),
      'type': type.toString().split('.').last,
      'isRecurring': isRecurring,
      'category': category?.toString().split('.').last,
      'categoryId': categoryId,
      'isHidden': isHidden,
      'linkedDebtId': linkedDebtId,
      'linkedRecurringId': linkedRecurringId,
      'linkedJobId': linkedJobId,
      'isCatchUp': isCatchUp,
    };
  }

  LocalTransaction copyWith({
    String? id,
    double? amount,
    String? description,
    DateTime? date,
    TransactionType? type,
    bool? isRecurring,
    TransactionCategory? category,
    String? categoryId,
    bool? isHidden,
    String? linkedDebtId,
    String? linkedRecurringId,
    String? linkedJobId,
    bool? isCatchUp,
  }) {
    return LocalTransaction(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      date: date ?? this.date,
      type: type ?? this.type,
      isRecurring: isRecurring ?? this.isRecurring,
      category: category ?? this.category,
      categoryId: categoryId ?? this.categoryId,
      isHidden: isHidden ?? this.isHidden,
      linkedDebtId: linkedDebtId ?? this.linkedDebtId,
      linkedRecurringId: linkedRecurringId ?? this.linkedRecurringId,
      linkedJobId: linkedJobId ?? this.linkedJobId,
      isCatchUp: isCatchUp ?? this.isCatchUp,
    );
  }
}
