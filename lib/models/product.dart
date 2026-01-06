import 'package:supabase_flutter/supabase_flutter.dart';

// ProductModel with search functionality
class ProductModel {
  final String name;
  final String description;
  final double price;
  final List<String> imageUrls;
  final String? categoryTitle;
  final double? rating;
  final int? reviewedCount;
  final String? brandName;
  final int? id;
  
  ProductModel({
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrls,
    this.categoryTitle,
    this.rating,
    this.reviewedCount,
    this.brandName,
    this.id,
  });
  
  // Factory constructor to parse JSON from Supabase
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as int?,
      name: json['name'] as String? ?? json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      imageUrls: _parseImageUrls(json),
      categoryTitle: json['category_title'] as String? ?? json['category'] as String?,
      rating: (json['rating'] as num?)?.toDouble(),
      reviewedCount: json['reviewed_count'] as int? ?? json['review_count'] as int?,
      brandName: json['brand_name'] as String? ?? json['brand'] as String?,
    );
  }
  
  // Helper to parse image URLs (can be string, array, or JSON)
  static List<String> _parseImageUrls(Map<String, dynamic> json) {
    final imageData = json['image_urls'] ?? json['images'] ?? json['image'];
    if (imageData == null) return [];
    
    if (imageData is String) {
      // Single image URL or comma-separated
      return imageData.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    } else if (imageData is List) {
      return imageData.map((e) => e.toString()).toList();
    }
    return [];
  }
  
  // Static methods for fetching products from Supabase
  // TODO: Update table name 'products' to match your actual Supabase table name
  static Future<List<ProductModel>> fetchFeaturedViews({required int limit, required int offset}) async {
    try {
      final response = await Supabase.instance.client
          .from('products') // ⚠️ Update this table name to match your Supabase table
          .select()
          .eq('is_featured', true) // Assuming you have an is_featured column
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);
      
      return (response as List).map((json) => ProductModel.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      // Fallback to dummy data if table doesn't exist or query fails
      return _generateDummyProducts(limit, offset, 'Featured');
    }
  }
  
  static Future<List<ProductModel>> fetchClicksViews({required int limit, required int offset}) async {
    try {
      final response = await Supabase.instance.client
          .from('products') // ⚠️ Update this table name
          .select()
          .order('views', ascending: false) // Assuming you have a views column
          .range(offset, offset + limit - 1);
      
      return (response as List).map((json) => ProductModel.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      return _generateDummyProducts(limit, offset, 'Popular');
    }
  }
  
  static Future<List<ProductModel>> fetchRecentViewedProducts({required int limit, required int offset}) async {
    try {
      final currentUser = Supabase.instance.client.auth.currentUser;
      if (currentUser == null) return [];
      
      // Assuming you have a user_product_views table
      final response = await Supabase.instance.client
          .from('user_product_views') // ⚠️ Update this table name
          .select('products(*)')
          .eq('user_id', currentUser.id)
          .order('viewed_at', ascending: false)
          .range(offset, offset + limit - 1);
      
      // Extract products from the joined response
      final products = <ProductModel>[];
      for (var item in response as List) {
        if (item['products'] != null) {
          products.add(ProductModel.fromJson(item['products'] as Map<String, dynamic>));
        }
      }
      return products;
    } catch (e) {
      return _generateDummyProducts(limit, offset, 'Recent');
    }
  }
  
  static Future<List<ProductModel>> fetchLatestProducts({required int limit, required int offset}) async {
    try {
      final response = await Supabase.instance.client
          .from('products') // ⚠️ Update this table name
          .select()
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);
      
      return (response as List).map((json) => ProductModel.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      return _generateDummyProducts(limit, offset, 'Latest');
    }
  }
  
  // Helper method to generate dummy products for testing
  static List<ProductModel> _generateDummyProducts(int limit, int offset, String prefix) {
    final products = <ProductModel>[];
    for (int i = 0; i < limit; i++) {
      final index = offset + i;
      products.add(ProductModel(
        name: '$prefix Product ${index + 1}',
        description: 'This is a description for $prefix product number ${index + 1}. It has great features and quality.',
        price: (100 + (index * 10)).toDouble(),
        imageUrls: [
          'https://picsum.photos/300/300?random=$index', // Random placeholder images
        ],
        categoryTitle: 'Category ${(index % 5) + 1}',
        rating: 4.0 + (index % 2) * 0.5,
        reviewedCount: 10 + (index * 3),
        brandName: 'Brand ${(index % 3) + 1}',
      ));
    }
    return products;
  }
  
  // Search method for ProductSearchCubit
  static Future<List<ProductModel>> search({
    int? brandId,
    List<int>? tagIds,
    List<int>? categoryIds,
    String? searchTerm,
    required int limit,
    required int offset,
  }) async {
    try {
      var query = Supabase.instance.client
          .from('products') // ⚠️ Update this table name
          .select();
      
      // Apply filters
      if (brandId != null) {
        query = query.eq('brand_id', brandId);
      }
      
      if (categoryIds != null && categoryIds.isNotEmpty) {
        query = query.inFilter('category_id', categoryIds);
      }
      
      if (searchTerm != null && searchTerm.isNotEmpty) {
        // Search in name or description (PostgreSQL text search)
        query = query.or('name.ilike.%$searchTerm%,description.ilike.%$searchTerm%');
      }
      
      // Apply tag filter if you have a product_tags junction table
      if (tagIds != null && tagIds.isNotEmpty) {
        // This requires a join or subquery - adjust based on your schema
        // Example: query = query.in_('tags', tagIds);
      }
      
      final response = await query
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);
      
      return (response as List).map((json) => ProductModel.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      // Fallback to dummy data
      await Future<void>.delayed(const Duration(milliseconds: 500));
      final allProducts = _generateDummyProducts(limit * 2, 0, 'Search');
      if (searchTerm != null && searchTerm.isNotEmpty) {
        return allProducts
            .where((p) => p.name.toLowerCase().contains(searchTerm.toLowerCase()))
            .take(limit)
            .toList();
      }
      return allProducts.take(limit).toList();
    }
  }
}

