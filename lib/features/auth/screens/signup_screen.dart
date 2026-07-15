import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_theme_colors.dart';
import '../services/auth_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key, required this.onToggleTheme});

  final VoidCallback onToggleTheme;

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _agreedToTerms = false;
  bool _isLoading = false;
  String? _errorText;

  final _emailRegex = RegExp(r'^[\w\.\-]+@[\w\-]+\.[\w\.\-]+$');

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      setState(() => _errorText = 'Please fill in all fields.');
      return;
    }
    if (!_emailRegex.hasMatch(email)) {
      setState(() => _errorText = 'Please enter a valid email.');
      return;
    }
    if (password.length < 6) {
      setState(() => _errorText = 'Password must be at least 6 characters.');
      return;
    }
    if (!_agreedToTerms) {
      setState(() => _errorText = 'Please agree to the Terms & Conditions.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    final error = await AuthService.instance.signUp(
      name: name,
      email: email,
      password: password,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (error != null) {
      setState(() => _errorText = error);
      return;
    }

    // Signup successful — go back to Login so the user signs in.
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Account created. Please log in.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Create Your Account',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: _nameController,
                  style: GoogleFonts.inter(color: colors.textPrimary),
                  decoration: _fieldDecoration('Name', colors),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: GoogleFonts.inter(color: colors.textPrimary),
                  decoration: _fieldDecoration('Email', colors),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  style: GoogleFonts.inter(color: colors.textPrimary),
                  decoration: _fieldDecoration('Password', colors).copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: colors.textSecondary,
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Checkbox(
                      value: _agreedToTerms,
                      activeColor: AppColors.primary,
                      onChanged: (value) {
                        setState(() => _agreedToTerms = value ?? false);
                      },
                    ),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: GoogleFonts.inter(color: colors.textSecondary, fontSize: 13),
                          children: [
                            const TextSpan(text: 'I agree with '),
                            TextSpan(
                              text: 'Terms & Conditions',
                              style: GoogleFonts.inter(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                if (_errorText != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _errorText!,
                    style: GoogleFonts.inter(color: Colors.redAccent, fontSize: 13),
                  ),
                ],
                const SizedBox(height: 16),
                SizedBox(
                  height: 48,
                  child: FilledButton(
                    onPressed: _isLoading ? null : _handleSignup,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            'Sign Up',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Have an account? ',
                      style: GoogleFonts.inter(color: colors.textSecondary, fontSize: 13),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Text(
                        'Login',
                        style: GoogleFonts.inter(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _fieldDecoration(String hint, AppThemeColors colors) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.inter(color: colors.textSecondary),
      filled: true,
      fillColor: colors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.primary),
      ),
    );
  }
}