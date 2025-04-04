import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../providers/product_provider.dart';
import '../models/cart_item.dart';
import '../models/product.dart';
import '../utils/app_colors.dart';
import '../utils/formatters.dart';
import '../services/cart_service.dart';
import '../components/completion_dialog.dart';
import '../components/purchase_confirm_dialog.dart';
import 'product_list_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({Key? key}) : super(key: key);

  // 서비스 인스턴스
  static final CartService _cartService = CartService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          '장바구니',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
      ),
      body: Consumer<CartProvider>(
        builder: (ctx, cartProvider, _) {
          final cartItems = cartProvider.items;

          if (_cartService.isCartEmpty(cartProvider)) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 80,
                    color: AppColors.primaryLight.withOpacity(0.5),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    '장바구니가 비어있습니다',
                    style: TextStyle(
                      fontSize: 18,
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '원하는 상품을 장바구니에 담아보세요',
                    style: TextStyle(fontSize: 14, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.bakery_dining_outlined),
                    label: Text('쇼핑 계속하기'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // 상단 정보 요약
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                color: AppColors.primaryLight.withOpacity(0.1),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '총 ${cartItems.length}개 상품',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // 장바구니 목록
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // 장바구니 아이템
                    ...List.generate(cartItems.length, (index) {
                      final item = cartItems[index];
                      return _buildCartItem(context, item);
                    }),

                    // 함께 먹으면 좋아요 섹션
                    const SizedBox(height: 24),
                    _buildRecommendationSection(context),
                  ],
                ),
              ),

              // 하단 결제 정보
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 요약 정보
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '상품 금액',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          Formatters.formatCurrency(
                            _cartService.getTotalPrice(cartProvider),
                          ),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '배송비',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          '무료',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.accent,
                          ),
                        ),
                      ],
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Divider(
                        color: AppColors.primaryLight.withOpacity(0.2),
                        thickness: 1,
                      ),
                    ),

                    // 총 금액
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '총 결제 금액',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          Formatters.formatCurrency(
                            _cartService.getTotalPrice(cartProvider),
                          ),
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // 구매 버튼
                    ElevatedButton(
                      onPressed: () => _showPurchaseDialog(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        '구매하기',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCartItem(BuildContext context, CartItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 상품 이미지
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(color: AppColors.backgroundMuted),
                child:
                    item.product.imageUrl.startsWith('http')
                        ? Image.network(
                          item.product.imageUrl,
                          fit: BoxFit.cover,
                        )
                        : Image.asset(item.product.imageUrl, fit: BoxFit.cover),
              ),
            ),

            const SizedBox(width: 16),

            // 상품 정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.product.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    Formatters.formatCurrency(item.product.price),
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 수량 조절 및 가격
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // 수량 조절 버튼
                      Row(
                        children: [
                          _buildQuantityButton(
                            icon:
                                item.quantity > 1
                                    ? Icons.remove
                                    : Icons.delete_outline,
                            onPressed: () {
                              if (item.quantity > 1) {
                                _cartService.updateQuantity(
                                  Provider.of<CartProvider>(
                                    context,
                                    listen: false,
                                  ),
                                  item.product,
                                  item.quantity - 1,
                                );
                              } else {
                                // 수량이 1이면 삭제 - 간단히 제거
                                _cartService.removeFromCart(
                                  Provider.of<CartProvider>(
                                    context,
                                    listen: false,
                                  ),
                                  item.product,
                                );
                              }
                            },
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${item.quantity}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          _buildQuantityButton(
                            icon: Icons.add,
                            onPressed: () {
                              if (item.quantity < 99) {
                                _cartService.updateQuantity(
                                  Provider.of<CartProvider>(
                                    context,
                                    listen: false,
                                  ),
                                  item.product,
                                  item.quantity + 1,
                                );
                              }
                            },
                          ),
                        ],
                      ),

                      // 합계 금액
                      Text(
                        Formatters.formatCurrency(
                          item.product.price * item.quantity,
                        ),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, color: AppColors.primary, size: 16),
      ),
    );
  }

  void _showPurchaseDialog(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final totalPrice = _cartService.getTotalPrice(cartProvider);
    final totalItems = cartProvider.items.length;

    showDialog(
      context: context,
      builder:
          (ctx) => PurchaseConfirmDialog(
            totalItems: totalItems,
            totalPrice: totalPrice,
            onConfirm: () {
              Navigator.of(ctx).pop();
              _showCompletionDialog(context);
            },
            onCancel: () => Navigator.of(ctx).pop(),
          ),
    );
  }

  void _showCompletionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (ctx) => CompletionDialog(
            onConfirm: () {
              _cartService.clearCart(
                Provider.of<CartProvider>(context, listen: false),
              );
              Navigator.of(ctx).pop();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProductListScreen(),
                ),
                (route) => false,
              );
            },
          ),
    );
  }

  Widget _buildRecommendationSection(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (ctx, productProvider, _) {
        // 추천 상품 목록 (데모용으로 최대 3개만 표시)
        final recommendedProducts =
            productProvider.products
                .where(
                  (p) =>
                      !Provider.of<CartProvider>(
                        context,
                        listen: false,
                      ).isInCart(p),
                )
                .take(3)
                .toList();

        if (recommendedProducts.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 섹션 제목
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  Icon(Icons.recommend, size: 20, color: AppColors.accent),
                  const SizedBox(width: 8),
                  Text(
                    '함께 먹으면 좋아요',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),

            // 추천 상품 목록
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children:
                    recommendedProducts.map((product) {
                      return _buildRecommendedProductItem(context, product);
                    }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRecommendedProductItem(BuildContext context, Product product) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.backgroundMuted.withOpacity(0.5),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // 상품 이미지
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(color: AppColors.backgroundMuted),
              child:
                  product.imageUrl.startsWith('http')
                      ? Image.network(product.imageUrl, fit: BoxFit.cover)
                      : Image.asset(product.imageUrl, fit: BoxFit.cover),
            ),
          ),

          const SizedBox(width: 12),

          // 상품 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  Formatters.formatCurrency(product.price),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),

          // 추가 버튼
          SizedBox(
            width: 32,
            height: 32,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primary, width: 1.5),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: () {
                  // 장바구니에 추가
                  _cartService.addToCart(
                    Provider.of<CartProvider>(context, listen: false),
                    product,
                    1,
                  );

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Icon(
                            Icons.shopping_cart_outlined,
                            size: 16,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${product.name}을(를) 담았어요',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      backgroundColor: Colors.black.withOpacity(0.75),
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(milliseconds: 1800),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      margin: EdgeInsets.only(
                        bottom: MediaQuery.of(context).size.height / 2 - 20,
                        left: MediaQuery.of(context).size.width * 0.2,
                        right: MediaQuery.of(context).size.width * 0.2,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      elevation: 0,
                    ),
                  );
                },
                icon: Icon(Icons.add, size: 16, color: AppColors.primary),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
