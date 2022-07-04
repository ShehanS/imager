import 'dart:async';

import 'package:flutter/material.dart';



enum DialogAction { yes, no }

class CustomDialog {
  static Future<DialogAction> simpleDialog(
      BuildContext context, String title, String body) async {
    final action = await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            title: Text(title),
            content: Text(body),
            actions: <Widget>[
              TextButton(
                  onPressed: () => Navigator.of(context).pop(DialogAction.no),
                  child: const Text("NO", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold))),
              TextButton(
                  onPressed: () => Navigator.of(context).pop(DialogAction.yes),
                  child: const Text("YES", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold))),
            ],
          );
        });
    return (action != null) ? action : DialogAction.no;
  }

  static loadingDialog(BuildContext context , String text) async {
    AlertDialog loadingDialog = AlertDialog(
      shape:
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 0,
      content: SizedBox(
        width: 200,
        height: 100,
        child: Center(
            child: Column(
              children: <Widget>[
                Text(text, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                const Padding(
                  padding: EdgeInsets.only(top: 30.0),
                  child: CircularProgressIndicator(),
                ),
              ],
            )
        ),
      ),
    );
    await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return WillPopScope(onWillPop: (){
          return Future.value(false);
        }, child: loadingDialog);
      },
    );
  }

}
