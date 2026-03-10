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

// Eine neue Klasse, die das Ergebnis UND den neuen Zustand der Coinbox enthält
class PurchaseOutcome {
  final PaymentResult paymentResult;
  final Coinbox newCoinbox;

  PurchaseOutcome({required this.paymentResult, required this.newCoinbox});
}

class Coinbox {
  Map<int, int> _stock = {};

  Map<int, int> get currentStock => Map.from(_stock);

  Coinbox() {
    for (int value in Coin.values) {
      _stock[value] = 10;
    }
  }

  Coinbox.fromStock(Map<int, int> stock) {
    for (int value in Coin.values) {
      _stock[value] = stock[value] ?? 0;
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

  void setCoinCount(int coinValue, int newCount) {
    if (_stock.containsKey(coinValue) && newCount >= 0) {
      _stock[coinValue] = newCount;
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

  PurchaseOutcome processPayment(int price, List<int> insertedCoins) {
    //  Gesamtwert der eingeworfenen Münzen berechnen
    int totalInserted = insertedCoins.fold(0, (sum, coin) => sum + coin);

    //  Genug Geld?
    if (totalInserted < price) {
      return PurchaseOutcome(
        newCoinbox:
            this, // Es hat sich nichts geändert, gib die alte Coinbox zurück
        paymentResult: PaymentResult(
          success: false,
          message: "Nicht genug Geld.",
          changeCoins: insertedCoins, // Geld direkt wieder ausspucken
        ),
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

    if (change != null) {
      // Erfolg! Wir haben das Wechselgeld im `tempStock` berechnet.
      // `tempStock` repräsentiert jetzt den neuen, korrekten Zustand unserer Kasse.
      // Erstellen wir also eine neue Coinbox damit.
      final newCoinbox = Coinbox.fromStock(tempStock);
      return PurchaseOutcome(
        newCoinbox: newCoinbox,
        paymentResult: PaymentResult(
          success: true,
          message: "Vielen Dank!",
          changeCoins: change,
        ),
      );
    } else {
      // Fehler, kein Wechselgeld. Gib das Geld zurück und ändere den Bestand nicht.
      return PurchaseOutcome(
        newCoinbox:
            this, // Es hat sich nichts geändert, gib die alte Coinbox zurück
        paymentResult: PaymentResult(
          success: false,
          message: "Kein passendes Wechselgeld.",
          changeCoins: insertedCoins, // Kunde kriegt sein Geld zurück
        ),
      );
    }
  }
}
