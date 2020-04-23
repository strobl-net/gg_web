import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:gg_app/views/home.dart';
import 'package:gg_app/.env.dart' as env;


class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = new TextEditingController();
  final TextEditingController passwordController = new TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    emailController.addListener(reload);
    passwordController.addListener(reload);
    super.initState();
  }

  void reload() {
    setState(() => {});
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent));
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [Colors.blue, Colors.teal],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter),
        ),
        child: _isLoading ? Center(child: CircularProgressIndicator()) : ListView(
          children: <Widget>[
            headerSection(),
            textSection(),
            buttonSection(),
          ],
        ),
      ),
    );
  }

  _fetchProfile() async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    setState(() => {
      _isLoading = true,
    });
    var baseUrl = env.environment['baseUrl'];
    final url = "$baseUrl/api/profiles/" + sharedPreferences.getString('user.id');
    final response = await http.get(
      url,
      headers: {
        "Authorization": "Token " + sharedPreferences.getString("user.token")
      });

    if (response.statusCode == 200) {
      final profile = jsonDecode(response.body);

      setState(() => {
        _isLoading = false,
      });
      
      sharedPreferences.setString("user.grade", profile['grade']);
      sharedPreferences.setBool("user.is_super_student", profile['is_super_student']);
      sharedPreferences.setBool("user.is_tech", profile['is_tech']);
      sharedPreferences.setBool("user.is_teacher", profile['is_teacher']);
      sharedPreferences.setBool("user.is_super_teacher", profile['is_super_teacher']);
      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => HomePage()), (Route<dynamic> route) => true);
    } else {
      print(response.body);
    }
  }

  signIn(String email, password) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    Map credentials = {
      'username': email,
      'password': password,
    };

    var baseUrl = env.environment['baseUrl'];
    var user;
    var response = await http.post("$baseUrl/api/auth/login/", body: credentials);
    if(response.statusCode == 200) {
      user = json.decode(response.body);
      if(user != null) {
        setState(() => {
          _fetchProfile()
        });
        sharedPreferences.setString("user.token", user['token']);
        sharedPreferences.setString("user.id", user["user"]['id'].toString());
        sharedPreferences.setString("user.name", user['user']['username']);
        sharedPreferences.setString("user.email", user['user']['email']);
      }
    }
    else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Container buttonSection() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 40.0,
      padding: EdgeInsets.symmetric(horizontal: 15.0),
      margin: EdgeInsets.only(top: 15.0),
      child: RaisedButton(
        onPressed: emailController.text == "" || passwordController.text == "" ? null : () {
          setState(() {
            _isLoading = true;
          });
          signIn(emailController.text, passwordController.text);
        },
        elevation: 0.0,
        color: Colors.purple,
        child: Text("Sign In", style: TextStyle(color: Colors.white70)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
      ),
    );
  }



  Container textSection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
      child: Column(
        children: <Widget>[
          TextFormField(
            controller: emailController,
            cursorColor: Colors.white,
            style: TextStyle(color: Colors.white70),
            decoration: InputDecoration(
              icon: Icon(Icons.email, color: Colors.white70),
              hintText: "Username",
              border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white70)),
              hintStyle: TextStyle(color: Colors.white70),
            ),
          ),
          SizedBox(height: 30.0),
          TextFormField(
            controller: passwordController,
            cursorColor: Colors.white,
            obscureText: true,
            style: TextStyle(color: Colors.white70),
            decoration: InputDecoration(
              icon: Icon(Icons.lock, color: Colors.white70),
              hintText: "Password",
              border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white70)),
              hintStyle: TextStyle(color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }

  Container headerSection() {
    return Container(
      margin: EdgeInsets.only(top: 50.0),
      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
      child: Text("My GG",
        style: TextStyle(
        color: Colors.white70,
        fontSize: 40.0,
        fontWeight: FontWeight.bold)),
    );
  }
}