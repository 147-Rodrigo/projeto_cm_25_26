import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'Style/custom_appbar.dart';
import 'Style/text_styles.dart';
import 'home.dart';
import 'eventos.dart';
import 'donation.dart';
import 'info.dart';
import 'perfil.dart';
import 'noticias.dart';
import 'notificacoes.dart';

// ─────────────────────────────────────────────
// MODELOS
// ─────────────────────────────────────────────

class ForumComment {
  final String username;
  final String text;
  final DateTime createdAt;

  ForumComment({
    required this.username,
    required this.text,
    required this.createdAt,
  });
}

class ForumPost {
  final String id;
  final String username;
  final String text;
  final DateTime createdAt;
  final Uint8List? imageBytes; // foto opcional
  final List<ForumComment> comments;

  ForumPost({
    required this.id,
    required this.username,
    required this.text,
    required this.createdAt,
    this.imageBytes,
    List<ForumComment>? comments,
  }) : comments = comments ?? [];
}

// ─────────────────────────────────────────────
// STORE GLOBAL (em memória, sem Firebase)
// ─────────────────────────────────────────────

class ForumStore {
  static final ForumStore _instance = ForumStore._internal();
  factory ForumStore() => _instance;
  ForumStore._internal();

  final List<ForumPost> posts = [
    ForumPost(
      id: '1',
      username: 'José Nunes',
      text:
          'Devemos todos reciclar. Pequenas ações fazem diferença no ambiente da nossa comunidade.',
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    ForumPost(
      id: '2',
      username: 'João Silva',
      text:
          'Os ecopontos estão distribuídos por toda a cidade e são essenciais para a separação correta dos resíduos.',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    ForumPost(
      id: '3',
      username: 'Maria Ferreira',
      text:
          'Comecei a separar o lixo cá em casa há uns meses e nota-se mesmo a diferença na quantidade de resíduos indiferenciados. Pequenas mudanças acabam por ter impacto.',
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
    ),
    ForumPost(
      id: '4',
      username: 'Ricardo Pêra',
      text:
          'Acho que ainda falta mais educação ambiental nas escolas e nas empresas. Muita gente quer reciclar mas nem sempre sabe onde colocar cada material.',
      createdAt: DateTime.now().subtract(const Duration(days: 90)),
    ),
    ForumPost(
      id: '5',
      username: 'Tiago Santos',
      text:
          'Tenho tentado comprar menos plástico descartável e usar garrafas reutilizáveis. Além de produzir menos lixo, também se acaba por poupar dinheiro.',
      createdAt: DateTime.now().subtract(const Duration(days: 365)),
    ),
  ];

  void addPost(ForumPost post) {
    posts.insert(0, post);
  }

  void addComment(String postId, ForumComment comment) {
    final post = posts.firstWhere((p) => p.id == postId);
    post.comments.add(comment);
  }
}

// ─────────────────────────────────────────────
// HELPERS
// ─────────────────────────────────────────────

String _timeAgo(DateTime dt) {
  final diff = DateTime.now().difference(dt);
  if (diff.inMinutes < 60) return '${diff.inMinutes} min';
  if (diff.inHours < 24) return '${diff.inHours} hora${diff.inHours > 1 ? 's' : ''}';
  if (diff.inDays < 7) return '${diff.inDays} dia${diff.inDays > 1 ? 's' : ''}';
  if (diff.inDays < 30) {
    final w = (diff.inDays / 7).floor();
    return '$w semana${w > 1 ? 's' : ''}';
  }
  if (diff.inDays < 365) {
    final m = (diff.inDays / 30).floor();
    return '$m mês${m > 1 ? 'es' : ''}';
  }
  final y = (diff.inDays / 365).floor();
  return '$y ano${y > 1 ? 's' : ''}';
}

// ─────────────────────────────────────────────
// PÁGINA PRINCIPAL DO FÓRUM
// ─────────────────────────────────────────────

class ForumPage extends StatefulWidget {
  const ForumPage({super.key});

  @override
  State<ForumPage> createState() => _ForumPageState();
}

class _ForumPageState extends State<ForumPage> {
  final ForumStore _store = ForumStore();

  void _openNewPost() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _NewPostSheet(
        onPost: (text, imageBytes) {
          setState(() {
            _store.addPost(ForumPost(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              username: 'Eu',
              text: text,
              createdAt: DateTime.now(),
              imageBytes: imageBytes,
            ));
          });
        },
      ),
    );
  }

