import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_responsive.dart';

/// Global reusable text field with floating label on border
/// Label appears on the top border of the field when focused or has text
class AppTextFieldWithLabel extends StatefulWidget {
  const AppTextFieldWithLabel({
    super.key,
    required this.controller,
    required this.label,
    this.hintText,
    this.keyboardType,
    this.obscureText = false,
    this.inputFormatters,
    this.validator,
    this.textInputAction,
    this.onFieldSubmitted,
    this.autofillHints,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
    this.readOnly = false,
    this.onTap,
    this.maxLines = 1,
    this.onChanged,
    this.backgroundColor = Colors.white,
    this.borderColor,
    this.focusedBorderColor,
    this.errorBorderColor,
    this.isRequired = false,
    this.maxLength,
    this.counterText,
    this.autofocus = false,
  });

  final TextEditingController controller;
  final String label;
  final String? hintText;
  final TextInputType? keyboardType;
  final bool obscureText;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final TextInputAction? textInputAction;
  final void Function(String)? onFieldSubmitted;
  final Iterable<String>? autofillHints;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool enabled;
  final bool readOnly;
  final VoidCallback? onTap;
  final int maxLines;
  final void Function(String)? onChanged;
  final Color backgroundColor;
  final Color? borderColor;
  final Color? focusedBorderColor;
  final Color? errorBorderColor;
  final bool isRequired;
  final int? maxLength;
  final String? counterText;
  final bool autofocus;

  @override
  State<AppTextFieldWithLabel> createState() => _AppTextFieldWithLabelState();
}

class _AppTextFieldWithLabelState extends State<AppTextFieldWithLabel> {
  late FocusNode _focusNode;
  bool _isFocused = false;
  bool _obscured = true;

  static const Color _hintColor = Color(0xFF9E9E9E);
  static const Color _textColor = Color(0xFF1A1A1A);
  static const Color _defaultBorderColor = Color(0xFF000000);
  static const Color _errorBorderColor = Color(0xFFD32F2F);
  static const Color _requiredAsteriskColor = Color(0xFFD32F2F);

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
    widget.controller.addListener(_onControllerChange);
    _obscured = widget.obscureText;
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    widget.controller.removeListener(_onControllerChange);
    super.dispose();
  }

  void _onControllerChange() {
    setState(() {});
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    final borderRadius = AppResponsive.borderRadius(context, 10);
    final borderWidth = AppResponsive.thickness(context, 2);

    return FormField<String>(
      initialValue: widget.controller.text,
      validator: widget.validator != null
          ? (_) => widget.validator!(widget.controller.text)
          : null,
      builder: (FormFieldState<String> state) {
        final hasError = state.hasError;
        final borderColor = hasError
            ? (widget.errorBorderColor ?? _errorBorderColor)
            : _defaultBorderColor;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Text Field with floating label
            Stack(
              clipBehavior: Clip.none,
              children: [
                // Text Field Container
                Container(
                  decoration: BoxDecoration(
                    color: widget.backgroundColor,
                    borderRadius: borderRadius,
                    border: Border.all(
                      color: borderColor,
                      width: borderWidth,
                    ),
                  ),
                  child: TextFormField(
                    controller: widget.controller,
                    focusNode: _focusNode,
                    autofocus: widget.autofocus,
                    readOnly: widget.readOnly,
                    onTap: widget.onTap,
                    keyboardType: widget.keyboardType,
                    maxLines: widget.obscureText ? 1 : widget.maxLines,
                    minLines: widget.maxLines == 1 ? null : 1,
                    obscureText: widget.obscureText && _obscured,
                    enabled: widget.enabled,
                    inputFormatters: widget.inputFormatters,
                    textInputAction: widget.textInputAction,
                    onFieldSubmitted: widget.onFieldSubmitted,
                    autofillHints: widget.autofillHints,
                    maxLength: widget.maxLength,
                    onChanged: (value) {
                      state.didChange(value);
                      widget.onChanged?.call(value);
                    },
                    cursorColor: _textColor,
                    style: TextStyle(
                      color: _textColor,
                      fontSize: AppResponsive.font(context, 17),
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: InputDecoration(
                      label: (!_isFocused && widget.controller.text.isEmpty)
                          ? _buildLabelWithAsterisk(
                              widget.hintText ?? widget.label,
                              isFloating: false,
                              hasError: false,
                            )
                          : null,
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      hintStyle: TextStyle(
                        color: _hintColor,
                        fontSize: AppResponsive.font(context, 17),
                        fontWeight: FontWeight.w600,
                      ),
                      filled: true,
                      fillColor: widget.backgroundColor,
                      contentPadding: AppResponsive.padding(
                        context,
                        horizontal: 12,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: borderRadius,
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: borderRadius,
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: borderRadius,
                        borderSide: BorderSide.none,
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: borderRadius,
                        borderSide: BorderSide.none,
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: borderRadius,
                        borderSide: BorderSide.none,
                      ),
                      errorStyle: const TextStyle(height: 0, fontSize: 0),
                      prefixIcon: widget.prefixIcon,
                      suffixIcon: _buildSuffixIcon(),
                      counterText: widget.counterText,
                    ),
                  ),
                ),
                // Floating Label on border - visible only when focused or has text
                // For readonly fields we do not show the floating label
                if (!widget.readOnly &&
                    (_isFocused || widget.controller.text.isNotEmpty))
                  Positioned(
                    left: AppResponsive.s(context, 12),
                    top: -AppResponsive.s(context, 8),
                    child: Container(
                      padding: AppResponsive.padding(context, horizontal: 4),
                      color: widget.backgroundColor,
                      child: _buildLabelWithAsterisk(
                        widget.label,
                        isFloating: true,
                        hasError: hasError,
                      ),
                    ),
                  ),
              ],
            ),
            // Error message
            if (hasError && state.errorText != null)
              Padding(
                padding: AppResponsive.padding(
                  context,
                  left: 12,
                  top: 4,
                ),
                child: Text(
                  state.errorText!,
                  style: TextStyle(
                    fontFamily: 'SFProRounded',
                    color: _errorBorderColor,
                    fontSize: AppResponsive.font(context, 12),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  /// Builds a label widget with optional red asterisk for required fields
  Widget _buildLabelWithAsterisk(
    String text, {
    required bool isFloating,
    required bool hasError,
  }) {
    final textStyle = TextStyle(
      color: isFloating
          ? (hasError ? _errorBorderColor : _defaultBorderColor)
          : _defaultBorderColor,
      fontSize: isFloating
          ? AppResponsive.font(context, 12)
          : AppResponsive.font(context, 17),
      fontWeight: isFloating ? FontWeight.w600 : FontWeight.w600,
    );

    if (widget.isRequired) {
      return RichText(
        text: TextSpan(
          text: text,
          style: textStyle,
          children: [
            TextSpan(
              text: ' *',
              style: textStyle.copyWith(
                color: _requiredAsteriskColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return Text(text, style: textStyle);
  }

  Widget? _buildSuffixIcon() {
    // Slight right padding for suffix icons to align visually with the field
    final suffixPad = AppResponsive.padding(context, right: 0);

    if (widget.suffixIcon != null) {
      return Padding(
        padding: suffixPad,
        child: widget.suffixIcon,
      );
    }

    if (widget.obscureText) {
      return GestureDetector(
        onTap: () => setState(() => _obscured = !_obscured),
        child: Padding(
          padding: suffixPad,
          child: Icon(
            _obscured
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            size: AppResponsive.icon(context, 22),
            color: Colors.black,
          ),
        ),
      );
    }

    return null;
  }
}
