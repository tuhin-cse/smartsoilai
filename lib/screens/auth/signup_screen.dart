import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartsoilai/widgets/buttons.dart';

import '../../controllers/auth_controller.dart';
import '../../widgets/input.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _verificationCodeController = TextEditingController();

  String _selectedGender = '';
  bool _isLoading = false;
  bool _showVerificationCode = false;
  bool _isCodeSent = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _verificationCodeController.dispose();
    super.dispose();
  }

  void _handleBack() {
    Get.back();
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authController = Get.find<AuthController>();

      // Send verification code first if not sent
      if (!_isCodeSent) {
        await authController.signup(
          _emailController.text,
          _passwordController.text,
          _fullNameController.text,
          gender: _selectedGender,
        );
        
        setState(() {
          _showVerificationCode = true;
          _isCodeSent = true;
        });
      } else {
        // Verify code and complete signup
        if (_verificationCodeController.text.length != 6) {
          Get.snackbar('Error', 'Please enter the 6-digit verification code');
          return;
        }

        await authController.verifySignupOtp(
          _emailController.text,
          _verificationCodeController.text,
        );

        if (authController.isAuthenticated) {
          Get.offNamed('/main-navigation');
        } else {
          Get.snackbar(
            'Signup Failed',
            'Unable to verify account. Please try again.',
          );
        }
      }
    } catch (error) {
      // Error handling is done in the controller
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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

  void _handleSocialSignup(String provider) {
    Get.snackbar('Social Signup', '$provider signup will be implemented soon.');
  }

  void _handleLogin() {
    Get.toNamed('/login');
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
                            'Sign Up',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1F1F1F),
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Create your account to start monitoring your soil and making smarter agricultural decisions.',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF83888D),
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Signup Form
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            // Full Name Input
                            CustomFormField(
                              label: 'Full Name',
                              hintText: 'Enter your full name',
                              controller: _fullNameController,
                              keyboardType: TextInputType.name,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your full name';
                                }
                                if (value.trim().split(' ').length < 2) {
                                  return 'Please enter your first and last name';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),

                            // Email Input
                            CustomFormField(
                              label: 'Email Address',
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

                            // Gender Selection
                            CustomFormPickerField<String>(
                              label: 'Gender',
                              hintText: 'Select your gender',
                              options: const [
                                PickerOption(
                                  value: 'Male',
                                  label: 'Male',
                                  icon: Icon(
                                    Icons.male,
                                    color: Color(0xFF62BE24),
                                    size: 20,
                                  ),
                                ),
                                PickerOption(
                                  value: 'Female',
                                  label: 'Female',
                                  icon: Icon(
                                    Icons.female,
                                    color: Color(0xFF62BE24),
                                    size: 20,
                                  ),
                                ),
                                PickerOption(
                                  value: 'Other',
                                  label: 'Other',
                                  icon: Icon(
                                    Icons.person,
                                    color: Color(0xFF62BE24),
                                    size: 20,
                                  ),
                                ),
                              ],
                              initialValue: _selectedGender.isEmpty
                                  ? null
                                  : _selectedGender,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please select your gender';
                                }
                                return null;
                              },
                              onChanged: (value) {
                                setState(() {
                                  _selectedGender = value ?? '';
                                });
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

                            // Confirm Password Field
                            CustomFormField(
                              label: 'Confirm Password',
                              hintText: 'Re-enter your password',
                              isPassword: true,
                              controller: _confirmPasswordController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please confirm your password';
                                }
                                if (value != _passwordController.text) {
                                  return 'Passwords do not match';
                                }
                                return null;
                              },
                            ),

                            // Verification Code Field (shown after initial signup attempt)
                            if (_showVerificationCode) ...[
                              const SizedBox(height: 20),
                              CustomFormField(
                                label: 'Verification Code',
                                hintText: 'Enter 6-digit code',
                                controller: _verificationCodeController,
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter the verification code';
                                  }
                                  if (value.length != 6) {
                                    return 'Verification code must be 6 digits';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),
                              Align(
                                alignment: Alignment.centerRight,
                                child: GestureDetector(
                                  onTap: _resendVerificationCode,
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 8),
                                    child: Text(
                                      'Resend Code',
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

                            const SizedBox(height: 40),

                            PrimaryButton(
                              title: _showVerificationCode
                                  ? "Verify & Sign Up"
                                  : "Send Verification Code",
                              onPressed: _isLoading ? null : _handleSignup,
                            ),
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),

                    // Divider (only show if not in verification mode)
                    if (!_showVerificationCode) ...[
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

                      // Social Signup Buttons
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            _buildSocialButton(
                              title: 'Sign up with Google',
                              imagePath: 'assets/images/google.png',
                              onPressed: () => _handleSocialSignup('Google'),
                            ),
                            const SizedBox(height: 16),
                            _buildSocialButton(
                              title: 'Sign up with Facebook',
                              imagePath: 'assets/images/facebook.png',
                              onPressed: () => _handleSocialSignup('Facebook'),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Login Link
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 32,
                      ),
                      child: Center(
                        child: GestureDetector(
                          onTap: _handleLogin,
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: const TextSpan(
                              text: 'Already have an account? ',
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
