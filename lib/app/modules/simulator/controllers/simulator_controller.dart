import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:koaa/app/services/ml/koala_ml_engine.dart';
import 'package:koaa/app/services/ml/models/simulator_engine.dart';

class SimulatorController extends GetxController {
  final amountController = TextEditingController();
  final result = Rxn<SimulationReport>();
  final isLoading = false.obs;
  final selectedScenario = SimulationScenario().obs; // Default scenario
  final isAmountValid = false.obs;

  @override
  void onInit() {
    super.onInit();

    amountController.addListener(() {
      isAmountValid.value = amountController.text.isNotEmpty;
    });
  }

  @override
  void onClose() {
    amountController.dispose();
    super.onClose();
  }

  void setSelectedScenario(SimulationScenario scenario) {
    selectedScenario.value = scenario;
  }

  void simulate() async {
    final amount = double.tryParse(amountController.text);
    if (amount == null || amount <= 0) {
      Get.snackbar(
          'Erreur', 'Veuillez entrer un montant valide pour la simulation.');
      return;
    }

    isLoading.value = true;
    await Future.delayed(
        const Duration(milliseconds: 500)); // Small delay for UX

    try {
      final engine = Get.find<KoalaMLEngine>();

      // Create a scenario based on the purchase amount
      final scenario = selectedScenario.value.copyWith(
        purchaseAmount: amount,
        // Other scenario parameters can be added here from UI inputs
        // For example:
        // delayDuration: Duration(days: 30),
        // debtIdToAdjust: 'someDebtId',
        // extraDebtPayment: 100.0,
      );

      final simulationReport = engine.simulatorEngine.simulateWithContext(
        daysToSimulate: 90, // Simulate for 90 days as per plan
        scenario: scenario,
      );

      result.value = simulationReport;
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de lancer la simulation: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
