import 'package:flutter/material.dart';

class HowItWorksPage extends StatelessWidget {
  const HowItWorksPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Container(
      color: colorScheme.background,
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.lightbulb_outline_rounded, // Example icon
            size: 120,
            color: colorScheme.primary,
          ),
          const SizedBox(height: 40),
          Text(
            "How It Works",
            style: textTheme.displayMedium?.copyWith(
              color: colorScheme.onBackground,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFeatureItem(
                  context,
                  Icons.post_add,
                  "Lost something? Post a report with details and images.",
                ),
                const SizedBox(height: 16),
                _buildFeatureItem(
                  context,
                  Icons.find_in_page,
                  "Found a document? Easily upload its information to help find its owner.",
                ),
                const SizedBox(height: 16),
                _buildFeatureItem(
                  context,
                  Icons.connect_without_contact,
                  "Connect securely with others to retrieve or return documents.",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(BuildContext context, IconData icon, String text) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 30, color: colorScheme.secondary),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            text,
            style: textTheme.bodyLarge?.copyWith(
              color: colorScheme.onBackground.withOpacity(0.8),
            ),
          ),
        ),
      ],
    );
  }
}