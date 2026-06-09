import 'package:flutter/material.dart';

import 'Style/custom_appbar.dart';
import 'Style/text_styles.dart';

import 'login.dart';
import 'main.dart';
import 'services/auth_service.dart';

class RegistoPage extends StatefulWidget {
  const RegistoPage({super.key});

  @override
  State<RegistoPage> createState() => _RegistoPageState();
}

class _RegistoPageState extends State<RegistoPage> {
  final _formKey = GlobalKey<FormState>();

  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _dataController = TextEditingController();
  final _localizacaoController = TextEditingController();

  final AuthService _authService = AuthService();

  bool _loading = false;

  Future<void> _registar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      await _authService.register(
        name: _nomeController.text.trim(),
        email: _emailController.text.trim(),
        password: _senhaController.text.trim(),
        dataNascimento: _dataController.text.trim(),
        localizacao: _localizacaoController.text.trim(),
        // role por omissão — 'admin' só pode ser definido manualmente
        // no Firestore ou por outro admin
        role: 'utilizador',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Registo bem-sucedido")),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const StartPage()),
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro: $e")),
      );
    }

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Registo",
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const StartPage()),
              (route) => false,
            );
          },
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 30),

                const CircleAvatar(
                  radius: 55,
                  backgroundColor: Colors.green,
                  child:
                      Icon(Icons.person, size: 60, color: Colors.white),
                ),

                const SizedBox(height: 30),

                TextFormField(
                  controller: _nomeController,
                  decoration: const InputDecoration(
                    labelText: "Nome Completo",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? "Insira o nome completo"
                      : null,
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: "Email",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? "Insira o email"
                      : null,
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _senhaController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "Senha",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? "Insira a senha"
                      : null,
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _dataController,
                  decoration: const InputDecoration(
                    labelText: "Data de Nascimento",
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _localizacaoController,
                  decoration: const InputDecoration(
                    labelText: "Localização",
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 24),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _loading ? null : _registar,
                  child: _loading
                      ? const CircularProgressIndicator(
                          color: Colors.white)
                      : const Text("Registar"),
                ),

                const SizedBox(height: 16),

                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const LoginPage()),
                  ),
                  child: const Text(
                    "Já tem conta? Faça Login",
                    style: AppTextStyles.linkText,
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
