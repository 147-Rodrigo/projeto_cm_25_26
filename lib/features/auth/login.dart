import 'package:flutter/material.dart';

import '../../core/services/auth_service.dart';

import '../../core/Style/custom_appbar.dart';
import '../../core/Style/text_styles.dart';

import '../home/home.dart';
import 'registo.dart';
import '../../main.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

// Formulário e Controladores
class _LoginPageState extends State<LoginPage> {
  // Chave global para validar o formulário inteiro
  final _formKey = GlobalKey<FormState>();

  // Controlador do campo de email
  final _emailController = TextEditingController();

  // Controlador do campo de password
  final _passwordController = TextEditingController();

  // Serviço de autenticação (Firebase)
  final AuthService _authService = AuthService();

  // Estado de loading (evita múltiplos cliques no botão)
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      // App Bar
      appBar: CustomAppBar(
        title: "Login",

        // Botão de voltar
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => const StartPage(),
              ),
              (route) => false,
            );
          },
        ),
      ),

      // Página
      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Form(
          key: _formKey,

    child: SingleChildScrollView(
      child: Column(
        children: [

              // Espaçamento superior
              const SizedBox(height: 30),

              // Ícone do utilizador
              const CircleAvatar(
                radius: 55,
                backgroundColor: Colors.green,
                child: Icon(
                  Icons.person,
                  size: 60,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 30),

              // Campo Email
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,

                decoration: const InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(),
                ),

                // Validação simples do email
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Insira o email";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Campo Password
              TextFormField(
                controller: _passwordController,
                obscureText: true,

                decoration: const InputDecoration(
                  labelText: "Senha",
                  border: OutlineInputBorder(),
                ),

                // Validação simples da password
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Insira a senha";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Botão Login
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),

                // Desativa botão enquanto está a carregar
                onPressed: _loading
                    ? null
                    : () async {
                        // Valida formulário antes de continuar
                        if (!_formKey.currentState!.validate()) return;

                        setState(() => _loading = true);

                        try {
                          // Tenta fazer login com Firebase
                          await _authService.login(
                            email: _emailController.text.trim(),
                            password: _passwordController.text.trim(),
                          );

                          // Evita erro se a página já foi fechada
                          if (!mounted) return;

                          // Mostra mensagem de sucesso
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Login bem-sucedido"),
                            ),
                          );

                          // Vai para a Home e remove a página de login
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const HomePage(),
                            ),
                          );
                        } catch (e) {
                          // Mostra erro no login
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Erro: $e")),
                          );
                        }

                        setState(() => _loading = false);
                      },

                // Texto do botão ou loading
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Entrar"),
              ),

              const SizedBox(height: 16),

              // Link para Registo
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RegistoPage(),
                    ),
                  );
                },

                child: const Text(
                  "Não tem conta? Registe-se",
                  style: AppTextStyles.linkText,
                ),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}