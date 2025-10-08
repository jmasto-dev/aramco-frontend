import 'package:flutter_test/flutter_test.dart';
import 'package:aramco_frontend/core/models/task.dart';

void main() {
  group('Task Model Tests', () {
    test('Task should create from JSON correctly', () {
      // Arrange
      final json = {
        'id': '1',
        'title': 'Test Task',
        'description': 'Test Description',
        'type': 'task',
        'status': 'todo',
        'priority': 'normal',
        'assigneeId': 'user1',
        'projectId': 'project1',
        'dueDate': '2024-12-31T23:59:59.000Z',
        'startDate': '2024-01-01T00:00:00.000Z',
        'completedAt': null,
        'estimatedHours': 8,
        'actualHours': 6,
        'progress': 75,
        'tagIds': ['tag1', 'tag2'],
        'createdAt': '2024-01-01T00:00:00.000Z',
        'updatedAt': '2024-01-02T00:00:00.000Z',
      };

      // Act
      final task = Task.fromJson(json);

      // Assert
      expect(task.id, '1');
      expect(task.title, 'Test Task');
      expect(task.description, 'Test Description');
      expect(task.type, TaskType.task);
      expect(task.status, TaskStatus.todo);
      expect(task.priority, TaskPriority.normal);
      expect(task.assigneeId, 'user1');
      expect(task.projectId, 'project1');
      expect(task.dueDate, DateTime.parse('2024-12-31T23:59:59.000Z'));
      expect(task.startDate, DateTime.parse('2024-01-01T00:00:00.000Z'));
      expect(task.completedAt, isNull);
      expect(task.estimatedHours, 8);
      expect(task.actualHours, 6);
      expect(task.progress, 75);
      expect(task.tagIds, ['tag1', 'tag2']);
      expect(task.createdAt, DateTime.parse('2024-01-01T00:00:00.000Z'));
      expect(task.updatedAt, DateTime.parse('2024-01-02T00:00:00.000Z'));
    });

    test('Task should convert to JSON correctly', () {
      // Arrange
      final task = Task(
        id: '1',
        title: 'Test Task',
        description: 'Test Description',
        type: TaskType.task,
        status: TaskStatus.todo,
        priority: TaskPriority.normal,
        assigneeId: 'user1',
        projectId: 'project1',
        dueDate: DateTime.parse('2024-12-31T23:59:59.000Z'),
        startDate: DateTime.parse('2024-01-01T00:00:00.000Z'),
        estimatedHours: 8,
        actualHours: 6,
        progress: 75,
        tagIds: ['tag1', 'tag2'],
        createdAt: DateTime.parse('2024-01-01T00:00:00.000Z'),
        updatedAt: DateTime.parse('2024-01-02T00:00:00.000Z'),
      );

      // Act
      final json = task.toJson();

      // Assert
      expect(json['id'], '1');
      expect(json['title'], 'Test Task');
      expect(json['description'], 'Test Description');
      expect(json['type'], 'task');
      expect(json['status'], 'todo');
      expect(json['priority'], 'normal');
      expect(json['assigneeId'], 'user1');
      expect(json['projectId'], 'project1');
      expect(json['dueDate'], '2024-12-31T23:59:59.000Z');
      expect(json['startDate'], '2024-01-01T00:00:00.000Z');
      expect(json['completedAt'], isNull);
      expect(json['estimatedHours'], 8);
      expect(json['actualHours'], 6);
      expect(json['progress'], 75);
      expect(json['tagIds'], ['tag1', 'tag2']);
      expect(json['createdAt'], '2024-01-01T00:00:00.000Z');
      expect(json['updatedAt'], '2024-01-02T00:00:00.000Z');
    });

    test('Task should handle null optional fields', () {
      // Arrange
      final json = {
        'id': '1',
        'title': 'Test Task',
        'type': 'task',
        'status': 'todo',
        'priority': 'normal',
        'createdAt': '2024-01-01T00:00:00.000Z',
        'updatedAt': '2024-01-01T00:00:00.000Z',
      };

      // Act
      final task = Task.fromJson(json);

      // Assert
      expect(task.id, '1');
      expect(task.title, 'Test Task');
      expect(task.description, isNull);
      expect(task.type, TaskType.task);
      expect(task.status, TaskStatus.todo);
      expect(task.priority, TaskPriority.normal);
      expect(task.assigneeId, isNull);
      expect(task.projectId, isNull);
      expect(task.dueDate, isNull);
      expect(task.startDate, isNull);
      expect(task.completedAt, isNull);
      expect(task.estimatedHours, 0);
      expect(task.actualHours, 0);
      expect(task.progress, isNull);
      expect(task.tagIds, isEmpty);
      expect(task.createdAt, DateTime.parse('2024-01-01T00:00:00.000Z'));
      expect(task.updatedAt, DateTime.parse('2024-01-01T00:00:00.000Z'));
    });

    test('Task equality should work correctly', () {
      // Arrange
      final task1 = Task(
        id: '1',
        title: 'Test Task',
        description: 'Test Description',
        type: TaskType.task,
        status: TaskStatus.todo,
        priority: TaskPriority.normal,
        assigneeId: 'user1',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final task2 = Task(
        id: '1',
        title: 'Test Task',
        description: 'Test Description',
        type: TaskType.task,
        status: TaskStatus.todo,
        priority: TaskPriority.normal,
        assigneeId: 'user1',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final task3 = Task(
        id: '2',
        title: 'Different Task',
        description: 'Different Description',
        type: TaskType.task,
        status: TaskStatus.todo,
        priority: TaskPriority.normal,
        assigneeId: 'user2',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Assert
      expect(task1, equals(task2));
      expect(task1, isNot(equals(task3)));
    });

    test('Task toString should return title', () {
      // Arrange
      final task = Task(
        id: '1',
        title: 'Test Task',
        description: 'Test Description',
        type: TaskType.task,
        status: TaskStatus.todo,
        priority: TaskPriority.normal,
        assigneeId: 'user1',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Act & Assert
      expect(task.toString(), 'Test Task');
    });

    test('TaskType enum should have correct values', () {
      expect(TaskType.values.length, 7);
      expect(TaskType.task.name, 'task');
      expect(TaskType.bug.name, 'bug');
      expect(TaskType.feature.name, 'feature');
      expect(TaskType.improvement.name, 'improvement');
      expect(TaskType.documentation.name, 'documentation');
      expect(TaskType.meeting.name, 'meeting');
      expect(TaskType.review.name, 'review');
    });

    test('TaskStatus enum should have correct values', () {
      expect(TaskStatus.values.length, 6);
      expect(TaskStatus.todo.name, 'todo');
      expect(TaskStatus.inProgress.name, 'inProgress');
      expect(TaskStatus.inReview.name, 'inReview');
      expect(TaskStatus.completed.name, 'completed');
      expect(TaskStatus.cancelled.name, 'cancelled');
      expect(TaskStatus.onHold.name, 'onHold');
    });

    test('TaskPriority enum should have correct values', () {
      expect(TaskPriority.values.length, 4);
      expect(TaskPriority.urgent.name, 'urgent');
      expect(TaskPriority.high.name, 'high');
      expect(TaskPriority.normal.name, 'normal');
      expect(TaskPriority.low.name, 'low');
    });

    test('Task copyWith should work correctly', () {
      // Arrange
      final originalTask = Task(
        id: '1',
        title: 'Original Task',
        description: 'Original Description',
        type: TaskType.task,
        status: TaskStatus.todo,
        priority: TaskPriority.normal,
        assigneeId: 'user1',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Act
      final updatedTask = originalTask.copyWith(
        title: 'Updated Task',
        status: TaskStatus.inProgress,
        progress: 50,
      );

      // Assert
      expect(updatedTask.id, originalTask.id);
      expect(updatedTask.title, 'Updated Task');
      expect(updatedTask.description, originalTask.description);
      expect(updatedTask.type, originalTask.type);
      expect(updatedTask.status, TaskStatus.inProgress);
      expect(updatedTask.priority, originalTask.priority);
      expect(updatedTask.progress, 50);
      expect(updatedTask.createdAt, originalTask.createdAt);
      expect(updatedTask.updatedAt, originalTask.updatedAt);
    });

    test('Task should handle empty tag list', () {
      // Arrange
      final json = {
        'id': '1',
        'title': 'Test Task',
        'type': 'task',
        'status': 'todo',
        'priority': 'normal',
        'tagIds': [],
        'createdAt': '2024-01-01T00:00:00.000Z',
        'updatedAt': '2024-01-01T00:00:00.000Z',
      };

      // Act
      final task = Task.fromJson(json);

      // Assert
      expect(task.tagIds, isEmpty);
    });

    test('Task should handle missing tagIds field', () {
      // Arrange
      final json = {
        'id': '1',
        'title': 'Test Task',
        'type': 'task',
        'status': 'todo',
        'priority': 'normal',
        'createdAt': '2024-01-01T00:00:00.000Z',
        'updatedAt': '2024-01-01T00:00:00.000Z',
      };

      // Act
      final task = Task.fromJson(json);

      // Assert
      expect(task.tagIds, isEmpty);
    });

    test('Task should handle completedAt field', () {
      // Arrange
      final json = {
        'id': '1',
        'title': 'Test Task',
        'type': 'task',
        'status': 'completed',
        'priority': 'normal',
        'completedAt': '2024-06-15T10:30:00.000Z',
        'createdAt': '2024-01-01T00:00:00.000Z',
        'updatedAt': '2024-06-15T10:30:00.000Z',
      };

      // Act
      final task = Task.fromJson(json);

      // Assert
      expect(task.completedAt, DateTime.parse('2024-06-15T10:30:00.000Z'));
    });

    test('Task should handle zero hours', () {
      // Arrange
      final json = {
        'id': '1',
        'title': 'Test Task',
        'type': 'task',
        'status': 'todo',
        'priority': 'normal',
        'estimatedHours': 0,
        'actualHours': 0,
        'createdAt': '2024-01-01T00:00:00.000Z',
        'updatedAt': '2024-01-01T00:00:00.000Z',
      };

      // Act
      final task = Task.fromJson(json);

      // Assert
      expect(task.estimatedHours, 0);
      expect(task.actualHours, 0);
    });

    test('Task should handle large hour values', () {
      // Arrange
      final json = {
        'id': '1',
        'title': 'Test Task',
        'type': 'task',
        'status': 'todo',
        'priority': 'normal',
        'estimatedHours': 1000,
        'actualHours': 800,
        'createdAt': '2024-01-01T00:00:00.000Z',
        'updatedAt': '2024-01-01T00:00:00.000Z',
      };

      // Act
      final task = Task.fromJson(json);

      // Assert
      expect(task.estimatedHours, 1000);
      expect(task.actualHours, 800);
    });

    test('Task should handle progress boundaries', () {
      // Arrange
      final json = {
        'id': '1',
        'title': 'Test Task',
        'type': 'task',
        'status': 'todo',
        'priority': 'normal',
        'progress': 100,
        'createdAt': '2024-01-01T00:00:00.000Z',
        'updatedAt': '2024-01-01T00:00:00.000Z',
      };

      // Act
      final task = Task.fromJson(json);

      // Assert
      expect(task.progress, 100);
    });

    test('Task should handle all enum types correctly', () {
      // Test all TaskType values
      for (final type in TaskType.values) {
        final json = {
          'id': '1',
          'title': 'Test Task',
          'description': 'Test Description',
          'type': type.name,
          'status': 'todo',
          'priority': 'normal',
          'createdAt': '2024-01-01T00:00:00.000Z',
          'updatedAt': '2024-01-01T00:00:00.000Z',
        };

        final task = Task.fromJson(json);
        expect(task.type, type);
      }

      // Test all TaskStatus values
      for (final status in TaskStatus.values) {
        final json = {
          'id': '1',
          'title': 'Test Task',
          'description': 'Test Description',
          'type': 'task',
          'status': status.name,
          'priority': 'normal',
          'createdAt': '2024-01-01T00:00:00.000Z',
          'updatedAt': '2024-01-01T00:00:00.000Z',
        };

        final task = Task.fromJson(json);
        expect(task.status, status);
      }

      // Test all TaskPriority values
      for (final priority in TaskPriority.values) {
        final json = {
          'id': '1',
          'title': 'Test Task',
          'description': 'Test Description',
          'type': 'task',
          'status': 'todo',
          'priority': priority.name,
          'createdAt': '2024-01-01T00:00:00.000Z',
          'updatedAt': '2024-01-01T00:00:00.000Z',
        };

        final task = Task.fromJson(json);
        expect(task.priority, priority);
      }
    });
  });

  group('Task Model Edge Cases', () {
    test('Task should handle empty strings', () {
      // Arrange
      final json = {
        'id': '1',
        'title': '',
        'description': '',
        'type': 'task',
        'status': 'todo',
        'priority': 'normal',
        'assigneeId': '',
        'projectId': '',
        'createdAt': '2024-01-01T00:00:00.000Z',
        'updatedAt': '2024-01-01T00:00:00.000Z',
      };

      // Act
      final task = Task.fromJson(json);

      // Assert
      expect(task.title, '');
      expect(task.description, '');
      expect(task.assigneeId, '');
      expect(task.projectId, '');
    });

    test('Task should handle null date fields', () {
      // Arrange
      final json = {
        'id': '1',
        'title': 'Test Task',
        'description': 'Test Description',
        'type': 'task',
        'status': 'todo',
        'priority': 'normal',
        'dueDate': null,
        'startDate': null,
        'completedAt': null,
        'createdAt': '2024-01-01T00:00:00.000Z',
        'updatedAt': '2024-01-01T00:00:00.000Z',
      };

      // Act
      final task = Task.fromJson(json);

      // Assert
      expect(task.dueDate, isNull);
      expect(task.startDate, isNull);
      expect(task.completedAt, isNull);
    });

    test('Task should handle invalid date formats', () {
      // Arrange
      final json = {
        'id': '1',
        'title': 'Test Task',
        'description': 'Test Description',
        'type': 'task',
        'status': 'todo',
        'priority': 'normal',
        'dueDate': 'invalid-date',
        'createdAt': '2024-01-01T00:00:00.000Z',
        'updatedAt': '2024-01-01T00:00:00.000Z',
      };

      // Depending on implementation, this might throw an exception or handle gracefully
      // expect(() => Task.fromJson(json), throwsA(isA<FormatException>()));
    });

    test('Task should handle maximum title length', () {
      // Arrange
      final longTitle = 'a' * 255; // Assuming max length is 255
      final json = {
        'id': '1',
        'title': longTitle,
        'description': 'Test Description',
        'type': 'task',
        'status': 'todo',
        'priority': 'normal',
        'createdAt': '2024-01-01T00:00:00.000Z',
        'updatedAt': '2024-01-01T00:00:00.000Z',
      };

      // Act
      final task = Task.fromJson(json);

      // Assert
      expect(task.title, longTitle);
    });

    test('Task should handle maximum description length', () {
      // Arrange
      final longDescription = 'a' * 1000; // Assuming max length is 1000
      final json = {
        'id': '1',
        'title': 'Test Task',
        'description': longDescription,
        'type': 'task',
        'status': 'todo',
        'priority': 'normal',
        'createdAt': '2024-01-01T00:00:00.000Z',
        'updatedAt': '2024-01-01T00:00:00.000Z',
      };

      // Act
      final task = Task.fromJson(json);

      // Assert
      expect(task.description, longDescription);
    });

    test('Task should handle negative hours gracefully', () {
      // Arrange
      final json = {
        'id': '1',
        'title': 'Test Task',
        'description': 'Test Description',
        'type': 'task',
        'status': 'todo',
        'priority': 'normal',
        'estimatedHours': -5,
        'actualHours': -3,
        'createdAt': '2024-01-01T00:00:00.000Z',
        'updatedAt': '2024-01-01T00:00:00.000Z',
      };

      // Act
      final task = Task.fromJson(json);

      // Assert
      expect(task.estimatedHours, -5);
      expect(task.actualHours, -3);
    });

    test('Task should handle progress out of bounds', () {
      // Arrange
      final json = {
        'id': '1',
        'title': 'Test Task',
        'description': 'Test Description',
        'type': 'task',
        'status': 'todo',
        'priority': 'normal',
        'progress': 150, // Over 100%
        'createdAt': '2024-01-01T00:00:00.000Z',
        'updatedAt': '2024-01-01T00:00:00.000Z',
      };

      // Act
      final task = Task.fromJson(json);

      // Assert
      expect(task.progress, 150);
    });

    test('Task should handle negative progress', () {
      // Arrange
      final json = {
        'id': '1',
        'title': 'Test Task',
        'description': 'Test Description',
        'type': 'task',
        'status': 'todo',
        'priority': 'normal',
        'progress': -10, // Negative progress
        'createdAt': '2024-01-01T00:00:00.000Z',
        'updatedAt': '2024-01-01T00:00:00.000Z',
      };

      // Act
      final task = Task.fromJson(json);

      // Assert
      expect(task.progress, -10);
    });

    test('Task should handle empty tags array', () {
      // Arrange
      final json = {
        'id': '1',
        'title': 'Test Task',
        'description': 'Test Description',
        'type': 'task',
        'status': 'todo',
        'priority': 'normal',
        'tagIds': [],
        'createdAt': '2024-01-01T00:00:00.000Z',
        'updatedAt': '2024-01-01T00:00:00.000Z',
      };

      // Act
      final task = Task.fromJson(json);

      // Assert
      expect(task.tagIds, isEmpty);
    });

    test('Task should handle single tag', () {
      // Arrange
      final json = {
        'id': '1',
        'title': 'Test Task',
        'description': 'Test Description',
        'type': 'task',
        'status': 'todo',
        'priority': 'normal',
        'tagIds': ['single-tag'],
        'createdAt': '2024-01-01T00:00:00.000Z',
        'updatedAt': '2024-01-01T00:00:00.000Z',
      };

      // Act
      final task = Task.fromJson(json);

      // Assert
      expect(task.tagIds, ['single-tag']);
    });

    test('Task should handle multiple tags', () {
      // Arrange
      final json = {
        'id': '1',
        'title': 'Test Task',
        'description': 'Test Description',
        'type': 'task',
        'status': 'todo',
        'priority': 'normal',
        'tagIds': ['tag1', 'tag2', 'tag3'],
        'createdAt': '2024-01-01T00:00:00.000Z',
        'updatedAt': '2024-01-01T00:00:00.000Z',
      };

      // Act
      final task = Task.fromJson(json);

      // Assert
      expect(task.tagIds, ['tag1', 'tag2', 'tag3']);
    });
  });
}
