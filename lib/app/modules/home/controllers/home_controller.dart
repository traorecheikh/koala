import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_ce/hive.dart';
import 'package:intl/intl.dart';
import 'package:koaa/app/data/models/local_transaction.dart';
import 'package:koaa/app/data/models/local_user.dart';
import 'package:koaa/app/data/models/recurring_transaction.dart';
import 'package:koaa/app/modules/home/widgets/user_setup_dialog.dart';

class HomeController extends GetxController {
  final balanceVisible = true.obs;
  final userName = ''.obs;
  final Rxn<LocalUser> user = Rxn<LocalUser>();
  final RxDouble balance = 0.0.obs;
  final RxList<LocalTransaction> transactions = <LocalTransaction>[].obs;

  @override
  void onInit() {
    super.onInit();
    checkUser();

    final transactionBox = Hive.box<LocalTransaction>('transactionBox');
    transactions.assignAll(transactionBox.values.toList());
    calculateBalance();

    transactionBox.watch().listen((_) {
      transactions.assignAll(transactionBox.values.toList());
      calculateBalance();
    });

    generateRecurringTransactions();
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
    final recurringBox = Hive.box<RecurringTransaction>('recurringTransactionBox');
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
              category: TransactionCategory.otherExpense, // Default category for recurring
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
}
