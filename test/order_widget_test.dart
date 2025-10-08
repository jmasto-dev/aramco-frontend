import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aramco_frontend/presentation/screens/orders_screen.dart';
import 'package:aramco_frontend/presentation/widgets/order_card.dart';
import 'package:aramco_frontend/presentation/widgets/status_badge.dart';
import 'package:aramco_frontend/core/models/order.dart';
import 'package:aramco_frontend/core/models/order_status.dart';

void main() {
  group('Order Widget Tests', () {
    late Order testOrder;

    setUp(() {
      testOrder = Order(
        id: '1',
        customerId: 'cust_1',
        customerName: 'John Doe',
        customerEmail: 'john@example.com',
        customerPhone: '+1234567890',
        status: OrderStatus.pending,
        totalAmount: 100.0,
        taxAmount: 20.0,
        shippingAmount: 10.0,
        currency: 'EUR',
        items: [],
        createdAt: DateTime.now(),
        shippingAddress: const ShippingAddress(
          street: '123 Main St',
          city: 'Paris',
          postalCode: '75001',
          country: 'France',
        ),
        paymentInfo: const PaymentInfo(
          id: 'pay_1',
          method: PaymentMethod.creditCard,
          status: PaymentStatus.pending,
          amount: 100.0,
          currency: 'EUR',
        ),
      );
    });

    group('StatusBadge Widget', () {
      testWidgets('should display pending status correctly', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: StatusBadge(status: OrderStatus.pending),
            ),
          ),
        );

        expect(find.text('En attente'), findsOneWidget);
        expect(find.byIcon(Icons.pending), findsOneWidget);
      });

      testWidgets('should display processing status correctly', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: StatusBadge(status: OrderStatus.processing),
            ),
          ),
        );

        expect(find.text('En traitement'), findsOneWidget);
        expect(find.byIcon(Icons.pending_actions), findsOneWidget);
      });

      testWidgets('should display shipped status correctly', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: StatusBadge(status: OrderStatus.shipped),
            ),
          ),
        );

        expect(find.text('Expédié'), findsOneWidget);
        expect(find.byIcon(Icons.local_shipping), findsOneWidget);
      });

      testWidgets('should display delivered status correctly', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: StatusBadge(status: OrderStatus.delivered),
            ),
          ),
        );

        expect(find.text('Livré'), findsOneWidget);
        expect(find.byIcon(Icons.check_circle), findsOneWidget);
      });

      testWidgets('should display cancelled status correctly', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: StatusBadge(status: OrderStatus.cancelled),
            ),
          ),
        );

        expect(find.text('Annulé'), findsOneWidget);
        expect(find.byIcon(Icons.cancel), findsOneWidget);
      });
    });

    group('OrderCard Widget', () {
      testWidgets('should display order information correctly', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: OrderCard(
                order: testOrder,
                onTap: () {},
              ),
            ),
          ),
        );

        expect(find.textContaining('CMD-'), findsOneWidget);
        expect(find.text('John Doe'), findsOneWidget);
        expect(find.text('100.00 €'), findsOneWidget);
        expect(find.text('En attente'), findsOneWidget);
      });

      testWidgets('should call onTap when card is tapped', (WidgetTester tester) async {
        bool wasTapped = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: OrderCard(
                order: testOrder,
                onTap: () => wasTapped = true,
              ),
            ),
          ),
        );

        await tester.tap(find.byType(OrderCard));
        await tester.pump();

        expect(wasTapped, isTrue);
      });

      testWidgets('should display order date correctly', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: OrderCard(
                order: testOrder,
                onTap: () {},
              ),
            ),
          ),
        );

        expect(find.byType(OrderCard), findsOneWidget);
        expect(find.textContaining('Créée le'), findsOneWidget);
      });

      testWidgets('should display customer email', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: OrderCard(
                order: testOrder,
                onTap: () {},
              ),
            ),
          ),
        );

        expect(find.text('john@example.com'), findsOneWidget);
      });
    });

    group('OrdersScreen Widget', () {
      testWidgets('should display loading state', (WidgetTester tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: OrdersScreen(),
            ),
          ),
        );

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.text('Chargement des commandes...'), findsOneWidget);
      });

      testWidgets('should display app bar with correct title', (WidgetTester tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: OrdersScreen(),
            ),
          ),
        );

        expect(find.text('Commandes'), findsOneWidget);
      });

      testWidgets('should display search button', (WidgetTester tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: OrdersScreen(),
            ),
          ),
        );

        expect(find.byIcon(Icons.search), findsOneWidget);
      });

      testWidgets('should display filter button', (WidgetTester tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: OrdersScreen(),
            ),
          ),
        );

        expect(find.byIcon(Icons.filter_list), findsOneWidget);
      });

      testWidgets('should display export button', (WidgetTester tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: OrdersScreen(),
            ),
          ),
        );

        expect(find.byIcon(Icons.download), findsOneWidget);
      });
    });
  });
}
