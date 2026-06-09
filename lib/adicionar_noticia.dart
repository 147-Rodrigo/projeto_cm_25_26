import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'Style/custom_appbar.dart';

class AdicionarNoticiaPage extends StatefulWidget {
  const AdicionarNoticiaPage({super.key});

  @override
  State<AdicionarNoticiaPage> createState() => _AdicionarNoticiaPageState();
}

class _AdicionarNoticiaPageState extends State<AdicionarNoticiaPage> {
  final _formKey = GlobalKey<FormState>();

  final _tituloController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _resumoController = TextEditingController();
  final _fonteController = TextEditingController();
  final _imagemUrlController = TextEditingController();

  String _categoriaSelecionada = 'Geral';
  bool _loading = false;
  bool _previewErro = false;

  static const _categorias = [
    'Geral',
    'Reciclagem',
    'Clima',
    'Energia',
    'Biodiversidade',
    'Comunidade',
    'Outro',
  ];

  Future<void> _submeter() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;

      // Criar notícia
      final noticiaRef = await FirebaseFirestore.instance
          .collection('noticias')
          .add({
        'titulo': _tituloController.text.trim(),
        'descricao': _descricaoController.text.trim(),
        'resumo': _resumoController.text.trim(),
        'fonte': _fonteController.text.trim().isNotEmpty
            ? _fonteController.text.trim()
            : (user?.email ?? 'EcoLoop'),
        'imagemUrl': _imagemUrlController.text.trim(),
        'categoria': _categoriaSelecionada,
        'dataPublicacao': FieldValue.serverTimestamp(),
        'criadoPor': user?.uid ?? '',
      });

      // Criar notificação
      await FirebaseFirestore.instance.collection('notifications').add({
        'titulo': 'Nova notícia publicada',
        'mensagem': _tituloController.text.trim(),
        'data': FieldValue.serverTimestamp(),
        'noticiaId': noticiaRef.id,
        'tipo': 'noticia',
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Notícia adicionada com sucesso!")),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro: $e")),
      );
    } finally {
      setState(() => _loading = false);
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
        title: "Adicionar Notícia",
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

                TextFormField(
                  controller: _resumoController,
                  maxLines: 8,
                  decoration: const InputDecoration(
                    labelText: "Artigo *",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.description),
                    alignLabelWithHint: true,
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? "Insira o artigo" : null,
                ),

                const SizedBox(height: 14),

                TextFormField(
                  controller: _fonteController,
                  decoration: const InputDecoration(
                    labelText: "Fonte (opcional)",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.source),
                  ),
                ),

                const SizedBox(height: 14),

                DropdownButtonFormField<String>(
                  value: _categoriaSelecionada,
                  decoration: const InputDecoration(
                    labelText: "Categoria",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.category),
                  ),
                  items: _categorias
                      .map((c) => DropdownMenuItem(
                            value: c,
                            child: Text(c),
                          ))
                      .toList(),
                  onChanged: (v) =>
                      setState(() => _categoriaSelecionada = v!),
                ),

                const SizedBox(height: 14),

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
                        : const Text(
                            "Publicar Notícia",
                            style: TextStyle(fontSize: 16),
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