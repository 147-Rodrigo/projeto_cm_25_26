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
import 'notificacoes.dart';
import 'services/admin_service.dart';

class NoticiasPage extends StatefulWidget {
  const NoticiasPage({super.key});

  @override
  State<NoticiasPage> createState() => _NoticiasPageState();
}

class _NoticiasPageState extends State<NoticiasPage> {
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    AdminService.isAdmin().then((v) => setState(() => _isAdmin = v));
  }

  // ─── Apagar notícia (admin) ─────────────────────────────────────────────────
  Future<void> _apagarNoticia(String docId) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Apagar notícia?"),
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
        .collection('noticias')
        .doc(docId)
        .delete();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Notícia apagada.")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Notícias",
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
            icon: const Icon(Icons.notifications),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NotificacoesPage()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const PerfilPage())),
          ),
        ],
      ),

      // FAB — só visível para admin
      floatingActionButton: _isAdmin
          ? FloatingActionButton(
              backgroundColor: Colors.green,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const AdicionarNoticiaPage()),
              ),
              tooltip: "Adicionar Notícia",
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,

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
                      "Sem notícias de momento.",
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
                    final data =
                        docs[i].data() as Map<String, dynamic>;
                    return _NoticiaCard(
                      docId: docs[i].id,
                      data: data,
                      isAdmin: _isAdmin,
                      onDelete: () => _apagarNoticia(docs[i].id),
                    );
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
  final bool isAdmin;
  final VoidCallback onDelete;

  const _NoticiaCard({
    required this.docId,
    required this.data,
    required this.isAdmin,
    required this.onDelete,
  });

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
          // Imagem
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
                // Categoria + botões admin
                Row(
                  children: [
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
                    const Spacer(),
                    // Ações admin
                    if (isAdmin) ...[
                      IconButton(
                        icon: const Icon(Icons.edit,
                            color: Colors.green, size: 20),
                        tooltip: "Editar",
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AdicionarNoticiaPage(
                              docId: docId,
                              dadosExistentes: data,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.delete_outline,
                            color: Colors.red, size: 20),
                        tooltip: "Apagar",
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: onDelete,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),

                Text(titulo, style: AppTextStyles.forumUsername),
                const SizedBox(height: 6),

                Text(
                  descricao,
                  style: AppTextStyles.forumText,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (fonte.isNotEmpty)
                      Text('📰 $fonte', style: AppTextStyles.forumDate),
                    Text(dataFormatada, style: AppTextStyles.forumDate),
                  ],
                ),

                const SizedBox(height: 10),

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
                    label: const Text("Ler mais",
                        style: TextStyle(fontWeight: FontWeight.bold)),
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