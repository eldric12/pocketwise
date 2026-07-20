class CategoryDefinition {
  const CategoryDefinition({
    required this.id,
    required this.label,
    required this.isExpense,
    required this.iconKey,
    required this.colorKey,
    required this.isCustom,
  });

  final String id;
  final String label;
  final bool isExpense;
  final String iconKey;
  final String colorKey;
  final bool isCustom;

  CategoryDefinition copyWith({
    String? label,
    String? iconKey,
    String? colorKey,
  }) {
    return CategoryDefinition(
      id: id,
      label: label ?? this.label,
      isExpense: isExpense,
      iconKey: iconKey ?? this.iconKey,
      colorKey: colorKey ?? this.colorKey,
      isCustom: isCustom,
    );
  }
}
