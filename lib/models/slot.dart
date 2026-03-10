import 'package:snack_automat/models/product.dart';

class Slot {
  static const int maxCapacity = 5;

  Product product;
  int quantity;

  Slot({required this.product, this.quantity = maxCapacity});

  bool isEmpty() {
    return quantity <= 0;
  }

  void increment() {
    if (quantity < maxCapacity) {
      quantity++;
    }
  }

  void decrement() {
    if (quantity > 0) {
      quantity--;
    }
  }

  Slot copyWith({Product? product, int? quantity}) {
    return Slot(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }
}
