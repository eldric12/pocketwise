part of '../dashboard_tabs.dart';

class HeaderSection extends StatelessWidget {
  const HeaderSection({
    super.key,
    required this.userName,
    required this.onToggleTheme,
  });

  final String? userName;
  final VoidCallback onToggleTheme;

  @override
  Widget build(BuildContext context) {
    final trimmedName = userName?.trim();
    final firstName = trimmedName == null || trimmedName.isEmpty
        ? null
        : trimmedName.split(RegExp(r'\s+')).first;
    final greeting = _greetingFor(DateTime.now().hour);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                firstName == null ? 'Welcome back' : '$greeting, $firstName',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  color: context.themeColors.textPrimary,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  height: 1.08,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'Your financial overview',
                style: GoogleFonts.inter(
                  color: context.themeColors.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        CircleIconButton(
          icon: Theme.of(context).brightness == Brightness.dark
              ? Icons.light_mode_outlined
              : Icons.dark_mode_outlined,
          onPressed: onToggleTheme,
        ),
      ],
    );
  }

  String _greetingFor(int hour) {
    if (hour < 12) return 'Good morning';
    if (hour < 18) return 'Good afternoon';
    return 'Good evening';
  }
}

class BalanceCard extends StatelessWidget {
  const BalanceCard({
    super.key,
    required this.currentBalance,
    required this.monthlyIncome,
    required this.monthlyExpense,
  });

  final double currentBalance;
  final double monthlyIncome;
  final double monthlyExpense;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Total Spending',
                  style: GoogleFonts.inter(
                    color: context.themeColors.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const _BalanceScopeBadge(),
            ],
          ),
          const SizedBox(height: 10),
          Semantics(
            label: 'All-time current balance',
            value: formatAmount(currentBalance, signed: false),
            child: ExcludeSemantics(
              child: Text(
                formatAmount(currentBalance, signed: false),
                style: GoogleFonts.spaceGrotesk(
                  color: context.themeColors.textPrimary,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Divider(height: 1, color: context.themeColors.border),
          const SizedBox(height: 16),
          Text(
            'THIS MONTH',
            style: GoogleFonts.inter(
              color: context.themeColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: MetricTile(
                  label: 'Income',
                  amount: monthlyIncome,
                  positive: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: MetricTile(
                  label: 'Expense',
                  amount: monthlyExpense,
                  positive: false,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BalanceScopeBadge extends StatelessWidget {
  const _BalanceScopeBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: context.themeColors.surfaceSoft,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        'ALL TIME',
        style: GoogleFonts.inter(
          color: Theme.of(context).colorScheme.primary,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class MetricTile extends StatelessWidget {
  const MetricTile({
    super.key,
    required this.label,
    required this.amount,
    required this.positive,
  });

  final String label;
  final double amount;
  final bool positive;

  @override
  Widget build(BuildContext context) {
    final color = positive ? AppColors.success : AppColors.danger;

    return Semantics(
      label: 'This month $label',
      value: formatAmount(amount, signed: true, positive: positive),
      child: ExcludeSemantics(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  positive
                      ? Icons.arrow_downward_rounded
                      : Icons.arrow_upward_rounded,
                  color: color,
                  size: 14,
                ),
                const SizedBox(width: 5),
                Text(
                  label,
                  style: GoogleFonts.inter(
                    color: context.themeColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              formatAmount(amount, signed: true, positive: positive),
              style: GoogleFonts.spaceGrotesk(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
