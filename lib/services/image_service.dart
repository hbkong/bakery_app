import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ImageService {
  static final ImageService _instance = ImageService._internal();

  factory ImageService() {
    return _instance;
  }

  ImageService._internal();

  static final List<String> fallbackImages = [
    'assets/images/bakery_logo.png',
    'assets/images/1.png',
  ];

  // 기기에서 이미지 선택
  Future<String> pickImageFromDevice() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      return image.path;
    } else {
      // 사용자가 이미지 선택을 취소한 경우
      throw Exception('이미지 선택이 취소되었습니다');
    }
  }

  // 랜덤 빵 이미지 URL 반환
  Future<String> getRandomImage() async {
    // 예제 빵 이미지 URL 목록
    final List<String> breadImages = [
      'https://images.unsplash.com/photo-1608198093002-ad4e005484ec',
      'https://images.unsplash.com/photo-1534620808146-d33bb39128b2',
      'https://images.unsplash.com/photo-1589367920969-ab8e050bbb04',
      'https://images.unsplash.com/photo-1509440159596-0249088772ff',
      'https://images.unsplash.com/photo-1549931319-a545dcf3bc7c',
      'https://images.unsplash.com/photo-1586444248732-f703ce9756b3',
      'https://images.unsplash.com/photo-1605283763975-ae9ef8951c41',
      'https://images.unsplash.com/photo-1612207566125-eab3273be129',
      'https://images.unsplash.com/photo-1556471013-0001958d2f12',
      'https://images.unsplash.com/photo-1524342361841-16e43c79bt8f',
    ];

    // 네트워크 지연 시뮬레이션 (실제 API 호출처럼 동작하기 위해)
    await Future.delayed(const Duration(milliseconds: 500));

    // 랜덤 인덱스 생성 및 이미지 URL 반환
    final random = Random();
    final index = random.nextInt(breadImages.length);
    return breadImages[index];
  }

  // 이미지 URL이 유효한지 확인
  bool isValidImageUrl(String url) {
    if (url.isEmpty) return false;

    // 기본적인 URL 형식 검증
    final RegExp urlRegex = RegExp(
      r'^(http|https)://([\w-]+\.)+[\w-]+(/[\w-./?%&=]*)?$',
      caseSensitive: false,
    );

    return urlRegex.hasMatch(url);
  }

  static String getRandomImageUrl() {
    // 안정적인 이미지 URL 사용
    final List<String> imageUrls = [
      'https://images.unsplash.com/photo-1608198093002-ad4e005484ec',
      'https://images.unsplash.com/photo-1509440159596-0249088772ff',
      'https://images.unsplash.com/photo-1517433670267-08bbd4be890f',
      'https://images.unsplash.com/photo-1495147466023-ac5c588e2e94',
      'https://images.unsplash.com/photo-1483695028939-5bb13f8648b0',
    ];

    // 랜덤 인덱스 생성
    final random = Random();
    final index = random.nextInt(imageUrls.length);

    // 필요한 매개변수 추가
    final selectedUrl =
        '${imageUrls[index]}?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=600&q=80';

    return selectedUrl;
  }

  static Widget loadImage(
    String imageUrl, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
  }) {
    // 이미지 URL이 유효한지 확인
    if (imageUrl.isEmpty) {
      return _getFallbackImage(width: width, height: height, fit: fit);
    }

    // 네트워크 이미지인 경우
    if (imageUrl.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        width: width,
        height: height,
        fit: fit,
        placeholder:
            (context, url) => Container(
              color: Colors.grey[200],
              child: Center(child: CircularProgressIndicator()),
            ),
        errorWidget:
            (context, url, error) =>
                _getFallbackImage(width: width, height: height, fit: fit),
      );
    }
    // 로컬 이미지(애셋)인 경우
    else {
      return Image.asset(
        imageUrl,
        width: width,
        height: height,
        fit: fit,
        errorBuilder:
            (context, error, stackTrace) =>
                _getFallbackImage(width: width, height: height, fit: fit),
      );
    }
  }

  static Widget _getFallbackImage({
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
  }) {
    final random = Random();
    final fallbackImage = fallbackImages[random.nextInt(fallbackImages.length)];

    return Image.asset(
      fallbackImage,
      width: width,
      height: height,
      fit: fit,
      errorBuilder:
          (context, error, stackTrace) => Container(
            width: width,
            height: height,
            color: Colors.grey[300],
            child: Icon(Icons.image_not_supported, color: Colors.grey[600]),
          ),
    );
  }

  // 이미지 사전 캐싱
  static Future<void> precacheImages(BuildContext context) async {
    for (String url in fallbackImages) {
      await precacheImage(AssetImage(url), context);
    }
  }
}
