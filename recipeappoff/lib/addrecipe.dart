import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'database_helper.dart';
import 'ingredient_model.dart';
import 'recipe_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:io';


class AddRecipe extends StatefulWidget {
  const AddRecipe({super.key, this.recipe});
  final Recipe? recipe;


  @override
  State<AddRecipe> createState() => _AddRecipeState();
}

class _AddRecipeState extends State<AddRecipe> {
  // Form
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final imageController = TextEditingController();
  final List<Ingredient> ingredients = [];

  File? image; // Image

  // Dispose
  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    imageController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    addRecipeData();
    super.initState();
  }

  void addRecipeData() {
    if (widget.recipe != null && mounted) {
      setState(() {
        nameController.text = widget.recipe!.name;
        descriptionController.text = widget.recipe!.description;
        imageController.text = widget.recipe!.imagePath ?? '';
        ingredients.addAll(widget.recipe!.ingredients);
      });
    }
  }

  // Ajouter un ingrédient
  void addIngredient() {
    setState(() {
      ingredients.add(Ingredient(name: 'New Ingredient'));
    });
  }

  // Supprimer un ingrédient
  void removeIngredient(int index) {
    setState(() {
      ingredients.removeAt(index);
    });
  }

  // Enregistrer la recette
  Future<void> addRecipe() async {
    final recipe = Recipe(
      name: nameController.text,
      description: descriptionController.text,
      imagePath: imageController.text,
      ingredients: ingredients,
    );

    if (widget.recipe == null) {
   // insert la recette
    await DatabaseHelper.instance.insertRecipe(recipe).then((recipeId) async {
      // Insert les ingrédients
      recipe.id = recipeId;

      for (final ingredient in ingredients) {
        final ingredientId = await DatabaseHelper.instance.insertIngredient(ingredient);
        await DatabaseHelper.instance.insertRecipeIngredient(recipe.id!, ingredientId);
      }
    });
  } else {
  // Mettre à jour la recette
  recipe.id = widget.recipe!.id;
  await DatabaseHelper.instance.update(recipe);
  }

  }

  // // Add a recipe
  // Future<void> addRecipe() async {
  //   Recipe recipe = Recipe(
  //     name: nameController.text,
  //     description: descriptionController.text,
  //     imagePath: image != null ? image!.path : null,
  //   );
  //
  //   if (widget.recipe == null) {
  //     await DatabaseHelper.instance.insertRecipe(recipe);
  //   } else {
  //     recipe.id = widget.recipe!.id;
  //     await DatabaseHelper.instance.update(recipe);
  //   }



Future<void> pickImage() async {
    try {
      // Récupérer l'image
      final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          image = File(pickedFile.path);
          imageController.text = image!.path;
        });
      }
    } catch (e) {
      debugPrint(e.toString());
    }

}
    // Build
    @override
      Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Ajouter recette'),
        ),
        body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nom',
                  hintText: 'Nom de la recette',
                ),
              ),
              const SizedBox(height: 36),
              TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Separer chaque étape par un point-virgule',
                ),
              ),
              const SizedBox(height: 36),
              TextFormField(
                controller: imageController,
                decoration: const InputDecoration(
                  labelText: 'Image',
                  hintText: 'Sélectionner depuis la galerie',
                ),
                onTap: pickImage, // Appeler la méthode _pickImage lorsqu'on appuie sur le champ
              ),
              const SizedBox(height: 16),
              // Gestion des ingrédients
              for (int i = 0; i < ingredients.length; i++)
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: TextEditingController(text: ingredients[i].name),
                        onChanged: (value) => ingredients[i].name = value,
                        decoration: const InputDecoration(
                          labelText: 'Ingrédient',
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: () => removeIngredient(i),
                    ),
                  ],
                ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: addIngredient,
                child: const Text('Ajouter un ingrédient'),
              ),
              const SizedBox(height: 16),
              MaterialButton(onPressed: ()
              {
                addRecipe();
                Navigator.pop(context);
              },
              child: const Text('Ajouter'),
              )
            ]
          ),
        ),
        ));
    }
   }