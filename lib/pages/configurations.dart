import 'package:flutter/material.dart';
import 'package:ledstripcontroller/tiles.dart';
import 'package:ledstripcontroller/navigation.dart';
import 'package:ledstripcontroller/storage.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:ledstripcontroller/configuration.dart';

// Generates a new configuration name that isn't already claimed.
Future<String> getNewConfigurationName() async
{
  Storage storage  = Storage();
  await storage.setup();
  List<String> confNames = [];
  await storage.getConfigurations().then((savedConfs) {
    for(int i=0; i < savedConfs.length; i++)
      {
      confNames.add(savedConfs[i].name);
      }
    });
  int addition = 0;
  String newName = "New Conf";
  while (confNames.contains(newName))
    {
      addition+=1;
      newName = "New Conf" + addition.toString();
    }
  return newName;
}

// Shows the saved configurations.
class ConfigurationsPage extends StatefulWidget {
  @override
  _ConfigurationsPageState createState() => _ConfigurationsPageState();
}

class _ConfigurationsPageState extends State<ConfigurationsPage> {

  ScrollController _scrollController = ScrollController();
  List<Configuration> configurations = [];

  // Puts the 'configurations' list into storage.
  void saveConfigurations() async
  {
    Storage storage  = Storage();
    await storage.setup();
    await storage.replaceConfigurationsFileContent(configurations);
  }

  // Populates the 'configurations' list with all configurations from the storage.
  void getSavedConfigurations() async
  {
    Storage storage = Storage();
    await storage.setup();
    await storage.getConfigurations().then((savedConfs)
    {
      setState(() {
        configurations = savedConfs;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    getSavedConfigurations();
  }

  RefreshController _refreshController =  RefreshController(initialRefresh: false);

  void _onRefresh() async{
    await Future.delayed(Duration(milliseconds: 100));
    await getSavedConfigurations();
    _refreshController.refreshCompleted();
  }

  @override
  Widget build(BuildContext context) {
    AppBar appBar = AppBar(
      title: Text("Configurations"),
      centerTitle: true,
    );
    return Scaffold(
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
                child: Text("Configurations"),
              ),
              Container(
                height: (MediaQuery.of(context).size.height - appBar.preferredSize.height) / 3*2,
                child: ListView(
                  controller: _scrollController,
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  children: configurations.length == 0 ? [
                    Center(
                      child: Text("No Configurations yet",
                          style: TextStyle(fontSize: 20, fontStyle: FontStyle.italic)),
                    ),]
                      :
                  configurations.asMap().entries.map((entry)
                  {
                    return ConfigurationTile(conf: entry.value, deleteFunc: () async
                    {
                      await deleteConfiguration(entry.value.name);
                      setState(() {configurations.removeAt(entry.key);});
                    });
                  }).toList(),
                ),
              ),
              // The 'add group' and 'add strip' buttons.

              SizedBox(
                height: 40,
              ),
              Container(
                child: Center(
                  child: IntrinsicWidth (
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        RaisedButton(
                          onPressed: () async {
                            await getNewConfigurationName().then((value) {
                              configurations.add(Configuration("(1024, 0, 0);Wait(0.2);(0, 0, 0);Wait(0.2);(1024, 0, 0);Wait(0.2);(0, 0, 0);Wait(2)", value));
                            });
                            await saveConfigurations();
                            _scrollController.animateTo(
                              _scrollController.position.maxScrollExtent+100,
                              curve: Curves.easeOut,
                              duration: const Duration(milliseconds: 200),
                            );
                            setState(() {});
                          },
                          child: Row(
                            children: <Widget>[
                              Icon(Icons.add, color: Colors.black,),
                              SizedBox(width: 5,),
                              Text("Add Configuration", style: TextStyle(color: Colors.black),),
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
            ],
          ),
        ),
      ),
    );
  }
}


