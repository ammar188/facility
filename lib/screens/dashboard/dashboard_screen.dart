import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      body: Row(
        children: [
          // Left Sidebar - 20% width
          SizedBox(
            width: screenWidth * 0.2,
            child: Container(
              color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFF2C2C2C),
              child: Column(
                children: [
                  // Search bar in sidebar
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF2C2C2C) : const Color(0xFF3A3A3A),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextField(
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search',
                          hintStyle: TextStyle(color: Colors.white54),
                          prefixIcon: Icon(Icons.search, color: Colors.white54, size: 20),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                      ),
                    ),
                  ),
                  // Navigation items
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        _buildNavItem(context, 'Dashboard', Icons.home, isActive: true),
                        _buildNavItem(context, 'Profile', Icons.person),
                        _buildNavItem(context, 'Exercise', Icons.fitness_center),
                        _buildNavItem(context, 'Settings', Icons.settings),
                        _buildNavItem(context, 'History', Icons.history),
                        _buildNavItem(context, 'Signout', Icons.logout),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Main Content Area - 80% width
          Expanded(
            child: Container(
              color: isDark ? const Color(0xFF121212) : const Color(0xFFF5F5F5),
              child: SingleChildScrollView(
                padding: EdgeInsets.all(screenWidth * 0.02),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top search bar
                    Container(
                      width: screenWidth * 0.3,
                      height: 40,
                      margin: EdgeInsets.only(bottom: screenHeight * 0.02),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextField(
                        style: TextStyle(
                          color: isDark ? Colors.white70 : Colors.black87,
                          fontSize: 14,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search',
                          hintStyle: TextStyle(color: isDark ? Colors.white54 : Colors.black54),
                          prefixIcon: Icon(Icons.search, color: isDark ? Colors.white54 : Colors.black54, size: 20),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                      ),
                    ),
                    // Metrics cards row
                    Row(
                      children: [
                        Expanded(child: _buildMetricCard(context, '305 Calories burned', Icons.local_fire_department, Colors.orange)),
                        SizedBox(width: screenWidth * 0.01),
                        Expanded(child: _buildMetricCard(context, '10,983 Steps', Icons.directions_walk, Colors.blue)),
                        SizedBox(width: screenWidth * 0.01),
                        Expanded(child: _buildMetricCard(context, '7km Distance', Icons.directions_run, Colors.green)),
                        SizedBox(width: screenWidth * 0.01),
                        Expanded(child: _buildMetricCard(context, '7h48m Sleep', Icons.bedtime, Colors.purple)),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.03),
                    // Steps Overview Graph
                    Container(
                      width: double.infinity,
                      height: screenHeight * 0.3,
                      padding: EdgeInsets.all(screenWidth * 0.015),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Steps Overview',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.02),
                          Expanded(
                            child: _buildLineChart(context),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.03),
                    // Bottom section with charts and profile
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left column - Bar charts
                        Expanded(
                          flex: 2,
                          child: Column(
                            children: [
                              _buildBarChart(context, 'Activity Level', Colors.orange, [5, 7, 6, 8, 7, 9]),
                              SizedBox(height: screenHeight * 0.02),
                              _buildBarChart(context, 'Nutrition', Colors.pink, [6, 8, 7, 9, 8, 10]),
                              SizedBox(height: screenHeight * 0.02),
                              _buildBarChart(context, 'Hydration Level', Colors.blue, [7, 9, 8, 10, 9, 11]),
                            ],
                          ),
                        ),
                        SizedBox(width: screenWidth * 0.02),
                        // Right column - Profile and Schedule
                        Expanded(
                          flex: 1,
                          child: Column(
                            children: [
                              _buildProfileCard(context),
                              SizedBox(height: screenHeight * 0.02),
                              _buildScheduleCard(context),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, String title, IconData icon, {bool isActive = false}) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF4FD1C7) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(icon, color: isActive ? Colors.white : Colors.white70, size: 20),
        title: Text(
          title,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.white70,
            fontSize: 14,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        onTap: () {},
      ),
    );
  }

  Widget _buildMetricCard(BuildContext context, String value, IconData icon, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.015),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLineChart(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Simple line chart representation
    return CustomPaint(
      painter: LineChartPainter(isDark),
      child: Container(),
    );
  }

  Widget _buildBarChart(BuildContext context, String title, Color color, List<int> values) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Container(
      padding: EdgeInsets.all(screenWidth * 0.015),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (int i = 0; i < values.length; i++)
                Column(
                  children: [
                    Container(
                      width: screenWidth * 0.015,
                      height: values[i] * 8.0,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      ['M', 'T', 'W', 'T', 'F', 'S'][i],
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Container(
      padding: EdgeInsets.all(screenWidth * 0.015),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.yellow.shade700,
            child: Icon(Icons.person, size: 40, color: Colors.white),
          ),
          SizedBox(height: 12),
          Text(
            'Summer',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Edit health details',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildProfileDetail(context, '53kg', 'Weight'),
              _buildProfileDetail(context, '162cm', 'Height'),
              _buildProfileDetail(context, 'O+', 'Blood Type'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileDetail(BuildContext context, String value, String label) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.white70 : Colors.black54,
          ),
        ),
      ],
    );
  }

  Widget _buildScheduleCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Container(
      padding: EdgeInsets.all(screenWidth * 0.015),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Scheduled',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          SizedBox(height: 16),
          _buildScheduleItem(context, 'Hatha Yoga', 'Today, 9AM - 10AM'),
          SizedBox(height: 12),
          _buildScheduleItem(context, 'Body Combat', 'Tomorrow, 5PM - 6PM'),
          SizedBox(height: 12),
          _buildScheduleItem(context, 'Hatha Yoga', 'Wednesday, 9AM - 10AM'),
        ],
      ),
    );
  }

  Widget _buildScheduleItem(BuildContext context, String title, String time) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              SizedBox(height: 4),
              Text(
                time,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
            ],
          ),
        ),
        Icon(Icons.more_vert, color: isDark ? Colors.white54 : Colors.black54, size: 20),
      ],
    );
  }
}

