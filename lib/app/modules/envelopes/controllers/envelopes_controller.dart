import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:koaa/app/data/models/envelope.dart';
import 'package:koaa/app/services/envelope_service.dart';
import 'package:koaa/app/services/financial_context_service.dart';

class EnvelopesController extends GetxController {
  final EnvelopeService _envelopeService = Get.find<EnvelopeService>();
  final FinancialContextService _financialContext =
      Get.find<FinancialContextService>();

  final textController = TextEditingController();
  final amountController = TextEditingController();

  RxList<Envelope> get envelopes => _envelopeService.envelopes;
  double get totalAllocated => _envelopeService.totalAllocated.value;
  double get freeBalance => _financialContext.freeBalance;

  Future<void> createEnvelope(String name, double target) async {
    await _envelopeService.createEnvelope(name: name, targetAmount: target);
  }

  Future<void> deleteEnvelope(String id) async {
    await _envelopeService.deleteEnvelope(id);
  }

  Future<void> allocateToEnvelope(String id, double amount) async {
    if (amount > freeBalance) {
      Get.snackbar('Erreur', 'Solde disponible insuffisant',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    await _envelopeService.allocateFunds(id, amount);
  }

  @override
  void onClose() {
    textController.dispose();
    amountController.dispose();
    super.onClose();
  }
}
