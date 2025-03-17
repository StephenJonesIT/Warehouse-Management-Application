import 'dart:convert';
import 'dart:math';

import 'package:bai1/models/supplier_models.dart';
import 'package:bai1/suppliers/add_supplier.dart';
import 'package:bai1/suppliers/edit_supplier.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ListSupplierScreen extends StatefulWidget {
  ListSupplierScreen();

  @override
  State<ListSupplierScreen> createState() {
    return _ListSupplierState();
  }
}

class _ListSupplierState extends State<ListSupplierScreen> {
  List<Supplier> cachedSupplierList = [];
  int currentPage = 1;
  int pageSize = 10;
  int totalItems = 0;
  bool isLoadingMore = false;
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchSuppliers();
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

  Future<void> _fetchSuppliers() async {
    setState(() {
      if (currentPage == 1) {
        cachedSupplierList.clear();
      }
      isLoadingMore = true;
    });

    final response = await http.get(Uri.parse(
        "http://10.0.2.2:8810/api/suppliers?page=$currentPage&limit=$pageSize"));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List<dynamic> suppliersJson = data['data'];
      totalItems = data['filter']['total'];
      setState(() {
        if (currentPage == 1) {
          cachedSupplierList =
              suppliersJson.map((json) => Supplier.fromJson(json)).toList();
        } else {
          cachedSupplierList.addAll(
              suppliersJson.map((json) => Supplier.fromJson(json)).toList());
        }
        isLoadingMore = false;
      });
    } else {
      setState(() {
        isLoadingMore = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load suppliers')),
      );
    }
  }

  Future<void> _loadMore() async {
    if (!isLoadingMore && cachedSupplierList.length < totalItems) {
      setState(() {
        currentPage++;
      });
      _fetchSuppliers();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: Text(
          'Suppliers List',
          style: TextStyle(
              fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
        ),
        centerTitle: true,
        foregroundColor: Colors.white,
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
              onPressed: () {
                showSearch(
                    context: context,
                    delegate:
                    SearchSupplierDelegate(supplierList: Future.value(cachedSupplierList)));
              },
              icon: Icon(Icons.search)),
          IconButton(
              onPressed: () async {
                final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AddSupplierScreen()));
                if (result == true) {
                  setState(() {
                    currentPage = 1;
                  });
                  _fetchSuppliers();
                }
              },
              icon: Icon(Icons.add))
        ],
      ),
      body: ListView.builder(
        controller: scrollController,
        itemCount: cachedSupplierList.length + (isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index < cachedSupplierList.length) {
            final supplier = cachedSupplierList[index];
            return ListTile(
              title: Text(supplier.name),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Phone: ${supplier.phone}'),
                ],
              ),
              leading: CircleAvatar(
                backgroundColor: getRandomColor(),
                child: Text(supplier.name[0]),
              ),
              trailing: Icon(Icons.info_outline),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context)=>
                    EditSupplierScreen(supllier: supplier)
                ));
              },
              onLongPress: () =>
                  _showDeleteConfirmationDialog(context, supplier.id),
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }

  Color getRandomColor() {
    final Random random = Random();
    return Color.fromRGBO(
      random.nextInt(256), // Red
      random.nextInt(256), // Green
      random.nextInt(256), // Blue
      1, // Alpha (opacity)
    );
  }

  Future<void> _showDeleteConfirmationDialog(
      BuildContext context, int itemId) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // Người dùng phải nhấn nút
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xác nhận xóa'),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text('Bạn có chắc chắn muốn xóa mục này?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Đóng hộp thoại
              },
            ),
            TextButton(
              child: const Text('Yes'),
              onPressed: () {
                _deleteItem(itemId); // Gọi API xóa
                Navigator.of(context).pop(); // Đóng hộp thoại
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteItem(int itemId) async {
    final url = Uri.parse(
        'http://10.0.2.2:8810/api/supplier/$itemId'); // Thay YOUR_DELETE_API_ENDPOINT
    try {
      final response = await http.delete(url);
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Item deleted successfully!')),
        );
        setState(() {
          cachedSupplierList.removeWhere((supplier) => supplier.id == itemId);
          if (cachedSupplierList.isEmpty && currentPage > 1) {
            currentPage--;
          }
          _fetchSuppliers();
        });
      } else {
        final responseBody = json.decode(response.body); // Decode JSON
        final errorMessage = responseBody['message']; // Lấy thông báo lỗi
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } catch (e) {
      print('Error deleting item: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }
}

class SearchSupplierDelegate extends SearchDelegate {
  final Future<List<Supplier>> supplierList;

  SearchSupplierDelegate({required this.supplierList});

  @override
  List<Widget>? buildActions(BuildContext context) => [
    IconButton(
        onPressed: () {
          if (query.isEmpty) {
            close(context, null);
          } else {
            query = '';
          }
        },
        icon: Icon(Icons.clear))
  ];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
      onPressed: () => close(context, null), icon: Icon(Icons.arrow_back));

  @override
  Widget buildResults(BuildContext context) {
    return FutureBuilder<List<Supplier>>(
        future: supplierList,
        builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Center(child: CircularProgressIndicator());
      } else if (snapshot.hasError) {
        return Center(child: Text('Error: ${snapshot.error}'));
      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
        return Center(child: Text('No suppliers found'));
      } else{
        final List<Supplier> results = snapshot.data!
            .where((supplier) =>
            supplier.name.toLowerCase().contains(query.toLowerCase()))
            .toList();

        return ListView.builder(
          itemCount: results.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(results[index].name),
              onTap: () {
                close(context, results[index]);
              },
            );
          },
        );
      }
        },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return FutureBuilder<List<Supplier>>(
      future: supplierList,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No suppliers found'));
        } else {
          final List<Supplier> suggestions = snapshot.data!
              .where((supplier) =>
              supplier.name.toLowerCase().contains(query.toLowerCase()))
              .toList();

          return ListView.builder(
            itemCount: suggestions.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(suggestions[index].name),
                onTap: () {
                  query = suggestions[index].name;
                  showResults(context);
                },
              );
            },
          );
        }
      },
    );
  }
}