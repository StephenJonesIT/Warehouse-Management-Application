import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddProductScreen extends StatefulWidget {
  AddProductScreen();

  @override
  State<AddProductScreen> createState() => AddProductState();
}

class AddProductState extends State<AddProductScreen> {
  File? _image;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Product"),
        centerTitle: true,
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: InkWell(
          onTap: () => _showPicker(context), // Sửa ở đây
          highlightColor: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: _image == null
                    ? Image.asset(
                  'assets/photo_default.png',
                  width: 200,
                  height: 200,
                )
                    : ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(
                                        _image!,
                                        width: 250,
                                        height: 200,
                                        fit: BoxFit.cover,
                                      ),
                    ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min, // Để Row chỉ chiếm không gian cần thiết
                children: <Widget>[
                  Icon(Icons.launch_sharp), // Icon bạn muốn thêm
                  SizedBox(width: 8.0), // Khoảng cách giữa icon và text
                  Text("Choose an image"),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final returnedImage = await ImagePicker().pickImage(source: source);
      setState(() {
        if (returnedImage != null) {
          _image = File(returnedImage.path);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Không có ảnh nào được chọn.')),
          );
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi chọn ảnh: $e')),
      );
    }
  }

  void _showPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 150,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.photo),
                title: Text('Chọn ảnh từ thư viện'),
                onTap: () async {
                  try {
                    await _pickImage(ImageSource.gallery);
                    Navigator.of(context).pop();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Lỗi: $e')),
                    );
                  }
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Chụp ảnh từ Camera'),
                onTap: () async {
                  try {
                    await _pickImage(ImageSource.camera);
                    Navigator.of(context).pop();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Lỗi: $e')),
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}