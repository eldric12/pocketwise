part of '../dashboard_tabs.dart';

class ActivityTab extends StatelessWidget {
  const ActivityTab({super.key, required this.transactions});

  final List<Transaction> transactions;

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final startOfToday = DateTime(today.year, today.month, today.day);
    final startOfYesterday = startOfToday.subtract(const Duration(days: 1));

    final todayItems = transactions
        .where(
          (tx) => tx.date.isAfter(startOfToday.subtract(const Duration(seconds: 1))),
        )
        .toList();
    final yesterdayItems = transactions
        .where(
          (tx) =>
              tx.date.isAfter(startOfYesterday.subtract(const Duration(seconds: 1))) &&
              tx.date.isBefore(startOfToday),
        )
        .toList();

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
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              const CircleIconButton(icon: Icons.swap_vert_rounded),
            ],
          ),
          const SizedBox(height: 20),
          const Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              FilterChipCard(label: 'All', selected: true),
              FilterChipCard(label: 'Income'),
              FilterChipCard(label: 'Expense'),
              FilterChipCard(label: 'This month'),
            ],
          ),
          const SizedBox(height: 24),
          if (transactions.isEmpty)
            const EmptyStateCard(
              title: 'Nothing to review',
              subtitle: 'Your transactions, filters, and history will show up here once you start logging activity.',
            )
          else ...[
            ActivityGroup(title: 'Today', transactions: todayItems),
            const SizedBox(height: 18),
            ActivityGroup(title: 'Yesterday', transactions: yesterdayItems),
          ],
        ],
      ),
    );
  }
}

