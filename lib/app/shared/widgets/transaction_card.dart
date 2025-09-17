import 'package:flutter/material.dart';
import 'package:koala/app/data/models/transaction_model.dart';

/// Modern transaction card widget with beautiful design
class TransactionCard extends StatelessWidget {
  final TransactionModel transaction;
  final VoidCallback? onTap;

  const TransactionCard({super.key, required this.transaction, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(color: Colors.grey[100]!, width: 1),
        ),
        child: Row(
          children: [
            _buildTransactionIcon(),
            const SizedBox(width: 16),
            Expanded(child: _buildTransactionDetails()),
            _buildAmountAndDate(),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionIcon() {
    Color backgroundColor;
    Color iconColor;
    IconData iconData;

    switch (transaction.type) {
      case TransactionType.income:
        backgroundColor = Colors.green.withOpacity(0.1);
        iconColor = Colors.green;
        iconData = Icons.add_circle;
        break;
      case TransactionType.expense:
        backgroundColor = Colors.red.withOpacity(0.1);
        iconColor = Colors.red;
        iconData = Icons.remove_circle;
        break;
      case TransactionType.transfer:
        backgroundColor = Colors.blue.withOpacity(0.1);
        iconColor = Colors.blue;
        iconData = Icons.swap_horiz;
        break;
      case TransactionType.loan:
        backgroundColor = Colors.orange.withOpacity(0.1);
        iconColor = Colors.orange;
        iconData = Icons.handshake;
        break;
      case TransactionType.repayment:
        backgroundColor = Colors.purple.withOpacity(0.1);
        iconColor = Colors.purple;
        iconData = Icons.payment;
        break;
    }

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(iconData, color: iconColor, size: 24),
    );
  }

  Widget _buildTransactionDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          transaction.description,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            if (transaction.category.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  transaction.category,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
            if (transaction.merchant != null &&
                transaction.merchant!.isNotEmpty)
              Flexible(
                child: Text(
                  transaction.merchant!,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildAmountAndDate() {
    Color amountColor;
    String amountPrefix;

    switch (transaction.type) {
      case TransactionType.income:
        amountColor = Colors.green;
        amountPrefix = '+';
        break;
      case TransactionType.expense:
        amountColor = Colors.red;
        amountPrefix = '-';
        break;
      default:
        amountColor = Colors.grey[700]!;
        amountPrefix = '';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '$amountPrefix${_formatAmount(transaction.amount)} XOF',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: amountColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _formatDate(transaction.date),
          style: TextStyle(fontSize: 12, color: Colors.grey[500]),
        ),
      ],
    );
  }

  String _formatAmount(double amount) {
    // Format amount with thousands separator
    final formatted = amount.toInt().toString();
    final RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return formatted.replaceAllMapped(reg, (Match match) => '${match[1]} ');
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final transactionDate = DateTime(date.year, date.month, date.day);

    if (transactionDate == today) {
      return 'Aujourd\'hui';
    } else if (transactionDate == yesterday) {
      return 'Hier';
    } else if (now.difference(date).inDays < 7) {
      final weekdays = [
        'Lundi',
        'Mardi',
        'Mercredi',
        'Jeudi',
        'Vendredi',
        'Samedi',
        'Dimanche',
      ];
      return weekdays[date.weekday - 1];
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
