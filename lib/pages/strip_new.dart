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
  void configureStrip() async
  {
    await Socket.connect(stripIP, 7777).then((socket) async {
      String stripHostname = "STRIP_${stripName.replaceAll(" ", "_")}";
      print('Connected to: '
          '${socket.remoteAddress.address}:${socket.remotePort}');
       socket.write("$wifiSSID,$wifiPassword,$stripHostname");
      socket.destroy();
      });
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
          child: Column(
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
                  await configureStrip();
                  // connect to the wifi again.
                  WifiConnectionStatus connectionStatus = await WifiConfiguration.connectToWifi(wifiSSID, wifiPassword, "com.example.ledstripcontroller");
                  await Future.delayed(Duration(milliseconds: 10000));
                  if(connectionStatus == WifiConnectionStatus.connected)
                  {
                    // Fires after the strip has been found on the wifi network.
                    void addStrip(addr) async
                    {
                      print("GOT STRIP:: "+addr.ip);
                      Storage storage = Storage();
                      await storage.setup();
                      await storage.appendStripsFile(LedStrip(name: stripName, ip: addr.ip));
                      Navigator.pop(context); // Removes the dialog
                      Navigator.pop(context); // Removes strip_new
                      Navigator.pop(context); // Removes strip_add
                    }

                    await getSavedStrips();
                    final String ip = await Wifi.ip;
                    final String subnet = ip.substring(0, ip.lastIndexOf('.'));
                    final int port = 8778;
                    final stream = NetworkAnalyzer.discover(subnet, port);
                    var streamer;
                    streamer = stream.listen((NetworkAddress addr) async {
                      print("IN STREAM "+addr.ip);
                      if (addr.exists) {
                        print('Found device: ${addr.ip}');
                        if(strips.length == 0)
                        {
                          addStrip(addr);
                          streamer.cancel();
                        }
                        else{
                          for(int i=0; i< strips.length; i++)
                          {
                            if(strips[i].ip != addr.ip)
                            {
                              addStrip(addr);
                              streamer.cancel();
                            }
                          }
                        }
                      }
                      else if(addr.ip.endsWith("255"))
                      {
                        _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("Strip couldn't be found on the network. Did you enter the correct wifi password?")));
                        await Future.delayed(Duration(milliseconds: 7000));
                        Navigator.pop(context); // Removes dialog
                        Navigator.pop(context); // Removes strip_new
                      }
                    });
                  }
                  else
                    {
                      _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("Couldn't connect back to wifi. Did you enter the correct wifi password?")));
                      await Future.delayed(Duration(milliseconds: 7000));
                      Navigator.pop(context); // Removes dialog
                      Navigator.pop(context); // Removes strip_new
                    }

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
      );
  }
}

