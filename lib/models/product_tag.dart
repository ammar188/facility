// ProductTag model
class ProductTag {
  final int id;
  final String tagName;
  
  ProductTag({
    required this.id,
    required this.tagName,
  });
  
  factory ProductTag.fromJson(Map<String, dynamic> json) {
    return ProductTag(
      id: json['id'] as int,
      tagName: json['tag_name'] as String? ?? json['name'] as String? ?? '',
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tag_name': tagName,
    };
  }
}

