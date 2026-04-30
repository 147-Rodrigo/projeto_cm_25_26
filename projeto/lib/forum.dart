import 'package:flutter/material.dart';
import 'home.dart';
import 'eventos.dart';
import 'donation.dart';
import 'info.dart';
import 'main.dart';

class ForumPage extends StatelessWidget {
  const ForumPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Fórum"),
        centerTitle: true,

        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),

      body: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 200,
            child: Image.asset(
              'assets/forum.png',
              fit: BoxFit.cover,
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            "Seja bem-vindo à comunidade",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          const Text(
            "José Nunes: Devemos todos reciclar. Pequenas ações fazem diferença no ambiente da nossa comunidade.",
            style: TextStyle(
              fontSize: 14,
              color: Colors.black,
            ),
          ),

          const Spacer(),

          //Barra de ícones
          Container(
            width: double.infinity,
            color: Colors.green,
            child: SizedBox(
              height: 60,
              child: Row(
                children: [
                  //Mapa
                  _buildButton(Icons.map, () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const HomePage(),
                    ),
                    );
                  }),

                  _divider(),

                  //Eventos
                  _buildButton(Icons.calendar_month, () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const EventosPage(),
                    ),
                    );
                  }),
                  _divider(),

                  //Doações (não faz nada)
                  _buildButton(Icons.volunteer_activism, () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const DonationPage(),
                    ),
                    );
                  }),
                  _divider(),

                  //Forum (não faz nada)
                  _buildButton(Icons.message, () {}),
                  _divider(),

                  //Info
                  _buildButton(Icons.info, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const InfoPage(),
                      ),
                    );
                  }),

                  _divider(),

                  //Sair - volta ao Inicio da APP
                  _buildButton(Icons.logout, () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const StartPage(),
                      ),
                      (route) => false,
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(IconData icon, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Center(
          child: Icon(icon, color: Colors.white, size: 28),
        ),
      ),
    );
  }

  Widget _divider() {
    return Container(
      width: 1,
      height: 30,
      color: Colors.white30,
    );
  }
}