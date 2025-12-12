import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_ce/hive.dart';
import 'package:koaa/app/data/models/local_transaction.dart';
import 'package:koaa/app/data/models/recurring_transaction.dart';
import 'package:koaa/app/services/ml/koala_ml_engine.dart';
import 'package:koaa/app/services/ml/models/simulator_engine.dart';

class SimulatorController extends GetxController {
  final amountController = TextEditingController();
  final result = Rxn<SimulationResult>();
  final isLoading = false.obs;

  void simulate() async {
    final amount = double.tryParse(amountController.text);
    if (amount == null || amount <= 0) return;

    isLoading.value = true;
    
    // Simulate network/calc delay for effect
    await Future.delayed(const Duration(seconds: 1));

    try {
      final engine = Get.find<KoalaMLEngine>();
      final txBox = Hive.box<LocalTransaction>('transactionBox');
      final recurringBox = Hive.box<RecurringTransaction>('recurringTransactionBox');
      
      // Calculate current balance (simplified)
      double balance = 0;
      for (var t in txBox.values) {
        if (!t.isHidden) {
          if (t.type == TransactionType.income) balance += t.amount;
          else balance -= t.amount;
        }
      }

      final simulation = engine.simulatorEngine.simulatePurchase(
        currentBalance: balance,
        purchaseAmount: amount,
        recurringBills: recurringBox.values.toList(),
        recentHistory: txBox.values.toList(),
      );

      result.value = simulation;
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de lancer la simulation');
    } finally {
      isLoading.value = false;
    }
  }
}
