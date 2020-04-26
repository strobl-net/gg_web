import 'package:flutter/material.dart';
import 'package:gg_app/.env.dart' as env;
import 'package:photo_view/photo_view.dart';


class MensaPage extends StatefulWidget {
  @override
  _MensaPageState createState() => _MensaPageState();
}

class _MensaPageState extends State<MensaPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Menus"),
      ),
      body: new Container(
        child: new PhotoView(
        imageProvider:  new NetworkImage(env.environment["mensaUrl"].toString())
        )
      )
    );
  }
}
