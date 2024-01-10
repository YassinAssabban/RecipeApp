import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:recipeappoff/recipe_details_screen.dart';
import 'package:sqflite/sqflite.dart';
import 'addrecipe.dart';
import 'database_helper.dart';
import 'recipe_model.dart';
import 'dart:io';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await deleteDatabase(join(await getDatabasesPath(), 'database.db'));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recipe app',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );

  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>{
  // Recipes
  List<Recipe> recipes = [];
  bool isLoading = true;

    // Get DB
    void initDb() async {
      await DatabaseHelper.instance.database;
    }
    // Init
      @override
      void initState() {
        initDb();
        getRecipes();
        super.initState();
      }

    // Get all recipes
    void getRecipes() async {
      await DatabaseHelper.instance.getAllRecipes().then((value) {
        setState(() {
          recipes = value;
          isLoading = false;
        });
    }).catchError((e) => debugPrint(e.toString()));
    }

    // Build
    @override
  Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(title: const Text('Recettes')),
        body: isLoading
          ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
          itemCount: recipes.length,
          itemBuilder: (context, index) => Card(
            color: Colors.green.shade50,
            margin: const EdgeInsets.all(15),
            child: ListTile(
              title: Text(recipes[index].name),
              // leading: Image.network("https://t4.ftcdn.net/jpg/04/70/29/97/240_F_470299797_UD0eoVMMSUbHCcNJCdv2t8B2g1GVqYgs.jpg"),
                leading: SizedBox(
                height: 50,
                width: 50,
                  child: recipes[index].imagePath != null
                ? Image.file(File(recipes[index].imagePath!))
                  : Image.network("https://t4.ftcdn.net/jpg/04/70/29/97/240_F_470299797_UD0eoVMMSUbHCcNJCdv2t8B2g1GVqYgs.jpg"),
                ),
              // subtitle: Text(recipes[index].description),
                subtitle: Text(
                  _truncateDescription(recipes[index].description, 25), // 25 représente le nombre maximum de caractères
                ),
                onTap: () {
                  // Naviguer vers la vue détaillée lorsqu'un élément de la liste est cliqué
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RecipeDetailScreen(recipe: recipes[index]),
                    ),
                  );
                },
              trailing: SizedBox(
              width: 100,
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => AddRecipe(recipe: recipes[index])),
                        );
                        getRecipes();
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        DatabaseHelper.instance.delete(recipes[index].id!).then((value) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(content: Text('Deleted')));
                        }).catchError((e) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(SnackBar(content: Text(e.toString())));
                        });
                        getRecipes();
                      },
                    ),
                  ],
                ),
              )
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        backgroundColor: Colors.green,
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddRecipe()),
          );
          getRecipes();
        },

      ),
        );
    }

}
String _truncateDescription(String description, int maxLength) {
  if (description.length <= maxLength) {
    return description;
  } else {
    // Si la description est plus longue que maxLength, tronquer et ajouter "..."
    return '${description.substring(0, maxLength)}...';
  }
}






