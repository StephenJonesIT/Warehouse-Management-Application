import 'dart:convert';

import 'package:bai1/models/product_model.dart';
import 'package:bai1/models/warehouse_model.dart';
import 'package:bai1/products/list_product.dart';
import 'package:bai1/warehouses/list_warehouse.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class GoodsIssueScreen extends StatefulWidget {
  const GoodsIssueScreen();
  @override
  State<GoodsIssueScreen> createState() => GoodsIssueScreenState();
}
class GoodsIssueScreenState extends State<GoodsIssueScreen>{
  Product? product;
  Warehouse? warehouse;

  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {
    'nameProduct': TextEditingController(),
    'nameWarehouse': TextEditingController(),
    'quantity':TextEditingController(),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Goods Issue",style: TextStyle(fontWeight: FontWeight.bold),),
        foregroundColor: Colors.white,
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.only(top: 24.0),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildTextField("Name Product", 'nameProduct', Icons.shopping_cart,readOnly: true, onTap:_pickProduct,validator: _validateProduct),
                    _buildTextField("Name Warehouse", 'nameWarehouse', Icons.warehouse,readOnly: true, onTap: _pickWarehouse, validator: _validateWarehouse),
                    _buildTextField("Quantity", 'quantity', Icons.dialpad,keyboardType: TextInputType.number, validator: _validateQuantity),
                    _buildSubmitButton()
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String key, IconData icon, {bool readOnly = false, TextInputType? keyboardType, int maxLines = 1, String? Function(String?)? validator, VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: TextFormField(
        controller: _controllers[key],
        readOnly: readOnly,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          enabledBorder: _inputBorder(Colors.white),
          focusedBorder: _inputBorder(Colors.blueAccent),
          errorBorder: _inputBorder(Colors.red),
          focusedErrorBorder: _inputBorder(Colors.red),
          filled: true,
          fillColor: Colors.grey[250],
          suffixIcon: onTap != null ? IconButton(onPressed: onTap, icon: Icon(Icons.arrow_drop_down)) : null,
        ),
        validator: validator,
        onTap: onTap,
      ),
    );
  }

  InputBorder _inputBorder(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: color, width: 1.0),
    );
  }

  Future<void> _pickProduct() async {
    final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => ListProductScreen(isSelected: true,)));
    if (result != null) {
      setState(() {
        product = result;
        _controllers['nameProduct']!.text = product!.productName;
      });
    }
  }

  Future<void> _pickWarehouse() async {
    final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => ListWarehouseScreen(isSelected: true,)));
    if (result != null) {
      setState(() {
        warehouse = result;
        _controllers['nameWarehouse']!.text = warehouse!.name;
      });
    }
  }

  Widget _buildSubmitButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: SizedBox(
          width: double.infinity,
          height:50,
          child: ElevatedButton(
            child: Text('Create Goods Receipt', style: TextStyle(fontWeight: FontWeight.bold)),
            onPressed: _createGoodsReceipt,
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)
              ),
            ),
          )),
    );
  }
  String? _validateQuantity(String? value) {
    if (value == null || value.isEmpty) return 'Quantity is required';
    if (int.tryParse(value) == null || int.parse(value) < 0) return 'Invalid Quantity';
    return null;
  }

  String? _validateProduct(String? value) {
    if (value == null || value.isEmpty) return 'Product is required';
    return null;
  }

  String? _validateWarehouse(String? value) {
    if (value == null || value.isEmpty) return 'Warehouse is required';
    return null;
  }

  Future<void> _createGoodsReceipt() async {
    if (_formKey.currentState!.validate()) {
      final url = Uri.parse('https://manage-sale-microservice.onrender.com/api/transaction'); // Thay URL của bạn
      try {
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'product_id': product!.productId,
            'warehouse_id': warehouse!.id,
            'quantity': int.parse(_controllers['quantity']!.text),
            'transaction_type': 1
          }),
        );

        if (response.statusCode == 200) {
          // Thêm thành công
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Tạo phiếu xuất thành công!')),
          );
          Navigator.pop(context); // Quay lại màn hình trước
        } else {
          // Thêm thất bại
          final responseBody = json.decode(response.body);
          final errorMessage = responseBody['message'];
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Tạo phiếu xuất thất bại: $errorMessage')),
          );
        }
      } catch (e) {
        print('Error create goods receipt: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã xảy ra lỗi: $e')),
        );
      }
    }
  }
}