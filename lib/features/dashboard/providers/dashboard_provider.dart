import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/transaction.dart';

class DashboardState {
  final List<Transaction> transactions;
  final Map<String, double>? _budgetLimits;
  final bool isLoading;

  DashboardState({
    required this.transactions,
    Map<String, double>? budgetLimits,
    this.isLoading = false,
  }) : _budgetLimits = budgetLimits;

  Map<String, double> get budgetLimits => _budgetLimits ?? const {};

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
  DashboardNotifier() : super(DashboardState(transactions: [])) {
    _loadInitialData();
  }

  void _loadInitialData() {
    state = DashboardState(transactions: []);
  }

  void addTransaction(Transaction transaction) {
    state = state.copyWith(
      transactions: [transaction, ...state.transactions],
    );
  }

  void deleteTransaction(String id) {
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

final dashboardProvider = StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
  return DashboardNotifier();
});
