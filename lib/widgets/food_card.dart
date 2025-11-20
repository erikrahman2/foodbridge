// lib/widgets/food_card.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../utils/constants.dart';
import '../providers/favorite_provider.dart';

class FoodCard extends StatelessWidget {
  final String id;
  final String title;
  final double rating;
  final String time;
  final int price;
  final int? discount;
  final String? imagePath;
  final VoidCallback? onTap;

  const FoodCard({
    super.key,
    required this.id,
    required this.title,
    required this.rating,
    required this.time,
    required this.price,
    this.discount,
    this.imagePath,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<FavoriteProvider>(
      builder: (context, favoriteProvider, child) {
        final isFavorite = favoriteProvider.isFavorite(id);

        return GestureDetector(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImageSection(isFavorite, favoriteProvider, context),
                _buildContentSection(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildImageSection(
    bool isFavorite,
    FavoriteProvider favoriteProvider,
    BuildContext context,
  ) {
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.all(14),
          height: 160,
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFFC9A89C),
            borderRadius: BorderRadius.circular(18),
          ),
          child:
              imagePath != null && imagePath!.isNotEmpty
                  ? ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: CachedNetworkImage(
                      imageUrl: imagePath!,
                      fit: BoxFit.cover,
                      placeholder:
                          (context, url) => Container(
                            color: const Color(0xFFC9A89C),
                            child: Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.primaryOrange,
                              ),
                            ),
                          ),
                      errorWidget: (context, url, error) => _buildPlaceholder(),
                      httpHeaders: const {
                        'User-Agent':
                            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
                      },
                    ),
                  )
                  : _buildPlaceholder(),
        ),
        Positioned(
          top: 16,
          right: 16,
          child: GestureDetector(
            onTap: () async {
              await favoriteProvider.toggleFavorite(id);

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isFavorite
                          ? 'Removed from favorites'
                          : 'Added to favorites',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    backgroundColor: isFavorite ? Colors.red : Colors.green,
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    margin: const EdgeInsets.all(16),
                  ),
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? Colors.red : AppColors.primaryOrange,
                size: 20,
              ),
            ),
          ),
        ),
        if (discount != null && discount! > 0)
          Positioned(
            top: 24,
            left: 24,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$discount% OFF',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Icon(Icons.fastfood, color: Colors.grey[400], size: 40),
      ),
    );
  }

  Widget _buildContentSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.black,
              height: 1.2,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 18),
              const SizedBox(width: 4),
              Text(
                rating.toStringAsFixed(1),
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(width: 12),
              Icon(Icons.schedule, color: Colors.grey[600], size: 16),
              const SizedBox(width: 4),
              Text(
                time,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              if (discount != null && discount! > 0) ...[
                Text(
                  'Rp ${(price * (1 + discount! / 100)).toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    decoration: TextDecoration.lineThrough,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  'Rp ${price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryOrange,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
