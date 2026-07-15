import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_theme_colors.dart';
import '../../dashboard/screens/dashboard_screen.dart';
import '../services/auth_service.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.onToggleTheme});

  final VoidCallback onToggleTheme;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _userIdController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorText;

  @override
  void dispose() {
    _userIdController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final userId = _userIdController.text.trim();
    final password = _passwordController.text;

    if (userId.isEmpty || password.isEmpty) {
      setState(() => _errorText = 'Please fill in both fields.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    final error = await AuthService.instance.login(
      userId: userId,
      password: password,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (error != null) {
      setState(() => _errorText = error);
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => DashboardScreen(onToggleTheme: widget.onToggleTheme),
      ),
    );
  }

  void _goToSignup() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SignupScreen(onToggleTheme: widget.onToggleTheme),
      ),
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
                  'Login to Your Account',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 32),
                _buildLabel('Email', colors),
                const SizedBox(height: 6),
                TextField(
                  controller: _userIdController,
                  style: GoogleFonts.inter(color: colors.textPrimary),
                  decoration: _fieldDecoration(colors),
                ),
                const SizedBox(height: 20),
                _buildLabel('Password', colors),
                const SizedBox(height: 6),
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  style: GoogleFonts.inter(color: colors.textPrimary),
                  decoration: _fieldDecoration(colors).copyWith(
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
                if (_errorText != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _errorText!,
                    style: GoogleFonts.inter(color: Colors.redAccent, fontSize: 13),
                  ),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  height: 48,
                  child: FilledButton(
                    onPressed: _isLoading ? null : _handleLogin,
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
                            'Login',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    // TODO: wire up forgot password flow if required by assignment
                  },
                  child: Text(
                    'Forget User / Password?',
                    style: GoogleFonts.inter(color: colors.textSecondary, fontSize: 13),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: GoogleFonts.inter(color: colors.textSecondary, fontSize: 13),
                    ),
                    GestureDetector(
                      onTap: _goToSignup,
                      child: Text(
                        'Sign Up',
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

  Widget _buildLabel(String text, AppThemeColors colors) {
    return Text(
      text,
      style: GoogleFonts.inter(color: colors.textSecondary, fontSize: 13),
    );
  }

  InputDecoration _fieldDecoration(AppThemeColors colors) {
    return InputDecoration(
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