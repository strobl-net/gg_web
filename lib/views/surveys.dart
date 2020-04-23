import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:gg_app/.env.dart' as env;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gg_app/views/single_survey.dart';

class SurveyPage extends StatefulWidget {
  @override
  _SurveyPageState createState() => _SurveyPageState();
}

class _SurveyPageState extends State<SurveyPage> {
  SharedPreferences sharedPreferences;
  bool _isLoading = false;
  var surveys;
  var filteredAnswers;

  _fetchSurveys() async {
    setState(() => {
      _isLoading = true,
    });
    var baseUrl = env.environment['baseUrl'];
    final url = "$baseUrl/api/surveys/";
    final response = await http.get(
      url,
      headers: {
        "Authorization": "Token " + sharedPreferences.getString("user.token")
      });

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      setState(() => {
        this.surveys = data,
        _isLoading = false,
        _fetchUserAnswers(),
      });
    }
  }

  _fetchUserAnswers() async {
    setState(() => {
      _isLoading = true,
    });

    var baseUrl = env.environment['baseUrl'];
    final url = "$baseUrl/api/answers/?user_id=" + sharedPreferences.getString('user.id');
    final response = await http.get(
      url,
      headers: {
        "Authorization": "Token " + sharedPreferences.getString("user.token")
      });

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      setState(() => {
        this.filteredAnswers = data,
        _isLoading = false,
      });
    } else {
      print(response.statusCode);
    }
  }

  _checkAnswered(var i) {
      for (var j = 0; j < this.filteredAnswers.length; j++) {
        if (this.surveys[i]['id'] == this.filteredAnswers[j]['survey_id']) {
          return true;
        }
      }
    return false;
  }

  @override
  void initState() {
    SharedPreferences.getInstance().then((sharedPreferences) {
      setState(() =>{
        this.sharedPreferences = sharedPreferences,
        _fetchSurveys(),
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Surveys"),
        actions: <Widget> [
          new IconButton(icon: new Icon(Icons.refresh),
          onPressed: () => {
            _fetchSurveys()
          })
        ],
      ),
      body: Center(
        child: _isLoading ? new CircularProgressIndicator() :
          new ListView.builder(
            itemCount: this.surveys != null ? this.surveys.length : 0,
            itemBuilder: (context, i) {
              final survey = this.surveys[i];
              if (!this._checkAnswered(i))
                return new FlatButton( 
                  onPressed: () => {
                    Navigator.push(context, 
                      new MaterialPageRoute(
                        builder: (context) => new SingleSurveyPage(
                          survey: survey)
                      )).then((value) {
                        this._fetchSurveys();
                        final snackBar = SnackBar(
                          content: Text("Survey has been answered!"),
                        );
                        Scaffold.of(context).showSnackBar(snackBar);
                      }),
                  },
                  child: new Column(
                    children: <Widget>[
                      new Card(
                        child: Column (
                          children: <Widget>[
                            new ListTile(
                              leading: new Icon(Icons.alarm_add),
                              title: new Text(survey["name"]),
                              subtitle: new Text(survey["description"]),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              else
              return new FlatButton( 
                  onPressed: () {
                    final snackBar = SnackBar(
                      content: Text("You have already answered this survey! (changing answers coming soon!)"),
                      action: SnackBarAction(
                        label: "Change Answer",
                        onPressed: () {

                        },
                      ),
                    );
                    Scaffold.of(context).showSnackBar(snackBar);
                    },
                  child: new Column(
                    children: <Widget>[
                      new Card(
                        color: new Color.fromRGBO(0, 0, 0, 0),
                        child: Column (
                          children: <Widget>[
                            new ListTile(
                              leading: new Icon(Icons.alarm_on),
                              title: new Text(survey["name"]),
                              subtitle: new Text(survey["description"]),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
              );
            },
          )
      ),
    );
  }
}
