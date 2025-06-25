import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:back2u/services/auth_kyc_service.dart'; // Import your AuthKycService
import 'package:back2u/utils/app_drawer.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final authService = Provider.of<AuthKycService>(context); // Listen to AuthKycService

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign In'),
        centerTitle: true,
        elevation: 1,
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        leading: IconButton( // Back button
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushNamed(context, '/home'),
        ),
      ),
      // drawer: const AppDrawer(),
      body: authService.isLoadingAuth // Show loading indicator if auth operation is in progress
          ? Center(child: CircularProgressIndicator(color: colors.primary))
          : SafeArea(child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Welcome to Back2U!',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Sign in to access all features, report lost/found items, and connect with the community.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Google Sign-In Button
                  ElevatedButton.icon(
                    onPressed: () async {
                      try {
                        await authService.signInWithGoogle();
                        // If sign-in is successful and page was pushed, pop it.
                        // Check if the current route is not the root or an initial route
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        } else {
                          // If this is the first screen, navigate to home or desired destination
                          Navigator.pushReplacementNamed(context, '/home');
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  'Sign-In failed: ${e.toString().contains('cancelled') ? 'User cancelled' : e.toString()}')),
                        );
                      }
                    },
                    icon: Image.asset('assets/images/google-logo.png', height: 24.0), // Ensure path is correct
                    label: Text(
                      'Sign in with Google',
                      style: theme.textTheme.titleMedium?.copyWith(color: colors.onPrimary),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primary, // Use primary color for main action
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Optional: Anonymous Sign-In Button
                  TextButton(
                    onPressed: () async {
                      try {
                        await authService.signInAnonymously();
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        } else {
                          Navigator.pushReplacementNamed(context, '/home');
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Signed in anonymously')),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Anonymous sign-in failed: $e')),
                        );
                      }
                    },
                    child: Text(
                      'Continue as Guest',
                      style: theme.textTheme.labelLarge?.copyWith(color: colors.primary),
                    ),
                  ),
                ],
              ),
            ),),
    );
  }
}