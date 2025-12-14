/// Custom exception for validation failures
class ValidationException implements Exception {
  final String message;
  ValidationException(this.message);

  @override
  String toString() => message;
}

/// Comprehensive financial data validators
class FinancialValidators {
  /// Validate transaction amount
  /// Returns: true if valid
  /// Throws: ValidationException if invalid
  static void validateAmount(double amount, {String fieldName = 'Amount'}) {
    if (amount.isNaN) {
      throw ValidationException('$fieldName is not a valid number');
    }
    if (amount <= 0) {
      throw ValidationException('$fieldName must be greater than 0');
    }
    if (amount > 999999999) {
      throw ValidationException('$fieldName is too large (max 999,999,999)');
    }
  }

  /// Validate transaction category exists
  static void validateCategory(String? categoryId) {
    if (categoryId == null || categoryId.isEmpty) {
      throw ValidationException('Please select a category');
    }
  }

  /// Validate transaction description
  static void validateDescription(String description) {
    if (description.isEmpty) {
      throw ValidationException('Description cannot be empty');
    }
    if (description.length > 200) {
      throw ValidationException('Description must be less than 200 characters');
    }
  }

  /// Validate budget amount
  static void validateBudgetAmount(double amount) {
    if (amount < 0) {
      throw ValidationException('Budget cannot be negative');
    }
    if (amount > 999999999) {
      throw ValidationException('Budget is too large');
    }
    // Note: Zero budget is allowed but discouraged
  }

  /// Validate goal amounts
  static void validateGoalAmounts(double targetAmount, double currentAmount) {
    validateAmount(targetAmount, fieldName: 'Target amount');
    if (currentAmount < 0) {
      throw ValidationException('Current amount cannot be negative');
    }
    if (currentAmount > 999999999) {
      throw ValidationException('Current amount is too large');
    }
  }

  /// Validate debt amounts
  static void validateDebtAmounts(double originalAmount) {
    validateAmount(originalAmount, fieldName: 'Debt amount');
  }

  /// Validate string is not empty
  static void validateNotEmpty(String? value, String fieldName) {
    if (value?.isEmpty ?? true) {
      throw ValidationException('$fieldName is required');
    }
  }

  /// Validate multiple amounts are provided for goal milestones
  static void validateMilestoneAmounts(List<double> milestoneAmounts) {
    if (milestoneAmounts.isEmpty) {
      throw ValidationException('At least one milestone is required');
    }
    for (var amount in milestoneAmounts) {
      if (amount <= 0) {
        throw ValidationException('Milestone amounts must be positive');
      }
    }
  }

  /// Validate date is in the future or today
  static void validateFutureDate(DateTime? date) {
    if (date == null) {
      throw ValidationException('Date is required');
    }
    final today = DateTime.now();
    if (date.isBefore(DateTime(today.year, today.month, today.day))) {
      throw ValidationException('Date must be today or in the future');
    }
  }

  /// Validate date is not in the future
  static void validatePastOrTodayDate(DateTime? date) {
    if (date == null) {
      throw ValidationException('Date is required');
    }
    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final dateNormalized = DateTime(date.year, date.month, date.day);
    if (dateNormalized.isAfter(today)) {
      throw ValidationException('Date cannot be in the future');
    }
  }

  /// Validate person name for debts
  static void validatePersonName(String? name) {
    if (name == null || name.isEmpty) {
      throw ValidationException('Person name is required');
    }
    if (name.length > 100) {
      throw ValidationException('Person name must be less than 100 characters');
    }
  }
}
