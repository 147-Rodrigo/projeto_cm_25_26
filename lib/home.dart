import 'package:flutter/material.dart';

import 'API/maps.dart';
import 'Style/custom_appbar.dart';

import 'perfil.dart';
import 'eventos.dart';
import 'donation.dart';
import 'forum.dart';
import 'info.dart';
import 'main.dart';

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
            },
          ),
        ],
      ),

      body: Column(
        children: [

          // MAPA
          Expanded(
            child: SizedBox.expand(
              child: Maps(),
            ),
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