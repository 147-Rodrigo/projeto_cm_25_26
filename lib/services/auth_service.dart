import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Registo
  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String dataNascimento,
    required String localizacao,
    String role = 'utilizador',
  }) async {
    
    // validação da senha antes do Firebase
    if (password.length < 6) {
      throw Exception("A senha deve ter pelo menos 6 caracteres");
    }

    try {
      // criar conta
      final userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // guardar no Firestore
      await _db.collection("users").doc(userCredential.user!.uid).set({
        "nome": name,
        "email": email,
        "dataNascimento": dataNascimento,
        "localizacao": localizacao,
        "role": role,
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        throw Exception("Este email já está registado");
      } else if (e.code == 'invalid-email') {
        throw Exception("Email inválido");
      } else {
        throw Exception("Erro ao criar conta");
      }
    }
  }

  // Login
  Future<UserCredential> login({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw Exception("Utilizador não encontrado");
      } else if (e.code == 'wrong-password') {
        throw Exception("Password incorreta");
      } else {
        throw Exception("Erro ao fazer login");
      }
    }
  }

  //Edição Perfil
  Future<void> updateUserProfile({
  required String uid,
  required String name,
  required String dataNascimento,
  required String localizacao,
}) async {
  try {
    await _db.collection("users").doc(uid).update({
      "nome": name,
      "dataNascimento": dataNascimento,
      "localizacao": localizacao,
    });
  } catch (e) {
    throw Exception("Erro ao atualizar perfil");
  }
}

Future<void> showEditProfileSheet({
  required BuildContext context,
  required String uid,
  required Map<String, dynamic> currentData,
}) async {
  final nameController = TextEditingController(text: currentData["nome"]);
  final birthController = TextEditingController(text: currentData["dataNascimento"]);
  final locationController = TextEditingController(text: currentData["localizacao"]);

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Editar Perfil",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Nome"),
            ),

            TextField(
              controller: birthController,
              decoration: const InputDecoration(labelText: "Data de Nascimento"),
            ),

            TextField(
              controller: locationController,
              decoration: const InputDecoration(labelText: "Localização"),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () async {
                await updateUserProfile(
                  uid: uid,
                  name: nameController.text,
                  dataNascimento: birthController.text,
                  localizacao: locationController.text,
                );

                if (context.mounted) Navigator.pop(context);
              },
              child: const Text("Guardar"),
            ),

            const SizedBox(height: 20),
          ],
        ),
      );
    },
  );
}
}