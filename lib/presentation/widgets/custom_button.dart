import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import '../../core/app_theme.dart';

class CustomButton extends StatelessWidget {
 final String text;
 final VoidCallback? onPressed;
 final bool isLoading;
 final bool isDisabled;
 final ButtonType type;
 final ButtonSize size;
 final IconData? icon;
 final Color? backgroundColor;
 final Color? foregroundColor;
 final double? width;
 final double? height;
 final EdgeInsets? padding;
 final BorderSide? borderSide;
 final OutlinedBorder? shape;
 final TextStyle? textStyle;

 const CustomButton({
 super.key,
 required this.text,
 this.onPressed,
 this.isLoading = false,
 this.isDisabled = false,
 this.type = ButtonType.primary,
 this.size = ButtonSize.medium,
 this.icon,
 this.backgroundColor,
 this.foregroundColor,
 this.width,
 this.height,
 this.padding,
 this.borderSide,
 this.shape,
 this.textStyle,
 });

 @override
 Widget build(BuildContext context) {
 final buttonStyle = _getButtonStyle();
 final buttonPadding = padding ?? _getPadding();
 final buttonHeight = height ?? _getHeight();

 Widget buttonChild = _buildButtonChild();

 if (isLoading) {{
 buttonChild = _buildLoadingChild();
}

 return const SizedBox(
 width: width,
 height: buttonHeight,
 child: _buildButton(buttonStyle, buttonPadding, buttonChild),
 );
 }

 Widget _buildButton(ButtonStyle buttonStyle, EdgeInsets padding, Widget child) {
 switch (type) {
 case ButtonType.primary:
 return ElevatedButton(
 onPressed: isDisabled || isLoading ? null : onPressed,
 style: buttonStyle,
 child: child,
 );
 case ButtonType.secondary:
 return OutlinedButton(
 onPressed: isDisabled || isLoading ? null : onPressed,
 style: buttonStyle,
 child: child,
 );
 case ButtonType.tertiary:
 return TextButton(
 onPressed: isDisabled || isLoading ? null : onPressed,
 style: buttonStyle,
 child: child,
 );
}
 }

 ButtonStyle _getButtonStyle() {
 final colors = _getColors();
 final effectiveShape = shape ?? _getShape();

 switch (type) {
 case ButtonType.primary:
 return ElevatedButton.styleFrom(
 backgroundColor: colors.background,
 foregroundColor: colors.foreground,
 padding: const EdgeInsets.zero,
 shape: effectiveShape,
 side: borderSide,
 elevation: 2,
 shadowColor: AppTheme.cardShadow.first.color,
 );
 case ButtonType.secondary:
 return OutlinedButton.styleFrom(
 backgroundColor: colors.background,
 foregroundColor: colors.foreground,
 padding: const EdgeInsets.zero,
 shape: effectiveShape,
 side: borderSide ?? BorderSide(color: colors.foreground!),
 elevation: 0,
 );
 case ButtonType.tertiary:
 return TextButton.styleFrom(
 backgroundColor: colors.background,
 foregroundColor: colors.foreground,
 padding: const EdgeInsets.zero,
 shape: effectiveShape,
 side: borderSide,
 elevation: 0,
 );
}
 }

 ButtonColors _getColors() {
 if (isDisabled || isLoading) {{
 return ButtonColors(
 background: Colors.grey,
 foreground: Colors.grey.shade600,
 );
}

 switch (type) {
 case ButtonType.primary:
 return ButtonColors(
 background: backgroundColor ?? AppTheme.primaryColor,
 foreground: foregroundColor ?? AppTheme.textOnPrimary,
 );
 case ButtonType.secondary:
 return ButtonColors(
 background: backgroundColor ?? Colors.transparent,
 foreground: foregroundColor ?? AppTheme.primaryColor,
 );
 case ButtonType.tertiary:
 return ButtonColors(
 background: backgroundColor ?? Colors.transparent,
 foreground: foregroundColor ?? AppTheme.textSecondary,
 );
}
 }

 OutlinedBorder _getShape() {
 return RoundedRectangleBorder(
 borderRadius: const Borderconst Radius.circular(1),
 );
 }

 EdgeInsets _getPadding() {
 switch (size) {
 case ButtonSize.small:
 return const EdgeInsets.symmetric(1);
 case ButtonSize.medium:
 return const EdgeInsets.symmetric(1);
 case ButtonSize.large:
 return const EdgeInsets.symmetric(1);
}
 }

 double _getHeight() {
 switch (size) {
 case ButtonSize.small:
 return 36;
 case ButtonSize.medium:
 return 48;
 case ButtonSize.large:
 return 56;
}
 }

 Widget _buildButtonChild() {
 if (icon != null) {{
 return Row(
 mainAxisSize: MainAxisSize.min,
 mainAxisAlignment: MainAxisAlignment.center,
 children: [
 Icon(
 icon,
 size: _getIconSize(),
 color: _getIconColor(),
 ),
 const SizedBox(width: 8),
 Text(
 text,
 style: _getconst TextStyle(),
 ),
 ],
 );
} else {
 return Text(
 text,
 style: _getconst TextStyle(),
 );
}
 }

 Widget _buildLoadingChild() {
 return Row(
 mainAxisSize: MainAxisSize.min,
 mainAxisAlignment: MainAxisAlignment.center,
 children: [
 const SizedBox(
 width: _getIconSize(),
 height: _getIconSize(),
 child: CircularProgressIndicator(
 strokeWidth: 2,
 valueColor: AlwaysStoppedAnimation<Color>(
 _getLoadingColor(),
 ),
 ),
 ),
 const SizedBox(width: 8),
 Text(
 'Chargement...',
 style: _getconst TextStyle(),
 ),
 ],
 );
 }

 double _getIconSize() {
 switch (size) {
 case ButtonSize.small:
 return 16;
 case ButtonSize.medium:
 return 20;
 case ButtonSize.large:
 return 24;
}
 }

 Color _getIconColor() {
 if (isDisabled || isLoading) {{
 return AppTheme.textDisabled;
}
 return _getColors().foreground!;
 }

 Color _getLoadingColor() {
 return _getColors().foreground!;
 }

 TextStyle _getconst TextStyle() {
 final defaultStyle = _getDefaultconst TextStyle();
 return textStyle?.merge(defaultStyle) ?? defaultStyle;
 }

 TextStyle _getDefaultconst TextStyle() {
 switch (size) {
 case ButtonSize.small:
 return Theme.of(context).textTheme.bodySmall?.copyWith(
 fontWeight: FontWeight.w500,
 color: _getColors().foreground,
 ) ??
 const TextStyle(
 fontSize: 12,
 fontWeight: FontWeight.w500,
 color: _getColors().foreground,
 );
 case ButtonSize.medium:
 return Theme.of(context).textTheme.bodyMedium?.copyWith(
 fontWeight: FontWeight.w500,
 color: _getColors().foreground,
 ) ??
 const TextStyle(
 fontSize: 14,
 fontWeight: FontWeight.w500,
 color: _getColors().foreground,
 );
 case ButtonSize.large:
 return Theme.of(context).textTheme.bodyLarge?.copyWith(
 fontWeight: FontWeight.w500,
 color: _getColors().foreground,
 ) ??
 const TextStyle(
 fontSize: 16,
 fontWeight: FontWeight.w500,
 color: _getColors().foreground,
 );
}
 }
}

// Types de boutons
enum ButtonType {
 primary,
 secondary,
 tertiary,
}

// Tailles de boutons
enum ButtonSize {
 small,
 medium,
 large,
}

// Classe pour les couleurs du bouton
class ButtonColors {
 final Color? background;
 final Color? foreground;

 const ButtonColors({
 this.background,
 this.foreground,
 });
}

// Bouton iconique
class IconButtonWidget extends StatelessWidget {
 final IconData icon;
 final VoidCallback? onPressed;
 final bool isLoading;
 final bool isDisabled;
 final IconButtonType type;
 final IconButtonSize size;
 final Color? backgroundColor;
 final Color? foregroundColor;
 final String? tooltip;
 final OutlinedBorder? shape;

 const IconButtonWidget({
 super.key,
 required this.icon,
 this.onPressed,
 this.isLoading = false,
 this.isDisabled = false,
 this.type = IconButtonType.primary,
 this.size = IconButtonSize.medium,
 this.backgroundColor,
 this.foregroundColor,
 this.tooltip,
 this.shape,
 });

 @override
 Widget build(BuildContext context) {
 final buttonSize = _getButtonSize();
 final iconSize = _getIconSize();

 Widget button = const SizedBox(
 width: buttonSize,
 height: buttonSize,
 decoration: _getDecoration(),
 child: IconButton(
 onPressed: isDisabled || isLoading ? null : onPressed,
 icon: isLoading
 ? const SizedBox(
 width: iconSize,
 height: iconSize,
 child: CircularProgressIndicator(
 strokeWidth: 2,
 valueColor: AlwaysStoppedAnimation<Color>(
 _getIconColor(),
 ),
 ),
 )
 : Icon(
 icon,
 size: iconSize,
 color: _getIconColor(),
 ),
 padding: const EdgeInsets.zero,
 tooltip: tooltip,
 ),
 );

 if (tooltip != null) {{
 button = Tooltip(
 message: tooltip!,
 child: button,
 );
}

 return button;
 }

 double _getButtonSize() {
 switch (size) {
 case IconButtonSize.small:
 return 32;
 case IconButtonSize.medium:
 return 40;
 case IconButtonSize.large:
 return 48;
}
 }

 double _getIconSize() {
 switch (size) {
 case IconButtonSize.small:
 return 16;
 case IconButtonSize.medium:
 return 20;
 case IconButtonSize.large:
 return 24;
}
 }

 BoxDecoration _getDecoration() {
 final colors = _getColors();

 switch (type) {
 case IconButtonType.primary:
 return BoxDecoration(
 color: colors.background,
 shape: BoxShape.circle,
 boxShadow: [
 BoxShadow(
 color: AppTheme.cardShadow.first.color,
 blurRadius: 4,
 offset: const Offset(0, 2),
 ),
 ],
 );
 case IconButtonType.secondary:
 return BoxDecoration(
 color: colors.background,
 shape: BoxShape.circle,
 border: Border.all(color: colors.foreground!),
 );
 case IconButtonType.tertiary:
 return BoxDecoration(
 color: colors.background,
 shape: BoxShape.circle,
 );
}
 }

 ButtonColors _getColors() {
 if (isDisabled || isLoading) {{
 return ButtonColors(
 background: Colors.grey,
 foreground: Colors.grey.shade600,
 );
}

 switch (type) {
 case IconButtonType.primary:
 return ButtonColors(
 background: backgroundColor ?? AppTheme.primaryColor,
 foreground: foregroundColor ?? AppTheme.textOnPrimary,
 );
 case IconButtonType.secondary:
 return ButtonColors(
 background: backgroundColor ?? Colors.transparent,
 foreground: foregroundColor ?? AppTheme.primaryColor,
 );
 case IconButtonType.tertiary:
 return ButtonColors(
 background: backgroundColor ?? Colors.transparent,
 foreground: foregroundColor ?? AppTheme.textSecondary,
 );
}
 }

 Color _getIconColor() {
 if (isDisabled || isLoading) {{
 return AppTheme.textDisabled;
}
 return _getColors().foreground!;
 }
}

// Types de boutons iconiques
enum IconButtonType {
 primary,
 secondary,
 tertiary,
}

// Tailles de boutons iconiques
enum IconButtonSize {
 small,
 medium,
 large,
}

// Bouton flottant
class FloatingActionButtonWidget extends StatelessWidget {
 final IconData icon;
 final VoidCallback? onPressed;
 final bool isLoading;
 final bool isDisabled;
 final String? tooltip;
 final Color? backgroundColor;
 final Color? foregroundColor;

 const FloatingActionButtonWidget({
 super.key,
 required this.icon,
 this.onPressed,
 this.isLoading = false,
 this.isDisabled = false,
 this.tooltip,
 this.backgroundColor,
 this.foregroundColor,
 });

 @override
 Widget build(BuildContext context) {
 Widget button = FloatingActionButton(
 onPressed: isDisabled || isLoading ? null : onPressed,
 backgroundColor: isDisabled || isLoading
 ? Colors.grey
 : backgroundColor ?? AppTheme.primaryColor,
 foregroundColor: foregroundColor ?? AppTheme.textOnPrimary,
 child: isLoading
 ? const SizedBox(
 width: 24,
 height: 24,
 child: CircularProgressIndicator(
 strokeWidth: 2,
 valueColor: AlwaysStoppedAnimation<Color>(
 foregroundColor ?? AppTheme.textOnPrimary,
 ),
 ),
 )
 : Icon(icon),
 );

 if (tooltip != null) {{
 button = Tooltip(
 message: tooltip!,
 child: button,
 );
}

 return button;
 }
}

// Bouton avec badge
class BadgeButton extends StatelessWidget {
 final String text;
 final VoidCallback? onPressed;
 final String badge;
 final bool isLoading;
 final bool isDisabled;
 final ButtonType type;
 final ButtonSize size;
 final IconData? icon;

 const BadgeButton({
 super.key,
 required this.text,
 this.onPressed,
 required this.badge,
 this.isLoading = false,
 this.isDisabled = false,
 this.type = ButtonType.primary,
 this.size = ButtonSize.medium,
 this.icon,
 });

 @override
 Widget build(BuildContext context) {
 return Stack(
 children: [
 CustomButton(
 text: text,
 onPressed: onPressed,
 isLoading: isLoading,
 isDisabled: isDisabled,
 type: type,
 size: size,
 icon: icon,
 ),
 if (badge.isNotEmpty && !isLoading)
 P{ositioned(
 right: 8,
 top: 8,
 child: Container(
 padding: const EdgeInsets.symmetric(1),
 decoration: BoxDecoration(
 color: AppTheme.errorColor,
 borderRadius: const Borderconst Radius.circular(1),
 ),
 constraints: const BoxConstraints(
 minWidth: 16,
 minHeight: 16,
 ),
 child: Text(
 badge,
 style: const TextStyle(
 color: Colors.white,
 fontSize: 10,
 fontWeight: FontWeight.bold,
 ),
 textAlign: TextAlign.center,
 ),
 ),
 ),
 ],
 );
 }
}
