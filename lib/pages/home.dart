import 'package:flutter/material.dart';
import 'package:ledstripcontroller/ledstrip.dart';
import 'package:ledstripcontroller/tiles.dart';
import 'package:ledstripcontroller/navigation.dart';
import 'package:ledstripcontroller/storage.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:ledstripcontroller/group.dart';
import 'dart:io';
import 'package:ledstripcontroller/dialogs.dart';
import 'package:wifi/wifi.dart';
import 'package:ping_discover_network/ping_discover_network.dart';




// Generates a name for a group.
// It makes sure that this name isn't already used by a different group.
Future<String> getNewGroupName() async
{
  Storage storage  = Storage();
  await storage.setup();
  List<String> groupNames = [];
  await storage.getGroups().then((savedGroups) {
    for(int i=0; i < savedGroups.length; i++)
    {
      groupNames.add(savedGroups[i].name);
    }
  });
  int addition = 0;
  String newName = "New Group";
  while (groupNames.contains(newName))
  {
    addition+=1;
    newName = "New Group" + addition.toString();
  }
  return newName;
}

// Shows the home screen with the saved strips and groups.
class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  ScrollController _StripsScrollController = ScrollController();
  ScrollController _GroupsScrollController = ScrollController();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  List<LedStrip> strips = [];
  List<Group> groups = [];

  Future<String> getNetworkDevices() async
  {
    String stripIP;
    final String ip = await Wifi.ip;
    final String subnet = ip.substring(0, ip.lastIndexOf('.'));
    final int port = 8778;
    final stream = NetworkAnalyzer.discover(subnet, port);
    await stream.listen((NetworkAddress addr) {
      if (addr.exists) {
        for(int i=0; i< strips.length; i++)
          {
            if(strips[i].ip != addr.ip)
              {
                stripIP = addr.ip;
              }
          }
      }
      return stripIP;
    });

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

  // Populates 'groups' with all the groups from storage.
  void getSavedGroups() async
  {
    Storage storage = Storage();
    await storage.setup();
    await storage.getGroups().then((savedGroups)
    {
      setState(() {
        groups = savedGroups;
      });
    });
  }

  // Puts 'groups' into storage.
  void saveGroups() async
  {
    Storage storage  = Storage();
    await storage.setup();
    await storage.replaceGroupsFileContent(groups);
  }


  @override
  void initState() {
    super.initState();
    getSavedStrips();
    getSavedGroups();
  }

  RefreshController _refreshController =  RefreshController(initialRefresh: false);

  void _onRefresh() async{
    await Future.delayed(Duration(milliseconds: 100));
    await getSavedGroups();
    await getSavedStrips();
    _refreshController.refreshCompleted();
  }

  @override
  Widget build(BuildContext context) {

    AppBar appBar = AppBar(
      title: Text("Led Strips Controller"),
      centerTitle: true,
    );
    return Scaffold(
      key: _scaffoldKey,
      drawer: NavDrawer(),
      appBar: appBar,
      body: SmartRefresher(
        controller: _refreshController,
        onRefresh: _onRefresh,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Strips",
                  style: TextStyle(
                    fontWeight: FontWeight.w300,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: (MediaQuery.of(context).size.height - appBar.preferredSize.height) / 3,
                ),
                child: ListView(
                  controller: _StripsScrollController,
                  scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    children: strips.length == 0 ? [
                      Center(
                        child: Text("No Strips yet",
                        style: TextStyle(fontSize: 20, fontStyle: FontStyle.italic)),
                        ),]
                        :
                    strips.asMap().entries.map((entry)
                    {
                      return StripTile(scaffoldKey: _scaffoldKey,strip: entry.value, deleteFunc: () async
                      {
                        await showDialog(
                          context: context,
                          builder: (BuildContext context)
                            {
                              return ConfirmationDialog(title: "Delete ${entry.value.name}?", message: "Are you sure you want to delete ${entry.value.name}?", callback: () async {
                                await deleteStrip(entry.value.name);
                                setState(() {strips.removeAt(entry.key);});
                                _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("${entry.value.name} has been deleted.")));
                              });
                            }
                        );
                      },
                          rebootFunc: () async {
                        try
                          {
                            print("Sending restart message to ${entry.value.ip}.");
                            await Socket.connect(entry.value.ip, dataPort).then((socket) {
                              print('Connected to: '
                                  '${socket.remoteAddress.address}:${socket.remotePort}');
                              socket.write("restart");
                              socket.destroy();
                              _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("Reboot message sent to ${entry.value.name}.")));
                            });
                          }
                        catch(e)
                          {
                            _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("Couldn't send reboot message to ${entry.value.name}.")));
                          }
                      });
                    }).toList(),
                  ),
              ),
              // The 'add group' and 'add strip' buttons.
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Groups",
                  style: TextStyle(
                    fontWeight: FontWeight.w300,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: (MediaQuery.of(context).size.height - appBar.preferredSize.height) / 3,
                ),
                child: ListView(
                  controller: _GroupsScrollController,
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  children: groups.length == 0 ?
                  [Center(
                    child: Text("No Groups yet",
                    style: TextStyle(fontSize: 20, fontStyle: FontStyle.italic)),
                  ),]
                      :
                  groups.asMap().entries.map((entry)
                  {
                    return GroupTile(scaffoldKey: _scaffoldKey, group: entry.value, deleteFunc: () async
                    {
                      await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return ConfirmationDialog(title: "Delete ${entry.value.name}?", message: "Are you sure you want to delete ${entry.value.name}?", callback: () async {
                            await deleteGroup(entry.value.name);
                            setState(() {groups.removeAt(entry.key);});
                            _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("${entry.value.name} has been deleted.")));
                          });
                        }
                      );
                    });
                  }).toList(),
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
                          onPressed: () {
                            Navigator.pushNamed(context, '/strip_add');
                          },
                          child: Row(
                            children: <Widget>[
                              Icon(Icons.add, color: Colors.black,),
                              SizedBox(width: 5,),
                              Text("Add Strip", style: TextStyle(color: Colors.black),),
                            ],
                          ),
                          color: Colors.amber,
                          padding: EdgeInsets.symmetric(horizontal: 50),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
                        ),
                        RaisedButton(
                          onPressed: () {
                            setState(() {
                              getNewGroupName().then((value) {
                                groups.add(Group(name:value));
                              });
                              saveGroups();
                              _GroupsScrollController.animateTo(
                                _GroupsScrollController.position.maxScrollExtent+100,
                                curve: Curves.easeOut,
                                duration: const Duration(milliseconds: 200),
                              );
                            });
                          },
                          child: Row(
                            children: <Widget>[
                              Icon(Icons.add, color: Colors.black,),
                              SizedBox(width: 5,),
                              Text("Add Group", style: TextStyle(color: Colors.black),),
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
              ),
              // The 'add group' and 'add strip' buttons.
            ],
          ),
        ),
      ),
    );
  }
}


