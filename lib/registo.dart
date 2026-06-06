import 'package:flutter/material.dart';

import 'Style/custom_appbar.dart';
import 'Style/text_styles.dart';

import 'login.dart';
import 'main.dart';

class RegistoPage extends StatefulWidget {
  const RegistoPage({super.key});

  @override
  State<RegistoPage> createState() => _RegistoPageState();
}

class _RegistoPageState extends State<RegistoPage> {

  // Chave do formulário
  final _formKey = GlobalKey<FormState>();

  // Controladores
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      // Barra superior
      appBar: CustomAppBar(
        title: "Registo",

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

      // Corpo da página
      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Form(
          key: _formKey,

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,

            children: [

              // Espaço
              const SizedBox(height: 30),

              // Avatar
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

              // Campo Nome
              TextFormField(
                controller: _nomeController,

                decoration: const InputDecoration(
                  labelText: "Nome Completo",
                  border: OutlineInputBorder(),
                ),

                validator: (value) {

                  if (value == null || value.isEmpty) {
                    return "Insira o nome completo";
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Campo Email
              TextFormField(
                controller: _emailController,

                keyboardType: TextInputType.emailAddress,

                decoration: const InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(),
                ),

                validator: (value) {

                  if (value == null || value.isEmpty) {
                    return "Insira o email";
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Campo Senha
              TextFormField(
                controller: _senhaController,

                obscureText: true,

                decoration: const InputDecoration(
                  labelText: "Senha",
                  border: OutlineInputBorder(),
                ),

                validator: (value) {

                  if (value == null || value.isEmpty) {
                    return "Insira a senha";
                  }

                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Botão Registar
              ElevatedButton(

                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),

                onPressed: () {

                  // Validação
                  if (_formKey.currentState!.validate()) {

                    // Mensagem
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Registo bem-sucedido"),
                      ),
                    );
                  }
                },

                child: const Text("Registar"),
              ),

              const SizedBox(height: 16),

              // Ir para Login
              GestureDetector(

                onTap: () {

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginPage(),
                    ),
                  );
                },

                child: const Text(
                  "Já tem conta? Faça Login",
                  style: AppTextStyles.linkText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}