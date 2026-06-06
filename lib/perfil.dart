import 'package:flutter/material.dart';
import 'Style/custom_appbar.dart';
import 'Style/text_styles.dart';
import 'home.dart';
import 'eventos.dart';
import 'donation.dart';
import 'forum.dart';
import 'info.dart';
import 'main.dart';

class PerfilPage extends StatelessWidget {
  const PerfilPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Perfil",
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {},
          ),
        ],
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 30),

            // ÍCONE PERFIL
            const CircleAvatar(
              radius: 55,
              backgroundColor: Colors.green,
              child: Icon(
                Icons.person,
                size: 60,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 30),

            // CAMPOS
            _buildInfoCard("Email", "utilizador@email.com"),
            _buildInfoCard("Nome / Nickname", "Utilizador123"),
            _buildInfoCard("Data de Nascimento", "01/01/2000"),
            _buildInfoCard("Localização", "Portugal"),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String label, String value) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(171, 255, 156, 1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}