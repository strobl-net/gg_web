import 'package:flutter/material.dart';
import 'package:gg_app/views/home.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(GGApp());

class GGApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    // build android app
    //  flutter build apk --split-per-abi

    //comment mockvalues in release!
    //SharedPreferences.setMockInitialValues({});
    
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

