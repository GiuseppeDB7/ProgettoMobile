import 'package:flutter/material.dart';
import 'package:snapbasket/models/home.dart';
import 'package:snapbasket/models/item.dart';
import 'package:provider/provider.dart';

class ListItem extends StatefulWidget {
  Item item;
  ListItem({super.key, required this.item});

  @override
  State<ListItem> createState() => _ListItemState();
}

class _ListItemState extends State<ListItem> {
  void removeItemFromCart() {
    Provider.of<Cart>(context, listen: false).removeItemByCart(widget.item);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      margin: const EdgeInsets.only(bottom: 10.0),
      child: ListTile(
        leading: Image.asset(widget.item.imagePath),
        title: Text(widget.item.name),
        subtitle: Text(widget.item.price),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: removeItemFromCart,
        ),
      ),
    );
  }
}
