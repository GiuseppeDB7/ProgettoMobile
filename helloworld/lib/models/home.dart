import 'package:flutter/material.dart';
import 'package:helloworld/models/item.dart';

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

  //list items in cart
  List<Item> userCart = [];

  //get list of Items for sale
  List<Item> getItemList() {
    return itemShop;
  }

  //get cart
  List<Item> getUserCart() {
    return userCart;
  }

  //add to cart
  void addItemToCart(Item item) {
    userCart.add(item);
    notifyListeners();
  }

  //remove from cart
  void removeItemByCart(Item item) {
    userCart.remove(item);
    notifyListeners();
  }
}
