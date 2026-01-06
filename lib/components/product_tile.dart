import 'package:flutter/material.dart';

class ProductTile extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String description;
  final String? category;
  final double? estimatedPrice;
  final double rating;
  final int reviewCount;
  final String? brand;
  final VoidCallback? onTap;
  
  const ProductTile({
    required this.imageUrl,
    required this.title,
    required this.description,
    this.category,
    this.estimatedPrice,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.brand,
    this.onTap,
    super.key,
  });
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              imageUrl,
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 150,
                color: Colors.grey[300],
                child: const Icon(Icons.image),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  if (estimatedPrice != null)
                    Text('\$$estimatedPrice', style: const TextStyle(color: Colors.green)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

