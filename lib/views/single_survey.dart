import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import 'package:gg_app/.env.dart' as env;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SingleSurveyPage extends StatefulWidget {
  final survey;

  SingleSurveyPage({Key key, @required this.survey}) : super(key: key);

  @override
  _SingleSurveyPageState createState() => _SingleSurveyPageState(survey);
}


class _SingleSurveyPageState extends State<SingleSurveyPage> {
  SharedPreferences sharedPreferences;
  bool _isLoading = false;
  var survey;
  List optionsList;
  List<String> surveyAnswers;
  List<TextEditingController> textController;

  _SingleSurveyPageState (this.survey);

  _putAnswer() async {
    setState(() => {
      _isLoading = true,
    });

    Map data = {
      "user_id": sharedPreferences.getString("user.id"),
      "survey_id": survey["id"],
      "answers": surveyAnswers
    };

    var baseUrl = env.environment['baseUrl'];
    final url = "$baseUrl/api/answers/";
    final response = await http.post(
      url,
      body: json.encode(data),
      headers: {
        "Content-Type" : "application/json",
        "Authorization": "Token " + sharedPreferences.getString("user.token")
        }
      );
    if (response.statusCode == 201) {
      setState(() => {
        _isLoading = false,
      });
      Navigator.of(context).pop(this);
    } else {
      print(response.statusCode);
    }
  }
  @override
  void dispose() {
    for(var textController in this.textController) {
      textController.dispose();
    }
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((sharedPreferences) {
      setState(() =>{
        this.sharedPreferences = sharedPreferences  
      });
    });
    this.surveyAnswers = [for(var i=0; i<this.survey["questions"].length; i++) ""];
    this.textController = [for(var i=0; i<this.survey["questions"].length; i++) new TextEditingController()];
    this.optionsList = [for(var i=0; i<this.survey["questions"].length; i++) -1];
    for (var controller in this.textController) {
        controller.addListener(this.setTextValues);
    }
  }

  void setTextValues() {
    for (var i=0; i<this.survey["questions"].length; i++) {
      if (this.survey["questions"][i]["type"] == "text" || this.survey["questions"][i]["type"] == "number") {
        this.surveyAnswers[i] = textController[i].text;
        setState(() {
        });
      }
    }
  }

  bool checkCorrect() {
    for (var i=0; i<this.survey["questions"].length; i++) {
      if (this.survey["questions"][i]["type"] == "text" || this.survey["questions"][i]["type"] == "number"){
        if (this.surveyAnswers[i] == ""){
          return false;
        }
      }
      if (this.survey["questions"][i]["type"] == "radio"){
        if (this.surveyAnswers[i] == null || this.surveyAnswers[i] == "" || this.surveyAnswers[i] == -1){
          return false;
        }
      }  
    }
    return true;
  }

  @override
    Widget build(BuildContext context) {
      return new Scaffold (
        appBar: new AppBar(
          title: Text(this.survey["name"]),
        ),
        body: new Column (
          children: <Widget>[
            new Expanded(
              child: new ListView.builder(
                itemCount: this.survey["questions"] != null ? this.survey["questions"].length : 0,
                itemBuilder: (context, i) {
                  final question = this.survey["questions"][i];
                  return new Container(
                    margin: const EdgeInsets.all(8.0),
                    child: new Column(
                      children: <Widget>[
                        new Container(
                          alignment: Alignment(-1.0, 0.0),
                          color: Colors.amber,
                          child: new Text(question["question"] + (question["required"]? " *" : "")),
                        ),
                        if (question["type"] == "text")
                          new Container(
                            color: Colors.white,
                            child: new TextField(
                              controller: this.textController[i],
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Your Answer'
                            ), 
                            )
                          )
                        else if (question["type"] == "number")
                          new Container(
                            color: Colors.white,
                            child: new TextField(
                              controller: this.textController[i],
                              keyboardType: TextInputType.number,
                              inputFormatters: <TextInputFormatter>[
                                WhitelistingTextInputFormatter.digitsOnly
                              ],
                            )
                          )
                        else if (question["type"] == "radio")
                          for (var option in question["options"])
                            new RadioListTile<int>(
                              title: new Text(option["name"]),
                              value: option["value"],
                              groupValue: this.optionsList[i],
                              onChanged: (int value) {
                                setState(() => {
                                  this.optionsList[i] = value,
                                  this.surveyAnswers[i] = value.toString(),
                                });
                              }
                            )
                        else
                          new Text("Invalid / No Type given")
                      ],
                    )
                  ); 
                },
              ),
            ),
          
          new RaisedButton(
            onPressed: checkCorrect()? () => {
              this._putAnswer(),
            } : null,
            child: Text(
              'Submit',
              style: TextStyle(fontSize: 20)
            ),
          ),
        ],
      )
    );
  }
}