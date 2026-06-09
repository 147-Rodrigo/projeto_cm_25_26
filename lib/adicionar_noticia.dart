import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'Style/custom_appbar.dart';

class AdicionarNoticiaPage extends StatefulWidget {
  /// Se fornecido, entra em modo de edição.
  final String? docId;
  final Map<String, dynamic>? dadosExistentes;

  const AdicionarNoticiaPage({
    super.key,
    this.docId,
    this.dadosExistentes,
  });

  @override
  State<AdicionarNoticiaPage> createState() => _AdicionarNoticiaPageState();
}

class _AdicionarNoticiaPageState extends State<AdicionarNoticiaPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _tituloController;
  late final TextEditingController _descricaoController;
  late final TextEditingController _resumoController;
  late final TextEditingController _fonteController;
  late final TextEditingController _imagemUrlController;

  late String _categoriaSelecionada;
  bool _loading = false;
  bool _previewErro = false;

  bool get _isEdicao => widget.docId != null;

  static const _categorias = [
    'Geral',
    'Reciclagem',
    'Clima',
    'Energia',
    'Biodiversidade',
    'Comunidade',
    'Outro',
  ];

  @override
  void initState() {
    super.initState();
    final d = widget.dadosExistentes ?? {};
    _tituloController =
        TextEditingController(text: d['titulo'] as String? ?? '');
    _descricaoController =
        TextEditingController(text: d['descricao'] as String? ?? '');
    _resumoController =
        TextEditingController(text: d['resumo'] as String? ?? '');
    _fonteController =
        TextEditingController(text: d['fonte'] as String? ?? '');
    _imagemUrlController =
        TextEditingController(text: d['imagemUrl'] as String? ?? '');
    _categoriaSelecionada = (d['categoria'] as String?) ?? 'Geral';
  }

  // ─── Submeter / Atualizar ───────────────────────────────────────────────────
  Future<void> _submeter() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;

      final payload = {
        'titulo': _tituloController.text.trim(),
        'descricao': _descricaoController.text.trim(),
        'resumo': _resumoController.text.trim(),
        'fonte': _fonteController.text.trim().isNotEmpty
            ? _fonteController.text.trim()
            : (user?.email ?? 'EcoLoop'),
        'imagemUrl': _imagemUrlController.text.trim(),
        'categoria': _categoriaSelecionada,
      };

      if (_isEdicao) {
        // Atualiza documento existente
        await FirebaseFirestore.instance
            .collection('noticias')
            .doc(widget.docId)
            .update({
          ...payload,
          'editadoEm': FieldValue.serverTimestamp(),
          'editadoPor': user?.uid ?? '',
        });
      } else {
        // Cria novo documento e guarda a referência para a notificação
        final noticiaRef = await FirebaseFirestore.instance
            .collection('noticias')
            .add({
          ...payload,
          'dataPublicacao': FieldValue.serverTimestamp(),
          'criadoPor': user?.uid ?? '',
        });

        // Criar notificação apenas ao publicar (não na edição)
        await FirebaseFirestore.instance.collection('notifications').add({
          'titulo': 'Nova notícia publicada',
          'mensagem': _tituloController.text.trim(),
          'data': FieldValue.serverTimestamp(),
          'noticiaId': noticiaRef.id,
          'tipo': 'noticia',
        });
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEdicao
              ? "Notícia atualizada com sucesso!"
              : "Notícia adicionada com sucesso!"),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro: $e")),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descricaoController.dispose();
    _resumoController.dispose();
    _fonteController.dispose();
    _imagemUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final urlImagem = _imagemUrlController.text.trim();

    return Scaffold(
      appBar: CustomAppBar(
        title: _isEdicao ? "Editar Notícia" : "Adicionar Notícia",
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 16),

                // Título
                TextFormField(
                  controller: _tituloController,
                  decoration: const InputDecoration(
                    labelText: "Título da Notícia *",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.newspaper),
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? "Insira o título" : null,
                ),

                const SizedBox(height: 14),

                // Descrição
                TextFormField(
                  controller: _descricaoController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: "Descrição *",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.short_text),
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? "Insira a descrição" : null,
                ),

                const SizedBox(height: 14),

                // Artigo
                TextFormField(
                  controller: _resumoController,
                  maxLines: 8,
                  decoration: const InputDecoration(
                    labelText: "Artigo * (texto completo ao clicar em Ler mais)",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.description),
                    alignLabelWithHint: true,
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? "Insira o artigo" : null,
                ),

                const SizedBox(height: 14),

                // Fonte
                TextFormField(
                  controller: _fonteController,
                  decoration: const InputDecoration(
                    labelText: "Fonte (opcional)",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.source),
                  ),
                ),

                const SizedBox(height: 14),

                // Categoria
                DropdownButtonFormField<String>(
                  value: _categoriaSelecionada,
                  decoration: const InputDecoration(
                    labelText: "Categoria",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.category),
                  ),
                  items: _categorias
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) =>
                      setState(() => _categoriaSelecionada = v!),
                ),

                const SizedBox(height: 14),

                // URL da Imagem
                TextFormField(
                  controller: _imagemUrlController,
                  decoration: const InputDecoration(
                    labelText: "URL da Imagem (opcional)",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.image),
                  ),
                  onChanged: (_) => setState(() => _previewErro = false),
                ),

                const SizedBox(height: 10),

                // Preview da imagem
                if (urlImagem.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: _previewErro
                        ? Container(
                            height: 50,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              border: Border.all(color: Colors.red),
                            ),
                            child: const Center(
                              child: Text(
                                "URL inválido — imagem não carregada",
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          )
                        : Image.network(
                            urlImagem,
                            height: 160,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) {
                              WidgetsBinding.instance.addPostFrameCallback(
                                (_) => setState(() => _previewErro = true),
                              );
                              return const SizedBox.shrink();
                            },
                          ),
                  ),

                const SizedBox(height: 28),

                // Botão submeter
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: _loading ? null : _submeter,
                    child: _loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            _isEdicao ? "Guardar Alterações" : "Publicar Notícia",
                            style: const TextStyle(fontSize: 16),
                          ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}