import 'package:get/get.dart';

/// Controller for managing loan operations and state
class LoansController extends GetxController {
  // Observable state
  final RxBool isLoading = false.obs;
  final RxList<dynamic> loans = <dynamic>[].obs;
  final RxDouble totalLoanAmount = 0.0.obs;

  // Computed properties
  List<dynamic> get activeLoans =>
      loans.where((loan) => loan.isActive).toList();

  @override
  void onInit() {
    super.onInit();
    loadLoans();
  }

  /// Load loans from storage
  Future<void> loadLoans() async {
    try {
      isLoading.value = true;
      // TODO: Implement loan loading from storage
      await Future.delayed(const Duration(milliseconds: 500));
      // Mock data for now
      loans.clear();
      calculateTotalLoanAmount();
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de charger les prêts');
    } finally {
      isLoading.value = false;
    }
  }

  /// Refresh loans data
  Future<void> refreshLoans() async {
    await loadLoans();
  }

  /// Calculate total loan amount
  void calculateTotalLoanAmount() {
    totalLoanAmount.value = loans.fold(
      0.0,
      (sum, loan) => sum + loan.remainingAmount,
    );
  }

  /// Navigate to create new loan
  void navigateToCreateLoan() {
    Get.toNamed('/loans/create');
  }

  /// View loan details
  void viewLoanDetails(String loanId) {
    Get.toNamed('/loans/$loanId');
  }

  /// Make a payment on a loan
  void makePayment(String loanId) {
    Get.toNamed('/loans/$loanId/payment');
  }
}
