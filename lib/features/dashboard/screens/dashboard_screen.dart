import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme_colors.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/transaction.dart';
import '../providers/dashboard_provider.dart';
import '../screens/new_transaction_screen.dart';
import '../widgets/dashboard_navigation.dart';
import '../widgets/dashboard_tabs.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key, required this.onToggleTheme});

  final VoidCallback onToggleTheme;

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final dashboardState = ref.watch(dashboardProvider);
    final transactions = dashboardState.transactions;
    final userName = ref
        .watch(currentUserNameProvider)
        .when(
          data: (name) => name,
          loading: () => null,
          error: (_, __) => null,
        );

    return Scaffold(
      backgroundColor: context.themeColors.background,
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 260),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          child: KeyedSubtree(
            key: ValueKey(_currentIndex),
            child: _buildCurrentScreen(
              transactions,
              dashboardState.budgetLimits,
              userName,
            ),
          ),
        ),
      ),
      bottomNavigationBar: PocketWiseBottomBar(
        currentIndex: _currentIndex,
        onChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        onAddPressed: _openAddTransaction,
      ),
    );
  }

  Widget _buildCurrentScreen(
    List<Transaction> transactions,
    Map<String, double> budgetLimits,
    String? userName,
  ) {
    switch (_currentIndex) {
      case 0:
        return HomeTab(
          transactions: transactions,
          budgetLimits: budgetLimits,
          userName: userName,
          onTransactionTap: _openEditTransaction,
          onSeeAll: _showActivity,
          onToggleTheme: widget.onToggleTheme,
        );
      case 1:
        return ActivityTab(
          transactions: transactions,
          onTransactionTap: _openEditTransaction,
        );
      case 2:
        return BudgetsTab(
          transactions: transactions,
          budgetLimits: budgetLimits,
          onSetBudget: _setBudget,
          onRemoveBudget: _removeBudget,
        );
      case 3:
        return MoreTab(
          onToggleTheme: widget.onToggleTheme,
          onOpenReports: () {
            setState(() {
              _currentIndex = 0;
            });
          },
        );
      default:
        return HomeTab(
          transactions: transactions,
          budgetLimits: budgetLimits,
          userName: userName,
          onTransactionTap: _openEditTransaction,
          onSeeAll: _showActivity,
          onToggleTheme: widget.onToggleTheme,
        );
    }
  }

  void _showActivity() {
    setState(() => _currentIndex = 1);
  }

  Future<void> _setBudget(String category, double limit) async {
    try {
      await ref.read(dashboardProvider.notifier).setBudget(category, limit);
    } catch (_) {
      if (mounted) {
        _showPersistenceError('Unable to save this budget. Please try again.');
      }
    }
  }

  Future<void> _removeBudget(String category) async {
    try {
      await ref.read(dashboardProvider.notifier).removeBudget(category);
    } catch (_) {
      if (mounted) {
        _showPersistenceError(
          'Unable to remove this budget. Please try again.',
        );
      }
    }
  }

  void _showPersistenceError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _openAddTransaction() async {
    await _openTransactionForm();
  }

  Future<void> _openEditTransaction(Transaction transaction) async {
    await _openTransactionForm(transaction: transaction);
  }

  Future<void> _openTransactionForm({Transaction? transaction}) async {
    await Navigator.of(context).push(
      PageRouteBuilder<Transaction>(
        pageBuilder: (context, animation, secondaryAnimation) {
          return FadeTransition(
            opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
            child: NewTransactionScreen(initialTransaction: transaction),
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final slide =
              Tween<Offset>(
                begin: const Offset(0, 0.06),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
              );
          return SlideTransition(position: slide, child: child);
        },
      ),
    );
  }
}
