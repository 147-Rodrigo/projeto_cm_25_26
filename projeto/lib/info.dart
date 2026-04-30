import 'package:flutter/material.dart';
import 'home.dart';
import 'eventos.dart';
import 'donation.dart';
import 'forum.dart';
import 'main.dart';

class InfoPage extends StatelessWidget {
  const InfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Guia Formativo"),
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
              'assets/info.png',
              fit: BoxFit.cover,
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            "Seja bem-vindo!",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          const Text(
            "Esta parte do nosso trabalho consiste em ajudar a comunidade que deseja tornar-se mais ecológica. Aqui encontras informações úteis sobre vários temas, como locais de reciclagem, lojas de roupa sustentável, cafés pet-friendly e outras iniciativas amigas do ambiente.",
            style: TextStyle(
              fontSize: 14,
              color: Colors.black,
            ),
          ),

          const Spacer(),

          // 🔘 Barra de ícones
          Container(
            width: double.infinity,
            color: Colors.green,
            child: SizedBox(
              height: 60,
              child: Row(
                children: [
                  //MAPA
                  _buildButton(Icons.map, () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const HomePage(),
                    ),
                    );
                  }),

                  _divider(),

                  //EVENTOS
                  _buildButton(Icons.calendar_month, () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const EventosPage(),
                    ),
                    );
                  }),
                  _divider(),

                  //DOAÇÕES (não faz nada)
                  _buildButton(Icons.volunteer_activism, () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const DonationPage(),
                    ),
                    );
                  }),
                  _divider(),

                  //Forum
                  _buildButton(Icons.message, () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const ForumPage(),
                    ),
                    );
                  }),
                  _divider(),

                  //INFO (não faz nada)
                  _buildButton(Icons.info, () {}),
                  _divider(),

                  //LOGOUT - volta ao Inicio da APP
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