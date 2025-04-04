class Product {
  final int id;
  final String name;
  final String description;
  final int price;
  final String imageUrl;
  final List<String> infoChips;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.infoChips = const [],
  });
}
