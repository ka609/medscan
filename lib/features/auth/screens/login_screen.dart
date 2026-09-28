import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/routes/app_router.dart';
import '../../../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final success = await context.read<AuthProvider>().login(
      username: _usernameController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) {
      return;
    }

    if (success) {
      context.go(AppRoutes.main);
      return;
    }

    final error = context.read<AuthProvider>().error;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(error ?? 'Échec de la connexion.')));
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
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
                    _buildHeader(),
                    const SizedBox(height: 40),
                    _buildUsernameField(),
                    const SizedBox(height: 16),
                    _buildPasswordField(),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          context.push(AppRoutes.forgotPassword);
                        },
                        child: const Text('Mot de passe oublié ?'),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: authProvider.isLoading ? null : _login,
                        child: authProvider.isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Se connecter'),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Vous n’avez pas de compte ?'),
                        TextButton(
                          onPressed: () {
                            context.push(AppRoutes.register);
                          },
                          child: const Text('Créer un compte'),
                        ),
                      ],
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

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.medical_services_outlined,
            size: 48,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'MedScan',
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Connectez-vous à votre espace santé',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildUsernameField() {
    return TextFormField(
      controller: _usernameController,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.next,
      decoration: const InputDecoration(
        labelText: 'Nom d’utilisateur',
        hintText: 'Entrez votre nom d’utilisateur',
        prefixIcon: Icon(Icons.person_outline),
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Entrez votre nom d’utilisateur.';
        }

        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (_) => _login(),
      decoration: InputDecoration(
        labelText: 'Mot de passe',
        hintText: 'Entrez votre mot de passe',
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
          icon: Icon(
            _obscurePassword
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
          ),
        ),
        border: const OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Entrez votre mot de passe.';
        }

        return null;
      },
    );
  }
}
