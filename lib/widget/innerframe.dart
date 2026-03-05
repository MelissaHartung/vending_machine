import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snack_automat/models/product.dart';
import 'package:snack_automat/models/transaction.dart';
import 'package:snack_automat/provider/app_state_notifier.dart';
import 'package:snack_automat/widget/coin_menu.dart';
import 'package:snack_automat/widget/slotTile.dart';
import 'package:snack_automat/models/coin.dart';

class Innerframe extends ConsumerStatefulWidget {
  @override
  ConsumerState<Innerframe> createState() => _InnerframeState();
}

class _InnerframeState extends ConsumerState<Innerframe> {
  Product? _selectedProduct;
  String _displaymassage = '';
  Product? _dispensedProduct;
  List<int> _changeCoinsForPickup = [];
  String _changeAmountLabel() {
    final sumCents = _changeCoinsForPickup.fold<int>(
      0,
      (sum, coin) => sum + coin,
    );
    return '${(sumCents / 100).toStringAsFixed(2)} €';
  }

  double getCurrentBalance(Transaction? transaction) {
    return (transaction?.amountPaid ?? 0) / 100;
  }

  void _resetDisplayIfIdle() {
    final hasActiveTransaction =
        ref.read(appStateProvider).currentTransaction != null;
    if (!hasActiveTransaction &&
        _dispensedProduct == null &&
        _changeCoinsForPickup.isEmpty) {
      _displaymassage = '';
      _selectedProduct = null;
    }
  }

  void _showCoinMenu() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return CoinMenu(
          onCoinTap: (int value) {
            final hasTransaction =
                ref.read(appStateProvider).currentTransaction != null;
            if (!hasTransaction) {
              setState(() {
                _displaymassage = 'Bitte zuerst ein Produkt wählen';
              });
              return;
            }
            ref.read(appStateProvider.notifier).insertCoin(value);
            setState(() {
              _displaymassage = '';
            });
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = ref.watch(appStateProvider);
    final slots = appState.slots;
    final currentTransaction = appState.currentTransaction;
    final currentBalance = getCurrentBalance(currentTransaction);

    return Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 233, 175, 235),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              margin: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 233, 175, 235),
                borderRadius: BorderRadius.circular(10),
              ),
              child: GridView(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  childAspectRatio: 0.6,
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                ),
                children: slots.map((slot) {
                  return Slottile(
                    slot: slot,
                    onTap: () {
                      ref
                          .read(appStateProvider.notifier)
                          .selectProduct(slot.product.id);
                      setState(() {
                        _selectedProduct = slot.product;
                      });
                    },
                    selected: _selectedProduct?.id == slot.product.id,
                  );
                }).toList(),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 233, 175, 235),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.all(15),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 22, 22, 22),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      _displaymassage.isNotEmpty
                          ? _displaymassage
                          : (currentBalance == 0
                                ? 'Bitte Produkt wählen'
                                : '${currentBalance.toStringAsFixed(2)} €'),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 255, 255, 255),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Container(
                    height: 60,
                    width: 60,
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Color(0xFFBDBDBD),
                          Color(0xFFD6D6D6),
                          Color(0xFFF0F0F0),
                          Color(0xFFC2C2C2),
                        ],
                        stops: [0.0, 0.4, 0.6, 1.0],
                      ),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color.fromARGB(255, 0, 0, 0),
                        width: 2,
                      ),
                    ),
                    child: _selectedProduct != null
                        ? Image.asset(_selectedProduct!.image)
                        : const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 10),
                  InkWell(
                    onTap: _showCoinMenu,
                    child: Container(
                      height: 30,
                      width: 30,
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Color(0xFFBDBDBD),
                            Color(0xFFD6D6D6),
                            Color(0xFFF0F0F0),
                            Color(0xFFC2C2C2),
                          ],
                          stops: [0.0, 0.4, 0.6, 1.0],
                        ),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color.fromARGB(255, 0, 0, 0),
                          width: 2,
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          '|',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (currentTransaction != null) {
                        try {
                          ref
                              .read(appStateProvider.notifier)
                              .completePurchase();
                          setState(() {
                            _dispensedProduct = currentTransaction.product;
                            _displaymassage = 'Viel Spaß mit deinem Snack!';
                            _selectedProduct = null;
                            _changeCoinsForPickup = List<int>.from(
                              currentTransaction.changeCoins,
                            );
                          });
                        } catch (e) {
                          setState(() {
                            _displaymassage = e.toString();
                          });
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 148, 49, 140),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      side: const BorderSide(
                        color: Color.fromARGB(255, 53, 3, 50),
                        width: 2,
                      ),
                    ),
                    child: const Text(
                      'Kaufen',
                      style: TextStyle(fontSize: 12, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 5),
                  ElevatedButton(
                    onPressed: () {
                      if (currentTransaction != null) {
                        ref.read(appStateProvider.notifier).cancelTransaction();
                      }
                      setState(() {
                        _displaymassage = '';
                        _selectedProduct = null;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 148, 49, 140),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      side: const BorderSide(
                        color: Color.fromARGB(255, 53, 3, 50),
                        width: 2,
                      ),
                    ),
                    child: const Text(
                      'Abbrechen',
                      style: TextStyle(fontSize: 12, color: Colors.white),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      if (_changeCoinsForPickup.isEmpty) {
                        return;
                      }
                      setState(() {
                        _changeCoinsForPickup = [];
                        _resetDisplayIfIdle();
                      });
                    },
                    child: Container(
                      height: 30,
                      width: 90,
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 59, 59, 59),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color.fromARGB(255, 0, 0, 0),
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: _changeCoinsForPickup.isEmpty
                            ? const SizedBox.shrink()
                            : Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      Coin.getImage(_changeCoinsForPickup.first),
                                      height: 15,
                                      width: 15,
                                      fit: BoxFit.cover,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      _changeAmountLabel(),
                                      style: const TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  InkWell(
                    onTap: () {
                      setState(() {
                        _dispensedProduct = null;
                        _resetDisplayIfIdle();
                      });
                    },
                    child: Container(
                      height: 80,
                      width: 80,
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color.fromARGB(255, 29, 29, 29),
                            Color.fromARGB(255, 42, 42, 42),
                            Color.fromARGB(255, 58, 58, 58),
                            Color.fromARGB(255, 37, 37, 37),
                          ],
                          stops: [0.0, 0.4, 0.6, 1.0],
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black54,
                            blurRadius: 6,
                            offset: Offset(3, 4),
                          ),
                          BoxShadow(
                            color: Colors.white12,
                            blurRadius: 4,
                            offset: Offset(-2, -2),
                          ),
                        ],
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color.fromARGB(255, 0, 0, 0),
                          width: 2,
                        ),
                      ),
                      child: _dispensedProduct != null
                          ? Image.asset(_dispensedProduct!.image)
                          : const SizedBox.shrink(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
