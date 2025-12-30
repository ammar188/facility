import 'api_service.dart';
import '../models/location.dart';
import '../config/app_config.dart';

class LocationService {
  final ApiService apiService;

  LocationService(this.apiService);

  /// Fetch all locations
  Future<List<Location>> getLocations() async {
    try {
      final response = await apiService.get(AppConfig.locationsEndpoint);
      
      if (response['success'] == true && response['data'] != null) {
        final data = response['data'];
        if (data is List) {
          return data.map((json) {
            try {
              return Location.fromJson(json as Map<String, dynamic>);
            } catch (e) {
              print('Error parsing location: $e');
              return null;
            }
          }).whereType<Location>().toList();
        }
      } else if (response['data'] is List) {
        final List<dynamic> data = response['data'] as List<dynamic>;
        return data.map((json) {
          try {
            return Location.fromJson(json as Map<String, dynamic>);
          } catch (e) {
            print('Error parsing location: $e');
            return null;
          }
        }).whereType<Location>().toList();
      }
      print('Locations response format not recognized: ${response.keys}');
      return [];
    } catch (e) {
      // Log error for debugging
      print('Error fetching locations: $e');
      rethrow; // Re-throw so the UI can show the error
    }
  }
}
