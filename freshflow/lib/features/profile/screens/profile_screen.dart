import 'package:flutter/material.dart';
import 'package:freshflow/core/providers/auth_provider.dart';
import 'package:freshflow/core/theme/app_colors.dart';
import 'package:freshflow/core/providers/theme_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock user data
    final user = context.read<AuthProvider>().currentUser;
    final email = user?.email ?? 'user@freshflow.com';
    final phone = user?.phone ?? '+91 98765 43210';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Profile',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 24),
            // Avatar
            const Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: AppColors.secondary,
                backgroundImage:
                    NetworkImage('https://i.pravatar.cc/150?img=12'),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'FreshFlow User',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 32),

            // Details Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildProfileRow(Icons.email_outlined, 'Email', email),
                  const Divider(height: 32),
                  _buildProfileRow(Icons.phone_android, 'Phone', phone),
                  const Divider(height: 32),
                  _buildProfileRow(Icons.location_on_outlined, 'Address',
                      'HSR Layout, Sector 2, Bengaluru'),
                ],
              ),
            ),

            const SizedBox(height: 24),
            // Settings
            const SettingsSection(),

            const Spacer(),

            // Logout Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton(
                onPressed: () {
                  context.read<AuthProvider>().signOut();
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Log Out',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: AppColors.secondary,
              ),
            ),
            Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class SettingsSection extends StatelessWidget {
  const SettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.themeMode == ThemeMode.dark;

    return Column(
      children: [
        SwitchListTile(
          title: Text('Dark Mode',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
          value: isDark,
          onChanged: (val) {
            themeProvider.setThemeMode(val ? ThemeMode.dark : ThemeMode.light);
          },
        ),
        SwitchListTile(
          title: Text('Material You Theme',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
          subtitle: Text('Use dynamic system colors',
              style: GoogleFonts.plusJakartaSans(fontSize: 12)),
          value: themeProvider.isDynamicColorEnabled,
          onChanged: (val) {
            themeProvider.toggleDynamicColor(val);
          },
        ),
      ],
    );
  }
}
