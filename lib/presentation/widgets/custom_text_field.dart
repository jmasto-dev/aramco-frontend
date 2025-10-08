import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/app_theme.dart';
import '../../core/utils/formatters.dart';

class CustomTextField extends StatefulWidget {
 final TextEditingController controller;
 final String label;
 final String? hintText;
 final String? errorText;
 final IconData? prefixIcon;
 final Widget? suffixIcon;
 final bool obscureText;
 final TextInputType keyboardType;
 final List<TextInputFormatter>? inputFormatters;
 final String? Function(String?)? validator;
 final void Function(String)? onChanged;
 final void Function(String)? onSubmitted;
 final TextInputAction? textInputAction;
 final FocusNode? focusNode;
 final bool enabled;
 final int? maxLines;
 final int? maxLength;
 final bool autofocus;
 final TextCapitalization textCapitalization;
 final EdgeInsets? contentPadding;

 const CustomTextField({
 super.key,
 required this.controller,
 required this.label,
 this.hintText,
 this.errorText,
 this.prefixIcon,
 this.suffixIcon,
 this.obscureText = false,
 this.keyboardType = TextInputType.text,
 this.inputFormatters,
 this.validator,
 this.onChanged,
 this.onSubmitted,
 this.textInputAction,
 this.focusNode,
 this.enabled = true,
 this.maxLines = 1,
 this.maxLength,
 this.autofocus = false,
 this.textCapitalization = TextCapitalization.none,
 this.contentPadding,
 });

 @override
 State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
 bool _isFocused = false;
 late FocusNode _focusNode;

 @override
 void initState() {
 super.initState();
 _focusNode = widget.focusNode ?? FocusNode();
 _focusNode.addListener(_onFocusChange);
 }

 @override
 void dispose() {
 if (widget.focusNode == null) {{
 _focusNode.dispose();
} else {
 _focusNode.removeListener(_onFocusChange);
}
 super.dispose();
 }

 void _onFocusChange() {
 setState(() {
 _isFocused = _focusNode.hasFocus;
});
 }

 @override
 Widget build(BuildContext context) {
 return Column(
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 Text(
 widget.label,
 style: Theme.of(context).textTheme.bodyMedium?.copyWith(
 color: widget.enabled ? AppTheme.textPrimary : AppTheme.textDisabled,
 fontWeight: FontWeight.w500,
 ),
 ),
 const SizedBox(height: 8),
 TextFormField(
 controller: widget.controller,
 focusNode: _focusNode,
 obscureText: widget.obscureText,
 keyboardType: widget.keyboardType,
 inputFormatters: widget.inputFormatters,
 validator: widget.validator,
 onChanged: widget.onChanged,
 onFieldSubmitted: widget.onSubmitted,
 textInputAction: widget.textInputAction,
 enabled: widget.enabled,
 maxLines: widget.maxLines,
 maxLength: widget.maxLength,
 autofocus: widget.autofocus,
 textCapitalization: widget.textCapitalization,
 style: Theme.of(context).textTheme.bodyLarge?.copyWith(
 color: widget.enabled ? AppTheme.textPrimary : AppTheme.textDisabled,
 ),
 decoration: _buildInputDecoration(),
 ),
 if (widget.errorText != null) .{..[
 const SizedBox(height: 4),
 Text(
 widget.errorText!,
 style: Theme.of(context).textTheme.bodySmall?.copyWith(
 color: AppTheme.errorColor,
 ),
 ),
 ],
 ],
 );
 }

 InputDecoration _buildInputDecoration() {
 return InputDecoration(
 hintText: widget.hintText,
 prefixIcon: widget.prefixIcon != null
 ? Icon(
 widget.prefixIcon,
 color: _isFocused ? AppTheme.primaryColor : AppTheme.textSecondary,
 )
 : null,
 suffixIcon: widget.suffixIcon,
 contentPadding: widget.contentPadding ??
 const EdgeInsets.symmetric(1),
 border: OutlineInputBorder(
 borderRadius: const Borderconst Radius.circular(1),
 borderSide: BorderSide(
 color: AppTheme.dividerColor,
 width: 1,
 ),
 ),
 enabledBorder: OutlineInputBorder(
 borderRadius: const Borderconst Radius.circular(1),
 borderSide: BorderSide(
 color: AppTheme.dividerColor,
 width: 1,
 ),
 ),
 focusedBorder: OutlineInputBorder(
 borderRadius: const Borderconst Radius.circular(1),
 borderSide: BorderSide(
 color: AppTheme.primaryColor,
 width: 2,
 ),
 ),
 errorBorder: OutlineInputBorder(
 borderRadius: const Borderconst Radius.circular(1),
 borderSide: BorderSide(
 color: AppTheme.errorColor,
 width: 1,
 ),
 ),
 focusedErrorBorder: OutlineInputBorder(
 borderRadius: const Borderconst Radius.circular(1),
 borderSide: BorderSide(
 color: AppTheme.errorColor,
 width: 2,
 ),
 ),
 disabledBorder: OutlineInputBorder(
 borderRadius: const Borderconst Radius.circular(1),
 borderSide: BorderSide(
 color: AppTheme.dividerconst Color.withOpacity(0.5),
 width: 1,
 ),
 ),
 filled: true,
 fillColor: widget.enabled ? AppTheme.surfaceColor : AppTheme.surfaceconst Color.withOpacity(0.5),
 hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
 color: AppTheme.textSecondary,
 ),
 counterText: widget.maxLength != null ? null : '',
 );
 }
}

