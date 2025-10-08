import 'package:intl/intl.dart';
import 'constants.dart';

class AppFormatters {
 // Formateurs de date et heure
 static final DateFormat _dateFormatter = DateFormat(AppConstants.dateFormat);
 static final DateFormat _timeFormatter = DateFormat(AppConstants.timeFormat);
 static final DateFormat _dateTimeFormatter = DateFormat(AppConstants.dateTimeFormat);
 static final DateFormat _apiDateFormatter = DateFormat(AppConstants.apiDateFormat);
 static final DateFormat _apiDateTimeFormatter = DateFormat(AppConstants.apiDateTimeFormat);

 // Formateur de devise
 static final NumberFormat _currencyFormatter = NumberFormat.currency(
 locale: 'fr_FR',
 symbol: 'FCFA',
 decimalDigits: 0,
 );

 // Formateur de nombre
 static final NumberFormat _numberFormatter = NumberFormat.decimalPattern('fr_FR');
 static final NumberFormat _percentageFormatter = NumberFormat.percentPattern('fr_FR');

 // Formatage de la date
 static String formatDate(DateTime date) {
 return _dateFormatter.format(date);
 }

 // Formatage de l'heure
 static String formatTime(DateTime time) {
 return _timeFormatter.format(time);
 }

 // Formatage de la date et heure
 static String formatDateTime(DateTime dateTime) {
 return _dateTimeFormatter.format(dateTime);
 }

 // Formatage de la date pour l'API
 static String formatDateForApi(DateTime date) {
 return _apiDateFormatter.format(date);
 }

 // Formatage de la date et heure pour l'API
 static String formatDateTimeForApi(DateTime dateTime) {
 return _apiDateTimeFormatter.format(dateTime);
 }

