import 'package:flutter/material.dart';
import 'package:ledstripcontroller/ledstrip.dart';
import 'storage.dart';
import 'package:wifi/wifi.dart';
import 'package:ledstripcontroller/configuration.dart';
import 'package:ledstripcontroller/group.dart';
import 'package:wifi_configuration/wifi_configuration.dart';
import 'package:ledstripcontroller/dialogs.dart';

// Visualisation of a Strip object.
// Is displayed on the homepage.
class StripTile extends StatefulWidget {

  LedStrip strip;
  Function deleteFunc;
  GlobalKey<ScaffoldState> scaffoldKey;
  bool online;
  StripTile({this.strip, this.scaffoldKey, this.deleteFunc});

  @override
  _StripTileState createState() => _StripTileState();
}

class _StripTileState extends State<StripTile> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        trailing: IconButton(
          onPressed: widget.deleteFunc,
          icon: Icon(Icons.delete),
        ),
        title: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Text(
                  "Name: ",
                  style: TextStyle(
                    fontWeight: FontWeight.w300,
                    letterSpacing: 2.0,
                  ),
                ),
                Text(
                  widget.strip.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.0,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Text(
                  "Configuration: ",
                  style: TextStyle(
                    fontWeight: FontWeight.w200,
                    letterSpacing: 2.0,
                  ),
                ),
                Text(
                  widget.strip.configuration.name,
                  style: TextStyle(
                    letterSpacing: 2.0,
                  ),
                ),
              ],
            ),
          ],
        ),
        onTap: () async
        {
          String start_name = widget.strip.name;
          String start_conf_name = widget.strip.configuration.name;
          dynamic result = await Navigator.pushNamed(context, '/strip_control', arguments: {'strip': widget.strip, 'scaffoldKey':widget.scaffoldKey, 'deleteFunc': widget.deleteFunc});

          bool turnedOff = result[1];
          result = result[0];
          // Only change anything if the strip is on.
          if(!turnedOff)
            {
              await updateSavedStrip(start_name, result);
              // Only apply the configuration if the configuration changed.
              if (!(start_conf_name == result.configuration.name)){
                try
                {
                  widget.scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("Sending new congiruation to ${widget.strip.name}.")));
                  await result.sendConfigurationToStrip();
                  widget.scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("The configuration of ${widget.strip.name} has succesfully been sent. The strip might not update immediately.")));
                }
                catch(e)
                {
                  widget.scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("Sending new configuration to ${widget.strip.name} failed. Is the strip connected to the wifi?")));
                }
              }
              setState(() {
              });
            }
          }
      ),
    );
  }
}

// Visualisation of a Configuration object.
// Is displayed on the configurations page.
class ConfigurationTile extends StatefulWidget {

  Configuration conf;
  Function deleteFunc;
  ConfigurationTile({this.conf, this.deleteFunc});

  @override
  _ConfigurationTileState createState() => _ConfigurationTileState();
}

class _ConfigurationTileState extends State<ConfigurationTile> {

  // Converts and returns the configuration.conf as a string.
  String getConfiguriationString()
  {
    List<String> items = [];
    for(int i=0; i < widget.conf.conf.length; i++)
      {
        items.add(widget.conf.conf[i].toString());
      }
    return items.join(", ");
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        trailing: widget.conf.name == "Test" ? null : IconButton(
          onPressed: widget.deleteFunc,
          icon: Icon(Icons.delete),
        ),
        title: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Text(
                  "Name: ",
                  style: TextStyle(
                    fontWeight: FontWeight.w300,
                    letterSpacing: 2.0,
                  ),
                ),
                Text(
                  widget.conf.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.0,
                  ),
                ),
              ],
            ),
            Container(
              alignment: Alignment(-1,0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "Configuration: ",
                      style: TextStyle(
                        fontWeight: FontWeight.w200,
                        letterSpacing: 2.0,
                      ),
                    ),
                    Text(
                      getConfiguriationString(),
                      style: TextStyle(
                        letterSpacing: 2.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        onTap: widget.conf.name == "Test" ? null :() async
        {
          final result = await Navigator.pushNamed(context, '/configuration_control', arguments: {
            'conf':widget.conf,
          });
          setState(() {
            widget.conf = result;
          });
        },
      ),
    );
  }
}

// Visualisation of a Group object.
// Is displayed on the homepage.
class GroupTile extends StatefulWidget {

  Group group;
  Function deleteFunc;
  GlobalKey<ScaffoldState> scaffoldKey;
  GroupTile({this.group, this.deleteFunc, this.scaffoldKey});

