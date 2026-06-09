import 'package:flutter/material.dart';
import 'Style/custom_appbar.dart';
import 'Style/text_styles.dart';
import 'home.dart';
import 'eventos.dart';
import 'forum.dart';
import 'info.dart';
import 'perfil.dart';
import 'noticias.dart';

class DonationPage extends StatelessWidget {
  const DonationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Doações",
        actions: [
          IconButton(
            icon: const Icon(Icons.newspaper),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NoticiasPage()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PerfilPage(),
                  ),
                );
              }),
        ],
      ),

      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [

                  const SizedBox(height: 20),

                  const Text(
                    "Doar",
                    style: AppTextStyles.welcomeTitle,
                  ),

                  const SizedBox(height: 20),

                  _buildInfoBox(
                    "Cáritas Portuguesa",
                    "assets/doações/caritas.png",
                    ),

                  const SizedBox(height: 15),

                  _buildInfoBox(
                    "Banco Alimentar Contra a Fome",
                    "assets/doações/banco_alimentar.png",
                    ),

                  const SizedBox(height: 15),

                  _buildInfoBox("Comunidade Vida e Paz",
                  "assets/doações/comunidade_vida.png",
                  ),

                  const SizedBox(height: 15),

                  _buildInfoBox("Santa Casa da Misericórdia",
                  "assets/doações/santa_casa.png",
                  ),

                  const SizedBox(height: 15),

                  _buildInfoBox("Cruz Vermelha Portuguesa",
                  "assets/doações/cruz.png",
                  ),

                  const SizedBox(height: 15),

                  _buildInfoBox("Liga dos Bombeiros Portugueses",
                  "assets/doações/bombeiros.png",
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

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
                  _buildButton(Icons.volunteer_activism, () {}),
                  _divider(),

                  //Mensagens
                  _buildButton(Icons.message, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ForumPage(),
                      ),
                    );
                  }),

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
          child: Icon(
            icon,
            color: Colors.white,
            size: 28,
          ),
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

// INFO BOX

Widget _buildInfoBox(
  String title,
  String imagePath,
) {
  return Container(
    width: double.infinity,

    margin: const EdgeInsets.symmetric(
      horizontal: 20,
      vertical: 5,
    ),

    padding: const EdgeInsets.all(16),

    decoration: BoxDecoration(
      color: const Color.fromRGBO(171, 255, 156, 1),
      borderRadius: BorderRadius.circular(15),
    ),

    child: Row(
      children: [

        // IMAGEM
        CircleAvatar(
          radius: 25,
          backgroundColor: Colors.white,
          backgroundImage: AssetImage(imagePath),
        ),

        const SizedBox(width: 15),

        // TEXTO
        Expanded(
          child: Text(
            title,
            style: AppTextStyles.cardTitle,
          ),
        ),
      ],
    ),
  );
}
