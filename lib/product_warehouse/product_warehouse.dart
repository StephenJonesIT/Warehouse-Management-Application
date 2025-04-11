import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:bai1/models/product_warehouse_model.dart';
import 'package:flutter/material.dart';

class ProductWarehouseScreen extends StatefulWidget {
  @override
  _ProductWarehouseScreenState createState() => _ProductWarehouseScreenState();
}

class _ProductWarehouseScreenState extends State<ProductWarehouseScreen> {
  List<ProductWarehouse> products = [];
  List<ProductWarehouse> filteredProducts = [];
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
          'https://manage-sale-microservice.onrender.com/api/product/warehouses?page=$currentPage&limit=$pageSize'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<dynamic> productData = data['data'];
        totalItems = data['filter']['total'];

        setState(() {
          products.addAll(
              productData.map((json) => ProductWarehouse.fromJson(json)).toList());
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
        final warehouseLower = product.warehouseName.toLowerCase();
        final searchLower = query.toLowerCase();
        return nameLower.contains(searchLower) || warehouseLower.contains(searchLower);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Product Warehouse List'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: ProductWarehouseSearchDelegate(products: products),
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

  Widget buildProductItem(ProductWarehouse product) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: ListTile(
        contentPadding: EdgeInsets.all(12),
        leading: CircleAvatar(
          backgroundColor: _getColorBasedOnQuantity(product.quantity),
          child: Text(
            product.productName[0],
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
            Text(product.warehouseName),
          ],
        ),
        trailing: Text(product.quantity.toString(), style: TextStyle(fontSize: 16),),
        onTap: () {
          _showProductDetail(context, product);
        },
        onLongPress: () => _showDeleteConfirmationDialog(context, product),
      ),
    );
  }

  Color _getColorBasedOnQuantity(int quantity) {
    if (quantity > 50) return Colors.green;
    if (quantity > 20) return Colors.blue;
    if (quantity > 10) return Colors.orange;
    return Colors.red;
  }

  void _showProductDetail(BuildContext context, ProductWarehouse product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(product.productName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(product.productId),
            Text(product.warehouseName),
            Text('Quantity: ${product.quantity}'),
            SizedBox(height: 16),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteConfirmationDialog(
      BuildContext context, ProductWarehouse product) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm deletion', textAlign: TextAlign.center),
          content: Text(
            'Are you sure you want to delete "${product.productName}" from ${product.warehouseName}?',
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
                    await _deleteItem(product);
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

  Future<void> _deleteItem(ProductWarehouse product) async {
    try {
      final response = await http.delete(
        Uri.parse("https://manage-sale-microservice.onrender.com/api/product/warehouse/${product.productId}/${product.warehouseId}"),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Item deleted successfully")),
        );

        setState(() {
          products.removeWhere((p) =>
          p.productId == product.productId &&
              p.warehouseId == product.warehouseId);
          filteredProducts.removeWhere((p) =>
          p.productId == product.productId &&
              p.warehouseId == product.warehouseId);
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

class ProductWarehouseSearchDelegate extends SearchDelegate {
  final List<ProductWarehouse> products;

  ProductWarehouseSearchDelegate({required this.products});

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
    final List<ProductWarehouse> results = products.where((product) {
      final nameLower = product.productName.toLowerCase();
      final warehouseLower = product.warehouseName.toLowerCase();
      final searchLower = query.toLowerCase();
      return nameLower.contains(searchLower) || warehouseLower.contains(searchLower);
    }).toList();

    return _buildSearchResults(results);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final List<ProductWarehouse> suggestions = query.isEmpty
        ? []
        : products.where((product) {
      final nameLower = product.productName.toLowerCase();
      final warehouseLower = product.warehouseName.toLowerCase();
      final searchLower = query.toLowerCase();
      return nameLower.contains(searchLower) || warehouseLower.contains(searchLower);
    }).toList();

    return _buildSearchResults(suggestions);
  }

  Widget _buildSearchResults(List<ProductWarehouse> results) {
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final product = results[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: _getColorBasedOnQuantity(product.quantity),
            child: Text(
              product.quantity.toString(),
              style: TextStyle(color: Colors.white),
            ),
          ),
          title: Text(product.productName),
          subtitle: Text('${product.warehouseName} (${product.quantity})'),
          onTap: () {
            close(context, product);
          },
        );
      },
    );
  }

  Color _getColorBasedOnQuantity(int quantity) {
    if (quantity > 50) return Colors.green;
    if (quantity > 20) return Colors.blue;
    if (quantity > 10) return Colors.orange;
    return Colors.red;
  }
}