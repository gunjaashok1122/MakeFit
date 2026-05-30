import 'package:flutter/material';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../themes/app_theme.dart';
import '../providers/auth_provider.dart';
import '../widgets/glass_card.dart';
import '../widgets/neon_button.dart';
import 'main_navigation_wrapper.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isLogin = true;
  bool _obscurePassword = true;
  String _errorMessage = '';

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _errorMessage = '';
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    bool success = false;

    if (_isLogin) {
      success = await authProvider.login(
        _emailController.text.trim(),
        _passwordController.text,
      );
    } else {
      success = await authProvider.register(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text,
      );
    }

    if (success) {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const MainNavigationWrapper(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      }
    } else {
      setState(() {
        _errorMessage = _isLogin 
            ? 'Invalid email or password (min 6 characters)' 
            : 'Please fill all details correctly';
      });
    }
  }

  void _socialSignIn(String provider) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.loginWithSocial(provider);
    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const MainNavigationWrapper(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.bgGradient,
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),
                    // Welcome Title
                    Text(
                      _isLogin ? 'Welcome Back!' : 'Create Account',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textWhite,
                        fontFamily: 'Outfit',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isLogin ? 'Sign in to continue' : 'Register to start your fitness journey',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.textGrey,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Social buttons
                    Row(
                      children: [
                        Expanded(
                          child: NeonButton(
                            height: 48,
                            borderRadius: 12,
                            gradient: const LinearGradient(
                              colors: [Color(0xFF2E305C), Color(0xFF1C1D3D)],
                            ),
                            shadows: [],
                            onTap: () => _socialSignIn('Google'),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.network(
                                  'https://upload.wikimedia.org/wikipedia/commons/c/c1/Google_%22G%22_logo.svg',
                                  height: 18,
                                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.g_mobiledata, color: AppTheme.textWhite, size: 24),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Google',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textWhite,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: NeonButton(
                            height: 48,
                            borderRadius: 12,
                            gradient: const LinearGradient(
                              colors: [Color(0xFF2E305C), Color(0xFF1C1D3D)],
                            ),
                            shadows: [],
                            onTap: () => _socialSignIn('Apple'),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.apple, color: AppTheme.textWhite, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'Apple',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textWhite,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(child: Divider(color: AppTheme.textMuted.withOpacity(0.3))),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            'or',
                            style: TextStyle(color: AppTheme.textGrey, fontSize: 12),
                          ),
                        ),
                        Expanded(child: Divider(color: AppTheme.textMuted.withOpacity(0.3))),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Inputs Block
                    if (!_isLogin) ...[
                      const Text(
                        'Name',
                        style: TextStyle(color: AppTheme.textWhite, fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 8),
                      GlassCard(
                        padding: EdgeInsets.zero,
                        borderRadius: 12,
                        child: TextFormField(
                          controller: _nameController,
                          style: const TextStyle(color: AppTheme.textWhite),
                          decoration: const InputDecoration(
                            hintText: 'Enter your name',
                            hintStyle: TextStyle(color: AppTheme.textMuted),
                            prefixIcon: Icon(Icons.person_outline, color: AppTheme.textGrey),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                          ),
                          validator: (value) {
                            if (!_isLogin && (value == null || value.trim().isEmpty)) {
                              return 'Please enter your name';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    const Text(
                      'Email',
                      style: TextStyle(color: AppTheme.textWhite, fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    GlassCard(
                      padding: EdgeInsets.zero,
                      borderRadius: 12,
                      child: TextFormField(
                        controller: _emailController,
                        style: const TextStyle(color: AppTheme.textWhite),
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          hintText: 'Enter your email',
                          hintStyle: TextStyle(color: AppTheme.textMuted),
                          prefixIcon: Icon(Icons.email_outlined, color: AppTheme.textGrey),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                        ),
                        validator: (value) {
                          if (value == null || !value.contains('@')) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    const Text(
                      'Password',
                      style: TextStyle(color: AppTheme.textWhite, fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    GlassCard(
                      padding: EdgeInsets.zero,
                      borderRadius: 12,
                      child: TextFormField(
                        controller: _passwordController,
                        style: const TextStyle(color: AppTheme.textWhite),
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          hintText: 'Enter your password',
                          hintStyle: const TextStyle(color: AppTheme.textMuted),
                          prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.textGrey),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              color: AppTheme.textGrey,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                        ),
                        validator: (value) {
                          if (value == null || value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                    ),

                    if (_isLogin) ...[
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Mock reset email sent successfully.'),
                              ),
                            );
                          },
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(color: AppTheme.neonPurple, fontSize: 13, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                    ] else
                      const SizedBox(height: 24),

                    // Display errors
                    if (_errorMessage.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Text(
                          _errorMessage,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppTheme.neonPink, fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],

                    // Sign In / Register Action button
                    authProvider.isLoading
                        ? const Center(
                            child: SpinKitCircle(
                              color: AppTheme.neonPurple,
                              size: 40.0,
                            ),
                          )
                        : NeonButton(
                            onTap: _submitForm,
                            child: Text(
                              _isLogin ? 'Sign In' : 'Sign Up',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textWhite,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ),

                    const SizedBox(height: 24),
                    // Switch login / sign up
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _isLogin ? "Don't have an account? " : "Already have an account? ",
                          style: const TextStyle(color: AppTheme.textGrey, fontSize: 14),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _isLogin = !_isLogin;
                              _errorMessage = '';
                            });
                          },
                          child: Text(
                            _isLogin ? 'Sign Up' : 'Sign In',
                            style: const TextStyle(
                              color: AppTheme.neonPurple,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
