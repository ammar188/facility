class Board {
  final int id;
  final String title;
  final String? description;
  final double? price;
  final String currency;
  final double? latitude;
  final double? longitude;
  final double? width;
  final double? height;
  final String status;
  final String slug;
  final int categoryId;
  final String ownerId;
  final int locationId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double? avgRating;
  final int totalRatings;

  Board({
    required this.id,
    required this.title,
    this.description,
    this.price,
    required this.currency,
    this.latitude,
    this.longitude,
    this.width,
    this.height,
    required this.status,
    required this.slug,
    required this.categoryId,
    required this.ownerId,
    required this.locationId,
    required this.createdAt,
    required this.updatedAt,
    this.avgRating,
    this.totalRatings = 0,
  });

  factory Board.fromJson(Map<String, dynamic> json) {
    return Board(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String?,
      price: json['price'] != null ? (json['price'] as num).toDouble() : null,
      currency: json['currency'] as String? ?? 'USD',
      latitude: json['latitude'] != null ? (json['latitude'] as num).toDouble() : null,
      longitude: json['longitude'] != null ? (json['longitude'] as num).toDouble() : null,
      width: json['width'] != null ? (json['width'] as num).toDouble() : null,
      height: json['height'] != null ? (json['height'] as num).toDouble() : null,
      status: json['status'] as String? ?? 'available',
      slug: json['slug'] as String,
      categoryId: json['category_id'] as int,
      ownerId: json['owner_id'] as String,
      locationId: json['location_id'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      avgRating: json['avg_rating'] != null ? (json['avg_rating'] as num).toDouble() : null,
      totalRatings: json['total_ratings'] as int? ?? 0,
    );
  }
}
