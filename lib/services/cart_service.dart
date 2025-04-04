import '../models/product.dart';
import '../providers/cart_provider.dart';

class CartService {
  static final CartService _instance = CartService._internal();

  factory CartService() {
    return _instance;
  }

  CartService._internal();

  // 장바구니에 상품 추가
  void addToCart(CartProvider provider, Product product, int quantity) {
    provider.addToCart(product, quantity);
  }

  // 장바구니 상품 수량 업데이트
  void updateQuantity(CartProvider provider, Product product, int quantity) {
    provider.updateQuantity(product, quantity);
  }

  // 장바구니에서 상품 제거
  void removeFromCart(CartProvider provider, Product product) {
    provider.remove(product);
  }

  // 장바구니 비우기
  void clearCart(CartProvider provider) {
    provider.clearCart();
  }

  // 장바구니 총 가격 계산
  int getTotalPrice(CartProvider provider) {
    return provider.totalPrice;
  }

  // 장바구니가 비어 있는지 확인
  bool isCartEmpty(CartProvider provider) {
    return provider.items.isEmpty;
  }
}
