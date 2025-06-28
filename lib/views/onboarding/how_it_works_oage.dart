import 'package:flutter/material.dart';

class HowItWorksPage extends StatelessWidget {
  const HowItWorksPage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      color: colorScheme.background,
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.lightbulb_outline_rounded,
            size: 90,
            color: colorScheme.primary,
          ),
          const SizedBox(height: 24),
          Text(
            "How It Works",
            style: textTheme.headlineMedium?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colorScheme.surfaceVariant.withOpacity(0.5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFeatureItem(
                  context,
                  Icons.post_add,
                  "Create a report for a lost or found item with details and images.",
                  colorScheme,
                ),
                const SizedBox(height: 14),
                _buildFeatureItem(
                  context,
                  Icons.rate_review,
                  "Others can review and submit a claim if they recognize the item.",
                  colorScheme,
                ),
                const SizedBox(height: 14),
                _buildFeatureItem(
                  context,
                  Icons.verified_user,
                  "You review and accept valid claims to unlock contact details.",
                  colorScheme,
                ),
                const SizedBox(height: 14),
                _buildFeatureItem(
                  context,
                  Icons.connect_without_contact,
                  "Communicate and arrange a safe handover.",
                  colorScheme,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(BuildContext context, IconData icon, String text, ColorScheme colorScheme) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: colorScheme.secondary.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          padding: const EdgeInsets.all(8),
          child: Icon(icon, size: 22, color: colorScheme.secondary),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            text,
            style: textTheme.bodyLarge?.copyWith(
              color: colorScheme.onBackground.withOpacity(0.85),
            ),
          ),
        ),
      ],
    );
  }
}