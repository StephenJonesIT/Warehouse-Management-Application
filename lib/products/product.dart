import 'package:flutter/material.dart';

class ProductScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController( // Thêm DefaultTabController
      length: 3, // Số lượng tab
      child: Scaffold(
        appBar: AppBar(
          title: Text("Product",style: TextStyle(fontWeight: FontWeight.bold),),
          centerTitle: true,
          backgroundColor: Colors.pinkAccent,
          foregroundColor: Colors.white,
          bottom: TabBar(
            indicatorColor: Colors.white, // Màu của đường gạch chân
            labelColor: Colors.white, // Màu chữ của tab được chọn
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(icon: Icon(Icons.filter_list_alt), text: "All"),
              Tab(icon: Icon(Icons.directions_transit), text: "Transit"),
              Tab(icon: Icon(Icons.directions_bike), text: "Bike"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            Center(child: Text('Car Tab Content')),
            Center(child: Text('Transit Tab Content')),
            Center(child: Text('Bike Tab Content')),
          ],
        ),
      ),
    );
  }
}