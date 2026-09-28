import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _sendCode() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    context.push('/otp', extra: _emailController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mot de passe oublié')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(
                      Icons.lock_reset_outlined,
                      size: 72,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Réinitialiser le mot de passe',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Entrez votre adresse email. Un code de vérification vous sera envoyé.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Adresse email',
                        prefixIcon: Icon(Icons.email_outlined),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Entrez votre email.';
                        }

                        if (!value.contains('@')) {
                          return 'Entrez un email valide.';
                        }

                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _sendCode,
                        child: const Text('Envoyer le code'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () {
                        context.go('/login');
                      },
                      child: const Text('Retour à la connexion'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
