import 'package:flutter/material.dart';
import '../utils/constants.dart';

class FoodCard extends StatelessWidget {
  final String title;
  final double rating;
  final String time;
  final int price;
  final int? discount;
  final String? imagePath;
  final VoidCallback? onTap;

  const FoodCard({
    super.key,
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.borderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [_buildImageSection(), _buildContentSection()],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Stack(
      children: [
        Container(
          height: 120,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(AppSizes.borderRadius),
              topRight: Radius.circular(AppSizes.borderRadius),
            ),
          ),
          child:
              imagePath != null
                  ? ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(AppSizes.borderRadius),
                      topRight: Radius.circular(AppSizes.borderRadius),
                    ),
                    child: Image.asset(
                      imagePath!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildPlaceholder();
                      },
                    ),
                  )
                  : _buildPlaceholder(),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: Container(
            padding: EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.favorite_border, color: Colors.grey, size: 16),
          ),
        ),
        if (discount != null)
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$discount% OFF',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
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
      padding: EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.star, color: Colors.orange, size: 14),
              SizedBox(width: 4),
              Text(rating.toString(), style: AppTextStyles.bodySmall),
              Spacer(),
              Icon(Icons.access_time, color: Colors.grey, size: 14),
              SizedBox(width: 4),
              Text(time, style: AppTextStyles.bodySmall),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              if (discount != null) ...[
                Text(
                  'Rp ${(price * (1 + discount! / 100)).toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                  style: AppTextStyles.bodySmall.copyWith(
                    decoration: TextDecoration.lineThrough,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(width: 8),
              ],
              Text(
                'Rp ${price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryOrange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
