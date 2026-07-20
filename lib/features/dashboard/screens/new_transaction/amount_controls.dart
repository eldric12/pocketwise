part of '../new_transaction_screen.dart';

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
        color: context.themeColors.surface,
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
    final accent = expense ? AppColors.danger : AppColors.success;
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
              color: selected
                  ? accent.withValues(alpha: 0.15)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(11),
              border: Border.all(color: selected ? accent : Colors.transparent),
            ),
            child: Text(
              label,
              style: GoogleFonts.inter(
                color: selected ? accent : context.themeColors.textSecondary,
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
                ? Icon(
                    Icons.backspace_outlined,
                    size: 24,
                    color: context.themeColors.textSecondary,
                  )
                : Text(
                    value,
                    style: GoogleFonts.spaceMono(
                      color: context.themeColors.textPrimary,
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
