import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddWarehouseScreen extends StatefulWidget{
  AddWarehouseScreen();
  @override
  State<AddWarehouseScreen> createState() => _AddWarehouseState();
}

class _AddWarehouseState extends State<AddWarehouseScreen>{
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  String? _errorName;
  String? _errorLocation;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.black,
        backgroundColor: Colors.white,
        title: Text("Add Warehouse", style: TextStyle(fontWeight: FontWeight.bold),),
        centerTitle: true,
        leading: IconButton(onPressed: ()=> Navigator.pop(context), icon: Icon(Icons.clear)),
        actions: [
          IconButton(onPressed: (){
            _addWarehouse();
          }, icon: Icon(Icons.check))
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(height: 50,),
                TextFormField(
                  controller: _nameController,
                  maxLength: 50,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    errorText: _errorName,
                    suffixIcon: _errorName != null
                        ? Icon(Icons.error, color: Colors.red)
                        : _nameController.text.isNotEmpty // Check if text is not empty
                        ? Icon(Icons.check, color: Colors.green)
                        : null, // Display null when text is empty
                    contentPadding: EdgeInsets.only(bottom: 0, left: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      setState(() {
                        _errorName = 'Please enter a Warehouse name.';
                      });
                      return '';
                    } else {
                      setState(() {
                        _errorName = null;
                      });
                      return null;
                    }
                  },
                ),
                SizedBox(height: 20,),
                TextFormField(
                  minLines: 1,
                  maxLines: 10,
                  controller: _locationController,
                  decoration: InputDecoration(
                    errorText: _errorLocation,
                    prefixIcon: Icon(Icons.location_city),
                    suffixIcon: _errorLocation != null
                        ? Icon(Icons.error, color: Colors.red)
                        : _locationController.text.isNotEmpty // Check if text is not empty
                        ? Icon(Icons.check, color: Colors.green)
                        : null,
                    labelText: 'Location',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value){
                    if(value == null ||value.isEmpty){
                      setState(() {
                        _errorLocation = 'Please enter a warehouse location.';
                      });
                      return '';
                    }else{
                      setState(() {
                        _errorLocation = null;
                      });
                      return null;
                    }
                  },
                ),
                SizedBox(height: 40,),
                LayoutBuilder(
                  builder: (context, constraints){
                    return IntrinsicHeight(
                      child: SizedBox(
                        width: constraints.maxWidth,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.pink,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(8))
                              )
                          ),
                          onPressed: _addWarehouse,
                          child: Text('Add Warehouse', style: TextStyle(fontWeight: FontWeight.bold),),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  Future<void> _addWarehouse() async {
    if (_formKey.currentState!.validate()) {
      final url = Uri.parse('http://10.0.2.2:8810/api/warehouse'); // Thay URL của bạn
      try {
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'Warehouse_Name': _nameController.text,
            'Location': _locationController.text,
          }),
        );

        if (response.statusCode == 201) {
          // Thêm thành công
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Warehouse added successfully!')),
          );
          Navigator.of(context).pop(true); // Quay lại màn hình trước
        } else {
          // Thêm thất bại
          final responseBody = json.decode(response.body);
          final errorMessage = responseBody['message'];
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to add warehouse: $errorMessage')),
          );
        }
      } catch (e) {
        print('Error adding supplier: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred: $e')),
        );
      }
    }
  }
}