  void _openPostDetail(ForumPost post) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _PostDetailPage(
          post: post,
          onComment: (comment) {
            setState(() {
              _store.addComment(post.id, comment);
            });
          },
        ),
      ),
    );
    setState(() {}); // refresh comment counts
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Fórum",
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

      body: Column(
        children: [
          // ── LISTA DE POSTS ──
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 16),
              itemCount: _store.posts.length + 1, // +1 para o header
              itemBuilder: (context, index) {
                if (index == 0) {
                  return const Padding(
                    padding: EdgeInsets.only(bottom: 16),
                    child: Text(
                      "Seja bem-vindo à comunidade!",
                      style: AppTextStyles.welcomeTitle,
                      textAlign: TextAlign.center,
                    ),
                  );
                }
                final post = _store.posts[index - 1];
                return _PostCard(
                  post: post,
                  onTap: () => _openPostDetail(post),
                );
              },
            ),
          ),

          // ── BARRA INFERIOR ──
          Container(
            width: double.infinity,
            color: Colors.green,
            child: SizedBox(
              height: 60,
              child: Row(
                children: [
                  _navButton(Icons.map, () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const HomePage()))),
                  _navDivider(),
                  _navButton(Icons.calendar_month, () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const EventosPage()))),
                  _navDivider(),
                  _navButton(Icons.volunteer_activism, () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const DonationPage()))),
                  _navDivider(),
                  _navButton(Icons.message, () {}),
                  _navDivider(),
                  _navButton(Icons.info, () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const InfoPage()))),
                ],
              ),
            ),
          ),
        ],
      ),

      // ── FAB: NOVO POST ──
      floatingActionButton: FloatingActionButton(
        onPressed: _openNewPost,
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _navButton(IconData icon, VoidCallback onTap) => Expanded(
        child: InkWell(
          onTap: onTap,
          child: Center(child: Icon(icon, color: Colors.white, size: 28)),
        ),
      );

  Widget _navDivider() => Container(width: 1, height: 30, color: Colors.white30);
}

// ─────────────────────────────────────────────
// CARD DE POST
// ─────────────────────────────────────────────

class _PostCard extends StatelessWidget {
  final ForumPost post;
  final VoidCallback onTap;