// Custom painter for line chart
class LineChartPainter extends CustomPainter {
  final bool isDark;
  
  LineChartPainter(this.isDark);
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isDark ? Colors.white24 : Colors.black26
      ..strokeWidth = 1.0;
    
    // Draw grid lines
    for (int i = 0; i <= 4; i++) {
      final y = size.height * (i / 4);
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
    
    // Draw months on x-axis
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );
    
    for (int i = 0; i < months.length; i++) {
      textPainter.text = TextSpan(
        text: months[i],
        style: TextStyle(
          fontSize: 10,
          color: isDark ? Colors.white54 : Colors.black54,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(size.width * (i / months.length) - textPainter.width / 2, size.height - 20),
      );
    }
    
    // Draw line chart
    final linePaint = Paint()
      ..color = const Color(0xFF4FD1C7)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    
    final points = [
      Offset(size.width * 0.0, size.height * 0.7),
      Offset(size.width * 0.2, size.height * 0.5),
      Offset(size.width * 0.3, size.height * 0.4),
      Offset(size.width * 0.4, size.height * 0.3),
      Offset(size.width * 0.5, size.height * 0.35),
      Offset(size.width * 0.6, size.height * 0.3),
      Offset(size.width * 0.7, size.height * 0.4),
      Offset(size.width * 0.8, size.height * 0.5),
      Offset(size.width * 0.9, size.height * 0.6),
      Offset(size.width * 1.0, size.height * 0.55),
    ];
    
    final path = Path();
    path.moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(path, linePaint);
    
    // Draw points
    final pointPaint = Paint()
      ..color = const Color(0xFF4FD1C7)
      ..style = PaintingStyle.fill;
    
    for (final point in points) {
      canvas.drawCircle(point, 3, pointPaint);
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
