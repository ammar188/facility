import 'api_service.dart';
import '../config/app_config.dart';

class BoardService {
  final ApiService apiService;

  BoardService(this.apiService);

  /// Generate a URL-friendly slug from a title
  /// Example: "My Board Title" -> "my-board-title-12345678"
  /// Adds timestamp suffix to ensure uniqueness
  static String generateSlug(String title) {
    // Convert to lowercase
    String slug = title.toLowerCase();
    
    // Replace spaces and special characters with hyphens
    slug = slug.replaceAll(RegExp(r'[^\w\s-]'), ''); // Remove special chars
    slug = slug.replaceAll(RegExp(r'\s+'), '-'); // Replace spaces with hyphens
    slug = slug.replaceAll(RegExp(r'-+'), '-'); // Replace multiple hyphens with single
    slug = slug.trim().replaceAll(RegExp(r'^-+|-+$'), ''); // Remove leading/trailing hyphens
    
    // Add timestamp suffix (last 8 digits) to ensure uniqueness
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final suffix = timestamp.length > 8 
        ? timestamp.substring(timestamp.length - 8)
        : timestamp;
    slug = '$slug-$suffix';
    
    return slug;
  }

  /// Create a new board (Admin only)
  /// 
  /// Required fields:
  /// - title: Board title
  /// - category_id: ID of the board category
  /// - owner_id: Supabase user UUID of the board owner
  /// - location_id: ID of the location
  /// 
  /// Optional fields:
  /// - description: Board description
  /// - price: Price in decimal
  /// - currency: Currency code (default: "USD")
  /// - latitude: Latitude coordinate
  /// - longitude: Longitude coordinate
  /// - width: Board width
  /// - height: Board height
  /// - status: Board status (default: "available")
  /// - slug: Custom slug (if not provided, auto-generated from title)
  /// - metadata: Additional metadata as Map
  Future<Map<String, dynamic>> createBoard({
    required String title,
    required int categoryId,
    required String ownerId,
    required int locationId,
    String? description,
    double? price,
    String? currency,
    double? latitude,
    double? longitude,
    double? width,
    double? height,
    String? status,
    String? slug,
    Map<String, dynamic>? metadata,
  }) async {
    // Generate slug from title if not provided
    final finalSlug = slug ?? generateSlug(title);
    
    final body = <String, dynamic>{
      'title': title,
      'slug': finalSlug, // Include slug to ensure uniqueness
      'category_id': categoryId,
      'owner_id': ownerId,
      'location_id': locationId,
    };

    // Add optional fields only if provided
    if (description != null && description.isNotEmpty) {
      body['description'] = description;
    }
    if (price != null) {
      body['price'] = price;
    }
    if (currency != null) {
      body['currency'] = currency;
    }
    if (latitude != null) {
      body['latitude'] = latitude;
    }
    if (longitude != null) {
      body['longitude'] = longitude;
    }
    if (width != null) {
      body['width'] = width;
    }
    if (height != null) {
      body['height'] = height;
    }
    if (status != null) {
      body['status'] = status;
    }
    if (metadata != null) {
      body['metadata'] = metadata;
    }

    return await apiService.post(AppConfig.createBoardEndpoint, body);
  }
}
