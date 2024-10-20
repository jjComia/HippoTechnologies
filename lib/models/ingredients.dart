class Ingredient 
{
  final String id;
  final String name;
  final double quantity;
  final int purchaseQuantity;
  final double costPerPurchaseUnit;
  final String unit;
  final String notes;

  Ingredient({required this.id, required this.name, required this.quantity, required this.purchaseQuantity, required this.costPerPurchaseUnit, required this.unit, required this.notes});
}