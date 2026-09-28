import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _firstNameController = TextEditingController();

  final _lastNameController = TextEditingController();

  final _emailController = TextEditingController();

  final _usernameController = TextEditingController();

  final _passwordController = TextEditingController();

  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _register() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('L’inscription sera connectée à l’API prochainement.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Créer un compte')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 12),
                    Text(
                      'Bienvenue sur MedScan',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Créez votre compte pour accéder à vos services de santé.',
                    ),
                    const SizedBox(height: 28),
                    _buildField(
                      controller: _firstNameController,
                      label: 'Prénom',
                      icon: Icons.person_outline,
                    ),
                    const SizedBox(height: 16),
                    _buildField(
                      controller: _lastNameController,
                      label: 'Nom',
                      icon: Icons.person_outline,
                    ),
                    const SizedBox(height: 16),
                    _buildField(
                      controller: _emailController,
                      label: 'Email',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    _buildField(
                      controller: _usernameController,
                      label: 'Nom d’utilisateur',
                      icon: Icons.account_circle_outlined,
                    ),
                    const SizedBox(height: 16),
                    _buildPasswordField(
                      controller: _passwordController,
                      label: 'Mot de passe',
                      obscure: _obscurePassword,
                      onToggle: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildPasswordField(
                      controller: _confirmPasswordController,
                      label: 'Confirmer le mot de passe',
                      obscure: _obscureConfirmPassword,
                      onToggle: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Confirmez votre mot de passe.';
                        }

                        if (value != _passwordController.text) {
                          return 'Les mots de passe ne correspondent pas.';
                        }

                        return null;
                      },
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _register,
                        child: const Text('Créer mon compte'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        context.go('/login');
                      },
                      child: const Text('J’ai déjà un compte'),
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

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Ce champ est obligatoire.';
        }

        return null;
      },
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscure,
    required VoidCallback onToggle,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          onPressed: onToggle,
          icon: Icon(
            obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          ),
        ),
        border: const OutlineInputBorder(),
      ),
      validator:
          validator ??
          (value) {
            if (value == null || value.isEmpty) {
              return 'Ce champ est obligatoire.';
            }

            if (value.length < 6) {
              return 'Minimum 6 caractères.';
            }

            return null;
          },
    );
  }
}
