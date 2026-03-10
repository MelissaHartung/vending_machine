import 'package:snack_automat/models/coinbox.dart';
import 'package:snack_automat/models/transaction.dart';
import 'package:snack_automat/models/slot.dart';

class Appstate {
  static const Object _noChange = Object();

  final List<Slot> slots;
  final Coinbox coinbox;
  final Transaction? currentTransaction;

  Appstate({
    required this.slots,
    required this.coinbox,
    this.currentTransaction,
  });

  Appstate copyWith({
    List<Slot>? slots,
    Coinbox? coinbox,
    Object? currentTransaction = _noChange,
  }) {
    return Appstate(
      slots: slots ?? this.slots,
      coinbox: coinbox ?? this.coinbox,
      currentTransaction: identical(currentTransaction, _noChange)
          ? this.currentTransaction
          : currentTransaction as Transaction?,
    );
  }
}
