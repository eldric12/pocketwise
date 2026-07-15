import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_provider.dart';
import '../../auth/services/transaction_service.dart';
import '../models/transaction.dart';

class DashboardState {
  final List<Transaction> transactions;
  final Map<String, double> budgetLimits;
  final bool isLoading;

  DashboardState({
    required this.transactions,
    this.budgetLimits = const {},
    this.isLoading = false,
  });

  DashboardState copyWith({
    List<Transaction>? transactions,
    Map<String, double>? budgetLimits,
    bool? isLoading,
  }) {
    return DashboardState(
      transactions: transactions ?? this.transactions,
      budgetLimits: budgetLimits ?? this.budgetLimits,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class DashboardNotifier extends StateNotifier<DashboardState> {
  DashboardNotifier({required this.userId})
      : super(DashboardState(transactions: [], isLoading: true)) {
    _loadInitialData();
  }

  final String? userId;

  Future<void> _loadInitialData() async {
    if (userId == null) {
      state = DashboardState(transactions: [], isLoading: false);
      return;
    }
    final transactions =
        await TransactionService.instance.getTransactionsForUser(userId!);
    state = state.copyWith(transactions: transactions, isLoading: false);
  }

  Future<void> addTransaction(Transaction transaction) async {
    if (userId == null) return;
    await TransactionService.instance.insertTransaction(userId!, transaction);
    state = state.copyWith(
      transactions: [transaction, ...state.transactions],
    );
  }

  Future<void> deleteTransaction(String id) async {
    if (userId == null) return;
    await TransactionService.instance.deleteTransaction(userId!, id);
    state = state.copyWith(
      transactions: state.transactions.where((t) => t.id != id).toList(),
    );
  }

  void setBudget(String category, double limit) {
    state = state.copyWith(
      budgetLimits: {...state.budgetLimits, category: limit},
    );
  }

  void removeBudget(String category) {
    final updatedLimits = Map<String, double>.from(state.budgetLimits)
      ..remove(category);
    state = state.copyWith(budgetLimits: updatedLimits);
  }
}

final dashboardProvider =
    StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  return DashboardNotifier(userId: userId);
});