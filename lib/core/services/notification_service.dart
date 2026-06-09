import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
  NotificationService._();
  static final instance = NotificationService._();

  final _db = FirebaseFirestore.instance;

  Future<void> addNotification({
    required String titulo,
    required String mensagem,
  }) async {
    await _db.collection("notifications").add({
      "titulo": titulo,
      "mensagem": mensagem,
      "data": FieldValue.serverTimestamp(),
    });
  }
}