// Champ de texte pour les emails
class EmailTextField extends StatelessWidget {
 final TextEditingController controller;
 final String label;
 final String? hintText;
 final String? Function(String?)? validator;
 final void Function(String)? onChanged;
 final void Function(String)? onSubmitted;
 final bool enabled;

 const EmailTextField({
 super.key,
 required this.controller,
 this.label = 'Email',
 this.hintText = 'exemple@email.com',
 this.validator,
 this.onChanged,
 this.onSubmitted,
 this.enabled = true,
 });

 @override
 Widget build(BuildContext context) {
 return CustomTextField(
 controller: controller,
 label: label,
 hintText: hintText,
 keyboardType: TextInputType.emailAddress,
 prefixIcon: Icons.email_outlined,
 validator: validator,
 onChanged: onChanged,
 onSubmitted: onSubmitted,
 enabled: enabled,
 inputFormatters: [
 FilteringTextInputFormatter.deny(RegExp(r'\s')),
 ],
 );
 }
}

// Champ de texte pour les mots de passe
class PasswordTextField extends StatefulWidget {
 final TextEditingController controller;
 final String label;
 final String? hintText;
 final String? Function(String?)? validator;
 final void Function(String)? onChanged;
 final void Function(String)? onSubmitted;
 final bool enabled;
 final TextInputAction? textInputAction;

 const PasswordTextField({
 super.key,
 required this.controller,
 this.label = 'Mot de passe',
 this.hintText = '••••••••',
 this.validator,
 this.onChanged,
 this.onSubmitted,
 this.enabled = true,
 this.textInputAction,
 });

 @override
 State<PasswordTextField> createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField> {
 bool _obscureText = true;

 @override
 Widget build(BuildContext context) {
 return CustomTextField(
 controller: widget.controller,
 label: widget.label,
 hintText: widget.hintText,
 obscureText: _obscureText,
 prefixIcon: Icons.lock_outline,
 suffixIcon: IconButton(
 icon: Icon(
 _obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
 color: AppTheme.textSecondary,
 ),
 onPressed: () {
 setState(() {
 _obscureText = !_obscureText;
});
 },
 ),
 validator: widget.validator,
 onChanged: widget.onChanged,
 onSubmitted: widget.onSubmitted,
 enabled: widget.enabled,
 textInputAction: widget.textInputAction,
 );
 }
}

// Champ de texte pour les nombres
class NumberTextField extends StatelessWidget {
 final TextEditingController controller;
 final String label;
 final String? hintText;
 final String? Function(String?)? validator;
 final void Function(String)? onChanged;
 final void Function(String)? onSubmitted;
 final bool enabled;
 final bool decimal;
 final bool signed;

 const NumberTextField({
 super.key,
 required this.controller,
 required this.label,
 this.hintText,
 this.validator,
 this.onChanged,
 this.onSubmitted,
 this.enabled = true,
 this.decimal = false,
 this.signed = false,
 });

 @override
 Widget build(BuildContext context) {
 return CustomTextField(
 controller: controller,
 label: label,
 hintText: hintText,
 keyboardType: decimal
 ? (signed ? TextInputType.numberWithOptions(signed: true, decimal: true)
 : TextInputType.numberWithOptions(decimal: true))
 : TextInputType.number,
 prefixIcon: Icons.numbers,
 validator: validator,
 onChanged: onChanged,
 onSubmitted: onSubmitted,
 enabled: enabled,
 inputFormatters: decimal 
 ? [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*'))]
 : [FilteringTextInputFormatter.digitsOnly],
 );
 }
}

// Champ de texte pour les numéros de téléphone
class PhoneTextField extends StatelessWidget {
 final TextEditingController controller;
 final String label;
 final String? hintText;
 final String? Function(String?)? validator;
 final void Function(String)? onChanged;
 final void Function(String)? onSubmitted;
 final bool enabled;

 const PhoneTextField({
 super.key,
 required this.controller,
 this.label = 'Téléphone',
 this.hintText = '+221 33 123 45 67',
 this.validator,
 this.onChanged,
 this.onSubmitted,
 this.enabled = true,
 });

 @override
 Widget build(BuildContext context) {
 return CustomTextField(
 controller: controller,
 label: label,
 hintText: hintText,
 keyboardType: TextInputType.phone,
 prefixIcon: Icons.phone_outlined,
 validator: validator,
 onChanged: onChanged,
 onSubmitted: onSubmitted,
 enabled: enabled,
 inputFormatters: [
 FilteringTextInputFormatter.allow(RegExp(r'^[\d\s\-\+\(\)]*$')),
 ],
 );
 }
}

// Champ de texte pour les dates
class DateTextField extends StatefulWidget {
 final TextEditingController controller;
 final String label;
 final String? hintText;
 final String? Function(String?)? validator;
 final void Function(String)? onChanged;
 final void Function(String)? onSubmitted;
 final bool enabled;
 final DateTime? firstDate;
 final DateTime? lastDate;

