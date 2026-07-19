import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../models/custom_category.dart';
import '../models/transaction.dart';
import '../providers/dashboard_provider.dart';

part 'new_transaction/amount_controls.dart';
part 'new_transaction/category_controls.dart';
part 'new_transaction/detail_controls.dart';

class NewTransactionScreen extends ConsumerStatefulWidget {
  const NewTransactionScreen({super.key, this.initialTransaction});

  final Transaction? initialTransaction;

  @override
  ConsumerState<NewTransactionScreen> createState() =>
      _NewTransactionScreenState();
}

class _NewTransactionScreenState extends ConsumerState<NewTransactionScreen> {
  late final TextEditingController _noteController;
  String _amountText = '0';
  bool _isExpense = true;
  String _category = 'Food';
  String _paymentMethod = 'Cash';
  DateTime _selectedDate = DateTime.now();
  bool _showAmountError = false;
  bool _isSaving = false;
  bool _isDeleting = false;
  bool _allowPop = false;
  bool _discardDialogOpen = false;

  final _expenseCategories = <_CategoryOption>[
    const _CategoryOption('Food', Icons.restaurant_rounded),
    const _CategoryOption('Transport', Icons.directions_car_filled_rounded),
    const _CategoryOption('Bills', Icons.receipt_long_rounded),
    const _CategoryOption('Entertainment', Icons.movie_outlined),
    const _CategoryOption('Shopping', Icons.shopping_bag_outlined),
    const _CategoryOption('Books', Icons.menu_book_rounded),
  ];

  final _incomeCategories = <_CategoryOption>[
    const _CategoryOption('Salary', Icons.account_balance_wallet_rounded),
    const _CategoryOption('Freelance', Icons.work_outline_rounded),
    const _CategoryOption('Gift', Icons.card_giftcard_rounded),
    const _CategoryOption('Refund', Icons.replay_rounded),
  ];

  @override
  void initState() {
    super.initState();
    final transaction = widget.initialTransaction;
    _noteController = TextEditingController(text: transaction?.note ?? '');
    _noteController.addListener(_handleNoteChanged);
    for (final category in ref.read(dashboardProvider).customCategories) {
      final options = category.isExpense
          ? _expenseCategories
          : _incomeCategories;
      if (!options.any(
        (option) => option.label.toLowerCase() == category.label.toLowerCase(),
      )) {
        options.add(_CategoryOption(category.label, Icons.category_outlined));
      }
    }
    if (transaction == null) return;

    _amountText = transaction.amount.toStringAsFixed(2);
    _isExpense = transaction.isExpense;
    _category = transaction.categoryLabel;
    _paymentMethod = transaction.paymentMethod;
    _selectedDate = transaction.date;

    final categories = transaction.isExpense
        ? _expenseCategories
        : _incomeCategories;
    if (!categories.any(
      (option) => option.label == transaction.categoryLabel,
    )) {
      categories.add(
        _CategoryOption(transaction.categoryLabel, Icons.category_outlined),
      );
    }
  }

  @override
  void dispose() {
    _noteController.removeListener(_handleNoteChanged);
    _noteController.dispose();
    super.dispose();
  }

  void _handleNoteChanged() {
    if (_isEditing && mounted) setState(() {});
  }

  List<_CategoryOption> get _categories =>
      _isExpense ? _expenseCategories : _incomeCategories;

  double get _amount => double.tryParse(_amountText) ?? 0;

  Color get _transactionAccent =>
      _isExpense ? AppColors.danger : AppColors.success;

