import 'package:snack_automat/models/coinbox.dart';
import 'package:snack_automat/models/product.dart';
import 'package:snack_automat/models/slot.dart';
import 'package:snack_automat/storage/data_repository.dart';

class MockDataRepository implements DataRepository {
  final List<Slot> _slots = [];
  final Coinbox _coinbox = Coinbox();

  MockDataRepository() {
    _initializeMockData();
  }

  void _initializeMockData() {
    _slots.addAll([
      Slot(
        product: Product(
          id: 'p1',
          name: 'Riegel',
          price: 100,
          image: 'images/snack.png',
        ),
      ),
      Slot(
        product: Product(
          id: 'p2',
          name: 'Chips',
          price: 190,
          image: 'images/kekse.png',
        ),
      ),
      Slot(
        product: Product(
          id: 'p3',
          name: 'Kekse',
          price: 100,
          image: 'images/kekse.png',
        ),
      ),
      Slot(
        product: Product(
          id: 'p4',
          name: 'Bonbons',
          price: 300,
          image: 'images/snack.png',
        ),
      ),
      Slot(
        product: Product(
          id: 'p5',
          name: 'Waffeln',
          price: 100,
          image: 'images/snack.png',
        ),
      ),
      Slot(
        product: Product(
          id: 'p6',
          name: 'Wasser',
          price: 250,
          image: 'images/popcorn.png',
        ),
      ),
    ]);
  }

  @override
  Future<List<Slot>> getSlots() async {
    await Future.delayed(Duration(milliseconds: 100));
    return List.from(_slots);
  }

  @override
  Future<void> updateSlot(String productId, int newQuantity) async {
    await Future.delayed(Duration(milliseconds: 50));
    final slot = _slots.firstWhere((slot) => slot.product.id == productId);
    slot.quantity = newQuantity;
    // Hier später der Supabase-Call
  }

  @override
  Future<Coinbox> getCoinbox() async {
    await Future.delayed(Duration(milliseconds: 100));
    return _coinbox;
  }

  @override
  Future<void> updateCoinStock(int coinValue, int newCount) async {
    await Future.delayed(Duration(milliseconds: 50));
    _coinbox.setCoinCount(coinValue, newCount);
    // Hier später der Supabase-Call
  }
}
