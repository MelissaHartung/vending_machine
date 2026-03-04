import 'package:snack_automat/models/product.dart';

enum TransactionStatus { active, cancel, completed, failed }

class Transaction {
  final String transactionId;
  final Product product;
  int amountPaid;
  TransactionStatus status;

  final List<int> insertedCoins;
  List<int> changeCoins;

  Transaction({
    required this.transactionId,
    required this.product,
    this.amountPaid = 0, // Startet bei 0
    this.status = TransactionStatus.active, // Startet als "aktiv"
    List<int>? insertedCoins, // Optional beim Start
    List<int>? changeCoins,
  }) : insertedCoins = insertedCoins ?? [],
       changeCoins = changeCoins ?? [];

  int get price => product.price;

  int get missingAmount {
    return price - amountPaid;
  }

  void completeTransaction(List<int> changeCoins) {
    this.changeCoins = changeCoins;
    status = TransactionStatus.completed;
  }

  void failTransaction() {
    status = TransactionStatus.failed;
  }

  Transaction copyWith({
    String? transactionId,
    Product? product,
    int? amountPaid,
    TransactionStatus? status,
    List<int>? insertedCoins,
    List<int>? changeCoins,
  }) {
    return Transaction(
      transactionId: transactionId ?? this.transactionId,
      product: product ?? this.product,
      amountPaid: amountPaid ?? this.amountPaid,
      status: status ?? this.status,
      insertedCoins: insertedCoins ?? this.insertedCoins,
      changeCoins: changeCoins ?? this.changeCoins,
    );
  }
}
