import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:ledstripcontroller/configitem.dart';
import 'package:ledstripcontroller/dialogs.dart';
import 'package:ledstripcontroller/storage.dart';
import 'package:ledstripcontroller/configuration.dart';


// page to make changes to a specific configuration.
class ConfigurationControl extends StatefulWidget {
  @override
  _ConfigurationControlState createState() => _ConfigurationControlState();
}

class _ConfigurationControlState extends State<ConfigurationControl> {

  ScrollController _scrollController = ScrollController();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  Map data;
  bool gotStripData = false;
  Configuration originalConf ;
  Configuration temporaryConf = Configuration("","");

  // Make a deep copy of the configuration of the strip.
  List<String> copyList(orig)
  {
    List<String> a = [];
    for(int i = 0; i < orig.length; i++)
    {
      a.add(orig[i]);
    }
    return a;
  }

  // Applies the configuration to the strips in storage.
  void applyConfiguration() async
  {
    String originalName = originalConf.name;
    Function eq = const DeepCollectionEquality().equals;
    bool configChanged = !eq(originalConf.conf, temporaryConf.conf);
    originalConf.conf = copyList(temporaryConf.conf);
    originalConf.name = temporaryConf.name;
    await updateSavedConfiguration(originalName, temporaryConf);
    Storage storage  = Storage();
    await storage.setup();
    if(configChanged)
      {
        await storage.getStrips().then((savedStrips) {
          for(int i=0; i < savedStrips.length; i++)
          {
            if(savedStrips[i].configuration.name == temporaryConf.name)
            {
              try
              {
                _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("Sending new congiruation to ${savedStrips[i].name}.")));
                savedStrips[i].sendConfigurationToStrip();
                _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("The configuration of ${savedStrips[i].name} has succesfully been sent. The strip might not update immediately.")));
              }
              catch(e)
              {
                _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("Sending new configuration to ${savedStrips[i].name} failed. Is the strip connected to the wifi?")));
              }
            }
          }
        });
      }
  }
  // Changes the value of the transition or color in the temporaryConf.
  // Doesn't change anything in storage.
  void changeValue(int index, dynamic value)
  {
    setState(() {
      String originalvalue = temporaryConf.conf[index];
      int startIndex = originalvalue.indexOf('(');
      int endIndex = originalvalue.indexOf(')');
      String newValue = originalvalue.replaceRange(startIndex+1, endIndex, value);
      temporaryConf.conf[index] = newValue;
    });
  }

  // changes the type of the transition. ('Wait' or 'Fade').
  // Doesn't change anything in storage.
  void changeTransitionType(int index, dynamic value)
  {
    setState(() {
      String originalValue = temporaryConf.conf[index];
      String originalTransitionType = temporaryConf.conf[index].substring(0,4);
      String newValue = originalValue.replaceAll(originalTransitionType, value);
      temporaryConf.conf[index] = newValue;
    });
  }

  // Adds a new transition or color (depends on the current last item)
  // to the end of the temporaryConf configuration loop.
  void addConfigItem()
  {
    setState(() {
      // Add a transition if the last item is a color.
      if(temporaryConf.conf.length == 0)
        {
          temporaryConf.conf.add("(1024, 1024, 1024)");
        }
      else if(temporaryConf.conf[temporaryConf.conf.length-1].toString().startsWith("("))
        {
          temporaryConf.conf.add("Wait(1.0)");
        }
      else
        {
        temporaryConf.conf.add("(1024, 1024, 1024)");
        }
    });
  }

  List<String> confNames = [];

  // Populates the 'confNames' list with all the saved configuration names from storage.
  void getAllConfNames() async
  {
    Storage storage = Storage();
    await storage.setup();
    await storage.getConfigurations().then((savedConfs)
    {
      setState(() {
        for(int i=0; i < savedConfs.length; i++)
        {
          confNames.add(savedConfs[i].name);
        }
      });
    });
  }

  // Changes the name of the temporaryConf configuration.
  // Doesn't change anything in storage.
  void changeConfName(String value)
  {
    // dont't allow a name that already exists or an empty name.
    if(value != "" && !confNames.contains(value))
    {
      temporaryConf.name = value;
    }
  }
  @override
  void initState() {
    super.initState();
    getAllConfNames();
  }

  @override
  Widget build(BuildContext context) {

    data = ModalRoute.of(context).settings.arguments;
    originalConf = data['conf'];

    AppBar appBar = AppBar(
      leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () async{
            if (listEquals(originalConf.conf, temporaryConf.conf) && originalConf.name == temporaryConf.name) {
              Navigator.pop(context, originalConf);
            }
            else {
              bool leave = false;
              await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return temporaryConf.conf[temporaryConf.conf.length-1].toString().startsWith('(') ?
                    CantApplyDialog(dontApply: () {leave = true;},)
                        :
                    NotAppliedDialog(applyFunction: () {applyConfiguration(); leave = true;},);
                  }
              );
              if(leave){Navigator.pop(context, originalConf);}
            }
          }
      ),
      title: Text(originalConf.name),
      centerTitle: true,
    );


    // get the strip data only the first time.
    if (gotStripData != true)
      {
        temporaryConf.conf = copyList(originalConf.conf);
        temporaryConf.name = originalConf.name;
        gotStripData = true;
      }

    return Scaffold(
      key: _scaffoldKey,
      appBar: appBar,
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("Configuration", style: TextStyle(fontSize: 20, letterSpacing: 2,)),
            ),
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width/2,
                child: TextFormField(
                  initialValue: temporaryConf.name,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(15),
                  ],
                  onChanged: (String value) {
                    setState(() {
                      changeConfName(value);
                    });
                  },
                ),
              ),
            ),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: (MediaQuery.of(context).size.height - appBar.preferredSize.height) / 3*2,
              ),
              child: ListView(
                controller: _scrollController,
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                children: temporaryConf.conf.asMap().entries.map((entry)
                {
                  return ConfigItem(entry.value, (){
                    setState(() {
                      temporaryConf.conf.removeAt(entry.key);
                    });
                    }, (value){changeValue(entry.key, value);}, (new_trans){changeTransitionType(entry.key,new_trans);} ,entry.key == temporaryConf.conf.length-1);
                }).toList(),
              )
            ),
            RaisedButton(
              onPressed: () {
                addConfigItem();
                _scrollController.animateTo(
                  _scrollController.position.maxScrollExtent+100,
                  curve: Curves.easeOut,
                  duration: const Duration(milliseconds: 200),
                );
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(Icons.add, color: Colors.black,),
                  SizedBox(width: 5,),
                  Text("Add", style: TextStyle(color: Colors.black),),
                ],
              ),
              color: Colors.amber,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
            ),
            temporaryConf.conf.length == 0 ?
            Text(
              "Can't apply, Add at least one color and one transition.",
              textAlign: TextAlign.center,
            )
                :
            temporaryConf.conf[temporaryConf.conf.length-1].toString().startsWith('(') ?
              Text(
                  "Can't apply, Last configuration item can't be a color. It must be a transition from the last to the first color.",
                textAlign: TextAlign.center,
              )
                :
            RaisedButton(
              onPressed: () {
                applyConfiguration();
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
          ],
        ),
      ),
    );
  }
}



