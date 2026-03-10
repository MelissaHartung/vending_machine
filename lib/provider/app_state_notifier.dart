import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snack_automat/models/app_state.dart';
import 'package:snack_automat/models/coinbox.dart';
import 'package:snack_automat/models/slot.dart';
import 'package:snack_automat/models/transaction.dart';
import 'package:snack_automat/storage/data_repository.dart';
import 'package:snack_automat/storage/repository_provider.dart';

class AppStateNotifier extends Notifier<Appstate> {
  DataRepository get _repository => ref.read(dataRepositoryProvider);

  @override
  Appstate build() {
    _loadInitialData();
    return Appstate(
      slots: _createInitialSlots(),
      coinbox: Coinbox(),
      currentTransaction: null,
    );
  }

  Future<void> _loadInitialData() async {
    final slots = await _repository.getSlots();
    final coinbox = await _repository.getCoinbox();
    state = state.copyWith(slots: slots, coinbox: coinbox);
  }

  List<Slot> _createInitialSlots() {
    // Leere Liste zurückgeben, da _loadInitialData die echten Daten lädt.
    return [];
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
      return;
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
    final purchaseOutcome = state.coinbox.processPayment(
      transaction.price,
      transaction.insertedCoins,
    );

    if (!purchaseOutcome.paymentResult.success) {
      throw Exception(purchaseOutcome.paymentResult.message);
    }

    // Slot aktualisieren (Produkt rausnehmen)
    final updatedSlots = state.slots.map((slot) {
      if (slot.product.id == transaction.product.id) {
        // Erstelle eine Kopie des Slots mit reduzierter Menge
        return slot.copyWith(quantity: slot.quantity - 1);
      }
      return slot; // Gib den unveränderten Slot zurück
    }).toList();

    // Transaction als completed markieren
    transaction.completeTransaction(purchaseOutcome.paymentResult.changeCoins);

    // State zurücksetzen
    state = state.copyWith(
      slots: updatedSlots,
      coinbox: purchaseOutcome.newCoinbox,
      currentTransaction: null,
    );
  }

  void cancelTransaction() {
    // Einfach Transaction auf null setzen - Status ist egal wenn gelöscht
    state = state.copyWith(currentTransaction: null);
  }

  void incrementSlot(String productId) async {
    // Erstelle eine neue Liste, indem du den richtigen Slot durch eine Kopie ersetzt
    final updatedSlots = state.slots.map((slot) {
      if (slot.product.id == productId) {
        final newQuantity = slot.quantity < Slot.maxCapacity
            ? slot.quantity + 1
            : slot.quantity;
        return slot.copyWith(quantity: newQuantity);
      }
      return slot;
    }).toList();

    state = state.copyWith(slots: updatedSlots);

    // Finde den aktualisierten Slot, um die neue Menge an das Repository zu senden
    final updatedSlot = updatedSlots.firstWhere(
      (slot) => slot.product.id == productId,
    );
    await _repository.updateSlot(productId, updatedSlot.quantity);
  }

  void decrementSlot(String productId) async {
    final updatedSlots = state.slots.map((slot) {
      if (slot.product.id == productId) {
        // Erstelle eine Kopie des Slots mit reduzierter Menge
        final newQuantity = slot.quantity > 0 ? slot.quantity - 1 : 0;
        return slot.copyWith(quantity: newQuantity);
      }
      return slot;
    }).toList();

    state = state.copyWith(slots: updatedSlots);

    final updatedSlot = updatedSlots.firstWhere(
      (slot) => slot.product.id == productId,
    );
    await _repository.updateSlot(productId, updatedSlot.quantity);
  }

  void addCoinToBox(int coinValue) async {
    state.coinbox.addCoin(coinValue, 1);
    // State muss neu gesetzt werden damit Riverpod merkt dass sich was geändert hat
    state = state.copyWith(coinbox: state.coinbox);
    final newCount = state.coinbox.stock[coinValue] ?? 0;
    await _repository.updateCoinStock(coinValue, newCount);
  }

  void removeCoinFromBox(int coinValue) async {
    state.coinbox.removeCoin(coinValue, 1);
    state = state.copyWith(coinbox: state.coinbox);
    final newCount = state.coinbox.stock[coinValue] ?? 0;
    await _repository.updateCoinStock(coinValue, newCount);
  }
}

final appStateProvider = NotifierProvider<AppStateNotifier, Appstate>(
  () => AppStateNotifier(),
);
