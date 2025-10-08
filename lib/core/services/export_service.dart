import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import '../models/export_options.dart';
import '../models/order.dart';
import '../models/order_item.dart';
import '../models/product.dart';
import 'api_service.dart';

class ExportService {
  static final ExportService _instance = ExportService._internal();
  factory ExportService() => _instance;
  ExportService._internal();

  final Logger _logger = Logger();
  final ApiService _apiService = ApiService();

  // Colonnes disponibles pour l'export
  List<ExportColumn> getAvailableColumns() {
    return [
      const ExportColumn(
        key: 'id',
        label: 'ID Commande',
        width: 120.0,
      ),
      const ExportColumn(
        key: 'customerName',
        label: 'Client',
        width: 150.0,
      ),
      const ExportColumn(
        key: 'customerEmail',
        label: 'Email Client',
        width: 180.0,
      ),
      const ExportColumn(
        key: 'customerPhone',
        label: 'Téléphone',
        width: 120.0,
      ),
      const ExportColumn(
        key: 'status',
        label: 'Statut',
        width: 100.0,
      ),
      const ExportColumn(
        key: 'totalAmount',
        label: 'Montant Total',
        width: 120.0,
        format: 'currency',
      ),
      const ExportColumn(
        key: 'taxAmount',
        label: 'Montant Taxe',
        width: 120.0,
        format: 'currency',
      ),
      const ExportColumn(
        key: 'shippingAmount',
        label: 'Frais Livraison',
        width: 120.0,
        format: 'currency',
      ),
      const ExportColumn(
        key: 'itemCount',
        label: 'Nombre Articles',
        width: 120.0,
        format: 'number',
      ),
      const ExportColumn(
        key: 'shippingAddress',
        label: 'Adresse Livraison',
        width: 200.0,
      ),
      const ExportColumn(
        key: 'createdAt',
        label: 'Date Création',
        width: 140.0,
        format: 'datetime',
      ),
      const ExportColumn(
        key: 'updatedAt',
        label: 'Date Mise à Jour',
        width: 140.0,
        format: 'datetime',
      ),
    ];
  }

  // Templates prédéfinis
  List<ExportColumn> getTemplateColumns(ExportTemplate template) {
    final allColumns = getAvailableColumns();
    
    switch (template) {
      case ExportTemplate.standard:
        return allColumns.where((col) => 
          ['id', 'customerName', 'status', 'totalAmount', 'createdAt'].contains(col.key)
        ).toList();
      
      case ExportTemplate.detailed:
        return allColumns;
      
      case ExportTemplate.summary:
        return allColumns.where((col) => 
          ['id', 'customerName', 'status', 'totalAmount', 'itemCount', 'createdAt'].contains(col.key)
        ).toList();
      
      case ExportTemplate.custom:
        return allColumns.map((col) => col.copyWith(selected: false)).toList();
    }
  }

