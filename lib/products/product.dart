import 'dart:convert';
import 'package:bai1/products/update_product.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:bai1/models/product_model.dart';

class ProductScreen extends StatefulWidget {
  @override
  _ProductScreenState createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  List<Product> products = [];
  int currentPage = 1;
  int pageSize = 10;
  int totalItems = 0;
  bool isLoading = false;
  bool isLoadingMore = false;
  ScrollController scrollController = ScrollController();
  String currentFilter = '';

  @override
  void initState() {
    super.initState();
    _fetchProducts(currentFilter);
    scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      _loadMore();
    }
  }

  Future<void> _fetchProducts(String filter) async {
    setState(() {
      if (currentPage == 1) {
        products.clear();
      }
      isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse(
          'https://manage-sale-microservice.onrender.com/api/products?page=$currentPage&limit=$pageSize&status=$filter'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<dynamic> productData = data['data'];
        totalItems = data['filter']['total'];
        setState(() {
          if (currentPage == 1) {
            products = productData.map((json) => Product.fromJson(json)).toList();
          } else {
            products.addAll(
                productData.map((json) => Product.fromJson(json)).toList());
          }
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
      _fetchProducts(currentFilter);
    }
  }

  void _onTabChange(int index) {
    setState(() {
      currentPage = 1;
      currentFilter = index == 1 ? 'on sale' : index == 2 ? 'new arrival' : '';
      _fetchProducts(currentFilter);
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Product",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: Colors.pinkAccent,
          foregroundColor: Colors.white,
          bottom: TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            onTap: _onTabChange,
            tabs: [
              Tab(icon: Icon(Icons.filter_list_alt), text: "All"),
              Tab(icon: Icon(Icons.campaign), text: "Sales"),
              Tab(icon: Icon(Icons.card_giftcard), text: "New Arrival"),
            ],
          ),
        ),
        body: TabBarView(
          physics: NeverScrollableScrollPhysics(),
          children: [
            _buildProductGrid(),
            _buildProductGrid(),
            _buildProductGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildProductGrid() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: isLoading && products.isEmpty
            ? Center(child: CircularProgressIndicator())
            : GridView.builder(
          controller: scrollController,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 0.8,
          ),
          itemBuilder: (context, index) {
            if (index < products.length) {
              return buildProductCard(products[index]);
            } else if (isLoadingMore) {
              return Center(child: CircularProgressIndicator());
            } else {
              return SizedBox.shrink(); // Avoid rendering extra space
            }
          },
          itemCount: products.length + (isLoadingMore ? 1 : 0),

        ),
      ),
    );
  }

  Widget buildProductCard(Product product) {
    return GestureDetector(
      onTap: () async{
        final result = await Navigator.push(context, MaterialPageRoute(builder: (context)=>UpdateProductScreen(product: product)));
        if (result == true){
         setState(() {
           currentPage = 1;
         });
         _fetchProducts('');
        }
      },
      onLongPress: ()=>_showDeleteConfirmationDialog(context, product),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                "https://manage-sale-microservice.onrender.com${product.urlImage}", // Replace with your server IP
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset(
                    'assets/photo_default.png',
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.fill,
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.productName,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '\$${product.price.toString()}',
                    style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDeleteConfirmationDialog(BuildContext context, Product product){
      return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            alignment: Alignment.bottomCenter,
            title: Text('Confirm deletion',textAlign: TextAlign.center,),
            content: Text(
                'Are you sure you want to delete "${product.productName}"?',
                textAlign: TextAlign.center,
            ),
            actions: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  TextButton(
                    child: Text('Cancel', style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold
                    ),),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  TextButton(
                    child: Text('Delete', style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold
                    ),),
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
          if (products.isEmpty && currentPage > 1) {
            currentPage--;
          }
          _fetchProducts(currentFilter);
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