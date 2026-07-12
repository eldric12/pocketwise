import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../models/transaction.dart';
import '../providers/dashboard_provider.dart';

part 'new_transaction/amount_controls.dart';
part 'new_transaction/category_controls.dart';
part 'new_transaction/detail_controls.dart';

class NewTransactionScreen extends ConsumerStatefulWidget {
  const NewTransactionScreen({super.key});

  @override
  ConsumerState<NewTransactionScreen> createState() =>
      _NewTransactionScreenState();
}

class _NewTransactionScreenState
    extends ConsumerState<NewTransactionScreen> {
  final _noteController = TextEditingController();
  String _amountText = '0';
  bool _isExpense = true;
  String _category = 'Food';
  String _paymentMethod = 'Cash';
  DateTime _selectedDate = DateTime.now();
  bool _showAmountError = false;

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
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  List<_CategoryOption> get _categories =>
      _isExpense ? _expenseCategories : _incomeCategories;

  double get _amount => double.tryParse(_amountText) ?? 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
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
                  ),
                  const SizedBox(height: 12),
                  _buildCategoryGrid(),
                  const SizedBox(height: 30),
                  const _SectionLabel(text: 'ADDITIONAL DETAILS'),
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 20, 20),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFF26344A))),
      ),
      child: Row(
        children: [
          Semantics(
            button: true,
            label: 'Close new transaction',
            child: Material(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                onTap: () => Navigator.of(context).pop(),
                borderRadius: BorderRadius.circular(14),
                child: const SizedBox(
                  width: 50,
                  height: 50,
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 19,
                    color: Color(0xFFC8D4E7),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 24),
          Text(
            'NEW TRANSACTION',
            style: GoogleFonts.inter(
              color: Colors.white,
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
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: _showAmountError
              ? AppColors.danger.withValues(alpha: 0.8)
              : const Color(0xFF28364C),
        ),
      ),
      child: Column(
        children: [
          const _SectionLabel(text: 'ENTER AMOUNT', centered: true),
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
                    color: _isExpense
                        ? const Color(0xFFFF5D7A)
                        : AppColors.success,
                    fontSize: 29,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 28),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 160),
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: child,
                  ),
                  child: Text(
                    _amount.toStringAsFixed(2),
                    key: ValueKey(_amountText),
                    style: GoogleFonts.spaceMono(
                      color: Colors.white,
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
                  const keys = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '.', 'backspace'];
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
          return _AddCategoryCard(onTap: _addCategory);
        }
        final option = _categories[index];
        return _CategoryCard(
          option: option,
          selected: _category == option.label,
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
      ),
    );

    if (name == null || !mounted) return;
    HapticFeedback.mediumImpact();
    setState(() {
      final option = _CategoryOption(name, Icons.category_outlined);
      _categories.add(option);
      _category = name;
    });
  }

  Widget _buildConfirmButton() {
    final accent = _isExpense ? AppColors.primary : AppColors.success;
    return SizedBox(
      width: double.infinity,
      height: 64,
      child: FilledButton.icon(
        onPressed: _saveTransaction,
        icon: const Icon(Icons.check_rounded, size: 22),
        label: Text(
          'Confirm transaction',
          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        style: FilledButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: _isExpense ? Colors.white : AppColors.background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
      ),
    );
  }

  void _changeTransactionType(bool isExpense) {
    if (_isExpense == isExpense) return;
    HapticFeedback.selectionClick();
    setState(() {
      _isExpense = isExpense;
      _category = isExpense ? _expenseCategories.first.label : _incomeCategories.first.label;
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
      final wholeDigits = decimalIndex == -1 ? _amountText.length : decimalIndex;
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
          colorScheme: const ColorScheme.dark(
            primary: AppColors.primary,
            surface: AppColors.surface,
          ),
        ),
        child: child!,
      ),
    );
    if (date != null && mounted) setState(() => _selectedDate = date);
  }

  String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  void _saveTransaction() {
    if (_amount <= 0) {
      HapticFeedback.mediumImpact();
      setState(() => _showAmountError = true);
      return;
    }

    final note = _noteController.text.trim();
    ref.read(dashboardProvider.notifier).addTransaction(
          Transaction(
            id: DateTime.now().microsecondsSinceEpoch.toString(),
            title: note.isEmpty
                ? (_isExpense ? '$_category expense' : '$_category income')
                : note,
            amount: _amount,
            date: _selectedDate,
            categoryId: _category.toLowerCase().replaceAll(' ', '_'),
            categoryLabel: _category,
            paymentMethod: _paymentMethod,
            note: note,
            isExpense: _isExpense,
          ),
        );
    HapticFeedback.mediumImpact();
    Navigator.of(context).pop();
  }
}
