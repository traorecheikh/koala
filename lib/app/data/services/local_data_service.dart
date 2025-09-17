import 'package:get/get.dart';
import 'package:koala/app/data/models/account_model.dart';
import 'package:koala/app/data/models/loan_model.dart';
import 'package:koala/app/data/models/recurring_model.dart';
import 'package:koala/app/data/models/transaction_model.dart';
import 'package:koala/app/data/models/user_model.dart';
import 'package:koala/app/data/services/hive_service.dart';

/// Local data service for offline-first operations
/// Handles CRUD operations with Hive storage and optimistic updates
class LocalDataService extends GetxService {
  static LocalDataService get to => Get.find();

  // Current user
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  
  // Observable lists for reactive UI updates
  final RxList<TransactionModel> transactions = <TransactionModel>[].obs;
  final RxList<AccountModel> accounts = <AccountModel>[].obs;
  final RxList<LoanModel> loans = <LoanModel>[].obs;
  final RxList<RecurringModel> recurrings = <RecurringModel>[].obs;

  @override
  Future<void> onInit() async {
    super.onInit();
    await _loadLocalData();
  }

  /// Load all data from local storage
  Future<void> _loadLocalData() async {
    try {
      // Load current user (should be only one)
      final users = HiveService.users.values.toList();
      if (users.isNotEmpty) {
        currentUser.value = users.first;
      }

      // Load all data collections
      transactions.assignAll(HiveService.transactions.values.toList());
      accounts.assignAll(HiveService.accounts.values.toList());
      loans.assignAll(HiveService.loans.values.toList());
      recurrings.assignAll(HiveService.recurrings.values.toList());

      // Sort transactions by date (newest first)
      transactions.sort((a, b) => b.date.compareTo(a.date));
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de charger les données locales: $e');
    }
  }

  // ==== USER OPERATIONS ====

  /// Create or update user profile
  Future<UserModel> saveUser(UserModel user) async {
    try {
      await HiveService.users.put(user.id, user);
      currentUser.value = user;
      return user;
    } catch (e) {
      throw Exception('Erreur lors de la sauvegarde utilisateur: $e');
    }
  }

  /// Get current user
  UserModel? getCurrentUser() => currentUser.value;

  /// Update user balance
  Future<void> updateUserBalance(double newBalance) async {
    final user = currentUser.value;
    if (user != null) {
      final updatedUser = user.copyWith(currentBalance: newBalance);
      await saveUser(updatedUser);
    }
  }

  // ==== TRANSACTION OPERATIONS ====

  /// Add new transaction with optimistic update
  Future<TransactionModel> addTransaction(TransactionModel transaction) async {
    try {
      // Save to local storage
      await HiveService.transactions.put(transaction.id, transaction);
      
      // Update local list
      transactions.insert(0, transaction);
      
      // Update user balance if transaction affects it
      if (transaction.affectsBalance) {
        await _updateBalanceForTransaction(transaction, isAdding: true);
      }

      return transaction;
    } catch (e) {
      throw Exception('Erreur lors de l\'ajout de la transaction: $e');
    }
  }

  /// Update existing transaction
  Future<TransactionModel> updateTransaction(TransactionModel transaction) async {
    try {
      // Get old transaction for balance calculation
      final oldTransaction = HiveService.transactions.get(transaction.id);
      
      // Save updated transaction
      await HiveService.transactions.put(transaction.id, transaction);
      
      // Update local list
      final index = transactions.indexWhere((t) => t.id == transaction.id);
      if (index != -1) {
        transactions[index] = transaction;
      }

      // Update balance if needed
      if (oldTransaction != null && oldTransaction.affectsBalance) {
        await _updateBalanceForTransaction(oldTransaction, isAdding: false);
      }
      if (transaction.affectsBalance) {
        await _updateBalanceForTransaction(transaction, isAdding: true);
      }

      return transaction;
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour de la transaction: $e');
    }
  }

  /// Delete transaction
  Future<void> deleteTransaction(String transactionId) async {
    try {
      final transaction = HiveService.transactions.get(transactionId);
      if (transaction != null) {
        // Remove from storage
        await HiveService.transactions.delete(transactionId);
        
        // Update local list
        transactions.removeWhere((t) => t.id == transactionId);
        
        // Update balance
        if (transaction.affectsBalance) {
          await _updateBalanceForTransaction(transaction, isAdding: false);
        }
      }
    } catch (e) {
      throw Exception('Erreur lors de la suppression de la transaction: $e');
    }
  }

  /// Get transactions by date range
  List<TransactionModel> getTransactionsByDateRange(DateTime start, DateTime end) {
    return transactions.where((t) => 
      t.date.isAfter(start.subtract(const Duration(days: 1))) &&
      t.date.isBefore(end.add(const Duration(days: 1)))
    ).toList();
  }

