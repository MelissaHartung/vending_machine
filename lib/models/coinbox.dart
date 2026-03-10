import 'package:snack_automat/models/coin.dart';

class PaymentResult {
  final List<int> changeCoins;
  final String message;
  final bool success;

  PaymentResult({
    this.changeCoins = const [],
    required this.message,
    required this.success,
  });
}

class Coinbox {
  Map<int, int> _stock = {};

  Coinbox() {
    for (int value in Coin.values) {
      _stock[value] = 10;
    }
  }

  Map<int, int> get stock => Map.from(_stock);
  void addCoin(int coinValue, int amount) {
    if (_stock.containsKey(coinValue)) {
      _stock[coinValue] = _stock[coinValue]! + amount;
    }
  }

  void removeCoin(int coinValue, int amount) {
    if (_stock.containsKey(coinValue) && _stock[coinValue]! >= amount) {
      _stock[coinValue] = _stock[coinValue]! - amount;
    }
  }

  // Gibt eine Liste der Münzen zurück, wenn es klappt.
  // Gibt null zurück, wenn wir nicht passend herausgeben können.
  List<int>? _tryCalculateChange(Map<int, int> tempStock, int changeAmount) {
    List<int> changeToReturn = [];
    int remaining = changeAmount;

    // WICHTIG: Wir müssen die Münzwerte rückwärts durchgehen (von groß nach klein)
    // Coin.values ist [1, 2, 5, ..., 200]. reversed hilft uns dabei.
    for (int coinValue in Coin.values.reversed) {
      while (remaining >= coinValue && tempStock[coinValue]! > 0) {
        remaining = remaining - coinValue;
        tempStock[coinValue] = tempStock[coinValue]! - 1;
        changeToReturn.add(coinValue);
      }
    }
    if (remaining == 0) {
      //kein rest vom wechselgeld übrig
      return changeToReturn;
    } else {
      return null;
    }

    // Diese Münze ist zu groß, überspringen
  }

  PaymentResult processPayment(int price, List<int> insertedCoins) {
    //  Gesamtwert der eingeworfenen Münzen berechnen
    int totalInserted = insertedCoins.fold(0, (sum, coin) => sum + coin);

    //  Genug Geld?
    if (totalInserted < price) {
      return PaymentResult(
        success: false,
        message: "Nicht genug Geld.",
        changeCoins: insertedCoins, // Geld direkt wieder ausspucken
      );
    }

    int changeNeeded = totalInserted - price;

    // Simulation: eine Kopie unseres Bestands
    // und tun so, als wären die eingeworfenen Münzen schon drin.
    // (Denn man kann ja auch das eingeworfene Geld direkt als Wechselgeld nutzen!)
    Map<int, int> tempStock = Map.from(_stock);
    for (var coin in insertedCoins) {
      tempStock[coin] = tempStock[coin]! + 1;
      // ... tempStock erhöhen, um mit dem zugeführenen Geld, das Wechselgeldzu rechnen
    }

    // Versuchen, das  Wechselgeld zu berechnen mit den simulierten Münzen mit der tryCalculateChange-Methode
    List<int>? change = _tryCalculateChange(tempStock, changeNeeded);

    //  Die eingeworfenen Münzen zum ECHTEN Bestand (_stock) hinzufügen.
    if (change != null) {
      for (var coin in insertedCoins) {
        _stock[coin] = _stock[coin]! + 1;
      }
      // Wechselgeld abziehen
      for (var coin in change) {
        _stock[coin] = _stock[coin]! - 1;
      }

      return PaymentResult(
        success: true,
        message: "Vielen Dank!",
        changeCoins: change,
      );
    } else {
      return PaymentResult(
        success: false,
        message: "Kein passendes Wechselgeld.",
        changeCoins: insertedCoins, // Kunde kriegt sein Geld zurück
      );
    }
  }
}
