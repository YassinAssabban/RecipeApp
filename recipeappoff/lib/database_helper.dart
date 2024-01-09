import 'package:recipeappoff/recipe_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'ingredient_model.dart';


class DatabaseHelper {
  Database? _database;

  // Singleton
  static final DatabaseHelper instance = DatabaseHelper._init();

  DatabaseHelper._init();

  // Get the database
  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('database.db');
    return _database!;
  }

  // Init database
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  // Create the DB
  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE recipes ( 
      id INTEGER PRIMARY KEY AUTOINCREMENT, 
      name TEXT NOT NULL,
      description TEXT NOT NULL,
      imagePath TEXT
    )
  ''');

    await db.execute('''
    CREATE TABLE ingredients (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL
    )
  ''');

    await db.execute('''
    CREATE TABLE recipe_ingredients (
      recipe_id INTEGER NOT NULL,
      ingredient_id INTEGER NOT NULL,
      PRIMARY KEY (recipe_id, ingredient_id),
      FOREIGN KEY (recipe_id) REFERENCES recipes (id) ON DELETE CASCADE,
      FOREIGN KEY (ingredient_id) REFERENCES ingredients (id) ON DELETE CASCADE
    )
  ''');

  //   await db.execute('''
  //   INSERT INTO recipes (id, name, description, imagePath) VALUES (1, 'Poulet au curry', 'Un délicieux poulet au curry', '/data/data/be.sinyaa.recipeappoff/cache/496aea26-e231-452e-af6b-fd7aca72e1c3')
  // ''');
  //   await db.execute('''
  //   INSERT INTO ingredients (id, name) VALUES (1, 'Poulet')
  // ''');
  //
  //   await db.execute('''
  //   INSERT INTO recipe_ingredients (recipe_id, ingredient_id) VALUES (1, 1)
  // ''');

  }



  // Insert recipe
  Future<int> insertRecipe(Recipe recipe) async {
    final db = await database;
    print(recipe);
    return await db.insert('recipes', recipe.toMap());
  }

  // Insert ingredient
  Future<int> insertIngredient(Ingredient ingredient) async {
    final db = await database;
    ingredient.id = await db.insert('ingredients', ingredient.toMap());
    print(ingredient);
    return ingredient.id!;
  }

// Insert recipe-ingredient relationship
  Future<void> insertRecipeIngredient(int recipeId, int ingredientId) async {
    final db = await database;
    await db.insert('recipe_ingredients', {'recipe_id': recipeId, 'ingredient_id': ingredientId});
  }

  // Get all recipes
  Future<List<Recipe>> getAllRecipes() async {
    final db = await instance.database;

    final result = await db.query('recipes');

    return result.map((json) => Recipe.fromJSON(json)).toList();
  }

  // Get all ingredients for a recipe
  Future<List<Ingredient>> getIngredientsForRecipe(int recipeId) async {
    final db = await instance.database;

    final result = await db.rawQuery('''
      SELECT ingredients.* FROM ingredients
      JOIN recipe_ingredients ON ingredients.id = recipe_ingredients.ingredient_id
      WHERE recipe_ingredients.recipe_id = $recipeId
    ''');
    print(result.map((json) => Ingredient.fromJSON(json)).toList());
    return result.map((json) => Ingredient.fromJSON(json)).toList();
  }

  // Delete
  Future<void> delete(int id) async {
    try {
      final db = await instance.database;

      await db.delete(
        'recipes',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (_) {}
  }

  // Update
  Future<int> update(Recipe recipe) async {
    final db = await instance.database;

    return db.update(
      'recipes',
      recipe.toMap(),
      where: 'id = ?',
      whereArgs: [recipe.id],
    );
  }

  // Close the database
  Future close() async {
    final db = await instance.database;

    db.close();
  }
}
