import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartsoilai/widgets/buttons.dart';

import '../../controllers/auth_controller.dart';
import '../../widgets/input.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleBack() {
    Get.back();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authController = Get.find<AuthController>();
      await authController.login(
        _emailController.text,
        _passwordController.text,
      );

      if (authController.isAuthenticated) {
        Get.offNamed('/main-navigation');
      }
    } catch (error) {
      // Error handling is done in the controller
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _handleSocialLogin(String provider) {
    Get.snackbar('Social Login', '$provider login will be implemented soon.');
  }

  void _handleForgotPassword() {
    Get.toNamed('/forgot-password');
  }

  void _handleSignUp() {
    Get.toNamed('/signup');
  }

  @override
  Widget build(BuildContext context) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final EdgeInsets safeAreaInsets = mediaQuery.padding;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAF8),
      body: Column(
        children: [
          // Header with back button and logo
          Container(
            padding: EdgeInsets.only(
              top: safeAreaInsets.top + 16,
              left: 20,
              right: 20,
              bottom: 16,
            ),
            decoration: const BoxDecoration(
              color: Color(0xFFFAFAF8),
             
            ),
            child: Row(
              children: [
                // Back button
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: _handleBack,
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: const BoxDecoration(
                          color: Color(0xFFE3F8CF),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.chevron_left,
                          color: Color(0xFF435C5C),
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
                // Logo
                Image.asset('assets/images/icon.png', width: 56, height: 56),
              ],
            ),
          ),

          // Content
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title Section
                    const Padding(
                      padding: EdgeInsets.fromLTRB(20, 20, 20, 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Login',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1F1F1F),
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Sign in to monitor your soil conditions and make smarter decisions.',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF83888D),
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Login Form
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            // Email Input
                            CustomFormField(
                              label: 'Your Email Address',
                              hintText: 'example@email.com',
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your email';
                                }
                                if (!GetUtils.isEmail(value)) {
                                  return 'Please enter a valid email';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),

                            // Password Field
                            CustomFormField(
                              label: 'Password',
                              hintText: 'Enter your password',
                              isPassword: true,
                              controller: _passwordController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your password';
                                }
                                if (value.length < 6) {
                                  return 'Password must be at least 6 characters';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),

                            // Forgot Password
                            Align(
                              alignment: Alignment.centerRight,
                              child: GestureDetector(
                                onTap: _handleForgotPassword,
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8),
                                  child: Text(
                                    'Forgot Password?',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFFEF4444),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            PrimaryButton(
                              title: "Login",
                              onPressed: _isLoading ? null : _handleLogin,
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),

                    // Divider
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: Color(0xFFE8EBF0),
                              thickness: 1,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'Or Sign Up With',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF83888D),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: Color(0xFFE8EBF0),
                              thickness: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Social Login Buttons
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          _buildSocialButton(
                            title: 'Log in with Google',
                            imagePath: 'assets/images/google.png',
                            onPressed: () => _handleSocialLogin('Google'),
                          ),
                          const SizedBox(height: 16),
                          _buildSocialButton(
                            title: 'Log In with Facebook',
                            imagePath: 'assets/images/facebook.png',
                            onPressed: () => _handleSocialLogin('Facebook'),
                          ),
                        ],
                      ),
                    ),

                    // Sign Up Link
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 32,
                      ),
                      child: Center(
                        child: GestureDetector(
                          onTap: _handleSignUp,
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: const TextSpan(
                              text: 'Do not have an account? ',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF83888D),
                              ),
                              children: [
                                TextSpan(
                                  text: 'Sign Up',
                                  style: TextStyle(
                                    color: Color(0xFF62BE24),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton({
    required String title,
    required String imagePath,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF1F1F1F),
          elevation: 0,
          side: const BorderSide(color: Color(0xFFE8EBF0), width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(imagePath, width: 24, height: 24),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
