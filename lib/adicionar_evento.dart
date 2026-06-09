import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'Style/custom_appbar.dart';

class AdicionarEventoPage extends StatefulWidget {
  const AdicionarEventoPage({super.key});

  @override
  State<AdicionarEventoPage> createState() => _AdicionarEventoPageState();
}

class _AdicionarEventoPageState extends State<AdicionarEventoPage> {
  final _formKey = GlobalKey<FormState>();

  final _tituloController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _localController = TextEditingController();
  final _organizadorController = TextEditingController();
  final _imagemController = TextEditingController();

  DateTime? _dataSelecionada;
  TimeOfDay? _horaSelecionada;
  String _categoriaSelecionada = 'Reciclagem';
  bool _loading = false;

  static const _categorias = [
    'Reciclagem',
    'Limpeza',
    'Educação',
    'Comunidade',
    'Outro',
  ];

  // ─── Selecionar data ────────────────────────────────────────────────────────
  Future<void> _pickData() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null) setState(() => _dataSelecionada = picked);
  }

  // ─── Selecionar hora ────────────────────────────────────────────────────────
  Future<void> _pickHora() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) setState(() => _horaSelecionada = picked);
  }

  // ─── Submeter evento ────────────────────────────────────────────────────────
  Future<void> _submeter() async {
    if (!_formKey.currentState!.validate()) return;
    if (_dataSelecionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Selecione a data do evento")),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;

      // Combina data + hora
      final hora = _horaSelecionada ?? const TimeOfDay(hour: 9, minute: 0);
      final dataCompleta = DateTime(
        _dataSelecionada!.year,
        _dataSelecionada!.month,
        _dataSelecionada!.day,
        hora.hour,
        hora.minute,
      );

      // Guarda no Firestore
      await FirebaseFirestore.instance.collection('eventos').add({
        'titulo': _tituloController.text.trim(),
        'descricao': _descricaoController.text.trim(),
        'local': _localController.text.trim(),
        'organizador': _organizadorController.text.trim().isNotEmpty
            ? _organizadorController.text.trim()
            : (user?.email ?? 'Anónimo'),
        'imagemUrl': _imagemController.text.trim(),
        'categoria': _categoriaSelecionada,
        'data': Timestamp.fromDate(dataCompleta),
        'criadoPor': user?.uid ?? '',
        'criadoEm': FieldValue.serverTimestamp(),
      });

      // Adiciona notificação global na coleção 'notificacoes'
      await FirebaseFirestore.instance.collection('notificacoes').add({
        'titulo': '📅 Novo Evento: ${_tituloController.text.trim()}',
        'corpo': '$_categoriaSelecionada · ${_localController.text.trim()}',
        'dataHora': FieldValue.serverTimestamp(),
        'lida': false,
        'tipo': 'evento',
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Evento adicionado com sucesso!")),
      );

      Navigator.pop(context); // Volta à página de Eventos
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
    _localController.dispose();
    _organizadorController.dispose();
    _imagemController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Adicionar Evento",
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
                    labelText: "Título do Evento *",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.event),
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? "Insira o título" : null,
                ),
                const SizedBox(height: 14),

                // ─── Descrição ────────────────────────────────────────────
                TextFormField(
                  controller: _descricaoController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: "Descrição *",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.description),
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? "Insira a descrição" : null,
                ),
                const SizedBox(height: 14),

                // ─── Local ────────────────────────────────────────────────
                TextFormField(
                  controller: _localController,
                  decoration: const InputDecoration(
                    labelText: "Local *",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.location_on),
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? "Insira o local" : null,
                ),
                const SizedBox(height: 14),

                // ─── Organizador ──────────────────────────────────────────
                TextFormField(
                  controller: _organizadorController,
                  decoration: const InputDecoration(
                    labelText: "Organizador (opcional)",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 14),

                // ─── URL Imagem ───────────────────────────────────────────
                TextFormField(
                  controller: _imagemController,
                  decoration: const InputDecoration(
                    labelText: "URL da Imagem (opcional)",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.image),
                  ),
                ),
                const SizedBox(height: 14),

                // ─── Categoria ────────────────────────────────────────────
                DropdownButtonFormField<String>(
                  initialValue: _categoriaSelecionada,
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

                // ─── Data ─────────────────────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _pickData,
                        icon: const Icon(Icons.calendar_today,
                            color: Colors.green),
                        label: Text(
                          _dataSelecionada == null
                              ? "Selecionar Data *"
                              : '${_dataSelecionada!.day.toString().padLeft(2, '0')}/'
                                  '${_dataSelecionada!.month.toString().padLeft(2, '0')}/'
                                  '${_dataSelecionada!.year}',
                          style: TextStyle(
                            color: _dataSelecionada == null
                                ? Colors.grey
                                : Colors.black,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _pickHora,
                        icon: const Icon(Icons.access_time,
                            color: Colors.green),
                        label: Text(
                          _horaSelecionada == null
                              ? "Hora (opcional)"
                              : _horaSelecionada!.format(context),
                          style: TextStyle(
                            color: _horaSelecionada == null
                                ? Colors.grey
                                : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
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
                        ? const CircularProgressIndicator(
                            color: Colors.white)
                        : const Text("Adicionar Evento",
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
