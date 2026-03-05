import 'package:snack_automat/models/coinbox.dart';
import 'package:snack_automat/models/slot.dart';

abstract class DataRepository {
  Future<List<Slot>> getSlots();
  Future<void> updateSlot(String productId, int newQuantity);

  Future<Coinbox> getCoinbox();
  Future<void> updateCoinStock(int coinValue, int newCount);
}
