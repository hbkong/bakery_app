import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/formatters.dart';

class PurchaseConfirmDialog extends StatelessWidget {
  final int totalItems;
  final int totalPrice;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const PurchaseConfirmDialog({
    Key? key,
    required this.totalItems,
    required this.totalPrice,
    required this.onConfirm,
    required this.onCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        '구매 확인',
        style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.shopping_bag_outlined,
              size: 36,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: TextStyle(color: AppColors.textPrimary, fontSize: 16),
              children: [
                TextSpan(text: '총 '),
                TextSpan(
                  text: '$totalItems개',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: '의 상품,\n'),
                TextSpan(
                  text: Formatters.formatCurrency(totalPrice),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    fontSize: 20,
                  ),
                ),
                TextSpan(text: '을 결제하시겠습니까?'),
              ],
            ),
          ),
        ],
      ),
      actions: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: onCancel,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  foregroundColor: AppColors.primary,
                  side: BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('취소'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: onConfirm,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('결제하기'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
