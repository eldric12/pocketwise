part of '../dashboard_tabs.dart';

class OverviewCard extends StatefulWidget {
  const OverviewCard({super.key, required this.items});

  final List<ChartLegendItem> items;

  @override
  State<OverviewCard> createState() => _OverviewCardState();
}

class _OverviewCardState extends State<OverviewCard> {
  int _touchedIndex = -1;

  @override
  void didUpdateWidget(covariant OverviewCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_touchedIndex >= widget.items.length) _touchedIndex = -1;
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.items;
    final total = items.fold<double>(0, (sum, item) => sum + item.amount);
    final selectedItem = _touchedIndex >= 0 ? items[_touchedIndex] : null;
    final centerLabel = selectedItem?.label.toUpperCase() ?? 'TOTAL EXP';
    final centerAmount = selectedItem?.amount ?? total;

    if (items.isEmpty) {
      return GlassPanel(
        child: SizedBox(
          height: 116,
          child: Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.donut_large_rounded,
                  color: AppColors.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'No spending this month',
                      style: GoogleFonts.inter(
                        color: context.themeColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Add an expense to see your category breakdown.',
                      style: GoogleFonts.inter(
                        color: context.themeColors.textSecondary,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return GlassPanel(
      child: Row(
        children: [
          SizedBox(
            width: 142,
            height: 142,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 39,
                    startDegreeOffset: -90,
                    pieTouchData: PieTouchData(
                      touchCallback: (event, response) {
                        final touchedIndex =
                            response?.touchedSection?.touchedSectionIndex ?? -1;
                        final nextIndex = event.isInterestedForInteractions
                            ? touchedIndex
                            : -1;
                        if (nextIndex != _touchedIndex) {
                          setState(() => _touchedIndex = nextIndex);
                        }
                      },
                    ),
                    sections: items
                        .asMap()
                        .entries
                        .map(
                          (entry) => PieChartSectionData(
                            value: entry.value.amount,
                            color: entry.value.color,
                            radius: entry.key == _touchedIndex ? 24 : 20,
                            showTitle: false,
                          ),
                        )
                        .toList(),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 72,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          centerLabel,
                          maxLines: 1,
                          style: GoogleFonts.inter(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.7,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 3),
                    SizedBox(
                      width: 74,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'RM ${centerAmount.toStringAsFixed(0)}',
                          maxLines: 1,
                          style: GoogleFonts.spaceGrotesk(
                            color: context.themeColors.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: items
                  .asMap()
                  .entries
                  .map(
                    (entry) => MouseRegion(
                      onEnter: (_) {
                        setState(() => _touchedIndex = entry.key);
                      },
                      onExit: (_) {
                        setState(() => _touchedIndex = -1);
                      },
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          setState(() {
                            _touchedIndex = _touchedIndex == entry.key
                                ? -1
                                : entry.key;
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: entry.value.color,
                                  borderRadius: BorderRadius.circular(99),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '${entry.value.label} · RM${entry.value.amount.toStringAsFixed(0)}',
                                  style: GoogleFonts.inter(
                                    color: _touchedIndex == entry.key
                                        ? context.themeColors.textPrimary
                                        : context.themeColors.textSecondary,
                                    fontSize: 13,
                                    fontWeight: _touchedIndex == entry.key
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// Line Chart
class LineChartCard extends StatelessWidget {
  const LineChartCard({super.key, required this.items});

  final List<ChartLegendItem> items;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;

    final spots = items
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.amount))
        .toList();

    final rawMax = items.isEmpty
        ? 10.0
        : items.map((e) => e.amount).reduce((a, b) => a > b ? a : b);

    // round up to nearest 10 (or 20/50/100 depending on scale) for clean ticks
    final maxY = rawMax <= 0 ? 10.0 : (rawMax / 10).ceil() * 10.0 * 1.2;
    final yInterval = maxY / 4;

    // Avoid overcrowded labels when there are many points (e.g. 31 days)
    final labelInterval = items.length > 12
        ? (items.length / 6).ceil().toDouble()
        : 1.0;

    return SizedBox(
      height: 250,
      child: Padding(
        padding: const EdgeInsets.only(right: 16, top: 12),
        child: LineChart(
          LineChartData(
            minX: 0,
            maxX: spots.isEmpty ? 0 : (spots.length - 1).toDouble(),
            minY: 0,
            maxY: maxY,
            clipData: const FlClipData.all(),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: yInterval,
              getDrawingHorizontalLine: (value) =>
                  FlLine(color: colors.border, strokeWidth: 1),
            ),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                preventCurveOverShooting: true,
                color: AppColors.primary,
                barWidth: 3,
                dotData: const FlDotData(show: true),
                belowBarData: BarAreaData(
                  show: true,
                  color: AppColors.primary.withValues(alpha: 0.12),
                ),
              ),
            ],
            titlesData: FlTitlesData(
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: labelInterval,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index < 0 || index >= items.length) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        items[index].label,
                        style: GoogleFonts.inter(
                          color: colors.textSecondary,
                          fontSize: 10,
                        ),
                      ),
                    );
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  interval: yInterval,
                  getTitlesWidget: (value, meta) => Text(
                    value.toInt().toString(),
                    style: GoogleFonts.inter(
                      color: colors.textSecondary,
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Bar Chart - Income vs Expense
class BarChartCard extends StatelessWidget {
  const BarChartCard({super.key, required this.data});

  final IncomeExpenseItem data;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;

    final rawMax = data.income > data.expense ? data.income : data.expense;

    final maxY = rawMax <= 0 ? 10.0 : (rawMax / 10).ceil() * 10.0 * 1.2;

    final yInterval = maxY / 4;

    if (data.income == 0 && data.expense == 0) {
      return const EmptyStateCard(
        title: 'No income or expense data',
        subtitle: 'No transactions found for this period.',
      );
    }

    return GlassPanel(
      child: SizedBox(
        height: 250,
        child: Padding(
          padding: const EdgeInsets.only(right: 16, top: 12),
          child: BarChart(
            BarChartData(
              minY: 0,
              maxY: maxY,

              alignment: BarChartAlignment.spaceAround,

              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: yInterval,
                getDrawingHorizontalLine: (value) =>
                    FlLine(color: colors.border, strokeWidth: 1),
              ),

              borderData: FlBorderData(show: false),

              barGroups: [
                BarChartGroupData(
                  x: 0,
                  barRods: [
                    BarChartRodData(
                      toY: data.income,
                      width: 50,
                      color: AppColors.success,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ],
                ),

                BarChartGroupData(
                  x: 1,
                  barRods: [
                    BarChartRodData(
                      toY: data.expense,
                      width: 50,
                      color: AppColors.danger,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ],
                ),
              ],

              titlesData: FlTitlesData(
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),

                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),

                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    interval: yInterval,
                    getTitlesWidget: (value, meta) => Text(
                      value.toInt().toString(),
                      style: GoogleFonts.inter(
                        color: colors.textSecondary,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),

                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      String label = '';

                      switch (value.toInt()) {
                        case 0:
                          label = 'Income';
                          break;
                        case 1:
                          label = 'Expense';
                          break;
                      }

                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          label,
                          style: GoogleFonts.inter(
                            color: colors.textSecondary,
                            fontSize: 10,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
