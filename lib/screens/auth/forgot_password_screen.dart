import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartsoilai/widgets/buttons.dart';

import '../../controllers/auth_controller.dart';
import '../../widgets/input.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _isLoading = false;
  bool _showOtpForm = false;
  bool _showPasswordForm = false;

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleBack() {
    Get.back();
  }

  Future<void> _handleSendOtp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authController = Get.find<AuthController>();
      await authController.forgotPassword(_emailController.text);
      
      setState(() {
        _showOtpForm = true;
      });
    } catch (error) {
      // Error handling is done in the controller
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleVerifyOtp() async {
    if (_otpController.text.length != 6) {
      Get.snackbar('Error', 'Please enter the 6-digit OTP code');
      return;
    }

    setState(() {
      _showPasswordForm = true;
    });
  }

  Future<void> _handleResetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authController = Get.find<AuthController>();
      await authController.resetPassword(
        _emailController.text,
        _otpController.text,
        _newPasswordController.text,
      );
      
      // Navigate back to login
      Get.offNamed('/login');
    } catch (error) {
      // Error handling is done in the controller
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleResendOtp() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authController = Get.find<AuthController>();
      await authController.forgotPassword(_emailController.text);
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

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F8),
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
              color: Color(0xFFF9F9F8),
              boxShadow: [
                BoxShadow(
                  color: Color(0x40A6A9B7),
                  blurRadius: 80,
                  offset: Offset(0, 8),
                ),
              ],
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
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Forgot Password',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1F1F1F),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _getSubtitle(),
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color(0xFF83888D),
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Form
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            // Email Input (always visible)
                            CustomFormField(
                              label: 'Email Address',
                              hintText: 'example@email.com',
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              enabled: !_showOtpForm,
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

                            // OTP Input (shown after email is sent)
                            if (_showOtpForm) ...[
                              const SizedBox(height: 20),
                              CustomFormField(
                                label: 'OTP Code',
                                hintText: 'Enter 6-digit code',
                                controller: _otpController,
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter the OTP code';
                                  }
                                  if (value.length != 6) {
                                    return 'OTP code must be 6 digits';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),
                              Align(
                                alignment: Alignment.centerRight,
                                child: GestureDetector(
                                  onTap: _handleResendOtp,
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 8),
                                    child: Text(
                                      'Resend OTP',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF62BE24),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],

                            // Password Fields (shown after OTP verification)
                            if (_showPasswordForm) ...[
                              const SizedBox(height: 20),
                              CustomFormField(
                                label: 'New Password',
                                hintText: 'Enter new password',
                                isPassword: true,
                                controller: _newPasswordController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a new password';
                                  }
                                  if (value.length < 8) {
                                    return 'Password must be at least 8 characters';
                                  }
                                  if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(value)) {
                                    return 'Password must contain uppercase, lowercase and number';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),
                              CustomFormField(
                                label: 'Confirm New Password',
                                hintText: 'Re-enter new password',
                                isPassword: true,
                                controller: _confirmPasswordController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please confirm your new password';
                                  }
                                  if (value != _newPasswordController.text) {
                                    return 'Passwords do not match';
                                  }
                                  return null;
                                },
                              ),
                            ],

                            const SizedBox(height: 40),

                            PrimaryButton(
                              title: _getButtonTitle(),
                              onPressed: _isLoading ? null : _getButtonHandler(),
                            ),
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),

                    // Back to Login Link
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 32,
                      ),
                      child: Center(
                        child: GestureDetector(
                          onTap: () => Get.toNamed('/login'),
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: const TextSpan(
                              text: 'Remember your password? ',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF83888D),
                              ),
                              children: [
                                TextSpan(
                                  text: 'Log In',
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
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getSubtitle() {
    if (_showPasswordForm) {
      return 'Enter your new password to complete the reset process.';
    } else if (_showOtpForm) {
      return 'We\'ve sent a 6-digit OTP code to your email. Enter it below to verify your identity.';
    } else {
      return 'Enter your email address and we\'ll send you an OTP code to reset your password.';
    }
  }

  String _getButtonTitle() {
    if (_showPasswordForm) {
      return 'Reset Password';
    } else if (_showOtpForm) {
      return 'Verify OTP';
    } else {
      return 'Send OTP';
    }
  }

  VoidCallback _getButtonHandler() {
    if (_showPasswordForm) {
      return _handleResetPassword;
    } else if (_showOtpForm) {
      return _handleVerifyOtp;
    } else {
      return _handleSendOtp;
    }
  }
}