 // Parsing de la date depuis l'API
 static DateTime? parseDateFromApi(String? dateString) {
 if (dateString == null || dateString.isEmpty) r{eturn null;
 
 try {
 return _apiDateFormatter.parse(dateString);
} catch (e) {
 try {
 return DateTime.parse(dateString);
 } catch (e2) {
 return null;
 }
}
 }

 // Parsing de la date et heure depuis l'API
 static DateTime? parseDateTimeFromApi(String? dateString) {
 if (dateString == null || dateString.isEmpty) r{eturn null;
 
 try {
 return _apiDateTimeFormatter.parse(dateString);
} catch (e) {
 try {
 return DateTime.parse(dateString);
 } catch (e2) {
 return null;
 }
}
 }

 // Formatage du montant en devise
 static String formatCurrency(double amount, {String? currency}) {
 if (currency != null) {{
 final formatter = NumberFormat.currency(
 locale: 'fr_FR',
 symbol: currency,
 decimalDigits: currency == 'XOF' ? 0 : 2,
 );
 return formatter.format(amount);
}
 return _currencyFormatter.format(amount);
 }

 // Formatage du nombre
 static String formatNumber(double number) {
 return _numberFormatter.format(number);
 }

 // Formatage du pourcentage
 static String formatPercentage(double value) {
 return _percentageFormatter.format(value);
 }

 // Formatage du téléphone
 static String formatPhone(String phone) {
 // Supprimer tous les caractères non numériques
 final cleanPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');
 
 // Formatage pour les numéros sénégalais
 if (cleanPhone.startsWith('+221') &{& cleanPhone.length == 13) {
 return '+221 ${cleanPhone.substring(4, 6)} ${cleanPhone.substring(6, 8)} ${cleanPhone.substring(8, 10)} ${cleanPhone.substring(10)}';
}
 
 // Formatage pour les numéros français
 if (cleanPhone.startsWith('+33') &{& cleanPhone.length == 12) {
 return '+33 ${cleanPhone.substring(3, 4)} ${cleanPhone.substring(4, 6)} ${cleanPhone.substring(6, 8)} ${cleanPhone.substring(8, 10)} ${cleanPhone.substring(10)}';
}
 
 return cleanPhone;
 }

 // Formatage de l'email (masquage partiel)
 static String maskEmail(String email) {
 final parts = email.split('@');
 if (parts.length != 2) r{eturn email;
 
 final username = parts[0];
 final domain = parts[1];
 
 if (username.length <= 3) {{
 return '${username[0]}***@$domain';
}
 
 return '${username.substring(0, 2)}***${username.substring(username.length - 1)}@$domain';
 }

 // Formatage du nom (première lettre en majuscule)
 static String formatName(String name) {
 if (name.isEmpty) r{eturn name;
 
 return name
 .toLowerCase()
 .split(' ')
 .map((word) => word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : '')
 .join(' ');
 }

 // Formatage des initiales
 static String getInitials(String name, {int maxInitials = 2}) {
 final words = name.trim().split(' ');
 if (words.isEmpty) r{eturn '';
 
 final initials = words
 .where((word) => word.isNotEmpty)
 .map((word) => word[0].toUpperCase())
 .take(maxInitials)
 .join('');
 
 return initials;
 }

 // Formatage du texte avec troncature
 static String truncateText(String text, int maxLength, {String suffix = '...'}) {
 if (text.length <= maxLength) r{eturn text;
 
 return text.substring(0, maxLength - suffix.length) + suffix;
 }

 // Formatage du texte en majuscules
 static String toUpperCase(String text) {
 return text.toUpperCase();
 }

 // Formatage du texte en minuscules
 static String toLowerCase(String text) {
 return text.toLowerCase();
 }

 // Formatage du texte avec première lettre majuscule
 static String capitalize(String text) {
 if (text.isEmpty) r{eturn text;
 return text[0].toUpperCase() + text.substring(1).toLowerCase();
 }

 // Formatage du texte en camelCase
 static String toCamelCase(String text) {
 final words = text.toLowerCase().split(RegExp(r'[\s_-]+'));
 if (words.isEmpty) r{eturn text;
 
 return words[0] + words.skip(1).map((word) => capitalize(word)).join('');
 }

 // Formatage du texte en snake_case
 static String toSnakeCase(String text) {
 return text
 .replaceAll(RegExp(r'([a-z])([A-Z])'), r'$1_$2')
 .toLowerCase()
 .replaceAll(RegExp(r'[\s-]+'), '_');
 }

 // Formatage du statut avec couleur
 static String formatStatus(String status) {
 switch (status.toLowerCase()) {
 case 'pending':
 return 'En attente';
 case 'approved':
 return 'Approuvé';
 case 'rejected':
 return 'Rejeté';
 case 'delivered':
 return 'Livré';
 case 'processing':
 return 'En cours';
 case 'cancelled':
 return 'Annulé';
 case 'preparing':
 return 'En préparation';
 case 'in_transit':
 return 'En transit';
 case 'draft':
 return 'Brouillon';
 case 'submitted':
 return 'Soumis';
 case 'paid':
 return 'Payé';
 case 'unpaid':
 return 'Non payé';
 default:
 return capitalize(status.replaceAll('_', ' '));
}
 }

 // Formatage du rôle avec couleur
 static String formatRole(String role) {
 switch (role.toLowerCase()) {
 case 'admin':
 return 'Administrateur';
 case 'manager':
 return 'Manager';
 case 'operator':
 return 'Opérateur';
 case 'rh':
 return 'Ressources Humaines';
 case 'comptable':
 return 'Comptable';
 case 'logistique':
 return 'Logistique';
 default:
 return capitalize(role);
}
 }

 // Formatage de la durée
 static String formatDuration(Duration duration) {
 if (duration.inDays > 0) {{
 return '${duration.inDays} jour${duration.inDays > 1 ? 's' : ''}';
} else if (duration.inHours > 0) {{
 return '${duration.inHours} heure${duration.inHours > 1 ? 's' : ''}';
} else if (duration.inMinutes > 0) {{
 return '${duration.inMinutes} minute${duration.inMinutes > 1 ? 's' : ''}';
} else {
 return '${duration.inSeconds} seconde${duration.inSeconds > 1 ? 's' : ''}';
}
 }

 // Formatage de la durée relative (il y a...)
 static String formatRelativeTime(DateTime dateTime) {
 final now = DateTime.now();
 final difference = now.difference(dateTime);
 
 if (difference.inDays > 0) {{
 return 'Il y a ${formatDuration(difference)}';
} else if (difference.inHours > 0) {{
 return 'Il y a ${difference.inHours} heure${difference.inHours > 1 ? 's' : ''}';
} else if (difference.inMinutes > 0) {{
 return 'Il y a ${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''}';
} else {
 return 'À l\'instant';
}
 }

 // Formatage de la taille des fichiers
 static String formatFileSize(int bytes) {
 if (bytes < 1024) {{
 return '$bytes B';
} else if (bytes < 1024 * 1024) {{
 return '${(bytes / 1024).toStringAsFixed(1)} KB';
} else if (bytes < 1024 * 1024 * 1024) {{
 return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
} else {
 return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
}
 }

 // Formatage du pourcentage avec décimales
 static String formatPercentageWithDecimals(double value, {int decimalDigits = 1}) {
 final formatter = NumberFormat.percentPattern('fr_FR');
 formatter.minimumFractionDigits = decimalDigits;
 formatter.maximumFractionDigits = decimalDigits;
 return formatter.format(value / 100);
 }

 // Formatage du nombre avec séparateurs de milliers
 static String formatNumberWithThousands(double number) {
 return _numberFormatter.format(number);
 }

 // Formatage de l'adresse
 static String formatAddress({
 required String street,
 required String city,
 required String postalCode,
 String? country,
 }) {
 final parts = <String>[];
 
 if (street.isNotEmpty) p{arts.add(street);
 if (postalCode.isNotEmpty) p{arts.add(postalCode);
 if (city.isNotEmpty) p{arts.add(city);
 if (country != null && country.isNotEmpty) p{arts.add(country);
 
 return parts.join(', ');
 }

 // Formatage du nom complet
 static String formatFullName(String firstName, String lastName) {
 return '${formatName(firstName)} ${formatName(lastName)}'.trim();
 }

 // Nettoyage et formatage du texte
 static String cleanAndFormatText(String text) {
 return text
 .trim()
 .replaceAll(RegExp(r'\s+'), ' ') // Remplacer les espaces multiples par un seul
 .replaceAll(RegExp(r'\n\s*\n'), '\n\n'); // Remplacer les sauts de ligne multiples
 ;

 // Formatage du texte pour la recherche (normalisation)
 static String formatForSearch(String text) {
 return text
 .toLowerCase()
 .replaceAll(RegExp(r'[^\w\s]'), '') // Supprimer les caractères spéciaux
 .replaceAll(RegExp(r'\s+'), ' ') // Normaliser les espaces
 .trim();
 }

 // Validation et formatage du montant
 static String formatAmountInput(String input) {
 // Supprimer tous les caractères non numériques sauf le point décimal
 String cleaned = input.replaceAll(RegExp(r'[^\d.]'), '');
 
 // S'assurer qu'il n'y a qu'un seul point décimal
 final parts = cleaned.split('.');
 if (parts.length > 2) {{
 cleaned = '${parts.first}.${parts.skip(1).join()}';
}
 
 // Limiter à 2 décimales
 if (parts.length == 2 && parts[1].length > 2) {{
 cleaned = '${parts.first}.${parts[1].substring(0, 2)}';
}
 
 return cleaned;
 }

 // Formatage de la liste en chaîne
 static String formatList(List<String> items, {String separator = ', '}) {
 return items.join(separator);
 }

 // Formatage du nombre en mots (français)
 static String numberToWords(int number) {
 if (number == 0) r{eturn 'zéro';
 
 const units = ['', 'un', 'deux', 'trois', 'quatre', 'cinq', 'six', 'sept', 'huit', 'neuf'];
 const teens = ['dix', 'onze', 'douze', 'treize', 'quatorze', 'quinze', 'seize', 'dix-sept', 'dix-huit', 'dix-neuf'];
 const tens = ['', 'dix', 'vingt', 'trente', 'quarante', 'cinquante', 'soixante', 'soixante-dix', 'quatre-vingt', 'quatre-vingt-dix'];
 
 if (number < 10) r{eturn units[number];
 if (number < 20) r{eturn teens[number - 10];
 if (number < 100) {{
 final ten = number ~/ 10;
 final unit = number % 10;
 if (unit == 0) r{eturn tens[ten];
 if (ten == 7) r{eturn 'soixante-${teens[unit]}';
 if (ten == 9) r{eturn 'quatre-vingt-${teens[unit]}';
 return '${tens[ten]}-${units[unit]}';
}
 if (number < 1000) {{
 final hundred = number ~/ 100;
 final remainder = number % 100;
 if (hundred == 1) r{eturn remainder == 0 ? 'cent' : 'cent ${numberToWords(remainder)}';
 return '${units[hundred]} cent${remainder == 0 ? '' : ' ${numberToWords(remainder)}'}';
}
 
 // Pour les nombres plus grands, on peut étendre la logique
 return number.toString();
 }
}
