import 'package:flutter/material.dart';
import '../theme/app_responsive.dart';
import 'app_button.dart';

class GenericFormDialog extends StatefulWidget {
  final String title;
  final String? subtitle;
  final List<Widget> fields;
  final String submitLabel;
  final VoidCallback? onSubmit;
  final bool showAvatars;
  final GlobalKey<FormState>? formKey;

  const GenericFormDialog({
    super.key,
    required this.title,
    this.subtitle,
    required this.fields,
    this.submitLabel = 'Save',
    this.onSubmit,
    this.showAvatars = true,
    this.formKey,
    this.isLoading = false,
  });

  final bool isLoading;

  @override
  State<GenericFormDialog> createState() => _GenericFormDialogState();
}

class _GenericFormDialogState extends State<GenericFormDialog> {
  late final GlobalKey<FormState> _formKey;

  @override
  void initState() {
    super.initState();
    _formKey = widget.formKey ?? GlobalKey<FormState>();
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    // Call submit handler but do not auto-pop the dialog.
    // Callers (onSubmit) should pop when appropriate (especially for async operations).
    widget.onSubmit?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppResponsive.radius(context, 32)),
      ),
      backgroundColor: Colors.white,
      insetPadding: EdgeInsets.all(AppResponsive.p(context, 20)),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(AppResponsive.p(context, 24)),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.showAvatars) ...[
                  // Avatars (overlapping)
                  SizedBox(
                    height: AppResponsive.s(context, 60),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Transform.translate(
                          offset: const Offset(-28, 0),
                          child: CircleAvatar(
                            radius: AppResponsive.s(context, 18),
                            backgroundColor: Colors.brown.shade300,
                            child: const Icon(Icons.person,
                                color: Colors.white, size: 18,),
                          ),
                        ),
                        CircleAvatar(
                          radius: AppResponsive.s(context, 20),
                          backgroundColor: Colors.purple.shade100,
                          child: const Icon(Icons.person,
                              color: Colors.white, size: 20,),
                        ),
                        Transform.translate(
                          offset: const Offset(28, 0),
                          child: CircleAvatar(
                            radius: AppResponsive.s(context, 18),
                            backgroundColor: Colors.brown.shade400,
                            child: const Icon(Icons.person,
                                color: Colors.white, size: 18,),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: AppResponsive.p(context, 16)),
                ],

                // Title
                Text(
                  widget.title,
                  style: TextStyle(
                    fontFamily: 'SFProRounded',
                    fontSize: AppResponsive.font(context, 20),
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                if (widget.subtitle != null) ...[
                  SizedBox(height: AppResponsive.p(context, 8)),
                  Text(
                    widget.subtitle!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'SFProRounded',
                      fontSize: AppResponsive.font(context, 14),
                      color: Colors.grey[600],
                      height: 1.4,
                    ),
                  ),
                ],
                SizedBox(height: AppResponsive.p(context, 24)),

                // Form Fields
                ...widget.fields,
                SizedBox(height: AppResponsive.p(context, 24)),

                // Buttons: Cancel (left) and Submit (right)
                Row(
                  children: [
                    Expanded(
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => Navigator.of(context).pop(),
                          borderRadius: BorderRadius.circular(
                            AppResponsive.p(context, 30),
                          ),
                          child: Container(
                            height: AppResponsive.s(context, 50),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(0, 229, 229, 229),
                              borderRadius: BorderRadius.circular(
                                AppResponsive.p(context, 30),
                              ),
                              border: Border.all(
                                color: const Color(0xFFD5D7DA),
                                width: 1,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                  fontFamily: 'SFProRounded',
                                  color: const Color(0xFF414651),
                                  fontSize: AppResponsive.font(context, 16),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: AppResponsive.p(context, 12)),
                    Expanded(
                      child: AppButton(
                        onPressed: widget.isLoading ? null : _onSave,
                        text:
                            widget.isLoading ? 'Saving...' : widget.submitLabel,
                        isLoading: widget.isLoading,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
