import 'package:flutter/material.dart';
import 'Style/custom_appbar.dart';
import 'Style/text_styles.dart';
import 'home.dart';
import 'eventos.dart';
import 'donation.dart';
import 'forum.dart';
import 'perfil.dart';
import 'noticias.dart';

class InfoPage extends StatelessWidget {
  const InfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Guia",
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
                    "Seja bem-vindo!",
                    style: AppTextStyles.welcomeTitle
                  ),

                  const SizedBox(height: 20),

                  _buildInfoBox(
                    "EcoLoop",
                    "Esta parte do nosso trabalho consiste em ajudar a comunidade que deseja tornar-se mais ecológica. Aqui encontras informações úteis sobre vários temas, como locais de reciclagem, lojas de roupa sustentável, cafés pet-friendly e outras iniciativas amigas do ambiente.",
                  ),

                  const SizedBox(height: 15),

                  _buildInfoBox(
                    "♻️ Ecopontos: Onde e Como Usar",
                    "Os ecopontos estão distribuídos por toda a cidade e são essenciais para a separação correta dos resíduos.",
                  ),

                  const SizedBox(height: 15),

                  _buildInfoBox(
                    "👕 Lojas de Roupa Sustentável",
                    "Promovemos reutilização e economia circular através das nossas lojas parceiras.",
                  ),

                  const SizedBox(height: 15),

                  _buildInfoBox(
                    "🐾 Cafés Pet-Friendly",
                    "Descobre cafés que aceitam animais e promovem práticas sustentáveis.",
                  ),

                  const SizedBox(height: 15),

                  _buildInfoBox(
                    "🌿 Dicas para um Dia-a-Dia Mais Verde",
                    "Pequenas mudanças fazem grande diferença no ambiente.",
                  ),

                  const SizedBox(height: 15),

                  _buildInfoBox(
                    "📍 Mapa Verde Interativo",
                    "Encontra locais eco-friendly e pontos de reciclagem.",
                  ),

                  const SizedBox(height: 15),

                  _buildInfoBox(
                    "📅 Eventos de Sustentabilidade",
                    "Participa em workshops e eventos ecológicos.",
                  ),

                  const SizedBox(height: 15),

                  _buildInfoBox(
                    "🤝 Doações",
                    "Contribui para projetos sustentáveis e solidários.",
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // Bottom Bar fixa
          Container(
            width: double.infinity,
            color: Colors.green,
            child: SizedBox(
              height: 60,
              child: Row(
                children: [
                  _buildButton(Icons.map, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const HomePage()),
                    );
                  }),

                  _divider(),

                  _buildButton(Icons.calendar_month, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const EventosPage()),
                    );
                  }),

                  _divider(),

                  _buildButton(Icons.volunteer_activism, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const DonationPage()),
                    );
                  }),

                  _divider(),

                  _buildButton(Icons.message, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ForumPage()),
                    );
                  }),

                  _divider(),

                  _buildButton(Icons.info, () {}),
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

//InfoBox
Widget _buildInfoBox(String title, String text) {
  return Container(
    width: double.infinity,

    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),

    padding: const EdgeInsets.all(16),

    decoration: BoxDecoration(
      color: Color.fromRGBO(171, 255, 156, 100),
      borderRadius: BorderRadius.circular(15),
    ),

    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black,
          ),
        ),
      ],
    ),
  );
}
