part of '../new_transaction_screen.dart';

class _AddCategoryCard extends StatelessWidget {
  const _AddCategoryCard({required this.accentColor, required this.onTap});

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
              border: Border.all(color: accentColor.withValues(alpha: 0.55)),
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
                    child: Icon(Icons.add_rounded, color: foreground, size: 25),
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

  final CategoryDefinition option;
  final bool selected;
  final Color accentColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final visual = categoryAppearance(option, Theme.of(context).brightness);
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
              color: selected ? visual.background : context.themeColors.surface,
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
                              ? visual.foreground.withValues(alpha: 0.14)
                              : visual.background,
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: Icon(
                          visual.icon,
                          size: 23,
                          color: selected
                              ? selectedForeground
                              : visual.foreground,
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
                            fontWeight: selected
                                ? FontWeight.w700
                                : FontWeight.w500,
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
