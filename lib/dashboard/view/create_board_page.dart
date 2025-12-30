import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/board_service.dart';
import '../../services/auth_service.dart';
import '../../services/category_service.dart';
import '../../services/location_service.dart';
import '../../models/board.dart';
import '../../models/category.dart';
import '../../models/location.dart';
import '../../config/app_config.dart';

class CreateBoardPage extends StatefulWidget {
  const CreateBoardPage({super.key});

  @override
  State<CreateBoardPage> createState() => _CreateBoardPageState();
}

class _CreateBoardPageState extends State<CreateBoardPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _ownerIdController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  final _widthController = TextEditingController();
  final _heightController = TextEditingController();
  final _currencyController = TextEditingController(text: 'USD');

  bool _isLoading = false;
  bool _isLoadingData = true;
  String? _errorMessage;

  Category? _selectedCategory;
  Location? _selectedLocation;
  List<Category> _categories = [];
  List<Location> _locations = [];

  late final ApiService _apiService;
  late final BoardService _boardService;
  late final AuthService _authService;
  late final CategoryService _categoryService;
  late final LocationService _locationService;

  @override
  void initState() {
    super.initState();
    _authService = AuthService();
    _apiService = ApiService(
      baseUrl: AppConfig.backendUrl,
    );
    _boardService = BoardService(_apiService);
    _categoryService = CategoryService(_apiService);
    _locationService = LocationService(_apiService);
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    await _authService.initialize(); // This will load stored token if available
    final token = await _authService.getToken();
    if (token != null) {
      _apiService.setAuthToken(token);
    }
    await _loadCategoriesAndLocations();
  }

  Future<void> _loadCategoriesAndLocations() async {
    setState(() {
      _isLoadingData = true;
      _errorMessage = null;
    });

    try {
      print('Loading categories from: ${AppConfig.backendUrl}/api/categories');
      final categories = await _categoryService.getCategories();
      print('Loaded ${categories.length} categories');
      
      print('Loading locations from: ${AppConfig.backendUrl}/api/locations');
      final locations = await _locationService.getLocations();
      print('Loaded ${locations.length} locations');

      if (mounted) {
        setState(() {
          _categories = categories;
          _locations = locations;
          _isLoadingData = false;
          if (categories.isEmpty && locations.isEmpty) {
            _errorMessage = 'No categories or locations found. Please check your backend connection.';
          }
        });
      }
    } catch (e) {
      print('Error loading data: $e');
      if (mounted) {
        setState(() {
          _isLoadingData = false;
          _errorMessage = 'Failed to load categories and locations: $e\n\nBackend URL: ${AppConfig.backendUrl}';
        });
      }
    }
  }

  void _onLocationSelected(Location? location) {
    setState(() {
      _selectedLocation = location;
      // Note: Backend location data doesn't include latitude/longitude
      // You may need to get coordinates from a different source or make them optional
      if (location != null) {
        // Clear coordinates since they're not in the location response
        _latitudeController.clear();
        _longitudeController.clear();
      } else {
        _latitudeController.clear();
        _longitudeController.clear();
      }
    });
  }

  Future<void> _createBoard() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a category'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a location'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _boardService.createBoard(
        title: _titleController.text.trim(),
        categoryId: _selectedCategory!.id,
        ownerId: _ownerIdController.text.trim(),
        locationId: _selectedLocation!.id,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        price: _priceController.text.trim().isEmpty
            ? null
            : double.parse(_priceController.text.trim()),
        currency: _currencyController.text.trim().isEmpty
            ? null
            : _currencyController.text.trim(),
        latitude: _latitudeController.text.trim().isEmpty
            ? null
            : double.parse(_latitudeController.text.trim()),
        longitude: _longitudeController.text.trim().isEmpty
            ? null
            : double.parse(_longitudeController.text.trim()),
        width: _widthController.text.trim().isEmpty
            ? null
            : double.parse(_widthController.text.trim()),
        height: _heightController.text.trim().isEmpty
            ? null
            : double.parse(_heightController.text.trim()),
      );

      if (result['success'] == true && result['data'] != null) {
        final board = Board.fromJson(result['data']);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 12),
                  Text('Board created successfully!'),
                ],
              ),
              backgroundColor: const Color(0xFF8BC543),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
          _resetForm();
        }
      }
    } on ApiException catch (e) {
      String errorMessage = e.message;
      
      // Handle slug conflict error with helpful message
      if (e.message.contains('slug already exists') || 
          e.message.contains('slug') && e.message.contains('exists')) {
        errorMessage = 'A board with a similar title already exists.\n\n'
            'The slug (URL-friendly name) generated from your title conflicts with an existing board.\n\n'
            'Solution: Try adding something unique to your title, or the system will auto-generate a unique slug.';
      }
      
      setState(() {
        _errorMessage = errorMessage;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    errorMessage.contains('slug') 
                        ? 'Title conflict: Please use a more unique title'
                        : 'Error: ${e.message}',
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Unexpected error: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _resetForm() {
    _formKey.currentState!.reset();
    _titleController.clear();
    _descriptionController.clear();
    _priceController.clear();
    _ownerIdController.clear();
    _latitudeController.clear();
    _longitudeController.clear();
    _widthController.clear();
    _heightController.clear();
    _currencyController.text = 'USD';
    setState(() {
      _selectedCategory = null;
      _selectedLocation = null;
      _errorMessage = null;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _ownerIdController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _widthController.dispose();
    _heightController.dispose();
    _currencyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFFEAF245);
    const primaryText = Color(0xFF2D403C);
    const secondaryText = Color(0xFF7A7D86);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Enhanced Header
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  accent.withOpacity(0.1),
                  Colors.white,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey.shade200,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [accent, accent.withOpacity(0.8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: accent.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.add_business_rounded,
                    color: primaryText,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 20),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Create New Board',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: primaryText,
                          letterSpacing: -0.5,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Add a new advertising board to the platform',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Form Content
          Expanded(
            child: _isLoadingData
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 16),
                        Text(
                          'Loading categories and locations...',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Backend: ${AppConfig.backendUrl}',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  )
                : Builder(
                    builder: (context) {
                      try {
                        return SingleChildScrollView(
                          padding: const EdgeInsets.all(28),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                if (_errorMessage != null)
                                  _ErrorCard(
                                    message: _errorMessage!,
                                    onRetry: () => _loadCategoriesAndLocations(),
                                  ),
                                const SizedBox(height: 8),
                          // Basic Information Card
                          _FormCard(
                            title: 'Basic Information',
                            icon: Icons.info_outline_rounded,
                            children: [
                              _CustomTextField(
                                controller: _titleController,
                                label: 'Board Title',
                                hint: 'Enter board title',
                                icon: Icons.title_rounded,
                                isRequired: true,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Title is required';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),
                              _CustomTextField(
                                controller: _descriptionController,
                                label: 'Description',
                                hint: 'Enter board description (optional)',
                                icon: Icons.description_outlined,
                                maxLines: 4,
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          // Category & Ownership Card
                          _FormCard(
                            title: 'Category & Ownership',
                            icon: Icons.category_outlined,
                            children: [
                              _CustomDropdown<Category>(
                                label: 'Category',
                                hint: _categories.isEmpty 
                                    ? 'No categories available' 
                                    : 'Select a category',
                                icon: Icons.category_rounded,
                                isRequired: true,
                                value: _selectedCategory,
                                items: _categories,
                                onChanged: _categories.isEmpty 
                                    ? (_) {} 
                                    : (category) {
                                        setState(() {
                                          _selectedCategory = category;
                                        });
                                      },
                                displayText: (category) => category.name,
                              ),
                              if (_categories.isEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Row(
                                    children: [
                                      Icon(Icons.info_outline, 
                                        color: Colors.orange.shade600, 
                                        size: 16,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'Categories will appear here once loaded from the backend',
                                          style: TextStyle(
                                            color: Colors.orange.shade700,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              const SizedBox(height: 20),
                              _CustomTextField(
                                controller: _ownerIdController,
                                label: 'Owner ID (UUID)',
                                hint: 'Enter owner UUID',
                                icon: Icons.person_outline_rounded,
                                isRequired: true,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Owner ID is required';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          // Location Card
                          _FormCard(
                            title: 'Location',
                            icon: Icons.location_on_outlined,
                            children: [
                              _CustomDropdown<Location>(
                                label: 'Location',
                                hint: _locations.isEmpty 
                                    ? 'No locations available' 
                                    : 'Select a location',
                                icon: Icons.location_city_rounded,
                                isRequired: true,
                                value: _selectedLocation,
                                items: _locations,
                                onChanged: _locations.isEmpty 
                                    ? (_) {} 
                                    : _onLocationSelected,
                                displayText: (location) => location.displayName,
                              ),
                              if (_locations.isEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Row(
                                    children: [
                                      Icon(Icons.info_outline, 
                                        color: Colors.orange.shade600, 
                                        size: 16,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'Locations will appear here once loaded from the backend',
                                          style: TextStyle(
                                            color: Colors.orange.shade700,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          // Pricing Card
                          _FormCard(
                            title: 'Pricing',
                            icon: Icons.attach_money_rounded,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: _CustomTextField(
                                      controller: _priceController,
                                      label: 'Price',
                                      hint: '0.00',
                                      icon: Icons.currency_exchange_rounded,
                                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _CustomTextField(
                                      controller: _currencyController,
                                      label: 'Currency',
                                      hint: 'USD',
                                      icon: Icons.monetization_on_outlined,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          // Location Coordinates Card
                          _FormCard(
                            title: 'Coordinates',
                            icon: Icons.map_outlined,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: _CustomTextField(
                                      controller: _latitudeController,
                                      label: 'Latitude',
                                      hint: '24.8607',
                                      icon: Icons.navigation_outlined,
                                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _CustomTextField(
                                      controller: _longitudeController,
                                      label: 'Longitude',
                                      hint: '67.0011',
                                      icon: Icons.explore_outlined,
                                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          // Dimensions Card
                          _FormCard(
                            title: 'Dimensions',
                            icon: Icons.straighten_outlined,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: _CustomTextField(
                                      controller: _widthController,
                                      label: 'Width (meters)',
                                      hint: '2.5',
                                      icon: Icons.width_wide_outlined,
                                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _CustomTextField(
                                      controller: _heightController,
                                      label: 'Height (meters)',
                                      hint: '1.8',
                                      icon: Icons.height_outlined,
                                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                          // Action Buttons
                          Row(
                            children: [
                              Expanded(
                                child: _GradientButton(
                                  onPressed: _isLoading ? null : _createBoard,
                                  isLoading: _isLoading,
                                  label: 'Create Board',
                                  icon: Icons.add_circle_outline_rounded,
                                ),
                              ),
                              const SizedBox(width: 16),
                              _OutlinedActionButton(
                                onPressed: _isLoading ? null : _resetForm,
                                label: 'Clear',
                                icon: Icons.refresh_rounded,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  );
                      } catch (e) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.error_outline_rounded,
                                  size: 64,
                                  color: Colors.red.shade300,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'An error occurred',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.red.shade700,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  e.toString(),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      _isLoadingData = true;
                                    });
                                    _loadCategoriesAndLocations();
                                  },
                                  icon: const Icon(Icons.refresh),
                                  label: const Text('Retry'),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({
    required this.message,
    this.onRetry,
  });
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.shade200, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.error_outline_rounded, color: Colors.red.shade700, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    color: Colors.red.shade900,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Retry'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red.shade700,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _FormCard extends StatelessWidget {
  const _FormCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    const primaryText = Color(0xFF2D403C);
    const accent = Color(0xFFEAF245);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 22, color: primaryText),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: primaryText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }
}

class _CustomTextField extends StatelessWidget {
  const _CustomTextField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.isRequired = false,
    this.keyboardType,
    this.maxLines = 1,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final bool isRequired;
  final TextInputType? keyboardType;
  final int maxLines;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    const primaryText = Color(0xFF2D403C);
    const secondaryText = Color(0xFF7A7D86);
    const accent = Color(0xFFEAF245);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: primaryText,
              ),
            ),
            if (isRequired)
              const Text(
                ' *',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 14,
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          style: const TextStyle(
            color: primaryText,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: secondaryText.withOpacity(0.6),
              fontSize: 15,
            ),
            prefixIcon: Icon(icon, size: 22, color: secondaryText),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: accent, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.red.shade300),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.red.shade400, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 18,
            ),
          ),
        ),
      ],
    );
  }
}

class _CustomDropdown<T> extends StatelessWidget {
  const _CustomDropdown({
    required this.label,
    required this.hint,
    required this.icon,
    required this.value,
    required this.items,
    this.onChanged,
    required this.displayText,
    this.isRequired = false,
  });

  final String label;
  final String hint;
  final IconData icon;
  final T? value;
  final List<T> items;
  final ValueChanged<T?>? onChanged;
  final String Function(T) displayText;
  final bool isRequired;

  @override
  Widget build(BuildContext context) {
    const primaryText = Color(0xFF2D403C);
    const secondaryText = Color(0xFF7A7D86);
    const accent = Color(0xFFEAF245);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: primaryText,
              ),
            ),
            if (isRequired)
              const Text(
                ' *',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 14,
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: value == null ? Colors.grey.shade300 : accent,
              width: value == null ? 1 : 2,
            ),
          ),
          child: DropdownButtonFormField<T>(
            value: value,
            items: items.isEmpty
                ? [
                    DropdownMenuItem<T>(
                      value: null,
                      enabled: false,
                      child: Text(
                        'No items available',
                        style: TextStyle(
                          color: secondaryText.withOpacity(0.5),
                          fontSize: 15,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ]
                : items.map((T item) {
                    return DropdownMenuItem<T>(
                      value: item,
                      child: Text(
                        displayText(item),
                        style: const TextStyle(
                          color: primaryText,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: secondaryText.withOpacity(0.6),
                fontSize: 15,
              ),
              prefixIcon: Icon(icon, size: 22, color: secondaryText),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 18,
              ),
            ),
            icon: Icon(Icons.arrow_drop_down_rounded, color: secondaryText),
            dropdownColor: Colors.white,
            style: const TextStyle(color: primaryText),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ],
    );
  }
}

class _GradientButton extends StatelessWidget {
  const _GradientButton({
    required this.onPressed,
    required this.isLoading,
    required this.label,
    required this.icon,
  });

  final VoidCallback? onPressed;
  final bool isLoading;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFFEAF245);
    const primaryText = Color(0xFF2D403C);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [accent, accent.withOpacity(0.9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: accent.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          foregroundColor: primaryText,
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(primaryText),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 22),
                  const SizedBox(width: 10),
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _OutlinedActionButton extends StatelessWidget {
  const _OutlinedActionButton({
    required this.onPressed,
    required this.label,
    required this.icon,
  });

  final VoidCallback? onPressed;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    const secondaryText = Color(0xFF7A7D86);

    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: secondaryText,
        side: BorderSide(color: Colors.grey.shade300, width: 1.5),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 28),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
