import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:aramco_frontend/presentation/providers/order_provider.dart';
import 'package:aramco_frontend/core/services/order_service.dart';
import 'package:aramco_frontend/core/models/order.dart';
import 'package:aramco_frontend/core/models/order_status.dart';
import 'package:aramco_frontend/core/models/api_response.dart';

import 'order_provider_test.mocks.dart';

@GenerateMocks([OrderService])
void main() {
  group('OrderProvider Tests', () {
    late MockOrderService mockOrderService;
    late ProviderContainer container;
    late OrderNotifier orderNotifier;

    setUp(() {
      mockOrderService = MockOrderService();
      container = ProviderContainer(
        overrides: [
          orderServiceProvider.overrideWithValue(mockOrderService),
        ],
      );
      orderNotifier = container.read(orderProvider.notifier);
    });

    tearDown(() {
      container.dispose();
    });

    group('loadOrders', () {
      test('should load orders successfully', () async {
        // Arrange
        final mockOrders = [
          Order(
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
          ),
        ];

        final mockResponse = ApiResponse<List<Order>>.success(mockOrders);
        when(mockOrderService.getOrders())
            .thenAnswer((_) async => mockResponse);

        // Act
        await orderNotifier.loadOrders();

        // Assert
        final state = container.read(orderProvider);
        expect(state.isLoading, false);
        expect(state.orders, mockOrders);
        expect(state.error, isNull);
        verify(mockOrderService.getOrders()).called(1);
      });

      test('should handle loading error', () async {
        // Arrange
        final mockResponse = ApiResponse<List<Order>>.failure('Failed to load orders');
        when(mockOrderService.getOrders())
            .thenAnswer((_) async => mockResponse);

        // Act
        await orderNotifier.loadOrders();

        // Assert
        final state = container.read(orderProvider);
        expect(state.isLoading, false);
        expect(state.orders, isEmpty);
        expect(state.error, 'Failed to load orders');
        verify(mockOrderService.getOrders()).called(1);
      });

      test('should set loading state during fetch', () async {
        // Arrange
        final completer = Completer<ApiResponse<List<Order>>>();
        when(mockOrderService.getOrders())
            .thenAnswer((_) async => completer.future);

        // Act
        final future = orderNotifier.loadOrders();

        // Assert - loading state should be true
        expect(container.read(orderProvider).isLoading, true);

        // Complete the future
        completer.complete(ApiResponse<List<Order>>.success([]));
        await future;

        // Assert - loading state should be false
        expect(container.read(orderProvider).isLoading, false);
      });
    });

    group('createOrder', () {
      test('should create order successfully', () async {
        // Arrange
        final newOrder = Order(
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

        final createdOrder = newOrder.copyWith(id: '1');
        final mockResponse = ApiResponse<Order>.success(createdOrder);
        when(mockOrderService.createOrder(newOrder))
            .thenAnswer((_) async => mockResponse);

        // Act
        await orderNotifier.createOrder(newOrder);

        // Assert
        final state = container.read(orderProvider);
        expect(state.isCreating, false);
        expect(state.orders, contains(createdOrder));
        expect(state.error, isNull);
        verify(mockOrderService.createOrder(newOrder)).called(1);
      });

      test('should handle creation error', () async {
        // Arrange
        final newOrder = Order(
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

        final mockResponse = ApiResponse<Order>.failure('Failed to create order');
        when(mockOrderService.createOrder(newOrder))
            .thenAnswer((_) async => mockResponse);

        // Act
        await orderNotifier.createOrder(newOrder);

        // Assert
        final state = container.read(orderProvider);
        expect(state.isCreating, false);
        expect(state.error, 'Failed to create order');
        verify(mockOrderService.createOrder(newOrder)).called(1);
      });
    });

    group('updateOrder', () {
      test('should update order successfully', () async {
        // Arrange
        final existingOrder = Order(
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

        final updatedOrder = existingOrder.copyWith(
          customerName: 'John Doe Updated',
          status: OrderStatus.processing,
        );

        final mockResponse = ApiResponse<Order>.success(updatedOrder);
        when(mockOrderService.updateOrder(updatedOrder))
            .thenAnswer((_) async => mockResponse);

        // Set initial state
        container.read(orderProvider.notifier).state = 
            const OrderState().copyWith(orders: [existingOrder]);

        // Act
        await orderNotifier.updateOrder(updatedOrder);

        // Assert
        final state = container.read(orderProvider);
        expect(state.isUpdating, false);
        expect(state.orders, contains(updatedOrder));
        expect(state.orders.first.customerName, 'John Doe Updated');
        expect(state.orders.first.status, OrderStatus.processing);
        verify(mockOrderService.updateOrder(updatedOrder)).called(1);
      });
    });

    group('deleteOrder', () {
      test('should delete order successfully', () async {
        // Arrange
        final orderToDelete = Order(
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

        final mockResponse = ApiResponse<void>.success(null);
        when(mockOrderService.deleteOrder('1'))
            .thenAnswer((_) async => mockResponse);

        // Set initial state
        container.read(orderProvider.notifier).state = 
            const OrderState().copyWith(orders: [orderToDelete]);

        // Act
        await orderNotifier.deleteOrder('1');

        // Assert
        final state = container.read(orderProvider);
        expect(state.isDeleting, false);
        expect(state.orders, isEmpty);
        verify(mockOrderService.deleteOrder('1')).called(1);
      });
    });

    group('updateOrderStatus', () {
      test('should update order status successfully', () async {
        // Arrange
        final existingOrder = Order(
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

        final updatedOrder = existingOrder.copyWith(status: OrderStatus.processing);
        final mockResponse = ApiResponse<Order>.success(updatedOrder);
        when(mockOrderService.updateOrderStatus('1', OrderStatus.processing))
            .thenAnswer((_) async => mockResponse);

        // Set initial state
        container.read(orderProvider.notifier).state = 
            const OrderState().copyWith(orders: [existingOrder]);

        // Act
        await orderNotifier.updateOrderStatus('1', OrderStatus.processing);

        // Assert
        final state = container.read(orderProvider);
        expect(state.isUpdating, false);
        expect(state.orders.first.status, OrderStatus.processing);
        verify(mockOrderService.updateOrderStatus('1', OrderStatus.processing)).called(1);
      });
    });

    group('clearError', () {
      test('should clear error state', () async {
        // Arrange
        container.read(orderProvider.notifier).state = 
            const OrderState().copyWith(error: 'Some error');

        // Act
        orderNotifier.clearError();

        // Assert
        final state = container.read(orderProvider);
        expect(state.error, isNull);
      });
    });

    group('refresh', () {
      test('should refresh orders', () async {
        // Arrange
        final mockOrders = [
          Order(
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
          ),
        ];

        final mockResponse = ApiResponse<List<Order>>.success(mockOrders);
        when(mockOrderService.getOrders())
            .thenAnswer((_) async => mockResponse);

        // Act
        await orderNotifier.refresh();

        // Assert
        final state = container.read(orderProvider);
        expect(state.isLoading, false);
        expect(state.orders, mockOrders);
        expect(state.error, isNull);
        verify(mockOrderService.getOrders()).called(1);
      });
    });
  });
}
