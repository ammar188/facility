class Category {
  final int id;
  final String name;
  final String? description;
  final String? slug;

  Category({
    required this.id,
    required this.name,
    this.description,
    this.slug,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      slug: json['slug'] as String?,
    );
  }
}
