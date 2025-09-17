import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:koala/app/core/theme/app_colors.dart';
import 'package:koala/app/core/theme/app_dimensions.dart';
import 'package:koala/app/core/theme/app_text_styles.dart';
import 'package:koala/app/data/models/user_model.dart';
import 'package:koala/app/data/services/local_data_service.dart';
import 'package:koala/app/shared/widgets/base_bottom_sheet.dart';

/// Financial information editing bottom sheet
class FinancialInfoBottomSheet extends StatefulWidget {
  const FinancialInfoBottomSheet({super.key});

  static Future<void> show() {
    return BaseBottomSheet.show(
      title: 'Informations financières',
      child: const FinancialInfoBottomSheet(),
    );
  }

  @override
  State<FinancialInfoBottomSheet> createState() => _FinancialInfoBottomSheetState();
}

class _FinancialInfoBottomSheetState extends State<FinancialInfoBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _salaryController = TextEditingController();
  final _balanceController = TextEditingController();
  
  final _isLoading = false.obs;
  final _selectedPayDay = 1.obs;
  UserModel? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  @override
  void dispose() {
    _salaryController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  void _loadCurrentUser() {
    _currentUser = LocalDataService.to.getCurrentUser();
    if (_currentUser != null) {
      _salaryController.text = _currentUser!.monthlySalary.toStringAsFixed(0);
      _balanceController.text = _currentUser!.currentBalance.toStringAsFixed(0);
      _selectedPayDay.value = _currentUser!.payDay;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFinancialHeader(),
          const SizedBox(height: 24),
          _buildFormFields(),
          const SizedBox(height: 32),
          _buildSaveButton(),
        ],
      ),
    );
  }

  Widget _buildFinancialHeader() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Icon(
              Icons.account_balance_wallet,
              size: 30,
              color: AppColors.success,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Finances personnelles',
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Gérez votre salaire et votre solde',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(
          controller: _salaryController,
          label: 'Salaire mensuel (XOF)',
          icon: Icons.payments_outlined,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Le salaire est obligatoire';
            }
            final salary = double.tryParse(value);
            if (salary == null || salary <= 0) {
              return 'Veuillez entrer un salaire valide';
            }
            if (salary < 50000) {
              return 'Le salaire semble très bas (minimum 50,000 XOF)';
            }
            return null;
          },
          suffix: 'XOF',
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _balanceController,
          label: 'Solde actuel (XOF)',
          icon: Icons.account_balance_outlined,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9-]')),
          ],
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Le solde est obligatoire';
            }
            final balance = double.tryParse(value);
            if (balance == null) {
              return 'Veuillez entrer un solde valide';
            }
            return null;
          },
          suffix: 'XOF',
        ),
        const SizedBox(height: 24),
        _buildPayDaySelector(),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? suffix,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primary),
        suffixText: suffix,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.textSecondary),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(
            color: AppColors.textSecondary.withValues(alpha: 0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
      ),
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
    );
  }

  Widget _buildPayDaySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date de paie',
          style: AppTextStyles.body.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Jour du mois où vous recevez votre salaire',
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(
              color: AppColors.textSecondary.withValues(alpha: 0.3),
            ),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Obx(() => DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: _selectedPayDay.value,
              isExpanded: true,
              icon: const Icon(Icons.arrow_drop_down, color: AppColors.primary),
              onChanged: (int? newValue) {
                if (newValue != null) {
                  _selectedPayDay.value = newValue;
                }
              },
              items: List.generate(31, (index) {
                final day = index + 1;
                return DropdownMenuItem<int>(
                  value: day,
                  child: Text(
                    day == 31 ? 'Dernier jour du mois' : '$day du mois',
                    style: AppTextStyles.body,
                  ),
                );
              }),
            ),
          )),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return Obx(() => SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isLoading.value ? null : _saveChanges,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.success,
          foregroundColor: AppColors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
        icon: _isLoading.value
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.white,
                ),
              )
            : const Icon(Icons.save, size: 20),
        label: Text(
          _isLoading.value ? 'Sauvegarde...' : 'Sauvegarder',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
    ));
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    if (_currentUser == null) {
      Get.snackbar('Erreur', 'Utilisateur non trouvé');
      return;
    }

    try {
      _isLoading.value = true;

      final salary = double.parse(_salaryController.text);
      final balance = double.parse(_balanceController.text);

      // Create updated user model
      final updatedUser = _currentUser!.copyWith(
        monthlySalary: salary,
        currentBalance: balance,
        payDay: _selectedPayDay.value,
      );

      // Save to local storage
      await LocalDataService.to.saveUser(updatedUser);

      Get.back();
      Get.snackbar(
        'Succès',
        'Informations financières mises à jour',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success,
        colorText: AppColors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de sauvegarder: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: AppColors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    } finally {
      _isLoading.value = false;
    }
  }
}