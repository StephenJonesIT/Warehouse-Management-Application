import 'dart:convert';
import 'package:bai1/products/update_product.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:bai1/models/product_model.dart';

class ListProductScreen extends StatefulWidget {
  final bool isSelected;
  const ListProductScreen({required this.isSelected});
  @override
  State<ListProductScreen> createState() => _ListProductScreenState();
}

class _ListProductScreenState extends State<ListProductScreen> {
  List<Product> products = [];
  List<Product> filteredProducts = [];
  int currentPage = 1;
  int pageSize = 10;
  int totalItems = 0;
  bool isLoading = false;
  bool isLoadingMore = false;
  ScrollController scrollController = ScrollController();
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchProducts();
    scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    scrollController.dispose();
    searchController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      _loadMore();
    }
  }

  Future<void> _fetchProducts() async {
    setState(() {
      if (currentPage == 1) {
        products.clear();
      }
      isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse(
          'https://manage-sale-microservice.onrender.com/api/products?page=$currentPage&limit=$pageSize'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<dynamic> productData = data['data'];
        totalItems = data['filter']['total'];

        setState(() {
          products.addAll(
              productData.map((json) => Product.fromJson(json)).toList());
          filteredProducts = List.from(products);
          isLoading = false;
          isLoadingMore = false;
        });
      } else {
        setState(() {
          isLoading = false;
          isLoadingMore = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load products')),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        isLoadingMore = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }

  Future<void> _loadMore() async {
    if (!isLoadingMore && products.length < totalItems) {
      setState(() {
        isLoadingMore = true;
        currentPage++;
      });
      await _fetchProducts();
    }
  }

  void _filterProducts(String query) {
    setState(() {
      filteredProducts = products.where((product) {
        final nameLower = product.productName.toLowerCase();
        final searchLower = query.toLowerCase();
        return nameLower.contains(searchLower);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Product List'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: ProductSearchDelegate(products: products),
              );
            },
          ),
        ],
      ),
      body: _buildProductList(),
    );
  }

  Widget _buildProductList() {
    if (isLoading && products.isEmpty) {
      return Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: () async {
        setState(() {
          currentPage = 1;
        });
        await _fetchProducts();
      },
      child: ListView.builder(
        controller: scrollController,
        itemCount: filteredProducts.length + (isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index < filteredProducts.length) {
            return buildProductItem(filteredProducts[index]);
          } else if (isLoadingMore) {
            return Center(child: CircularProgressIndicator());
          } else {
            return SizedBox.shrink();
          }
        },
      ),
    );
  }

  Widget buildProductItem(Product product) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: ListTile(
        contentPadding: EdgeInsets.all(8),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            "https://manage-sale-microservice.onrender.com${product.urlImage}",
            width: 60,
            height: 60,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Image.asset(
                'assets/photo_default.png',
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              );
            },
          ),
        ),
        title: Text(
          product.productName,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            Text(
              '\$${product.price.toString()}',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
            if (product.status != null && product.status!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  product.status!,
                  style: TextStyle(
                    color: product.status == 'on sale'
                        ? Colors.green
                        : Colors.blue,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
        trailing: IconButton(
          icon: Icon(Icons.more_vert),
          onPressed: () {
            _showProductOptions(context, product);
          },
        ),
        onTap: () async {
          if (widget.isSelected){
            Navigator.pop(context, product);
          }else {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UpdateProductScreen(product: product),
              ),
            );
            if (result == true) {
              setState(() {
                currentPage = 1;
              });
              _fetchProducts();
            }
          }
        },
      ),
    );
  }

  void _showProductOptions(BuildContext context, Product product) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.edit, color: Colors.blue),
              title: Text('Edit Product'),
              onTap: () async {
                Navigator.pop(context);
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UpdateProductScreen(product: product),
                  ),
                );
                if (result == true) {
                  setState(() {
                    currentPage = 1;
                  });
                  _fetchProducts();
                }
              },
            ),
            ListTile(
              leading: Icon(Icons.delete, color: Colors.red),
              title: Text('Delete Product'),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmationDialog(context, product);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showDeleteConfirmationDialog(
      BuildContext context, Product product) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          alignment: Alignment.bottomCenter,
          title: Text('Confirm deletion', textAlign: TextAlign.center),
          content: Text(
            'Are you sure you want to delete "${product.productName}"?',
            textAlign: TextAlign.center,
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton(
                  child: Text('Cancel',
                      style: TextStyle(
                          color: Colors.green, fontWeight: FontWeight.bold)),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text('Delete',
                      style: TextStyle(
                          color: Colors.red, fontWeight: FontWeight.bold)),
                  onPressed: () async {
                    await _deleteItem(product.productId);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            )
          ],
        );
      },
    );
  }

  Future<void> _deleteItem(String itemId) async {
    try {
      final response = await http.delete(
        Uri.parse("http://10.0.2.2:8810/api/product/$itemId"),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Item deleted successfully")),
        );

        setState(() {
          products.removeWhere((product) => product.productId == itemId);
          filteredProducts.removeWhere((product) => product.productId == itemId);
          if (products.isEmpty && currentPage > 1) {
            currentPage--;
          }
          _fetchProducts();
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

class ProductSearchDelegate extends SearchDelegate {
  final List<Product> products;

  ProductSearchDelegate({required this.products});

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final List<Product> results = products.where((product) {
      final nameLower = product.productName.toLowerCase();
      final searchLower = query.toLowerCase();
      return nameLower.contains(searchLower);
    }).toList();

    return _buildSearchResults(results);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final List<Product> suggestions = query.isEmpty
        ? []
        : products.where((product) {
      final nameLower = product.productName.toLowerCase();
      final searchLower = query.toLowerCase();
      return nameLower.contains(searchLower);
    }).toList();

    return _buildSearchResults(suggestions);
  }

  Widget _buildSearchResults(List<Product> results) {
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final product = results[index];
        return ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              "https://manage-sale-microservice.onrender.com${product.urlImage}",
              width: 50,
              height: 50,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Image.asset(
                  'assets/photo_default.png',
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                );
              },
            ),
          ),
          title: Text(product.productName),
          subtitle: Text('\$${product.price.toString()}'),
          onTap: () {
            close(context, product);
          },
        );
      },
    );
  }
}