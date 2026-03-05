import 'package:flutter/material.dart';
import 'package:snack_automat/screens/admin_screen.dart';
import 'package:snack_automat/widget/innerframe.dart';

class Homescreen extends StatelessWidget {
  const Homescreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('images/miau.webp', fit: BoxFit.cover),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize
                  .min, // Damit die Column nur so groß wie nötig ist
              children: [
                AspectRatio(
                  aspectRatio: 2 / 3,
                  child: Container(
                    margin: const EdgeInsets.all(30),
                    padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromARGB(255, 110, 110, 110),
                          spreadRadius: 5,
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                      border: Border.all(
                        color: const Color.fromARGB(255, 80, 2, 69),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(10),
                      color: const Color.fromARGB(255, 180, 112, 177),
                    ),
                    child: Innerframe(),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 150,
                      vertical: 10,
                    ),
                    side: BorderSide(
                      color: const Color.fromARGB(255, 194, 194, 194),
                      width: 2,
                    ),
                  ),
                  onPressed: () {
                    final TextEditingController passwordController =
                        TextEditingController();

                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text("Admin Login"),
                          content: TextField(
                            controller: passwordController,
                            obscureText: true,
                            decoration: const InputDecoration(
                              hintText: "Passwort",
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                if (passwordController.text == "1234") {
                                  Navigator.pop(context);
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => const Adminscreen(),
                                    ),
                                  );
                                }
                              },
                              child: const Text("Anmelden"),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: const Text(
                    style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                    "Admin",
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
