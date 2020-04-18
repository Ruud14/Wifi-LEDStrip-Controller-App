import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ledstripcontroller/ledstrip.dart';
import 'package:ledstripcontroller/storage.dart';
import 'package:ledstripcontroller/dialogs.dart';
import 'package:ledstripcontroller/configuration.dart';
import 'dart:io';

// Page to make changes to a specific ledstrip.
class StripControl extends StatefulWidget {
  @override
  _StripControlState createState() => _StripControlState();
}

class _StripControlState extends State<StripControl> {

  Map data;
  LedStrip strip;
  Function deleteFunc;
  Function rebootFunc;
  List<String> stripNames = [];

  // Populates 'stripNames' with the names from all the strips from the storage.
  void getAllStripNames() async
  {
    Storage storage = Storage();
    await storage.setup();
    await storage.getStrips().then((savedStrips)
    {
      setState(() {
        for(int i=0; i < savedStrips.length; i++)
          {
            stripNames.add(savedStrips[i].name);
          }
      });
    });
  }

  // Changes the name of 'strip'.
  // Doesn't change anything in storage.
  void changeStripName(String value)
  {
    // dont't allow a name that already exists or an empty name.
    if(value != "" && !stripNames.contains(value))
    {
      strip.name = value;
    }
  }

  @override
  void initState() {
    super.initState();
    getAllStripNames();
  }

  @override
  Widget build(BuildContext context) {
    data = ModalRoute.of(context).settings.arguments;
    strip = data['strip'];
    deleteFunc = data['deleteFunc'];
    rebootFunc = data['rebootFunc'];

    return Scaffold(
      appBar: AppBar(
        title: Text(strip.name),
        centerTitle: true,
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () async
              {
                Navigator.pop(context, strip);
              }
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 10,),
            Container(
                width: MediaQuery.of(context).size.width/2,
                alignment: Alignment.center,
                child: Text("IP: "+strip.ip, textAlign: TextAlign.center,)),
            SizedBox(height: 30,),
            Container(
              width: MediaQuery.of(context).size.width/2,
              alignment: Alignment.bottomLeft,
                child: Text("Name:", textAlign: TextAlign.left,)),
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width/2,
                child: TextFormField(
                  initialValue: strip.name,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(15),
                  ],
                  onChanged: (String value) {
                    setState(() {
                      changeStripName(value);
                    });
                  },
                ),
              ),
            ),
            SizedBox(height: 40,),
            Container(
              child: Center(
                child: IntrinsicWidth (
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      RaisedButton(
                        onPressed: () async{
                          await showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return ChangeConfigurationDialog(strip.configuration, (Configuration conf){ setState(() {
                                  strip.configuration = conf;
                                });});
                              }
                          );
                        },
                        child: Text("Change configuration", style: TextStyle(color: Colors.black),),
                        color: Colors.amber,
                        padding: EdgeInsets.symmetric(horizontal: 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 80,),
            RaisedButton(
              onPressed: () {
                Navigator.pop(context, strip);
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(Icons.save, color: Colors.black,),
                  SizedBox(width: 5,),
                  Text("Apply", style: TextStyle(color: Colors.black),),
                ],
              ),
              color: Colors.amber,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
            ),
            SizedBox(height: 20,),
            Container(
                width: MediaQuery.of(context).size.width/2,
                alignment: Alignment.center,
                child: Text("Reboot the strip controller:", textAlign: TextAlign.center,)),
            SizedBox(height: 10,),
            RaisedButton(
              onPressed: () {
                Navigator.pop(context, strip);
                rebootFunc();
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(Icons.refresh, color: Colors.black,),
                  SizedBox(width: 5,),
                  Text("Restart", style: TextStyle(color: Colors.black),),
                ],
              ),
              color: Colors.amber,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
            ),
            SizedBox(height: 20,),
            Container(
                width: MediaQuery.of(context).size.width/2,
                alignment: Alignment.center,
                child: Text("Reset the strip controller and delete it from storage:", textAlign: TextAlign.center,)),
            SizedBox(height: 10,),
            RaisedButton(
              onPressed: () {
                Navigator.pop(context, strip);
                deleteFunc();
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(Icons.warning, color: Colors.black,),
                  SizedBox(width: 5,),
                  Text("Reset/Delete", style: TextStyle(color: Colors.black),),
                ],
              ),
              color: Colors.amber,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
            ),
          ],
        ),
      ),
    );
  }
}


