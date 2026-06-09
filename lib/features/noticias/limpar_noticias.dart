import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LimparNoticiasPage extends StatefulWidget {
  const LimparNoticiasPage({super.key});

  @override
  State<LimparNoticiasPage> createState() => _LimparNoticiasPageState();
}

class _LimparNoticiasPageState extends State<LimparNoticiasPage> {
  bool _loading = false;
  String _mensagem = '';

  Future<void> _limparTudo() async {
    // Confirmação antes de apagar
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Tens a certeza?"),
        content: const Text("Isto vai apagar TODAS as notícias permanentemente."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Apagar tudo", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    setState(() {
      _loading = true;
      _mensagem = '';
    });

    try {
      final snap = await FirebaseFirestore.instance
          .collection('noticias')
          .get();

      for (final doc in snap.docs) {
        await doc.reference.delete();
      }

      setState(() => _mensagem = '✅ ${snap.docs.length} notícias apagadas com sucesso!');
    } catch (e) {
      setState(() => _mensagem = '❌ Erro: $e');
    }

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text("Limpar Notícias", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.delete_forever, size: 80, color: Colors.red),
              const SizedBox(height: 24),
              const Text(
                "Apagar todas as notícias",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                "Esta ação é irreversível.",
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: _loading ? null : _limparTudo,
                icon: _loading
                    ? const SizedBox(
                        width: 18, height: 18,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Icon(Icons.delete_sweep),
                label: Text(_loading ? "A apagar..." : "Apagar tudo"),
              ),
              const SizedBox(height: 24),
              if (_mensagem.isNotEmpty)
                Text(
                  _mensagem,
                  style: TextStyle(
                    fontSize: 16,
                    color: _mensagem.startsWith('✅') ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
