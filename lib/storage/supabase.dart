import 'package:snack_automat/models/coinbox.dart';
import 'package:snack_automat/models/slot.dart';
import 'package:snack_automat/storage/data_repository.dart';
import 'package:snack_automat/storage/snack_service.dart';

class SupabaseDataRepository implements DataRepository {
  // Übergangsweise delegieren auf Mock-Daten, bis URL/Key + Tabellen da sind.
  // Danach nur die Methodeninhalte einpflegen
  final MockDataRepository _fallback = MockDataRepository();

  @override
  Future<List<Slot>> getSlots() {
    return _fallback.getSlots();
  }

  @override
  Future<void> updateSlot(String productId, int newQuantity) {
    return _fallback.updateSlot(productId, newQuantity);
  }

  @override
  Future<Coinbox> getCoinbox() {
    return _fallback.getCoinbox();
  }

  @override
  Future<void> updateCoinStock(int coinValue, int newCount) {
    return _fallback.updateCoinStock(coinValue, newCount);
  }
}