  // Export principal
  Future<ExportHistory> exportOrders(ExportOptions options) async {
    try {
      _logger.i('Début export commandes - Format: ${options.format.displayName}');
      
      // Récupération des données
      final orders = await _getFilteredOrders(options.filter);
      
      // Génération du fichier selon le format
      Uint8List fileData;
      switch (options.format) {
        case ExportFormat.pdf:
          fileData = await _generatePDF(orders, options);
          break;
        case ExportFormat.excel:
          fileData = await _generateExcel(orders, options);
          break;
        case ExportFormat.csv:
          fileData = await _generateCSV(orders, options);
          break;
        case ExportFormat.json:
          fileData = await _generateJSON(orders, options);
          break;
      }

      // Sauvegarde du fichier
      final filePath = await _saveFile(fileData, options.fileName);
      final fileSize = fileData.length.toDouble();

      // Création de l'historique
      final history = ExportHistory(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        fileName: options.fileName,
        format: options.format,
        template: options.template,
        recordCount: orders.length,
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(days: 30)),
        filePath: filePath,
        fileSize: fileSize,
        filter: options.filter,
        createdBy: 'current_user', // TODO: Récupérer l'utilisateur actuel
      );

      _logger.i('Export terminé - ${orders.length} commandes exportées');
      return history;
      
    } catch (e) {
      _logger.e('Erreur lors de l\'export: $e');
      throw Exception('Échec de l\'export: $e');
    }
  }

  // Récupération des commandes filtrées
  Future<List<Order>> _getFilteredOrders(ExportFilter filter) async {
    try {
      // Construction des paramètres de filtre
      final Map<String, dynamic> params = {};
      
      if (filter.startDate != null) {
        params['startDate'] = filter.startDate!.toIso8601String();
      }
      if (filter.endDate != null) {
        params['endDate'] = filter.endDate!.toIso8601String();
      }
      if (filter.statuses != null && filter.statuses!.isNotEmpty) {
        params['statuses'] = filter.statuses;
      }
      if (filter.customers != null && filter.customers!.isNotEmpty) {
        params['customers'] = filter.customers;
      }
      if (filter.minAmount != null) {
        params['minAmount'] = filter.minAmount;
      }
      if (filter.maxAmount != null) {
        params['maxAmount'] = filter.maxAmount;
      }
      if (filter.searchQuery != null && filter.searchQuery!.isNotEmpty) {
        params['search'] = filter.searchQuery;
      }

      // Appel API
      final ApiResponse<dynamic> response = await _apiService.get('/orders', queryParameters: params);
      
      if (response.data['success'] == true) {
        final List<dynamic> ordersData = response.data['data']['orders'];
        return ordersData.map((json) => Order.fromJson(json)).toList();
      } else {
        throw Exception(response.data['message'] ?? 'Erreur lors de la récupération des commandes');
      }
    } catch (e) {
      _logger.e('Erreur récupération commandes filtrées: $e');
      throw Exception('Impossible de récupérer les commandes: $e');
    }
  }

  // Génération PDF
  Future<Uint8List> _generatePDF(List<Order> orders, ExportOptions options) async {
    final pdf = pw.Document();
    
    // Page de titre
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(16),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Rapport des Commandes',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 16),
              pw.Text(
                'Généré le ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
                style: pw.TextStyle(fontSize: 12),
              ),
              pw.Text(
                'Nombre de commandes: ${orders.length}',
                style: pw.TextStyle(fontSize: 12),
              ),
              if (options.includeTotals) ...[
                pw.SizedBox(height: 8),
                pw.Text(
                  'Montant total: ${_formatCurrency(_calculateTotalAmount(orders))}',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ],
              pw.SizedBox(height: 32),
            ],
          );
        },
      ),
    );

    // Tableau des commandes
    if (orders.isNotEmpty) {
      final selectedColumns = options.columns.where((col) => col.selected).toList();
      
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(16),
          build: (pw.Context context) {
            return pw.TableHelper.fromTextArray(
              context: context,
              data: <List<String>>[
                // En-têtes
                if (options.includeHeaders)
                  selectedColumns.map((col) => col.label).toList(),
                // Données
                ...orders.map((order) => selectedColumns.map((col) => 
                  _formatCellValue(order, col)
                ).toList()),
              ],
              headerStyle: pw.TextStyle(
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
              ),
              bodyStyle: pw.TextStyle(fontSize: 9),
              cellAlignments: {
                0: pw.Alignment.centerLeft,
                1: pw.Alignment.centerLeft,
                2: pw.Alignment.centerLeft,
                3: pw.Alignment.centerLeft,
                4: pw.Alignment.center,
                5: pw.Alignment.centerRight,
                6: pw.Alignment.centerRight,
                7: pw.Alignment.centerRight,
                8: pw.Alignment.center,
                9: pw.Alignment.centerLeft,
                10: pw.Alignment.centerLeft,
                11: pw.Alignment.centerLeft,
              },
              columnWidths: {
                for (int i = 0; i < selectedColumns.length; i++)
                  i: pw.FixedColumnWidth(selectedColumns[i].width),
              },
              cellPadding: const pw.EdgeInsets.all(4),
              headerDecoration: pw.BoxDecoration(
                color: PdfColor.fromInt(0xFFE0E0E0),
              ),
              border: pw.TableBorder.all(
                color: PdfColor.fromInt(0xFF9E9E9E),
                width: 0.5,
              ),
            );
          },
        ),
      );
    }

    return pdf.save();
  }

  // Génération Excel
  Future<Uint8List> _generateExcel(List<Order> orders, ExportOptions options) async {
    final excel = Excel.createExcel();
    final sheet = excel['Commandes'];

    final selectedColumns = options.columns.where((col) => col.selected).toList();
    int rowIndex = 0;

    // En-têtes
    if (options.includeHeaders) {
      for (int i = 0; i < selectedColumns.length; i++) {
        final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: rowIndex));
        cell.value = selectedColumns[i].label;
        cell.cellStyle = CellStyle(
          bold: true,
          backgroundColorHex: '#E0E0E0',
          horizontalAlign: HorizontalAlign.Center,
        );
      }
      rowIndex++;
    }

    // Données
    for (final order in orders) {
      for (int i = 0; i < selectedColumns.length; i++) {
        final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: rowIndex));
        final value = _formatCellValue(order, selectedColumns[i]);
        
        // Formatage selon le type de colonne
        if (selectedColumns[i].format == 'currency') {
          cell.value = _parseCurrency(value);
        } else if (selectedColumns[i].format == 'datetime') {
          cell.value = _parseDateTime(value);
        } else if (selectedColumns[i].format == 'number') {
          cell.value = _parseNumber(value);
        } else {
          cell.value = value;
        }
      }
      rowIndex++;
    }

    // Totaux
    if (options.includeTotals && orders.isNotEmpty) {
      rowIndex++; // Ligne vide
      
      // Ligne de total
      for (int i = 0; i < selectedColumns.length; i++) {
        final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: rowIndex));
        
        if (selectedColumns[i].key == 'totalAmount') {
          cell.value = _calculateTotalAmount(orders);
          cell.cellStyle = CellStyle(bold: true);
        } else if (selectedColumns[i].key == 'itemCount') {
          cell.value = orders.fold<int>(0, (sum, order) => sum + order.items.length);
          cell.cellStyle = CellStyle(bold: true);
        } else if (i == 0) {
          cell.value = 'TOTAL';
          cell.cellStyle = CellStyle(bold: true);
        }
      }
    }

    // Ajustement de la largeur des colonnes
    for (int i = 0; i < selectedColumns.length; i++) {
      sheet.setColWidth(i, selectedColumns[i].width / 7); // Conversion pour Excel
    }

    return excel.save();
  }

  // Génération CSV
  Future<Uint8List> _generateCSV(List<Order> orders, ExportOptions options) async {
    final selectedColumns = options.columns.where((col) => col.selected).toList();
    final buffer = StringBuffer();

    // En-têtes
    if (options.includeHeaders) {
      buffer.writeln(selectedColumns.map((col) => _escapeCSV(col.label)).join(','));
    }

    // Données
    for (final order in orders) {
      final row = selectedColumns.map((col) => 
        _escapeCSV(_formatCellValue(order, col))
      ).join(',');
      buffer.writeln(row);
    }

    // Totaux
    if (options.includeTotals && orders.isNotEmpty) {
      buffer.writeln(); // Ligne vide
      
      final totalRow = <String>[];
      for (int i = 0; i < selectedColumns.length; i++) {
        if (selectedColumns[i].key == 'totalAmount') {
          totalRow.add(_calculateTotalAmount(orders).toStringAsFixed(2));
        } else if (selectedColumns[i].key == 'itemCount') {
          totalRow.add(orders.fold<int>(0, (sum, order) => sum + order.items.length).toString());
        } else if (i == 0) {
          totalRow.add('TOTAL');
        } else {
          totalRow.add('');
        }
      }
      buffer.writeln(totalRow.join(','));
    }

    return Uint8List.fromList(utf8.encode(buffer.toString()));
  }

  // Génération JSON
  Future<Uint8List> _generateJSON(List<Order> orders, ExportOptions options) async {
    final selectedColumns = options.columns.where((col) => col.selected).toList();
    
    final List<Map<String, dynamic>> jsonData = [];
    
    for (final order in orders) {
      final Map<String, dynamic> orderData = {};
      
      for (final column in selectedColumns) {
        orderData[column.key] = _getJsonValue(order, column);
      }
      
      jsonData.add(orderData);
    }

    final exportData = {
      'metadata': {
        'generatedAt': DateTime.now().toIso8601String(),
        'recordCount': orders.length,
        'template': options.template.name,
        'filter': options.filter.toJson(),
      },
      'data': jsonData,
      if (options.includeTotals)
        'totals': {
          'totalAmount': _calculateTotalAmount(orders),
          'totalItems': orders.fold<int>(0, (sum, order) => sum + order.items.length),
        },
    };

    return Uint8List.fromList(utf8.encode(jsonEncode(exportData)));
  }

  // Utilitaires de formatage
  String _formatCellValue(Order order, ExportColumn column) {
    switch (column.key) {
      case 'id':
        return order.id;
      case 'customerName':
        return order.customerName;
      case 'customerEmail':
        return order.customerEmail;
      case 'customerPhone':
        return order.customerPhone;
      case 'status':
        return order.status.displayName;
      case 'totalAmount':
        return _formatCurrency(order.totalAmount);
      case 'taxAmount':
        return _formatCurrency(order.taxAmount);
      case 'shippingAmount':
        return _formatCurrency(order.shippingAmount);
      case 'itemCount':
        return order.items.length.toString();
      case 'shippingAddress':
        return order.shippingAddress;
      case 'createdAt':
        return DateFormat('dd/MM/yyyy HH:mm').format(order.createdAt);
      case 'updatedAt':
        return DateFormat('dd/MM/yyyy HH:mm').format(order.updatedAt);
      default:
        return '';
    }
  }

  dynamic _getJsonValue(Order order, ExportColumn column) {
    switch (column.key) {
      case 'id':
      case 'customerName':
      case 'customerEmail':
      case 'customerPhone':
      case 'shippingAddress':
        return _formatCellValue(order, column);
      case 'status':
        return order.status.name;
      case 'totalAmount':
      case 'taxAmount':
      case 'shippingAmount':
        return order.totalAmount; // Valeur numérique
      case 'itemCount':
        return order.items.length;
      case 'createdAt':
      case 'updatedAt':
        return order.createdAt.toIso8601String();
      default:
        return null;
    }
  }

  String _formatCurrency(double amount) {
    return '${amount.toStringAsFixed(2)} €';
  }

  String _escapeCSV(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

  double _parseCurrency(String value) {
    return double.tryParse(value.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
  }

  DateTime? _parseDateTime(String value) {
    try {
      return DateFormat('dd/MM/yyyy HH:mm').parse(value);
    } catch (e) {
      return null;
    }
  }

  double _parseNumber(String value) {
    return double.tryParse(value) ?? 0.0;
  }

  double _calculateTotalAmount(List<Order> orders) {
    return orders.fold<double>(0.0, (sum, order) => sum + order.totalAmount);
  }

  // Sauvegarde du fichier
  Future<String> _saveFile(Uint8List data, String fileName) async {
    try {
      // Demande de permission pour Android
      if (Platform.isAndroid) {
        final status = await Permission.storage.request();
        if (!status.isGranted) {
          throw Exception('Permission de stockage refusée');
        }
      }

      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/exports/$fileName';
      
      // Création du répertoire si nécessaire
      final file = File(filePath);
      await file.parent.create(recursive: true);
      await file.writeAsBytes(data);

      return filePath;
    } catch (e) {
      _logger.e('Erreur sauvegarde fichier: $e');
      throw Exception('Impossible de sauvegarder le fichier: $e');
    }
  }

  // Partage du fichier
  Future<void> shareFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await Share.shareXFiles(
          [XFile(filePath)],
          subject: 'Export des commandes Aramco',
        );
      } else {
        throw Exception('Fichier introuvable');
      }
    } catch (e) {
      _logger.e('Erreur partage fichier: $e');
      throw Exception('Impossible de partager le fichier: $e');
    }
  }

  // Nettoyage des anciens exports
  Future<void> cleanupOldExports() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final exportsDir = Directory('${directory.path}/exports');
      
      if (await exportsDir.exists()) {
        final files = await exportsDir.list().toList();
        final now = DateTime.now();
        
        for (final file in files) {
          if (file is File) {
            final stat = await file.stat();
            final age = now.difference(stat.modified);
            
            // Suppression des fichiers de plus de 30 jours
            if (age.inDays > 30) {
              await file.delete();
              _logger.i('Fichier supprimé: ${file.path}');
            }
          }
        }
      }
    } catch (e) {
      _logger.e('Erreur nettoyage exports: $e');
    }
  }

  // Récupération de l'historique des exports
  Future<List<ExportHistory>> getExportHistory() async {
    try {
      // TODO: Implémenter la récupération depuis le stockage local ou l'API
      return [];
    } catch (e) {
      _logger.e('Erreur récupération historique: $e');
      return [];
    }
  }
}
