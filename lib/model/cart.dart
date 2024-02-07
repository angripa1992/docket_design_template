
import 'package:docket_design_template/model/brand.dart';
import 'package:docket_design_template/model/modifiers.dart';

class TemplateCart {
  final String id;
  final String name;
  final String image;
  final String price;
  final String comment;
  final int quantity;
  final String unitPrice;
  final TemplateCartBrand cartBrand;
  final List<TemplateModifierGroups> modifierGroups;

  TemplateCart(
      {required this.id,
        required this.name,
        required this.image,
        required this.price,
        required this.comment,
        required this.quantity,
        required this.unitPrice,
        required this.cartBrand,
        required this.modifierGroups});
}