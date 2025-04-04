import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_colors.dart';
import 'product_list_screen.dart';
import '../providers/product_provider.dart';
import '../models/product.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // 애니메이션 컨트롤러 설정
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // 페이드 인 애니메이션
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    // 스케일 애니메이션 (약간 커지는 효과)
    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );

    // 애니메이션 시작
    _controller.forward();

    // 초기 샘플 상품 데이터 추가
    _addSampleProducts();

    // 2.5초 후에 상품 목록 화면으로 이동
    Timer(const Duration(milliseconds: 2500), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const ProductListScreen()),
      );
    });
  }

  // 초기 샘플 상품 데이터 추가 메서드
  void _addSampleProducts() {
    // Provider 가져오기
    final productProvider = Provider.of<ProductProvider>(
      context,
      listen: false,
    );

    // 이미 샘플 데이터가 있는지 확인 (앱 재시작 시 중복 방지)
    if (productProvider.products.isNotEmpty) {
      return;
    }

    // 샘플 상품 1 - 크루아상
    final croissant = Product(
      id: 1,
      name: '버터 크루아상',
      description:
          '겉은 바삭하고 속은 부드러운 전통 프랑스식 크루아상입니다. 100% 천연 버터를 사용하여 72시간의 저온 발효 과정을 거쳐 완성된 풍부한 풍미의 프리미엄 크루아상입니다.',
      price: 4500,
      imageUrl:
          'https://images.unsplash.com/photo-1555507036-ab1f4038808a?q=80&w=1000',
    );

    // 샘플 상품 2 - 통밀 식빵
    final wheatBread = Product(
      id: 2,
      name: '통밀 식빵',
      description:
          '유기농 통밀을 사용하여 건강하고 고소한 맛이 일품인 식빵입니다. 천연 발효종을 사용하여 12시간 저온 발효한 건강한 빵으로, 식이섬유가 풍부하고 담백한 맛이 특징입니다.',
      price: 6000,
      imageUrl:
          'https://images.unsplash.com/photo-1586444248732-f703ce9756b3?q=80&w=1000',
    );

    // Provider에 샘플 상품 추가
    productProvider.addProduct(croissant);
    productProvider.addProduct(wheatBread);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            children: [
              // 배경 패턴 (옵션)
              Positioned.fill(
                child: Opacity(
                  opacity: 0.05,
                  child: Image.asset(
                    'assets/images/bakery_logo.png',
                    repeat: ImageRepeat.repeat,
                    color: AppColors.primary,
                  ),
                ),
              ),

              // 중앙 컨텐츠
              Center(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // 빵 로고 이미지
                        Container(
                          width: 140,
                          height: 140,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.shadow.withOpacity(0.2),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Image.asset(
                            'assets/images/bakery_logo.png',
                            width: 100,
                            height: 100,
                          ),
                        ),

                        const SizedBox(height: 36),

                        // 앱 타이틀 로고 (브라운 톤 적용)
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: '\$4 ',
                                style: TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              TextSpan(
                                text: 'bakery',
                                style: TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.w300,
                                  color: AppColors.primary,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // 앱 설명 텍스트
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '맛있는 빵이 가득한 베이커리',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),

                        const SizedBox(height: 60),

                        // 프로그레스 인디케이터
                        SizedBox(
                          width: 40,
                          height: 40,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.accent,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 하단 로딩 텍스트
              Positioned(
                bottom: size.height * 0.08,
                left: 0,
                right: 0,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Center(
                    child: Text(
                      '맛있는 빵을 로딩 중입니다...',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
