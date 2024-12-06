import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RecipesPage extends StatefulWidget {
  @override
  _RecipesPageState createState() => _RecipesPageState();
}

class _RecipesPageState extends State<RecipesPage> {
  List<dynamic> recipes = [];
  bool isLoading = false;

  // Fetch recipes from the API
  Future<void> fetchRecipes() async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(Uri.parse('https://jsonplaceholder.typicode.com/posts'));
      if (response.statusCode == 200) {
        setState(() => recipes = json.decode(response.body));
      } else {
        throw Exception('Failed to load recipes');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch recipes')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  // Delete a recipe by ID
  void deleteRecipe(int id) {
    setState(() => recipes.removeWhere((recipe) => recipe['id'] == id));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Recipe deleted')),
    );
  }

  // Edit a recipe title
  void editRecipe(int id, String newTitle) {
    setState(() {
      // Loop through recipes and update the title
      for (var recipe in recipes) {
        if (recipe['id'] == id) {
          recipe['title'] = newTitle;
          break;
        }
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Recipe updated')),
    );
  }

  @override
  void initState() {
    super.initState();
    fetchRecipes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Recipes')),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: recipes.length,
              itemBuilder: (context, index) {
                final recipe = recipes[index];
                return Card(
                  margin: EdgeInsets.all(10),
                  child: ListTile(
                    title: Text(
                      recipe['title'],
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(recipe['body']),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => showEditDialog(recipe['id'], recipe['title']),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => deleteRecipe(recipe['id']),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  // Show a dialog to edit the recipe title
  void showEditDialog(int id, String currentTitle) {
    final _controller = TextEditingController(text: currentTitle);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Recipe'),
        content: TextField(
          controller: _controller,
          decoration: InputDecoration(hintText: 'Enter new title'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newTitle = _controller.text.trim();
              if (newTitle.isNotEmpty) {
                editRecipe(id, newTitle); // Update the recipe with new title
                Navigator.pop(context); // Close the dialog
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Title cannot be empty')),
                );
              }
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }
}
