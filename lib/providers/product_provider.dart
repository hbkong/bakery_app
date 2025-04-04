import 'package:flutter/foundation.dart';
import 'package:collection/collection.dart';
import '../models/product.dart';

class ProductProvider with ChangeNotifier {
  final List<Product> _products = [
    Product(
      id: 1,
      name: '크로와상',
      description: '바삭하고 부드러운 정통 프랑스식 크로와상입니다. 고소한 버터의 풍미가 가득합니다.',
      price: 4000,
      imageUrl:
          'https://images.unsplash.com/photo-1555507036-ab1f4038808a?q=80&w=1000',
      infoChips: ['신상품', '인기상품', '버터'],
    ),
    Product(
      id: 2,
      name: '통밀 식빵',
      description: '건강한 통밀로 만든 식빵입니다. 고소하고 담백한 맛이 일품입니다.',
      price: 6000,
      imageUrl:
          'https://images.unsplash.com/photo-1549931319-a545dcf3bc73?q=80&w=1000',
      infoChips: ['유기농', '통밀', '건강빵'],
    ),
    Product(
      id: 3,
      name: '초코 머핀',
      description: '진한 초콜릿과 부드러운 머핀의 완벽한 조화. 달콤한 간식으로 제격입니다.',
      price: 3500,
      imageUrl:
          'https://images.unsplash.com/photo-1607958996333-41aef7caefaa?q=80&w=1000',
      infoChips: ['초콜릿', '달콤함', '인기상품'],
    ),
    Product(
      id: 4,
      name: '치즈 베이글',
      description: '쫄깃한 베이글에 고소한 치즈가 듬뿍! 토스트해서 드시면 더욱 맛있습니다.',
      price: 4500,
      imageUrl:
          'https://images.unsplash.com/photo-1585445490387-f47934b73b54?q=80&w=1000',
      infoChips: ['치즈', '고단백', '아침식사'],
    ),
    Product(
      id: 5,
      name: '과일 타르트',
      description: '신선한 계절 과일을 듬뿍 올린 타르트입니다. 상큼하고 달콤한 맛이 특징입니다.',
      price: 5500,
      imageUrl:
          'https://images.unsplash.com/photo-1488477304112-4944851de03d?q=80&w=1000',
      infoChips: ['과일', '한정판매', '디저트'],
    ),
    Product(
      id: 6,
      name: '호두 파운드',
      description: '고소한 호두가 가득한 파운드케이크입니다. 차와 함께 드시면 좋습니다.',
      price: 4800,
      imageUrl:
          'https://images.unsplash.com/photo-1605286978633-2dec93ff88a2?q=80&w=1000',
      infoChips: ['호두', '견과류', '선물용'],
    ),
  ];

  List<Product> get products => _products;

  void addProduct(Product product) {
    _products.add(product);
    notifyListeners();
  }

  Product? getById(int id) => _products.firstWhereOrNull((p) => p.id == id);
}
