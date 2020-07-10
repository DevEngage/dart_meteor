import 'dart:async';
import './meteor_client.dart';

/// Provides useful methods of the `accounts-password` Meteor package.
///
/// Assumes, your Meteor server uses the `accounts-password` package.
class Accounts {
  /// Creates a new user using [username], [email], [password] and a [profile] map.
  ///
  /// Returns the `userId` of the created user.
  static Future<MeteorClientLoginResult> createUser(String username,
      String email, String password, Map<String, String> profile) async {
    Completer completer = Completer<MeteorClientLoginResult>();
    if (Meteor.isConnected) {
      var map = {
        'username': username,
        'email': email,
        'password': password,
        'profile': profile
      };
      try {
        var result = await Meteor().call('createUser', [map]);
        if (Meteor.showDebug) print(result);
        //Handle result
        Meteor().notifyLoginResult(result, completer);
      } catch (error) {
        Meteor().handleLoginError(error, completer);
      }
    } else {
      completer.completeError('Not connected to server');
    }
    return completer.future;
  }

  /// Change the user account password provided the user is already logged in.
  static Future<String> changePassword(
      String oldPassword, String newPassword) async {
    Completer completer = Completer<String>();
    if (Meteor.isConnected) {
      var result =
          await Meteor().call('changePassword', [oldPassword, newPassword]);
      if (Meteor.showDebug) print(result);
      //Handle result
      if (result['passwordChanged'] != null) {
        completer.complete('Password changed');
      } else {
        _notifyError(completer, result);
      }
    } else {
      if (Meteor.showDebug) print('Not connected to server');
      completer.completeError('Not connected to server');
    }
    return completer.future;
  }

  /// Sends a `forgotPassword` email to the user with a link to reset the password.
  static Future<String> forgotPassword(String email) async {
    Completer completer = Completer<String>();
    if (Meteor.isConnected) {
      var result = await Meteor().call('forgotPassword', [
        {'email': email}
      ]);
      if (Meteor.showDebug) print(result);
      //Handle result
      if (result == null) {
        completer.complete('Email sent');
      } else {
        _notifyError(completer, result);
      }
    } else {
      if (Meteor.showDebug) print('Not connected to server');
      completer.completeError('Not connected to server');
    }
    return completer.future;
  }

  /// Resets the user password by taking the [passwordResetToken] and the [newPassword].
  static Future<String> resetPassword(
      String passwordResetToken, String newPassword) async {
    Completer completer = Completer<String>();
    if (Meteor.isConnected) {
      var result = await Meteor()
          .call('resetPassword', [passwordResetToken, newPassword]);
      if (result['error'] != null) {
        _notifyError(completer, result);
      } else {
        completer.complete(result.toString());
      }
    } else {
      if (Meteor.showDebug) print('Not connected to server');
      completer.completeError('Not connected to server');
    }
    return completer.future;
  }

  /// Verifies the user email by taking the [verificationToken] sent to the user.
  static Future<String> verifyEmail(String verificationToken) async {
    Completer completer = Completer<String>();
    if (Meteor.isConnected) {
      var result = await Meteor().call('verifyEmail', [verificationToken]);
      if (result['error'] != null) {
        _notifyError(completer, result);
      } else {
        completer.complete(result.toString());
      }
    } else {
      if (Meteor.showDebug) print('Not connected to server');
      completer.completeError('Not connected to server');
    }
    return completer.future;
  }

  /// Notifies a future with the error.
  ///
  /// This error can be handled using `catchError` if using the `Future` directly.
  /// And using the `try-catch` block, if using the `await` feature.
  static void _notifyError(Completer completer, dynamic result) {
    completer.completeError(result['reason']);
  }
}
