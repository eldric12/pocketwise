part of '../dashboard_tabs.dart';

class TransactionCardList extends StatelessWidget {
  const TransactionCardList({
    super.key,
    required this.transactions,
  });

  final List<Transaction> transactions;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (var i = 0; i < transactions.length; i++) ...[
            TransactionRow(transaction: transactions[i]),
            if (i != transactions.length - 1) const PanelDivider(),
          ],
        ],
      ),
    );
  }
}

class ActivityGroup extends StatelessWidget {
  const ActivityGroup({
    super.key,
    required this.title,
    required this.transactions,
  });

  final String title;
  final List<Transaction> transactions;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            color: AppColors.mutedText,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        if (transactions.isEmpty)
          const EmptyStateCard(
            title: 'No transactions here',
            subtitle: 'This section stays clean until matching activity is available.',
          )
        else
          TransactionCardList(transactions: transactions),
      ],
    );
  }
}

class TransactionRow extends StatelessWidget {
  const TransactionRow({
    super.key,
    required this.transaction,
  });

  final Transaction transaction;

  @override
  Widget build(BuildContext context) {
    final visual = categoryVisual(transaction.categoryLabel);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: visual.background,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              visual.icon,
              color: visual.foreground,
              size: 18,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.title,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${transaction.categoryLabel} · ${transaction.paymentMethod}',
                  style: GoogleFonts.inter(
                    color: AppColors.mutedText,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            formatAmount(
              transaction.amount,
              signed: true,
              positive: !transaction.isExpense,
            ),
            style: GoogleFonts.spaceGrotesk(
              color: transaction.isExpense ? AppColors.danger : AppColors.success,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

