# 🥐 Bakery App

Flutter로 개발된 베이커리 쇼핑몰 애플리케이션입니다. 사용자 친화적인 UI/UX를 통해 베이커리 상품을 쉽게 둘러보고 구매할 수 있습니다.

## 📱 주요 기능

### 상품
- 🛍️ 상품 목록 보기 및 검색
- 🔍 상품 상세 정보 확인
- 🏷️ 상품 카테고리별 분류
- ⭐ 상품 평가 및 리뷰

### 장바구니/주문
- 🛒 장바구니 담기/수정/삭제
- 💳 주문 및 결제 프로세스
- 📦 주문 내역 조회

### 사용자 경험
- ✨ 스플래시 스크린
- 🎨 모던한 UI/UX
- 🌙 다크 모드 지원
- 📱 반응형 디자인

## 🎯 프로젝트 구조

```
bakery_app/
├── lib/
│   ├── components/     # 재사용 가능한 위젯
│   ├── models/         # 데이터 모델
│   ├── providers/      # 상태 관리
│   ├── screens/        # 화면 UI
│   ├── services/       # 비즈니스 로직
│   └── utils/          # 유틸리티 함수
├── assets/
│   ├── images/         # 이미지 리소스
│   └── fonts/          # 폰트 파일
└── test/              # 테스트 코드
```

## 🛠️ 기술 스택

- **프레임워크**: Flutter
- **상태관리**: Provider
- **디자인패턴**: MVVM
- **배포**: Vercel
- **버전관리**: Git

## 🖥️ 데모

웹 데모: [Bakery App on Vercel](https://bakery-app-hazel.vercel.app/)

## 🚀 시작하기

### 필수 요구사항
- Flutter SDK
- Dart SDK
- Android Studio 또는 VS Code
- iOS 시뮬레이터 또는 Android 에뮬레이터

### 설치 및 실행

1. Flutter 설치 확인
```bash
flutter doctor
```

2. 프로젝트 클론
```bash
git clone https://github.com/hbkong/bakery_app.git
cd bakery_app
```

3. 의존성 설치
```bash
flutter pub get
```

4. 실행
```bash
# 디버그 모드 실행
flutter run

# 웹 빌드
flutter build web
```

## 📱 스크린샷

(스크린샷 추가 예정)

## 🤝 기여하기

1. 이 저장소를 포크합니다
2. 새로운 브랜치를 생성합니다
3. 변경사항을 커밋합니다
4. 브랜치에 푸시합니다
5. Pull Request를 생성합니다

## 📝 라이선스

이 프로젝트는 MIT 라이선스를 따릅니다. 자세한 내용은 [LICENSE](LICENSE) 파일을 참조하세요.

## 👥 개발자

- [@hbkong](https://github.com/hbkong)
