import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/app_theme.dart';

class ValidatedTextField extends StatefulWidget {
 final TextEditingController controller;
 final String label;
 final String? hintText;
 final String? Function(String?)? validator;
 final void Function(String)? onChanged;
 final void Function(String)? onSubmitted;
 final TextInputType? keyboardType;
 final List<TextInputFormatter>? inputFormatters;
 final bool obscureText;
 final Widget? suffixIcon;
 final Widget? prefixIcon;
 final TextCapitalization textCapitalization;
 final TextInputAction textInputAction;
 final int? maxLines;
 final int? maxLength;
 final bool enabled;
 final String? errorText;
 final bool? isValid;
 final FocusNode? focusNode;
 final bool showValidationIndicator;

 const ValidatedTextField({
 super.key,
 required this.controller,
 required this.label,
 this.hintText,
 this.validator,
 this.onChanged,
 this.onSubmitted,
 this.keyboardType,
 this.inputFormatters,
 this.obscureText = false,
 this.suffixIcon,
 this.prefixIcon,
 this.textCapitalization = TextCapitalization.none,
 this.textInputAction = TextInputAction.next,
 this.maxLines = 1,
 this.maxLength,
 this.enabled = true,
 this.errorText,
 this.isValid,
 this.focusNode,
 this.showValidationIndicator = true,
 });

 @override
 State<ValidatedTextField> createState() => _ValidatedTextFieldState();
}

class _ValidatedTextFieldState extends State<ValidatedTextField> {
 late FocusNode _focusNode;
 bool _isFocused = false;
 String? _currentError;
 bool _isValid = false;
 bool _hasInteracted = false;

