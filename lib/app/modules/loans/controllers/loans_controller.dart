import 'dart:math' as Math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Loans controller managing loan operations per OpenAPI spec
class LoansController extends GetxController {
  final loans = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;
  
  // Form controllers for creating/editing loans
  final principalController = TextEditingController();
  final interestRateController = TextEditingController();
  final termMonthsController = TextEditingController();
  final notesController = TextEditingController();
  
  final selectedStartDate = DateTime.now().obs;
  
  @override
  void onInit() {
    super.onInit();
    _loadLoans();
  }
  
  void _loadLoans() {
    // Sample loan data - in real app this would come from API/local storage
    loans.assignAll([
      {
        'id': '1',
        'principal': 500000.0,
        'interestRate': 15.0,
        'startDate': DateTime.now().subtract(const Duration(days: 180)),
        'termMonths': 12,
        'monthlyDue': 45833.33,
        'remainingBalance': 275000.0,
        'notes': 'Prêt pour formation en développement',
        'status': 'active',
        'nextPaymentDate': DateTime.now().add(const Duration(days: 15)),
      },
      {
        'id': '2',
        'principal': 200000.0,
        'interestRate': 10.0,
        'startDate': DateTime.now().subtract(const Duration(days: 60)),
        'termMonths': 6,
        'monthlyDue': 35000.0,
        'remainingBalance': 140000.0,
        'notes': 'Prêt familial pour équipement',
        'status': 'active',
        'nextPaymentDate': DateTime.now().add(const Duration(days: 5)),
      },
      {
        'id': '3',
        'principal': 100000.0,
        'interestRate': 8.0,
        'startDate': DateTime.now().subtract(const Duration(days: 365)),
        'termMonths': 12,
        'monthlyDue': 8695.65,
        'remainingBalance': 0.0,
        'notes': 'Prêt pour achat véhicule',
        'status': 'completed',
        'nextPaymentDate': null,
      },
    ]);
  }
  
  void showAddLoanDialog() {
    // Clear form
    principalController.clear();
    interestRateController.clear();
    termMonthsController.clear();
    notesController.clear();
    selectedStartDate.value = DateTime.now();
    
    Get.bottomSheet(
      _buildAddLoanSheet(),
      isScrollControlled: true,
      backgroundColor: Get.theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    );
  }
  
  Widget _buildAddLoanSheet() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nouveau Prêt',
            style: Get.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: principalController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Montant principal (XOF)',
              hintText: 'Ex: 500000',
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: interestRateController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Taux d\'intérêt (%)',
              hintText: 'Ex: 15',
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: termMonthsController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Durée (mois)',
              hintText: 'Ex: 12',
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: notesController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Notes (optionnel)',
              hintText: 'Description du prêt...',
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Get.back(),
                  child: const Text('Annuler'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: saveLoan,
                  child: const Text('Créer'),
                ),
              ),
            ],
          ),
          SizedBox(height: MediaQuery.of(Get.context!).viewInsets.bottom),
        ],
      ),
    );
  }
  
  void saveLoan() {
    if (principalController.text.isEmpty || 
        interestRateController.text.isEmpty || 
        termMonthsController.text.isEmpty) {
      Get.snackbar(
        'Erreur',
        'Veuillez remplir tous les champs obligatoires',
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
      return;
    }
    
    final principal = double.tryParse(principalController.text);
    final interestRate = double.tryParse(interestRateController.text);
    final termMonths = int.tryParse(termMonthsController.text);
    
    if (principal == null || principal <= 0 ||
        interestRate == null || interestRate < 0 ||
        termMonths == null || termMonths <= 0) {
      Get.snackbar(
        'Erreur',
        'Veuillez saisir des valeurs valides',
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
      return;
    }
    
    // Calculate monthly payment using loan formula
    final monthlyRate = interestRate / 100 / 12;
    final monthlyDue = principal * 
        (monthlyRate * Math.pow(1 + monthlyRate, termMonths)) /
        (Math.pow(1 + monthlyRate, termMonths) - 1);
    
    final newLoan = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'principal': principal,
      'interestRate': interestRate,
      'startDate': selectedStartDate.value,
      'termMonths': termMonths,
      'monthlyDue': monthlyDue,
      'remainingBalance': principal,
      'notes': notesController.text,
      'status': 'active',
      'nextPaymentDate': DateTime.now().add(const Duration(days: 30)),
    };
    
    loans.insert(0, newLoan);
    Get.back();
    
    Get.snackbar(
      'Succès',
      'Prêt créé avec succès',
      backgroundColor: Get.theme.colorScheme.primary,
      colorText: Get.theme.colorScheme.onPrimary,
    );
  }
  
  void makePayment(String loanId, double amount) {
    final loanIndex = loans.indexWhere((loan) => loan['id'] == loanId);
    if (loanIndex == -1) return;
    
    final loan = loans[loanIndex];
    final remainingBalance = loan['remainingBalance'] as double;
    
    if (amount > remainingBalance) {
      Get.snackbar(
        'Erreur',
        'Le montant ne peut pas dépasser le solde restant',
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
      return;
    }
    
    final newBalance = remainingBalance - amount;
    loan['remainingBalance'] = newBalance;
    
    if (newBalance <= 0) {
      loan['status'] = 'completed';
      loan['nextPaymentDate'] = null;
    } else {
      // Update next payment date
      final currentDate = loan['nextPaymentDate'] as DateTime?;
      loan['nextPaymentDate'] = (currentDate ?? DateTime.now())
          .add(const Duration(days: 30));
    }
    
    loans[loanIndex] = loan;
    
    // TODO: Create a payment transaction
    
    Get.snackbar(
      'Succès',
      'Paiement de ${amount.toStringAsFixed(0)} XOF enregistré',
      backgroundColor: Get.theme.colorScheme.primary,
      colorText: Get.theme.colorScheme.onPrimary,
    );
  }
  
  @override
  void onClose() {
    principalController.dispose();
    interestRateController.dispose();
    termMonthsController.dispose();
    notesController.dispose();
    super.onClose();
  }
}