import 'package:flutter/material.dart';
import 'package:back2u/models/user_model.dart';
import 'package:back2u/services/auth_kyc_service.dart';
import 'package:back2u/views/settings/profile/edit_profile_page.dart';
import 'package:back2u/views/settings/profile/phone_management_page.dart';
import 'package:intl/intl.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthKycService _authService = AuthKycService();
  AppUser? _appUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() => _isLoading = true);
    try {
      final userId = _authService.currentUser?.uid;
      if (userId != null) {
        _appUser = await _authService.getUserProfile(userId);
      }
    } catch (e) {
      // Handle error
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
          backgroundColor: colors.primary,
          foregroundColor: colors.onPrimary,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_appUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
          backgroundColor: colors.primary,
          foregroundColor: colors.onPrimary,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person_off, size: 64, color: colors.onSurfaceVariant),
              const SizedBox(height: 16),
              Text(
                'No profile found',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Please sign in to view your profile',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditProfilePage(
                    appUser: _appUser,
                    onProfileUpdated: _loadUserProfile,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadUserProfile,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Profile Header
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: colors.primary.withOpacity(0.1),
                    backgroundImage: _appUser!.profileImageUrl != null
                        ? NetworkImage(_appUser!.profileImageUrl!)
                        : null,
                    child: _appUser!.profileImageUrl == null
                        ? Icon(
                            Icons.person,
                            size: 60,
                            color: colors.primary,
                          )
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _appUser!.username,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _appUser!.email,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: _appUser!.verified 
                          ? Colors.green.withOpacity(0.1)
                          : Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _appUser!.verified 
                            ? Colors.green.withOpacity(0.3)
                            : Colors.orange.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _appUser!.verified ? Icons.verified : Icons.pending,
                          size: 16,
                          color: _appUser!.verified ? Colors.green : Colors.orange,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _appUser!.verified ? 'Verified' : 'Pending Verification',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: _appUser!.verified ? Colors.green : Colors.orange,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Profile Information
            _buildInfoSection(
              title: 'Account Information',
              children: [
                _buildInfoTile(
                  icon: Icons.person_outline,
                  title: 'Username',
                  value: _appUser!.username,
                ),
                _buildInfoTile(
                  icon: Icons.email_outlined,
                  title: 'Email',
                  value: _appUser!.email,
                ),
                _buildInfoTile(
                  icon: Icons.phone_outlined,
                  title: 'Phone Number',
                  value: _appUser!.phone ?? 'Not set',
                  trailing: _appUser!.phone != null
                      ? Icon(
                          _appUser!.verified ? Icons.verified : Icons.cancel_outlined,
                          color: _appUser!.verified ? Colors.green : colors.onSurfaceVariant,
                          size: 16,
                        )
                      : null,
                ),
                if (_appUser!.whatsappNumber != null)
                  _buildInfoTile(
                    icon: Icons.phone,
                    title: 'WhatsApp',
                    value: _appUser!.whatsappNumber!,
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Account Details
            _buildInfoSection(
              title: 'Account Details',
              children: [
                _buildInfoTile(
                  icon: Icons.calendar_today_outlined,
                  title: 'Joined',
                  value: DateFormat('MMM dd, yyyy').format(_appUser!.createdAt.toDate()),
                ),
                _buildInfoTile(
                  icon: Icons.update_outlined,
                  title: 'Last Updated',
                  value: DateFormat('MMM dd, yyyy').format(_appUser!.updatedAt.toDate()),
                ),
                _buildInfoTile(
                  icon: Icons.bookmark_outline,
                  title: 'Saved Reports',
                  value: '${_appUser!.savedReports.length}',
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Action Buttons
            _buildActionButton(
              icon: Icons.edit_outlined,
              title: 'Edit Profile',
              subtitle: 'Update your personal information',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditProfilePage(
                      appUser: _appUser,
                      onProfileUpdated: _loadUserProfile,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            _buildActionButton(
              icon: Icons.phone_outlined,
              title: 'Manage Phone',
              subtitle: 'Update or verify your phone number',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PhoneManagementPage(
                      appUser: _appUser,
                      onPhoneUpdated: _loadUserProfile,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection({
    required String title,
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colors.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String value,
    Widget? trailing,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return ListTile(
      leading: Icon(icon, color: colors.onSurfaceVariant, size: 20),
      title: Text(
        title,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: colors.onSurfaceVariant,
        ),
      ),
      subtitle: Text(
        value,
        style: theme.textTheme.bodyLarge,
      ),
      trailing: trailing,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colors.outline.withOpacity(0.2),
        ),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: colors.primary, size: 20),
        ),
        title: Text(title, style: theme.textTheme.bodyLarge),
        subtitle: Text(
          subtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: colors.onSurfaceVariant,
        ),
        onTap: onTap,
      ),
    );
  }
} 