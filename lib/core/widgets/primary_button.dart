import 'package:flutter/material.dart';

/// Bouton d'action principal (ex: "Continue", "Book Now", "Save").
/// [trailingArrow] reproduit le chevron ">" vu sur la plupart des CTA
/// des maquettes.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.trailingArrow = true,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool trailingArrow;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2.4,
                color: Colors.white,
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(label),
                if (trailingArrow) ...[
                  const SizedBox(width: 6),
                  const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                ],
              ],
            ),
    );
  }
}
