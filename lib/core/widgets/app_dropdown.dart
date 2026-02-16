import 'package:flutter/material.dart';

import '../theme/app_colors_new.dart';
import '../theme/app_responsive.dart';
import 'app_loading.dart';

/// Controller to manage dropdown state globally
/// Ensures only one dropdown is open at a time
class AppDropdownController {
  static _AppDropdownFieldState? _activeDropdown;

  static void register(_AppDropdownFieldState dropdown) {
    // If another dropdown is open, close it first
    if (_activeDropdown != null && _activeDropdown != dropdown) {
      _activeDropdown!._removeOverlayExternally();
    }
    _activeDropdown = dropdown;
  }

  static void unregister(_AppDropdownFieldState dropdown) {
    if (_activeDropdown == dropdown) {
      _activeDropdown = null;
    }
  }

  static void closeActive() {
    _activeDropdown?._removeOverlayExternally();
    _activeDropdown = null;
  }
}

/// A generic overlay-based dropdown that matches the app's design
///
/// Features:
/// - Clean rounded design with white background and black borders
/// - Dynamic height that adjusts to content and available viewport space
/// - Smart positioning (opens downward or upward based on available space)
/// - Automatic scrolling only when content exceeds viewport constraints
/// - Loading state support
/// - Single dropdown open at a time
/// - Matches the light theme styling of the app
class AppDropdown<T> extends StatefulWidget {
  const AppDropdown({
    super.key,
    required this.label,
    required this.items,
    required this.onChanged,
    required this.itemLabel,
    this.value,
    this.hint,
    this.enabled = true,
    this.isLoading = false,
    this.prefixIcon,
    this.validator,
    this.contentPadding,
    this.isRequired = false,
    this.borderRadius,
  });

  /// The label/placeholder text when no value is selected
  final String label;

  /// The currently selected value
  final T? value;

  /// List of available items to select from
  final List<T> items;

  /// Callback when selection changes
  final void Function(T?) onChanged;

  /// Function to get display label for each item
  final String Function(T) itemLabel;

  /// Optional hint text (defaults to label if not provided)
  final String? hint;

  /// Whether the dropdown is enabled
  final bool enabled;

  /// Whether to show loading indicator
  final bool isLoading;

  /// Optional prefix icon
  final IconData? prefixIcon;

  /// Optional validator function
  final String? Function(T?)? validator;

  /// Optional padding for the field content. If not provided, a sensible
  /// default matching other text fields will be used in `build`.
  final EdgeInsets? contentPadding;

  /// Whether this field is required (shows asterisk)
  final bool isRequired;

  /// Optional custom border radius (defaults to 10 if not provided)
  final double? borderRadius;

  @override
  State<AppDropdown<T>> createState() => _AppDropdownFieldState<T>();
}

