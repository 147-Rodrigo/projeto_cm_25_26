import 'package:flutter/material.dart';
import 'Style/custom_appbar.dart';
import 'Style/text_styles.dart';
import 'home.dart';
import 'eventos.dart';
import 'donation.dart';
import 'info.dart';
import 'perfil.dart';
import 'main.dart';

class ForumPage extends StatelessWidget {
  const ForumPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Fórum",
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
                    "Seja bem-vindo à comunidade!",
                    style: AppTextStyles.welcomeTitle,
                  ),

                  const SizedBox(height: 20),

                  _buildInfoBox(
                    "José Nunes",
                    "1 hora",
                    "Devemos todos reciclar. Pequenas ações fazem diferença no ambiente da nossa comunidade.",
                  ),

                  const SizedBox(height: 15),

                  _buildInfoBox(
                    "João Silva",
                    "5 dias",
                    "Os ecopontos estão distribuídos por toda a cidade e são essenciais para a separação correta dos resíduos.",
                  ),

                  const SizedBox(height: 15),

                  _buildInfoBox(
                    "Maria Ferreira",
                    "1 semana",
                    "Comecei a separar o lixo cá em casa há uns meses e nota-se mesmo a diferença na quantidade de resíduos indiferenciados. Pequenas mudanças acabam por ter impacto.",
                  ),

                  const SizedBox(height: 15),

                  _buildInfoBox(
                    "Ricardo Pêra",
                    "3 meses",
                    "Acho que ainda falta mais educação ambiental nas escolas e nas empresas. Muita gente quer reciclar mas nem sempre sabe onde colocar cada material",
                  ),

                  const SizedBox(height: 15),

                  _buildInfoBox(
                    "Tiago Santos",
                    "1 ano",
                    "Tenho tentado comprar menos plástico descartável e usar garrafas reutilizáveis. Além de produzir menos lixo, também se acaba por poupar dinheiro.",
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // Barra Inferior
          Container(
            width: double.infinity,
            color: Colors.green,
            child: SizedBox(
              height: 60,
              child: Row(
                children: [

                  // MAPA
                  _buildButton(Icons.map, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HomePage(),
                      ),
                    );
                  }),

                  _divider(),

                  // EVENTOS
                  _buildButton(Icons.calendar_month, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EventosPage(),
                      ),
                    );
                  }),

                  _divider(),

                  // DOAÇÕES
                  _buildButton(Icons.volunteer_activism, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DonationPage(),
                      ),
                    );
                  }),

                  _divider(),

                  // FÓRUM
                  _buildButton(Icons.message, () {}),

                  _divider(),

                  // INFO
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

// ==========================
// INFO BOX
// ==========================

Widget _buildInfoBox(
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

            // FOTO PERFIL
            const CircleAvatar(
              radius: 25,
              backgroundColor: Colors.green,
              child: Icon(
                Icons.person,
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