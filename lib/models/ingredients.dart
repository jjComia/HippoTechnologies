class Ingredient 
{
  final String recipeId;
  final String inventoryId;
  final String name;
  final int quantity;
  final int minQuantity;
  final String unit;

  Ingredient({required this.recipeId, required this.inventoryId, required this.name, required this.quantity, required this.minQuantity, required this.unit});
}