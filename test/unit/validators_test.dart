import 'package:flutter_test/flutter_test.dart';
import 'package:complaint_app/core/utils/validators.dart';

void main() {
  group('Validators Unit Tests', () {
    group('validateEmail', () {
      test('should return error for null or empty email', () {
        expect(Validators.validateEmail(null), 'Email is required.');
        expect(Validators.validateEmail(''), 'Email is required.');
        expect(Validators.validateEmail('   '), 'Email is required.');
      });

      test('should return error for invalid email format', () {
        expect(Validators.validateEmail('test'), 'Please enter a valid email address.');
        expect(Validators.validateEmail('test@'), 'Please enter a valid email address.');
        expect(Validators.validateEmail('@test.com'), 'Please enter a valid email address.');
        expect(Validators.validateEmail('test@com'), 'Please enter a valid email address.');
      });

      test('should return null for valid email format', () {
        expect(Validators.validateEmail('test@example.com'), null);
        expect(Validators.validateEmail('user.name@company.org'), null);
      });
    });

    group('validatePassword', () {
      test('should return error for null or empty password', () {
        expect(Validators.validatePassword(null), 'Password is required.');
        expect(Validators.validatePassword(''), 'Password is required.');
      });

      test('should return error for password less than 6 characters', () {
        expect(Validators.validatePassword('12345'), 'Password must be at least 6 characters.');
      });

      test('should return null for valid password', () {
        expect(Validators.validatePassword('123456'), null);
        expect(Validators.validatePassword('password123'), null);
      });
    });

    group('validateName', () {
      test('should return error for null or empty name', () {
        expect(Validators.validateName(null), 'Name is required.');
        expect(Validators.validateName(''), 'Name is required.');
      });

      test('should return error for name less than 2 characters', () {
        expect(Validators.validateName('A'), 'Name must be at least 2 characters.');
      });

      test('should return null for valid name', () {
        expect(Validators.validateName('John Doe'), null);
      });
    });

    group('validateDescription', () {
      test('should return error if description is too short', () {
        expect(Validators.validateDescription('Short desc'), 'Please provide at least 20 characters for the description.');
      });

      test('should return null for long enough description', () {
        expect(Validators.validateDescription('This is a long enough description for testing purposes.'), null);
      });
    });

    group('validateConfirmPassword', () {
      test('should return error for null or empty confirm password', () {
        expect(Validators.validateConfirmPassword(null, 'password123'), 'Please confirm your password.');
        expect(Validators.validateConfirmPassword('', 'password123'), 'Please confirm your password.');
      });

      test('should return error if passwords do not match', () {
        expect(Validators.validateConfirmPassword('mismatch', 'password123'), 'Passwords do not match.');
      });

      test('should return null if passwords match', () {
        expect(Validators.validateConfirmPassword('password123', 'password123'), null);
      });
    });

    group('validateRequired', () {
      test('should return error for null or empty value', () {
        expect(Validators.validateRequired(null, 'Title'), 'Title is required.');
        expect(Validators.validateRequired('', 'Category'), 'Category is required.');
        expect(Validators.validateRequired('   ', 'Field'), 'Field is required.');
      });

      test('should return null for non-empty value', () {
        expect(Validators.validateRequired('Technical Issue', 'Title'), null);
      });
    });
  });
}
