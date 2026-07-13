part of '../new_transaction_screen.dart';

class _AddCategoryDialog extends StatefulWidget {
  const _AddCategoryDialog({
    required this.existingNames,
    required this.accentColor,
  });

  final Set<String> existingNames;
  final Color accentColor;

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
      backgroundColor: context.themeColors.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: context.themeColors.border),
      ),
      title: Text(
        'Add category',
        style: GoogleFonts.inter(
          color: context.themeColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLength: 20,
        textCapitalization: TextCapitalization.words,
        style: GoogleFonts.inter(color: context.themeColors.textPrimary, fontSize: 16),
        decoration: InputDecoration(
          labelText: 'Category name',
          hintText: 'e.g. Health',
          errorText: _errorText,
          counterText: '',
          filled: true,
          fillColor: context.themeColors.background,
          labelStyle: GoogleFonts.inter(color: context.themeColors.textSecondary),
          hintStyle: GoogleFonts.inter(color: const Color(0xFF64748B)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: context.themeColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: widget.accentColor,
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
            backgroundColor: widget.accentColor,
            foregroundColor: AppColors.background,
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
  const _AddCategoryCard({
    required this.accentColor,
    required this.onTap,
  });

  final Color accentColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final foreground = Theme.of(context).brightness == Brightness.dark
        ? accentColor
        : Color.lerp(accentColor, Colors.black, 0.35)!;

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
              color: accentColor.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: accentColor.withValues(alpha: 0.55),
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
                      color: accentColor.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Icon(
                      Icons.add_rounded,
                      color: foreground,
                      size: 25,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Add category',
                    maxLines: 1,
                    style: GoogleFonts.inter(
                      color: foreground,
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
    required this.accentColor,
    required this.onTap,
  });

  final _CategoryOption option;
  final bool selected;
  final Color accentColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final selectedForeground = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Color.lerp(accentColor, Colors.black, 0.35)!;

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
                  ? accentColor.withValues(alpha: 0.1)
                  : context.themeColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: selected ? accentColor : context.themeColors.border,
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
                              ? accentColor.withValues(alpha: 0.12)
                              : const Color(0xFF253348),
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: Icon(
                          option.icon,
                          size: 23,
                          color: selected
                              ? selectedForeground
                              : context.themeColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          option.label,
                          maxLines: 1,
                          style: GoogleFonts.inter(
                            color: selected
                                ? selectedForeground
                                : context.themeColors.textSecondary,
                            fontSize: 14,
                            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (selected)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: CircleAvatar(
                      radius: 5,
                      backgroundColor: accentColor,
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
