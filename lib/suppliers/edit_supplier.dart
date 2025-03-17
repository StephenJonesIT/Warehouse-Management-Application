import 'dart:convert';

import 'package:bai1/models/supplier_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

class EditSupplierScreen extends StatefulWidget{
  final Supplier supllier;
  EditSupplierScreen({required this.supllier});

  @override
  State<EditSupplierScreen> createState() => _EditSupplierState();
}

class _EditSupplierState extends State<EditSupplierScreen>{
  bool isEnable = false;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _emailController;
  late TextEditingController _cityController;
  late TextEditingController _nationalController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.supllier.name);
    _phoneController = TextEditingController(text: widget.supllier.phone);
    _emailController = TextEditingController(text: widget.supllier.email);
    _addressController = TextEditingController(text: widget.supllier.address);
    _cityController = TextEditingController(text: widget.supllier.city);
    _nationalController = TextEditingController(text: widget.supllier.country);
  }

  Future<void> _updateSupplier() async {
    if (_formKey.currentState!.validate()) {
      final url = Uri.parse('http://10.0.2.2:8810/api/supplier/${widget.supllier.id}'); // Thay URL của bạn
      try {
        final response = await http.put(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'supplier_name': _nameController.text,
            'phone': _phoneController.text,
            'address': _addressController.text,
            'email': _emailController.text,
            'city': _cityController.text,
            'country': _nationalController.text,
          }),
        );

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Cập nhật nhà cung cấp thành công!')),
          );
          Navigator.of(context).pop(true); // Trả về true
        } else {
          final responseBody = json.decode(response.body);
          final errorMessage = responseBody['message'];
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Cập nhật nhà cung cấp thất bại: $errorMessage')),
          );
        }
      } catch (e) {
        print('Error updating supplier: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã xảy ra lỗi: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            title: Text("Edit Supplier", style: TextStyle(fontWeight: FontWeight.bold),),
            leading: BackButton(),
            actions: [
              IconButton(onPressed: (){
                  setState(() {
                    isEnable = true;
                  });
              }, icon: Icon(Icons.edit))
            ],
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 16, bottom: 16),
                      child: TextFormField(
                        enabled: isEnable,
                        controller: _nameController,
                        decoration: InputDecoration(
                            prefixIcon: Icon(Icons.person),
                            labelText: 'Name Supplier',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10)
                            )
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter name supplier';
                          }
                          return null;
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 16),
                      child: TextFormField(
                        enabled: isEnable,
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                            prefixIcon: Icon(Icons.email),
                            labelText: 'Email',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10)
                            )
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter email supplier';
                          } else if (!RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$')
                              .hasMatch(value)) {
                            return 'Please enter a valid email address';
                          }
                          return null;
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              enabled: isEnable,
                              controller: _nationalController,
                              decoration: InputDecoration(
                                prefixIcon: Icon(Icons.flag),
                                labelText: 'National',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter national';
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: TextFormField(
                              enabled: isEnable,
                              controller: _cityController,
                              decoration: InputDecoration(
                                prefixIcon: Icon(Icons.location_city),
                                labelText: 'City',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter city';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 16),
                      child: TextFormField(
                        enabled: isEnable,
                        controller: _addressController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                            prefixIcon: Icon(Icons.place),
                            labelText: 'Address',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10)
                            )
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter address supplier';
                          }
                          return null;
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 16, bottom: 16),
                      child: TextFormField(
                        enabled: isEnable,
                        maxLength: 11,
                        keyboardType: TextInputType.phone,
                        controller: _phoneController,
                        decoration: InputDecoration(
                            prefixIcon: Icon(Icons.phone),
                            labelText: 'Phone',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10)
                            )
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter phone supplier';
                          } else if (value.length < 10 || value.length > 11) {
                            return 'Please enter a valid phone number';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(height: 20),
                    LayoutBuilder(
                      builder: (context, constraints){
                        return IntrinsicHeight(
                          child: SizedBox(
                            width: constraints.maxWidth,
                            child: Visibility(
                              visible: isEnable,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    backgroundColor: Colors.green[500],
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(Radius.circular(4))
                                    )
                                ),
                                onPressed: _updateSupplier,
                                child: Text('Edit Supplier'),
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
        )
    );
  }
}