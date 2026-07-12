import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../models/transaction.dart';
import '../providers/dashboard_provider.dart';

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
    _CategoryOption('Food', Icons.restaurant_rounded),
    _CategoryOption('Transport', Icons.directions_car_filled_rounded),
    _CategoryOption('Bills', Icons.receipt_long_rounded),
    _CategoryOption('Entertainment', Icons.movie_outlined),
    _CategoryOption('Shopping', Icons.shopping_bag_outlined),
    _CategoryOption('Books', Icons.menu_book_rounded),
  ];

  final _incomeCategories = <_CategoryOption>[
    _CategoryOption('Salary', Icons.account_balance_wallet_rounded),
    _CategoryOption('Freelance', Icons.work_outline_rounded),
    _CategoryOption('Gift', Icons.card_giftcard_rounded),
    _CategoryOption('Refund', Icons.replay_rounded),
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

class _TransactionTypeToggle extends StatelessWidget {
  const _TransactionTypeToggle({
    required this.isExpense,
    required this.onChanged,
  });

  final bool isExpense;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: _TypeButton(
              label: 'EXPENSE',
              selected: isExpense,
              expense: true,
              onTap: () => onChanged(true),
            ),
          ),
          Expanded(
            child: _TypeButton(
              label: 'INCOME',
              selected: !isExpense,
              expense: false,
              onTap: () => onChanged(false),
            ),
          ),
        ],
      ),
    );
  }
}

