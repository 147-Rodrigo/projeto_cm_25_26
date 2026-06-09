import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projeto/Style/custom_appbar.dart';

class NotificacoesPage extends StatelessWidget {
  const NotificacoesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Notificações",
      ),
body: StreamBuilder<QuerySnapshot>(
  stream: FirebaseFirestore.instance
      .collection("notifications")
      .orderBy("data", descending: true)
      .snapshots(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
      return const Center(child: Text("Sem notificações"));
    }

    final notificacoes = snapshot.data!.docs;

    return ListView.builder(
      itemCount: notificacoes.length,
      itemBuilder: (context, index) {
        final notif = notificacoes[index];

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: ListTile(
            leading: const Icon(Icons.notifications, color: Colors.green),
            title: Text(notif["titulo"] ?? ""),
            subtitle: Text(notif["mensagem"] ?? ""),
          ),
        );
      },
    );
  },
),
    );
  }
}