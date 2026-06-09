import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projeto/Style/custom_appbar.dart';
import 'package:projeto/services/LocalNotificationService%20.dart';

class NotificacoesPage extends StatefulWidget {
  const NotificacoesPage({super.key});

  @override
  State<NotificacoesPage> createState() => _NotificacoesPageState();
}

class _NotificacoesPageState extends State<NotificacoesPage> {
  final stream = FirebaseFirestore.instance
      .collection("notifications")
      .orderBy("data", descending: true)
      .snapshots();

  @override
  void initState() {
    super.initState();

    stream.listen((snapshot) {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final data = change.doc.data();

          if (data != null) {
            LocalNotificationService.instance.showNotification(
              title: data["titulo"] ?? "",
              body: data["mensagem"] ?? "",
            );
          }
        }
      }
    });
  }

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