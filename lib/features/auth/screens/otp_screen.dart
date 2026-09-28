import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key, this.email});

  final String? email;

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  void _verifyOtp() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'La vérification OTP sera connectée à l’API prochainement.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final email = widget.email;

    return Scaffold(
      appBar: AppBar(title: const Text('Vérification')),
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
                      Icons.verified_outlined,
                      size: 72,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Code de vérification',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      email == null
                          ? 'Entrez le code reçu.'
                          : 'Entrez le code reçu sur $email.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: _otpController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 6,
                      decoration: const InputDecoration(
                        labelText: 'Code OTP',
                        hintText: '000000',
                        prefixIcon: Icon(Icons.pin_outlined),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Entrez le code.';
                        }

                        if (value.length != 6) {
                          return 'Le code doit contenir 6 chiffres.';
                        }

                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _verifyOtp,
                        child: const Text('Vérifier'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Un nouveau code sera envoyé via l’API.',
                            ),
                          ),
                        );
                      },
                      child: const Text('Renvoyer le code'),
                    ),
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
