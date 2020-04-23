import 'dart:convert';
import 'dart:io';
import 'package:gg_app/views/users.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:gg_app/views/surveys.dart';
import 'package:gg_app/views/mensa.dart';
import 'package:gg_app/views/auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gg_app/.env.dart' as env;


class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  SharedPreferences sharedPreferences;
  var profile;
  bool _isLoggedIn = false; 
  bool _isLoading = false;

  @override
  void initState() {
    SharedPreferences.getInstance().then((sharedPreferences) {
      setState(() =>{
        this.sharedPreferences = sharedPreferences,
        checkLoginStatus()
      });
    });
    super.initState();
  }

  bool isAuthority() {
    if (_isLoggedIn) {
      if (sharedPreferences.getBool('user.is_super_student') || sharedPreferences.getBool('user.is_teacher')) {
        return true;
      }
      return false;
    }
    return false;
  }

  checkLoginStatus() async {
    sharedPreferences = await SharedPreferences.getInstance();
    if(sharedPreferences.getString("user.token") == null) {
      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => LoginPage()), (Route<dynamic> route) => false);
    } else {
      setState(() {
        _isLoggedIn = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home Page"),
        backgroundColor: Colors.redAccent,
      ),
      drawer: new Drawer(
        child: new ListView(
          children: <Widget>[
            if(this._isLoggedIn)
              new UserAccountsDrawerHeader(
                currentAccountPicture: new CircleAvatar(
                  backgroundImage: NetworkImage("https://www.politischebildung.schulen.bayern.de/fileadmin/_processed_/6/1/csm_SMV_Logo_Web_d185e74d9d.png"),
                ),
                accountName: new Text(sharedPreferences.getString("user.name")),
                accountEmail: new Text(sharedPreferences.getString("user.email"))
              )
            else
              new Text("not logged in"),
            new ListTile(
              title: new Text("Surveys"),
              trailing: new Icon(Icons.question_answer),
              onTap: () => Navigator.of(context).push(new MaterialPageRoute(builder: (BuildContext context) => new SurveyPage())),
            ),
            new ListTile(
              title: new Text("Mensa"),
              trailing: new Icon(Icons.fastfood),
              onTap: () => Navigator.of(context).push(new MaterialPageRoute(builder: (BuildContext context) => new MensaPage())),
            ),
            new ListTile(
              title: new Text("Users"),
              trailing: new Icon(Icons.people),
              onTap: isAuthority() ? () => {
                Navigator.of(context).push(new MaterialPageRoute(builder: (BuildContext context) => new UsersPage())),
              } : null,
            ),
            new Divider(),
            new ListTile(
              title: new Text("Logout"),
              trailing: new Icon(Icons.lock),
              onTap: () => {
                sharedPreferences.remove('user.token'),
                sharedPreferences.remove('user.id'),
                sharedPreferences.remove('user.name'),
                sharedPreferences.remove('user.email'),
                sharedPreferences.remove('user.grade'),
                sharedPreferences.remove('user.is_super_student'),
                sharedPreferences.remove('user.is_tech'),
                sharedPreferences.remove('user.is_teacher'),
                sharedPreferences.remove('user.is_super_teacher'),
                Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => LoginPage()), (Route<dynamic> route) => false),
              },
            )
          ],
        ),
      ),
      body: Center(
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            new Text("The home page is work in progress!"),
            new Divider(),
            new Container(
              alignment: Alignment(-1.0, 0.0),
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  new Text("Guide for current features:"),
                  new Text("1. Press the 3 bars on the top left"),
                  new Text("2. Select surveys"),
                  new Text("3. Select a survey"),
                  new Text("4. Answer the questions and press submit"),
                ],
              ),
            ),
            new Divider(),
            new Text("to log out, press the 3 bars on the top left and select logout"),
            new Divider(),
            new Container(
              alignment: Alignment(-1.0, 0.0),
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  new Text("Upcoming features:"),
                  new Text("X check if user answered a survey already [DONE]"),
                  new Text("- change answers given to a survey"),
                  new Text("- see survey results"),
                  new Text("- mensa plan"),
                  new Text("- application logo"),
                  new Text("- survey expiration date"),
                  new Text("- school login via 'open-id'"),
                  new Text("- browser version (and non-appstore ios app)"),
                  new Text("- Admin Panel to create and manage surveys"),
                  new Text("- personalised representation table"),
                ],
              ),
            ),
          ],
        )
      ),
    );
  }
}
