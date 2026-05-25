import 'package:flutter/material.dart';
import 'login.dart';
import 'registo.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Projeto',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const StartPage(),
    );
  }
}

class StartPage extends StatelessWidget {
  const StartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Imagem
            Image.asset(
              'assets/logo.png',
              width: 200,
            ),

            const SizedBox(height: 40),

            // Botão Login
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green, // Cor de fundo do Botão
                foregroundColor: Colors.white, // Cor do texto
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
              child: const Text("Login"),
            ),

            const SizedBox(height: 20),

            // Botão Registo
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green, // Cor de fundo do Botão
                foregroundColor: Colors.white, // Cor do texto
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RegistoPage()),
                );
              },
              child: const Text("Registo"),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}