
class Ingredient {
  int? id;
  String name;

  Ingredient({this.id, required this.name});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }
  // Add this method to exclude 'id' when creating the map
  Map<String, dynamic> toMapWithoutId() {
    return {
      'name': name,
    };
  }

  factory Ingredient.fromJSON(Map<String, dynamic> json) {
    return Ingredient(
      id: json['id'],
      name: json['name'],
    );
  }
}