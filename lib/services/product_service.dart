import 'package:flutter/material.dart';
import '../models/product.dart';
import '../providers/product_provider.dart';

class ProductService {
  static final ProductService _instance = ProductService._internal();

  factory ProductService() {
    return _instance;
  }

  ProductService._internal();

  // 상품 정보 검증
  bool validateProduct({
    required String name,
    required String price,
    required String description,
    required String imageUrl,
    List<String>? infoChips,
  }) {
    if (name.isEmpty ||
        price.isEmpty ||
        description.isEmpty ||
        imageUrl.isEmpty) {
      return false;
    }

    // 가격이 숫자인지 확인
    if (int.tryParse(price) == null) {
      return false;
    }

    return true;
  }

  // 상품 생성
  void createProduct({
    required ProductProvider provider,
    required String name,
    required String description,
    required String price,
    required String imageUrl,
    List<String>? infoChips,
  }) {
    // 상품 정보 검증
    if (!validateProduct(
      name: name,
      price: price,
      description: description,
      imageUrl: imageUrl,
      infoChips: infoChips,
    )) {
      throw Exception('유효하지 않은 상품 정보입니다');
    }

    // 상품 생성
    final product = Product(
      id: DateTime.now().millisecondsSinceEpoch,
      name: name,
      description: description,
      price: int.parse(price),
      imageUrl: imageUrl,
      infoChips: infoChips ?? [],
    );

    // 상품 추가
    provider.addProduct(product);
  }

  // ID로 상품 조회
  Product? getProductById(ProductProvider provider, int id) {
    try {
      return provider.getById(id);
    } catch (e) {
      return null;
    }
  }

  // 추천 인포칩 목록 가져오기
  List<String> getRecommendedInfoChips() {
    return [
      '신상품',
      '인기상품',
      '추천상품',
      '한정판매',
      '유기농',
      '글루텐프리',
      '비건',
      '무설탕',
      '저탄수',
      '고단백',
      '아몬드',
      '호두',
      '초콜릿',
      '크림',
      '과일',
      '치즈',
    ];
  }
}