class _TypeButton extends StatelessWidget {
  const _TypeButton({
    required this.label,
    required this.selected,
    required this.expense,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool expense;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = expense ? const Color(0xFFFF5D7A) : AppColors.success;
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(11),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected ? accent.withValues(alpha: 0.15) : Colors.transparent,
              borderRadius: BorderRadius.circular(11),
              border: Border.all(color: selected ? accent : Colors.transparent),
            ),
            child: Text(
              label,
              style: GoogleFonts.inter(
                color: selected ? accent : const Color(0xFF91A8CC),
                fontSize: 14,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _KeypadButton extends StatelessWidget {
  const _KeypadButton({required this.value, required this.onPressed});

  final String value;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final isBackspace = value == 'backspace';
    return Semantics(
      button: true,
      label: isBackspace ? 'Delete digit' : value,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onPressed,
          splashColor: AppColors.primary.withValues(alpha: 0.16),
          highlightColor: AppColors.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          child: Center(
            child: isBackspace
                ? const Icon(
                    Icons.backspace_outlined,
                    size: 24,
                    color: Color(0xFFC7D3E6),
                  )
                : Text(
                    value,
                    style: GoogleFonts.spaceMono(
                      color: Colors.white,
                      fontSize: 23,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class _AddCategoryDialog extends StatefulWidget {
  const _AddCategoryDialog({required this.existingNames});

  final Set<String> existingNames;

  @override
  State<_AddCategoryDialog> createState() => _AddCategoryDialogState();
}

class _AddCategoryDialogState extends State<_AddCategoryDialog> {
  late final TextEditingController _controller;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFF33435B)),
      ),
      title: Text(
        'Add category',
        style: GoogleFonts.inter(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLength: 20,
        textCapitalization: TextCapitalization.words,
        style: GoogleFonts.inter(color: Colors.white, fontSize: 16),
        decoration: InputDecoration(
          labelText: 'Category name',
          hintText: 'e.g. Health',
          errorText: _errorText,
          counterText: '',
          filled: true,
          fillColor: AppColors.background,
          labelStyle: GoogleFonts.inter(color: AppColors.mutedText),
          hintStyle: GoogleFonts.inter(color: const Color(0xFF64748B)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF3A4960)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: AppColors.primary,
              width: 1.5,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.danger),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.danger),
          ),
        ),
        onChanged: (_) {
          if (_errorText != null) setState(() => _errorText = null);
        },
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          child: const Text('Add category'),
        ),
      ],
    );
  }

  void _submit() {
    final name = _controller.text.trim();
    if (name.isEmpty) {
      setState(() => _errorText = 'Enter a category name.');
      return;
    }
    final alreadyExists = widget.existingNames.any(
      (existingName) => existingName.toLowerCase() == name.toLowerCase(),
    );
    if (alreadyExists) {
      setState(() => _errorText = 'This category already exists.');
      return;
    }
    Navigator.pop(context, name);
  }
}

class _AddCategoryCard extends StatelessWidget {
  const _AddCategoryCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Add a new category',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.55),
              ),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: const Icon(
                      Icons.add_rounded,
                      color: AppColors.primary,
                      size: 25,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Add category',
                    maxLines: 1,
                    style: GoogleFonts.inter(
                      color: const Color(0xFFA9B8FF),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final _CategoryOption option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: '${option.label} category',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: selected
                  ? AppColors.primary.withValues(alpha: 0.1)
                  : AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: selected ? AppColors.success : const Color(0xFF243249),
              ),
            ),
            child: Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.success.withValues(alpha: 0.12)
                              : const Color(0xFF253348),
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: Icon(
                          option.icon,
                          size: 23,
                          color: selected ? Colors.white : const Color(0xFF93A7C5),
                        ),
                      ),
                      const SizedBox(height: 10),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          option.label,
                          maxLines: 1,
                          style: GoogleFonts.inter(
                            color: selected ? Colors.white : const Color(0xFF9AB8E4),
                            fontSize: 14,
                            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (selected)
                  const Positioned(
                    right: 0,
                    top: 0,
                    child: CircleAvatar(
                      radius: 5,
                      backgroundColor: AppColors.success,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PaymentMethodDropdown extends StatelessWidget {
  const _PaymentMethodDropdown({
    required this.value,
    required this.onChanged,
  });

  final String value;
  final ValueChanged<String> onChanged;

  static const _methods = ['Cash', 'E-wallet', 'Card', 'Bank transfer'];

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 80),
      padding: const EdgeInsets.fromLTRB(18, 14, 8, 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: const Color(0xFF243249)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
            const Icon(
              Icons.credit_card_rounded,
              color: Color(0xFF91A6C5),
              size: 24,
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'PAYMENT METHOD',
                    style: GoogleFonts.inter(
                      color: const Color(0xFF7898C6),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.7,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    value,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              initialValue: value,
              onSelected: onChanged,
              tooltip: 'Select payment method',
              color: const Color(0xFF243249),
              surfaceTintColor: Colors.transparent,
              elevation: 12,
              position: PopupMenuPosition.under,
              offset: const Offset(0, 4),
              constraints: const BoxConstraints(minWidth: 220),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: const BorderSide(color: Color(0xFF33435B)),
              ),
              itemBuilder: (context) => _methods
                  .map(
                    (method) => PopupMenuItem<String>(
                      value: method,
                      height: 52,
                      child: Row(
                        children: [
                          Icon(
                            _iconFor(method),
                            size: 21,
                            color: method == value
                                ? AppColors.primary
                                : const Color(0xFF9AAEC9),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              method,
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (method == value)
                            const Icon(
                              Icons.check_rounded,
                              size: 20,
                              color: AppColors.primary,
                            ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
              child: const SizedBox(
                width: 48,
                height: 48,
                child: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Color(0xFFC8D4E7),
                  size: 24,
                ),
              ),
            ),
        ],
      ),
    );
  }

  IconData _iconFor(String method) => switch (method) {
        'Cash' => Icons.payments_outlined,
        'E-wallet' => Icons.account_balance_wallet_outlined,
        'Card' => Icons.credit_card_rounded,
        _ => Icons.account_balance_outlined,
      };
}

class _DetailTile extends StatelessWidget {
  const _DetailTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.trailing,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final IconData trailing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          constraints: const BoxConstraints(minHeight: 80),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFF243249)),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(icon, color: const Color(0xFF91A6C5), size: 24),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.inter(
                        color: const Color(0xFF7898C6),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.7,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      value,
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(trailing, color: const Color(0xFFC8D4E7), size: 21),
            ],
          ),
        ),
      ),
    );
  }
}

class _MemoField extends StatelessWidget {
  const _MemoField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 88),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF243249)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 12),
            child: Icon(
              Icons.note_alt_outlined,
              color: Color(0xFF91A6C5),
              size: 24,
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: TextField(
              controller: controller,
              maxLength: 80,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                labelText: 'MEMO / NOTES',
                labelStyle: GoogleFonts.inter(
                  color: const Color(0xFF7898C6),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                ),
                hintText: 'e.g. Lunch, groceries, monthly pay',
                hintStyle: GoogleFonts.inter(
                  color: const Color(0xFF587091),
                  fontSize: 15,
                ),
                counterText: '',
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text, this.centered = false});

  final String text;
  final bool centered;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: centered ? Alignment.center : Alignment.centerLeft,
      child: Text(
        text,
        style: GoogleFonts.inter(
          color: const Color(0xFF8FB3E8),
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _CategoryOption {
  const _CategoryOption(this.label, this.icon);

  final String label;
  final IconData icon;
}
