import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:aramco_frontend/core/services/api_service.dart';
import 'package:aramco_frontend/core/services/order_service.dart';
import 'package:aramco_frontend/core/models/order.dart';
import 'package:aramco_frontend/core/models/order_status.dart';
import 'package:aramco_frontend/core/models/api_response.dart';

import 'order_service_test.mocks.dart';

@GenerateMocks([ApiService])
void main() {
  group('OrderService Tests', () {
    late OrderService orderService;
    late MockApiService mockApiService;

    setUp(() {
      mockApiService = MockApiService();
      orderService = OrderService();
    });

    group('getOrders', () {
      test('should return list of orders when API call is successful', () async {
        // Arrange
        final mockResponse = {
          'success': true,
          'data': [
            {
              'id': '1',
              'customerId': 'cust_1',
              'customerName': 'John Doe',
              'customerEmail': 'john@example.com',
              'customerPhone': '+1234567890',
              'status': 'pending',
              'totalAmount': 100.0,
              'taxAmount': 20.0,
              'shippingAmount': 10.0,
              'currency': 'EUR',
              'items': [],
              'createdAt': '2023-01-01T00:00:00.000Z',
              'updatedAt': '2023-01-01T00:00:00.000Z',
              'shippingAddress': {
                'street': '123 Main St',
                'city': 'Paris',
                'postalCode': '75001',
                'country': 'France',
              },
              'paymentInfo': {
                'id': 'pay_1',
                'method': 'creditCard',
                'status': 'pending',
                'amount': 100.0,
                'currency': 'EUR',
              },
              'statusHistory': [],
              'attachments': [],
            }
          ],
          'pagination': {
            'currentPage': 1,
            'totalPages': 1,
            'totalItems': 1,
            'hasNextPage': false,
            'hasPreviousPage': false,
          }
        };

        when(mockApiService.get('/orders', queryParameters: anyNamed('queryParameters')))
            .thenAnswer((_) async => mockResponse);

        // Act
        final result = await orderService.getOrders();

        // Assert
        expect(result.isSuccess, true);
        expect(result.data, isNotNull);
        expect(result.data!.length, 1);
        expect(result.data!.first.customerName, 'John Doe');
        verify(mockApiService.get('/orders', queryParameters: anyNamed('queryParameters'))).called(1);
      });

      test('should return failure when API call fails', () async {
        // Arrange
        final mockResponse = {
          'success': false,
          'message': 'Failed to fetch orders'
        };

        when(mockApiService.get('/orders', queryParameters: anyNamed('queryParameters')))
            .thenAnswer((_) async => mockResponse);

        // Act
        final result = await orderService.getOrders();

        // Assert
        expect(result.isSuccess, false);
        expect(result.message, 'Failed to fetch orders');
        expect(result.data, isNull);
        verify(mockApiService.get('/orders', queryParameters: anyNamed('queryParameters'))).called(1);
      });

      test('should handle API exception', () async {
        // Arrange
        when(mockApiService.get('/orders', queryParameters: anyNamed('queryParameters')))
            .thenThrow(Exception('Network error'));

        // Act
        final result = await orderService.getOrders();

        // Assert
        expect(result.isSuccess, false);
        expect(result.message, contains('Network error'));
        expect(result.data, isNull);
        verify(mockApiService.get('/orders', queryParameters: anyNamed('queryParameters'))).called(1);
      });
    });

    group('getOrderById', () {
      test('should return order when found', () async {
        // Arrange
        final orderId = '1';
        final mockResponse = {
          'success': true,
          'data': {
            'id': orderId,
            'customerId': 'cust_1',
            'customerName': 'John Doe',
            'customerEmail': 'john@example.com',
            'customerPhone': '+1234567890',
            'status': 'pending',
            'totalAmount': 100.0,
            'taxAmount': 20.0,
            'shippingAmount': 10.0,
            'currency': 'EUR',
            'items': [],
            'createdAt': '2023-01-01T00:00:00.000Z',
            'updatedAt': '2023-01-01T00:00:00.000Z',
            'shippingAddress': {
              'street': '123 Main St',
              'city': 'Paris',
              'postalCode': '75001',
              'country': 'France',
            },
            'paymentInfo': {
              'id': 'pay_1',
              'method': 'creditCard',
              'status': 'pending',
              'amount': 100.0,
              'currency': 'EUR',
            },
            'statusHistory': [],
            'attachments': [],
          }
        };

        when(mockApiService.get('/orders/$orderId'))
            .thenAnswer((_) async => mockResponse);

        // Act
        final result = await orderService.getOrderById(orderId);

        // Assert
        expect(result.isSuccess, true);
        expect(result.data?.id, orderId);
        expect(result.data?.customerName, 'John Doe');
        verify(mockApiService.get('/orders/$orderId')).called(1);
      });

      test('should return failure when order not found', () async {
        // Arrange
        final orderId = '999';
        final mockResponse = {
          'success': false,
          'message': 'Order not found'
        };

        when(mockApiService.get('/orders/$orderId'))
            .thenAnswer((_) async => mockResponse);

        // Act
        final result = await orderService.getOrderById(orderId);

        // Assert
        expect(result.isSuccess, false);
        expect(result.message, 'Order not found');
        expect(result.data, isNull);
        verify(mockApiService.get('/orders/$orderId')).called(1);
      });
    });

    group('createOrder', () {
      test('should create order successfully', () async {
        // Arrange
        final order = Order(
          id: '',
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

        final mockResponse = {
          'success': true,
          'data': {
            'id': '1',
            ...order.toJson(),
          }
        };

        when(mockApiService.post('/orders', data: anyNamed('data')))
            .thenAnswer((_) async => mockResponse);

        // Act
        final result = await orderService.createOrder(order);

        // Assert
        expect(result.isSuccess, true);
        expect(result.data?.id, '1');
        expect(result.data?.customerName, 'John Doe');
        verify(mockApiService.post('/orders', data: anyNamed('data'))).called(1);
      });

      test('should return failure when creation fails', () async {
        // Arrange
        final order = Order(
          id: '',
          customerId: 'cust_1',
          customerName: '',
          customerEmail: '',
          customerPhone: '',
          status: OrderStatus.pending,
          totalAmount: 0.0,
          taxAmount: 0.0,
          shippingAmount: 0.0,
          currency: 'EUR',
          items: [],
          createdAt: DateTime.now(),
          shippingAddress: const ShippingAddress(
            street: '',
            city: '',
            postalCode: '',
            country: '',
          ),
          paymentInfo: const PaymentInfo(
            id: 'pay_1',
            method: PaymentMethod.creditCard,
            status: PaymentStatus.pending,
            amount: 0.0,
            currency: 'EUR',
          ),
        );

        final mockResponse = {
          'success': false,
          'message': 'Validation failed'
        };

        when(mockApiService.post('/orders', data: anyNamed('data')))
            .thenAnswer((_) async => mockResponse);

        // Act
        final result = await orderService.createOrder(order);

        // Assert
        expect(result.isSuccess, false);
        expect(result.message, 'Validation failed');
        expect(result.data, isNull);
        verify(mockApiService.post('/orders', data: anyNamed('data'))).called(1);
      });
    });

    group('updateOrder', () {
      test('should update order successfully', () async {
        // Arrange
        final order = Order(
          id: '1',
          customerId: 'cust_1',
          customerName: 'John Doe Updated',
          customerEmail: 'john@example.com',
          customerPhone: '+1234567890',
          status: OrderStatus.processing,
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

        final mockResponse = {
          'success': true,
          'data': order.toJson(),
        };

        when(mockApiService.put('/orders/${order.id}', data: anyNamed('data')))
            .thenAnswer((_) async => mockResponse);

        // Act
        final result = await orderService.updateOrder(order);

        // Assert
        expect(result.isSuccess, true);
        expect(result.data?.customerName, 'John Doe Updated');
        expect(result.data?.status, OrderStatus.processing);
        verify(mockApiService.put('/orders/${order.id}', data: anyNamed('data'))).called(1);
      });

      test('should return failure when update fails', () async {
        // Arrange
        final order = Order(
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

        final mockResponse = {
          'success': false,
          'message': 'Update failed'
        };

        when(mockApiService.put('/orders/${order.id}', data: anyNamed('data')))
            .thenAnswer((_) async => mockResponse);

        // Act
        final result = await orderService.updateOrder(order);

        // Assert
        expect(result.isSuccess, false);
        expect(result.message, 'Update failed');
        verify(mockApiService.put('/orders/${order.id}', data: anyNamed('data'))).called(1);
      });
    });

    group('deleteOrder', () {
      test('should delete order successfully', () async {
        // Arrange
        final orderId = '1';
        final mockResponse = {
          'success': true,
          'message': 'Order deleted successfully'
        };

        when(mockApiService.delete('/orders/$orderId'))
            .thenAnswer((_) async => mockResponse);

        // Act
        final result = await orderService.deleteOrder(orderId);

        // Assert
        expect(result.isSuccess, true);
        expect(result.message, 'Order deleted successfully');
        verify(mockApiService.delete('/orders/$orderId')).called(1);
      });

      test('should return failure when delete fails', () async {
        // Arrange
        final orderId = '1';
        final mockResponse = {
          'success': false,
          'message': 'Delete failed'
        };

        when(mockApiService.delete('/orders/$orderId'))
            .thenAnswer((_) async => mockResponse);

        // Act
        final result = await orderService.deleteOrder(orderId);

        // Assert
        expect(result.isSuccess, false);
        expect(result.message, 'Delete failed');
        verify(mockApiService.delete('/orders/$orderId')).called(1);
      });
    });

    group('updateOrderStatus', () {
      test('should update order status successfully', () async {
        // Arrange
        final orderId = '1';
        final newStatus = OrderStatus.processing;
        final mockResponse = {
          'success': true,
          'data': {
            'id': orderId,
            'status': newStatus.name,
          }
        };

        when(mockApiService.patch('/orders/$orderId/status', data: anyNamed('data')))
            .thenAnswer((_) async => mockResponse);

        // Act
        final result = await orderService.updateOrderStatus(orderId, newStatus);

        // Assert
        expect(result.isSuccess, true);
        expect(result.data?.status, newStatus);
        verify(mockApiService.patch('/orders/$orderId/status', data: anyNamed('data'))).called(1);
      });

      test('should return failure when status update fails', () async {
        // Arrange
        final orderId = '1';
        final newStatus = OrderStatus.processing;
        final mockResponse = {
          'success': false,
          'message': 'Status update failed'
        };

        when(mockApiService.patch('/orders/$orderId/status', data: anyNamed('data')))
            .thenAnswer((_) async => mockResponse);

        // Act
        final result = await orderService.updateOrderStatus(orderId, newStatus);

        // Assert
        expect(result.isSuccess, false);
        expect(result.message, 'Status update failed');
        verify(mockApiService.patch('/orders/$orderId/status', data: anyNamed('data'))).called(1);
      });
    });
  });
}
