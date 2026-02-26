import 'package:flutter/material.dart';
import 'package:vego/core/providers/auth_provider.dart';
import 'package:vego/core/utils/input_validators.dart';
import 'package:vego/features/auth/screens/otp_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vego/core/theme/app_colors.dart';
import 'package:vego/core/widgets/liquid_wave_background.dart';
import 'package:vego/core/widgets/backgrounds.dart';

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

    final error = InputValidators.validatePhone(phone);
    if (error != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error)),
        );
      }
      return;
    }

    final cleanedPhone = phone.replaceAll(RegExp(r'\s+'), '');

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
    if (emailError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(emailError)),
      );
      return;
    }

    final passwordError = InputValidators.validatePasswordLogin(password);
    if (passwordError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(passwordError)),
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
    if (emailError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(emailError)),
      );
      return;
    }

    final passwordError = InputValidators.validatePassword(password);
    if (passwordError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(passwordError)),
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
      body: LiquidWaveBackground(
        child: SafeArea(
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

                  // Frosted glass form card
                  FrostedGlass(
                    borderRadius: 24,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                                color: _isEmailMode
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
                          ],
                        ),
                        const SizedBox(height: 24),

                        if (!_isEmailMode) ...[
                          // Phone Input
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 4),
                            clipBehavior: Clip.antiAlias,
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
                                hintStyle: TextStyle(
                                    color: context.textSecondary
                                        .withValues(alpha: 0.5)),
                                prefixIcon: Icon(Icons.phone_android,
                                    color: Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.white70
                                        : context.textSecondary),
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
                                  ? const CircularProgressIndicator(
                                      color: Colors.white)
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
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 4),
                            clipBehavior: Clip.antiAlias,
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
                                hintStyle: TextStyle(
                                    color: context.textSecondary
                                        .withValues(alpha: 0.5)),
                                prefixIcon: Icon(Icons.email_outlined,
                                    color: Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.white70
                                        : context.textSecondary),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Password Input
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 4),
                            clipBehavior: Clip.antiAlias,
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
                                hintStyle: TextStyle(
                                    color: context.textSecondary
                                        .withValues(alpha: 0.5)),
                                prefixIcon: Icon(Icons.lock_outline,
                                    color: Colors.white70),
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
                                      side: BorderSide(
                                          color: context.textPrimary
                                              .withValues(alpha: 0.6)),
                                      foregroundColor: context.textPrimary,
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
                                              color: context.textPrimary,
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
