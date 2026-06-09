import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projeto/core/services/admin_service.dart';

import 'adicionar_comentario.dart';
import '../../core/Style/custom_appbar.dart';
import '../../core/Style/text_styles.dart';
import '../home/home.dart';
import '../eventos/eventos.dart';
import '../donation/donation.dart';
import '../info/info.dart';
import '../profile/perfil.dart';
import '../noticias/noticias.dart';
import '../notificacoes/notificacoes.dart';

class ForumPage extends StatefulWidget {
  const ForumPage({super.key});

  @override
  State<ForumPage> createState() => _ForumPageState();
}

class _ForumPageState extends State<ForumPage> {
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    AdminService.isAdmin().then((v) {
      if (!mounted) return;
      setState(() => _isAdmin = v);
    });
  }

  // ─── APAGAR POST ─────────────────────────────
  Future<void> _apagarPost(String postId) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Apagar publicação?"),
        content: const Text("Esta ação é irreversível."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              "Apagar",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    await FirebaseFirestore.instance
        .collection('forumPosts')
        .doc(postId)
        .delete();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Publicação apagada.")),
    );
  }

  // ─── NOVO POST ─────────────────────────────
  void _openNewPost() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const AdicionarComentarioPage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Fórum",
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
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NoticiasPage()),
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
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PerfilPage()),
            ),
          ),
        ],
      ),

      body: Stack(
        children: [
          Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(12),
                child: Text(
                  "Comunidade EcoLoop",
                  style: AppTextStyles.welcomeTitle,
                  textAlign: TextAlign.center,
                ),
              ),

              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('forumPosts')
                      .orderBy('createdAt', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final docs = snapshot.data!.docs;

                    if (docs.isEmpty) {
                      return const Center(
                        child: Text("Ainda não há publicações."),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      itemCount: docs.length,
                      itemBuilder: (context, i) {
                        final data =
                            docs[i].data() as Map<String, dynamic>;

                        return _PostCard(
                          postId: docs[i].id,
                          data: data,
                          isAdmin: _isAdmin,
                          onDelete: () => _apagarPost(docs[i].id),
                        );
                      },
                    );
                  },
                ),
              ),

              const _BottomBar(),
            ],
          ),

          Positioned(
            bottom: 80,
            right: 20,
            child: FloatingActionButton(
              backgroundColor: Colors.green,
              onPressed: _openNewPost,
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _CommentSheet extends StatefulWidget {
  final String postId;

  const _CommentSheet({required this.postId});

  @override
  State<_CommentSheet> createState() => _CommentSheetState();
}

class _CommentSheetState extends State<_CommentSheet> {
  final TextEditingController ctrl = TextEditingController();

  @override
  void dispose() {
    ctrl.dispose();
    super.dispose();
  }

  void submit() {
    final text = ctrl.text.trim();
    if (text.isEmpty) return;

    FirebaseFirestore.instance
        .collection('forumPosts')
        .doc(widget.postId)
        .collection('comments')
        .add({
      'username': 'Eu',
      'text': text,
      'createdAt': FieldValue.serverTimestamp(),
    });

    ctrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        children: [
          const Text(
            "Comentários",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 10),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('forumPosts')
                  .doc(widget.postId)
                  .collection('comments')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snap) {
                if (!snap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snap.data!.docs;

                if (docs.isEmpty) {
                  return const Center(
                    child: Text("Sem comentários ainda."),
                  );
                }

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, i) {
                    final data = docs[i].data() as Map<String, dynamic>;

                    return ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Colors.green,
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                      title: Text(data['username'] ?? 'Utilizador'),
                      subtitle: Text(data['text'] ?? ''),
                    );
                  },
                );
              },
            ),
          ),

          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: ctrl,
                  decoration: const InputDecoration(
                    hintText: "Escreve um comentário...",
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send, color: Colors.green),
                onPressed: submit,
              )
            ],
          ),
        ],
      ),
    );
  }
}
class _PostCard extends StatelessWidget {
  final String postId;
  final Map<String, dynamic> data;
  final bool isAdmin;
  final VoidCallback onDelete;

  const _PostCard({
    required this.postId,
    required this.data,
    required this.isAdmin,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final text = data['text'] ?? '';
    final username = data['username'] ?? 'Utilizador';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      padding: const EdgeInsets.all(14),
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
                backgroundColor: Colors.green,
                child: Icon(Icons.person, color: Colors.white),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  username,
                  style: AppTextStyles.forumUsername,
                ),
              ),
              if (isAdmin)
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: onDelete,
                ),
            ],
          ),

          const SizedBox(height: 10),

          Text(text, style: AppTextStyles.forumText),

          const SizedBox(height: 10),

          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('forumPosts')
                .doc(postId)
                .collection('comments')
                .snapshots(),
            builder: (context, snap) {
              final count = snap.data?.docs.length ?? 0;

              return Text(
                "$count comentários",
                style: AppTextStyles.forumDate,
              );
            },
          ),

          const SizedBox(height: 8),

          TextButton.icon(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.white,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (_) => _CommentSheet(postId: postId),
              );
            },
            icon: const Icon(Icons.comment, color: Colors.green),
            label: const Text("Comentar"),
          ),
        ],
      ),
    );
  }
}
class _BottomBar extends StatelessWidget {
  const _BottomBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      color: Colors.green,
      child: Row(
        children: [
          _btn(context, Icons.map, const HomePage()),
          _div(),
          _btn(context, Icons.calendar_month, const EventosPage()),
          _div(),
          _btn(context, Icons.volunteer_activism, const DonationPage()),
          _div(),
          _btn(context, Icons.message, null),
          _div(),
          _btn(context, Icons.info, const InfoPage()),
        ],
      ),
    );
  }

  Widget _btn(BuildContext context, IconData icon, Widget? page) {
    return Expanded(
      child: InkWell(
        onTap: page == null
            ? null
            : () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => page),
                ),
        child: Center(
          child: Icon(icon, color: Colors.white, size: 28),
        ),
      ),
    );
  }

  Widget _div() => Container(width: 1, height: 30, color: Colors.white30);
}