  @override
  _GroupTileState createState() => _GroupTileState();
}

class _GroupTileState extends State<GroupTile> {

  // Returns all strip names as a comma separated String.
  String getStripNames()
  {
    List<String> names = [];
    if(widget.group.strips.length == 1){
      return "only "+widget.group.strips[0].name;
    }
    else if (widget.group.strips.length == 0)
    {
      return "None at the moment.";
    }
    for(int i = 0; i< widget.group.strips.length; i++)
    {
      names.add(widget.group.strips[i].name);
    }
    return names.join(", ");
  }

  @override
  Widget build(BuildContext context) {

    return Card(
      child: ListTile(
        trailing: IconButton(
          onPressed: widget.deleteFunc,
          icon: Icon(Icons.delete),
        ),
        title: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Text(
                  "Name: ",
                  style: TextStyle(
                    fontWeight: FontWeight.w300,
                    letterSpacing: 2.0,
                  ),
                ),
                Text(
                  widget.group.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.0,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Text(
                  "Configuration: ",
                  style: TextStyle(
                    fontWeight: FontWeight.w200,
                    letterSpacing: 2.0,
                  ),
                ),
                Text(
                  widget.group.configuration.name,
                  style: TextStyle(
                    letterSpacing: 2.0,
                  ),
                ),
              ],
            ),
            Container(
              alignment: Alignment(-1,0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "Strips: ",
                      style: TextStyle(
                        fontWeight: FontWeight.w200,
                        letterSpacing: 2.0,
                      ),
                    ),
                    Text(
                      getStripNames(),
                      style: TextStyle(
                        letterSpacing: 2.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        onTap: () async
        {
          String start_name = widget.group.name;
          String start_conf_name = widget.group.configuration.name;
          dynamic result = await Navigator.pushNamed(context, '/group_control', arguments: {'group': widget.group, 'scaffoldKey':widget.scaffoldKey});
          bool turnedOff = result[1];
          result = result[0];
          // Only change anything if the strip is on.
          if(!turnedOff)
            {
              await updateSavedGroup(start_name, result);

              if(!(start_conf_name == result.configuration.name))
                {
                  widget.scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("Sending new congiruation to all strips in ${result.name}.")));
                  for(int i =0; i < result.strips.length; i++)
                  {
                    try
                    {
                      await result.strips[i].sendConfigurationToStrip();
                      widget.scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("The configuration of ${result.strips[i].name} has succesfully been sent. The strip might not update immediately.")));
                    }
                    catch(e)
                    {
                      widget.scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("Sending new configuration to ${result.strips[i].name} failed. Is the strip connected to the wifi?")));
                    }
                  }
                }
              setState((){
              });
            }
          }
      )
    );
  }
}

// Visualisation of a not-yet-configured ledstrip.
// Is displayed on the strip_add page.
class NewStripTile extends StatefulWidget {

  String wifi_ssid;
  String strip_ssid;

  NewStripTile({this.strip_ssid});

  // Get the ssid of the current wifi network.
  void getWifiSSID() async {
    wifi_ssid = await Wifi.ssid;
  }

  @override
  _NewStripTileState createState() => _NewStripTileState();
}

class _NewStripTileState extends State<NewStripTile> {

  @override
  void initState() {
    widget.getWifiSSID();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
        child: ListTile(
          title: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Name: ",
                    style: TextStyle(
                      fontWeight: FontWeight.w300,
                      letterSpacing: 2.0,
                    ),
                  ),
                  Text(
                    widget.strip_ssid,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0,
                    ),
                  ),
                ],
              ),
            ],
          ),
          onTap: () async
          {
            showDialog(
                context: context,
                barrierDismissible: false,
                child: AlertDialog(
                  content: Text("Connecting to strip. Please wait..."),
            ));
            WifiConnectionStatus connectionStatus = await WifiConfiguration.connectToWifi(widget.strip_ssid, "Ruud14_LedStrip", "com.example.ledstripcontroller");
            if(connectionStatus == WifiConnectionStatus.connected)
              {
                await Future.delayed(Duration(milliseconds: 10000));
                Navigator.of(context, rootNavigator: true).pop();
                Navigator.pushNamed(context, '/strip_new', arguments: {'wifi_ssid': widget.wifi_ssid, 'strip_ssid': widget.strip_ssid});
              }
            else
              {
                Navigator.of(context, rootNavigator: true).pop();
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return CantConnectToStripDialog();
                    });
              }
            }
        )
    );
  }
}
