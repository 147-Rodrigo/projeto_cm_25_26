import 'package:flutter/material.dart';
import 'Style/custom_appbar.dart';
import 'Style/text_styles.dart';
import 'home.dart';
import 'donation.dart';
import 'forum.dart';
import 'info.dart';
import 'perfil.dart';
import 'main.dart';

class EventosPage extends StatelessWidget {
  const EventosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Eventos",
        actions: [
          IconButton(
            icon: const Icon(Icons.newspaper),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.notifications),
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
                    "Eventos",
                    style: AppTextStyles.welcomeTitle,
                  ),

                  const SizedBox(height: 20),

                  _buildInfoBox(
                    Icons.cleaning_services,
                    "Limpeza Verde Comunitária",
                    "15 de junho de 2026",
                    "Ação de recolha de lixo e reciclagem em espaços públicos.",
                  ),

                  const SizedBox(height: 15),

                  _buildInfoBox(
                    Icons.calendar_month,
                    "Dia da Reciclagem Ativa",
                    "3 de julho de 2026",
                    "Atividades rápidas para promover a separação correta de resíduos.",
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HomePage(),
                    ),
                    );
                  }),

                  _divider(),

                  //Eventos
                  _buildButton(Icons.calendar_month, () {}),
                  _divider(),

                  //Doações
                  _buildButton(Icons.volunteer_activism, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DonationPage(),
                      ),
                    );
                  }),

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

                  _divider(),

                  // LOGOUT
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

// ==========================
// INFO BOX
// ==========================

Widget _buildInfoBox(
  IconData icon,
  String username,
  String date,
  String text,
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

    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        // FOTO + NOME + DATA
        Row(
          children: [

            // ÍCONE
            CircleAvatar(
              radius: 25,
              backgroundColor: Colors.green,
              child: Icon(
                icon,
                color: Colors.white,
                size: 28,
              ),
            ),

            const SizedBox(width: 12),

            // NOME + DATA
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(
                  username,
                  style: AppTextStyles.forumUsername,
                ),

                const SizedBox(height: 4),

                Text(
                  date,
                  style: AppTextStyles.forumDate,
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 15),

        // TEXTO
        Text(
          text,
          style: AppTextStyles.forumText,
        ),
      ],
    ),
  );
}