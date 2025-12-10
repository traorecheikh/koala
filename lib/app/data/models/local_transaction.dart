import 'package:hive_ce/hive.dart';

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

  String get icon {
    switch (this) {
      // Income
      case TransactionCategory.salary:
        return '💼';
      case TransactionCategory.freelance:
        return '💻';
      case TransactionCategory.investment:
        return '📈';
      case TransactionCategory.business:
        return '🏢';
      case TransactionCategory.gift:
        return '🎁';
      case TransactionCategory.bonus:
        return '🎉';
      case TransactionCategory.refund:
        return '↩️';
      case TransactionCategory.rental:
        return '🏠';
      case TransactionCategory.otherIncome:
        return '💰';

      // Expenses
      case TransactionCategory.food:
        return '🍽️';
      case TransactionCategory.transport:
        return '🚗';
      case TransactionCategory.shopping:
        return '🛍️';
      case TransactionCategory.entertainment:
        return '🎬';
      case TransactionCategory.bills:
        return '📄';
      case TransactionCategory.health:
        return '⚕️';
      case TransactionCategory.education:
        return '📚';
      case TransactionCategory.rent:
        return '🏡';
      case TransactionCategory.groceries:
        return '🛒';
      case TransactionCategory.utilities:
        return '💡';
      case TransactionCategory.insurance:
        return '🛡️';
      case TransactionCategory.travel:
        return '✈️';
      case TransactionCategory.clothing:
        return '👕';
      case TransactionCategory.fitness:
        return '💪';
      case TransactionCategory.beauty:
        return '💄';
      case TransactionCategory.gifts:
        return '🎁';
      case TransactionCategory.charity:
        return '❤️';
      case TransactionCategory.subscriptions:
        return '📱';
      case TransactionCategory.maintenance:
        return '🔧';
      case TransactionCategory.otherExpense:
        return '📦';
    }
  }

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

  LocalTransaction({
    required this.amount,
    required this.description,
    required this.date,
    required this.type,
    this.isRecurring = false,
    TransactionCategory? category,
    this.categoryId,
  }) : category = category ??
           (type == TransactionType.income
               ? TransactionCategory.otherIncome
               : TransactionCategory.otherExpense);
}
