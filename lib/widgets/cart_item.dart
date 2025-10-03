import 'package:flutter/material.dart';
import '../utils/constants.dart';

class CartItem extends StatelessWidget {
  final Map<String, dynamic> food;
  final Function(int) onQuantityChanged;
  final VoidCallback onRemoved;

  const CartItem({
    super.key,
    required this.food,
    required this.onQuantityChanged,
    required this.onRemoved,
  });

  @override
  Widget build(BuildContext context) {
    final quantity = food['quantity'] as int;
    final price = food['price'] as int;
    final totalPrice = price * quantity;

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildFoodImage(),
          SizedBox(width: 12),
          Expanded(child: _buildFoodInfo()),
          _buildQuantityControls(quantity),
        ],
      ),
    );
  }

  Widget _buildFoodImage() {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[200],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child:
            food['image'] != null
                ? Image.asset(
                  food['image'],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildImagePlaceholder();
                  },
                )
                : _buildImagePlaceholder(),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: Icon(Icons.fastfood, color: Colors.grey[400], size: 30),
    );
  }

  Widget _buildFoodInfo() {
    final quantity = food['quantity'] as int;
    final price = food['price'] as int;
    final totalPrice = price * quantity;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                food['title'],
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            GestureDetector(
              onTap: onRemoved,
              child: Icon(Icons.delete_outline, color: Colors.red, size: 20),
            ),
          ],
        ),
        SizedBox(height: 4),
        if (food['discount'] != null) ...[
          Text(
            'Rp ${((price * (1 + food['discount'] / 100)).toInt()).toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
            style: AppTextStyles.bodySmall.copyWith(
              decoration: TextDecoration.lineThrough,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 2),
        ],
        Text(
          'Rp ${price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} × $quantity',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Rp ${totalPrice.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primaryOrange,
          ),
        ),
      ],
    );
  }

  Widget _buildQuantityControls(int quantity) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: quantity > 1 ? () => onQuantityChanged(quantity - 1) : null,
            child: Container(
              padding: EdgeInsets.all(8),
              child: Icon(
                Icons.remove,
                size: 16,
                color: quantity > 1 ? Colors.black : Colors.grey,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Text(
              quantity.toString(),
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => onQuantityChanged(quantity + 1),
            child: Container(
              padding: EdgeInsets.all(8),
              child: Icon(Icons.add, size: 16, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
