class AppConfig {
  // Backend URL - Update this to match your backend
  // For local development (same machine): 'http://localhost:3000'
  // For local network: 'http://192.168.18.110:3000'
  // For production: 'https://adryd-backend.onrender.com'
  static const String backendUrl = 'http://localhost:3000';
  
  // API Endpoints - Update these if your backend uses different paths
  // Common variations:
  // - '/api/categories' (default)
  // - '/categories'
  // - '/v1/categories'
  // - '/boards/categories'
  static const String categoriesEndpoint = '/api/categories';
  static const String locationsEndpoint = '/api/location/locations';  // Updated to match backend
  static const String createBoardEndpoint = '/api/admin/boards';
  
  // Note: Supabase is not needed if your backend handles authentication
  // Remove supabase_flutter dependency if not using Supabase
}
