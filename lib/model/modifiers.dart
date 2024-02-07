class TemplateModifierGroups {
  late String id;
  late String name;
  late List<TemplateModifiers> modifiers;

  TemplateModifierGroups(
      {required this.id, required this.name, required this.modifiers});
}

class TemplateModifiers {
  late String id;
  late String name;
  late String price;
  late int quantity;
  late String unitPrice;
  late List<TemplateModifierGroups> modifierGroups;

  TemplateModifiers({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    required this.unitPrice,
    required this.modifierGroups,
  });
}