  Color _transactionTextAccent(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.dark) {
      return _transactionAccent;
    }
    return Color.lerp(_transactionAccent, Colors.black, 0.35)!;
  }

  bool get _isEditing => widget.initialTransaction != null;
  bool get _isBusy => _isSaving || _isDeleting;

  bool get _hasUnsavedChanges {
    final initial = widget.initialTransaction;
    if (initial == null) return false;
    return _amount != initial.amount ||
        _isExpense != initial.isExpense ||
        _category != initial.categoryLabel ||
        _paymentMethod != initial.paymentMethod ||
        _selectedDate != initial.date ||
        _noteController.text.trim() != initial.note;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<void>(
      canPop: _allowPop || !_hasUnsavedChanges,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _requestClose();
      },
      child: Scaffold(
        backgroundColor: context.themeColors.background,
        body: SafeArea(
          child: CustomScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            slivers: [
              SliverToBoxAdapter(child: _buildHeader()),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 30, 16, 40),
                sliver: SliverList.list(
                  children: [
                    _TransactionTypeToggle(
                      isExpense: _isExpense,
                      onChanged: _changeTransactionType,
                    ),
                    const SizedBox(height: 30),
                    _buildAmountPanel(),
                    const SizedBox(height: 30),
                    _SectionLabel(
                      text: _isExpense ? 'SELECT CATEGORY' : 'INCOME SOURCE',
                      accentColor: _transactionTextAccent(context),
                    ),
                    const SizedBox(height: 12),
                    _buildCategoryGrid(),
                    const SizedBox(height: 30),
                    _SectionLabel(
                      text: 'ADDITIONAL DETAILS',
                      accentColor: _transactionTextAccent(context),
                    ),
                    const SizedBox(height: 12),
                    _DetailTile(
                      icon: Icons.calendar_today_outlined,
                      label: 'DATE',
                      value: _formatDate(_selectedDate),
                      trailing: Icons.calendar_month_outlined,
                      onTap: _pickDate,
                    ),
                    const SizedBox(height: 12),
                    _PaymentMethodDropdown(
                      value: _paymentMethod,
                      onChanged: (value) {
                        HapticFeedback.selectionClick();
                        setState(() => _paymentMethod = value);
                      },
                    ),
                    const SizedBox(height: 12),
                    _MemoField(controller: _noteController),
                    const SizedBox(height: 34),
                    _buildConfirmButton(),
                    if (_isEditing) ...[
                      const SizedBox(height: 14),
                      _buildDeleteButton(),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 20, 20),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: context.themeColors.border)),
      ),
      child: Row(
        children: [
          Semantics(
            button: true,
            label: 'Close new transaction',
            child: Material(
              color: context.themeColors.surface,
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                onTap: _isBusy ? null : _requestClose,
                borderRadius: BorderRadius.circular(14),
                child: SizedBox(
                  width: 50,
                  height: 50,
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 19,
                    color: context.themeColors.textPrimary,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 24),
          Text(
            _isEditing ? 'EDIT TRANSACTION' : 'NEW TRANSACTION',
            style: GoogleFonts.inter(
              color: context.themeColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.7,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountPanel() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.fromLTRB(16, 30, 16, 18),
      decoration: BoxDecoration(
        color: context.themeColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: _showAmountError
              ? AppColors.danger.withValues(alpha: 0.8)
              : context.themeColors.border,
        ),
      ),
      child: Column(
        children: [
          _SectionLabel(
            text: 'ENTER AMOUNT',
            centered: true,
            accentColor: _transactionTextAccent(context),
          ),
          const SizedBox(height: 12),
          Semantics(
            liveRegion: true,
            label: 'Amount RM ${_amount.toStringAsFixed(2)}',
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'RM',
                  style: GoogleFonts.spaceGrotesk(
                    color: _transactionTextAccent(context),
                    fontSize: 29,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 28),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 160),
                  transitionBuilder: (child, animation) =>
                      FadeTransition(opacity: animation, child: child),
                  child: Text(
                    _amount.toStringAsFixed(2),
                    key: ValueKey(_amountText),
                    style: GoogleFonts.spaceMono(
                      color: context.themeColors.textPrimary,
                      fontSize: 42,
                      fontWeight: FontWeight.w700,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
              ],
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 180),
            child: _showAmountError
                ? Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Enter an amount greater than RM 0.00',
                      style: GoogleFonts.inter(
                        color: AppColors.danger,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          const SizedBox(height: 20),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 300),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 12,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 2,
                  crossAxisSpacing: 10,
                  childAspectRatio: 1.8,
                ),
                itemBuilder: (context, index) {
                  const keys = [
                    '1',
                    '2',
                    '3',
                    '4',
                    '5',
                    '6',
                    '7',
                    '8',
                    '9',
                    '0',
                    '.',
                    'backspace',
                  ];
                  return _KeypadButton(
                    value: keys[index],
                    onPressed: () => _handleKeypadInput(keys[index]),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _categories.length + 1,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.02,
      ),
      itemBuilder: (context, index) {
        if (index == _categories.length) {
          return _AddCategoryCard(
            accentColor: _transactionAccent,
            onTap: _addCategory,
          );
        }
        final option = _categories[index];
        return _CategoryCard(
          option: option,
          selected: _category == option.label,
          accentColor: _transactionAccent,
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() => _category = option.label);
          },
        );
      },
    );
  }

  Future<void> _addCategory() async {
    final name = await showDialog<String>(
      context: context,
      builder: (context) => _AddCategoryDialog(
        existingNames: _categories.map((category) => category.label).toSet(),
        accentColor: _transactionAccent,
      ),
    );

    if (name == null || !mounted) return;
    final option = _CategoryOption(name, Icons.category_outlined);
    try {
      await ref
          .read(dashboardProvider.notifier)
          .addCustomCategory(
            CustomCategory(label: name, isExpense: _isExpense),
          );
    } catch (_) {
      if (!mounted) return;
      _showError('Unable to save this category. Please try again.');
      return;
    }
    if (!mounted) return;
    HapticFeedback.mediumImpact();
    setState(() {
      _categories.add(option);
      _category = name;
    });
  }

  Widget _buildConfirmButton() {
    return SizedBox(
      width: double.infinity,
      height: 64,
      child: FilledButton.icon(
        onPressed: _isBusy ? null : _saveTransaction,
        icon: _isSaving
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  color: AppColors.background,
                ),
              )
            : const Icon(Icons.check_rounded, size: 22),
        label: Text(
          _isSaving
              ? 'Saving...'
              : _isEditing
              ? 'Save changes'
              : 'Confirm transaction',
          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        style: FilledButton.styleFrom(
          backgroundColor: _transactionAccent,
          foregroundColor: AppColors.background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
      ),
    );
  }

  Widget _buildDeleteButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: OutlinedButton.icon(
        onPressed: _isBusy ? null : _confirmDelete,
        icon: _isDeleting
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.danger,
                ),
              )
            : const Icon(Icons.delete_outline_rounded, size: 21),
        label: Text(_isDeleting ? 'Deleting...' : 'Delete transaction'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.danger,
          side: BorderSide(color: AppColors.danger.withValues(alpha: 0.55)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  void _changeTransactionType(bool isExpense) {
    if (_isExpense == isExpense) return;
    HapticFeedback.selectionClick();
    setState(() {
      _isExpense = isExpense;
      _category = isExpense
          ? _expenseCategories.first.label
          : _incomeCategories.first.label;
    });
  }

  void _handleKeypadInput(String value) {
    HapticFeedback.selectionClick();
    setState(() {
      _showAmountError = false;
      if (value == 'backspace') {
        _amountText = _amountText.length <= 1
            ? '0'
            : _amountText.substring(0, _amountText.length - 1);
        return;
      }
      if (value == '.') {
        if (!_amountText.contains('.')) _amountText += '.';
        return;
      }
      final decimalIndex = _amountText.indexOf('.');
      if (decimalIndex != -1 && _amountText.length - decimalIndex > 2) return;
      final wholeDigits = decimalIndex == -1
          ? _amountText.length
          : decimalIndex;
      if (wholeDigits >= 7 && decimalIndex == -1) return;
      _amountText = _amountText == '0' ? value : '$_amountText$value';
    });
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(
            primary: AppColors.primary,
            surface: context.themeColors.surface,
          ),
        ),
        child: child!,
      ),
    );
    if (date != null && mounted) setState(() => _selectedDate = date);
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Future<void> _saveTransaction() async {
    if (_amount <= 0) {
      HapticFeedback.mediumImpact();
      setState(() => _showAmountError = true);
      return;
    }

    final note = _noteController.text.trim();
    final title = note.isEmpty
        ? (_isExpense ? '$_category expense' : '$_category income')
        : note;
    final initial = widget.initialTransaction;
    final transaction = initial == null
        ? Transaction(
            id: DateTime.now().microsecondsSinceEpoch.toString(),
            title: title,
            amount: _amount,
            date: _selectedDate,
            categoryId: _category.toLowerCase().replaceAll(' ', '_'),
            categoryLabel: _category,
            paymentMethod: _paymentMethod,
            note: note,
            isExpense: _isExpense,
          )
        : initial.copyWith(
            title: title,
            amount: _amount,
            date: _selectedDate,
            categoryId: _category.toLowerCase().replaceAll(' ', '_'),
            categoryLabel: _category,
            paymentMethod: _paymentMethod,
            note: note,
            isExpense: _isExpense,
          );

    setState(() => _isSaving = true);
    try {
      final notifier = ref.read(dashboardProvider.notifier);
      if (_isEditing) {
        await notifier.updateTransaction(transaction);
      } else {
        await notifier.addTransaction(transaction);
      }
      if (!mounted) return;
      HapticFeedback.mediumImpact();
      setState(() {
        _isSaving = false;
        _allowPop = true;
      });
      await Future<void>.delayed(Duration.zero);
      if (mounted) Navigator.of(context).pop(transaction);
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      _showError('Unable to save this transaction. Please try again.');
    }
  }

  Future<void> _requestClose() async {
    if (_isBusy || _discardDialogOpen) return;
    if (!_hasUnsavedChanges) {
      Navigator.of(context).pop();
      return;
    }

    _discardDialogOpen = true;
    final shouldDiscard = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: dialogContext.themeColors.surface,
        surfaceTintColor: Colors.transparent,
        title: const Text('Discard changes?'),
        content: const Text(
          'Your edits have not been saved. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Keep editing'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: AppColors.background,
            ),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
    _discardDialogOpen = false;

    if (shouldDiscard != true || !mounted) return;
    setState(() => _allowPop = true);
    await Future<void>.delayed(Duration.zero);
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _confirmDelete() async {
    final transaction = widget.initialTransaction;
    if (transaction == null) return;

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: dialogContext.themeColors.surface,
        surfaceTintColor: Colors.transparent,
        title: const Text('Delete transaction?'),
        content: Text(
          '"${transaction.title}" will be permanently removed from your records.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            icon: const Icon(Icons.delete_outline_rounded, size: 19),
            label: const Text('Delete'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: AppColors.background,
            ),
          ),
        ],
      ),
    );

    if (shouldDelete != true || !mounted) return;
    setState(() => _isDeleting = true);
    try {
      await ref
          .read(dashboardProvider.notifier)
          .deleteTransaction(transaction.id);
      if (!mounted) return;
      HapticFeedback.mediumImpact();
      setState(() {
        _isDeleting = false;
        _allowPop = true;
      });
      await Future<void>.delayed(Duration.zero);
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      setState(() => _isDeleting = false);
      _showError('Unable to delete this transaction. Please try again.');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}
