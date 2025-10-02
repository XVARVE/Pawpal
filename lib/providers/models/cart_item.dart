class CartItem {
  final String? id;       // Firestore productId (optional)
  final String img;       // can be network URL or asset path
  final String name;
  final String detail;    // e.g. "Dog", "Cat", "Food"
  final int price;
  final int qty;
  final int? originalPrice;

  CartItem({
    this.id,
    required this.img,
    required this.name,
    required this.detail,
    required this.price,
    this.qty = 1,
    this.originalPrice,
  });

  CartItem copyWith({
    String? id,
    String? img,
    String? name,
    String? detail,
    int? price,
    int? qty,
    int? originalPrice,
  }) {
    return CartItem(
      id: id ?? this.id,
      img: img ?? this.img,
      name: name ?? this.name,
      detail: detail ?? this.detail,
      price: price ?? this.price,
      qty: qty ?? this.qty,
      originalPrice: originalPrice ?? this.originalPrice,
    );
  }
}
