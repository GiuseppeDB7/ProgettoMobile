import 'package:flutter/material.dart';
import 'package:snapbasket/models/item.dart';

class Cart extends ChangeNotifier {
  List<Item> itemShop = [
    Item(
      name: 'TEXT',
      price: 'number',
      description: 'Description',
      imagePath: 'lib/assets/white.png',
    ),
    Item(
      name: 'TEXT',
      price: 'number',
      description: 'Description',
      imagePath: 'lib/assets/white.png',
    ),
    Item(
      name: 'TEXT',
      price: 'number',
      description: 'Description',
      imagePath: 'lib/assets/white.png',
    ),
    Item(
      name: 'TEXT',
      price: 'number',
      description: 'Description',
      imagePath: 'lib/assets/white.png',
    ),
  ];

  List<Item> userCart = [];

  List<Item> getItemList() {
    return itemShop;
  }

  List<Item> getUserCart() {
    return userCart;
  }

  void addItemToCart(Item item) {
    userCart.add(item);
    notifyListeners();
  }

  void removeItemByCart(Item item) {
    userCart.remove(item);
    notifyListeners();
  }
}
