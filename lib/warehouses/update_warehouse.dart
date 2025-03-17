import 'dart:convert';
import 'package:bai1/models/warehouse_model.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class UpdateWarehouseScreen extends StatefulWidget{
  final Warehouse warehouse;
  UpdateWarehouseScreen({required this.warehouse});
  @override
  State<UpdateWarehouseScreen> createState() => UpdateWarehouseState();
}

class UpdateWarehouseState extends State<UpdateWarehouseScreen> {
  late TextEditingController _nameController;
  late TextEditingController _locationController;
  final _formKey = GlobalKey<FormState>();
  bool isEdit = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.warehouse.name);
    _locationController =
        TextEditingController(text: widget.warehouse.location);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Update Warehouse", style: TextStyle(fontWeight: FontWeight.bold),),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
              onPressed: isEdit
                  ? () {
                _updateWarehouse();
              }
                  : () {
                setState(() {
                  isEdit = true;
                });
              },
              icon: isEdit ? Icon(Icons.check) : Icon(Icons.edit)
          )
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
                    decoration: InputDecoration(
                        labelText: 'Name',
                        enabled: isEdit,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)
                        ),
                        prefixIcon: Icon(Icons.drive_file_rename_outline)
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a warehouse name.';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 35,),
                  TextFormField(
                    controller: _locationController,
                    decoration: InputDecoration(
                        labelText: 'Location',
                        enabled: isEdit,
                        prefixIcon: Icon(Icons.location_city),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)
                        )
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a warehouse location';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 35,),
                  LayoutBuilder(
                      builder: (context, constraints) {
                        return IntrinsicHeight(
                          child: SizedBox(
                            width: constraints.maxWidth,
                            child: Visibility(
                              visible: isEdit,
                              child: ElevatedButton(
                                onPressed: () => _updateWarehouse,
                                child: Text("Update Warehouse",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold),),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.pink,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10))
                                    )
                                ),
                              ),
                            ),
                          ),
                        );
                      }
                  )
                ],
              )
          ),
        ),
      ),
    );
  }

  Future<void> _updateWarehouse() async {
    if (_formKey.currentState!.validate()) {
      final url = Uri.parse(
          "http://10.0.2.2:8810/api/warehouse/${widget.warehouse.id}");
      try {
        final response = await http.put(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'Warehouse_Name': _nameController.text,
            'Location': _locationController.text,
          }),
        );

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Warehouse updated successfully!')),
          );
          Navigator.of(context).pop(true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update warehouse. Status code: ${response.statusCode}')),
          );
          print('Error updating warehouse. Status code: ${response.statusCode}, Body: ${response.body}'); //In ra log để debug
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating warehouse: $e')),
        );
        print('Error updating warehouse: $e'); //In ra log để debug
      }
    }
  }
}