class _AppDropdownFieldState<T> extends State<AppDropdown<T>> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;
  String? _errorText;

  // Persistent controller for scrolling
  final ScrollController _scrollController = ScrollController();

  // Whether the overlay is displayed below the field (true) or above it (false)
  bool _displayBelow = true;

  // Estimated height per item
  static const double _estimatedItemHeight = 48.0;

  // Padding and spacing constants
  static const double _dropdownPadding = 8.0;
  static const double _maxViewportFraction = 0.5; // Max 50% of screen height

  void _toggleDropdown() {
    if (!widget.enabled || widget.isLoading || widget.items.isEmpty) return;

    if (_isOpen) {
      _removeOverlay();
      AppDropdownController.unregister(this);
      setState(() => _isOpen = false);
    } else {
      AppDropdownController.register(this);
      _showOverlay();
      setState(() => _isOpen = true);
    }
  }

  // Called when another dropdown opens
  void _removeOverlayExternally() {
    if (_isOpen) {
      _removeOverlay();
      setState(() => _isOpen = false);
    }
  }

  void _showOverlay() {
    final overlay = Overlay.of(context);
    final RenderBox? box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;
    final size = box.size;
    final offset = box.localToGlobal(Offset.zero);

    final mq = MediaQuery.of(context);
    final screenHeight = mq.size.height;
    final viewInsetsBottom = mq.viewInsets.bottom; // keyboard
    final paddingTop = mq.padding.top;

    // Calculate available space in viewport
    final availableBelow = screenHeight -
        (offset.dy + size.height) -
        viewInsetsBottom -
        _dropdownPadding;
    final availableAbove = offset.dy - paddingTop - _dropdownPadding;

    // Calculate ideal content height
    final itemCount = widget.items.length;
    final separatorCount = itemCount > 0 ? itemCount - 1 : 0;
    final estimatedContentHeight =
        (itemCount * _estimatedItemHeight) + (separatorCount * 1.0);

    // Smart positioning logic
    if (availableBelow >= estimatedContentHeight) {
      _displayBelow = true;
    } else if (availableAbove >= estimatedContentHeight) {
      _displayBelow = false;
    } else {
      _displayBelow = availableBelow >= availableAbove;
    }

    // Calculate dynamic height
    final maxAllowedHeight = screenHeight * _maxViewportFraction;
    final availableHeight = _displayBelow ? availableBelow : availableAbove;
    final dynamicHeight = estimatedContentHeight
        .clamp(0.0, availableHeight)
        .clamp(0.0, maxAllowedHeight);

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          // Detect outside taps to close dropdown
          Positioned.fill(
            child: GestureDetector(
              onTap: () {
                AppDropdownController.closeActive();
              },
              behavior: HitTestBehavior.translucent,
              child: Container(color: Colors.transparent),
            ),
          ),

          // Position dropdown using CompositedTransformFollower
          CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            offset: Offset.zero,
            targetAnchor:
                _displayBelow ? Alignment.bottomLeft : Alignment.topLeft,
            followerAnchor:
                _displayBelow ? Alignment.topLeft : Alignment.bottomLeft,
            child: SizedBox(
              height: dynamicHeight,
              width: size.width,
              child: Material(
                color: Colors.transparent,
                child: _buildDropdownList(dynamicHeight),
              ),
            ),
          ),
        ],
      ),
    );

    overlay.insert(_overlayEntry!);

    // Auto-scroll to selected item
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      try {
        final selectedIndex = widget.items.indexWhere(
          (item) => item == widget.value,
        );
        if (selectedIndex != -1 && _scrollController.hasClients) {
          final target = (selectedIndex * _estimatedItemHeight).clamp(
            0.0,
            _scrollController.position.maxScrollExtent,
          );
          _scrollController.jumpTo(target);
        }
      } catch (_) {
        // Ignore scrolling errors
      }
    });
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    AppDropdownController.unregister(this);
  }

  void _selectItem(T item) {
    widget.onChanged(item);
    _removeOverlay();
    setState(() {
      _isOpen = false;
      _errorText = widget.validator?.call(item);
    });
  }

  bool validate() {
    if (widget.validator != null) {
      setState(() {
        _errorText = widget.validator!(widget.value);
      });
      return _errorText == null;
    }
    return true;
  }

  @override
  void dispose() {
    AppDropdownController.unregister(this);
    _removeOverlay();
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildDropdownList(double height) {
    // Calculate if content needs scrolling
    final itemCount = widget.items.length;
    final separatorCount = itemCount > 0 ? itemCount - 1 : 0;
    final totalContentHeight =
        (itemCount * _estimatedItemHeight) + (separatorCount * 1.0);

    final needsScrolling = totalContentHeight > height;
    const borderColor = Color(0xFF000000);
    final borderWidth = AppResponsive.thickness(context, 2);
    // Dropdown list always uses radius 10
    final listRadius = AppResponsive.radius(context, 10);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(_displayBelow ? listRadius : 0),
          bottomRight: Radius.circular(_displayBelow ? listRadius : 0),
          topLeft: Radius.circular(!_displayBelow ? listRadius : 0),
          topRight: Radius.circular(!_displayBelow ? listRadius : 0),
        ),
        border: Border.all(color: borderColor, width: borderWidth),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      height: height,
      child: Material(
        color: Colors.transparent,
        child: Scrollbar(
          controller: _scrollController,
          thumbVisibility: needsScrolling,
          child: ListView.separated(
            controller: _scrollController,
            primary: false,
            shrinkWrap: true,
            physics: const ClampingScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: widget.items.length,
            separatorBuilder: (_, __) => Divider(
              color: Colors.grey.shade200,
              thickness: 1,
              height: 1,
            ),
            itemBuilder: (context, i) {
              final item = widget.items[i];
              final isSelected = item == widget.value;

              return InkWell(
                onTap: () => _selectItem(item),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppResponsive.s(context, 12),
                    vertical: AppResponsive.s(context, 12),
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.accentBlue.withOpacity(0.1)
                        : Colors.transparent,
                  ),
                  child: Text(
                    widget.itemLabel(item),
                    style: TextStyle(
                      fontSize: AppResponsive.font(context, 16),
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // When closed: use custom radius, when open: use radius 10
    final radiusValue = _isOpen
        ? AppResponsive.radius(context, 10)
        : AppResponsive.radius(context, widget.borderRadius ?? 10);
    final borderRadius = BorderRadius.circular(radiusValue);
    final borderColor = _errorText != null
        ? AppColors.error
        : widget.enabled
            ? const Color(0xFF000000)
            : const Color(0xFF000000).withOpacity(0.3);
    final borderWidth = AppResponsive.thickness(context, 2);

    // Determine content padding (default to horizontal:24 vertical:12)
    final fieldContentPadding = widget.contentPadding ??
        AppResponsive.padding(context, horizontal: 12, vertical: 13);

    // Loading state
    if (widget.isLoading) {
      return Container(
        padding: fieldContentPadding,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: borderRadius,
          border: Border.all(
            color: borderColor.withOpacity(0.3),
            width: borderWidth,
          ),
        ),
        child: AppLoading.dropdown(
          label: 'Loading ${widget.label}...',
        ),
      );
    }

    // Determine whether to show the floating label (when open or has a value)
    final showFloatingLabel =
        !widget.isLoading && (_isOpen || widget.value != null);

    return CompositedTransformTarget(
      link: _layerLink,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              GestureDetector(
                onTap: _toggleDropdown,
                child: Container(
                  padding: fieldContentPadding,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(
                        _displayBelow
                            ? radiusValue
                            : (_isOpen ? 0 : radiusValue),
                      ),
                      topRight: Radius.circular(
                        _displayBelow
                            ? radiusValue
                            : (_isOpen ? 0 : radiusValue),
                      ),
                      bottomLeft: Radius.circular(
                        _displayBelow
                            ? (_isOpen ? 0 : radiusValue)
                            : radiusValue,
                      ),
                      bottomRight: Radius.circular(
                        _displayBelow
                            ? (_isOpen ? 0 : radiusValue)
                            : radiusValue,
                      ),
                    ),
                    border: Border.all(color: borderColor, width: borderWidth),
                  ),
                  child: Row(
                    children: [
                      if (widget.prefixIcon != null) ...[
                        Icon(
                          widget.prefixIcon,
                          size: AppResponsive.icon(context, 20),
                          color: Colors.black,
                        ),
                        SizedBox(width: AppResponsive.s(context, 12)),
                      ],
                      Expanded(
                        child: Text(
                          widget.value != null
                              ? widget.itemLabel(widget.value as T)
                              : (widget.hint ?? widget.label),
                          style: TextStyle(
                            fontSize: AppResponsive.font(context, 16),
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
                      AnimatedRotation(
                        turns: _isOpen ? 0.5 : 0.0,
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          Icons.keyboard_arrow_down,
                          size: AppResponsive.icon(context, 24),
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Floating label positioned over the top border when needed
              if (showFloatingLabel)
                Positioned(
                  left: AppResponsive.s(context, 12),
                  top: -AppResponsive.s(context, 8),
                  child: Container(
                    padding: AppResponsive.padding(context, horizontal: 4),
                    color: Colors.white,
                    child: RichText(
                      text: TextSpan(
                        text: widget.label,
                        style: TextStyle(
                          fontSize: AppResponsive.font(context, 12),
                          fontWeight: FontWeight.w600,
                          color: _errorText != null
                              ? AppColors.error
                              : const Color(0xFF000000),
                        ),
                        children: widget.isRequired
                            ? [
                                TextSpan(
                                  text: ' *',
                                  style: TextStyle(
                                    color: AppColors.error,
                                    fontSize: AppResponsive.font(context, 12),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ]
                            : null,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          if (_errorText != null)
            Padding(
              padding: EdgeInsets.only(
                left: AppResponsive.p(context, 12),
                top: AppResponsive.p(context, 4),
              ),
              child: Text(
                _errorText!,
                style: TextStyle(
                  color: AppColors.error,
                  fontSize: AppResponsive.font(context, 12),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// A FormField wrapper for AppDropdown that integrates with Form validation
class AppDropdownFormField<T> extends FormField<T> {
  AppDropdownFormField({
    super.key,
    required String label,
    required List<T> items,
    required String Function(T) itemLabel,
    T? value,
    super.validator,
    void Function(T?)? onChanged,
    String? hint,
    super.enabled,
    bool isLoading = false,
    IconData? prefixIcon,
  }) : super(
          initialValue: value,
          builder: (FormFieldState<T> state) {
            return AppDropdown<T>(
              label: label,
              value: state.value,
              items: items,
              onChanged: (newValue) {
                state.didChange(newValue);
                onChanged?.call(newValue);
              },
              itemLabel: itemLabel,
              hint: hint,
              enabled: enabled,
              isLoading: isLoading,
              prefixIcon: prefixIcon,
              validator: validator,
            );
          },
        );
}
