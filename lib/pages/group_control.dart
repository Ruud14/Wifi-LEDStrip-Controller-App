import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ledstripcontroller/ledstrip.dart';
import 'package:ledstripcontroller/storage.dart';
import 'package:ledstripcontroller/dialogs.dart';
import 'package:ledstripcontroller/configuration.dart';
import 'package:ledstripcontroller/group.dart';

// Page to make changes to a specific group.
class GroupControl extends StatefulWidget {
  @override
  _GroupControlState createState() => _GroupControlState();
}

class _GroupControlState extends State<GroupControl> {

  Map data;
  Group group;
  List<String> groupNames = [];

  // Populates 'groupNames' with the names from all the groups from the storage.
  void getAllGroupNames() async
  {
    Storage storage = Storage();
    await storage.setup();
    await storage.getGroups().then((savedGroups)
    {
      setState(() {
        for(int i=0; i < savedGroups.length; i++)
        {
          groupNames.add(savedGroups[i].name);
        }
      });
    });
  }

  // Changes the name of 'group'.
  // Doesn't change anything in storage.
  void changeGroupName(String value)
  {
    // dont't allow a name that already exists or an empty name.
    if(value != "" && !groupNames.contains(value))
    {
      group.name = value;
    }
  }

  @override
  void initState() {
    super.initState();
    getAllGroupNames();
  }

  @override
  Widget build(BuildContext context) {
    data = ModalRoute.of(context).settings.arguments;
    group = data['group'];

    return Scaffold(
      appBar: AppBar(
        title: Text(group.name),
        centerTitle: true,
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () async
            {
              Navigator.pop(context, group);
            }
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 50,),
            Container(
                width: MediaQuery.of(context).size.width/2,
                alignment: Alignment.bottomLeft,
                child: Text("Name:", textAlign: TextAlign.left,)),
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width/2,
                child: TextFormField(
                  initialValue: group.name,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(15),
                  ],
                  onChanged: (String value) {
                    setState(() {
                      changeGroupName(value);
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
                                return ChangeConfigurationDialog(group.configuration, (Configuration conf){ setState(() {
                                  group.configuration = conf;
                                });});
                              }
                          );
                        },
                        child: Text("Change Configuration", style: TextStyle(color: Colors.black),),
                        color: Colors.amber,
                        padding: EdgeInsets.symmetric(horizontal: 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
                      ),
                      RaisedButton(
                        onPressed: () async{
                          await showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return ChangeGroupStripsDialog(group.strips, (List<LedStrip> strips){ setState(() {
                                  group.strips = strips;
                                });});
                              }
                          );
                        },
                        child: Text("Change Strips", style: TextStyle(color: Colors.black),),
                        color: Colors.amber,
                        padding: EdgeInsets.symmetric(horizontal: 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 50,),
            RaisedButton(
              onPressed: () {
                Navigator.pop(context, group);
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


