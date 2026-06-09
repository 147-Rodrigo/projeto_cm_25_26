import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/Style/add_com.dart';

class AdicionarComentarioPage extends StatefulWidget {
  const AdicionarComentarioPage({super.key});

  @override
  State<AdicionarComentarioPage> createState() =>
      _AdicionarComentarioPageState();
}

class _AdicionarComentarioPageState extends State<AdicionarComentarioPage> {
  final TextEditingController ctrl = TextEditingController();

  @override
  void dispose() {
    ctrl.dispose();
    super.dispose();
  }

  void submit() {
    final text = ctrl.text.trim();
    if (text.isEmpty) return;

    FirebaseFirestore.instance.collection('forumPosts').add({
      'username': 'Eu',
      'text': text,
      'createdAt': FieldValue.serverTimestamp(),
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: AddComStyles.pagePadding.left,
        right: AddComStyles.pagePadding.right,
        top: AddComStyles.pagePadding.top,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: ctrl,
            maxLines: 4,
            decoration: AddComStyles.textFieldDecoration,
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            style: AddComStyles.buttonStyle,
            onPressed: submit,
            child: const Text("Publicar"),
          ),
        ],
      ),
    );
  }
}