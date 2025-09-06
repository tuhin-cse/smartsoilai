import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartsoilai/widgets/buttons.dart';
import 'package:pinput/pinput.dart';
import 'package:smartsoilai/widgets/loader.dart';
import 'dart:async';

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
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _isEmailValid = false;
  bool _showPasswordForm = false;
  String _verifiedOtp = ''; // Store the verified OTP

  // Track which fields have been touched for individual validation
  final Set<String> _touchedFields = {};

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_onEmailChanged);
  }

  @override
  void dispose() {
    _emailController.removeListener(_onEmailChanged);
    _emailController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onEmailChanged() {
    final email = _emailController.text;
    final isValid = email.isNotEmpty && GetUtils.isEmail(email);
    if (_isEmailValid != isValid) {
      setState(() {
        _isEmailValid = isValid;
      });
    }
  }

  void _onFieldInteraction(String fieldName) {
    setState(() {
      _touchedFields.add(fieldName);
    });
    // Trigger validation to show/hide errors for this field
    _formKey.currentState?.validate();
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

      // Show OTP dialog instead of form
      if (mounted) {
        _showOtpDialog();
      }
    } catch (error) {
      // Error handling is done in the controller
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showOtpDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => _OtpDialog(
            email: _emailController.text,
            onResendOtp: _resendVerificationCode,
            onOtpVerified: (otp) => _onOtpVerified(otp),
          ),
    );
  }

  void _onOtpVerified(String otp) {
    setState(() {
      _verifiedOtp = otp;
      _showPasswordForm = true;
    });
  }

  Future<void> _resendVerificationCode() async {
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

  Future<void> _handleResetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authController = Get.find<AuthController>();
      await authController.resetPassword(
        _emailController.text,
        _verifiedOtp,
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
                          autovalidateMode: AutovalidateMode.disabled,
                          child: Column(
                            children: [
                              // Show different content based on state
                              if (!_showPasswordForm) ...[
                                // Email Input (visible when not in password reset mode)
                                CustomFormField(
                                  label: 'Email Address',
                                  hintText: 'example@email.com',
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  onChanged:
                                      (value) => _onFieldInteraction('email'),
                                  validator: (value) {
                                    // Only validate if this field has been touched
                                    if (!_touchedFields.contains('email'))
                                      return null;
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your email';
                                    }
                                    if (!GetUtils.isEmail(value)) {
                                      return 'Please enter a valid email';
                                    }
                                    return null;
                                  },
                                ),
                              ],

                              // Password Fields (shown after OTP verification)
                              if (_showPasswordForm) ...[
                                CustomFormField(
                                  label: 'New Password',
                                  hintText: 'Enter new password',
                                  isPassword: true,
                                  controller: _newPasswordController,
                                  onChanged:
                                      (value) =>
                                          _onFieldInteraction('newPassword'),
                                  validator: (value) {
                                    // Only validate if this field has been touched
                                    if (!_touchedFields.contains('newPassword'))
                                      return null;
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your password';
                                    }
                                    if (value.length < 8) {
                                      return 'Password must be at least 8 characters';
                                    }
                                    if (!RegExp(
                                      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)',
                                    ).hasMatch(value)) {
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
                                  onChanged:
                                      (value) => _onFieldInteraction(
                                        'confirmPassword',
                                      ),
                                  validator: (value) {
                                    // Only validate if this field has been touched
                                    if (!_touchedFields.contains(
                                      'confirmPassword',
                                    ))
                                      return null;
                                    if (value == null || value.isEmpty) {
                                      return 'Please confirm your password';
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
                                title:
                                    _showPasswordForm
                                        ? 'Reset Password'
                                        : 'Send OTP',
                                onPressed:
                                    _isLoading
                                        ? null
                                        : _showPasswordForm
                                        ? _handleResetPassword
                                        : (_isEmailValid
                                            ? _handleSendOtp
                                            : null),
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
      ),
    );
  }

  String _getSubtitle() {
    if (_showPasswordForm) {
      return 'Enter your new password to complete the reset process.';
    } else {
      return 'Enter your email address and we\'ll send you an OTP code to reset your password.';
    }
  }
}

class _OtpDialog extends StatefulWidget {
  final String email;
  final VoidCallback onResendOtp;
  final Function(String) onOtpVerified;

  const _OtpDialog({
    required this.email,
    required this.onResendOtp,
    required this.onOtpVerified,
  });

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
      // For forgot password, we just verify the OTP format
      // The actual verification will happen when resetting password
      if (mounted) {
        Navigator.of(context).pop(); // Close dialog
        widget.onOtpVerified(otp); // Trigger password form with OTP
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
                        Icons.lock_reset,
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
                  'Verify Reset Code',
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
