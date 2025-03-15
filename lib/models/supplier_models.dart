class Supplier {
  final int id;
  final String name;
  final String phone;
  final String email;
  final String address;
  final String city;
  final String country;

  Supplier(
    this.id,
    this.name,
    this.phone,
    this.email,
    this.address,
    this.city,
    this.country
  );

  factory Supplier.fromJson(Map<String, dynamic> json){
    return Supplier(
      json['supplier_id'], 
      json['supplier_name'],
      json['phone'], 
      json['email'], 
      json['address'],
      json['city'],
      json['country'],
    );
  }
}