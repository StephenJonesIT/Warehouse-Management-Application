import 'dart:convert';
import 'package:bai1/categories/update_category.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/category_model.dart';
import 'add_category.dart'; // Giả sử bạn có model Category

class ListCategoryScreen extends StatefulWidget {
  final bool isSelected;
  ListCategoryScreen({required this.isSelected});

  @override
  State<ListCategoryScreen> createState() => ListCategoryState();
}

class ListCategoryState extends State<ListCategoryScreen> {
  List<Category> cachedCategories = [];
  int currentPage = 1;
  int pageSize = 15;
  int totalItems = 0;
  bool isLoading = false;
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchCategories();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadMore();
    }
  }

  Future<void> _fetchCategories() async {
    setState(() {
      isLoading = true;
    });

    final response = await http.get(Uri.parse(
        'https://manage-sale-microservice.onrender.com/api/categories?page=$currentPage&limit=$pageSize'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List<dynamic> categoriesJson = data['data'];
      totalItems = data['filter']['total'];
      setState(() {
        if (currentPage == 1) {
          cachedCategories = categoriesJson
              .map((json) => Category.fromJson(json))
              .toList();
        } else {
          cachedCategories.addAll(categoriesJson
              .map((json) => Category.fromJson(json))
              .toList());
        }
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load categories')),
      );
    }
  }

  Future<void> _loadMore() async {
    if (!isLoading && cachedCategories.length < totalItems) {
      setState(() {
        currentPage++;
      });
      _fetchCategories();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Categories",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: Colors.pink,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddCategoryScreen()),
                );
                if (result == true) {
                  setState(() {
                    currentPage = 1;
                  });
                  _fetchCategories();
                }
              },
              icon: Icon(Icons.add),
            )
          ],
        ),
        body: ListView.separated(
          controller: _scrollController,
          itemCount: cachedCategories.length + (isLoading ? 1 : 0),
          itemBuilder: (context, index) {
            if (index < cachedCategories.length) {
              final category = cachedCategories[index];
              return ListTile(
                title: Text(category.name),
                trailing: Icon(Icons.arrow_forward_ios_rounded),
                onTap: () async {
                  if (widget.isSelected){
                    Navigator.pop(context,category);
                  }else{
                    final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                UpdateCategoryScreen(category: category)));
                    if (result == true) {
                      setState(() {
                        currentPage = 1;
                      });
                      _fetchCategories();
                    }
                  }
                },
                onLongPress: () {
                  _showDeleteConfirmationDialog(context, category);
                },
              );
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          },
          separatorBuilder: (context, index) {
            return Divider(
              color: Colors.grey,
              thickness: 1.0,
            );
          },
        ),
      ),
    );
  }

  Future<void> _showDeleteConfirmationDialog(
      BuildContext context, Category item) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Deletion"),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Do you want to delete this ${item.name}?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await _deleteItem(item.id);
                  Navigator.of(context).pop();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Failed to delete item: $e")),
                  );
                  Navigator.of(context).pop();
                }
              },
              child: const Text("Yes"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteItem(int itemId) async {
    try {
      final response = await http.delete(
        Uri.parse("http://10.0.2.2:8810/api/category/$itemId"),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Item deleted successfully")),
        );

        setState(() {
          cachedCategories.removeWhere((category) => category.id == itemId);
          if (cachedCategories.isEmpty && currentPage > 1) {
            currentPage--;
          }
          _fetchCategories();
        });
      } else {
        final responseBody = json.decode(response.body);
        final errorMessage = responseBody['message'];
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }
}