  const _PostCard({required this.post, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color.fromRGBO(171, 255, 156, 1),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── HEADER ──
            Row(
              children: [
                _avatar(post.imageBytes),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(post.username, style: AppTextStyles.forumUsername),
                    const SizedBox(height: 2),
                    Text(_timeAgo(post.createdAt), style: AppTextStyles.forumDate),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),

            // ── TEXTO ──
            Text(post.text, style: AppTextStyles.forumText),

            // ── IMAGEM DO POST (se houver) ──
            if (post.imageBytes != null) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.memory(
                  post.imageBytes!,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  height: 180,
                ),
              ),
            ],

            const SizedBox(height: 10),

            // ── RODAPÉ ──
            Row(
              children: [
                const Icon(Icons.comment_outlined, size: 16, color: Colors.black54),
                const SizedBox(width: 4),
                Text(
                  '${post.comments.length} comentário${post.comments.length != 1 ? 's' : ''}',
                  style: AppTextStyles.forumDate,
                ),
                const Spacer(),
                const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.black38),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _avatar(Uint8List? bytes) {
    if (bytes != null) {
      return CircleAvatar(
        radius: 25,
        backgroundImage: MemoryImage(bytes),
      );
    }
    return const CircleAvatar(
      radius: 25,
      backgroundColor: Colors.green,
      child: Icon(Icons.person, color: Colors.white, size: 28),
    );
  }
}

// ─────────────────────────────────────────────
// DETALHE DO POST + COMENTÁRIOS
// ─────────────────────────────────────────────

class _PostDetailPage extends StatefulWidget {
  final ForumPost post;
  final void Function(ForumComment) onComment;

  const _PostDetailPage({required this.post, required this.onComment});

  @override
  State<_PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<_PostDetailPage> {
  final TextEditingController _commentCtrl = TextEditingController();

  void _submitComment() {
    final text = _commentCtrl.text.trim();
    if (text.isEmpty) return;
    final comment = ForumComment(
      username: 'Eu',
      text: text,
      createdAt: DateTime.now(),
    );
    widget.onComment(comment);
    setState(() {
      _commentCtrl.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;

    return Scaffold(
      appBar: CustomAppBar(title: "Publicação"),
      body: Column(
        children: [
          // ── CONTEÚDO ──
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Post principal
                Container(
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
                            child: Icon(Icons.person, color: Colors.white, size: 28),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(post.username, style: AppTextStyles.forumUsername),
                              const SizedBox(height: 2),
                              Text(_timeAgo(post.createdAt), style: AppTextStyles.forumDate),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(post.text, style: AppTextStyles.forumText),
                      if (post.imageBytes != null) ...[
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.memory(
                            post.imageBytes!,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Separador comentários
                Row(
                  children: [
                    const Icon(Icons.comment, color: Colors.green, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      '${post.comments.length} comentário${post.comments.length != 1 ? 's' : ''}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Lista de comentários
                ...post.comments.map((c) => _CommentBubble(comment: c)),
              ],
            ),
          ),

          // ── CAIXA DE COMENTÁRIO ──
          Container(
            padding: EdgeInsets.only(
              left: 12,
              right: 12,
              top: 8,
              bottom: MediaQuery.of(context).viewInsets.bottom + 12,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.green,
                  child: Icon(Icons.person, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _commentCtrl,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _submitComment(),
                    decoration: InputDecoration(
                      hintText: 'Escreve um comentário…',
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _submitComment,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.send, color: Colors.white, size: 18),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// BUBBLE DE COMENTÁRIO
// ─────────────────────────────────────────────

class _CommentBubble extends StatelessWidget {
  final ForumComment comment;

  const _CommentBubble({required this.comment});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            radius: 18,
            backgroundColor: Colors.green,
            child: Icon(Icons.person, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(comment.username, style: AppTextStyles.forumUsername.copyWith(fontSize: 13)),
                    const SizedBox(width: 8),
                    Text(_timeAgo(comment.createdAt), style: AppTextStyles.forumDate),
                  ],
                ),
                const SizedBox(height: 4),
                Text(comment.text, style: AppTextStyles.forumText),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SHEET: NOVA PUBLICAÇÃO
// ─────────────────────────────────────────────

class _NewPostSheet extends StatefulWidget {
  final void Function(String text, Uint8List? imageBytes) onPost;

  const _NewPostSheet({required this.onPost});

  @override
  State<_NewPostSheet> createState() => _NewPostSheetState();
}

class _NewPostSheetState extends State<_NewPostSheet> {
  final TextEditingController _textCtrl = TextEditingController();
  Uint8List? _imageBytes;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1080,
      imageQuality: 80,
    );
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    setState(() => _imageBytes = bytes);
  }

  void _submit() {
    final text = _textCtrl.text.trim();
    if (text.isEmpty) return;
    widget.onPost(text, _imageBytes);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(
        left: 16, right: 16, top: 20, bottom: bottomPadding + 20,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40, height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          const Text(
            'Nova publicação',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),

          const SizedBox(height: 16),

          // Texto
          TextField(
            controller: _textCtrl,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Partilha algo com a comunidade…',
              hintStyle: TextStyle(color: Colors.grey.shade400),
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(14),
            ),
          ),

          const SizedBox(height: 12),

          // Preview imagem
          if (_imageBytes != null) ...[
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.memory(
                    _imageBytes!,
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 6, right: 6,
                  child: GestureDetector(
                    onTap: () => setState(() => _imageBytes = null),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, color: Colors.white, size: 16),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],

          // Botões
          Row(
            children: [
              // Adicionar foto
              OutlinedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.photo_library_outlined, color: Colors.green),
                label: const Text('Foto', style: TextStyle(color: Colors.green)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.green),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),

              const Spacer(),

              // Publicar
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text(
                  'Publicar',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}