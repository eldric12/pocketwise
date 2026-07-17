part of '../dashboard_tabs.dart';

class ReportAnalytics extends StatefulWidget {
  const ReportAnalytics({
    super.key,
    required this.transactions
  });

  final List<Transaction> transactions;

  @override
  State<ReportAnalytics> createState() => _ReportAnalytics();
}

class _ReportAnalytics extends State<ReportAnalytics> {

  @override
  Widget build(BuildContext context) {
    final chartItems = getMonthlyChartItems(widget.transactions);

    return Scaffold(
      backgroundColor: context.themeColors.background,
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: CircleIconButton(
              icon: Icons.arrow_back_ios,
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
        ),
        backgroundColor: context.themeColors.background,
        title: Text(
          'Reports & Analytics',
          style: GoogleFonts.inter(
            color: context.themeColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ))
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                const FilterChipCard(
                  label: 'Weekly',
                  // selected: _filter == _ActivityFilter.all,
                  // onTap: () => _setFilter(_ActivityFilter.all),
                ),
                const FilterChipCard(
                  label: 'Monthly',
                  // selected: _filter == _ActivityFilter.income,
                  // onTap: () => _setFilter(_ActivityFilter.income),
                ),
                const FilterChipCard(
                  label: 'Yearly',
                  // selected: _filter == _ActivityFilter.expense,
                  // onTap: () => _setFilter(_ActivityFilter.expense),
                ),
                CircleIconButton(
                  icon: Icons.calendar_month,
                  onPressed: () {

                  },
                )
              ],
            ),
            const SizedBox(height: 26),
            Text(
              'Spending trend',
              style: GoogleFonts.inter(
                color: context.themeColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            OverviewCard(items: chartItems),
          ],
        ),
      )
    );
  }
}