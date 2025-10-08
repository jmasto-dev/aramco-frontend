import 'package:flutter_test/flutter_test.dart';
import '../lib/core/models/tax_declaration.dart';

void main() {
  group('TaxDeclaration Model Tests', () {
    test('should create TaxDeclaration with required fields', () {
      // Arrange
      final declaration = TaxDeclaration(
        id: '1',
        declarationNumber: 'TVA-2024-001',
        type: TaxDeclarationType.vat,
        status: TaxDeclarationStatus.draft,
        period: TaxPeriod.quarterly,
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 3, 31),
        submissionDate: DateTime(2024, 4, 15),
        totalAmount: 12500.0,
        taxAmount: 2500.0,
        baseAmount: 10000.0,
        createdAt: DateTime(2024, 4, 1),
        updatedAt: DateTime(2024, 4, 1),
      );

      // Assert
      expect(declaration.id, equals('1'));
      expect(declaration.declarationNumber, equals('TVA-2024-001'));
      expect(declaration.type, equals(TaxDeclarationType.vat));
      expect(declaration.status, equals(TaxDeclarationStatus.draft));
      expect(declaration.period, equals(TaxPeriod.quarterly));
      expect(declaration.totalAmount, equals(12500.0));
      expect(declaration.taxAmount, equals(2500.0));
      expect(declaration.baseAmount, equals(10000.0));
    });

    test('should return correct type text', () {
      final vatDeclaration = TaxDeclaration(
        id: '1',
        declarationNumber: 'TVA-2024-001',
        type: TaxDeclarationType.vat,
        status: TaxDeclarationStatus.draft,
        period: TaxPeriod.quarterly,
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 3, 31),
        submissionDate: DateTime(2024, 4, 15),
        totalAmount: 12500.0,
        taxAmount: 2500.0,
        baseAmount: 10000.0,
        createdAt: DateTime(2024, 4, 1),
        updatedAt: DateTime(2024, 4, 1),
      );

      expect(vatDeclaration.typeText, equals('TVA'));
    });

    test('should return correct status text', () {
      final draftDeclaration = TaxDeclaration(
        id: '1',
        declarationNumber: 'TVA-2024-001',
        type: TaxDeclarationType.vat,
        status: TaxDeclarationStatus.draft,
        period: TaxPeriod.quarterly,
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 3, 31),
        submissionDate: DateTime(2024, 4, 15),
        totalAmount: 12500.0,
        taxAmount: 2500.0,
        baseAmount: 10000.0,
        createdAt: DateTime(2024, 4, 1),
        updatedAt: DateTime(2024, 4, 1),
      );

      expect(draftDeclaration.statusText, equals('Brouillon'));
    });

    test('should return correct period text', () {
      final quarterlyDeclaration = TaxDeclaration(
        id: '1',
        declarationNumber: 'TVA-2024-001',
        type: TaxDeclarationType.vat,
        status: TaxDeclarationStatus.draft,
        period: TaxPeriod.quarterly,
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 3, 31),
        submissionDate: DateTime(2024, 4, 15),
        totalAmount: 12500.0,
        taxAmount: 2500.0,
        baseAmount: 10000.0,
        createdAt: DateTime(2024, 4, 1),
        updatedAt: DateTime(2024, 4, 1),
      );

      expect(quarterlyDeclaration.periodText, equals('Trimestriel'));
    });

    test('should correctly identify overdue declarations', () {
      final overdueDeclaration = TaxDeclaration(
        id: '1',
        declarationNumber: 'TVA-2024-001',
        type: TaxDeclarationType.vat,
        status: TaxDeclarationStatus.submitted,
        period: TaxPeriod.quarterly,
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 3, 31),
        submissionDate: DateTime(2024, 4, 15),
        dueDate: DateTime.now().subtract(const Duration(days: 1)), // Yesterday
        totalAmount: 12500.0,
        taxAmount: 2500.0,
        baseAmount: 10000.0,
        createdAt: DateTime(2024, 4, 1),
        updatedAt: DateTime(2024, 4, 1),
      );

      expect(overdueDeclaration.isOverdue, isTrue);
    });

    test('should correctly identify pending payment declarations', () {
      final pendingPaymentDeclaration = TaxDeclaration(
        id: '1',
        declarationNumber: 'TVA-2024-001',
        type: TaxDeclarationType.vat,
        status: TaxDeclarationStatus.approved,
        period: TaxPeriod.quarterly,
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 3, 31),
        submissionDate: DateTime(2024, 4, 15),
        dueDate: DateTime.now().add(const Duration(days: 30)),
        totalAmount: 12500.0,
        taxAmount: 2500.0,
        baseAmount: 10000.0,
        createdAt: DateTime(2024, 4, 1),
        updatedAt: DateTime(2024, 4, 1),
      );

      expect(pendingPaymentDeclaration.isPendingPayment, isTrue);
    });

    test('should copy declaration with new values', () {
      final originalDeclaration = TaxDeclaration(
        id: '1',
        declarationNumber: 'TVA-2024-001',
        type: TaxDeclarationType.vat,
        status: TaxDeclarationStatus.draft,
        period: TaxPeriod.quarterly,
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 3, 31),
        submissionDate: DateTime(2024, 4, 15),
        totalAmount: 12500.0,
        taxAmount: 2500.0,
        baseAmount: 10000.0,
        createdAt: DateTime(2024, 4, 1),
        updatedAt: DateTime(2024, 4, 1),
      );

      final updatedDeclaration = originalDeclaration.copyWith(
        status: TaxDeclarationStatus.submitted,
        taxAmount: 2600.0,
      );

      expect(updatedDeclaration.id, equals(originalDeclaration.id));
      expect(updatedDeclaration.status, equals(TaxDeclarationStatus.submitted));
      expect(updatedDeclaration.taxAmount, equals(2600.0));
      expect(updatedDeclaration.type, equals(originalDeclaration.type));
    });
  });

  group('TaxDeclarationItem Model Tests', () {
    test('should create TaxDeclarationItem with required fields', () {
      final item = TaxDeclarationItem(
        id: '1',
        description: 'Ventes de marchandises',
        amount: 10000.0,
        taxRate: 0.20,
        taxAmount: 2000.0,
        category: 'Ventes',
      );

      expect(item.id, equals('1'));
      expect(item.description, equals('Ventes de marchandises'));
      expect(item.amount, equals(10000.0));
      expect(item.taxRate, equals(0.20));
      expect(item.taxAmount, equals(2000.0));
      expect(item.category, equals('Ventes'));
    });
  });

  group('TaxDocument Model Tests', () {
    test('should create TaxDocument with required fields', () {
      final document = TaxDocument(
        id: '1',
        name: 'facture_001.pdf',
        type: 'application/pdf',
        url: 'https://example.com/facture_001.pdf',
        size: 1024000,
        uploadedAt: DateTime(2024, 4, 15),
      );

      expect(document.id, equals('1'));
      expect(document.name, equals('facture_001.pdf'));
      expect(document.type, equals('application/pdf'));
      expect(document.size, equals(1024000));
    });

    test('should format file size correctly', () {
      final smallDocument = TaxDocument(
        id: '1',
        name: 'small.txt',
        type: 'text/plain',
        url: 'https://example.com/small.txt',
        size: 512,
        uploadedAt: DateTime(2024, 4, 15),
      );

      final largeDocument = TaxDocument(
        id: '2',
        name: 'large.pdf',
        type: 'application/pdf',
        url: 'https://example.com/large.pdf',
        size: 2097152, // 2 MB
        uploadedAt: DateTime(2024, 4, 15),
      );

      expect(smallDocument.formattedSize, equals('512 B'));
      expect(largeDocument.formattedSize, equals('2.0 MB'));
    });
  });

  group('TaxRate Model Tests', () {
    test('should create TaxRate with required fields', () {
      final taxRate = TaxRate(
        id: '1',
        name: 'TVA normale',
        rate: 0.20,
        description: 'Taux normal de TVA',
        isActive: true,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      expect(taxRate.id, equals('1'));
      expect(taxRate.name, equals('TVA normale'));
      expect(taxRate.rate, equals(0.20));
      expect(taxRate.isActive, isTrue);
    });

    test('should format percentage correctly', () {
      final taxRate = TaxRate(
        id: '1',
        name: 'TVA normale',
        rate: 0.20,
        description: 'Taux normal de TVA',
        isActive: true,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      expect(taxRate.percentageText, equals('20.00%'));
    });

    test('should correctly identify valid tax rates', () {
      final now = DateTime.now();
      final validRate = TaxRate(
        id: '1',
        name: 'TVA valide',
        rate: 0.20,
        description: 'Taux valide',
        isActive: true,
        validFrom: now.subtract(const Duration(days: 1)),
        validTo: now.add(const Duration(days: 30)),
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      final inactiveRate = TaxRate(
        id: '2',
        name: 'TVA inactive',
        rate: 0.10,
        description: 'Taux inactif',
        isActive: false,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      expect(validRate.isValid, isTrue);
      expect(inactiveRate.isValid, isFalse);
    });
  });

  group('TaxPayment Model Tests', () {
    test('should create TaxPayment with required fields', () {
      final payment = TaxPayment(
        id: '1',
        declarationId: 'decl-001',
        amount: 2500.0,
        paymentDate: DateTime(2024, 4, 20),
        paymentMethod: 'Virement bancaire',
        status: 'completed',
        createdAt: DateTime(2024, 4, 20),
      );

      expect(payment.id, equals('1'));
      expect(payment.declarationId, equals('decl-001'));
      expect(payment.amount, equals(2500.0));
      expect(payment.paymentMethod, equals('Virement bancaire'));
      expect(payment.status, equals('completed'));
    });
  });

  group('TaxDeclarationType Enum Tests', () {
    test('should have correct enum values', () {
      expect(TaxDeclarationType.vat, isA<TaxDeclarationType>());
      expect(TaxDeclarationType.corporateTax, isA<TaxDeclarationType>());
      expect(TaxDeclarationType.incomeTax, isA<TaxDeclarationType>());
      expect(TaxDeclarationType.propertyTax, isA<TaxDeclarationType>());
      expect(TaxDeclarationType.other, isA<TaxDeclarationType>());
    });
  });

  group('TaxDeclarationStatus Enum Tests', () {
    test('should have correct enum values', () {
      expect(TaxDeclarationStatus.draft, isA<TaxDeclarationStatus>());
      expect(TaxDeclarationStatus.submitted, isA<TaxDeclarationStatus>());
      expect(TaxDeclarationStatus.underReview, isA<TaxDeclarationStatus>());
      expect(TaxDeclarationStatus.approved, isA<TaxDeclarationStatus>());
      expect(TaxDeclarationStatus.rejected, isA<TaxDeclarationStatus>());
      expect(TaxDeclarationStatus.paid, isA<TaxDeclarationStatus>());
    });
  });

  group('TaxPeriod Enum Tests', () {
    test('should have correct enum values', () {
      expect(TaxPeriod.monthly, isA<TaxPeriod>());
      expect(TaxPeriod.quarterly, isA<TaxPeriod>());
      expect(TaxPeriod.semiAnnual, isA<TaxPeriod>());
      expect(TaxPeriod.annual, isA<TaxPeriod>());
    });
  });
}
