import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_theme.dart';


const Color _goldAccent = Color(0xFFD4AF37);
const Color _matteBlackCanvas = Color(0xFF121212);

class LoginRegisterScreen extends StatefulWidget {
  const LoginRegisterScreen({super.key});

  @override
  State<LoginRegisterScreen> createState() => _LoginRegisterScreenState();
}

class _LoginRegisterScreenState extends State<LoginRegisterScreen> {
  bool _isLogin = true;
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  String _selectedRole = 'student';
  bool _obscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  // ── CLEAR, HUMAN-READABLE ERROR PARSER ──
  String _parseAuthError(String errorRaw) {
    final String err = errorRaw.toLowerCase();
    
    if (err.contains('user-not-found') || err.contains('invalid-credential') || err.contains('wrong-password')) {
      return 'Incorrect email or password.';
    } else if (err.contains('email-already-in-use') || err.contains('already in use')) {
      return 'This email address is already registered.';
    } else if (err.contains('invalid-email')) {
      return 'Please enter a valid email address.';
    } else if (err.contains('network-request-failed') || err.contains('network error')) {
      return 'Network error. Please check your connection.';
    } else if (err.contains('weak-password')) {
      return 'Password must be at least 6 characters long.';
    }
    
    return errorRaw; // Show the raw error message if it doesn't match above rules
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // Dismiss the keyboard immediately upon submission
    FocusScope.of(context).unfocus();

    final auth = context.read<AuthProvider>();
    
    try {
      bool success;
      
      if (_isLogin) {
        success = await auth.login(_emailCtrl.text.trim(), _passwordCtrl.text);
      } else {
        success = await auth.register(
          _emailCtrl.text.trim(),
          _passwordCtrl.text,
          _nameCtrl.text.trim(),
          _selectedRole,
        );
      }

      if (!success && mounted) {
        final friendlyError = _parseAuthError(auth.error ?? 'An unknown error occurred.');
        _showFeedbackSnackBar(friendlyError, isError: true);
      } else if (success && mounted) {
        _showFeedbackSnackBar(_isLogin ? 'Welcome back!' : 'Account created successfully!', isError: false);
      }
      
    } catch (rawError) {
      // 🌟 Safety Net: Catches exceptions bubbling directly out of the provider
      if (mounted) {
        final friendlyError = _parseAuthError(rawError.toString());
        _showFeedbackSnackBar(friendlyError, isError: true);
      }
    }
  }


  Future<void> _handleGoogleSignIn() async {
    final auth = context.read<AuthProvider>();
    try {
      bool success = await auth.signInWithGoogle(); 
      if (success && mounted) {
        _showFeedbackSnackBar('Successfully signed in with Google.', isError: false);
      } else if (!success && mounted) {
        _showFeedbackSnackBar(auth.error ?? 'Google sign-in was cancelled.', isError: true);
      }
    } catch (e) {
      if (mounted) {
        _showFeedbackSnackBar('Google sign-in failed: ${e.toString()}', isError: true);
      }
    }
  }

  void _handleForgotPassword() {
    final emailInput = _emailCtrl.text.trim();
    
    // Quick validation check before opening the sheet
    if (emailInput.isEmpty) {
      _showFeedbackSnackBar('Please enter your email address in the input field first.', isError: true);
      return;
    }

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(emailInput)) {
      _showFeedbackSnackBar('Please enter a valid email address.', isError: true);
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF161616),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(color: Colors.white.withOpacity(0.06), width: 1),
          ),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Pull Handler bar
              Center(
                child: Container(
                  width: 38, height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'PASSWORD RECOVERY',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _goldAccent, letterSpacing: 1.5),
              ),
              const SizedBox(height: 6),
              const Text(
                'Confirm your account recovery destination',
                style: TextStyle(fontSize: 15, color: Colors.white70),
              ),
              const SizedBox(height: 24),

              // Focused Email Recovery Card
              InkWell(
                onTap: () async {
                  Navigator.pop(context); // Close the bottom sheet
                  
                  final auth = context.read<AuthProvider>();
                  bool success = await auth.sendPasswordRecovery(
                    target: emailInput, 
                    isPhoneFlow: false,
                  );
                  
                  if (success && mounted) {
                    _showFeedbackSnackBar(
                      'Reset link transmitted successfully! Check your inbox or spam.', 
                      isError: false,
                    );
                  } else if (mounted) {
                    _showFeedbackSnackBar(auth.error ?? 'Email recovery failed.', isError: true);
                  }
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.02),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _goldAccent.withOpacity(0.05),
                          shape: BoxShape.circle,
                          border: Border.all(color: _goldAccent.withOpacity(0.15)),
                        ),
                        child: const Icon(Icons.alternate_email_rounded, color: _goldAccent, size: 20),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Send Recovery Link', 
                              style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Dispatches a secure reset link to $emailInput', 
                              style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios_rounded, color: _goldAccent.withOpacity(0.6), size: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // UI Helper Widget for the Selection Items
  Widget _buildRecoveryOptionTile({
    required IconData icon, 
    required String title, 
    required String subtitle, 
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.02),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _goldAccent.withOpacity(0.05),
                shape: BoxShape.circle,
                border: Border.all(color: _goldAccent.withOpacity(0.15)),
              ),
              child: Icon(icon, color: _goldAccent, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 3),
                  Text(subtitle, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: Colors.white.withOpacity(0.25), size: 20),
          ],
        ),
      ),
    );
  }


