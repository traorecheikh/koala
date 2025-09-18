import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:koala/app/data/models/account_model.dart';
import 'package:koala/app/data/models/transaction_model.dart';
import 'package:koala/app/data/services/local_data_service.dart';
import 'package:koala/app/shared/widgets/add_transaction_bottom_sheet.dart';

class TransactionController extends GetxController {
  final filteredTransactions = <TransactionModel>[].obs;
  final isLoading = false.obs;

  final searchController = TextEditingController();
  final selectedCategory = ''.obs;
  final selectedDateRange = 'all'.obs;

  // Filter panel state
  final isFilterPanelOpen = false.obs;
  final searchQuery = ''.obs;
  final selectedType = 'all'.obs;
  final selectedDateFilter = 'all'.obs;

  final categories = [
    'Alimentation',
    'Transport',
    'Logement',
    'Santé',
    'Divertissement',
    'Shopping',
    'Services',
    'Éducation',
    'Autres',
  ].obs;

  // Use reactive data from LocalDataService
  List<TransactionModel> get transactions => LocalDataService.to.transactions;
  List<AccountModel> get accounts => LocalDataService.to.accounts;

  @override
  void onInit() {
    super.onInit();
    loadTransactions();

    // Listen to search changes
    searchController.addListener(_filterTransactions);
    ever(selectedCategory, (_) => _filterTransactions());
    ever(selectedDateRange, (_) => _filterTransactions());
    
    // Listen to changes in local data
    ever(LocalDataService.to.transactions, (_) => _filterTransactions());
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  /// Load transactions from storage
  Future<void> loadTransactions() async {
    try {
      isLoading.value = true;
      // Data is automatically loaded from LocalDataService
      _filterTransactions();
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de charger les transactions');
    } finally {
      isLoading.value = false;
    }
  }

  /// Refresh transactions
  Future<void> refreshTransactions() async {
    await loadTransactions();
  }

  /// Toggle filter panel visibility
  void toggleFilterPanel() {
    isFilterPanelOpen.value = !isFilterPanelOpen.value;
  }

  /// Handle search input changes
  void onSearchChanged(String query) {
    searchQuery.value = query;
    _filterTransactions();
  }

  /// Clear search query
  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
    _filterTransactions();
  }

  /// Add a new transaction
  Future<void> addTransaction(TransactionModel transaction) async {
    try {
      isLoading.value = true;

      // Save using LocalDataService
      await LocalDataService.to.addTransaction(transaction);

      // Refresh the filtered list
      _filterTransactions();

      Get.snackbar(
        'Succès', 
        'Transaction ajoutée avec succès',
        backgroundColor: const Color(0xFF4CAF50),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible d\'ajouter la transaction: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Delete a transaction
  Future<void> deleteTransaction(String transactionId) async {
    try {
      await LocalDataService.to.deleteTransaction(transactionId);
      _filterTransactions();
      
      Get.snackbar(
        'Succès', 
        'Transaction supprimée',
        backgroundColor: const Color(0xFF4CAF50),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de supprimer la transaction: $e');
    }
  }

      // TODO: Also sync with API if needed
      await Future.delayed(
        const Duration(milliseconds: 500),
      ); // Simulate API call
    } catch (e) {
      throw Exception('Failed to add transaction: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Navigate to add transaction (now opens bottom sheet)
  void navigateToAddTransaction() {
    AddTransactionBottomSheet.show();
  }

  /// Edit a transaction
  void editTransaction(TransactionModel transaction) {
    // TODO: Implement edit functionality - could open bottom sheet with pre-filled data
    Get.snackbar('Info', 'Fonctionnalité d\'édition à venir');
  }

  /// Delete a transaction with confirmation
  void deleteTransaction(String transactionId) {
    Get.dialog(
      AlertDialog(
        title: const Text('Supprimer la transaction'),
        content: const Text(
          'Êtes-vous sûr de vouloir supprimer cette transaction ?',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Annuler')),
          TextButton(
            onPressed: () {
              Get.back();
              _performDelete(transactionId);
            },
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  /// View transaction details
  void viewTransactionDetails(String transactionId) {
    Get.toNamed('/transactions/$transactionId');
  }

  /// Check if any filters are active
  bool get hasActiveFilters {
    return selectedType.value != 'all' ||
        selectedDateFilter.value != 'all' ||
        searchQuery.value.isNotEmpty;
  }

  /// Set type filter
  void setTypeFilter(String type) {
    selectedType.value = type;
    _filterTransactions();
  }

  /// Set date filter
  void setDateFilter(String dateFilter) {
    selectedDateFilter.value = dateFilter;
    _filterTransactions();
  }

  /// Clear all active filters
  void clearAllFilters() {
    selectedType.value = 'all';
    selectedDateFilter.value = 'all';
    searchController.clear();
    searchQuery.value = '';
    _filterTransactions();
  }

  /// Perform actual delete operation
  Future<void> _performDelete(String transactionId) async {
    try {
      // TODO: Delete from storage
      transactions.removeWhere((t) => t.id == transactionId);
      _filterTransactions();
      Get.snackbar('Succès', 'Transaction supprimée');
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de supprimer la transaction');
    }
  }

  /// Filter transactions based on current criteria
  void _filterTransactions() {
    var filtered = transactions.toList();

    // Apply search filter
    if (searchQuery.value.isNotEmpty) {
      filtered = filtered.where((t) {
        return t.description.toLowerCase().contains(
              searchQuery.value.toLowerCase(),
            ) ||
            t.merchant?.toLowerCase().contains(
                  searchQuery.value.toLowerCase(),
                ) ==
                true;
      }).toList();
    }

    // Apply type filter
    if (selectedType.value != 'all') {
      filtered = filtered.where((t) {
        switch (selectedType.value) {
          case 'income':
            return t.type == TransactionType.income;
          case 'expense':
            return t.type == TransactionType.expense;
          case 'loan':
            return t.type == TransactionType.loan;
          default:
            return true;
        }
      }).toList();
    }

    // Apply date filter
    if (selectedDateFilter.value != 'all') {
      final now = DateTime.now();
      filtered = filtered.where((t) {
        switch (selectedDateFilter.value) {
          case 'week':
            return t.date.isAfter(now.subtract(const Duration(days: 7)));
          case 'month':
            return t.date.isAfter(DateTime(now.year, now.month, 1));
          default:
            return true;
        }
      }).toList();
    }

    // Sort by date (newest first)
    filtered.sort((a, b) => b.date.compareTo(a.date));

    filteredTransactions.value = filtered;
  }
}
