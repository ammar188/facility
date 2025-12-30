import 'api_service.dart';
import '../models/category.dart';
import '../config/app_config.dart';

class CategoryService {
  final ApiService apiService;

  CategoryService(this.apiService);

  /// Fetch all categories
  Future<List<Category>> getCategories() async {
    try {
      final response = await apiService.get(AppConfig.categoriesEndpoint);
      
      if (response['success'] == true && response['data'] != null) {
        final data = response['data'];
        if (data is List) {
          return data.map((json) {
            try {
              return Category.fromJson(json as Map<String, dynamic>);
            } catch (e) {
              print('Error parsing category: $e');
              return null;
            }
          }).whereType<Category>().toList();
        }
      } else if (response['data'] is List) {
        final List<dynamic> data = response['data'] as List<dynamic>;
        return data.map((json) {
          try {
            return Category.fromJson(json as Map<String, dynamic>);
          } catch (e) {
            print('Error parsing category: $e');
            return null;
          }
        }).whereType<Category>().toList();
      }
      print('Categories response format not recognized: ${response.keys}');
      return [];
    } catch (e) {
      // Log error for debugging
      print('Error fetching categories: $e');
      rethrow; // Re-throw so the UI can show the error
    }
  }
}
