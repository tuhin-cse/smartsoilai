import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

// Export the form picker component
export 'form_picker.dart';

class CustomFormInput extends StatefulWidget {
  final String label;
  final String hintText;
  final IconData? leftIcon;
  final IconData? rightIcon;
  final bool isPassword;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final bool enabled;
  final void Function(String)? onChanged;
  final VoidCallback? onRightIconTap;
  final String? errorText;
  final int maxLines;
  final bool enableInteractiveSelection;
  final void Function(TextSelection, SelectionChangedCause)? onSelectionChanged;

  const CustomFormInput({
    super.key,
    required this.label,
    required this.hintText,
    this.leftIcon,
    this.rightIcon,
    this.isPassword = false,
    this.controller,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.enabled = true,
    this.onChanged,
    this.onRightIconTap,
    this.errorText,
    this.maxLines = 1,
    this.enableInteractiveSelection = true,
    this.onSelectionChanged,
  });

  @override
  State<CustomFormInput> createState() => _CustomFormInputState();
}

class _CustomFormInputState extends State<CustomFormInput> {
  bool _obscureText = true;
  String? _errorMessage;
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label - only show if not empty
        if (widget.label.isNotEmpty) ...[
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color:
                  _isFocused
                      ? const Color(0xFF62BE24) // Green label when focused
                      : AppColors.textPrimary, // Default color when unfocused
              height: 1.5,
            ),
            child: Text(widget.label),
          ),
          const SizedBox(height: 8),
        ],

        // Input Container
        AnimatedScale(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          scale: _isFocused ? 1.02 : 1.0, // Subtle scale up when focused
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200), // Smooth animation
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color:
                    _errorMessage != null
                        ? AppColors.error
                        : _isFocused
                        ? const Color(0xFF62BE24) // Green border when focused
                        : const Color(
                          0xFFE8EBE8,
                        ), // Light gray border from Figma
                width: _isFocused ? 2 : 1, // Thicker border when focused
              ),
              boxShadow:
                  _isFocused
                      ? [
                        BoxShadow(
                          color: const Color(0xFF62BE24).withValues(alpha: 0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ]
                      : null, // Subtle shadow when focused
            ),
            child: TextFormField(
              focusNode: _focusNode,
              controller: widget.controller,
              obscureText: widget.isPassword ? _obscureText : false,
              keyboardType: widget.keyboardType,
              enabled: widget.enabled,
              maxLines: widget.maxLines,
              onChanged: widget.onChanged,
              enableInteractiveSelection: widget.enableInteractiveSelection,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
                height: 1.3,
              ),
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFFA2A8AF), // Gray color from Figma
                  height: 1.3,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                prefixIcon:
                    widget.leftIcon != null
                        ? Padding(
                          padding: const EdgeInsets.only(left: 16, right: 8),
                          child: Icon(
                            widget.leftIcon,
                            size: 20,
                            color: const Color(
                              0xFFA2A8AF,
                            ), // Gray color from Figma
                          ),
                        )
                        : null,
                prefixIconConstraints:
                    widget.leftIcon != null
                        ? const BoxConstraints(minWidth: 44, minHeight: 24)
                        : null,
                suffixIcon: _buildSuffixIcon(),
                suffixIconConstraints:
                    (widget.rightIcon != null || widget.isPassword)
                        ? const BoxConstraints(minWidth: 44, minHeight: 24)
                        : null,
              ),
              validator: (value) {
                final error = widget.validator?.call(value);
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    setState(() {
                      _errorMessage = error;
                    });
                  }
                });
                return null; // Return null to prevent default error styling
              },
            ),
          ),
        ),

        // Error Message
        if (_errorMessage != null || widget.errorText != null) ...[
          const SizedBox(height: 4),
          Text(
            _errorMessage ?? widget.errorText!,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.error,
              height: 1.3,
            ),
          ),
        ],
      ],
    );
  }

  Widget? _buildSuffixIcon() {
    if (widget.isPassword) {
      return Padding(
        padding: const EdgeInsets.only(right: 16),
        child: GestureDetector(
          onTap: _togglePasswordVisibility,
          child: Icon(
            _obscureText ? Icons.visibility_off : Icons.visibility,
            size: 20,
            color: const Color(0xFFA2A8AF), // Gray color from Figma
          ),
        ),
      );
    } else if (widget.rightIcon != null) {
      return Padding(
        padding: const EdgeInsets.only(right: 16),
        child: GestureDetector(
          onTap: widget.onRightIconTap,
          child: Icon(
            widget.rightIcon,
            size: 20,
            color: const Color(0xFFA2A8AF), // Gray color from Figma
          ),
        ),
      );
    }
    return null;
  }
}

// Enhanced version with form field validation integration
/// CustomFormField with animated focus highlighting
///
/// Features:
/// - Smooth animated border color changes
/// - Animated label color transitions
/// - Subtle scale animation when focused
/// - Green highlight with shadow effect
class CustomFormField extends FormField<String> {
  final TextEditingController? controller;

  CustomFormField({
    super.key,
    required String label,
    required String hintText,
    IconData? leftIcon,
    IconData? rightIcon,
    bool isPassword = false,
    this.controller,
    super.validator,
    TextInputType keyboardType = TextInputType.text,
    bool enabled = true,
    void Function(String)? onChanged,
    VoidCallback? onRightIconTap,
    String? initialValue,
    int maxLines = 1,
    bool enableInteractiveSelection = true,
    void Function(TextSelection, SelectionChangedCause)? onSelectionChanged,
  }) : super(
         initialValue: controller?.text ?? initialValue ?? '',
         builder: (FormFieldState<String> state) {
           return CustomFormInput(
             label: label,
             hintText: hintText,
             leftIcon: leftIcon,
             rightIcon: rightIcon,
             isPassword: isPassword,
             controller: controller,
             keyboardType: keyboardType,
             enabled: enabled,
             maxLines: maxLines,
             errorText: state.errorText,
             enableInteractiveSelection: enableInteractiveSelection,
             onSelectionChanged: onSelectionChanged,
             onChanged: (value) {
               state.didChange(value);
               onChanged?.call(value);
             },
             onRightIconTap: onRightIconTap,
             validator: (value) {
               final error = validator?.call(value);
               return error;
             },
           );
         },
       );
}
