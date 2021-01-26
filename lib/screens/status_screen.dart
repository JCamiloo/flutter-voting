import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:band_names/providers/socket_provider.dart';

class StatusScreen extends StatelessWidget {
  const StatusScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    final socket = Provider.of<SocketProvider>(context);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Server status: ${socket.serverStatus}')
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.message),
        onPressed: () {
          socket.emit('emit-message', { 'name': 'Juan', 'message': 'Hello world' });
        },
      ),
    );
  }
}