import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'Style/custom_appbar.dart';
import 'Style/text_styles.dart';
import 'home.dart';
import 'donation.dart';
import 'forum.dart';
import 'info.dart';
import 'perfil.dart';
import 'criar_evento.dart';
import 'services/event_service.dart';

class EventosPage extends StatelessWidget {
  const EventosPage({super.key});

  @override
  Widget build(BuildContext context) {
    final EventService eventService = EventService();
    final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: CustomAppBar(
        title: "Eventos",
        actions: [
          IconButton(icon: const Icon(Icons.newspaper), onPressed: () {}),
          IconButton(icon: const Icon(Icons.notifications), onPressed: () {}),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const PerfilPage())),
          ),
        ],
      ),

      // FAB posicionado acima da barra de navegação
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 68),
        child: FloatingActionButton(
          backgroundColor: Colors.green,
          onPressed: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const CriarEventoPage())),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),

      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: eventService.getEventos(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator(color: Colors.green));
                }
                if (snapshot.hasError) {
                  return const Center(child: Text("Erro ao carregar eventos."));
                }

                final docs = snapshot.data?.docs ?? [];

                if (docs.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.event_busy, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          "Ainda não há eventos.\nSeja o primeiro a criar um!",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  itemCount: docs.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return const Padding(
                        padding: EdgeInsets.only(bottom: 12),
                        child: Center(
                          child: Text("Eventos", style: AppTextStyles.welcomeTitle),
                        ),
                      );
                    }

                    final doc = docs[index - 1];
                    final data = doc.data() as Map<String, dynamic>;
                    final isAutor = data["autorId"] == currentUserId;
                    final List inscritos = List.from(data["inscritos"] ?? []);
                    final isInscrito = inscritos.contains(currentUserId);
                    final int maxP = data["maxParticipantes"] ?? 0;

                    return _EventoCard(
                      eventoId: doc.id,
                      data: data,
                      isAutor: isAutor,
                      isInscrito: isInscrito,
                      inscritos: inscritos,
                      maxParticipantes: maxP,
                      eventService: eventService,
                    );
                  },
                );
              },
            ),
          ),

          // Barra de navegação
          Container(
            width: double.infinity,
            color: Colors.green,
            child: SizedBox(
              height: 60,
              child: Row(
                children: [
                  _buildButton(Icons.map, () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const HomePage()))),
                  _divider(),
                  _buildButton(Icons.calendar_month, () {}),
                  _divider(),
                  _buildButton(Icons.volunteer_activism, () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const DonationPage()))),
                  _divider(),
                  _buildButton(Icons.message, () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ForumPage()))),
                  _divider(),
                  _buildButton(Icons.info, () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const InfoPage()))),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(IconData icon, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Center(child: Icon(icon, color: Colors.white, size: 28)),
      ),
    );
  }

  Widget _divider() =>
      Container(width: 1, height: 30, color: Colors.white30);
}

// ==========================
// CARD DE EVENTO
// ==========================

class _EventoCard extends StatelessWidget {
  final String eventoId;
  final Map<String, dynamic> data;
  final bool isAutor;
  final bool isInscrito;
  final List inscritos;
  final int maxParticipantes;
  final EventService eventService;

  static const Map<String, IconData> _categoriaIcons = {
    "Limpeza": Icons.cleaning_services,
    "Reciclagem": Icons.recycling,
    "Plantação": Icons.park,
    "Educação": Icons.school,
    "Outro": Icons.event,
  };

  const _EventoCard({
    required this.eventoId,
    required this.data,
    required this.isAutor,
    required this.isInscrito,
    required this.inscritos,
    required this.maxParticipantes,
    required this.eventService,
  });

  @override
  Widget build(BuildContext context) {
    final String titulo = data["titulo"] ?? "";
    final String dataEvento = data["data"] ?? "";
    final String horaInicio = data["horaInicio"] ?? data["hora"] ?? "";
    final String horaFim = data["horaFim"] ?? "";
    final String local = data["local"] ?? "";
    final String descricao = data["descricao"] ?? "";
    final String categoria = data["categoria"] ?? "Outro";
    final String autorNome = data["autorNome"] ?? "Utilizador";
    final String materiais = data["materiais"] ?? "";
    final int numInscritos = inscritos.length;

    final bool lotado = maxParticipantes > 0 && numInscritos >= maxParticipantes;
    final icon = _categoriaIcons[categoria] ?? Icons.event;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(171, 255, 156, 1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho
            Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.green,
                  child: Icon(icon, color: Colors.white, size: 26),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(titulo, style: AppTextStyles.forumUsername),
                      const SizedBox(height: 2),
                      Text("por $autorNome", style: AppTextStyles.forumDate),
                    ],
                  ),
                ),
                // Editar (autor) ou menu vazio
                if (isAutor) ...[
                  IconButton(
                    icon: const Icon(Icons.edit_outlined,
                        color: Colors.green, size: 22),
                    tooltip: "Editar",
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CriarEventoPage(
                          eventoId: eventoId,
                          eventoData: data,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline,
                        color: Colors.red, size: 22),
                    tooltip: "Apagar",
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text("Apagar Evento"),
                          content: const Text(
                              "Tem a certeza que quer apagar este evento?"),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text("Cancelar"),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text("Apagar",
                                  style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        try {
                          await eventService.apagarEvento(eventoId);
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Erro: $e")));
                          }
                        }
                      }
                    },
                  ),
                ],
              ],
            ),

            const SizedBox(height: 12),

            // Data e horas
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 14, color: Colors.green),
                const SizedBox(width: 4),
                Text(dataEvento, style: AppTextStyles.forumDate),
                const SizedBox(width: 10),
                const Icon(Icons.access_time, size: 14, color: Colors.green),
                const SizedBox(width: 4),
                Text(
                  horaFim.isNotEmpty
                      ? "$horaInicio → $horaFim"
                      : horaInicio,
                  style: AppTextStyles.forumDate,
                ),
              ],
            ),

            const SizedBox(height: 4),

            // Local
            Row(
              children: [
                const Icon(Icons.location_on, size: 14, color: Colors.green),
                const SizedBox(width: 4),
                Expanded(child: Text(local, style: AppTextStyles.forumDate)),
              ],
            ),

            const SizedBox(height: 10),

            // Descrição
            Text(descricao, style: AppTextStyles.forumText),

            // Materiais
            if (materiais.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.build_circle_outlined,
                      size: 14, color: Colors.green),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      "Materiais: $materiais",
                      style: AppTextStyles.forumDate,
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 10),

            // Rodapé: badge categoria + participantes + botão inscrever
            Row(
              children: [
                // Badge categoria
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    categoria,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // Participantes
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.group, size: 13, color: Colors.green),
                      const SizedBox(width: 4),
                      Text(
                        maxParticipantes > 0
                            ? "$numInscritos / $maxParticipantes"
                            : "$numInscritos inscritos",
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Botão inscrever (só para não-autores)
                if (!isAutor)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isInscrito ? Colors.white : Colors.green,
                      foregroundColor:
                          isInscrito ? Colors.red : Colors.white,
                      side: BorderSide(
                          color: isInscrito ? Colors.red : Colors.green),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                    ),
                    onPressed: lotado && !isInscrito
                        ? null
                        : () async {
                            try {
                              await eventService.toggleInscricao(eventoId);
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text("$e")));
                              }
                            }
                          },
                    child: Text(
                      isInscrito
                          ? "Cancelar"
                          : lotado
                              ? "Lotado"
                              : "Inscrever",
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}