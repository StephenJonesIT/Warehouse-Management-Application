import 'dart:convert';
import 'package:bai1/models/category_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class UpdateCategoryScreen extends StatefulWidget{
  final Category category;
  UpdateCategoryScreen({required this.category});
  @override
  State<UpdateCategoryScreen> createState() => _UpdateCategoryState();
}
class _UpdateCategoryState extends State<UpdateCategoryScreen>{
  bool isEdit = false;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  String? _errorName;
  String? _errorDescription;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category.name);
    _descriptionController = TextEditingController(text: widget.category.description);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Colors.pink,
        title: Text("Update Category", style: TextStyle(fontWeight: FontWeight.bold),),
        centerTitle: true,
        leading: IconButton(onPressed: ()=> Navigator.pop(context), icon: Icon(Icons.clear)),
        actions: [
          IconButton(onPressed: isEdit 
              ? (){ _updateCategory();}
              : (){setState(() {
                  isEdit = true;
              });}
          , icon: isEdit ? Icon(Icons.check): Icon(Icons.edit))
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
                  enabled: isEdit,
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
                  enabled: isEdit,
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
                        child: Visibility(
                          visible: isEdit,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.pink,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(4))
                                )
                            ),
                            onPressed: ()=>_updateCategory(),
                            child: Text('Update Category', style: TextStyle(fontWeight: FontWeight.bold),),
                          ),
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

  Future<void> _updateCategory() async {
    if (_formKey.currentState!.validate()) {
      final url = Uri.parse('http://10.0.2.2:8810/api/category/${widget.category.id}'); // Thay URL của bạn
      try {
        final response = await http.put(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'category_name': _nameController.text,
            'description': _descriptionController.text,
          }),
        );

        if (response.statusCode == 200) {
          // Thêm thành công
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Category updated successfully!')),
          );
          Navigator.of(context).pop(true); // Quay lại màn hình trước
        } else {
          // Thêm thất bại
          final responseBody = json.decode(response.body);
          final errorMessage = responseBody['message'];
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update category: $errorMessage')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred: $e')),
        );
      }
    }
  }
}