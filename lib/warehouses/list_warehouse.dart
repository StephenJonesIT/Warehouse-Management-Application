import 'dart:convert';
import 'dart:math';

import 'package:bai1/models/warehouse_model.dart';
import 'package:bai1/warehouses/add_warehouse.dart';
import 'package:bai1/warehouses/update_warehouse.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ListWarehouseScreen extends StatefulWidget {
  ListWarehouseScreen();
  @override
  State<ListWarehouseScreen> createState() => _listWarehouseState();
}

class _listWarehouseState extends State<ListWarehouseScreen> {
  List<Warehouse> cachedListWarehouses = [];
  int currentPage = 1;
  int pageSize = 10;
  int totalItems = 0;
  bool isLoadingMore = false;
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchWarehouses();
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

  Future<void> _fetchWarehouses() async {
    setState(() {
      if (currentPage == 1) {
        cachedListWarehouses.clear();
      }
      isLoadingMore = true;
    });

    final response = await http.get(Uri.parse(
        'http://10.0.2.2:8810/api/warehouses?page=$currentPage&limit=$pageSize'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List<dynamic> warehousesJson = data['data'];
      totalItems = data['filter']['total'];
      setState(() {
        if (currentPage == 1) {
          cachedListWarehouses =
              warehousesJson.map((json) => Warehouse.fromJson(json)).toList();
        } else {
          cachedListWarehouses.addAll(
              warehousesJson.map((json) => Warehouse.fromJson(json)).toList());
        }
        isLoadingMore = false;
      });
    } else {
      setState(() {
        isLoadingMore = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load warehouses')),
      );
    }
  }

  Future<void> _loadMore() async {
    if (!isLoadingMore && cachedListWarehouses.length < totalItems) {
      setState(() {
        currentPage++;
      });
      _fetchWarehouses();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.black,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          "Warehouse List",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
              onPressed: () {
                showSearch(
                    context: context,
                    delegate: SearchWarehouseDelegate(
                        warehouses: cachedListWarehouses));
              },
              icon: Icon(Icons.search))
        ],
      ),
      body: ListView.builder(
        controller: scrollController,
        itemCount: cachedListWarehouses.length + (isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index < cachedListWarehouses.length) {
            final warehouse = cachedListWarehouses[index];
            return ListTile(
              trailing: Icon(
                Icons.arrow_forward_ios,
              ),
              title: Text(warehouse.name),
              subtitle: Text('${warehouse.location}'),
              leading: Icon(Icons.place),
              onTap: () async {
                final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context)=> UpdateWarehouseScreen(
                        warehouse: warehouse
                    )
                    )
                );
                if(result == true){
                  setState(() {
                    currentPage = 1;
                  });
                  _fetchWarehouses();
                }
              },
              onLongPress: () {
                _showDeleteConfirmationDialog(context, warehouse);
              },
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green[500],
        foregroundColor: Colors.white,
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddWarehouseScreen()),
          );
          if (result == true) {
            setState(() {
              currentPage = 1;
            });
            _fetchWarehouses();
          }
        },
        child: Icon(
          Icons.add,
          size: 30,
        ),
      ),
    );
  }

  Future<void> _showDeleteConfirmationDialog(
      BuildContext context, Warehouse warehouse) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xác nhận xóa'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Bạn có chắc chắn muốn xóa kho ${warehouse.name}?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Hủy'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Xóa'),
              onPressed: () {
                _deleteWarehouse(warehouse.id);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteWarehouse(int warehouseId) async {
    final url = Uri.parse('http://10.0.2.2:8810/api/warehouse/$warehouseId');
    try {
      final response = await http.delete(url);
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Kho hàng đã được xóa thành công')),
        );
        setState(() {
          cachedListWarehouses
              .removeWhere((warehouse) => warehouse.id == warehouseId);
          if (cachedListWarehouses.isEmpty && currentPage > 1) {
            currentPage--;
          }
          _fetchWarehouses();
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
        SnackBar(content: Text('Đã xảy ra lỗi: $e')),
      );
    }
  }
}

class SearchWarehouseDelegate extends SearchDelegate{
  final List<Warehouse> warehouses;

  SearchWarehouseDelegate({required this.warehouses});

  @override
  List<Widget>? buildActions(BuildContext context) => [
    IconButton(onPressed: (){
      if(query.isEmpty){
        close(context, null);
      }else{
        query = '';
        showSuggestions(context);
      }
    }, icon: Icon(Icons.clear)),
  ];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(onPressed: (){
    close(context, null);
  }, icon: Icon(Icons.arrow_back_ios_new_rounded));

  @override
  Widget buildResults(BuildContext context) {
    List<Warehouse> results = warehouses
        .where((warehouse) =>
    warehouse.name.toLowerCase().contains(query.toLowerCase()) ||
        warehouse.location.toLowerCase().contains(query.toLowerCase()))
        .toList();

    if (results.isEmpty) {
      return Center(child: Text('No results found for "$query"'));
    }

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final warehouse = results[index];
        return ListTile(
          leading: Icon(Icons.location_city),
          title: Text(warehouse.name),
          subtitle: Text(warehouse.location),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestionList = query.isEmpty
        ? []
        : warehouses
        .where((warehouse) =>
    warehouse.name.toLowerCase().contains(query.toLowerCase()) ||
        warehouse.location.toLowerCase().contains(query.toLowerCase()))
        .toList();

    if (suggestionList.isEmpty) {
      return Container(); // Return an empty container if no suggestions are found
    }

    final random = Random();
    final suggestionsToDisplay = <Warehouse>[];

    // Lấy ngẫu nhiên 5 item hoặc ít hơn nếu danh sách nhỏ hơn 5
    while (suggestionsToDisplay.length < 5 && suggestionsToDisplay.length < suggestionList.length) {
      final randomIndex = random.nextInt(suggestionList.length);
      final randomWarehouse = suggestionList[randomIndex];

      // Kiểm tra để tránh trùng lặp
      if (!suggestionsToDisplay.contains(randomWarehouse)) {
        suggestionsToDisplay.add(randomWarehouse);
      }
    }

    return ListView.builder(
      itemCount: suggestionsToDisplay.length,
      itemBuilder: (context, index) => ListTile(
        leading: Icon(Icons.location_city),
        title: RichText(
          text: TextSpan(
            text: suggestionsToDisplay[index].name.substring(
                0,
                query.length > suggestionsToDisplay[index].name.length
                    ? suggestionsToDisplay[index].name.length
                    : query.length),
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            children: [
              TextSpan(
                text: suggestionsToDisplay[index].name.substring(
                    query.length > suggestionsToDisplay[index].name.length
                        ? suggestionsToDisplay[index].name.length
                        : query.length),
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
        subtitle: Text(suggestionsToDisplay[index].location),
        onTap: () {
          query = suggestionsToDisplay[index].name;
          showResults(context);
        },
      ),
    );
  }
}