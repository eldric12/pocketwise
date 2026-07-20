part of '../dashboard_tabs.dart';

enum _TransactionTypeFilter { all, income, expense }

enum _DateRangeFilter { allDates, today, pastSevenDays, thisMonth }

const _allCategoriesFilter = '__all_categories__';

class ActivityTab extends StatefulWidget {
  const ActivityTab({
    super.key,
    required this.transactions,
    required this.categories,
    required this.onTransactionTap,
  });

  final List<Transaction> transactions;
  final List<CategoryDefinition> categories;
  final ValueChanged<Transaction> onTransactionTap;

  @override
  State<ActivityTab> createState() => _ActivityTabState();
}

class _ActivityTabState extends State<ActivityTab> {
  late final ScrollController _filterScrollController;
  _TransactionTypeFilter _typeFilter = _TransactionTypeFilter.all;
  _DateRangeFilter _dateFilter = _DateRangeFilter.allDates;
  String _categoryFilter = _allCategoriesFilter;
  bool _newestFirst = true;

  @override
  void initState() {
    super.initState();
    _filterScrollController = ScrollController();
  }

  @override
  void didUpdateWidget(covariant ActivityTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_categoryFilter != _allCategoriesFilter &&
        !widget.transactions.any(
          (transaction) => transaction.categoryLabel == _categoryFilter,
        )) {
      _categoryFilter = _allCategoriesFilter;
    }
  }

  @override
  void dispose() {
    _filterScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories =
        widget.transactions
            .map((transaction) => transaction.categoryLabel.trim())
            .where((category) => category.isNotEmpty)
            .toSet()
            .toList()
          ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
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
          SizedBox(
            height: 54,
            child: ScrollbarTheme(
              data: ScrollbarTheme.of(context).copyWith(
                thumbColor: WidgetStatePropertyAll(context.themeColors.border),
                thickness: const WidgetStatePropertyAll(4),
                radius: const Radius.circular(99),
              ),
              child: Scrollbar(
                controller: _filterScrollController,
                thumbVisibility: true,
                scrollbarOrientation: ScrollbarOrientation.bottom,
                child: SingleChildScrollView(
                  controller: _filterScrollController,
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      FilterChipCard(
                        label: 'All',
                        horizontalPadding: 12,
                        selected: _typeFilter == _TransactionTypeFilter.all,
                        onTap: () => _setTypeFilter(_TransactionTypeFilter.all),
                      ),
                      const SizedBox(width: 8),
                      FilterChipCard(
                        label: 'Income',
                        horizontalPadding: 12,
                        selected: _typeFilter == _TransactionTypeFilter.income,
                        onTap: () =>
                            _setTypeFilter(_TransactionTypeFilter.income),
                      ),
                      const SizedBox(width: 8),
                      FilterChipCard(
                        label: 'Expense',
                        horizontalPadding: 12,
                        selected: _typeFilter == _TransactionTypeFilter.expense,
                        onTap: () =>
                            _setTypeFilter(_TransactionTypeFilter.expense),
                      ),
                      const SizedBox(width: 8),
                      _DateRangeMenu(
                        value: _dateFilter,
                        onChanged: (value) {
                          if (value == _dateFilter) return;
                          HapticFeedback.selectionClick();
                          setState(() => _dateFilter = value);
                        },
                      ),
                      const SizedBox(width: 8),
                      _CategoryFilterMenu(
                        value: _categoryFilter,
                        categories: categories,
                        categoryDefinitions: widget.categories,
                        onChanged: (value) {
                          if (value == _categoryFilter) return;
                          HapticFeedback.selectionClick();
                          setState(() => _categoryFilter = value);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
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
                categories: widget.categories,
                onTransactionTap: widget.onTransactionTap,
              ),
              if (i != groupedTransactions.length - 1)
                const SizedBox(height: 18),
            ],
        ],
      ),
    );
  }

  void _setTypeFilter(_TransactionTypeFilter filter) {
    if (_typeFilter == filter) return;
    setState(() => _typeFilter = filter);
  }

  List<Transaction> _filteredTransactions() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final sevenDayStart = today.subtract(const Duration(days: 6));
    final filtered = widget.transactions.where((transaction) {
      final matchesType = switch (_typeFilter) {
        _TransactionTypeFilter.all => true,
        _TransactionTypeFilter.income => !transaction.isExpense,
        _TransactionTypeFilter.expense => transaction.isExpense,
      };
      if (!matchesType) return false;
      if (_categoryFilter != _allCategoriesFilter &&
          transaction.categoryLabel != _categoryFilter) {
        return false;
      }

      final transactionDay = DateTime(
        transaction.date.year,
        transaction.date.month,
        transaction.date.day,
      );
      return switch (_dateFilter) {
        _DateRangeFilter.allDates => true,
        _DateRangeFilter.today => transactionDay == today,
        _DateRangeFilter.pastSevenDays =>
          !transactionDay.isBefore(sevenDayStart) &&
              !transactionDay.isAfter(today),
        _DateRangeFilter.thisMonth =>
          transaction.date.year == now.year &&
              transaction.date.month == now.month,
      };
    }).toList();

    filtered.sort(
      (a, b) =>
          _newestFirst ? b.date.compareTo(a.date) : a.date.compareTo(b.date),
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

class _DateRangeMenu extends StatelessWidget {
  const _DateRangeMenu({required this.value, required this.onChanged});

  final _DateRangeFilter value;
  final ValueChanged<_DateRangeFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    final isDateFiltered = value != _DateRangeFilter.allDates;

    return PopupMenuButton<_DateRangeFilter>(
      initialValue: value,
      onSelected: onChanged,
      tooltip: 'Filter transactions by date',
      color: context.themeColors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 12,
      position: PopupMenuPosition.under,
      offset: const Offset(0, 6),
      constraints: const BoxConstraints(minWidth: 190),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: context.themeColors.border),
      ),
      itemBuilder: (context) => _DateRangeFilter.values
          .map(
            (filter) => PopupMenuItem<_DateRangeFilter>(
              value: filter,
              height: 48,
              child: Row(
                children: [
                  Icon(
                    _iconFor(filter),
                    size: 20,
                    color: filter == value
                        ? AppColors.primary
                        : context.themeColors.textSecondary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _labelFor(filter),
                      style: GoogleFonts.inter(
                        color: context.themeColors.textPrimary,
                        fontSize: 14,
                        fontWeight: filter == value
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                  if (filter == value)
                    const Icon(
                      Icons.check_rounded,
                      size: 19,
                      color: AppColors.primary,
                    ),
                ],
              ),
            ),
          )
          .toList(),
      child: Semantics(
        button: true,
        label: 'Date filter: ${_labelFor(value)}',
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
          decoration: BoxDecoration(
            color: isDateFiltered
                ? AppColors.primary.withValues(alpha: 0.12)
                : context.themeColors.surfaceSoft,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDateFiltered
                  ? AppColors.primary.withValues(alpha: 0.55)
                  : context.themeColors.border,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _labelFor(value),
                style: GoogleFonts.inter(
                  color: isDateFiltered
                      ? Theme.of(context).colorScheme.primary
                      : context.themeColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 18,
                color: isDateFiltered
                    ? Theme.of(context).colorScheme.primary
                    : context.themeColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _labelFor(_DateRangeFilter filter) => switch (filter) {
    _DateRangeFilter.allDates => 'All dates',
    _DateRangeFilter.today => 'Today',
    _DateRangeFilter.pastSevenDays => 'Past 7 days',
    _DateRangeFilter.thisMonth => 'This month',
  };

  IconData _iconFor(_DateRangeFilter filter) => switch (filter) {
    _DateRangeFilter.allDates => Icons.calendar_month_outlined,
    _DateRangeFilter.today => Icons.today_outlined,
    _DateRangeFilter.pastSevenDays => Icons.date_range_outlined,
    _DateRangeFilter.thisMonth => Icons.calendar_view_month_outlined,
  };
}

class _CategoryFilterMenu extends StatelessWidget {
  const _CategoryFilterMenu({
    required this.value,
    required this.categories,
    required this.categoryDefinitions,
    required this.onChanged,
  });

  final String value;
  final List<String> categories;
  final List<CategoryDefinition> categoryDefinitions;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final options = [_allCategoriesFilter, ...categories];
    final isCategoryFiltered = value != _allCategoriesFilter;

    return PopupMenuButton<String>(
      initialValue: value,
      onSelected: onChanged,
      tooltip: 'Filter transactions by category',
      color: context.themeColors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 12,
      position: PopupMenuPosition.under,
      offset: const Offset(0, 6),
      constraints: const BoxConstraints(minWidth: 210, maxWidth: 280),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: context.themeColors.border),
      ),
      itemBuilder: (context) => options
          .map(
            (category) => PopupMenuItem<String>(
              value: category,
              height: 48,
              child: Row(
                children: [
                  Icon(
                    _iconFor(context, category),
                    size: 20,
                    color: category == value
                        ? AppColors.primary
                        : context.themeColors.textSecondary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _labelFor(category),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        color: context.themeColors.textPrimary,
                        fontSize: 14,
                        fontWeight: category == value
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                  if (category == value)
                    const Icon(
                      Icons.check_rounded,
                      size: 19,
                      color: AppColors.primary,
                    ),
                ],
              ),
            ),
          )
          .toList(),
      child: Semantics(
        button: true,
        label: 'Category filter: ${_labelFor(value)}',
        child: Container(
          constraints: const BoxConstraints(maxWidth: 180),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          decoration: BoxDecoration(
            color: isCategoryFiltered
                ? AppColors.primary.withValues(alpha: 0.12)
                : context.themeColors.surfaceSoft,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isCategoryFiltered
                  ? AppColors.primary.withValues(alpha: 0.55)
                  : context.themeColors.border,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  _labelFor(value),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    color: isCategoryFiltered
                        ? Theme.of(context).colorScheme.primary
                        : context.themeColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 18,
                color: isCategoryFiltered
                    ? Theme.of(context).colorScheme.primary
                    : context.themeColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _labelFor(String category) =>
      category == _allCategoriesFilter ? 'All categories' : category;

  IconData _iconFor(BuildContext context, String category) {
    if (category == _allCategoriesFilter) return Icons.category_outlined;
    return categoryVisual(
      category,
      categories: categoryDefinitions,
      brightness: Theme.of(context).brightness,
    ).icon;
  }
}
