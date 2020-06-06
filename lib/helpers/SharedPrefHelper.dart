import 'dart:convert';

import 'package:deleco/model/objects/Pod.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class SharedPrefHelper{

  static final String sharedPod="pods";
  static Future<void> persistData(List<Pod> pods) async{

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(sharedPod, json.encode(pods));
  }

  static Future<String> getData() async{

    SharedPreferences prefs = await SharedPreferences.getInstance();
    //Return String
    String stringValue = prefs.getString(sharedPod);
    if(stringValue!=null){
      return stringValue;
    }else{
      return null;
    }

  }
}