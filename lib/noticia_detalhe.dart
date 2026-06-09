import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'Style/custom_appbar.dart';
import 'Style/text_styles.dart';

class NoticiaDetalhePage extends StatelessWidget {
  final String docId;
  final Map<String, dynamic> data;

  const NoticiaDetalhePage({
    super.key,
    required this.docId,
    required this.data,
  });

  String _formatDate(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}/'
      '${dt.month.toString().padLeft(2, '0')}/'
      '${dt.year}';

  @override
  Widget build(BuildContext context) {
    final titulo = data['titulo'] as String? ?? '';
    final descricao = data['descricao'] as String? ?? '';
    final artigo = data['resumo'] as String? ?? '';
    final fonte = data['fonte'] as String? ?? '';
    final categoria = data['categoria'] as String? ?? 'Geral';
    final imageUrl = data['imagemUrl'] as String?;
    final ts = data['dataPublicacao'] as Timestamp?;
    final dataFormatada = ts != null ? _formatDate(ts.toDate()) : '';

    return Scaffold(
      appBar: CustomAppBar(
        title: "Notícia",
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ─── Imagem de capa ───────────────────────────────────────────
            if (imageUrl != null && imageUrl.isNotEmpty)
              Image.network(
                imageUrl,
                height: 220,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              )
            else
              Container(
                height: 140,
                width: double.infinity,
                color: const Color.fromRGBO(171, 255, 156, 1),
                child: const Icon(
                  Icons.newspaper,
                  size: 72,
                  color: Colors.green,
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // ─── Categoria badge ──────────────────────────────────
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
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // ─── Título ───────────────────────────────────────────
                  Text(
                    titulo,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ─── Fonte + Data ─────────────────────────────────────
                  Row(
                    children: [
                      if (fonte.isNotEmpty) ...[
                        const Icon(Icons.source,
                            size: 15, color: Colors.green),
                        const SizedBox(width: 4),
                        Text(fonte, style: AppTextStyles.forumDate),
                        const SizedBox(width: 16),
                      ],
                      const Icon(Icons.calendar_today,
                          size: 15, color: Colors.green),
                      const SizedBox(width: 4),
                      Text(dataFormatada, style: AppTextStyles.forumDate),
                    ],
                  ),

                  const SizedBox(height: 20),

                  const Divider(color: Colors.green),

                  const SizedBox(height: 16),

                  // ─── Descrição (introdução) ───────────────────────────
                  if (artigo.isNotEmpty) ...[
                    Text(
                      artigo,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        height: 1.6,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: Colors.green),
                    const SizedBox(height: 16),
                  ],

                  // ─── Artigo completo ──────────────────────────────────
                  Text(
                    descricao,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.7,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
