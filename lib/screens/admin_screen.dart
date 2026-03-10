import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snack_automat/provider/app_state_notifier.dart';
import 'package:snack_automat/models/coin.dart';

class Adminscreen extends ConsumerStatefulWidget {
  const Adminscreen({super.key});

  @override
  ConsumerState<Adminscreen> createState() => _AdminscreenState();
}

class _AdminscreenState extends ConsumerState<Adminscreen> {
  double _gesamtGeld(Map<int, int> coinStock) {
    int summe = 0;
    coinStock.forEach((wert, anzahl) {
      summe += wert * anzahl;
    });
    return summe.toDouble() / 100;
  }

  @override
  Widget build(BuildContext context) {
    final appState = ref.watch(appStateProvider);
    final slots = appState.slots;
    final coinStock = appState.coinbox.stock;

    return Scaffold(
      appBar: AppBar(title: const Text("Verwaltung")),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              "Warenbestand",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: slots.length,
              itemBuilder: (context, index) {
                final slot = slots[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    vertical: 5,
                    horizontal: 10,
                  ),
                  child: ListTile(
                    leading: Image.asset(slot.product.image),
                    title: Text(slot.product.name),
                    subtitle: Text("Bestand: ${slot.quantity}"),
                    trailing: SizedBox(
                      width: 120,
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: () {
                              ref
                                  .read(appStateProvider.notifier)
                                  .decrementSlot(slot.product.id);
                            },
                          ),
                          Text(slot.quantity.toString()),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () {
                              ref
                                  .read(appStateProvider.notifier)
                                  .incrementSlot(slot.product.id);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(thickness: 2),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Wechselgeld",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  "Gesamt: ${_gesamtGeld(coinStock).toStringAsFixed(2)} €",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: Coin.values.length,
              itemBuilder: (context, index) {
                final coinValue = Coin.values[index];
                final coinCount = coinStock[coinValue] ?? 0;
                return Card(
                  margin: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 10,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListTile(
                      leading: Image.asset(Coin.getImage(coinValue)),
                      title: Text("${(coinValue / 100).toStringAsFixed(2)} €"),
                      trailing: SizedBox(
                        width: 120,
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: () => ref
                                  .read(appStateProvider.notifier)
                                  .removeCoinFromBox(coinValue),
                            ),
                            Text(coinCount.toString()),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () => ref
                                  .read(appStateProvider.notifier)
                                  .addCoinToBox(coinValue),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
