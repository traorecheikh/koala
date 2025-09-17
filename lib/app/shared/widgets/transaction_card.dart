import 'package:flutter/material.dart';
import 'package:koala/app/core/theme/app_colors.dart';
import 'package:koala/app/core/theme/app_dimensions.dart';
import 'package:koala/app/core/theme/app_text_styles.dart';
import 'package:koala/app/data/models/transaction_model.dart';

class TransactionCard extends StatelessWidget {
  final TransactionModel transaction;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const TransactionCard({
    super.key,
    required this.transaction,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(transaction.id),
      background: _buildSwipeBackground(true),
      secondaryBackground: _buildSwipeBackground(false),
      onDismissed: (direction) {
        if (direction == DismissDirection.startToEnd && onEdit != null) {
          onEdit!();
        } else if (direction == DismissDirection.endToStart &&
            onDelete != null) {
          onDelete!();
        }
      },
      child: Card(
        margin: const EdgeInsets.symmetric(
          horizontal: AppDimensions.md,
          vertical: AppDimensions.xs,
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.md),
            child: Row(
              children: [
                _buildTypeIcon(),
                const SizedBox(width: AppDimensions.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.description,
                        style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.xs),
                      if (transaction.merchant != null)
                        Text(
                          transaction.merchant!,
                          style: AppTextStyles.caption,
                        ),
                      Text(
                        _formatDate(transaction.date),
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${transaction.type == TransactionType.expense ? '-' : '+'}${transaction.amount.toStringAsFixed(0)} XOF',
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w600,
                        color: _getAmountColor(),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.xs),
                    if (transaction.category.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.sm,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _getCategoryColor().withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: Text(
                          transaction.category,
                          style: AppTextStyles.caption.copyWith(
                            color: _getCategoryColor(),
                            fontSize: 10,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypeIcon() {
    IconData iconData;
    Color iconColor;

    switch (transaction.type) {
      case TransactionType.income:
        iconData = Icons.arrow_downward;
        iconColor = AppColors.success;
        break;
      case TransactionType.expense:
        iconData = Icons.arrow_upward;
        iconColor = AppColors.error;
        break;
      case TransactionType.transfer:
        iconData = Icons.swap_horiz;
        iconColor = AppColors.info;
        break;
      case TransactionType.loan:
        iconData = Icons.account_balance;
        iconColor = AppColors.warning;
        break;
      default:
        iconData = Icons.help_outline;
        iconColor = AppColors.textSecondary;
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Icon(iconData, color: iconColor, size: 20),
    );
  }

  Widget _buildSwipeBackground(bool isEdit) {
    return Container(
      alignment: isEdit ? Alignment.centerLeft : Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.lg),
      color: isEdit ? AppColors.info : AppColors.error,
      child: Icon(isEdit ? Icons.edit : Icons.delete, color: AppColors.white),
    );
  }

  Color _getAmountColor() {
    switch (transaction.type) {
      case TransactionType.income:
        return AppColors.success;
      case TransactionType.expense:
        return AppColors.error;
      case TransactionType.transfer:
        return AppColors.info;
      case TransactionType.loan:
        return AppColors.warning;
      default:
        return AppColors.textPrimary;
    }
  }

  Color _getCategoryColor() {
    // Simple hash-based color assignment
    final hash = transaction.category.hashCode;
    final colors = [
      AppColors.primary,
      AppColors.success,
      AppColors.warning,
      AppColors.info,
      AppColors.secondary,
    ];
    return colors[hash.abs() % colors.length];
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final transactionDate = DateTime(date.year, date.month, date.day);

    if (transactionDate == today) {
      return 'Aujourd\'hui ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (transactionDate == today.subtract(const Duration(days: 1))) {
      return 'Hier ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
