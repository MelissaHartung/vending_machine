import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snack_automat/models/app_state.dart';
import 'package:snack_automat/models/coinbox.dart';
import 'package:snack_automat/models/slot.dart';
import 'package:snack_automat/models/transaction.dart';
import 'package:snack_automat/storage/snack_service.dart';

class AppStateNotifier extends Notifier<Appstate> {
  @override
  Appstate build() {
    return Appstate(
      slots: _createInitialSlots(),
      coinbox: Coinbox(),
      currentTransaction: null,
    );
  }

  List<Slot> _createInitialSlots() {
    final service = SnackService();
    return service.getSlots();
  }

  void selectProduct(String productId) {
    // 1. Finde das Produkt in den slots.
    final slot = state.slots.firstWhere((slot) => slot.product.id == productId);
    if (slot.isEmpty()) {
      throw StateError("Produkt ist nicht Verfügbar");
    }
    // 2. Erstelle eine neue Transaction mit diesem Produkt.
    final newTransaction = Transaction(
      product: slot.product,
      transactionId: '${DateTime.now().millisecondsSinceEpoch}',
    );
    // 3. Aktualisiere den State mit der neuen Transaktion.
    state = state.copyWith(currentTransaction: newTransaction);
  }

  void insertCoin(int coinValue) {
    // Prüfe ob Transaction existiert
    if (state.currentTransaction == null) {
      throw Exception('Keine aktive Transaktion');
    }

    // Erstelle neue Transaction mit aktualisiertem Betrag
    final updatedTransaction = Transaction(
      transactionId: state.currentTransaction!.transactionId,
      product: state.currentTransaction!.product,
      amountPaid: state.currentTransaction!.amountPaid + coinValue,
      insertedCoins: [...state.currentTransaction!.insertedCoins, coinValue],
    );

    // State aktualisieren
    state = state.copyWith(currentTransaction: updatedTransaction);
  }

  void completePurchase() {
    if (state.currentTransaction == null) {
      throw Exception('Keine aktive Transaktion');
    }

    final transaction = state.currentTransaction!;

    // Prüfe ob genug Geld da ist
    if (transaction.amountPaid < transaction.price) {
      throw Exception('Nicht genug Geld');
    }

    // Berechne Wechselgeld
    final result = state.coinbox.processPayment(
      transaction.price,
      transaction.insertedCoins,
    );

    if (!result.success) {
      throw Exception('Zahlung fehlgeschlagen');
    }

    // Slot aktualisieren (Produkt rausnehmen)
    final updatedSlots = state.slots.map((slot) {
      if (slot.product.id == transaction.product.id) {
        slot.decrement();
      }
      return slot;
    }).toList();

    // Transaction als completed markieren
    transaction.completeTransaction(result.changeCoins);

    // State zurücksetzen
    state = state.copyWith(slots: updatedSlots, currentTransaction: null);
  }

  void cancelTransaction() {
    // Einfach Transaction auf null setzen - Status ist egal wenn gelöscht
    state = state.copyWith(currentTransaction: null);
  }

  void incrementSlot(String productId) {
    final updatedSlots = state.slots.map((slot) {
      if (slot.product.id == productId) {
        slot.increment();
      }
      return slot;
    }).toList();

    state = state.copyWith(slots: updatedSlots);
  }

  void decrementSlot(String productId) {
    final updatedSlots = state.slots.map((slot) {
      if (slot.product.id == productId) {
        slot.decrement();
      }
      return slot;
    }).toList();

    state = state.copyWith(slots: updatedSlots);
  }

  void addCoinToBox(int coinValue) {
    state.coinbox.addCoin(coinValue, 1);
    // State muss neu gesetzt werden damit Riverpod merkt dass sich was geändert hat
    state = state.copyWith(coinbox: state.coinbox);
  }

  void removeCoinFromBox(int coinValue) {
    state.coinbox.removeCoin(coinValue, 1);
    state = state.copyWith(coinbox: state.coinbox);
  }
}

final appStateProvider = NotifierProvider<AppStateNotifier, Appstate>(
  () => AppStateNotifier(),
);
