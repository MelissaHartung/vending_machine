import 'package:flutter/material.dart';
import 'package:snack_automat/models/coin.dart';

class CoinMenu extends StatelessWidget {
  final Function(int) onCoinTap;

  const CoinMenu({super.key, required this.onCoinTap});

  @override
  Widget build(BuildContext context) {
    final List<int> coins = Coin.values;

    return Container(
      height: 300,
      padding: const EdgeInsets.all(20),
      color: Colors.grey[200],
      child: Column(
        children: [
          const Text(
            "Wähle eine Münze",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
              ),
              itemCount: coins.length,
              itemBuilder: (context, index) {
                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(5),
                    backgroundColor: Colors.white,
                  ),

                  onPressed: () => onCoinTap(coins[index]),
                  child: Image.asset(
                    Coin.getImage(coins[index]),
                    fit: BoxFit.contain,
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
