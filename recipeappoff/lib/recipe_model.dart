
import 'ingredient_model.dart';

class Recipe {
  int? id;
  String name;
  String description;
  String? imagePath;
  List<Ingredient> ingredients;

  Recipe({this.id, required this.name, required this.description, this.imagePath, List<Ingredient>? ingredients })
      : ingredients = ingredients ?? [];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imagePath': imagePath,
    };
  }

  factory Recipe.fromJSON(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      imagePath: json['imagePath'],
    );
  }
}
