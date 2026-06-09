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
import 'services/admin_service.dart';
class EventosPage extends StatefulWidget {
  const EventosPage({super.key});

  @override
  State<EventosPage> createState() => _EventosPageState();
}

class _EventosPageState extends State<EventosPage> {
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    AdminService.isAdmin().then((v) => setState(() => _isAdmin = v));
  }

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

  // ─── Apagar evento (admin) ──────────────────────────────────────────────────
  Future<void> _apagarEvento(String docId) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Apagar evento?"),
        content: const Text("Esta ação é irreversível."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Apagar",
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    await FirebaseFirestore.instance
        .collection('eventos')
        .doc(docId)
        .delete();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Evento apagado.")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Eventos",
        actions: [
          if (_isAdmin)
            const Tooltip(
              message: "Modo Admin",
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Icon(Icons.admin_panel_settings,
                    color: Colors.amber, size: 22),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.newspaper),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const NoticiasPage())),
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
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const PerfilPage())),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const AdicionarEventoPage())),
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
                      const Text("Eventos", style: AppTextStyles.welcomeTitle),
                      const SizedBox(height: 20),
                      ...docs.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 15),
                          child: _EventoCard(
                            docId: doc.id,
                            titulo: data['titulo'] as String? ?? '',
                            data: _formatDate(data['data']),
                            descricao: data['descricao'] as String? ?? '',
                            categoria: data['categoria'] as String? ?? '',
                            isAdmin: _isAdmin,
                            onDelete: () => _apagarEvento(doc.id),
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

          // Barra inferior
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
                  _buildButton(Icons.calendar_month, () {}),
                  _divider(),
                  _buildButton(Icons.volunteer_activism, () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const DonationPage()))),
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

// ─── Card de evento ───────────────────────────────────────────────────────────
class _EventoCard extends StatelessWidget {
  final String docId;
  final String titulo;
  final String data;
  final String descricao;
  final String categoria;
  final bool isAdmin;
  final VoidCallback onDelete;

  const _EventoCard({
    required this.docId,
    required this.titulo,
    required this.data,
    required this.descricao,
    required this.categoria,
    required this.isAdmin,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => EventoDetalhePage(eventoId: docId)),
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
            Row(
              children: [
                const CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.green,
                  child: Icon(Icons.calendar_month,
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
                // Botão apagar — só admin
                if (isAdmin)
                  IconButton(
                    icon: const Icon(Icons.delete_outline,
                        color: Colors.red, size: 22),
                    tooltip: "Apagar evento",
                    onPressed: onDelete,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(descricao, style: AppTextStyles.forumText),
            const SizedBox(height: 8),
            const Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text("Ver detalhes",
                    style: TextStyle(
                        color: Colors.green,
                        fontSize: 12,
                        fontWeight: FontWeight.bold)),
                SizedBox(width: 4),
                Icon(Icons.arrow_forward_ios, color: Colors.green, size: 12),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