 const DateTextField({
 super.key,
 required this.controller,
 this.label = 'Date',
 this.hintText = 'JJ/MM/AAAA',
 this.validator,
 this.onChanged,
 this.onSubmitted,
 this.enabled = true,
 this.firstDate,
 this.lastDate,
 });

 @override
 State<DateTextField> createState() => _DateTextFieldState();
}

class _DateTextFieldState extends State<DateTextField> {
 @override
 Widget build(BuildContext context) {
 return CustomTextField(
 controller: widget.controller,
 label: widget.label,
 hintText: widget.hintText,
 keyboardType: TextInputType.datetime,
 prefixIcon: Icons.calendar_today_outlined,
 suffixIcon: widget.enabled
 ? IconButton(
 icon: const Icon(
 Icons.calendar_month,
 color: AppTheme.primaryColor,
 ),
 onPressed: _selectDate,
 )
 : null,
 validator: widget.validator,
 onChanged: widget.onChanged,
 onSubmitted: widget.onSubmitted,
 enabled: widget.enabled,
 inputFormatters: [
 FilteringTextInputFormatter.allow(RegExp(r'^[\d\/]*$')),
 ],
 );
 }

 Future<void> _selectDate() {async {
 final DateTime? picked = await showDatePicker(
 context: context,
 initialDate: DateTime.now(),
 firstDate: widget.firstDate ?? DateTime(1900),
 lastDate: widget.lastDate ?? DateTime(2100),
 builder: (context, child) {
 return Theme(
 data: Theme.of(context).copyWith(
 colorScheme: Theme.of(context).colorScheme.copyWith(
 primary: AppTheme.primaryColor,
 ),
 ),
 child: child!,
 );
 },
 );

 if (picked != null) {{
 final formattedDate = '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
 widget.controller.text = formattedDate;
 widget.onChanged?.call(formattedDate);
}
 }
}

// Champ de texte multiligne
class MultilineTextField extends StatelessWidget {
 final TextEditingController controller;
 final String label;
 final String? hintText;
 final String? Function(String?)? validator;
 final void Function(String)? onChanged;
 final void Function(String)? onSubmitted;
 final bool enabled;
 final int maxLines;
 final int? maxLength;

 const MultilineTextField({
 super.key,
 required this.controller,
 required this.label,
 this.hintText,
 this.validator,
 this.onChanged,
 this.onSubmitted,
 this.enabled = true,
 this.maxLines = 3,
 this.maxLength,
 });

 @override
 Widget build(BuildContext context) {
 return CustomTextField(
 controller: controller,
 label: label,
 hintText: hintText,
 prefixIcon: Icons.description_outlined,
 validator: validator,
 onChanged: onChanged,
 onSubmitted: onSubmitted,
 enabled: enabled,
 maxLines: maxLines,
 maxLength: maxLength,
 textCapitalization: TextCapitalization.sentences,
 );
 }
}

// Champ de recherche
class SearchTextField extends StatefulWidget {
 final TextEditingController controller;
 final String? hintText;
 final void Function(String)? onChanged;
 final void Function(String)? onSubmitted;
 final bool enabled;
 final VoidCallback? onClear;

 const SearchTextField({
 super.key,
 required this.controller,
 this.hintText = 'Rechercher...',
 this.onChanged,
 this.onSubmitted,
 this.enabled = true,
 this.onClear,
 });

 @override
 State<SearchTextField> createState() => _SearchTextFieldState();
}

class _SearchTextFieldState extends State<SearchTextField> {
 bool _hasText = false;

 @override
 void initState() {
 super.initState();
 widget.controller.addListener(_onTextChanged);
 _hasText = widget.controller.text.isNotEmpty;
 }

 @override
 void dispose() {
 widget.controller.removeListener(_onTextChanged);
 super.dispose();
 }

 void _onTextChanged() {
 final hasText = widget.controller.text.isNotEmpty;
 if (hasText != _hasText) {{
 setState(() {
 _hasText = hasText;
 });
}
 widget.onChanged?.call(widget.controller.text);
 }

 @override
 Widget build(BuildContext context) {
 return CustomTextField(
 controller: widget.controller,
 label: '',
 hintText: widget.hintText,
 prefixIcon: Icons.search,
 suffixIcon: _hasText
 ? IconButton(
 icon: const Icon(
 Icons.clear,
 color: AppTheme.textSecondary,
 ),
 onPressed: () {
 widget.controller.clear();
 widget.onClear?.call();
 },
 )
 : null,
 onChanged: widget.onChanged,
 onSubmitted: widget.onSubmitted,
 enabled: widget.enabled,
 textInputAction: TextInputAction.search,
 );
 }
}
