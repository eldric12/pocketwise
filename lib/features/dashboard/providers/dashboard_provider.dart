import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/transaction.dart';

class DashboardState {
  final List<Transaction> transactions;
  final bool isLoading;

  DashboardState({
    required this.transactions,
    this.isLoading = false,
  });

  DashboardState copyWith({
    List<Transaction>? transactions,
    bool? isLoading,
  }) {
    return DashboardState(
      transactions: transactions ?? this.transactions,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class DashboardNotifier extends StateNotifier<DashboardState> {
  DashboardNotifier() : super(DashboardState(transactions: [])) {
    _loadInitialData();
  }

  void _loadInitialData() {
    state = DashboardState(
      transactions: [
        Transaction(
          id: '1',
          title: 'Part-time pay',
          amount: 1500.0,
          date: DateTime.now().subtract(const Duration(days: 1)),
          categoryId: 'salary',
          categoryLabel: 'Salary',
          paymentMethod: 'Bank transfer',
          note: 'Campus event shift',
          isExpense: false,
        ),
        Transaction(
          id: '2',
          title: 'Lunch at Sunway',
          amount: 15.5,
          date: DateTime.now(),
          categoryId: 'food',
          categoryLabel: 'Food',
          paymentMethod: 'Cash',
          note: 'Chicken rice set',
          isExpense: true,
        ),
        Transaction(
          id: '3',
          title: 'Grab ride',
          amount: 12.0,
          date: DateTime.now(),
          categoryId: 'transport',
          categoryLabel: 'Transport',
          paymentMethod: 'E-wallet',
          note: 'Ride back to hostel',
          isExpense: true,
        ),
        Transaction(
          id: '4',
          title: 'Electricity bill',
          amount: 152.0,
          date: DateTime.now().subtract(const Duration(days: 4)),
          categoryId: 'bills',
          categoryLabel: 'Bills',
          paymentMethod: 'Bank transfer',
          note: 'Shared apartment utilities',
          isExpense: true,
        ),
      ],
    );
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
}

final dashboardProvider = StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
  return DashboardNotifier();
});
