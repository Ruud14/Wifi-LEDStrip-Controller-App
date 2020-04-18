import 'package:flutter/material.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:ledstripcontroller/storage.dart';
import 'package:ledstripcontroller/dialogs.dart';

// Page to configure a new strip from the network.
class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Settings"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              SizedBox(height: 40,),
              Container(
                  width: MediaQuery.of(context).size.width/2,
                  alignment: Alignment.center,
                  child: Text("Delete all saved strips:", textAlign: TextAlign.center,)),
              SizedBox(height: 20,),
              RaisedButton(
                onPressed: () async {
                  showDialog(context: context,
                  child: ConfirmationDialog(title: "Delete all strips?", message: "Are you sure you want to delte all the strips from storage?", callback: () async {
                    Storage storage = Storage();
                    await storage.setup();
                    storage.deleteStripsFile();
                    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("All strips have been deleted.")));
                  },),
                  );
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(Icons.warning, color: Colors.black,),
                    SizedBox(width: 5,),
                    Text("Delete all strips", style: TextStyle(color: Colors.black),),
                  ],
                ),
                color: Colors.amber,
                padding: EdgeInsets.symmetric(horizontal: 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
              ),
              SizedBox(height: 20,),

              Container(
                  width: MediaQuery.of(context).size.width/2,
                  alignment: Alignment.center,
                  child: Text("Delete all saved groups:", textAlign: TextAlign.center,)),
              SizedBox(height: 20,),
              RaisedButton(
                onPressed: () async {
                  showDialog(context: context,
                  child: ConfirmationDialog(title: "Delete all groups?", message: "Are you sure you want to delete all groups from storage?", callback: () async {
                    Storage storage = Storage();
                    await storage.setup();
                    storage.deleteGroupsFile();
                    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("All groups have been deleted.")));
                  },),
                  );
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(Icons.warning, color: Colors.black,),
                    SizedBox(width: 5,),
                    Text("Delete all groups", style: TextStyle(color: Colors.black),),
                  ],
                ),
                color: Colors.amber,
                padding: EdgeInsets.symmetric(horizontal: 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
              ),
              SizedBox(height: 20,),

              Container(
                  width: MediaQuery.of(context).size.width/2,
                  alignment: Alignment.center,
                  child: Text("Delete all saved configurations:", textAlign: TextAlign.center,)),
              SizedBox(height: 20,),
              RaisedButton(
                onPressed: () async {
                  showDialog(context: context,
                    child: ConfirmationDialog(title: "Delete all configurations?", message: "Are you sure you want to delete all configurations from storage?", callback: () async {
                      Storage storage = Storage();
                      await storage.setup();
                      storage.deleteConfigurationsFile();
                      _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("All configurations have been deleted.")));
                    },),
                  );
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(Icons.warning, color: Colors.black,),
                    SizedBox(width: 5,),
                    Text("Delete all configurations", style: TextStyle(color: Colors.black),),
                  ],
                ),
                color: Colors.amber,
                padding: EdgeInsets.symmetric(horizontal: 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
              ),
              SizedBox(height: 20,),

              Container(
                  width: MediaQuery.of(context).size.width/2,
                  alignment: Alignment.center,
                  child: Text("Color theme:", textAlign: TextAlign.left,)),
              SizedBox(height: 20,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  RaisedButton(
                    onPressed: () async {
                      DynamicTheme.of(context).setBrightness(Brightness.light);
                    },
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.brightness_5, color: Colors.black,),
                        SizedBox(width: 5,),
                        Text("Bright", style: TextStyle(color: Colors.black),),
                      ],
                    ),
                    color: Colors.amber,
                    padding: EdgeInsets.symmetric(horizontal: 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
                  ),
                  RaisedButton(
                    onPressed: () {
                      DynamicTheme.of(context).setBrightness(Brightness.dark);
                    },
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.brightness_3, color: Colors.black,),
                        SizedBox(width: 5,),
                        Text("Dark", style: TextStyle(color: Colors.black),),
                      ],
                    ),
                    color: Colors.amber,
                    padding: EdgeInsets.symmetric(horizontal: 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
                  ),
                ],
              ),
              SizedBox(height: 30,),
              Container(
                  width: MediaQuery.of(context).size.width/2,
                  alignment: Alignment.center,
                  child: Text("For more info go to https://github.com/Ruud14", textAlign: TextAlign.center,)),
            ],
          ),
        ),

    );
  }
}

