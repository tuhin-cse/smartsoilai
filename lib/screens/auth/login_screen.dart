import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartsoilai/widgets/buttons.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:smartsoilai/widgets/loader.dart';

import '../../controllers/auth_controller.dart';
import '../../widgets/input.dart';
import '../../repositories/api_client.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId:
        '282896781194-qq7iiet92kst597dvsndf2kdjmdvnel2.apps.googleusercontent.com',
    scopes: ['email', 'profile'],
  );
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

  Future<void> _handleSocialLogin() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Sign out first to ensure clean state
      await _googleSignIn.signOut();

      // Sign in with Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // User cancelled the sign-in
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Get authentication details
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Check if we got the required tokens
      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        throw Exception(
          'Failed to get authentication tokens from Google. Please try again.',
        );
      }

      // Create Firebase credential
      final firebase_auth.AuthCredential credential = firebase_auth
          .GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase
      final firebase_auth.UserCredential userCredential = await firebase_auth
          .FirebaseAuth
          .instance
          .signInWithCredential(credential);

      // Get the ID token
      final String? idToken = await userCredential.user?.getIdToken();

      if (idToken != null) {
        // Send to backend API
        await _socialLogin(idToken);
      } else {
        throw Exception('Failed to get ID token from Firebase');
      }
    } catch (error) {
      // Handle error with more specific messages
      String errorMessage = 'Google sign-in failed';

      if (error.toString().contains('network') ||
          error.toString().contains('connection')) {
        errorMessage = 'Network error. Please check your internet connection.';
      } else if (error.toString().contains('cancelled') ||
          error.toString().contains('null')) {
        errorMessage =
            'Sign-in was cancelled or configuration is missing. Please try again.';
      } else if (error.toString().contains('permission') ||
          error.toString().contains('denied')) {
        errorMessage = 'Permission denied. Please check app permissions.';
      } else if (error.toString().contains('platform')) {
        errorMessage =
            'Google Sign-In is not properly configured for this device.';
      }

      Get.snackbar(
        'Error',
        '$errorMessage\nDetails: ${error.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _socialLogin(String idToken) async {
    try {
      final response = await ApiClient.instance.post(
        '/auth/social-login',
        data: {'idToken': idToken},
      );

      if (response.statusCode == 200) {
        // Parse the response data
        final data = response.data;

        // Use AuthController's social login method
        final authController = Get.find<AuthController>();
        await authController.socialLogin(
          data['accessToken'],
          data['refreshToken'],
          data['user'] as Map<String, dynamic>,
        );

        // Navigate to main screen
        Get.offNamed('/main-navigation');
      } else {
        throw Exception('Social login failed');
      }
    } catch (error) {
      rethrow;
    }
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

    return LoaderStack(
      loading: _isLoading,
      child: Scaffold(
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
              decoration: const BoxDecoration(color: Color(0xFFFAFAF8)),
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
                                enableInteractiveSelection: true,
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
                                enableInteractiveSelection:
                                    false, // Disable for password security
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
                              onPressed: _handleSocialLogin,
                            ),
                            // const SizedBox(height: 16),
                            // _buildSocialButton(
                            //   title: 'Log In with Facebook',
                            //   imagePath: 'assets/images/facebook.png',
                            //   onPressed: () => _handleSocialLogin('Facebook'),
                            // ),
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
