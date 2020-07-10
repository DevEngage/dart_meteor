import 'package:flutter_meteor/meteor.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Meteor().connect(url: 'http://127.0.0.1:3000');
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _methodResult = '';

  void _callMethod() {
    Meteor().call('helloMethod', []).then((result) {
      setState(() {
        _methodResult = result.toString();
      });
    }).catchError((err) {
      if (err is MeteorError) {
        setState(() {
          _methodResult = err.message;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Package dart_meteor Example'),
        ),
        body: Container(
          padding: EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              StreamBuilder<DdpConnectionStatus>(
                stream: Meteor().status(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data.status ==
                        DdpConnectionStatusValues.connected) {
                      return RaisedButton(
                        child: Text('Disconnect'),
                        onPressed: () {
                          Meteor().disconnect();
                        },
                      );
                    }
                    return RaisedButton(
                      child: Text('Connect'),
                      onPressed: () {
                        Meteor().reconnect();
                      },
                    );
                  }
                  return Container();
                },
              ),
              StreamBuilder<DdpConnectionStatus>(
                stream: Meteor().status(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Text('Meteor Status ${snapshot.data.toString()}');
                  }
                  return Text('Meteor Status: ---');
                },
              ),
              StreamBuilder(
                  stream: Meteor().userIdStream(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return RaisedButton(
                        child: Text('Logout'),
                        onPressed: () {
                          Meteor().logout();
                        },
                      );
                    }
                    return RaisedButton(
                      child: Text('Login'),
                      onPressed: () {
                        Meteor().loginWithPassword('test', 'test');
                      },
                    );
                  }),
              StreamBuilder(
                stream: Meteor().userStream(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Text(snapshot.data.toString());
                  }
                  return Text('User: ----');
                },
              ),
              RaisedButton(
                child: Text('Method Call'),
                onPressed: _callMethod,
              ),
              Text(_methodResult),
            ],
          ),
        ),
      ),
    );
  }
}
