import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'Style/custom_appbar.dart';
import 'Style/text_styles.dart';

import 'perfil.dart';

class EventoDetalhePage extends StatelessWidget {
  final String eventoId;

  const EventoDetalhePage({super.key, required this.eventoId});

  String _formatDate(dynamic value) {
    if (value == null) return '';
    DateTime dt;
    if (value is Timestamp) {
      dt = value.toDate();
    } else {
      return value.toString();
    }
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/'
        '${dt.year}  '
        '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Detalhe do Evento",
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PerfilPage()),
            ),
          ),
        ],
      ),

      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('eventos')
            .doc(eventoId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("Evento não encontrado."));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final titulo = data['titulo'] as String? ?? '';
          final descricao = data['descricao'] as String? ?? '';
          final local = data['local'] as String? ?? '';
          final dataEvento = _formatDate(data['data']);
          final organizador = data['organizador'] as String? ?? '';
          final categoria = data['categoria'] as String? ?? '';
          final imageUrl = data['imagemUrl'] as String?;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Imagem de capa (se existir)
                if (imageUrl != null && imageUrl.isNotEmpty)
                  Image.network(
                    imageUrl,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const SizedBox.shrink(),
                  )
                else
                  Container(
                    height: 160,
                    width: double.infinity,
                    color: Colors.green.shade100,
                    child: const Icon(Icons.event,
                        size: 80, color: Colors.green),
                  ),

                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Categoria badge
                      if (categoria.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            categoria,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold),
                          ),
                        ),

                      const SizedBox(height: 12),

                      Text(titulo,
                          style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold)),

                      const SizedBox(height: 16),

                      _infoRow(Icons.calendar_today, dataEvento),
                      const SizedBox(height: 8),
                      _infoRow(Icons.location_on, local),
                      const SizedBox(height: 8),
                      if (organizador.isNotEmpty)
                        _infoRow(Icons.person, organizador),

                      const SizedBox(height: 20),

                      const Divider(color: Colors.green),

                      const SizedBox(height: 12),

                      const Text(
                        "Descrição",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green),
                      ),
                      const SizedBox(height: 8),
                      Text(descricao, style: AppTextStyles.forumText),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.green, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text, style: AppTextStyles.forumText),
        ),
      ],
    );
  }
}
