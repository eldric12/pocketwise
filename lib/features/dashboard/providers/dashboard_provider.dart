import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_provider.dart';
import '../../auth/services/transaction_service.dart';
import '../models/category_definition.dart';
import '../models/transaction.dart';
import '../services/local_finance_service.dart';

class DashboardState {
  final List<Transaction> transactions;
  final Map<String, double> budgetLimits;
  final List<CategoryDefinition> categories;
  final bool isLoading;

  DashboardState({
    required this.transactions,
    this.budgetLimits = const {},
    this.categories = const [],
    this.isLoading = false,
  });

  DashboardState copyWith({
    List<Transaction>? transactions,
    Map<String, double>? budgetLimits,
    List<CategoryDefinition>? categories,
    bool? isLoading,
  }) {
    return DashboardState(
      transactions: transactions ?? this.transactions,
      budgetLimits: budgetLimits ?? this.budgetLimits,
      categories: categories ?? this.categories,
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
      final categories = await LocalFinanceService.instance.loadCategories(
        userId!,
      );
      state = state.copyWith(
        transactions: localTransactions,
        budgetLimits: budgetLimits,
        categories: categories,
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

    try {
      final remoteBudgets = await TransactionService.instance
          .getBudgetsForUser(userId!);
      for (final entry in remoteBudgets.entries) {
        await LocalFinanceService.instance.saveBudget(
          userId!,
          entry.key,
          entry.value,
        );
      }
      state = state.copyWith(budgetLimits: remoteBudgets);
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
    try {
      await TransactionService.instance.saveBudget(userId!, category, limit);
    } catch (_) {
      // Offline — local copy above still keeps this budget for now.
    }
    state = state.copyWith(
      budgetLimits: {...state.budgetLimits, category: limit},
    );
  }

  Future<void> removeBudget(String category) async {
    if (userId == null) return;
    await LocalFinanceService.instance.deleteBudget(userId!, category);
    try {
      await TransactionService.instance.deleteBudget(userId!, category);
    } catch (_) {
      // Offline — local delete above still applies.
    }
    final updatedLimits = Map<String, double>.from(state.budgetLimits)
      ..remove(category);
    state = state.copyWith(budgetLimits: updatedLimits);
  }

  Future<void> addCategory(CategoryDefinition category) async {
    if (userId == null) return;
    await LocalFinanceService.instance.saveCategory(userId!, category);
    final alreadyExists = state.categories.any(
      (item) =>
          item.isExpense == category.isExpense &&
          item.label.toLowerCase() == category.label.toLowerCase(),
    );
    if (alreadyExists) return;
    state = state.copyWith(categories: [...state.categories, category]);
  }

  Future<void> updateCategory(CategoryDefinition category) async {
    if (userId == null) return;
    await LocalFinanceService.instance.saveCategory(userId!, category);
    state = state.copyWith(
      categories: [
        for (final item in state.categories)
          if (item.id == category.id && item.isExpense == category.isExpense)
            category
          else
            item,
      ],
    );
  }

  Future<void> clearAllData() async {
    if (userId == null) return;
    state = state.copyWith(isLoading: true);
    try {
      await TransactionService.instance.clearAllTransactions(userId!);
      await TransactionService.instance.clearAllBudgets(userId!);
    } catch (_) {
      // If offline, still clear local data so the UI reflects the reset.
    }
    await LocalFinanceService.instance.clearAllData(userId!);
    await _loadInitialData();
  }
}

final dashboardProvider =
    StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
      final userId = ref.watch(currentUserIdProvider);
      return DashboardNotifier(userId: userId);
    });