import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../models/transaction.dart';
import '../providers/dashboard_provider.dart';
import '../screens/new_transaction_screen.dart';
import '../widgets/dashboard_navigation.dart';
import '../widgets/dashboard_tabs.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final dashboardState = ref.watch(dashboardProvider);
    final transactions = dashboardState.transactions;

    return Scaffold(
      backgroundColor: AppColors.background,
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
  ) {
    switch (_currentIndex) {
      case 0:
        return HomeTab(
          transactions: transactions,
          budgetLimits: budgetLimits,
        );
      case 1:
        return ActivityTab(transactions: transactions);
      case 2:
        return BudgetsTab(
          transactions: transactions,
          budgetLimits: budgetLimits,
          onSetBudget: (category, limit) {
            ref.read(dashboardProvider.notifier).setBudget(category, limit);
          },
          onRemoveBudget: (category) {
            ref.read(dashboardProvider.notifier).removeBudget(category);
          },
        );
      case 3:
        return MoreTab(
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
        );
    }
  }

  Future<void> _openAddTransaction() async {
    await Navigator.of(context).push(
      PageRouteBuilder<void>(
        pageBuilder: (context, animation, secondaryAnimation) {
          return FadeTransition(
            opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
            child: const NewTransactionScreen(),
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final slide = Tween<Offset>(
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
