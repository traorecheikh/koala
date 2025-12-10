import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_ce/hive.dart';
import 'package:intl/intl.dart';
import 'package:koaa/app/data/models/local_transaction.dart';
import 'package:koaa/app/data/models/local_user.dart';
import 'package:koaa/app/data/models/recurring_transaction.dart';
import 'package:koaa/app/modules/home/widgets/user_setup_dialog.dart';
import 'package:koaa/app/services/ml_service.dart';

class HomeController extends GetxController {
  final balanceVisible = true.obs;
  final userName = ''.obs;
  final Rxn<LocalUser> user = Rxn<LocalUser>();
  final RxDouble balance = 0.0.obs;
  final RxList<LocalTransaction> transactions = <LocalTransaction>[].obs;
  final RxBool isCardFlipped = false.obs;
  final RxList<MLInsight> insights = <MLInsight>[].obs;
  final _mlService = MLService();

  @override
  void onInit() {
    super.onInit();
    checkUser();

    final transactionBox = Hive.box<LocalTransaction>('transactionBox');
    transactions.assignAll(transactionBox.values.toList());
    calculateBalance();
    _updateInsights();

    transactionBox.watch().listen((_) {
      transactions.assignAll(transactionBox.values.toList());
      calculateBalance();
      _updateInsights();
    });

    generateRecurringTransactions();
  }

  void _updateInsights() {
    insights.value = _mlService.generateInsights(transactions);
  }

  void checkUser() {
    final userBox = Hive.box<LocalUser>('userBox');
    if (userBox.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showUserSetupDialog(Get.context!);
      });
    } else {
      user.value = userBox.getAt(0);
      userName.value = user.value?.fullName ?? 'User';
    }

    user.listen((newUser) {
      if (newUser != null) {
        final userBox = Hive.box<LocalUser>('userBox');
        if (userBox.isEmpty) {
          userBox.add(newUser);
        } else {
          userBox.putAt(0, newUser);
        }
        userName.value = newUser.fullName;
      }
    });
  }

  void toggleBalanceVisibility() {
    balanceVisible.value = !balanceVisible.value;
  }

  void toggleCardFlip() {
    isCardFlipped.value = !isCardFlipped.value;
  }

  void calculateBalance() {
    double total = 0;
    for (var transaction in transactions) {
      if (transaction.type == TransactionType.income) {
        total += transaction.amount;
      } else {
        total -= transaction.amount;
      }
    }
    balance.value = total;
  }

  Future<void> addTransaction(LocalTransaction transaction) async {
    final transactionBox = Hive.box<LocalTransaction>('transactionBox');
    await transactionBox.add(transaction);
  }

  void generateRecurringTransactions() {
    final recurringBox = Hive.box<RecurringTransaction>(
      'recurringTransactionBox',
    );
    final today = DateTime.now();

    for (var recurring in recurringBox.values) {
      DateTime lastGenerated = recurring.lastGeneratedDate;
      while (lastGenerated.isBefore(today)) {
        lastGenerated = lastGenerated.add(const Duration(days: 1));
        bool shouldGenerate = false;
        switch (recurring.frequency) {
          case Frequency.daily:
            shouldGenerate = true;
            break;
          case Frequency.weekly:
            if (recurring.daysOfWeek.contains(lastGenerated.weekday)) {
              shouldGenerate = true;
            }
            break;
          case Frequency.monthly:
            if (lastGenerated.day == recurring.dayOfMonth) {
              shouldGenerate = true;
            }
            break;
        }

        if (shouldGenerate) {
          addTransaction(
            LocalTransaction(
              amount: recurring.amount,
              description: recurring.description,
              date: lastGenerated,
              type: TransactionType.expense, // Assuming recurring are expenses
              isRecurring: true,
              category: recurring.category, // Pass category from recurring
              categoryId: recurring.categoryId,
            ),
          );
        }
      }
      recurring.lastGeneratedDate = today;
      recurring.save();
    }
  }

  String get formattedBalance {
    final format = NumberFormat.currency(locale: 'fr_FR', symbol: 'FCFA');
    return format.format(balance.value);
  }

  /// Get the last transaction
  LocalTransaction? get lastTransaction {
    if (transactions.isEmpty) return null;
    return transactions.reduce((a, b) => a.date.isAfter(b.date) ? a : b);
  }

  /// Get top spending category
  MapEntry<TransactionCategory, double>? get topSpendingCategory {
    if (transactions.isEmpty) return null;

    final Map<TransactionCategory, double> categoryTotals = {};

    for (var tx in transactions) {
      if (tx.type == TransactionType.expense) {
        if (tx.category != null) {
           categoryTotals[tx.category!] =
            (categoryTotals[tx.category] ?? 0) + tx.amount;
        }
      }
    }

    if (categoryTotals.isEmpty) return null;

    return categoryTotals.entries.reduce((a, b) => a.value > b.value ? a : b);
  }

  /// Get recent activity for mini chart (last 7 days)
  List<double> get recentActivityData {
    final now = DateTime.now();
    final List<double> data = List.filled(7, 0.0);

    for (var tx in transactions) {
      final daysDiff = now.difference(tx.date).inDays;
      if (daysDiff >= 0 && daysDiff < 7) {
        final index = 6 - daysDiff;
        if (tx.type == TransactionType.expense) {
          data[index] += tx.amount;
        }
      }
    }

    return data;
  }

  /// Get color based on time of day
  Color getTimeOfDayColor() {
    final hour = DateTime.now().hour;

    if (hour >= 5 && hour < 12) {
      // Morning: Warm sunrise colors
      return const Color(0xFF2D3250);
    } else if (hour >= 12 && hour < 17) {
      // Afternoon: Bright colors
      return const Color(0xFF1E3A5F);
    } else if (hour >= 17 && hour < 21) {
      // Evening: Sunset colors
      return const Color(0xFF2C1810);
    } else {
      // Night: Deep dark colors
      return const Color(0xFF0F0F1E);
    }
  }

  /// Get gradient based on time of day
  LinearGradient getTimeOfDayGradient() {
    final hour = DateTime.now().hour;

    if (hour >= 5 && hour < 12) {
      // Morning
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [const Color(0xFF2D3250), const Color(0xFF424769)],
      );
    } else if (hour >= 12 && hour < 17) {
      // Afternoon
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [const Color(0xFF1E3A5F), const Color(0xFF2E5984)],
      );
    } else if (hour >= 17 && hour < 21) {
      // Evening
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [const Color(0xFF2C1810), const Color(0xFF4A2C1A)],
      );
    } else {
      // Night
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [const Color(0xFF0F0F1E), const Color(0xFF1A1B2E)],
      );
    }
  }
}
