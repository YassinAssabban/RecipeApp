import 'dart:io';
import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'ingredient_model.dart';
import 'recipe_model.dart';

class RecipeDetailScreen extends StatelessWidget {
  final Recipe recipe;

  const RecipeDetailScreen({Key? key, required this.recipe}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(recipe.name),
      ),
      body: SingleChildScrollView(
      child :Padding(
        padding: const EdgeInsets.all(20),
        child:
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image de la recette
            SizedBox(
              height: 400,
              child: recipe.imagePath != null
                  ? Image.file(File(recipe.imagePath!))
                  : Text('Pas d\'image'),
            ),
            const SizedBox(height: 20),
            // Description de la recette
            const Text(
              'Description:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(passerALaLigneSurPointVirgule(recipe.description)),
            // Text(recipe.description),
            const SizedBox(height: 16),
            // Liste des ingrédients
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ingrédients:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  FutureBuilder<List<Ingredient>>(
                    future: DatabaseHelper.instance.getIngredientsForRecipe(recipe.id!),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        final ingredients = snapshot.data ?? [];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (final ingredient in ingredients)
                              Text(ingredient.name),
                          ],
                        );
                      }
                    },
                  ),
                ],
              ),
          ],
        ),
      ),
      ),
    );
  }
}

String passerALaLigneSurPointVirgule(String input) {
  // Diviser la chaîne en une liste de sous-chaînes sur le point-virgule
  List<String> parties = input.split(';');

  // Joindre les sous-chaînes avec des sauts de ligne
  String resultat = parties.join('\n');

  return resultat;
}
