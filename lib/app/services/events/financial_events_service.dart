import 'dart:async';
import 'package:get/get.dart';
import 'package:koaa/app/data/models/financial_goal.dart';
import 'package:koaa/app/data/models/local_transaction.dart';
import 'package:koaa/app/data/models/debt.dart';
import 'package:koaa/app/data/models/budget.dart'; // Import Budget

// Define different types of financial events
enum FinancialEventType {
  transactionAdded,
  transactionUpdated,
  transactionDeleted,
  budgetExceeded,
  budgetApproachingLimit,
  goalMilestoneReached,
  goalCompleted,
  goalAbandoned,
  debtPaidOff,
  debtApproachingDueDate,
  cashFlowWarning,
  savingOpportunity,
  financialHealthImproved,
  financialHealthDeclined,
}

// Base class for all financial events
class FinancialEvent {
  final FinancialEventType type;
  final DateTime timestamp;
  final Map<String, dynamic> payload;

  FinancialEvent({
    required this.type,
    DateTime? timestamp,
    this.payload = const {},
  }) : timestamp = timestamp ?? DateTime.now();

  @override
  String toString() => 'FinancialEvent(type: $type, timestamp: $timestamp, payload: $payload)';
}

// Specific event classes for better type safety and clarity
class TransactionEvent extends FinancialEvent {
  TransactionEvent(FinancialEventType type, LocalTransaction transaction)
      : super(
          type: type,
          payload: transaction.toJson(), 
        );
}

class BudgetEvent extends FinancialEvent {
  BudgetEvent(FinancialEventType type, Budget budget, {double? currentSpending, double? overshootAmount, double? percentageSpent})
      : super(
          type: type,
          payload: {
            'budget': budget.toJson(),
            if (currentSpending != null) 'currentSpending': currentSpending,
            if (overshootAmount != null) 'overshootAmount': overshootAmount,
            if (percentageSpent != null) 'percentageSpent': percentageSpent,
          },
        );
}

class GoalEvent extends FinancialEvent {
  GoalEvent(FinancialEventType type, FinancialGoal goal)
      : super(
          type: type,
          payload: goal.toJson(), 
        );
}

class DebtEvent extends FinancialEvent {
  DebtEvent(FinancialEventType type, Debt debt)
      : super(
          type: type,
          payload: debt.toJson(), 
        );
}

// Service to manage and emit financial events
class FinancialEventsService extends GetxService {
  final _eventController = StreamController<FinancialEvent>.broadcast();

  // Emit an event
  void emit(FinancialEvent event) {
    print('Emitting event: ${event.type} with payload: ${event.payload}');
    _eventController.add(event);
  }

  void emitTransactionAdded(LocalTransaction transaction) {
    emit(TransactionEvent(FinancialEventType.transactionAdded, transaction));
  }

  void emitTransactionDeleted(String transactionId) {
    // For deletion, we might usually pass ID, but FinancialEvent takes payload map
    emit(FinancialEvent(type: FinancialEventType.transactionDeleted, payload: {'id': transactionId}));
  }

  void emitBudgetExceeded({required String budgetId, required String categoryId, required double overshootAmount}) {
    emit(BudgetEvent(FinancialEventType.budgetExceeded, 
      Budget(id: budgetId, categoryId: categoryId, amount: 0, year: 0, month: 0), 
      overshootAmount: overshootAmount,
    ));
  }

  void emitBudgetApproachingLimit({required String budgetId, required String categoryId, required double percentageSpent}) {
    emit(BudgetEvent(FinancialEventType.budgetApproachingLimit, 
      Budget(id: budgetId, categoryId: categoryId, amount: 0, year: 0, month: 0), 
      percentageSpent: percentageSpent,
    ));
  }

  void emitDebtPaidOff(Debt debt) {
    emit(DebtEvent(FinancialEventType.debtPaidOff, debt));
  }

  // Listen to all events
  Stream<FinancialEvent> onEvent() {
    return _eventController.stream;
  }

  // Listen to specific event types
  Stream<T> on<T extends FinancialEvent>() {
    return _eventController.stream.where((event) => event is T).cast<T>();
  }
  
  @override
  void onClose() {
    _eventController.close();
    super.onClose();
  }
}