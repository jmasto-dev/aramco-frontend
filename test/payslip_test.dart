import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:aramco_frontend/core/models/payslip.dart';
import 'package:aramco_frontend/core/services/payslip_service.dart';
import 'package:aramco_frontend/presentation/providers/payslip_provider.dart';

import 'payslip_test.mocks.dart';

@GenerateMocks([PayslipService])
void main() {
  group('Payslip Model Tests', () {
    test('Payslip should serialize to JSON correctly', () {
      final period = PayslipPeriod(
        month: 1,
        year: 2024,
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 1, 31),
      );

      final amounts = PayslipAmounts(
        baseSalary: 5000.0,
        overtimeHours: 0,
        overtimeAmount: 0,
        bonuses: 0,
        allowances: 0,
        commissions: 0,
        otherEarnings: 0,
        grossEarnings: 5000.0,
        socialSecurity: 500.0,
        incomeTax: 300.0,
        otherDeductions: 0,
        totalDeductions: 800.0,
        netAmount: 4200.0,
      );

      final summary = PayslipSummary(
        grossAmount: 5000.0,
        taxableAmount: 5000.0,
        nonTaxableAmount: 0,
        socialSecurityContributions: 500.0,
        incomeTax: 300.0,
        otherDeductions: 0,
        totalDeductions: 800.0,
        netAmount: 4200.0,
        yearToDateGross: 5000.0,
        yearToDateNet: 4200.0,
        yearToDateTax: 300.0,
      );

      final payslip = Payslip(
        id: '1',
        employeeId: 'emp1',
        employeeName: 'John Doe',
        employeeMatricule: 'EMP001',
        department: 'IT',
        position: 'Developer',
        period: period,
        issueDate: DateTime(2024, 1, 31),
        paymentDate: DateTime(2024, 1, 31),
        amounts: amounts,
        earnings: [],
        deductions: [],
        contributions: [],
        summary: summary,
        status: 'paid',
        createdAt: DateTime(2024, 1, 1),
      );

      final json = payslip.toJson();

      expect(json['id'], '1');
      expect(json['employeeId'], 'emp1');
      expect(json['employeeName'], 'John Doe');
      expect(json['status'], 'paid');
    });

    test('Payslip should deserialize from JSON correctly', () {
      final json = {
        'id': '1',
        'employeeId': 'emp1',
        'employeeName': 'John Doe',
        'employeeMatricule': 'EMP001',
        'department': 'IT',
        'position': 'Developer',
        'period': {
          'month': 1,
          'year': 2024,
          'startDate': '2024-01-01T00:00:00.000Z',
          'endDate': '2024-01-31T00:00:00.000Z',
        },
        'issueDate': '2024-01-31T00:00:00.000Z',
        'paymentDate': '2024-01-31T00:00:00.000Z',
        'amounts': {
          'baseSalary': 5000.0,
          'overtimeHours': 0,
          'overtimeAmount': 0,
          'bonuses': 0,
          'allowances': 0,
          'commissions': 0,
          'otherEarnings': 0,
          'grossEarnings': 5000.0,
          'socialSecurity': 500.0,
          'incomeTax': 300.0,
          'otherDeductions': 0,
          'totalDeductions': 800.0,
          'netAmount': 4200.0,
        },
        'earnings': [],
        'deductions': [],
        'contributions': [],
        'summary': {
          'grossAmount': 5000.0,
          'taxableAmount': 5000.0,
          'nonTaxableAmount': 0,
          'socialSecurityContributions': 500.0,
          'incomeTax': 300.0,
          'otherDeductions': 0,
          'totalDeductions': 800.0,
          'netAmount': 4200.0,
          'yearToDateGross': 5000.0,
          'yearToDateNet': 4200.0,
          'yearToDateTax': 300.0,
        },
        'currency': 'EUR',
        'status': 'paid',
        'attachments': [],
        'createdAt': '2024-01-01T00:00:00.000Z',
      };

      final payslip = Payslip.fromJson(json);

      expect(payslip.id, '1');
      expect(payslip.employeeId, 'emp1');
      expect(payslip.employeeName, 'John Doe');
      expect(payslip.status, 'paid');
      expect(payslip.period.month, 1);
      expect(payslip.period.year, 2024);
    });

    test('Payslip copyWith should work correctly', () {
      final period = PayslipPeriod(
        month: 1,
        year: 2024,
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 1, 31),
      );

      final amounts = PayslipAmounts(
        baseSalary: 5000.0,
        overtimeHours: 0,
        overtimeAmount: 0,
        bonuses: 0,
        allowances: 0,
        commissions: 0,
        otherEarnings: 0,
        grossEarnings: 5000.0,
        socialSecurity: 500.0,
        incomeTax: 300.0,
        otherDeductions: 0,
        totalDeductions: 800.0,
        netAmount: 4200.0,
      );

      final summary = PayslipSummary(
        grossAmount: 5000.0,
        taxableAmount: 5000.0,
        nonTaxableAmount: 0,
        socialSecurityContributions: 500.0,
        incomeTax: 300.0,
        otherDeductions: 0,
        totalDeductions: 800.0,
        netAmount: 4200.0,
        yearToDateGross: 5000.0,
        yearToDateNet: 4200.0,
        yearToDateTax: 300.0,
      );

      final originalPayslip = Payslip(
        id: '1',
        employeeId: 'emp1',
        employeeName: 'John Doe',
        employeeMatricule: 'EMP001',
        department: 'IT',
        position: 'Developer',
        period: period,
        issueDate: DateTime(2024, 1, 31),
        paymentDate: DateTime(2024, 1, 31),
        amounts: amounts,
        earnings: [],
        deductions: [],
        contributions: [],
        summary: summary,
        status: 'pending',
        createdAt: DateTime(2024, 1, 1),
      );

      final updatedPayslip = originalPayslip.copyWith(
        status: 'paid',
        paymentDate: DateTime(2024, 2, 1),
      );

      expect(updatedPayslip.id, originalPayslip.id);
      expect(updatedPayslip.status, 'paid');
      expect(updatedPayslip.paymentDate, DateTime(2024, 2, 1));
      expect(updatedPayslip.employeeName, originalPayslip.employeeName);
    });

    test('Payslip formattedPeriod should work correctly', () {
      final period = PayslipPeriod(
        month: 1,
        year: 2024,
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 1, 31),
      );

      final amounts = PayslipAmounts(
        baseSalary: 5000.0,
        overtimeHours: 0,
        overtimeAmount: 0,
        bonuses: 0,
        allowances: 0,
        commissions: 0,
        otherEarnings: 0,
        grossEarnings: 5000.0,
        socialSecurity: 500.0,
        incomeTax: 300.0,
        otherDeductions: 0,
        totalDeductions: 800.0,
        netAmount: 4200.0,
      );

      final summary = PayslipSummary(
        grossAmount: 5000.0,
        taxableAmount: 5000.0,
        nonTaxableAmount: 0,
        socialSecurityContributions: 500.0,
        incomeTax: 300.0,
        otherDeductions: 0,
        totalDeductions: 800.0,
        netAmount: 4200.0,
        yearToDateGross: 5000.0,
        yearToDateNet: 4200.0,
        yearToDateTax: 300.0,
      );

      final payslip = Payslip(
        id: '1',
        employeeId: 'emp1',
        employeeName: 'John Doe',
        employeeMatricule: 'EMP001',
        department: 'IT',
        position: 'Developer',
        period: period,
        issueDate: DateTime(2024, 1, 31),
        paymentDate: DateTime(2024, 1, 31),
        amounts: amounts,
        earnings: [],
        deductions: [],
        contributions: [],
        summary: summary,
        status: 'paid',
        createdAt: DateTime(2024, 1, 1),
      );

      expect(payslip.formattedPeriod, '1/2024');
    });

    test('Payslip formattedIssueDate should work correctly', () {
      final period = PayslipPeriod(
        month: 1,
        year: 2024,
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 1, 31),
      );

      final amounts = PayslipAmounts(
        baseSalary: 5000.0,
        overtimeHours: 0,
        overtimeAmount: 0,
        bonuses: 0,
        allowances: 0,
        commissions: 0,
        otherEarnings: 0,
        grossEarnings: 5000.0,
        socialSecurity: 500.0,
        incomeTax: 300.0,
        otherDeductions: 0,
        totalDeductions: 800.0,
        netAmount: 4200.0,
      );

      final summary = PayslipSummary(
        grossAmount: 5000.0,
        taxableAmount: 5000.0,
        nonTaxableAmount: 0,
        socialSecurityContributions: 500.0,
        incomeTax: 300.0,
        otherDeductions: 0,
        totalDeductions: 800.0,
        netAmount: 4200.0,
        yearToDateGross: 5000.0,
        yearToDateNet: 4200.0,
        yearToDateTax: 300.0,
      );

      final payslip = Payslip(
        id: '1',
        employeeId: 'emp1',
        employeeName: 'John Doe',
        employeeMatricule: 'EMP001',
        department: 'IT',
        position: 'Developer',
        period: period,
        issueDate: DateTime(2024, 1, 31),
        paymentDate: DateTime(2024, 1, 31),
        amounts: amounts,
        earnings: [],
        deductions: [],
        contributions: [],
        summary: summary,
        status: 'paid',
        createdAt: DateTime(2024, 1, 1),
      );

      expect(payslip.formattedIssueDate, '31/01/2024');
    });

    test('Payslip formattedNetAmount should work correctly', () {
      final period = PayslipPeriod(
        month: 1,
        year: 2024,
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 1, 31),
      );

      final amounts = PayslipAmounts(
        baseSalary: 5000.0,
        overtimeHours: 0,
        overtimeAmount: 0,
        bonuses: 0,
        allowances: 0,
        commissions: 0,
        otherEarnings: 0,
        grossEarnings: 5000.0,
        socialSecurity: 500.0,
        incomeTax: 300.0,
        otherDeductions: 0,
        totalDeductions: 800.0,
        netAmount: 4200.0,
      );

      final summary = PayslipSummary(
        grossAmount: 5000.0,
        taxableAmount: 5000.0,
        nonTaxableAmount: 0,
        socialSecurityContributions: 500.0,
        incomeTax: 300.0,
        otherDeductions: 0,
        totalDeductions: 800.0,
        netAmount: 4200.0,
        yearToDateGross: 5000.0,
        yearToDateNet: 4200.0,
        yearToDateTax: 300.0,
      );

      final payslip = Payslip(
        id: '1',
        employeeId: 'emp1',
        employeeName: 'John Doe',
        employeeMatricule: 'EMP001',
        department: 'IT',
        position: 'Developer',
        period: period,
        issueDate: DateTime(2024, 1, 31),
        paymentDate: DateTime(2024, 1, 31),
        amounts: amounts,
        earnings: [],
        deductions: [],
        contributions: [],
        summary: summary,
        status: 'paid',
        createdAt: DateTime(2024, 1, 1),
      );

      expect(payslip.formattedNetAmount, '4200.00 EUR');
    });

    test('Payslip status getters should work correctly', () {
      final period = PayslipPeriod(
        month: 1,
        year: 2024,
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 1, 31),
      );

      final amounts = PayslipAmounts(
        baseSalary: 5000.0,
        overtimeHours: 0,
        overtimeAmount: 0,
        bonuses: 0,
        allowances: 0,
        commissions: 0,
        otherEarnings: 0,
        grossEarnings: 5000.0,
        socialSecurity: 500.0,
        incomeTax: 300.0,
        otherDeductions: 0,
        totalDeductions: 800.0,
        netAmount: 4200.0,
      );

      final summary = PayslipSummary(
        grossAmount: 5000.0,
        taxableAmount: 5000.0,
        nonTaxableAmount: 0,
        socialSecurityContributions: 500.0,
        incomeTax: 300.0,
        otherDeductions: 0,
        totalDeductions: 800.0,
        netAmount: 4200.0,
        yearToDateGross: 5000.0,
        yearToDateNet: 4200.0,
        yearToDateTax: 300.0,
      );

      final paidPayslip = Payslip(
        id: '1',
        employeeId: 'emp1',
        employeeName: 'John Doe',
        employeeMatricule: 'EMP001',
        department: 'IT',
        position: 'Developer',
        period: period,
        issueDate: DateTime(2024, 1, 31),
        paymentDate: DateTime(2024, 1, 31),
        amounts: amounts,
        earnings: [],
        deductions: [],
        contributions: [],
        summary: summary,
        status: 'paid',
        createdAt: DateTime(2024, 1, 1),
      );

      final pendingPayslip = Payslip(
        id: '2',
        employeeId: 'emp1',
        employeeName: 'John Doe',
        employeeMatricule: 'EMP001',
        department: 'IT',
        position: 'Developer',
        period: period,
        issueDate: DateTime(2024, 1, 31),
        paymentDate: DateTime(2024, 1, 31),
        amounts: amounts,
        earnings: [],
        deductions: [],
        contributions: [],
        summary: summary,
        status: 'pending',
        createdAt: DateTime(2024, 1, 1),
      );

      expect(paidPayslip.isPaid, true);
      expect(paidPayslip.isPending, false);
      expect(pendingPayslip.isPending, true);
      expect(pendingPayslip.isPaid, false);
    });

    test('Payslip statusDisplay should work correctly', () {
      final period = PayslipPeriod(
        month: 1,
        year: 2024,
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 1, 31),
      );

      final amounts = PayslipAmounts(
        baseSalary: 5000.0,
        overtimeHours: 0,
        overtimeAmount: 0,
        bonuses: 0,
        allowances: 0,
        commissions: 0,
        otherEarnings: 0,
        grossEarnings: 5000.0,
        socialSecurity: 500.0,
        incomeTax: 300.0,
        otherDeductions: 0,
        totalDeductions: 800.0,
        netAmount: 4200.0,
      );

      final summary = PayslipSummary(
        grossAmount: 5000.0,
        taxableAmount: 5000.0,
        nonTaxableAmount: 0,
        socialSecurityContributions: 500.0,
        incomeTax: 300.0,
        otherDeductions: 0,
        totalDeductions: 800.0,
        netAmount: 4200.0,
        yearToDateGross: 5000.0,
        yearToDateNet: 4200.0,
        yearToDateTax: 300.0,
      );

      final payslip = Payslip(
        id: '1',
        employeeId: 'emp1',
        employeeName: 'John Doe',
        employeeMatricule: 'EMP001',
        department: 'IT',
        position: 'Developer',
        period: period,
        issueDate: DateTime(2024, 1, 31),
        paymentDate: DateTime(2024, 1, 31),
        amounts: amounts,
        earnings: [],
        deductions: [],
        contributions: [],
        summary: summary,
        status: 'paid',
        createdAt: DateTime(2024, 1, 1),
      );

      expect(payslip.statusDisplay, 'Payée');
    });

    test('Payslip equality should work correctly', () {
      final period = PayslipPeriod(
        month: 1,
        year: 2024,
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 1, 31),
      );

      final amounts = PayslipAmounts(
        baseSalary: 5000.0,
        overtimeHours: 0,
        overtimeAmount: 0,
        bonuses: 0,
        allowances: 0,
        commissions: 0,
        otherEarnings: 0,
        grossEarnings: 5000.0,
        socialSecurity: 500.0,
        incomeTax: 300.0,
        otherDeductions: 0,
        totalDeductions: 800.0,
        netAmount: 4200.0,
      );

      final summary = PayslipSummary(
        grossAmount: 5000.0,
        taxableAmount: 5000.0,
        nonTaxableAmount: 0,
        socialSecurityContributions: 500.0,
        incomeTax: 300.0,
        otherDeductions: 0,
        totalDeductions: 800.0,
        netAmount: 4200.0,
        yearToDateGross: 5000.0,
        yearToDateNet: 4200.0,
        yearToDateTax: 300.0,
      );

      final payslip1 = Payslip(
        id: '1',
        employeeId: 'emp1',
        employeeName: 'John Doe',
        employeeMatricule: 'EMP001',
        department: 'IT',
        position: 'Developer',
        period: period,
        issueDate: DateTime(2024, 1, 31),
        paymentDate: DateTime(2024, 1, 31),
        amounts: amounts,
        earnings: [],
        deductions: [],
        contributions: [],
        summary: summary,
        status: 'paid',
        createdAt: DateTime(2024, 1, 1),
      );

      final payslip2 = Payslip(
        id: '1',
        employeeId: 'emp1',
        employeeName: 'John Doe',
        employeeMatricule: 'EMP001',
        department: 'IT',
        position: 'Developer',
        period: period,
        issueDate: DateTime(2024, 1, 31),
        paymentDate: DateTime(2024, 1, 31),
        amounts: amounts,
        earnings: [],
        deductions: [],
        contributions: [],
        summary: summary,
        status: 'paid',
        createdAt: DateTime(2024, 1, 1),
      );

      final payslip3 = Payslip(
        id: '2',
        employeeId: 'emp1',
        employeeName: 'John Doe',
        employeeMatricule: 'EMP001',
        department: 'IT',
        position: 'Developer',
        period: period,
        issueDate: DateTime(2024, 1, 31),
        paymentDate: DateTime(2024, 1, 31),
        amounts: amounts,
        earnings: [],
        deductions: [],
        contributions: [],
        summary: summary,
        status: 'paid',
        createdAt: DateTime(2024, 1, 1),
      );

      expect(payslip1, equals(payslip2));
      expect(payslip1, isNot(equals(payslip3)));
    });
  });

  group('PayslipPeriod Tests', () {
    test('PayslipPeriod monthName should work correctly', () {
      final period = PayslipPeriod(
        month: 1,
        year: 2024,
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 1, 31),
      );

      expect(period.monthName, 'Janvier');
    });

    test('PayslipPeriod display should work correctly', () {
      final period = PayslipPeriod(
        month: 1,
        year: 2024,
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 1, 31),
      );

      expect(period.display, 'Janvier 2024');
    });
  });

  group('PayslipAmounts Tests', () {
    test('PayslipAmounts formatted methods should work correctly', () {
      final amounts = PayslipAmounts(
        baseSalary: 5000.0,
        overtimeHours: 0,
        overtimeAmount: 0,
        bonuses: 0,
        allowances: 0,
        commissions: 0,
        otherEarnings: 0,
        grossEarnings: 5000.0,
        socialSecurity: 500.0,
        incomeTax: 300.0,
        otherDeductions: 0,
        totalDeductions: 800.0,
        netAmount: 4200.0,
      );

      expect(amounts.formattedBaseSalary, '5000.00 €');
      expect(amounts.formattedNetAmount, '4200.00 €');
      expect(amounts.formattedGrossEarnings, '5000.00 €');
    });
  });

  group('PayslipEarning Tests', () {
    test('PayslipEarning should work correctly', () {
      final earning = PayslipEarning(
        id: '1',
        type: 'base',
        description: 'Salaire de base',
        amount: 5000.0,
        quantity: 1,
        rate: 5000.0,
        isTaxable: true,
      );

      expect(earning.formattedAmount, '5000.00 €');
      expect(earning.displayDescription, 'Salaire de base');
    });

    test('PayslipEarning displayDescription should include quantity', () {
      final earning = PayslipEarning(
        id: '1',
        type: 'overtime',
        description: 'Heures supplémentaires',
        amount: 200.0,
        quantity: 5,
        rate: 40.0,
        isTaxable: true,
      );

      expect(earning.displayDescription, 'Heures supplémentaires (5)');
    });
  });

  group('PayslipDeduction Tests', () {
    test('PayslipDeduction should work correctly', () {
      final deduction = PayslipDeduction(
        id: '1',
        type: 'tax',
        description: 'Impôt sur le revenu',
        amount: 300.0,
        percentage: 6.0,
        isPreTax: false,
      );

      expect(deduction.formattedAmount, '300.00 €');
      expect(deduction.formattedPercentage, '6.0%');
    });
  });

  group('PayslipContribution Tests', () {
    test('PayslipContribution should work correctly', () {
      final contribution = PayslipContribution(
        id: '1',
        type: 'social',
        description: 'Sécurité sociale',
        employeeContribution: 500.0,
        employerContribution: 800.0,
        totalContribution: 1300.0,
        percentage: 20.0,
        isMandatory: true,
      );

      expect(contribution.formattedEmployeeContribution, '500.00 €');
      expect(contribution.formattedEmployerContribution, '800.00 €');
      expect(contribution.formattedTotalContribution, '1300.00 €');
    });
  });

  group('PayslipSummary Tests', () {
    test('PayslipSummary formatted methods should work correctly', () {
      final summary = PayslipSummary(
        grossAmount: 5000.0,
        taxableAmount: 5000.0,
        nonTaxableAmount: 0,
        socialSecurityContributions: 500.0,
        incomeTax: 300.0,
        otherDeductions: 0,
        totalDeductions: 800.0,
        netAmount: 4200.0,
        yearToDateGross: 5000.0,
        yearToDateNet: 4200.0,
        yearToDateTax: 300.0,
      );

      expect(summary.formattedGrossAmount, '5000.00 €');
      expect(summary.formattedNetAmount, '4200.00 €');
      expect(summary.formattedYearToDateGross, '5000.00 €');
    });
  });

  group('PayslipStatus Enum Tests', () {
    test('PayslipStatus displayName should work correctly', () {
      expect(PayslipStatus.draft.displayName, 'Brouillon');
      expect(PayslipStatus.pending.displayName, 'En attente');
      expect(PayslipStatus.approved.displayName, 'Approuvée');
      expect(PayslipStatus.paid.displayName, 'Payée');
      expect(PayslipStatus.cancelled.displayName, 'Annulée');
    });

    test('PayslipStatus fromString should work correctly', () {
      expect(PayslipStatus.fromString('Payée'), PayslipStatus.paid);
      expect(PayslipStatus.fromString('paid'), PayslipStatus.paid);
      expect(PayslipStatus.fromString('unknown'), PayslipStatus.draft);
    });
  });

  group('Payslip Service Tests', () {
    late MockPayslipService mockService;

    setUp(() {
      mockService = MockPayslipService();
    });

    test('should get payslips successfully', () async {
      final period = PayslipPeriod(
        month: 1,
        year: 2024,
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 1, 31),
      );

      final amounts = PayslipAmounts(
        baseSalary: 5000.0,
        overtimeHours: 0,
        overtimeAmount: 0,
        bonuses: 0,
        allowances: 0,
        commissions: 0,
        otherEarnings: 0,
        grossEarnings: 5000.0,
        socialSecurity: 500.0,
        incomeTax: 300.0,
        otherDeductions: 0,
        totalDeductions: 800.0,
        netAmount: 4200.0,
      );

      final summary = PayslipSummary(
        grossAmount: 5000.0,
        taxableAmount: 5000.0,
        nonTaxableAmount: 0,
        socialSecurityContributions: 500.0,
        incomeTax: 300.0,
        otherDeductions: 0,
        totalDeductions: 800.0,
        netAmount: 4200.0,
        yearToDateGross: 5000.0,
        yearToDateNet: 4200.0,
        yearToDateTax: 300.0,
      );

      final payslips = [
        Payslip(
          id: '1',
          employeeId: 'emp1',
          employeeName: 'John Doe',
          employeeMatricule: 'EMP001',
          department: 'IT',
          position: 'Developer',
          period: period,
          issueDate: DateTime(2024, 1, 31),
          paymentDate: DateTime(2024, 1, 31),
          amounts: amounts,
          earnings: [],
          deductions: [],
          contributions: [],
          summary: summary,
          status: 'paid',
          createdAt: DateTime(2024, 1, 1),
        ),
      ];

      when(mockService.getPayslips()).thenAnswer((_) async => payslips);

      final result = await mockService.getPayslips();

      expect(result, isA<List<Payslip>>());
      expect(result.length, 1);
      expect(result.first.employeeName, 'John Doe');
      verify(mockService.getPayslips()).called(1);
    });

    test('should handle service errors gracefully', () async {
      when(mockService.getPayslips()).thenThrow(Exception('Service error'));

      expect(() async => await mockService.getPayslips(), throwsException);
      verify(mockService.getPayslips()).called(1);
    });
  });

  group('Payslip Performance Tests', () {
    test('should handle large payslip lists efficiently', () {
      final period = PayslipPeriod(
        month: 1,
        year: 2024,
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 1, 31),
      );

      final amounts = PayslipAmounts(
        baseSalary: 5000.0,
        overtimeHours: 0,
        overtimeAmount: 0,
        bonuses: 0,
        allowances: 0,
        commissions: 0,
        otherEarnings: 0,
        grossEarnings: 5000.0,
        socialSecurity: 500.0,
        incomeTax: 300.0,
        otherDeductions: 0,
        totalDeductions: 800.0,
        netAmount: 4200.0,
      );

      final summary = PayslipSummary(
        grossAmount: 5000.0,
        taxableAmount: 5000.0,
        nonTaxableAmount: 0,
        socialSecurityContributions: 500.0,
        incomeTax: 300.0,
        otherDeductions: 0,
        totalDeductions: 800.0,
        netAmount: 4200.0,
        yearToDateGross: 5000.0,
        yearToDateNet: 4200.0,
        yearToDateTax: 300.0,
      );

      final largePayslipList = List.generate(1000, (index) => Payslip(
        id: index.toString(),
        employeeId: 'emp$index',
        employeeName: 'Employee $index',
        employeeMatricule: 'EMP${index.toString().padLeft(3, '0')}',
        department: 'IT',
        position: 'Developer',
        period: period,
        issueDate: DateTime(2024, 1, 31),
        paymentDate: DateTime(2024, 1, 31),
        amounts: amounts,
        earnings: [],
        deductions: [],
        contributions: [],
        summary: summary,
        status: 'paid',
        createdAt: DateTime(2024, 1, 1),
      ));

      final stopwatch = Stopwatch()..start();

      final filtered = largePayslipList.where((p) => p.employeeId == 'emp1').toList();

      stopwatch.stop();

      expect(filtered.length, 1);
      expect(stopwatch.elapsedMilliseconds, lessThan(100));
    });

    test('should handle concurrent operations safely', () async {
      final period = PayslipPeriod(
        month: 1,
        year: 2024,
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 1, 31),
      );

      final amounts = PayslipAmounts(
        baseSalary: 5000.0,
        overtimeHours: 0,
        overtimeAmount: 0,
        bonuses: 0,
        allowances: 0,
        commissions: 0,
        otherEarnings: 0,
        grossEarnings: 5000.0,
        socialSecurity: 500.0,
        incomeTax: 300.0,
        otherDeductions: 0,
        totalDeductions: 800.0,
        netAmount: 4200.0,
      );

      final summary = PayslipSummary(
        grossAmount: 5000.0,
        taxableAmount: 5000.0,
        nonTaxableAmount: 0,
        socialSecurityContributions: 500.0,
        incomeTax: 300.0,
        otherDeductions: 0,
        totalDeductions: 800.0,
        netAmount: 4200.0,
        yearToDateGross: 5000.0,
        yearToDateNet: 4200.0,
        yearToDateTax: 300.0,
      );

      final payslip = Payslip(
        id: '1',
        employeeId: 'emp1',
        employeeName: 'John Doe',
        employeeMatricule: 'EMP001',
        department: 'IT',
        position: 'Developer',
        period: period,
        issueDate: DateTime(2024, 1, 31),
        paymentDate: DateTime(2024, 1, 31),
        amounts: amounts,
        earnings: [],
        deductions: [],
        contributions: [],
        summary: summary,
        status: 'paid',
        createdAt: DateTime(2024, 1, 1),
      );

      final futures = List.generate(10, (index) => 
        Future.delayed(Duration(milliseconds: index * 10), () {
          return payslip.formattedNetAmount;
        })
      );

      final results = await Future.wait(futures);

      expect(results.length, 10);
      expect(results.every((result) => result == '4200.00 EUR'), true);
    });
  });
}
