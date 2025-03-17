class Warehouse {
  final int id;
  final String name;
  final String location;

  Warehouse({required this.id, required this.name, required this.location});

  factory Warehouse.fromJson(Map<String, dynamic> json){
    return Warehouse(
        id: json['warehouse_id'],
        name: json['warehouse_name'],
        location: json['location']
    );
  }
}