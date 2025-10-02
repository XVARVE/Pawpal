import 'package:flutter/material.dart';

class FavouriteItem {
  final String image;
  final String title;
  final String desc;
  final String price;

  FavouriteItem({
    required this.image,
    required this.title,
    required this.desc,
    required this.price,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is FavouriteItem &&
              runtimeType == other.runtimeType &&
              image == other.image &&
              title == other.title;

  @override
  int get hashCode => image.hashCode ^ title.hashCode;
}

class FavouritesProvider with ChangeNotifier {
  final List<FavouriteItem> _items = [];

  List<FavouriteItem> get items => List.unmodifiable(_items);

  bool isFavourite(FavouriteItem item) => _items.contains(item);

  void toggleFavourite(FavouriteItem item) {
    if (isFavourite(item)) {
      _items.remove(item);
    } else {
      _items.add(item);
    }
    notifyListeners();
  }

  void removeFavourite(FavouriteItem item) {
    _items.remove(item);
    notifyListeners();
  }
}
