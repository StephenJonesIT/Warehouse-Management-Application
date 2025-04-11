import 'package:bai1/home.dart';
import 'package:bai1/suppliers/supplier.dart';
import 'package:bai1/products/product.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: const MyHomePage(title: 'Inventory Management'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  // ignore: prefer_final_fields
  static List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    ProductScreen(),
    SupplierScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: _selectedIndex == 0
        ? AppBar(
          backgroundColor: Colors.blueAccent,
          title: Text(
            style: TextStyle(color: Colors.white),
            widget.title,
          ),
          foregroundColor: Colors.white,
          actions: [
            Icon(Icons.notification_important,),
            SizedBox(width: 20,)
          ],
        )
        : null,
        body: _widgetOptions.elementAt(_selectedIndex),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
            BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: ''),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.blue[800],
          unselectedItemColor: Colors.grey,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          onTap: (index) => setState(() {
            _selectedIndex = index;
          }),
        ));
  }
}
