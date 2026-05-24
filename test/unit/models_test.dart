import 'package:flutter_test/flutter_test.dart';
import 'package:complaint_app/models/user_model.dart';
import 'package:complaint_app/models/complaint_model.dart';
import 'package:complaint_app/models/message_model.dart';
import 'package:complaint_app/models/notification_model.dart';
import 'package:mocktail/mocktail.dart';

class MockTimestamp extends Mock {
  DateTime toDate();
}

void main() {
  group('Models Unit Tests', () {
    final now = DateTime.now();
    final mockTimestamp = MockTimestamp();
    when(() => mockTimestamp.toDate()).thenReturn(now);

    group('UserModel', () {
      test('should create UserModel from JSON', () {
        final json = {
          'uid': 'user123',
          'name': 'John Doe',
          'email': 'john@example.com',
          'role': 'admin',
          'avatarUrl': 'https://example.com/avatar.png',
          'createdAt': mockTimestamp,
          'updatedAt': mockTimestamp,
        };

        final user = UserModel.fromJson(json);

        expect(user.uid, 'user123');
        expect(user.name, 'John Doe');
        expect(user.email, 'john@example.com');
        expect(user.role, 'admin');
        expect(user.isAdmin, true);
        expect(user.avatarUrl, 'https://example.com/avatar.png');
        expect(user.createdAt, now);
      });

      test('should convert UserModel to JSON', () {
        final user = UserModel(
          uid: 'user123',
          name: 'John Doe',
          email: 'john@example.com',
          role: 'user',
          createdAt: now,
          updatedAt: now,
        );

        final json = user.toJson();

        expect(json['uid'], 'user123');
        expect(json['name'], 'John Doe');
        expect(json['role'], 'user');
        expect(json['createdAt'], now);
      });
    });

    group('ComplaintModel', () {
      test('should create ComplaintModel from JSON', () {
        final json = {
          'refId': 'REF123',
          'userId': 'user123',
          'userName': 'John Doe',
          'title': 'Broken Elevator',
          'description': 'The elevator in building A is not working.',
          'category': 'Facilities',
          'status': 'pending',
          'attachments': ['img1.jpg', 'img2.jpg'],
          'createdAt': mockTimestamp,
          'updatedAt': mockTimestamp,
        };

        final complaint = ComplaintModel.fromJson(json, id: 'complaint123');

        expect(complaint.id, 'complaint123');
        expect(complaint.refId, 'REF123');
        expect(complaint.attachments.length, 2);
        expect(complaint.status, 'pending');
      });

      test('should handle AdminResponse in JSON', () {
        final json = {
          'refId': 'REF123',
          'adminResponse': {
            'message': 'We are looking into it.',
            'respondedBy': 'Admin1',
            'respondedByTitle': 'Manager',
            'respondedAt': mockTimestamp,
            'verified': true,
          }
        };

        final complaint = ComplaintModel.fromJson(json);

        expect(complaint.adminResponse, isNotNull);
        expect(complaint.adminResponse!.message, 'We are looking into it.');
        expect(complaint.adminResponse!.verified, true);
      });
    });

    group('MessageModel', () {
      test('should create MessageModel from JSON', () {
        final json = {
          'senderId': 'sender123',
          'senderName': 'John',
          'text': 'Hello there',
          'timestamp': mockTimestamp,
        };

        final message = MessageModel.fromJson(json, id: 'msg123');

        expect(message.id, 'msg123');
        expect(message.text, 'Hello there');
        expect(message.senderName, 'John');
        expect(message.timestamp, now);
      });
    });

    group('NotificationModel', () {
      test('should create NotificationModel from JSON', () {
        final json = {
          'userId': 'user123',
          'complaintId': 'comp456',
          'title': 'Update',
          'message': 'Your complaint was updated',
          'type': 'status_update',
          'isRead': false,
          'createdAt': mockTimestamp,
        };

        final notification = NotificationModel.fromJson(json, id: 'notif123');

        expect(notification.id, 'notif123');
        expect(notification.type, 'status_update');
        expect(notification.isRead, false);
      });
    });
  });
}
