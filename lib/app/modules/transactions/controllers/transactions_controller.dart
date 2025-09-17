import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:koala/app/modules/transactions/widgets/add_transaction_sheet.dart';

class TransactionsController extends GetxController {
  final monthlyExpenses = 125000.0.obs;
  final monthlyIncome = 180000.0.obs;
  final currentBalance = 245000.0.obs;
  final filteredTransactions = <Map<String, dynamic>>[].obs;
  final selectedFilter = 'All'.obs;

  // Form controllers
  final titleController = TextEditingController();
  final amountController = TextEditingController();
  final descriptionController = TextEditingController();
  final selectedCategory = 'Food & Dining'.obs;
  final selectedType = 'expense'.obs;
  final selectedAccount = 'Cash'.obs;

  final categories = [
    'Food & Dining',
    'Transportation',
    'Shopping',
    'Entertainment',
    'Bills & Utilities',
    'Healthcare',
    'Education',
    'Travel',
    'Salary',
    'Freelance',
    'Investment',
    'Gift',
  ].obs;

  final accounts = ['Cash', 'Orange Money', 'Wave', 'Bank Account'].obs;

  @override
  void onInit() {
    super.onInit();
    _loadTransactions();
  }

  void _loadTransactions() {
    filteredTransactions.assignAll([
      {
        'id': '1',
        'title': 'Salary Deposit',
        'category': 'Salary',
        'amount': 150000.0,
        'time': '2 hours ago',
        'type': 'income',
        'icon': Icons.work_outline,
        'account': 'Bank Account',
        'description': 'Monthly salary payment',
      },
      {
        'id': '2',
        'title': 'Grocery Shopping',
        'category': 'Food & Dining',
        'amount': -12500.0,
        'time': '5 hours ago',
        'type': 'expense',
        'icon': Icons.shopping_cart_outlined,
        'account': 'Cash',
        'description': 'Weekly groceries at Auchan',
      },
      {
        'id': '3',
        'title': 'BRT Transport',
        'category': 'Transportation',
        'amount': -500.0,
        'time': '1 day ago',
        'type': 'expense',
        'icon': Icons.directions_bus_outlined,
        'account': 'Orange Money',
        'description': 'Daily commute',
      },
      {
        'id': '4',
        'title': 'Freelance Project',
        'category': 'Freelance',
        'amount': 75000.0,
        'time': '2 days ago',
        'type': 'income',
        'icon': Icons.laptop_mac,
        'account': 'Wave',
        'description': 'Website development project',
      },
    ]);
  }

  void applyFilter(String filter) {
    selectedFilter.value = filter;
    // Apply filtering logic based on type
    if (filter == 'All') {
      _loadTransactions();
    } else if (filter == 'Income') {
      filteredTransactions.assignAll(
        filteredTransactions.where((tx) => tx['type'] == 'income').toList(),
      );
    } else if (filter == 'Expense') {
      filteredTransactions.assignAll(
        filteredTransactions.where((tx) => tx['type'] == 'expense').toList(),
      );
    }
  }

  void showAddTransactionSheet() {
    Get.bottomSheet(
      const AddTransactionSheet(),
      isScrollControlled: true,
    );
  }

  void saveTransaction() {
    if (titleController.text.isEmpty || amountController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please fill all required fields',
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
      return;
    }

    final amount = double.tryParse(amountController.text);
    if (amount == null || amount <= 0) {
      Get.snackbar(
        'Error',
        'Please enter a valid amount',
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
      return;
    }

    // Create new transaction
    final newTransaction = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'title': titleController.text,
      'category': selectedCategory.value,
      'amount': selectedType.value == 'expense' ? -amount : amount,
      'time': 'Just now',
      'type': selectedType.value,
      'icon': _getCategoryIcon(selectedCategory.value),
      'account': selectedAccount.value,
      'description': descriptionController.text,
    };

    // Add to transactions list
    filteredTransactions.insert(0, newTransaction);

    // Update balances
    if (selectedType.value == 'expense') {
      monthlyExpenses.value += amount;
      currentBalance.value -= amount;
    } else {
      monthlyIncome.value += amount;
      currentBalance.value += amount;
    }

    // Clear form
    titleController.clear();
    amountController.clear();
    descriptionController.clear();
    selectedCategory.value = categories.first;
    selectedAccount.value = accounts.first;

    Get.back();
    Get.snackbar(
      'Success',
      'Transaction saved successfully',
      backgroundColor: Get.theme.colorScheme.primary,
      colorText: Get.theme.colorScheme.onPrimary,
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Food & Dining':
        return Icons.restaurant;
      case 'Transportation':
        return Icons.directions_car;
      case 'Shopping':
        return Icons.shopping_bag;
      case 'Entertainment':
        return Icons.movie;
      case 'Bills & Utilities':
        return Icons.receipt;
      case 'Healthcare':
        return Icons.local_hospital;
      case 'Education':
        return Icons.school;
      case 'Travel':
        return Icons.flight;
      case 'Salary':
        return Icons.work;
      case 'Freelance':
        return Icons.laptop_mac;
      case 'Investment':
        return Icons.trending_up;
      case 'Gift':
        return Icons.card_giftcard;
      default:
        return Icons.category;
    }
  }

  @override
  void onClose() {
    titleController.dispose();
    amountController.dispose();
    descriptionController.dispose();
    super.onClose();
  }
}
