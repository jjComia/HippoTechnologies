class Inventory {
  final String name;
  final int quantity;
  final int purchaseQuantity;
  final double costPerPurchaseUnit;
  final String unit;
  final String notes;

  Inventory({required this.name, required this.quantity, required this.purchaseQuantity, required this.costPerPurchaseUnit, required this.unit, required this.notes});
}