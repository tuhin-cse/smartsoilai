import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class PickerOption<T> {
  final T value;
  final String label;
  final Widget? icon;

  const PickerOption({
    required this.value,
    required this.label,
    this.icon,
  });
}

class CustomFormPicker<T> extends StatefulWidget {
  final String label;
  final String hintText;
  final List<PickerOption<T>> options;
  final T? selectedValue;
  final void Function(T?)? onChanged;
  final String? Function(T?)? validator;
  final bool enabled;
  final String? errorText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;

  const CustomFormPicker({
    super.key,
    required this.label,
    required this.hintText,
    required this.options,
    this.selectedValue,
    this.onChanged,
    this.validator,
    this.enabled = true,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
  });

  @override
  State<CustomFormPicker<T>> createState() => _CustomFormPickerState<T>();
}

class _CustomFormPickerState<T> extends State<CustomFormPicker<T>> {
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Text(
          widget.label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 8),

        // Picker Container
        GestureDetector(
          onTap: widget.enabled ? _showPicker : null,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: widget.enabled ? AppColors.white : const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: _errorMessage != null
                    ? AppColors.error
                    : const Color(0xFFE8EBE8),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                // Prefix Icon
                if (widget.prefixIcon != null) ...[
                  widget.prefixIcon!,
                  const SizedBox(width: 12),
                ],

                // Selected Value or Hint
                Expanded(
                  child: Text(
                    _getDisplayText(),
                    style: TextStyle(
                      fontSize: 16,
                      color: widget.selectedValue != null
                          ? AppColors.textPrimary
                          : const Color(0xFFA2A8AF),
                      height: 1.5,
                    ),
                  ),
                ),

                // Suffix Icon (default dropdown arrow or custom)
                widget.suffixIcon ??
                    Icon(
                      Icons.keyboard_arrow_down,
                      size: 20,
                      color: widget.enabled
                          ? const Color(0xFFA2A8AF)
                          : const Color(0xFFD1D5DB),
                    ),
              ],
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

  String _getDisplayText() {
    if (widget.selectedValue != null) {
      final selectedOption = widget.options.firstWhere(
        (option) => option.value == widget.selectedValue,
        orElse: () => PickerOption(value: widget.selectedValue as T, label: ''),
      );
      return selectedOption.label;
    }
    return widget.hintText;
  }

  void _showPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _PickerBottomSheet<T>(
        title: widget.label,
        options: widget.options,
        selectedValue: widget.selectedValue,
        onSelected: (value) {
          setState(() {
            if (widget.validator != null) {
              _errorMessage = widget.validator!(value);
            }
          });
          widget.onChanged?.call(value);
          Navigator.pop(context);
        },
      ),
    );
  }
}

class _PickerBottomSheet<T> extends StatelessWidget {
  final String title;
  final List<PickerOption<T>> options;
  final T? selectedValue;
  final void Function(T?) onSelected;

  const _PickerBottomSheet({
    required this.title,
    required this.options,
    this.selectedValue,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFE8EBE8),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Select $title',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF5F5F5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 20,
                      color: Color(0xFF83888D),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Options List
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: options.length,
              itemBuilder: (context, index) {
                final option = options[index];
                final isSelected = option.value == selectedValue;

                return InkWell(
                  onTap: () => onSelected(option.value),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFE3F8CF)
                          : Colors.transparent,
                    ),
                    child: Row(
                      children: [
                        // Option Icon
                        if (option.icon != null) ...[
                          option.icon!,
                          const SizedBox(width: 12),
                        ],

                        // Option Label
                        Expanded(
                          child: Text(
                            option.label,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: isSelected
                                  ? const Color(0xFF62BE24)
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ),

                        // Selected Indicator
                        if (isSelected)
                          const Icon(
                            Icons.check,
                            size: 20,
                            color: Color(0xFF62BE24),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Bottom Safe Area
          SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
        ],
      ),
    );
  }
}

// FormField wrapper for form validation
class CustomFormPickerField<T> extends FormField<T> {
  CustomFormPickerField({
    super.key,
    required String label,
    required String hintText,
    required List<PickerOption<T>> options,
    T? initialValue,
    super.validator,
    void Function(T?)? onChanged,
    bool enabled = true,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) : super(
          initialValue: initialValue,
          builder: (FormFieldState<T> state) {
            return CustomFormPicker<T>(
              label: label,
              hintText: hintText,
              options: options,
              selectedValue: state.value,
              enabled: enabled,
              prefixIcon: prefixIcon,
              suffixIcon: suffixIcon,
              errorText: state.errorText,
              onChanged: (value) {
                state.didChange(value);
                onChanged?.call(value);
              },
              validator: (value) {
                final error = validator?.call(value);
                return error;
              },
            );
          },
        );
}
