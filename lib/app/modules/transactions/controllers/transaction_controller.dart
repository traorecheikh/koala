import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:koala/app/data/models/account_model.dart';
import 'package:koala/app/data/models/transaction_model.dart';

class TransactionController extends GetxController {
  final transactions = <TransactionModel>[].obs;
  final filteredTransactions = <TransactionModel>[].obs;
  final accounts = <AccountModel>[].obs;
  final isLoading = false.obs;

  final searchController = TextEditingController();
  final selectedCategory = ''.obs;
  final selectedDateRange =
      'all'.obs; // Changed from Rxn<DateTimeRange> to RxString

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

  @override
  void onInit() {
    super.onInit();
    loadTransactions();
    loadAccounts();

    // Listen to search changes
    searchController.addListener(_filterTransactions);
    ever(selectedCategory, (_) => _filterTransactions());
    ever(selectedDateRange, (_) => _filterTransactions());
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
      // TODO: Load from Hive storage
      await Future.delayed(const Duration(milliseconds: 500));

      // Mock transactions for now
      transactions.clear();
      _filterTransactions();
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de charger les transactions');
    } finally {
      isLoading.value = false;
    }
  }

  /// Load accounts from storage
  Future<void> loadAccounts() async {
    try {
      // TODO: Load from Hive storage
      await Future.delayed(const Duration(milliseconds: 300));
      accounts.clear();
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de charger les comptes');
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

  /// Set date filter
  void setDateFilter(String filter) {
    selectedDateFilter.value = filter;
    _filterTransactions();
  }

  /// Set type filter
  void setTypeFilter(String type) {
    selectedType.value = type;
    _filterTransactions();
  }

  /// Clear all filters
  void clearAllFilters() {
    searchController.clear();
    searchQuery.value = '';
    selectedType.value = 'all';
    selectedDateFilter.value = 'all';
    _filterTransactions();
  }

  /// Check if any filters are active
  bool get hasActiveFilters {
    return searchQuery.value.isNotEmpty ||
        selectedType.value != 'all' ||
        selectedDateFilter.value != 'all';
  }

  /// Navigate to add transaction
  void navigateToAddTransaction() {
    Get.toNamed('/transactions/add');
  }

  /// Edit transaction
  void editTransaction(dynamic transaction) {
    Get.toNamed('/transactions/edit', arguments: transaction);
  }

  /// Delete transaction
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
