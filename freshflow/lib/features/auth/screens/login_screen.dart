import 'package:flutter/material.dart';
import 'package:vego/core/providers/auth_provider.dart';
import 'package:vego/core/utils/input_validators.dart';
import 'package:vego/features/auth/screens/otp_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vego/core/theme/app_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isEmailMode = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signInPhone() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) return;
    final cleanedPhone = phone.replaceAll(RegExp(r'\s+'), '');

    // Validation
    final error = InputValidators.validatePhone(cleanedPhone);
    if (error != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error)),
        );
      }
      return;
    }

    // Default to +91 if missing
    String formattedPhone = cleanedPhone;
    if (!cleanedPhone.startsWith('+')) {
      formattedPhone = '+91$cleanedPhone';
    }

    try {
      await context.read<AuthProvider>().signInWithPhone(formattedPhone);
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => OtpScreen(phoneNumber: formattedPhone)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _signInEmail() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    final emailError = InputValidators.validateEmail(email);
    final passwordError = InputValidators.validatePasswordLogin(password);

    if (emailError != null || passwordError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(emailError ?? passwordError ?? 'Invalid input')),
      );
      return;
    }

    try {
      await context.read<AuthProvider>().signInWithEmail(email, password);
      // AuthProvider listens to auth state changes, so navigation might be handled by wrapper
      // But for explicit feedback/navigation:
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _signUpEmail() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    final emailError = InputValidators.validateEmail(email);
    final passwordError = InputValidators.validatePassword(password);

    if (emailError != null || passwordError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(emailError ?? passwordError ?? 'Invalid input')),
      );
      return;
    }

    try {
      await context.read<AuthProvider>().signUpWithEmail(email, password);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text('Sign up successful! Please check your email/login.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 48),
                Text(
                  'Welcome to\nVeGo',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: context.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _isEmailMode
                      ? 'Sign in with your email'
                      : 'Enter your phone number to get started',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    color: context.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),

                // Toggle
                Row(
                  children: [
                    ChoiceChip(
                      label: const Text('Phone'),
                      selected: !_isEmailMode,
                      onSelected: (selected) {
                        setState(() => _isEmailMode = !selected);
                      },
                      selectedColor: AppColors.primary,
                      backgroundColor: context.surfaceAltColor,
                      labelStyle: TextStyle(
                        color: !_isEmailMode
                            ? Colors.white
                            : context.textSecondary,
                        fontWeight: FontWeight.bold,
                      ),
                      checkmarkColor: Colors.white,
                      side: BorderSide.none,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ChoiceChip(
                      label: const Text('Email'),
                      selected: _isEmailMode,
                      onSelected: (selected) {
                        setState(() => _isEmailMode = selected);
                      },
                      selectedColor: AppColors.primary,
                      backgroundColor: context.surfaceAltColor,
                      labelStyle: TextStyle(
                        color:
                            _isEmailMode ? Colors.white : context.textSecondary,
                        fontWeight: FontWeight.bold,
                      ),
                      checkmarkColor: Colors.white,
                      side: BorderSide.none,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                if (!_isEmailMode) ...[
                  // Phone Input
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: context.surfaceColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: context.borderColor),
                    ),
                    child: TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: context.textPrimary,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: '+91 98765 43210',
                        hintStyle: TextStyle(color: context.textSecondary),
                        prefixIcon: Icon(Icons.phone_android,
                            color: context.textSecondary),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _signInPhone,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              'Send OTP',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ] else ...[
                  // Email Input
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: context.surfaceColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: context.borderColor),
                    ),
                    child: TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: context.textPrimary,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'john@example.com',
                        hintStyle: TextStyle(color: context.textSecondary),
                        prefixIcon: Icon(Icons.email_outlined,
                            color: context.textSecondary),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Password Input
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: context.surfaceColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: context.borderColor),
                    ),
                    child: TextField(
                      controller: _passwordController,
                      obscureText: true,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: context.textPrimary,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Password',
                        hintStyle: TextStyle(color: context.textSecondary),
                        prefixIcon: Icon(Icons.lock_outline,
                            color: context.textSecondary),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 56,
                          child: OutlinedButton(
                            onPressed: isLoading ? null : _signUpEmail,
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.primary),
                              foregroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: isLoading
                                ? const CircularProgressIndicator()
                                : Text(
                                    'Sign Up',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: SizedBox(
                          height: 56,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : _signInEmail,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white)
                                : Text(
                                    'Sign In',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
