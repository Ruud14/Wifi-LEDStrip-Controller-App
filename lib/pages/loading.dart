import 'package:flutter/material.dart';
import 'package:ledstripcontroller/storage.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:ledstripcontroller/configuration.dart';

// Loads all the stored data.
class Loading extends StatefulWidget {
  @override
  _LoadingState createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {

  // Gets the saved data from storage and consequently goes to the homepage.
  void getStoredData() async
  {
    Storage storage = Storage();
    List<Configuration> confs = await storage.getConfigurations();
    bool hasTest = false;
    for(int i=0; i < confs.length; i++)
      {
        if(confs[i].name == "Test")
          {
            hasTest = true;
            break;
          }
      }
    if(!hasTest)
      {
        Configuration testConfig = Configuration("(1024, 0, 0);Wait(0.2);(0, 0, 0);Wait(0.2);(1024, 0, 0);Wait(0.2);(0, 0, 0);Wait(2)", "Test");
        await storage.appendConfigurationsFile(testConfig);
      }
    Navigator.pushReplacementNamed(context, '/home',);
  }


  @override
  void initState() {
    super.initState();
    getStoredData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "Wifi Led Strip Controller",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 25,
              ),
            ),
            SizedBox(height: 100,),
            SpinKitCubeGrid(
              color: Colors.white,
              size: 50.0,
            ),
            SizedBox(height: 100,),
            Text(
              "https://github.com/Ruud14",
              style: TextStyle(
                  color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


