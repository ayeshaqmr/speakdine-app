class CategoryModel {
  String? id;
  String name;
  String? description;
  bool isAvailable;

  CategoryModel({
    this.id,
    required this.name,
    this.description,
    this.isAvailable = true,
  });

  factory CategoryModel.fromMap(Map<String, dynamic> data, String documentId) {
    return CategoryModel(
      id: documentId,
      name: data['name'] ?? '',
      description: data['description'],
      isAvailable: data['is_available'] ?? true,
    );
  }

  CategoryModel copyWith({
    String? id,
    String? name,
    String? description,
    bool? isAvailable,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }


  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'is_available': isAvailable,
    };
  }
}
