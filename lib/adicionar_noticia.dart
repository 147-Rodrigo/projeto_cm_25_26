import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

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

  String _categoriaSelecionada = 'Geral';
  bool _loading = false;

  XFile? _imagemSelecionada;

  static const _categorias = [
    'Geral',
    'Reciclagem',
    'Clima',
    'Energia',
    'Biodiversidade',
    'Comunidade',
    'Outro',
  ];

  // ─── Selecionar imagem ──────────────────────────────────────────────────────
  Future<void> _pickImagem() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked == null) return;
    setState(() => _imagemSelecionada = picked);
  }

  // ─── Faz upload para Firebase Storage e retorna a URL ──────────────────────
  Future<String?> _uploadImagem() async {
    if (_imagemSelecionada == null) return null;

    final ref = FirebaseStorage.instance
        .ref()
        .child('noticias')
        .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

    UploadTask task;

    if (kIsWeb) {
      final bytes = await _imagemSelecionada!.readAsBytes();
      task = ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
    } else {
      task = ref.putFile(File(_imagemSelecionada!.path));
    }

    final snap = await task;
    return await snap.ref.getDownloadURL();
  }

  // ─── Submeter notícia ───────────────────────────────────────────────────────
  Future<void> _submeter() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;

      // Faz upload da imagem (se existir) e obtém URL
      final imagemUrl = await _uploadImagem();

      await FirebaseFirestore.instance.collection('noticias').add({
        'titulo': _tituloController.text.trim(),
        'descricao': _descricaoController.text.trim(),
        'resumo': _resumoController.text.trim(),
        'fonte': _fonteController.text.trim().isNotEmpty
            ? _fonteController.text.trim()
            : (user?.email ?? 'EcoLoop'),
        'imagemUrl': imagemUrl ?? '',
        'categoria': _categoriaSelecionada,
        'dataPublicacao': FieldValue.serverTimestamp(),
        'criadoPor': user?.uid ?? '',
      });

      // Notificação global na coleção 'notificacoes'
      await FirebaseFirestore.instance.collection('notificacoes').add({
        'titulo': '📰 Nova Notícia: ${_tituloController.text.trim()}',
        'corpo':
            '$_categoriaSelecionada · ${_fonteController.text.trim().isNotEmpty ? _fonteController.text.trim() : 'EcoLoop'}',
        'dataHora': FieldValue.serverTimestamp(),
        'lida': false,
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
    }

    setState(() => _loading = false);
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descricaoController.dispose();
    _resumoController.dispose();
    _fonteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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

                // ─── Título ────────────────────────────────────────────────
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

                // ─── Descrição ────────────────────────────────────────────
                TextFormField(
                  controller: _descricaoController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: "Descrição * (aparece na lista)",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.short_text),
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? "Insira a descrição" : null,
                ),
                const SizedBox(height: 14),

                // ─── Artigo ───────────────────────────────────────────────
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

                // ─── Fonte ────────────────────────────────────────────────
                TextFormField(
                  controller: _fonteController,
                  decoration: const InputDecoration(
                    labelText: "Fonte (opcional)",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.source),
                  ),
                ),
                const SizedBox(height: 14),

                // ─── Categoria ────────────────────────────────────────────
                DropdownButtonFormField<String>(
                  value: _categoriaSelecionada,
                  decoration: const InputDecoration(
                    labelText: "Categoria",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.category),
                  ),
                  items: _categorias
                      .map((c) =>
                          DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) =>
                      setState(() => _categoriaSelecionada = v!),
                ),
                const SizedBox(height: 14),

                // ─── Imagem ───────────────────────────────────────────────
                GestureDetector(
                  onTap: _pickImagem,
                  child: Container(
                    width: double.infinity,
                    height: 160,
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.green, width: 1.5),
                    ),
                    child: _imagemSelecionada == null
                        ? const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_photo_alternate,
                                  size: 48, color: Colors.green),
                              SizedBox(height: 8),
                              Text(
                                "Toque para adicionar imagem\n(opcional)",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.green),
                              ),
                            ],
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: kIsWeb
                                ? Image.network(
                                    _imagemSelecionada!.path,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: 160,
                                  )
                                : Image.file(
                                    File(_imagemSelecionada!.path),
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: 160,
                                  ),
                          ),
                  ),
                ),

                if (_imagemSelecionada != null)
                  TextButton.icon(
                    onPressed: () =>
                        setState(() => _imagemSelecionada = null),
                    icon: const Icon(Icons.delete, color: Colors.red),
                    label: const Text("Remover imagem",
                        style: TextStyle(color: Colors.red)),
                  ),

                const SizedBox(height: 28),

                // ─── Botão Submeter ───────────────────────────────────────
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
                        : const Text("Publicar Notícia",
                            style: TextStyle(fontSize: 16)),
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
