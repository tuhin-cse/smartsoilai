
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartsoilai/widgets/buttons.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:smartsoilai/widgets/loader.dart';
import 'package:pinput/pinput.dart';
import 'dart:async';

import '../../controllers/auth_controller.dart';
import '../../repositories/exceptions/api_exception.dart';
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
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);
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
    } on ApiException catch (e) {
      if (e.errorCode == 'EMAIL_NOT_VERIFIED') {
        // Show OTP dialog for email reverification
        if (mounted) {
          final authController = Get.find<AuthController>();
          await authController.resendSignupOtp(_emailController.text);
          _showOtpDialog(_emailController.text);
        }
      }
    } catch (error) {
      // Error handling is done in the controller
      print(error);
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
      print('Google Sign-In Error: $error'); // Debug logging

      // Handle error with more specific messages
      String errorMessage = 'Google sign-in failed';

      if (error.toString().contains('network') ||
          error.toString().contains('connection')) {
        errorMessage = 'Network error. Please check your internet connection.';
      } else if (error.toString().contains('cancelled') ||
          error.toString().contains('SIGN_IN_CANCELLED')) {
        errorMessage = 'Sign-in was cancelled. Please try again.';
      } else if (error.toString().contains('permission') ||
          error.toString().contains('denied')) {
        errorMessage = 'Permission denied. Please check app permissions.';
      } else if (error.toString().contains('platform')) {
        errorMessage =
            'Google Sign-In is not properly configured for this device.';
      } else if (error.toString().contains('User')) {
        errorMessage = 'User data error. Please try again or contact support.';
      }

      Get.snackbar(
        'Login Error',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
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

        // Debug logging
        print('Social login response: $data');

        // Validate required fields
        if (data['accessToken'] == null ||
            data['refreshToken'] == null ||
            data['user'] == null) {
          throw Exception(
            'Invalid response from server. Missing required data.',
          );
        }

        // Use AuthController's social login method
        final authController = Get.find<AuthController>();
        await authController.socialLogin(
          data['accessToken'].toString(),
          data['refreshToken'].toString(),
          data['user'] as Map<String, dynamic>,
        );

        // Navigate to main screen
        Get.offNamed('/main-navigation');
      } else {
        throw Exception(
          'Social login failed with status: ${response.statusCode}',
        );
      }
    } catch (error) {
      print('Social login API error: $error'); // Debug logging

      // Enhanced error handling
      String errorMessage = 'Login failed. Please try again.';

      if (error.toString().contains('network') ||
          error.toString().contains('connection')) {
        errorMessage = 'Network error. Please check your internet connection.';
      } else if (error.toString().contains('timeout')) {
        errorMessage = 'Request timeout. Please try again.';
      } else if (error.toString().contains('500')) {
        errorMessage = 'Server error. Please try again later.';
      } else if (error.toString().contains('401') ||
          error.toString().contains('403')) {
        errorMessage = 'Authentication failed. Please try again.';
      }

      Get.snackbar(
        'Login Failed',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );

      rethrow;
    }
  }

  void _handleForgotPassword() {
    Get.toNamed('/forgot-password');
  }

  void _handleSignUp() {
    Get.toNamed('/signup');
  }

  void _showOtpDialog(String email) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) =>
              _OtpDialog(email: email, onResendOtp: _resendVerificationCode),
    );
  }

  Future<void> _resendVerificationCode() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authController = Get.find<AuthController>();
      await authController.resendSignupOtp(_emailController.text);
    } catch (error) {
      // Error handling is done in the controller
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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

class _OtpDialog extends StatefulWidget {
  final String email;
  final VoidCallback onResendOtp;

  const _OtpDialog({required this.email, required this.onResendOtp});

  @override
  State<_OtpDialog> createState() => _OtpDialogState();
}

class _OtpDialogState extends State<_OtpDialog> {
  final TextEditingController _otpController = TextEditingController();
  bool _isVerifying = false;
  bool _isResending = false;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    // Listen to text changes to cancel pending verification
    _otpController.addListener(() {
      if (_otpController.text.length < 6) {
        _debounceTimer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  void _handleOtpCompleted(String otp) {
    // Cancel any existing timer
    _debounceTimer?.cancel();

    // Set a new timer to debounce rapid successive calls
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _verifyOtp(otp);
    });
  }

  Future<void> _verifyOtp(String otp) async {
    // Prevent multiple simultaneous API calls
    if (otp.length != 6 || _isVerifying) return;

    setState(() {
      _isVerifying = true;
    });

    try {
      final authController = Get.find<AuthController>();

      await authController.verifySignupOtp(widget.email, otp);

      if (mounted && authController.isAuthenticated) {
        Navigator.of(context).pop(); // Close dialog
        Get.offNamed('/main-navigation');
      } else if (mounted) {
        // Clear the input on failure
        _otpController.clear();
      }
    } catch (error) {
      if (mounted) {
        // Clear the input on error
        _otpController.clear();
      }
    } finally {
      if (mounted) {
        setState(() {
          _isVerifying = false;
        });
      }
    }
  }

  Future<void> _handleResendOtp() async {
    setState(() {
      _isResending = true;
    });

    try {
      widget.onResendOtp();
      Get.snackbar(
        'Code Sent',
        'Verification code has been resent to your email.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFF62BE24),
        colorText: Colors.white,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isResending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Responsive sizing
    final dialogWidth = screenWidth > 400 ? 350.0 : screenWidth * 0.9;
    final pinSize = screenWidth > 400 ? 50.0 : (screenWidth * 0.9 - 100) / 6;

    final defaultPinTheme = PinTheme(
      width: pinSize,
      height: pinSize,
      textStyle: TextStyle(
        fontSize: pinSize * 0.4,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF374151),
      ),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFD1D5DB), width: 1.5),
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(color: const Color(0xFF10B981), width: 2),
        color: const Color(0xFFF0FDF4),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        color: const Color(0xFFECFDF5),
        border: Border.all(color: const Color(0xFF10B981), width: 1.5),
      ),
    );

    final errorPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(color: const Color(0xFFF87171), width: 2),
        color: const Color(0xFFFEF2F2),
      ),
    );

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        width: dialogWidth,
        constraints: BoxConstraints(maxHeight: screenHeight * 0.8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with close button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 32), // Balance the close button
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.email_outlined,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.close,
                          size: 18,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Title
                const Text(
                  'Verify Your Email',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),

                // Description
                Text(
                  'Enter the 6-digit code sent to',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  widget.email,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF10B981),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),

                // OTP Input
                Pinput(
                  controller: _otpController,
                  length: 6,
                  defaultPinTheme: defaultPinTheme,
                  focusedPinTheme: focusedPinTheme,
                  submittedPinTheme: submittedPinTheme,
                  errorPinTheme: errorPinTheme,
                  pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
                  showCursor: true,
                  onCompleted: _handleOtpCompleted,
                  enabled: !_isVerifying,
                  hapticFeedbackType: HapticFeedbackType.selectionClick,
                  cursor: Container(
                    width: 2,
                    height: 20,
                    color: const Color(0xFF10B981),
                  ),
                ),
                const SizedBox(height: 20),

                // Loading indicator
                if (_isVerifying)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Column(
                      children: [
                        const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFF10B981),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Verifying...',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Resend section
                if (!_isVerifying) ...[
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Didn\'t receive the code? ',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      GestureDetector(
                        onTap: _isResending ? null : _handleResendOtp,
                        child: Text(
                          _isResending ? 'Sending...' : 'Resend',
                          style: TextStyle(
                            fontSize: 14,
                            color:
                                _isResending
                                    ? Colors.grey[400]
                                    : const Color(0xFF10B981),
                            fontWeight: FontWeight.w600,
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
