import 'package:flutter/material.dart';

import 'Style/custom_appbar.dart';
import 'Style/text_styles.dart';

import 'home.dart';
import 'registo.dart';
import 'main.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  // Chave do formulário
  final _formKey = GlobalKey<FormState>();

  // Controladores dos campos
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      // Barra superior
      appBar: CustomAppBar(
        title: "Login",

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

                validator: (value) {

                  if (value == null || value.isEmpty) {
                    return "Insira a senha";
                  }

                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Botão Entrar
              ElevatedButton(

                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),

                onPressed: () {

                  // Verifica se os campos estão válidos
                  if (_formKey.currentState!.validate()) {

                    // Mensagem
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Login bem-sucedido"),
                      ),
                    );

                    // Vai para a Home
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HomePage(),
                      ),
                    );
                  }
                },

                child: const Text("Entrar"),
              ),

              const SizedBox(height: 16),

              // Texto para criar conta
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
    );
  }
}