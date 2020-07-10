/// Meteor connection for dart
/// This library is a meteor client warpper
library meteor;

export 'src/accounts.dart';
export 'src/meteor_client.dart';
export 'src/ddp_client.dart' if (dart.library.js) 'src/ddp_client_js.dart';
