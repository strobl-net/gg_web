import 'package:flutter/material.dart';


class MensaPage extends StatefulWidget {
  @override
  _MensaPageState createState() => _MensaPageState();
}

class _MensaPageState extends State<MensaPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Mensa"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Mensa feature will be added soon',
            ),
          ],
        ),
      ),
    );
  }
}