  /// Get transactions by category
  List<TransactionModel> getTransactionsByCategory(String category) {
    return transactions.where((t) => t.category == category).toList();
  }

  // ==== ACCOUNT OPERATIONS ====

  /// Add or update account
  Future<AccountModel> saveAccount(AccountModel account) async {
    try {
      await HiveService.accounts.put(account.id, account);
      
      final index = accounts.indexWhere((a) => a.id == account.id);
      if (index != -1) {
        accounts[index] = account;
      } else {
        accounts.add(account);
      }
      
      return account;
    } catch (e) {
      throw Exception('Erreur lors de la sauvegarde du compte: $e');
    }
  }

  /// Delete account
  Future<void> deleteAccount(String accountId) async {
    try {
      await HiveService.accounts.delete(accountId);
      accounts.removeWhere((a) => a.id == accountId);
    } catch (e) {
      throw Exception('Erreur lors de la suppression du compte: $e');
    }
  }

  // ==== LOAN OPERATIONS ====

  /// Add or update loan
  Future<LoanModel> saveLoan(LoanModel loan) async {
    try {
      await HiveService.loans.put(loan.id, loan);
      
      final index = loans.indexWhere((l) => l.id == loan.id);
      if (index != -1) {
        loans[index] = loan;
      } else {
        loans.add(loan);
      }
      
      return loan;
    } catch (e) {
      throw Exception('Erreur lors de la sauvegarde du prêt: $e');
    }
  }

  /// Delete loan
  Future<void> deleteLoan(String loanId) async {
    try {
      await HiveService.loans.delete(loanId);
      loans.removeWhere((l) => l.id == loanId);
    } catch (e) {
      throw Exception('Erreur lors de la suppression du prêt: $e');
    }
  }

  // ==== RECURRING OPERATIONS ====

  /// Add or update recurring transaction
  Future<RecurringModel> saveRecurring(RecurringModel recurring) async {
    try {
      await HiveService.recurrings.put(recurring.id, recurring);
      
      final index = recurrings.indexWhere((r) => r.id == recurring.id);
      if (index != -1) {
        recurrings[index] = recurring;
      } else {
        recurrings.add(recurring);
      }
      
      return recurring;
    } catch (e) {
      throw Exception('Erreur lors de la sauvegarde de la récurrence: $e');
    }
  }

  /// Delete recurring transaction
  Future<void> deleteRecurring(String recurringId) async {
    try {
      await HiveService.recurrings.delete(recurringId);
      recurrings.removeWhere((r) => r.id == recurringId);
    } catch (e) {
      throw Exception('Erreur lors de la suppression de la récurrence: $e');
    }
  }

  // ==== BALANCE CALCULATIONS ====

  /// Update user balance based on transaction
  Future<void> _updateBalanceForTransaction(TransactionModel transaction, {required bool isAdding}) async {
    final user = currentUser.value;
    if (user == null) return;

    final balanceChange = isAdding ? transaction.signedAmount : -transaction.signedAmount;
    final newBalance = user.currentBalance + balanceChange;
    
    await updateUserBalance(newBalance);
  }

  /// Calculate total balance from all accounts
  double getTotalBalance() {
    return accounts.fold(0.0, (sum, account) => sum + account.balance);
  }

  /// Get balance by account type
  double getBalanceByAccountType(String accountType) {
    return accounts
        .where((account) => account.type == accountType)
        .fold(0.0, (sum, account) => sum + account.balance);
  }

  // ==== DATA MANAGEMENT ====

  /// Clear all local data (for logout)
  Future<void> clearAllData() async {
    try {
      await HiveService.clearAll();
      currentUser.value = null;
      transactions.clear();
      accounts.clear();
      loans.clear();
      recurrings.clear();
    } catch (e) {
      throw Exception('Erreur lors de la suppression des données: $e');
    }
  }

  /// Export data for backup
  Map<String, dynamic> exportData() {
    return {
      'user': currentUser.value?.toJson(),
      'transactions': transactions.map((t) => t.toJson()).toList(),
      'accounts': accounts.map((a) => a.toJson()).toList(),
      'loans': loans.map((l) => l.toJson()).toList(),
      'recurrings': recurrings.map((r) => r.toJson()).toList(),
      'exported_at': DateTime.now().toIso8601String(),
    };
  }

  /// Get data statistics
  Map<String, dynamic> getDataStats() {
    return {
      'total_transactions': transactions.length,
      'total_accounts': accounts.length,
      'total_loans': loans.length,
      'total_recurrings': recurrings.length,
      'current_balance': currentUser.value?.currentBalance ?? 0.0,
      'last_transaction': transactions.isNotEmpty ? transactions.first.date.toIso8601String() : null,
    };
  }
}