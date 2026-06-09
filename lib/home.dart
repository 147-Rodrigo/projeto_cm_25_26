import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'API/maps.dart';
import 'Style/custom_appbar.dart';

import 'perfil.dart';
import 'eventos.dart';
import 'donation.dart';
import 'forum.dart';
import 'info.dart';
import 'noticias.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Home",
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
            },
          ),
        ],
      ),

      body: Column(
        children: [

          // MAPA
          Expanded(
            child: kIsWeb
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.map, size: 80, color: Colors.green),
                        SizedBox(height: 16),
                        Text(
                          "Mapa disponível apenas na app mobile",
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : SizedBox.expand(child: Maps()),
          ),

          // BARRA INFERIOR
          Container(
            width: double.infinity,
            color: Colors.green,

            child: SizedBox(
              height: 60,

              child: Row(
                children: [

                  // MAPA
                  _buildButton(Icons.map, () {}),

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
                  _buildButton(Icons.message, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ForumPage(),
                      ),
                    );
                  }),

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

  static Widget _buildButton(
    IconData icon,
    VoidCallback onTap,
  ) {
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

  static Widget _divider() {
    return Container(
      width: 1,
      height: 30,
      color: Colors.white30,
    );
  }
}
