import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class AddSupplierScreen extends StatefulWidget {
  @override
  State<AddSupplierScreen> createState() {
    return _AddSupplierState();
  }
}

class _AddSupplierState extends State<AddSupplierScreen>{
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _nationalController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            title: Text("Add Supplier", style: TextStyle(fontWeight: FontWeight.bold),),
            leading: BackButton(),
            actions: [

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
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                            prefixIcon: Icon(Icons.email),
                            labelText: 'Email Supplier',
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
                        controller: _addressController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                            prefixIcon: Icon(Icons.place),
                            labelText: 'Address Supplier',
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
                        maxLength: 11,
                        keyboardType: TextInputType.phone,
                        controller: _phoneController,
                        decoration: InputDecoration(
                            prefixIcon: Icon(Icons.phone),
                            labelText: 'Phone Supplier',
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
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: Colors.green[500],
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(Radius.circular(4))
                                  )
                              ),
                              onPressed: _addSupplier,
                              child: Text('Add Supplier', style: TextStyle(fontWeight: FontWeight.bold),),
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

  Future<void> _addSupplier() async {
    if (_formKey.currentState!.validate()) {
      final url = Uri.parse('https://manage-sale-microservice.onrender.com/api/supplier'); // Thay URL của bạn
      try {
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'supplier_name': _nameController.text,
            'phone': _phoneController.text,
            'address': _addressController.text,
            'email': _emailController.text,
            'city': _cityController.text,
            'country': _nationalController.text
          }),
        );

        if (response.statusCode == 201) {
          // Thêm thành công
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Thêm nhà cung cấp thành công!')),
          );
          Navigator.pop(context, true); // Quay lại màn hình trước
        } else {
          // Thêm thất bại
          final responseBody = json.decode(response.body);
          final errorMessage = responseBody['message'];
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Thêm nhà cung cấp thất bại: $errorMessage')),
          );
        }
      } catch (e) {
        print('Error adding supplier: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã xảy ra lỗi: $e')),
        );
      }
    }
  }
}
