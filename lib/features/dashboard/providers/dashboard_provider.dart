import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_provider.dart';
import '../../auth/services/transaction_service.dart';
import '../models/custom_category.dart';
import '../models/transaction.dart';
import '../services/local_finance_service.dart';

class DashboardState {
  final List<Transaction> transactions;
  final Map<String, double> budgetLimits;
  final List<CustomCategory> customCategories;
  final bool isLoading;

  DashboardState({
    required this.transactions,
    this.budgetLimits = const {},
    this.customCategories = const [],
    this.isLoading = false,
  });

  DashboardState copyWith({
    List<Transaction>? transactions,
    Map<String, double>? budgetLimits,
    List<CustomCategory>? customCategories,
    bool? isLoading,
  }) {
    return DashboardState(
      transactions: transactions ?? this.transactions,
      budgetLimits: budgetLimits ?? this.budgetLimits,
      customCategories: customCategories ?? this.customCategories,
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

    try {
      final localTransactions = await LocalFinanceService.instance
          .loadTransactions(userId!);
      final budgetLimits = await LocalFinanceService.instance.loadBudgets(
        userId!,
      );
      final customCategories = await LocalFinanceService.instance
          .loadCustomCategories(userId!);
      state = state.copyWith(
        transactions: localTransactions,
        budgetLimits: budgetLimits,
        customCategories: customCategories,
        isLoading: false,
      );
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }

    try {
      final remoteTransactions = await TransactionService.instance
          .getTransactionsForUser(userId!);
      await LocalFinanceService.instance.replaceTransactions(
        userId!,
        remoteTransactions,
      );
      state = state.copyWith(transactions: remoteTransactions);
    } catch (_) {
      // Keep the local snapshot available when Firebase cannot be reached.
    }
  }

  Future<void> addTransaction(Transaction transaction) async {
    if (userId == null) return;
    await TransactionService.instance.insertTransaction(userId!, transaction);
    await LocalFinanceService.instance.saveTransaction(userId!, transaction);
    state = state.copyWith(transactions: [transaction, ...state.transactions]);
  }

  Future<void> updateTransaction(Transaction transaction) async {
    if (userId == null) return;
    await TransactionService.instance.updateTransaction(userId!, transaction);
    await LocalFinanceService.instance.saveTransaction(userId!, transaction);
    final updatedTransactions =
        state.transactions
            .map((item) => item.id == transaction.id ? transaction : item)
            .toList()
          ..sort((a, b) => b.date.compareTo(a.date));
    state = state.copyWith(transactions: updatedTransactions);
  }

  Future<void> deleteTransaction(String id) async {
    if (userId == null) return;
    await TransactionService.instance.deleteTransaction(userId!, id);
    await LocalFinanceService.instance.deleteTransaction(userId!, id);
    state = state.copyWith(
      transactions: state.transactions.where((t) => t.id != id).toList(),
    );
  }

  Future<void> setBudget(String category, double limit) async {
    if (userId == null) return;
    await LocalFinanceService.instance.saveBudget(userId!, category, limit);
    state = state.copyWith(
      budgetLimits: {...state.budgetLimits, category: limit},
    );
  }

  Future<void> removeBudget(String category) async {
    if (userId == null) return;
    await LocalFinanceService.instance.deleteBudget(userId!, category);
    final updatedLimits = Map<String, double>.from(state.budgetLimits)
      ..remove(category);
    state = state.copyWith(budgetLimits: updatedLimits);
  }

  Future<void> addCustomCategory(CustomCategory category) async {
    if (userId == null) return;
    await LocalFinanceService.instance.saveCustomCategory(userId!, category);
    final alreadyExists = state.customCategories.any(
      (item) =>
          item.isExpense == category.isExpense &&
          item.label.toLowerCase() == category.label.toLowerCase(),
    );
    if (alreadyExists) return;
    state = state.copyWith(
      customCategories: [...state.customCategories, category],
    );
  }
}

final dashboardProvider =
    StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
      final userId = ref.watch(currentUserIdProvider);
      return DashboardNotifier(userId: userId);
    });
