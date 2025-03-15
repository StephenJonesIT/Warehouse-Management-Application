import 'package:bai1/home.dart';
import 'package:bai1/setting.dart';
import 'package:bai1/suppliers/supplier.dart';
import 'package:bai1/warehouse.dart';
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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Warehouse Management'),
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
    WarehouseScreen(),
    SupplierScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: _selectedIndex == 0
        ? AppBar(

          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.title),
        )
        : null,
        body: _widgetOptions.elementAt(_selectedIndex),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
            BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: ''),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
            BottomNavigationBarItem(icon: Icon(Icons.settings), label: ''),
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
