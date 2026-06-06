import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:projeto/Style/custom_appbar.dart';
import 'package:projeto/services/auth_service.dart';

import 'Style/profile_styles.dart';

import 'main.dart';

class PerfilPage extends StatelessWidget {
  const PerfilPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text("Utilizador não autenticado"),
        ),
      );
    }

    final uid = user.uid;

    return Scaffold(
      appBar: CustomAppBar(
        title: "Perfil",
      ),

      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection("users")
            .doc(uid)
            .snapshots(),
        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
              child: Text("Perfil não encontrado"),
            );
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 30),

                const CircleAvatar(
                  radius: 55,
                  backgroundColor: Colors.green,
                  child: Icon(
                    Icons.person,
                    size: 60,
                    color: Colors.white,
                  ),
                ),

                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      final user = FirebaseAuth.instance.currentUser;
                      
                      if (user == null) return;
                      
                      final auth = AuthService();
                      
                      auth.showEditProfileSheet(context: context, uid: user.uid, currentData: data,
                    );
                  },
                ),
                ),

                const SizedBox(height: 30),

                _buildInfoCard("Email", data["email"] ?? ""),
                _buildInfoCard("Nome", data["nome"] ?? ""),
                _buildInfoCard("Data de Nascimento", data["dataNascimento"] ?? ""),
                _buildInfoCard("Localização", data["localizacao"] ?? ""),

                const SizedBox(height: 20),

                ElevatedButton(
                  style: ProfileStyles.logoutButton,
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();

                    if (!context.mounted) return;

                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const StartPage(),
                      ),
                      (route) => false,
                    );
                  },
                  child: const Text("Terminar sessão"),
                ),

                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }
}

Widget _buildInfoCard(String label, String value) {
  return Container(
    width: double.infinity,
    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
    padding: const EdgeInsets.all(16),
    decoration: ProfileStyles.cardDecoration,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: ProfileStyles.labelStyle),
        const SizedBox(height: 6),
        Text(value, style: ProfileStyles.valueStyle),
      ],
    ),
  );
}