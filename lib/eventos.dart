import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'Style/custom_appbar.dart';
import 'Style/text_styles.dart';

import 'home.dart';
import 'donation.dart';
import 'forum.dart';
import 'info.dart';
import 'perfil.dart';
import 'evento_detalhe.dart';
import 'adicionar_evento.dart';
import 'noticias.dart';
import 'notificacoes.dart';

class EventosPage extends StatelessWidget {
  const EventosPage({super.key});

  // ─── Formata Timestamp ou String ────────────────────────────────────────────
  String _formatDate(dynamic value) {
    if (value == null) return '';
    if (value is Timestamp) {
      final dt = value.toDate();
      return '${dt.day.toString().padLeft(2, '0')} de '
          '${_mes(dt.month)} de ${dt.year}';
    }
    return value.toString();
  }

  String _mes(int m) {
    const meses = [
      '', 'janeiro', 'fevereiro', 'março', 'abril', 'maio', 'junho',
      'julho', 'agosto', 'setembro', 'outubro', 'novembro', 'dezembro'
    ];
    return meses[m];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Eventos",
        actions: [
          IconButton(
            icon: const Icon(Icons.newspaper),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NoticiasPage()),
            ),
          ),
          IconButton(
  icon: const Icon(Icons.notifications),
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const NotificacoesPage(),
      ),
    );
  },
),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PerfilPage()),
            ),
          ),
        ],
      ),

      // ─── FAB para adicionar evento ──────────────────────────────────────────
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AdicionarEventoPage()),
        ),
        tooltip: "Adicionar Evento",
        child: const Icon(Icons.add, color: Colors.white),
      ),

      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('eventos')
                  .orderBy('data', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      "Sem eventos de momento.\nCarregue em + para adicionar.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
                }

                final docs = snapshot.data!.docs;

                return SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 20),

                      const Text(
                        "Eventos",
                        style: AppTextStyles.welcomeTitle,
                      ),

                      const SizedBox(height: 20),

                      ...docs.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 15),
                          child: _buildEventoCard(
                            context: context,
                            docId: doc.id,
                            titulo: data['titulo'] as String? ?? '',
                            data: _formatDate(data['data']),
                            descricao: data['descricao'] as String? ?? '',
                            categoria: data['categoria'] as String? ?? '',
                          ),
                        );
                      }),

                      const SizedBox(height: 20),
                    ],
                  ),
                );
              },
            ),
          ),

          // ─── Barra inferior ─────────────────────────────────────────────────
          Container(
            width: double.infinity,
            color: Colors.green,
            child: SizedBox(
              height: 60,
              child: Row(
                children: [
                  _buildButton(Icons.map, () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const HomePage()))),
                  _divider(),
                  // Eventos — não faz nada (já estamos aqui)
                  _buildButton(Icons.calendar_month, () {}),
                  _divider(),
                  _buildButton(Icons.volunteer_activism, () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const DonationPage()))),
                  _divider(),
                  _buildButton(Icons.message, () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const ForumPage()))),
                  _divider(),
                  _buildButton(Icons.info, () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const InfoPage()))),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(IconData icon, VoidCallback onTap) => Expanded(
        child: InkWell(
          onTap: onTap,
          child: Center(child: Icon(icon, color: Colors.white, size: 28)),
        ),
      );

  Widget _divider() =>
      Container(width: 1, height: 30, color: Colors.white30);
}

// ─── Card de evento (tapping → detalhe) ──────────────────────────────────────
Widget _buildEventoCard({
  required BuildContext context,
  required String docId,
  required String titulo,
  required String data,
  required String descricao,
  required String categoria,
}) {
  return GestureDetector(
    onTap: () => Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EventoDetalhePage(eventoId: docId),
      ),
    ),
    child: Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(171, 255, 156, 1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ícone + Título + Data
          Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: Colors.green,
                child: const Icon(Icons.calendar_month,
                    color: Colors.white, size: 26),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(titulo, style: AppTextStyles.forumUsername),
                    const SizedBox(height: 4),
                    Text(data, style: AppTextStyles.forumDate),
                  ],
                ),
              ),
              // Badge categoria
              if (categoria.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.green.shade700,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    categoria,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(descricao, style: AppTextStyles.forumText),
          const SizedBox(height: 8),
          // "Ver mais" hint
          const Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text("Ver detalhes",
                  style: TextStyle(
                      color: Colors.green,
                      fontSize: 12,
                      fontWeight: FontWeight.bold)),
              SizedBox(width: 4),
              Icon(Icons.arrow_forward_ios,
                  color: Colors.green, size: 12),
            ],
          ),
        ],
      ),
    ),
  );
}
