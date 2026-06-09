import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminService {
  static const String _adminRole = 'admin';

  /// Devolve true se o utilizador autenticado tiver role == 'admin'
  static Future<bool> isAdmin() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (!doc.exists) return false;
    final data = doc.data() as Map<String, dynamic>;
    return (data['role'] as String?) == _adminRole;
  }

  /// Stream contínuo — útil para widgets que reagem a mudanças de role
  static Stream<bool> adminStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return Stream.value(false);

    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .map((snap) {
      if (!snap.exists) return false;
      final data = snap.data() as Map<String, dynamic>;
      return (data['role'] as String?) == _adminRole;
    });
  }
}
