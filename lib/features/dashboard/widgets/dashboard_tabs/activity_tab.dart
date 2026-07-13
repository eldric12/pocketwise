part of '../dashboard_tabs.dart';

enum _ActivityFilter { all, income, expense, thisMonth }

class ActivityTab extends StatefulWidget {
  const ActivityTab({super.key, required this.transactions});

  final List<Transaction> transactions;

  @override
  State<ActivityTab> createState() => _ActivityTabState();
}

class _ActivityTabState extends State<ActivityTab> {
  _ActivityFilter _filter = _ActivityFilter.all;
  bool _newestFirst = true;

  @override
  Widget build(BuildContext context) {
    final filteredTransactions = _filteredTransactions();
    final groupedTransactions = _groupByDate(filteredTransactions);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Transactions',
                style: GoogleFonts.inter(
                  color: context.themeColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              CircleIconButton(
                icon: _newestFirst
                    ? Icons.arrow_downward_rounded
                    : Icons.arrow_upward_rounded,
                onPressed: () {
                  setState(() => _newestFirst = !_newestFirst);
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              FilterChipCard(
                label: 'All',
                selected: _filter == _ActivityFilter.all,
                onTap: () => _setFilter(_ActivityFilter.all),
              ),
              FilterChipCard(
                label: 'Income',
                selected: _filter == _ActivityFilter.income,
                onTap: () => _setFilter(_ActivityFilter.income),
              ),
              FilterChipCard(
                label: 'Expense',
                selected: _filter == _ActivityFilter.expense,
                onTap: () => _setFilter(_ActivityFilter.expense),
              ),
              FilterChipCard(
                label: 'This month',
                selected: _filter == _ActivityFilter.thisMonth,
                onTap: () => _setFilter(_ActivityFilter.thisMonth),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (filteredTransactions.isEmpty)
            EmptyStateCard(
              title: widget.transactions.isEmpty
                  ? 'Nothing to review'
                  : 'No matching transactions',
              subtitle: widget.transactions.isEmpty
                  ? 'Your transaction history will appear here once you start logging activity.'
                  : 'Try another filter to see more of your activity.',
            )
          else
            for (var i = 0; i < groupedTransactions.length; i++) ...[
              ActivityGroup(
                title: _dateLabel(groupedTransactions[i].key),
                transactions: groupedTransactions[i].value,
              ),
              if (i != groupedTransactions.length - 1)
                const SizedBox(height: 18),
            ],
        ],
      ),
    );
  }

  void _setFilter(_ActivityFilter filter) {
    if (_filter == filter) return;
    setState(() => _filter = filter);
  }

  List<Transaction> _filteredTransactions() {
    final now = DateTime.now();
    final filtered = widget.transactions.where((transaction) {
      return switch (_filter) {
        _ActivityFilter.all => true,
        _ActivityFilter.income => !transaction.isExpense,
        _ActivityFilter.expense => transaction.isExpense,
        _ActivityFilter.thisMonth =>
          transaction.date.year == now.year &&
              transaction.date.month == now.month,
      };
    }).toList();

    filtered.sort(
      (a, b) => _newestFirst
          ? b.date.compareTo(a.date)
          : a.date.compareTo(b.date),
    );
    return filtered;
  }

  List<MapEntry<DateTime, List<Transaction>>> _groupByDate(
    List<Transaction> transactions,
  ) {
    final groups = <DateTime, List<Transaction>>{};
    for (final transaction in transactions) {
      final date = DateTime(
        transaction.date.year,
        transaction.date.month,
        transaction.date.day,
      );
      groups.putIfAbsent(date, () => []).add(transaction);
    }
    return groups.entries.toList();
  }

  String _dateLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    if (date == today) return 'Today';
    if (date == yesterday) return 'Yesterday';

    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}


