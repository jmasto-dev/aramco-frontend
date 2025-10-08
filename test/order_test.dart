import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:aramco_frontend/core/models/order.dart';
import 'package:aramco_frontend/core/models/order_status.dart';
import 'package:aramco_frontend/core/models/order_item.dart';
import 'package:aramco_frontend/core/services/order_service.dart';
import 'package:aramco_frontend/core/services/api_service.dart';
import 'package:aramco_frontend/core/models/api_response.dart';

import 'order_test.mocks.dart';

@GenerateMocks([ApiService])
void main() {
  group('Order Model Tests', () {
    test('Order should create with required fields', () {
      final order = Order(
        id: 'test-order-id',
        customerName: 'John Doe',
        customerEmail: 'john@example.com',
        items: [],
        totalAmount: 100.0,
        status: OrderStatus.pending,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(order.id, 'test-order-id');
      expect(order.customerName, 'John Doe');
      expect(order.customerEmail, 'john@example.com');
      expect(order.totalAmount, 100.0);
      expect(order.status, OrderStatus.pending);
    });

    test('Order should calculate total amount correctly', () {
      final items = [
        OrderItem(
          id: '1',
          productId: 'prod1',
          productName: 'Product 1',
          quantity: 2,
          unitPrice: 10.0,
          totalPrice: 20.0,
        ),
        OrderItem(
          id: '2',
          productId: 'prod2',
          productName: 'Product 2',
          quantity: 1,
          unitPrice: 30.0,
          totalPrice: 30.0,
        ),
      ];

      final order = Order(
        id: 'test-order-id',
        customerName: 'John Doe',
        customerEmail: 'john@example.com',
        items: items,
        totalAmount: 50.0,
        status: OrderStatus.pending,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(order.totalAmount, 50.0);
      expect(order.items.length, 2);
    });

    test('Order status should update correctly', () {
      var order = Order(
        id: 'test-order-id',
        customerName: 'John Doe',
        customerEmail: 'john@example.com',
        items: [],
        totalAmount: 100.0,
        status: OrderStatus.pending,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(order.status, OrderStatus.pending);

      order = order.copyWith(status: OrderStatus.confirmed);
      expect(order.status, OrderStatus.confirmed);

      order = order.copyWith(status: OrderStatus.delivered);
      expect(order.status, OrderStatus.delivered);
    });
  });

  group('OrderItem Model Tests', () {
    test('OrderItem should calculate total price correctly', () {
      final orderItem = OrderItem(
        id: 'test-item-id',
        productId: 'prod1',
        productName: 'Test Product',
        quantity: 3,
        unitPrice: 15.0,
        totalPrice: 45.0,
      );

      expect(orderItem.totalPrice, 45.0);
      expect(orderItem.quantity, 3);
      expect(orderItem.unitPrice, 15.0);
    });

    test('OrderItem should handle zero quantity', () {
      final orderItem = OrderItem(
        id: 'test-item-id',
        productId: 'prod1',
        productName: 'Test Product',
        quantity: 0,
        unitPrice: 15.0,
        totalPrice: 0.0,
      );

      expect(orderItem.totalPrice, 0.0);
      expect(orderItem.quantity, 0);
    });
  });

  group('OrderStatus Tests', () {
    test('OrderStatus should have correct display names', () {
      expect(OrderStatus.pending.displayName, 'En attente');
      expect(OrderStatus.confirmed.displayName, 'Confirmée');
      expect(OrderStatus.preparing.displayName, 'En préparation');
      expect(OrderStatus.shipped.displayName, 'Expédiée');
      expect(OrderStatus.delivered.displayName, 'Livrée');
      expect(OrderStatus.cancelled.displayName, 'Annulée');
    });

    test('OrderStatus should have correct colors', () {
      expect(OrderStatus.pending.color, Colors.orange);
      expect(OrderStatus.confirmed.color, Colors.blue);
      expect(OrderStatus.preparing.color, Colors.purple);
      expect(OrderStatus.shipped.color, Colors.teal);
      expect(OrderStatus.delivered.color, Colors.green);
      expect(OrderStatus.cancelled.color, Colors.red);
    });
  });

  group('OrderService Tests', () {
    late OrderService orderService;
    late MockApiService mockApiService;

    setUp(() {
      mockApiService = MockApiService();
      orderService = OrderService(mockApiService);
    });

    test('getOrders should return orders list on success', () async {
      final mockResponse = {
        'success': true,
        'data': [
          {
            'id': 'order1',
            'customerName': 'John Doe',
            'customerEmail': 'john@example.com',
            'items': [],
            'totalAmount': 100.0,
            'status': 'pending',
            'createdAt': '2023-01-01T00:00:00Z',
            'updatedAt': '2023-01-01T00:00:00Z',
          }
        ],
        'message': 'Orders retrieved successfully',
      };

      when(mockApiService.get(any, queryParameters: anyNamed('queryParameters')))
          .thenAnswer((_) async => mockResponse);

      final result = await orderService.getOrders();

      expect(result.isSuccess, true);
      expect(result.data, isNotNull);
      expect(result.data!.length, 1);
      expect(result.data!.first.customerName, 'John Doe');
    });

    test('getOrders should handle error response', () async {
      final mockResponse = {
        'success': false,
        'error': 'Failed to retrieve orders',
      };

      when(mockApiService.get(any, queryParameters: anyNamed('queryParameters')))
          .thenAnswer((_) async => mockResponse);

      final result = await orderService.getOrders();

      expect(result.isSuccess, false);
      expect(result.errorMessage, 'Failed to retrieve orders');
      expect(result.data, isNull);
    });

    test('getOrderById should return order on success', () async {
      final mockResponse = {
        'success': true,
        'data': {
          'id': 'order1',
          'customerName': 'John Doe',
          'customerEmail': 'john@example.com',
          'items': [],
          'totalAmount': 100.0,
          'status': 'pending',
          'createdAt': '2023-01-01T00:00:00Z',
          'updatedAt': '2023-01-01T00:00:00Z',
        },
        'message': 'Order retrieved successfully',
      };

      when(mockApiService.get(any))
          .thenAnswer((_) async => mockResponse);

      final result = await orderService.getOrderById('order1');

      expect(result.isSuccess, true);
      expect(result.data, isNotNull);
      expect(result.data!.id, 'order1');
      expect(result.data!.customerName, 'John Doe');
    });

    test('createOrder should return created order on success', () async {
      final mockResponse = {
        'success': true,
        'data': {
          'id': 'new-order',
          'customerName': 'Jane Smith',
          'customerEmail': 'jane@example.com',
          'items': [],
          'totalAmount': 150.0,
          'status': 'pending',
          'createdAt': '2023-01-01T00:00:00Z',
          'updatedAt': '2023-01-01T00:00:00Z',
        },
        'message': 'Order created successfully',
      };

      when(mockApiService.post(any, data: anyNamed('data')))
          .thenAnswer((_) async => mockResponse);

      final newOrder = Order(
        id: 'new-order',
        customerName: 'Jane Smith',
        customerEmail: 'jane@example.com',
        items: [],
        totalAmount: 150.0,
        status: OrderStatus.pending,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final result = await orderService.createOrder(newOrder);

      expect(result.isSuccess, true);
      expect(result.data, isNotNull);
      expect(result.data!.customerName, 'Jane Smith');
      expect(result.data!.totalAmount, 150.0);
    });

    test('updateOrderStatus should return updated order on success', () async {
      final mockResponse = {
        'success': true,
        'data': {
          'id': 'order1',
          'customerName': 'John Doe',
          'customerEmail': 'john@example.com',
          'items': [],
          'totalAmount': 100.0,
          'status': 'confirmed',
          'createdAt': '2023-01-01T00:00:00Z',
          'updatedAt': '2023-01-01T01:00:00Z',
        },
        'message': 'Order status updated successfully',
      };

      when(mockApiService.patch(any, data: anyNamed('data')))
          .thenAnswer((_) async => mockResponse);

      final result = await orderService.updateOrderStatus('order1', OrderStatus.confirmed);

      expect(result.isSuccess, true);
      expect(result.data, isNotNull);
      expect(result.data!.status, OrderStatus.confirmed);
    });

    test('cancelOrder should return cancelled order on success', () async {
      final mockResponse = {
        'success': true,
        'data': {
          'id': 'order1',
          'customerName': 'John Doe',
          'customerEmail': 'john@example.com',
          'items': [],
          'totalAmount': 100.0,
          'status': 'cancelled',
          'createdAt': '2023-01-01T00:00:00Z',
          'updatedAt': '2023-01-01T01:00:00Z',
        },
        'message': 'Order cancelled successfully',
      };

      when(mockApiService.patch(any, data: anyNamed('data')))
          .thenAnswer((_) async => mockResponse);

      final result = await orderService.cancelOrder('order1');

      expect(result.isSuccess, true);
      expect(result.data, isNotNull);
      expect(result.data!.status, OrderStatus.cancelled);
    });
  });

  group('Order Validation Tests', () {
    test('Order should require valid email', () {
      expect(() => Order(
        id: 'test-order-id',
        customerName: 'John Doe',
        customerEmail: 'invalid-email',
        items: [],
        totalAmount: 100.0,
        status: OrderStatus.pending,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ), throwsA(anything));
    });

    test('Order should require non-empty customer name', () {
      expect(() => Order(
        id: 'test-order-id',
        customerName: '',
        customerEmail: 'john@example.com',
        items: [],
        totalAmount: 100.0,
        status: OrderStatus.pending,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ), throwsA(anything));
    });

    test('Order should require non-negative total amount', () {
      expect(() => Order(
        id: 'test-order-id',
        customerName: 'John Doe',
        customerEmail: 'john@example.com',
        items: [],
        totalAmount: -10.0,
        status: OrderStatus.pending,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ), throwsA(anything));
    });
  });

  group('Order Calculations Tests', () {
    test('Order should calculate total from items correctly', () {
      final items = [
        OrderItem(
          id: '1',
          productId: 'prod1',
          productName: 'Product 1',
          quantity: 2,
          unitPrice: 25.0,
          totalPrice: 50.0,
        ),
        OrderItem(
          id: '2',
          productId: 'prod2',
          productName: 'Product 2',
          quantity: 3,
          unitPrice: 10.0,
          totalPrice: 30.0,
        ),
      ];

      final calculatedTotal = items.fold<double>(
        0, (sum, item) => sum + item.totalPrice,
      );

      expect(calculatedTotal, 80.0);
    });

    test('OrderItem should handle decimal prices correctly', () {
      final orderItem = OrderItem(
        id: 'test-item-id',
        productId: 'prod1',
        productName: 'Test Product',
        quantity: 2,
        unitPrice: 19.99,
        totalPrice: 39.98,
      );

      expect(orderItem.totalPrice, 39.98);
      expect(orderItem.unitPrice, 19.99);
    });
  });
}
