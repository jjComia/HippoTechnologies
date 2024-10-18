class RecipeIngredient {
  final int id;
  final String recipeID;
  final String inventoryID;
  final String name;
  final int quantity;
  final int minQuantity;
  final String unit;

  RecipeIngredient({required this.id, required this.recipeID, required this.inventoryID, required this.name, required this.quantity, required this.minQuantity, required this.unit});
}