// ── FEEDBACK SNACKBAR BUILDER ──
  void _showFeedbackSnackBar(String msg, {required bool isError}) {

    // 🌟 FIX 2: Flush out any existing or queued snackbars instantly
    ScaffoldMessenger.of(context).clearSnackBars(); 

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError ? Colors.redAccent.withOpacity(0.95) : Colors.green.withOpacity(0.95),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Text(
          msg, 
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration({required String label, required IconData prefix}) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white.withOpacity(0.01),
      labelText: label,
      prefixIcon: Icon(prefix, size: 18, color: Colors.white38),
      labelStyle: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12),
      floatingLabelStyle: const TextStyle(color: _goldAccent, fontWeight: FontWeight.bold, fontSize: 13),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.06)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _goldAccent, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    
    return Scaffold(
      backgroundColor: _matteBlackCanvas,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── LOGO FRAME ─────────────────────────────────────────────
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.02),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withOpacity(0.05)),
                      ),
                      child: Image.asset(
                        'assets/images/Logo/Logo.png',
                        height: 82,
                        width: 82,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.psychology, size: 54, color: _goldAccent);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'WELCOME',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _goldAccent, letterSpacing: 2.0),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'ML Advisor Platform',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: -0.5),
                  ),
                  const SizedBox(height: 36),

                  // ── LOGIN / REGISTER TOGGLE ────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.03),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white.withOpacity(0.06)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _isLogin = true),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: _isLogin ? _goldAccent : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                'Login',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: _isLogin ? _matteBlackCanvas : Colors.white60,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _isLogin = false),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: !_isLogin ? _goldAccent : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                'Register',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: !_isLogin ? _matteBlackCanvas : Colors.white60,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ── INPUT FIELDS CARD ──────────────────────────────────────
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.02),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white.withOpacity(0.06)),
                      ),
                      child: BackdropFilter(
                        filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Column(
                          children: [
                            if (!_isLogin) ...[
                              TextFormField(
                                controller: _nameCtrl,
                                style: const TextStyle(color: Colors.white, fontSize: 14),
                                decoration: _buildInputDecoration(label: 'Full Name', prefix: Icons.person_outline_rounded),
                                validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter your name.' : null,
                              ),
                              const SizedBox(height: 18),
                            ],
                            TextFormField(
                              controller: _emailCtrl,
                              keyboardType: TextInputType.emailAddress,
                              style: const TextStyle(color: Colors.white, fontSize: 14),
                              decoration: _buildInputDecoration(label: 'Email Address', prefix: Icons.alternate_email_rounded),
                              validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter your email.' : null,
                            ),
                            const SizedBox(height: 18),
                            TextFormField(
                              controller: _passwordCtrl,
                              obscureText: _obscure,
                              style: const TextStyle(color: Colors.white, fontSize: 14),
                              decoration: _buildInputDecoration(label: 'Password', prefix: Icons.lock_outline_rounded).copyWith(
                                suffixIcon: IconButton(
                                  icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 18, color: Colors.white38),
                                  onPressed: () => setState(() => _obscure = !_obscure),
                                ),
                              ),
                              validator: (v) => (v == null || v.length < 6) ? 'Password must be at least 6 characters.' : null,
                            ),
                            if (!_isLogin) ...[
                              const SizedBox(height: 18),
                              DropdownButtonFormField<String>(
                                value: _selectedRole,
                                dropdownColor: const Color(0xFF1A1A1A),
                                style: const TextStyle(color: Colors.white, fontSize: 14),
                                decoration: _buildInputDecoration(label: 'Account Role', prefix: Icons.badge_outlined),
                                items: const [
                                  DropdownMenuItem(value: 'student', child: Text('Student')),
                                  DropdownMenuItem(value: 'developer', child: Text('Developer')),
                                ], // ✅ Admin role successfully removed from here
                                onChanged: (v) => setState(() => _selectedRole = v!),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // ── FORGOT PASSWORD LINK ───────────────────────────────────
                  if (_isLogin)
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _handleForgotPassword,
                        style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(50, 30)),
                        child: const Text(
                          'Forgot Password?',
                          style: TextStyle(color: _goldAccent, fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),

                  // ── SUBMIT BUTTON ──────────────────────────────────────────
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _goldAccent,
                        foregroundColor: _matteBlackCanvas,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      onPressed: auth.loading ? null : _submit,
                      child: auth.loading
                          ? const SizedBox(
                              height: 20, width: 20,
                              child: CircularProgressIndicator(color: _matteBlackCanvas, strokeWidth: 2.5),
                            )
                          : Text(
                              _isLogin ? 'LOG IN' : 'CREATE ACCOUNT',
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                            ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // ── GOOGLE DIVIDER ─────────────────────────────────────────
                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.white.withOpacity(0.06), thickness: 1)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'OR CONTINUE WITH',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.25), 
                            fontSize: 11, 
                            letterSpacing: 1.0, 
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Expanded(child: Divider(color: Colors.white.withOpacity(0.06), thickness: 1)),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ── GOOGLE BUTTON ──────────────────────────────────────────
                  SizedBox(
                    height: 52,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: BorderSide(color: Colors.white.withOpacity(0.08)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        backgroundColor: Colors.white.withOpacity(0.01),
                      ),
                      onPressed: auth.loading ? null : _handleGoogleSignIn,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.network(
                            'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/24px-Google_%22G%22_logo.svg.png',
                            height: 18,
                            width: 18,
                            errorBuilder: (context, error, stackTrace) => const Icon(Icons.g_mobiledata_rounded, color: Colors.white),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Sign in with Google',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 0.2),
                          ),
                        ],
                      ),
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