import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:koala/app/data/models/transaction_model.dart';
import 'package:koala/app/modules/transactions/controllers/transaction_controller.dart';

/// Step-based transaction form as bottom sheet following OpenAPI schema
class AddTransactionBottomSheet extends StatefulWidget {
  const AddTransactionBottomSheet({super.key});

  static Future<void> show() {
    return Get.bottomSheet(
      const AddTransactionBottomSheet(),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: true,
    );
  }

  @override
  State<AddTransactionBottomSheet> createState() =>
      _AddTransactionBottomSheetState();
}

class _AddTransactionBottomSheetState extends State<AddTransactionBottomSheet>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;

  // Form data based on OpenAPI Transaction schema
  TransactionType _type = TransactionType.expense;
  double? _amount;
  String _description = '';
  String _merchant = '';
  String _category = '';
  final List<String> _tags = [];
  DateTime _timestamp = DateTime.now();

  // Step management
  int _currentStep = 0;
  final int _totalSteps = 4;
  bool _isLoading = false;

  // Controllers
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _merchantController = TextEditingController();
  final _tagController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    _merchantController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            0,
            _slideAnimation.value * MediaQuery.of(context).size.height,
          ),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.9,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                _buildHandle(),
                _buildHeader(),
                _buildProgressIndicator(),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildTypeStep(),
                      _buildAmountStep(),
                      _buildDetailsStep(),
                      _buildConfirmationStep(),
                    ],
                  ),
                ),
                _buildActionButtons(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHandle() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader() {
    final stepTitles = [
      'Type de transaction',
      'Montant',
      'Détails',
      'Confirmation',
    ];

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.close),
            style: IconButton.styleFrom(
              backgroundColor: Colors.grey[100],
              foregroundColor: Colors.grey[600],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Nouvelle transaction',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  stepTitles[_currentStep],
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Text(
            '${_currentStep + 1}/$_totalSteps',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: List.generate(_totalSteps, (index) {
          final isActive = index <= _currentStep;
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(right: index < _totalSteps - 1 ? 8 : 0),
              height: 4,
              decoration: BoxDecoration(
                color: isActive ? _getTypeColor() : Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  // Step 1: Transaction Type
  Widget _buildTypeStep() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quel type de transaction ?',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 32),
          _buildTypeOption(
            TransactionType.expense,
            'Dépense',
            'Argent que vous avez dépensé',
            Icons.remove_circle,
            Colors.red,
          ),
          const SizedBox(height: 16),
          _buildTypeOption(
            TransactionType.income,
            'Revenu',
            'Argent que vous avez reçu',
            Icons.add_circle,
            Colors.green,
          ),
          const SizedBox(height: 16),
          _buildTypeOption(
            TransactionType.transfer,
            'Transfert',
            'Mouvement entre comptes',
            Icons.swap_horiz,
            Colors.blue,
          ),
          const SizedBox(height: 16),
          _buildTypeOption(
            TransactionType.loan,
            'Prêt',
            'Argent prêté ou emprunté',
            Icons.handshake,
            Colors.orange,
          ),
          const SizedBox(height: 16),
          _buildTypeOption(
            TransactionType.repayment,
            'Remboursement',
            'Remboursement de prêt',
            Icons.payment,
            Colors.purple,
          ),
        ],
      ),
    );
  }

  Widget _buildTypeOption(
    TransactionType type,
    String title,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    final isSelected = _type == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          _type = type;
        });
        HapticFeedback.lightImpact();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.grey[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected ? color : Colors.grey[400],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? color : Colors.black87,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            if (isSelected) Icon(Icons.check_circle, color: color, size: 24),
          ],
        ),
      ),
    );
  }

  // Step 2: Amount
  Widget _buildAmountStep() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quel est le montant ?',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 48),
          Center(
            child: Column(
              children: [
                Text(
                  'Montant en XOF',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: _getTypeColor(),
                    ),
                    decoration: InputDecoration(
                      hintText: '0',
                      hintStyle: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[300],
                      ),
                      border: InputBorder.none,
                      suffix: Text(
                        'XOF',
                        style: TextStyle(fontSize: 20, color: Colors.grey[600]),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _amount = double.tryParse(value);
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Step 3: Details (description, merchant, category, tags)
  Widget _buildDetailsStep() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Détails de la transaction',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),

            // Description (required)
            const Text(
              'Description *',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                hintText: 'Ex: Achat supermarché',
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: _getTypeColor(), width: 2),
                ),
              ),
              onChanged: (value) => _description = value,
            ),

            const SizedBox(height: 20),

            // Merchant (optional)
            const Text(
              'Commerçant (optionnel)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _merchantController,
              decoration: InputDecoration(
                hintText: 'Ex: Carrefour',
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: _getTypeColor(), width: 2),
                ),
              ),
              onChanged: (value) => _merchant = value,
            ),

            const SizedBox(height: 20),

            // Category
            const Text(
              'Catégorie',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _category.isEmpty ? null : _category,
                  isExpanded: true,
                  hint: const Text('Sélectionner une catégorie'),
                  items: _getCategoriesForType().map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _category = value ?? '';
                    });
                  },
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Tags
            const Text(
              'Tags (optionnel)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _tagController,
                    decoration: InputDecoration(
                      hintText: 'Ajouter un tag',
                      filled: true,
                      fillColor: Colors.grey[50],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: _getTypeColor(),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _addTag,
                  icon: Icon(Icons.add, color: _getTypeColor()),
                  style: IconButton.styleFrom(
                    backgroundColor: _getTypeColor().withOpacity(0.1),
                  ),
                ),
              ],
            ),

            // Display tags
            if (_tags.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _tags.map((tag) {
                  return Chip(
                    label: Text(tag),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    onDeleted: () {
                      setState(() {
                        _tags.remove(tag);
                      });
                    },
                    backgroundColor: _getTypeColor().withOpacity(0.1),
                    side: BorderSide(color: _getTypeColor()),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Step 4: Confirmation
  Widget _buildConfirmationStep() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Confirmation',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildConfirmationRow('Type', _getTypeLabel(_type)),
                _buildConfirmationRow(
                  'Montant',
                  '${_amount?.toStringAsFixed(0) ?? '0'} XOF',
                ),
                _buildConfirmationRow('Description', _description),
                if (_merchant.isNotEmpty)
                  _buildConfirmationRow('Commerçant', _merchant),
                if (_category.isNotEmpty)
                  _buildConfirmationRow('Catégorie', _category),
                if (_tags.isNotEmpty)
                  _buildConfirmationRow('Tags', _tags.join(', ')),
                _buildConfirmationRow('Date', _formatDate(_timestamp)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmationRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousStep,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: _getTypeColor()),
                ),
                child: Text(
                  'Précédent',
                  style: TextStyle(color: _getTypeColor()),
                ),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            flex: _currentStep == 0 ? 1 : 1,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleNextOrSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: _getTypeColor(),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      _currentStep == _totalSteps - 1 ? 'Confirmer' : 'Suivant',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods
  Color _getTypeColor() {
    switch (_type) {
      case TransactionType.expense:
        return Colors.red;
      case TransactionType.income:
        return Colors.green;
      case TransactionType.transfer:
        return Colors.blue;
      case TransactionType.loan:
        return Colors.orange;
      case TransactionType.repayment:
        return Colors.purple;
    }
  }

  String _getTypeLabel(TransactionType type) {
    switch (type) {
      case TransactionType.expense:
        return 'Dépense';
      case TransactionType.income:
        return 'Revenu';
      case TransactionType.transfer:
        return 'Transfert';
      case TransactionType.loan:
        return 'Prêt';
      case TransactionType.repayment:
        return 'Remboursement';
    }
  }

  List<String> _getCategoriesForType() {
    switch (_type) {
      case TransactionType.expense:
        return [
          'Alimentation',
          'Transport',
          'Logement',
          'Santé',
          'Divertissement',
          'Shopping',
          'Services',
          'Éducation',
          'Autres',
        ];
      case TransactionType.income:
        return [
          'Salaire',
          'Freelance',
          'Investissements',
          'Cadeaux',
          'Vente',
          'Autres',
        ];
      default:
        return ['Général', 'Urgent', 'Planifié', 'Autres'];
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _addTag() {
    final tag = _tagController.text.trim();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
        _tagController.clear();
      });
    }
  }

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  bool _canProceedToNextStep() {
    switch (_currentStep) {
      case 0:
        return true; // Type is always selected
      case 1:
        return _amount != null && _amount! > 0;
      case 2:
        return _description.trim().isNotEmpty;
      case 3:
        return true; // Confirmation step
      default:
        return false;
    }
  }

  void _handleNextOrSubmit() {
    if (_currentStep == _totalSteps - 1) {
      _submitTransaction();
    } else if (_canProceedToNextStep()) {
      _nextStep();
    }
  }

  Future<void> _submitTransaction() async {
    if (!_canProceedToNextStep() ||
        _amount == null ||
        _description.trim().isEmpty) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Create transaction following OpenAPI schema
      final transaction = TransactionModel(
        userId: 'current-user-id', // TODO: Get from auth service
        amount: _amount!,
        type: _type,
        description: _description.trim(),
        merchant: _merchant.trim().isEmpty ? null : _merchant.trim(),
        category: _category,
        tags: _tags,
        date: _timestamp,
      );

      // Add transaction through controller
      final controller = Get.find<TransactionController>();
      await controller.addTransaction(transaction);

      // Success feedback
      HapticFeedback.heavyImpact();
      Get.back();
      Get.snackbar(
        'Succès',
        'Transaction ajoutée avec succès',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 2),
      );
    } catch (error) {
      Get.snackbar(
        'Erreur',
        'Impossible d\'ajouter la transaction',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