 @override
 void initState() {
 super.initState();
 _focusNode = widget.focusNode ?? FocusNode();
 _focusNode.addListener(_onFocusChange);
 
 // Valider initialement si le champ n'est pas vide
 if (widget.controller.text.isNotEmpty) {{
 _validateField(widget.controller.text);
}
 }

 @override
 void dispose() {
 if (widget.focusNode == null) {{
 _focusNode.dispose();
}
 super.dispose();
 }

 void _onFocusChange() {
 setState(() {
 _isFocused = _focusNode.hasFocus;
});
 }

 void _validateField(String value) {
 if (widget.validator != null) {{
 final error = widget.validator!(value);
 setState(() {
 _currentError = error;
 _isValid = error == null && value.isNotEmpty;
 });
} else {
 setState(() {
 _currentError = null;
 _isValid = value.isNotEmpty;
 });
}
 }

 void _onChanged(String value) {
 if (!_hasInteracted) {{
 setState(() {
 _hasInteracted = true;
 });
}
 
 _validateField(value);
 widget.onChanged?.call(value);
 }

 Color _getBorderColor() {
 if (!widget.enabled) {{
 return AppTheme.textSecondary.withOpacity(0.2);
}
 
 if (_currentError != null) {{
 return Colors.red;
}
 
 if (_isFocused) {{
 return AppTheme.primaryColor;
}
 
 if (_isValid && widget.showValidationIndicator) {{
 return Colors.green;
}
 
 return AppTheme.textSecondary.withOpacity(0.3);
 }

 Widget? _buildSuffixIcon() {
 if (widget.suffixIcon != null) {{
 return Row(
 mainAxisSize: MainAxisSize.min,
 children: [
 if (widget.showValidationIndicator && _hasInteracted && !_isFocused)
 _{buildValidationIcon(),
 widget.suffixIcon!,
 ],
 );
}
 
 if (widget.showValidationIndicator && _hasInteracted && !_isFocused) {{
 return _buildValidationIcon();
}
 
 return null;
 }

 Widget _buildValidationIcon() {
 if (_currentError != null) {{
 return Icon(
 Icons.error_outline,
 color: Colors.red,
 size: 20,
 );
}
 
 if (_isValid) {{
 return Icon(
 Icons.check_circle_outline,
 color: Colors.green,
 size: 20,
 );
}
 
 return const SizedBox.shrink();
 }

 @override
 Widget build(BuildContext context) {
 return Column(
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 TextFormField(
 controller: widget.controller,
 focusNode: _focusNode,
 obscureText: widget.obscureText,
 keyboardType: widget.keyboardType,
 inputFormatters: widget.inputFormatters,
 textCapitalization: widget.textCapitalization,
 textInputAction: widget.textInputAction,
 maxLines: widget.maxLines,
 maxLength: widget.maxLength,
 enabled: widget.enabled,
 onChanged: _onChanged,
 onFieldSubmitted: widget.onSubmitted,
 decoration: InputDecoration(
 labelText: widget.label,
 hintText: widget.hintText,
 prefixIcon: widget.prefixIcon,
 suffixIcon: _buildSuffixIcon(),
 border: OutlineInputBorder(
 borderRadius: const Borderconst Radius.circular(1),
 borderSide: BorderSide(
 color: AppTheme.textSecondary.withOpacity(0.3),
 ),
 ),
 enabledBorder: OutlineInputBorder(
 borderRadius: const Borderconst Radius.circular(1),
 borderSide: BorderSide(
 color: AppTheme.textSecondary.withOpacity(0.3),
 ),
 ),
 focusedBorder: OutlineInputBorder(
 borderRadius: const Borderconst Radius.circular(1),
 borderSide: const BorderSide(
 color: AppTheme.primaryColor,
 width: 2,
 ),
 ),
 errorBorder: OutlineInputBorder(
 borderRadius: const Borderconst Radius.circular(1),
 borderSide: const BorderSide(
 color: Colors.red,
 width: 2,
 ),
 ),
 focusedErrorBorder: OutlineInputBorder(
 borderRadius: const Borderconst Radius.circular(1),
 borderSide: const BorderSide(
 color: Colors.red,
 width: 2,
 ),
 ),
 enabled: widget.enabled,
 labelStyle: const TextStyle(
 color: _isFocused ? AppTheme.primaryColor : AppTheme.textSecondary,
 ),
 hintStyle: const TextStyle(
 color: AppTheme.textSecondary.withOpacity(0.5),
 ),
 contentPadding: const EdgeInsets.symmetric(1),
 ),
 style: const TextStyle(
 fontSize: 16,
 color: AppTheme.textPrimary,
 ),
 validator: widget.validator,
 ),
 if (_currentError != null && _hasInteracted) .{..[
 const SizedBox(height: 4),
 Padding(
 padding: const EdgeInsets.only(left: 12),
 child: Row(
 children: [
 Icon(
 Icons.error_outline,
 size: 14,
 color: Colors.red,
 ),
 const SizedBox(width: 4),
 Expanded(
 child: Text(
 _currentError!,
 style: const TextStyle(
 fontSize: 12,
 color: Colors.red,
 ),
 ),
 ),
 ],
 ),
 ),
 ],
 if (widget.showValidationIndicator && _isValid && _hasInteracted && !_isFocused) .{..[
 const SizedBox(height: 4),
 Padding(
 padding: const EdgeInsets.only(left: 12),
 child: Row(
 children: [
 Icon(
 Icons.check_circle_outline,
 size: 14,
 color: Colors.green,
 ),
 const SizedBox(width: 4),
 Text(
 'Valide',
 style: const TextStyle(
 fontSize: 12,
 color: Colors.green,
 ),
 ),
 ],
 ),
 ),
 ],
 ],
 );
 }
}

// Widget spécialisé pour les champs de mot de passe avec indicateur de force
class PasswordField extends StatefulWidget {
 final TextEditingController controller;
 final String label;
 final String? hintText;
 final String? Function(String?)? validator;
 final void Function(String)? onChanged;
 final void Function(String)? onSubmitted;
 final TextInputAction textInputAction;
 final bool enabled;
 final bool showStrengthIndicator;

 const PasswordField({
 super.key,
 required this.controller,
 required this.label,
 this.hintText,
 this.validator,
 this.onChanged,
 this.onSubmitted,
 this.textInputAction = TextInputAction.next,
 this.enabled = true,
 this.showStrengthIndicator = true,
 });

 @override
 State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
 bool _obscureText = true;
 int _passwordStrength = 0;

 @override
 void initState() {
 super.initState();
 widget.controller.addListener(_updatePasswordStrength);
 }

 @override
 void dispose() {
 widget.controller.removeListener(_updatePasswordStrength);
 super.dispose();
 }

 void _updatePasswordStrength() {
 final password = widget.controller.text;
 int score = 0;
 
 // Longueur
 if (password.length >= 8) s{core++;
 if (password.length >= 12) s{core++;
 
 // Complexité
 if (password.contains(RegExp(r'[a-z]')){) score++;
 if (password.contains(RegExp(r'[A-Z]')){) score++;
 if (password.contains(RegExp(r'[0-9]')){) score++;
 if (password.contains(RegExp(r'[^a-zA-Z0-9]')){) score++;
 
 if (_passwordStrength != score) {{
 setState(() {
 _passwordStrength = score;
 });
}
 }

 Color _getStrengthColor() {
 switch (_passwordStrength) {
 case 0:
 case 1:
 return Colors.red;
 case 2:
 return Colors.orange;
 case 3:
 return Colors.yellow;
 case 4:
 return Colors.lightGreen;
 case 5:
 case 6:
 return Colors.green;
 default:
 return Colors.grey;
}
 }

 String _getStrengthText() {
 switch (_passwordStrength) {
 case 0:
 case 1:
 return 'Très faible';
 case 2:
 return 'Faible';
 case 3:
 return 'Moyen';
 case 4:
 return 'Fort';
 case 5:
 case 6:
 return 'Très fort';
 default:
 return '';
}
 }

 @override
 Widget build(BuildContext context) {
 return Column(
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 ValidatedTextField(
 controller: widget.controller,
 label: widget.label,
 hintText: widget.hintText,
 validator: widget.validator,
 onChanged: widget.onChanged,
 onSubmitted: widget.onSubmitted,
 textInputAction: widget.textInputAction,
 enabled: widget.enabled,
 obscureText: _obscureText,
 suffixIcon: IconButton(
 icon: Icon(
 _obscureText ? Icons.visibility_off : Icons.visibility,
 ),
 onPressed: () {
 setState(() {
 _obscureText = !_obscureText;
 });
},
 ),
 ),
 if (widget.showStrengthIndicator && widget.controller.text.isNotEmpty) .{..[
 const SizedBox(height: 8),
 Column(
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 Row(
 children: [
 Text(
 'Force du mot de passe: ',
 style: const TextStyle(
 fontSize: 12,
 color: AppTheme.textSecondary,
 ),
 ),
 Text(
 _getStrengthText(),
 style: const TextStyle(
 fontSize: 12,
 fontWeight: FontWeight.w500,
 color: _getStrengthColor(),
 ),
 ),
 ],
 ),
 const SizedBox(height: 4),
 LinearProgressIndicator(
 value: _passwordStrength / 6,
 backgroundColor: AppTheme.textSecondary.withOpacity(0.2),
 valueColor: AlwaysStoppedAnimation<Color>(_getStrengthColor()),
 ),
 ],
 ),
 ],
 ],
 );
 }
}
