import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'Style/custom_appbar.dart';
import 'Style/text_styles.dart';
import 'services/event_service.dart';

class CriarEventoPage extends StatefulWidget {
  // Se eventoData for fornecido, entra em modo de edição
  final String? eventoId;
  final Map<String, dynamic>? eventoData;

  const CriarEventoPage({super.key, this.eventoId, this.eventoData});

  @override
  State<CriarEventoPage> createState() => _CriarEventoPageState();
}

class _CriarEventoPageState extends State<CriarEventoPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _tituloController;
  late final TextEditingController _descricaoController;
  late final TextEditingController _localController;
  late final TextEditingController _materiaisController;
  late final TextEditingController _maxParticipantesController;

  final EventService _eventService = EventService();

  String _dataEscolhida = "";
  String _horaInicio = "";
  String _horaFim = "";
  String _categoriaEscolhida = "Limpeza";
  bool _loading = false;

  bool get _isEditing => widget.eventoId != null;

  final List<Map<String, dynamic>> _categorias = [
    {"label": "Limpeza", "icon": Icons.cleaning_services},
    {"label": "Reciclagem", "icon": Icons.recycling},
    {"label": "Plantação", "icon": Icons.park},
    {"label": "Educação", "icon": Icons.school},
    {"label": "Outro", "icon": Icons.event},
  ];

  IconData get _iconDaCategoria =>
      _categorias.firstWhere((c) => c["label"] == _categoriaEscolhida)["icon"];

  @override
  void initState() {
    super.initState();
    final d = widget.eventoData;
    _tituloController = TextEditingController(text: d?["titulo"] ?? "");
    _descricaoController = TextEditingController(text: d?["descricao"] ?? "");
    _localController = TextEditingController(text: d?["local"] ?? "");
    _materiaisController = TextEditingController(text: d?["materiais"] ?? "");
    _maxParticipantesController = TextEditingController(
        text: d != null ? (d["maxParticipantes"] ?? 0).toString() : "");

    if (d != null) {
      _dataEscolhida = d["data"] ?? "";
      _horaInicio = d["horaInicio"] ?? "";
      _horaFim = d["horaFim"] ?? "";
      _categoriaEscolhida = d["categoria"] ?? "Limpeza";
    }
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descricaoController.dispose();
    _localController.dispose();
    _materiaisController.dispose();
    _maxParticipantesController.dispose();
    super.dispose();
  }

  Future<void> _escolherData() async {
    final hoje = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: hoje,
      firstDate: hoje,
      lastDate: DateTime(hoje.year + 2),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: Colors.green),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _dataEscolhida =
            "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      });
    }
  }

  Future<void> _escolherHora(bool isInicio) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: Colors.green),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      final formatted =
          "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
      setState(() {
        if (isInicio) {
          _horaInicio = formatted;
        } else {
          _horaFim = formatted;
        }
      });
    }
  }

  Future<void> _submeter() async {
    if (!_formKey.currentState!.validate()) return;

    if (_dataEscolhida.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor escolha uma data")),
      );
      return;
    }
    if (_horaInicio.isEmpty || _horaFim.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor escolha a hora de início e de término")),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final maxP = int.tryParse(_maxParticipantesController.text.trim()) ?? 0;

      if (_isEditing) {
        await _eventService.editarEvento(
          eventoId: widget.eventoId!,
          titulo: _tituloController.text.trim(),
          descricao: _descricaoController.text.trim(),
          data: _dataEscolhida,
          horaInicio: _horaInicio,
          horaFim: _horaFim,
          local: _localController.text.trim(),
          categoria: _categoriaEscolhida,
          materiais: _materiaisController.text.trim(),
          maxParticipantes: maxP,
        );
      } else {
        await _eventService.criarEvento(
          titulo: _tituloController.text.trim(),
          descricao: _descricaoController.text.trim(),
          data: _dataEscolhida,
          horaInicio: _horaInicio,
          horaFim: _horaFim,
          local: _localController.text.trim(),
          categoria: _categoriaEscolhida,
          materiais: _materiaisController.text.trim(),
          maxParticipantes: maxP,
        );
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing
              ? "Evento atualizado com sucesso!"
              : "Evento criado com sucesso!"),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro: $e")),
      );
    }

    setState(() => _loading = false);
  }

  Widget _horaPicker(String label, String valor, bool isInicio) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _escolherHora(isInicio),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            children: [
              Icon(
                isInicio ? Icons.play_circle_outline : Icons.stop_circle_outlined,
                color: Colors.grey,
                size: 20,
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  Text(
                    valor.isEmpty ? "--:--" : valor,
                    style: TextStyle(
                      fontSize: 14,
                      color: valor.isEmpty ? Colors.grey : Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: _isEditing ? "Editar Evento" : "Criar Evento",
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),

                // Ícone de pré-visualização
                Center(
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.green,
                    child: Icon(_iconDaCategoria, size: 40, color: Colors.white),
                  ),
                ),

                const SizedBox(height: 20),

                // Título
                TextFormField(
                  controller: _tituloController,
                  decoration: const InputDecoration(
                    labelText: "Título do Evento",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.title),
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? "Insira o título" : null,
                ),

                const SizedBox(height: 14),

                // Descrição
                TextFormField(
                  controller: _descricaoController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: "Descrição",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.description),
                    alignLabelWithHint: true,
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? "Insira a descrição" : null,
                ),

                const SizedBox(height: 14),

                // Local
                TextFormField(
                  controller: _localController,
                  decoration: const InputDecoration(
                    labelText: "Local",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.location_on),
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? "Insira o local" : null,
                ),

                const SizedBox(height: 14),

                // Materiais necessários
                TextFormField(
                  controller: _materiaisController,
                  decoration: const InputDecoration(
                    labelText: "Materiais necessários",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.build_circle_outlined),
                    hintText: "Ex: luvas, sacos de lixo, vassoura...",
                  ),
                ),

                const SizedBox(height: 14),

                // Máx. participantes
                TextFormField(
                  controller: _maxParticipantesController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    labelText: "Máximo de participantes",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.group),
                    hintText: "0 = sem limite",
                  ),
                ),

                const SizedBox(height: 14),

                // Data
                GestureDetector(
                  onTap: _escolherData,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today,
                            color: Colors.grey, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          _dataEscolhida.isEmpty ? "Data do evento" : _dataEscolhida,
                          style: TextStyle(
                            color: _dataEscolhida.isEmpty
                                ? Colors.grey
                                : Colors.black,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // Hora início e fim
                Row(
                  children: [
                    _horaPicker("Início", _horaInicio, true),
                    const SizedBox(width: 12),
                    _horaPicker("Término", _horaFim, false),
                  ],
                ),

                const SizedBox(height: 16),

                // Categoria
                const Text("Categoria", style: AppTextStyles.forumUsername),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _categorias.map((cat) {
                    final isSelected = _categoriaEscolhida == cat["label"];
                    return GestureDetector(
                      onTap: () =>
                          setState(() => _categoriaEscolhida = cat["label"]),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.green
                              : const Color.fromRGBO(171, 255, 156, 1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? Colors.green
                                : Colors.green.shade300,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(cat["icon"],
                                size: 16,
                                color:
                                    isSelected ? Colors.white : Colors.green),
                            const SizedBox(width: 6),
                            Text(
                              cat["label"],
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.green,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 28),

                // Botão
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: _loading ? null : _submeter,
                    child: _loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            _isEditing ? "Guardar Alterações" : "Criar Evento",
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
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