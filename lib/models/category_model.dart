class Category {
  final int id;
  final String name;
  final String description;

  Category({required this.id, required this.name, required this.description});

  factory Category.fromJson(Map<String, dynamic> json){
    return Category(
        id: json['category_id'],
        name: json['category_name'],
        description: json['description']);
  }
}