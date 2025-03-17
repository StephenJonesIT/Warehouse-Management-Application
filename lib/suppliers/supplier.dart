import 'package:bai1/categories/list_category.dart';
import 'package:bai1/products/add_product.dart';
import 'package:bai1/suppliers/add_supplier.dart';
import 'package:bai1/suppliers/list_supplier.dart';
import 'package:bai1/warehouses/list_warehouse.dart';
import 'package:flutter/material.dart';

class SupplierScreen extends StatelessWidget {
  final List<Map<String, dynamic>> suppliers = [
    {'icon': Icons.receipt, 'title': 'Supplier List'},
    {'icon': Icons.add_box, 'title': 'Add Product'},
    {'icon': Icons.warehouse_outlined, 'title': 'Warehouse'},
    {'icon': Icons.category, 'title': 'Category'},
    {'icon': Icons.cabin, 'title': 'Settings'},
  ];

  void navigateToAddSupplierScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddSupplierScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(
            'Suppliers',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: Column(
          children: [
            Container(
                color: Colors.grey[200],
                height: 250, // Ví dụ về một phần tử khác trong Column
                child: GestureDetector(
                  onTap: () => navigateToAddSupplierScreen(context),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: SizedBox(
                      width: 200,
                      height: 150,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(
                                  10)), // Adjust the radius here
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_circle_outline_outlined,
                              size: 50.0,
                              color: Colors.blue,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Text(
                                "Add Supplier",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                )),
            Expanded(
              child: ListView.separated(
                itemCount: suppliers.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: SizedBox(
                      height: 50, // Chiều cao của từng ListTile
                      child: ListTile(
                        leading: Icon(suppliers[index]['icon']),
                        title: Text(suppliers[index]['title']),
                        trailing: Icon(Icons.arrow_forward_ios_outlined),
                        onTap: () {
                          _navigationScreen(context, index);
                        },
                      ),
                    ),
                  );
                },
                separatorBuilder: (context, index) {
                  return Divider(
                    color: Colors.grey,
                    thickness: 1.0,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigationScreen(BuildContext context, int index) {
    switch (index) {
      case 0:
        {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ListSupplierScreen()),
          );
          break;
        }
      case 1:
      {
        Navigator.push(
          context, 
          MaterialPageRoute(builder: (context) => AddProductScreen()),
        );
      }
      case 2:{
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context)=>ListWarehouseScreen()),
        );
        break;
      }
      case 3:{
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context)=>ListCategoryScreen()),
        );
        break;
      }
    }
  }
}
