import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/product_provider.dart';
import '../models/product.dart';
import '../utils/app_colors.dart';
import 'dart:io';
import '../services/image_service.dart';
import '../services/product_service.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({Key? key}) : super(key: key);

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _urlController = TextEditingController();
  final _imageUrlController = TextEditingController();

  // 선택된 인포칩 목록
  final List<String> _selectedInfoChips = [];

  // 서비스 인스턴스
  final _imageService = ImageService();
  final _productService = ProductService();

  String? _imageUrl;
  bool _isLoading = false;
  bool _isLoadingImage = false;

  // 이미지 선택 다이얼로그 표시
  void _showImageOptionsDialog() {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(Icons.image, color: AppColors.primary, size: 28),
                const SizedBox(width: 12),
                Text(
                  '이미지 선택 방법',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildImageOptionTile(
                  icon: Icons.photo_library,
                  title: '기기에서 선택',
                  subtitle: '갤러리에서 이미지를 선택합니다',
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _pickImageFromDevice();
                  },
                ),
                const SizedBox(height: 8),
                _buildImageOptionTile(
                  icon: Icons.shuffle,
                  title: '랜덤 이미지',
                  subtitle: '랜덤 빵 이미지를 가져옵니다',
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _getRandomImage();
                  },
                ),
                const SizedBox(height: 8),
                _buildImageOptionTile(
                  icon: Icons.link,
                  title: 'URL로 가져오기',
                  subtitle: '온라인 이미지 URL을 입력합니다',
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _showUrlInputDialog();
                  },
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildImageOptionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primaryLight.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: AppColors.primaryLight,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  // URL 입력 다이얼로그 표시
  void _showUrlInputDialog() {
    String previewUrl = '';
    _urlController.text = '';

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  Icon(Icons.link, color: AppColors.primary, size: 24),
                  const SizedBox(width: 12),
                  Text(
                    '이미지 URL 입력',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: _urlController,
                      decoration: InputDecoration(
                        hintText: 'https://example.com/image.jpg',
                        prefixIcon: Icon(
                          Icons.insert_link,
                          color: AppColors.primaryLight,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppColors.primaryLight.withOpacity(0.3),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppColors.primaryLight.withOpacity(0.3),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.primary),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        filled: true,
                        fillColor: AppColors.background,
                      ),
                      keyboardType: TextInputType.url,
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textPrimary,
                      ),
                      autofocus: true,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton.icon(
                          onPressed: () {
                            if (_urlController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('URL을 입력해주세요'),
                                  backgroundColor: AppColors.error,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              );
                              return;
                            }
                            setDialogState(() {
                              previewUrl = _urlController.text;
                            });
                          },
                          icon: Icon(
                            Icons.preview,
                            size: 18,
                            color: AppColors.primary,
                          ),
                          label: Text(
                            '미리보기',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 14,
                          color: AppColors.textMuted,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'URL은 http:// 또는 https://로 시작해야 합니다',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                    if (previewUrl.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      Text(
                        '이미지 미리보기',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 180,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.primaryLight.withOpacity(0.3),
                          ),
                          color: AppColors.backgroundMuted,
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Image.network(
                              previewUrl,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              loadingBuilder: (
                                context,
                                child,
                                loadingProgress,
                              ) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value:
                                        loadingProgress.expectedTotalBytes !=
                                                null
                                            ? loadingProgress
                                                    .cumulativeBytesLoaded /
                                                loadingProgress
                                                    .expectedTotalBytes!
                                            : null,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppColors.primary,
                                    ),
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.broken_image,
                                        color: AppColors.textMuted,
                                        size: 40,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        '이미지를 불러올 수 없습니다',
                                        style: TextStyle(
                                          color: AppColors.textMuted,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '유효한 이미지 URL을 입력해주세요',
                                        style: TextStyle(
                                          color: AppColors.textMuted,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                OutlinedButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textMuted,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('취소'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final url = _urlController.text.trim();

                    if (!_imageService.isValidImageUrl(url)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('유효한 URL을 입력해주세요'),
                          backgroundColor: AppColors.error,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      );
                      return;
                    }

                    setState(() {
                      _imageUrl = url;
                    });
                    Navigator.of(ctx).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('적용'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // 기기에서 이미지 선택
  void _pickImageFromDevice() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final imagePath = await _imageService.pickImageFromDevice();

      setState(() {
        _imageUrl = imagePath;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('이미지를 선택하는 중 오류가 발생했습니다')));
      }
    }
  }

  // 랜덤 이미지 가져오기
  void _getRandomImage() {
    try {
      setState(() {
        _isLoadingImage = true;
      });

      final randomUrl = ImageService.getRandomImageUrl();
      _imageUrlController.text = randomUrl;

      setState(() {
        _isLoadingImage = false;
        _imageUrl = randomUrl; // 이미지 URL 업데이트
      });
    } catch (e) {
      setState(() {
        _isLoadingImage = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('랜덤 이미지를 가져오는데 실패했습니다. 다시 시도해주세요.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // 폼 검증
  bool _validateForm() {
    if (_imageUrl == null || _imageUrl!.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('이미지를 선택해주세요')));
      return false;
    }

    return _formKey.currentState?.validate() ?? false;
  }

  // 폼 제출
  void _submitForm() {
    if (!_validateForm()) {
      return;
    }

    final productProvider = Provider.of<ProductProvider>(
      context,
      listen: false,
    );

    // 서비스를 통해 상품 생성
    _productService.createProduct(
      provider: productProvider,
      name: _nameController.text,
      description: _descriptionController.text,
      price: _priceController.text,
      imageUrl: _imageUrl!,
      infoChips: _selectedInfoChips,
    );

    _showSuccessDialog();
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              '상품 등록 완료',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle_outline,
                    color: AppColors.primary,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  '상품이 성공적으로 등록되었습니다',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            actions: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    '확인',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _urlController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          '상품 등록',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: GestureDetector(
        onTap: () {
          // 키보드 포커스 해제
          FocusScope.of(context).unfocus();
        },
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 이미지 선택 영역
                Center(child: _buildImageSelector()),

                const SizedBox(height: 32),

                // 제목 섹션
                _buildSectionTitle('기본 정보', Icons.info_outline),
                const SizedBox(height: 16),

                // 상품명 입력 필드
                _buildFormField(
                  controller: _nameController,
                  labelText: '상품명',
                  hintText: '예: 바게트, 크루아상, 통밀 식빵',
                  icon: Icons.bakery_dining,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '상품명을 입력해주세요';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // 가격 입력 필드
                _buildFormField(
                  controller: _priceController,
                  labelText: '가격',
                  hintText: '예: 4000',
                  icon: Icons.attach_money,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '가격을 입력해주세요';
                    }
                    if (int.tryParse(value) == null) {
                      return '숫자만 입력해주세요';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // 인포칩 선택 영역
                _buildInfoChipsSection(),

                const SizedBox(height: 32),

                // 설명 섹션
                _buildSectionTitle('상품 설명', Icons.description),
                const SizedBox(height: 16),

                // 설명 입력 필드
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    hintText: '상품에 대한 설명을 입력해주세요',
                    fillColor: Colors.white,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppColors.primaryLight.withOpacity(0.3),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppColors.primaryLight.withOpacity(0.3),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.primary),
                    ),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                  maxLines: 5,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '상품 설명을 입력해주세요';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 48),

                // 등록 버튼
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child:
                        _isLoading
                            ? SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                            : Text(
                              '상품 등록하기',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            labelText,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: Icon(icon, color: AppColors.primaryLight),
            fillColor: Colors.white,
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.primaryLight.withOpacity(0.3),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.primaryLight.withOpacity(0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 14),
          ),
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
          style: TextStyle(fontSize: 16, color: AppColors.textPrimary),
        ),
      ],
    );
  }

  Widget _buildImageSelector() {
    final imageHeight = MediaQuery.of(context).size.width * 0.6;

    return Column(
      children: [
        Container(
          width: imageHeight,
          height: imageHeight,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.primaryLight.withOpacity(0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child:
              _imageUrl == null
                  ? InkWell(
                    onTap: _showImageOptionsDialog,
                    borderRadius: BorderRadius.circular(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_photo_alternate_outlined,
                          size: 60,
                          color: AppColors.primaryLight,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '이미지 추가',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '터치하여 이미지를 선택하세요',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  )
                  : Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child:
                            _imageUrl!.startsWith('http')
                                ? Image.network(_imageUrl!, fit: BoxFit.cover)
                                : Image.file(
                                  File(_imageUrl!),
                                  fit: BoxFit.cover,
                                ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _imageUrl = null;
                            });
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: InkWell(
                          onTap: _showImageOptionsDialog,
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.9),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.edit,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
        ),
        if (_imageUrl == null) ...[const SizedBox(height: 16)],
      ],
    );
  }

  // 인포칩 선택 섹션 빌드
  Widget _buildInfoChipsSection() {
    final recommendedChips = _productService.getRecommendedInfoChips();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('상품 정보 태그', Icons.tag),
        const SizedBox(height: 12),
        Text(
          '상품의 특징을 나타내는 태그를 선택해주세요 (선택사항)',
          style: TextStyle(fontSize: 14, color: AppColors.textMuted),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 12,
          children:
              recommendedChips.map((chip) {
                final isSelected = _selectedInfoChips.contains(chip);

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedInfoChips.remove(chip);
                      } else {
                        if (_selectedInfoChips.length < 3) {
                          _selectedInfoChips.add(chip);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('최대 3개까지 선택 가능합니다'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      }
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? AppColors.primary
                              : AppColors.primaryLight.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color:
                            isSelected
                                ? AppColors.primary
                                : AppColors.primaryLight.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          chip,
                          style: TextStyle(
                            fontSize: 14,
                            color:
                                isSelected
                                    ? Colors.white
                                    : AppColors.textSecondary,
                            fontWeight:
                                isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                          ),
                        ),
                        if (isSelected) ...[
                          const SizedBox(width: 4),
                          Icon(Icons.check, size: 14, color: Colors.white),
                        ],
                      ],
                    ),
                  ),
                );
              }).toList(),
        ),
        if (_selectedInfoChips.isNotEmpty) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.info_outline, size: 14, color: AppColors.accent),
              const SizedBox(width: 6),
              Text(
                '${_selectedInfoChips.length}/3 선택됨',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.accent,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  // 이미지 URL 미리보기
  Widget _buildImagePreview() {
    if (_imageUrl == null || _imageUrl!.isEmpty) {
      return Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(Icons.image, size: 80, color: Colors.grey[400]),
      );
    }

    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: ImageService.loadImage(
        _imageUrl!,
        width: double.infinity,
        height: 200,
        fit: BoxFit.cover,
      ),
    );
  }
}
