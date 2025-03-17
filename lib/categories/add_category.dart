import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddCategoryScreen extends StatefulWidget{
  AddCategoryScreen();
  @override
  State<AddCategoryScreen> createState() => _AddCategoryState();
}

class _AddCategoryState extends State<AddCategoryScreen>{
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String? _errorName;
  String? _errorDescription;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          foregroundColor: Colors.white,
          backgroundColor: Colors.pink,
          title: Text("Add Category", style: TextStyle(fontWeight: FontWeight.bold),),
          centerTitle: true,
          leading: IconButton(onPressed: ()=> Navigator.pop(context), icon: Icon(Icons.clear)),
          actions: [
            IconButton(onPressed: (){
              _addCategory();
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
              validator: (valua) {
                if (valua == null || valua.isEmpty) {
                  setState(() {
                    _errorName = 'Please enter a category name.';
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
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    errorText: _errorDescription,
                    suffixIcon: _errorDescription != null
                        ? Icon(Icons.error, color: Colors.red)
                        : _descriptionController.text.isNotEmpty // Check if text is not empty
                        ? Icon(Icons.check, color: Colors.green)
                        : null,
                    labelText: 'Description',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value){
                    if(value == null ||value.isEmpty){
                      setState(() {
                        _errorDescription = 'Please enter a category description.';
                      });
                      return '';
                    }else{
                      setState(() {
                        _errorDescription = null;
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
                                  borderRadius: BorderRadius.all(Radius.circular(4))
                              )
                          ),
                          onPressed: _addCategory,
                          child: Text('Add Category', style: TextStyle(fontWeight: FontWeight.bold),),
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
  Future<void> _addCategory() async {
    if (_formKey.currentState!.validate()) {
      final url = Uri.parse('http://10.0.2.2:8810/api/category'); // Thay URL của bạn
      try {
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'category_name': _nameController.text,
            'description': _descriptionController.text,
          }),
        );

        if (response.statusCode == 201) {
          // Thêm thành công
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Category added successfully!')),
          );
          Navigator.of(context).pop(true); // Quay lại màn hình trước
        } else {
          // Thêm thất bại
          final responseBody = json.decode(response.body);
          final errorMessage = responseBody['message'];
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to add category: $errorMessage')),
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