import 'package:bai1/categories/add_category.dart';
import 'package:bai1/categories/list_category.dart';
import 'package:bai1/product_warehouse/product_warehouse.dart';
import 'package:bai1/products/add_product.dart';
import 'package:bai1/products/list_product.dart';
import 'package:bai1/suppliers/add_supplier.dart';
import 'package:bai1/suppliers/list_supplier.dart';
import 'package:bai1/transaction/issue.dart';
import 'package:bai1/transaction/list_transaction.dart';
import 'package:bai1/transaction/receipt.dart';
import 'package:bai1/warehouses/add_warehouse.dart';
import 'package:bai1/warehouses/list_warehouse.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomePageState();
}

class _HomePageState extends State<HomeScreen> {
  List<Map<String, dynamic>> homes = [
    {'color': Colors.orange, 'icon': Icons.receipt, 'title': 'Supplier List'},
    {'color': Colors.green, 'icon': Icons.add_box, 'title': 'Add Product'},
    {'color': Colors.blueAccent, 'icon': Icons.warehouse_outlined, 'title': 'Add Warehouse'},
    {'color': Colors.pink, 'icon': Icons.category, 'title': 'Add Category'},
    {'color': Colors.green, 'icon': Icons.group_add, 'title': 'Add Supplier'},
    {'color': Colors.pink, 'icon': Icons.description, 'title': 'Category List'},
    {'color': Colors.orange, 'icon': Icons.description, 'title': 'Warehouse List'},
    {'color': Colors.red, 'icon': Icons.shopping_cart, 'title': 'Product List'},
    {'color': Colors.teal, 'icon': Icons.warehouse_rounded, 'title': 'Check Stock'},
    {'color': Colors.red, 'icon': Icons.history, 'title': 'History'},
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                          context, 
                          MaterialPageRoute(builder: (context)=>GoodsReceipt())
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.green[400],
                      padding: EdgeInsets.symmetric(
                          horizontal: 24, vertical: 20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.receipt, color: Colors.white),
                        SizedBox(width: 8),
                        Text("Goods Receipt"),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(context,
                      MaterialPageRoute(builder: (context)=>GoodsIssueScreen()));
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.blueAccent,
                      padding: EdgeInsets.symmetric(
                          horizontal: 24, vertical: 20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.description, color: Colors.white),
                        SizedBox(width: 8),
                        Text("Goods Issue"),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Quick Operation",
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 20),
                  ),
                ),
              ),
              SizedBox(height: 8),
              Expanded(
                child: GridView.builder(
                  padding: EdgeInsets.zero,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.9, // Adjusted aspect ratio
                  ),
                  itemCount: homes.length,
                  itemBuilder: (context, index) {
                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          _navigationScreen(context,index);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min, // Added to prevent overflow
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: homes[index]['color'].withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  homes[index]['icon'],
                                  color: homes[index]['color'],
                                  size: 24, // Reduced icon size
                                ),
                              ),
                              SizedBox(height: 8), // Reduced spacing
                              Text(
                                homes[index]['title'],
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12, // Reduced font size
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 2, // Allow text to wrap
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigationScreen(BuildContext context, int index){
      switch (index) {
        case 0: {
          Navigator.push(
              context,
              MaterialPageRoute(builder: (context)=>ListSupplierScreen(isSelected: false)));
          break;
        }
        case 1: {
          Navigator.push(
              context,
              MaterialPageRoute(builder: (context)=>AddProductScreen())
          );
          break;
        }
        case 2: {
          Navigator.push(
              context,
              MaterialPageRoute(builder: (context)=>AddWarehouseScreen())
          );
          break;
        }
        case 3: {
          Navigator.push(
              context,
              MaterialPageRoute(builder: (context)=>AddCategoryScreen())
          );
          break;
        }
        case 4: {
          Navigator.push(
              context,
              MaterialPageRoute(builder: (context)=>AddSupplierScreen())
          );
          break;
        }
        case 5: {
          Navigator.push(
              context,
              MaterialPageRoute(builder: (context)=>ListCategoryScreen(isSelected: false))
          );
          break;
        }
        case 6: {
          Navigator.push(
              context,
              MaterialPageRoute(builder: (context)=>ListWarehouseScreen(isSelected: false,))
          );
          break;
        }
        case 7: {
          Navigator.push(
              context,
              MaterialPageRoute(builder: (context)=>ListProductScreen(isSelected: false,))
          );
          break;
        }
        case 8: {
          Navigator.push(
              context,
              MaterialPageRoute(builder: (context)=>ProductWarehouseScreen())
          );
          break;
        }
        case 9: {
          Navigator.push(
              context,
              MaterialPageRoute(builder: (context)=>TransactionListScreen())
          );
          break;
        }
      }
  }
}