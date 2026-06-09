import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'Style/custom_appbar.dart';
import 'Style/text_styles.dart';

import 'home.dart';
import 'eventos.dart';
import 'donation.dart';
import 'forum.dart';
import 'info.dart';
import 'perfil.dart';
import 'adicionar_noticia.dart';
import 'noticia_detalhe.dart';

class NoticiasPage extends StatelessWidget {
  const NoticiasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Notícias",
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () {},
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

      // ─── FAB para adicionar notícia ─────────────────────────────────────────
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AdicionarNoticiaPage()),
        ),
        tooltip: "Adicionar Notícia",
        child: const Icon(Icons.add, color: Colors.white),
      ),

      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('noticias')
                  .orderBy('dataPublicacao', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      "Sem notícias de momento.\nCarregue em + para adicionar.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
                }

                final docs = snapshot.data!.docs;

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(
                      vertical: 16, horizontal: 12),
                  itemCount: docs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, i) {
                    final data = docs[i].data() as Map<String, dynamic>;
                    return _NoticiaCard(docId: docs[i].id, data: data);
                  },
                );
              },
            ),
          ),
          _BottomBar(),
        ],
      ),
    );
  }
}

// ─── Card de notícia ──────────────────────────────────────────────────────────
class _NoticiaCard extends StatelessWidget {
  final String docId;
  final Map<String, dynamic> data;
  const _NoticiaCard({required this.docId, required this.data});

  @override
  Widget build(BuildContext context) {
    final titulo = data['titulo'] as String? ?? '';
    final descricao = data['descricao'] as String? ?? '';
    final fonte = data['fonte'] as String? ?? '';
    final ts = data['dataPublicacao'] as Timestamp?;
    final dataFormatada = ts != null ? _formatDate(ts.toDate()) : '';
    final imageUrl = data['imagemUrl'] as String?;
    final categoria = data['categoria'] as String? ?? 'Geral';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(171, 255, 156, 1),
        borderRadius: BorderRadius.circular(15),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagem (se existir)
          if (imageUrl != null && imageUrl.isNotEmpty)
            Image.network(
              imageUrl,
              height: 160,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),

          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Categoria badge
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    categoria,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),

                // Título
                Text(titulo, style: AppTextStyles.forumUsername),
                const SizedBox(height: 6),

                // Descrição (máx 3 linhas no card)
                Text(
                  descricao,
                  style: AppTextStyles.forumText,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),

                // Fonte + Data
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (fonte.isNotEmpty)
                      Text('📰 $fonte', style: AppTextStyles.forumDate),
                    Text(dataFormatada, style: AppTextStyles.forumDate),
                  ],
                ),

                const SizedBox(height: 10),

                // Botão Ler mais
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => NoticiaDetalhePage(
                          docId: docId,
                          data: data,
                        ),
                      ),
                    ),
                    icon: const Icon(Icons.article_outlined, size: 16),
                    label: const Text(
                      "Ler mais",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}/'
      '${dt.month.toString().padLeft(2, '0')}/'
      '${dt.year}';
}

// ─── Barra inferior ───────────────────────────────────────────────────────────
class _BottomBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.green,
      child: SizedBox(
        height: 60,
        child: Row(
          children: [
            _btn(Icons.map, () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const HomePage()))),
            _div(),
            _btn(Icons.calendar_month, () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const EventosPage()))),
            _div(),
            _btn(Icons.volunteer_activism, () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const DonationPage()))),
            _div(),
            _btn(Icons.message, () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const ForumPage()))),
            _div(),
            _btn(Icons.info, () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const InfoPage()))),
          ],
        ),
      ),
    );
  }

  Widget _btn(IconData icon, VoidCallback onTap) => Expanded(
        child: InkWell(
          onTap: onTap,
          child: Center(
              child: Icon(icon, color: Colors.white, size: 28)),
        ),
      );

  Widget _div() =>
      Container(width: 1, height: 30, color: Colors.white30);
}
