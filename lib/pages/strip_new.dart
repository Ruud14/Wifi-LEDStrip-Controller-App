import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ledstripcontroller/ledstrip.dart';
import 'package:flutter/services.dart';
import 'package:ledstripcontroller/storage.dart';
import 'dart:io';
import 'package:wifi_configuration/wifi_configuration.dart';
import 'package:wifi/wifi.dart';
import 'package:ping_discover_network/ping_discover_network.dart';

// Page to configure a new strip from the network.
class StripNew extends StatefulWidget {
  @override
  _StripNewState createState() => _StripNewState();
}

class _StripNewState extends State<StripNew> {

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  Map data;
  List<String> stripNames = [];
  String stripName = "New Strip";
  String stripIP = "192.168.4.1";
  String stripSSID = "";
  String wifiSSID = "";
  String wifiPassword =  "";
  List<LedStrip> strips = [];

  // Changes 'stripName' to a new name
  // that isn't already used by any other strip in storage.
  void getNewStripName() async
  {
    Storage storage  = Storage();
    await storage.setup();
    List<String> _stripNames = [];
    await storage.getStrips().then((savedStrips) {
      for(int i=0; i < savedStrips.length; i++)
      {
        _stripNames.add(savedStrips[i].name);
      }
    });
    int addition = 0;
    String newName = "New_Strip";
    stripNames = _stripNames;
    while (_stripNames.contains(newName))
    {
      addition+=1;
      newName = "New_Strip" + addition.toString();
    }
    stripName = newName;
  }

  // Populates 'strips' with all the strips from storage.
  void getSavedStrips() async
  {
    Storage storage = Storage();
    await storage.setup();
    await storage.getStrips().then((savedStrips)
    {
      setState(() {
        strips = savedStrips;
      });
    });
  }


  // Changes 'stripName'.
  // Doesn't change anything in storage.
  void changeStripName(String value)
  {
    // dont't allow a name that already exists or an empty name.
    if(value != "" && !stripNames.contains(value))
    {
      stripName = value;
    }
  }

  // Sends the wifi credentials to the strip so It can connect to the wifi.
  void configureStrip(Function callback) async
  {
    String stripHostname = "STRIP_${stripName.replaceAll(" ", "_")}";
    Socket _socket;
    _socket = await Socket.connect(stripIP, 7777);
    _socket.listen((List<int> event) {
      String message = utf8.decode(event);
      callback(message);
      _socket.close();
      _socket.destroy();
    });
    _socket.add(utf8.encode("$wifiSSID,$wifiPassword,$stripHostname"));
  }

  @override
  void initState() {
    getNewStripName();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    data = ModalRoute.of(context).settings.arguments;
    wifiSSID = data['wifi_ssid'];
    stripSSID = data['strip_ssid'];


    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text("Add Strip"),
          centerTitle: true,
          leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () async
              {
                showDialog(
                    barrierDismissible: false,
                    context: context,
                    child: AlertDialog(
                      content: Text("Reconnecting to $wifiSSID..."),
                    ));
                await WifiConfiguration.connectToWifi(wifiSSID, wifiPassword, "com.example.ledstripcontroller");
                Navigator.pop(context); // Removes the dialog
                Navigator.pop(context); // Removes strip_new
              }
          ),
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                SizedBox(height: 20,),
                Container(
                    width: MediaQuery.of(context).size.width/2,
                    alignment: Alignment.bottomLeft,
                    child: Text("Name:", textAlign: TextAlign.left,)),
                Container(
                  width: MediaQuery.of(context).size.width/2,
                  child: TextFormField(
                    initialValue: "New Strip",
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
                SizedBox(height: 20,),
                Container(
                    width: MediaQuery.of(context).size.width/2,
                    alignment: Alignment.bottomLeft,
                    child: Text("Password of the '$wifiSSID' wifi network:", textAlign: TextAlign.left,)),
                Container(
                  width: MediaQuery.of(context).size.width/2,
                  child: TextFormField(
                    initialValue: "",
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(100),
                    ],
                    onChanged: (String value) {
                      setState(() {
                        wifiPassword = value;
                      });
                    },
                  ),
                ),
                SizedBox(height: 20,),
                RaisedButton(
                  onPressed: () async {
                    showDialog(
                        barrierDismissible: false,
                        context: context,
                        child: AlertDialog(
                          content: Text("Configuring strip. This can take up to 5 minutes. Please wait..."),
                        ));
                    // Send the wifi credentials to the strip.
                    void afterStripConnected(String ip) async
                    {
                      if(ip == "failed")
                        {
                          _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("The strip couldn't connect to wifi. Did you enter the wrong wifi password?")));
                          Navigator.pop(context); // Removes the dialog
                        }
                      else
                        {
                          // connect to the wifi again.
                          WifiConnectionStatus connectionStatus = await WifiConfiguration.connectToWifi(wifiSSID, wifiPassword, "com.example.ledstripcontroller");

                          // Add the strip to storage
                          Storage storage = Storage();
                          await storage.setup();
                          await storage.appendStripsFile(LedStrip(name: stripName, ip: ip));
                          Navigator.pop(context); // Removes the dialog
                          Navigator.pop(context); // Removes strip_new
                          Navigator.pop(context); // Removes strip_add

                          if(connectionStatus == WifiConnectionStatus.connected)
                          {
                          }
                          else
                          {
                            _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("Couldn't connect back to wifi.")));
                            Navigator.pop(context); // Removes dialog
                            await Future.delayed(Duration(milliseconds: 7000));
                            Navigator.pop(context); // Removes strip_new
                          }
                        }
                    }
                    await configureStrip(afterStripConnected);

                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(Icons.save, color: Colors.black,),
                      SizedBox(width: 5,),
                      Text("Save", style: TextStyle(color: Colors.black),),
                    ],
                  ),
                  color: Colors.amber,
                  padding: EdgeInsets.symmetric(horizontal: 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
                ),
              ],
            ),
          ),
        ),
      );
  }
}

