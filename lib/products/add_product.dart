import 'dart:io';
import 'package:bai1/categories/list_category.dart';
import 'package:bai1/models/category_model.dart';
import 'package:bai1/models/supplier_models.dart';
import 'package:bai1/suppliers/list_supplier.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class AddProductScreen extends StatefulWidget {
  final List<String> allProductStatuses = [
    "Available",
    "Out of Stock",
    "Discontinued",
    "Pre-Order",
    "Back-Ordered",
    "Reserved",
    "On Sale",
    "New Arrival",
    "Damaged",
    "Pending",
  ];

  @override
  State<AddProductScreen> createState() => _AddProductState();
}

class _AddProductState extends State<AddProductScreen> {
  File? _image;
  Category? category;
  Supplier? supplier;
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {
    'name': TextEditingController(),
    'price': TextEditingController(),
    'discount': TextEditingController(),
    'unit': TextEditingController(),
    'description': TextEditingController(),
    'category': TextEditingController(),
    'supplier': TextEditingController(),
    'type': TextEditingController(),
  };
  String? selectedStatus;

  @override
  void initState() {
    super.initState();
    selectedStatus = widget.allProductStatuses[0];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Product"),
        centerTitle: true,
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildImagePicker(),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildTextField('Name Product', 'name', Icons.shopping_bag, validator: _validateRequired),
                      _buildTextField('Price', 'price', Icons.price_change, keyboardType: TextInputType.number, validator: _validatePrice),
                      _buildRowFields(),
                      _buildDropdownStatus(),
                      SizedBox(height: 20,),
                      _buildTextField('Unit', 'unit', Icons.straighten),
                      _buildTextField('Description', 'description', Icons.description, maxLines: 10),
                      _buildTextField('Category', 'category', Icons.category, readOnly: true, onTap: _pickCategory,validator: _validateRequired),
                      _buildTextField('Supplier', 'supplier', Icons.person, readOnly: true, onTap: _pickSupplier, validator: _validateRequired),
                      SizedBox(height: 20,),
                      _buildSubmitButton(),
                      SizedBox(height: 60,)
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return InkWell(
      onTap: () => _showPicker(context),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: _image == null
                ? Image.asset('assets/photo_default.png', width: 200, height: 200)
                : ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.file(_image!, width: 250, height: 200, fit: BoxFit.cover),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.launch_sharp),
              SizedBox(width: 8.0),
              Text("Choose an image"),
            ],
          ),
        ],
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

  Widget _buildRowFields() {
    return Row(
      children: [
        Expanded(child: _buildTextField('Discount', 'discount', Icons.discount, keyboardType: TextInputType.number, maxLines: 1,validator: validateDiscount)),
        SizedBox(width: 10),
        Expanded(child: _buildTextField('Type', 'type', Icons.tab, keyboardType: TextInputType.number, maxLines: 1,validator: validateType)),
      ],
    );
  }

  Widget _buildDropdownStatus() {
    return DropdownButtonFormField<String>(
      value: selectedStatus,
      items: widget.allProductStatuses.map((status) => DropdownMenuItem(value: status, child: Text(status))).toList(),
      onChanged: (value) => setState(() => selectedStatus = value),
      decoration: InputDecoration(
        labelText: 'Product Status',
        border: _inputBorder(Colors.blueGrey),
        filled: true,
        fillColor: Colors.grey[250],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
        width: double.infinity,
        height:50,
        child: ElevatedButton(
          child: Text('Add Product', style: TextStyle(fontWeight: FontWeight.bold)),
          onPressed: _uploadProduct,
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.pink,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)
          ),
    ),
    ));
  }

  InputBorder _inputBorder(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: color, width: 1.0),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final returnedImage = await ImagePicker().pickImage(source: source);
      if (returnedImage != null) {
        setState(() => _image = File(returnedImage.path));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No image selected.')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _showPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(Icons.photo),
            title: Text('Choose from gallery'),
            onTap: () async {
              await _pickImage(ImageSource.gallery);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.camera_alt),
            title: Text('Take a photo'),
            onTap: () async {
              await _pickImage(ImageSource.camera);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _pickCategory() async {
    final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => ListCategoryScreen(isSelected: true)));
    if (result != null) {
      setState(() {
        category = result;
        _controllers['category']!.text = category!.name;
      });
    }
  }

  Future<void> _pickSupplier() async {
    final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => ListSupplierScreen(isSelected: true)));
    if (result != null) {
      setState(() {
        supplier = result;
        _controllers['supplier']!.text = supplier!.name;
      });
    }
  }

  Future<void> _uploadProduct() async {
    if (_formKey.currentState!.validate() && _image != null) {
      var request = http.MultipartRequest('POST', Uri.parse('https://manage-sale-microservice.onrender.com/api/product'));
      request.fields.addAll({
        'name': _controllers['name']!.text,
        'price': _controllers['price']!.text,
        'discount': _controllers['discount']!.text,
        'type': _controllers['type']!.text,
        'unit': _controllers['unit']!.text,
        'status': selectedStatus!,
        'description': _controllers['description']!.text,
        'category': category!.id.toString(),
        'supplier': supplier!.id.toString(),
      });
      request.files.add(await http.MultipartFile.fromPath('image', _image!.path));

      var response = await request.send();
      if (response.statusCode == 201) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Product created successfully')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to create product')));
      }
    }
  }

  String? _validateRequired(String? value) {
    if (value == null || value.isEmpty) return 'This field is required';
    return null;
  }

  String? _validatePrice(String? value) {
    if (value == null || value.isEmpty) return 'Price is required';
    if (int.tryParse(value) == null || int.parse(value) < 0) return 'Invalid price';
    return null;
  }

  String? validateDiscount(String? discount) {
    int a = int.parse(discount!);
    if (discount == null) {
      return null; // Không bắt lỗi nếu discount là null
    } else if (a < 1 || a > 100) {
      return 'Discount must be between 1 and 100.';
    }
    return null; // Giá trị hợp lệ
  }

  String? validateType(String? type) {
    int a = int.parse(type!);
    if (type == null) {
      return null; // Không bắt lỗi nếu discount là null
    } else if (a < 1 || a > 9) {
      return 'Type must be between 1 and 9.';
    }
    return null; // Giá trị hợp lệ
  }
}