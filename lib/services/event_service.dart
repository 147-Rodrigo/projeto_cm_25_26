import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EventService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Criar evento no Firestore
  Future<void> criarEvento({
    required String titulo,
    required String descricao,
    required String data,
    required String horaInicio,
    required String horaFim,
    required String local,
    required String categoria,
    required String materiais,
    required int maxParticipantes,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("Utilizador não autenticado");

    final userDoc = await _db.collection("users").doc(user.uid).get();
    final nomeAutor = userDoc.data()?["nome"] ?? "Utilizador";

    await _db.collection("eventos").add({
      "titulo": titulo,
      "descricao": descricao,
      "data": data,
      "horaInicio": horaInicio,
      "horaFim": horaFim,
      "local": local,
      "categoria": categoria,
      "materiais": materiais,
      "maxParticipantes": maxParticipantes,
      "inscritos": [],
      "autorId": user.uid,
      "autorNome": nomeAutor,
      "criadoEm": FieldValue.serverTimestamp(),
    });
  }

  // Editar evento
  Future<void> editarEvento({
    required String eventoId,
    required String titulo,
    required String descricao,
    required String data,
    required String horaInicio,
    required String horaFim,
    required String local,
    required String categoria,
    required String materiais,
    required int maxParticipantes,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("Utilizador não autenticado");

    await _db.collection("eventos").doc(eventoId).update({
      "titulo": titulo,
      "descricao": descricao,
      "data": data,
      "horaInicio": horaInicio,
      "horaFim": horaFim,
      "local": local,
      "categoria": categoria,
      "materiais": materiais,
      "maxParticipantes": maxParticipantes,
    });
  }

  // Inscrever / cancelar inscrição
  Future<void> toggleInscricao(String eventoId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("Utilizador não autenticado");

    final ref = _db.collection("eventos").doc(eventoId);
    final doc = await ref.get();
    final data = doc.data()!;
    final List inscritos = List.from(data["inscritos"] ?? []);
    final int maxParticipantes = data["maxParticipantes"] ?? 0;

    if (inscritos.contains(user.uid)) {
      inscritos.remove(user.uid);
    } else {
      if (maxParticipantes > 0 && inscritos.length >= maxParticipantes) {
        throw Exception("Evento já atingiu o número máximo de participantes");
      }
      inscritos.add(user.uid);
    }

    await ref.update({"inscritos": inscritos});
  }

  // Stream de todos os eventos
  Stream<QuerySnapshot> getEventos() {
    return _db
        .collection("eventos")
        .orderBy("criadoEm", descending: true)
        .snapshots();
  }

  Future<void> apagarEvento(String eventoId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("Utilizador não autenticado");

    final doc = await _db.collection("eventos").doc(eventoId).get();
    if (doc.data()?["autorId"] != user.uid) {
      throw Exception("Sem permissão para apagar este evento");
    }

    await _db.collection("eventos").doc(eventoId).delete();
  }
}