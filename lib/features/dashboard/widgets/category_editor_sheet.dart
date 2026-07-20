import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../models/category_definition.dart';
import '../utils/category_catalog.dart';

Future<CategoryDefinition?> showCategoryEditorSheet({
  required BuildContext context,
  required bool isExpense,
  required Set<String> existingNames,
  CategoryDefinition? initialCategory,
}) {
  return showModalBottomSheet<CategoryDefinition>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: context.themeColors.surface,
    barrierColor: Colors.black.withValues(alpha: 0.62),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (context) => _CategoryEditorSheet(
      isExpense: isExpense,
      existingNames: existingNames,
      initialCategory: initialCategory,
    ),
  );
}

class _CategoryEditorSheet extends StatefulWidget {
  const _CategoryEditorSheet({
    required this.isExpense,
    required this.existingNames,
    this.initialCategory,
  });

  final bool isExpense;
  final Set<String> existingNames;
  final CategoryDefinition? initialCategory;

  @override
  State<_CategoryEditorSheet> createState() => _CategoryEditorSheetState();
}

class _CategoryEditorSheetState extends State<_CategoryEditorSheet> {
  late final TextEditingController _nameController;
  late String _iconKey;
  late String _colorKey;
  String? _errorText;

  bool get _isEditing => widget.initialCategory != null;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialCategory;
    _nameController = TextEditingController(text: initial?.label ?? '');
    _iconKey = initial?.iconKey ?? 'category';
    _colorKey = initial?.colorKey ?? (widget.isExpense ? 'coral' : 'emerald');
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final preview = CategoryDefinition(
      id: widget.initialCategory?.id ?? 'preview',
      label: _nameController.text.trim().isEmpty
          ? 'New category'
          : _nameController.text.trim(),
      isExpense: widget.isExpense,
      iconKey: _iconKey,
      colorKey: _colorKey,
      isCustom: widget.initialCategory?.isCustom ?? true,
    );
    final visual = categoryAppearance(preview, Theme.of(context).brightness);

    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: context.themeColors.border,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _isEditing ? 'Edit category appearance' : 'Create category',
              style: GoogleFonts.inter(
                color: context.themeColors.textPrimary,
                fontSize: 21,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Choose an icon and color that will identify this category throughout PocketWise.',
              style: GoogleFonts.inter(
                color: context.themeColors.textSecondary,
                fontSize: 14,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: visual.background,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: visual.foreground.withValues(alpha: 0.5),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: visual.foreground.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      visual.icon,
                      color: visual.foreground,
                      size: 25,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      preview.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        color: context.themeColors.textPrimary,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Text(
                    widget.isExpense ? 'Expense' : 'Income',
                    style: GoogleFonts.inter(
                      color: visual.foreground,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nameController,
              autofocus: !_isEditing,
              readOnly: _isEditing,
              maxLength: 20,
              textCapitalization: TextCapitalization.words,
              style: GoogleFonts.inter(
                color: context.themeColors.textPrimary,
                fontSize: 16,
              ),
              decoration: InputDecoration(
                labelText: 'Category name',
                hintText: 'e.g. Health',
                helperText: _isEditing
                    ? 'Category names cannot be changed here.'
                    : null,
                errorText: _errorText,
                counterText: '',
                filled: true,
                fillColor: context.themeColors.background,
              ),
              onChanged: (_) {
                setState(() => _errorText = null);
              },
            ),
            const SizedBox(height: 24),
            _SectionLabel(label: 'Icon', value: _iconLabel(_iconKey)),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: categoryIconChoices.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 6,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
              ),
              itemBuilder: (context, index) {
                final choice = categoryIconChoices[index];
                final selected = choice.key == _iconKey;
                return Semantics(
                  button: true,
                  selected: selected,
                  label: '${choice.label} icon',
                  child: InkWell(
                    onTap: () => setState(() => _iconKey = choice.key),
                    borderRadius: BorderRadius.circular(14),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.primary.withValues(alpha: 0.14)
                            : context.themeColors.surfaceSoft,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: selected
                              ? AppColors.primary
                              : context.themeColors.border,
                          width: selected ? 1.5 : 1,
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(
                            choice.icon,
                            color: selected
                                ? AppColors.primary
                                : context.themeColors.textSecondary,
                            size: 23,
                          ),
                          if (selected)
                            const Positioned(
                              right: 3,
                              top: 3,
                              child: Icon(
                                Icons.check_circle_rounded,
                                size: 13,
                                color: AppColors.primary,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            _SectionLabel(label: 'Color', value: _colorLabel(_colorKey)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final choice in categoryColorChoices)
                  _ColorButton(
                    choice: choice,
                    selected: choice.key == _colorKey,
                    onTap: () => setState(() => _colorKey = choice.key),
                  ),
              ],
            ),
            const SizedBox(height: 28),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: _submit,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(_isEditing ? 'Save changes' : 'Add category'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _iconLabel(String key) {
    return categoryIconChoices.firstWhere((choice) => choice.key == key).label;
  }

  String _colorLabel(String key) {
    return categoryColorChoices.firstWhere((choice) => choice.key == key).label;
  }

  void _submit() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _errorText = 'Enter a category name.');
      return;
    }
    if (!_isEditing &&
        widget.existingNames.any(
          (existing) => existing.toLowerCase() == name.toLowerCase(),
        )) {
      setState(() => _errorText = 'This category already exists.');
      return;
    }

    final initial = widget.initialCategory;
    Navigator.pop(
      context,
      CategoryDefinition(
        id:
            initial?.id ??
            'custom_${DateTime.now().microsecondsSinceEpoch.toString()}',
        label: name,
        isExpense: widget.isExpense,
        iconKey: _iconKey,
        colorKey: _colorKey,
        isCustom: initial?.isCustom ?? true,
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            color: context.themeColors.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: GoogleFonts.inter(
            color: context.themeColors.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _ColorButton extends StatelessWidget {
  const _ColorButton({
    required this.choice,
    required this.selected,
    required this.onTap,
  });

  final CategoryColorChoice choice;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final checkColor = choice.accent.computeLuminance() > 0.48
        ? Colors.black
        : Colors.white;
    return Semantics(
      button: true,
      selected: selected,
      label: '${choice.label} color',
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: choice.accent,
            shape: BoxShape.circle,
            border: Border.all(
              color: selected
                  ? context.themeColors.textPrimary
                  : Colors.transparent,
              width: 3,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: choice.accent.withValues(alpha: 0.38),
                      blurRadius: 12,
                    ),
                  ]
                : null,
          ),
          child: selected
              ? Icon(Icons.check_rounded, color: checkColor, size: 23)
              : null,
        ),
      ),
    );
  }
}
