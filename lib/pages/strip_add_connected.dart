import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ledstripcontroller/ledstrip.dart';
import 'package:ledstripcontroller/storage.dart';

// Page to manually add a strip that is already connected to the wifi.
class StripAddConnected extends StatefulWidget {
  @override
  _StripAddConnectedState createState() => _StripAddConnectedState();
}

class _StripAddConnectedState extends State<StripAddConnected> {

  String stripName = "New_Strip";
  List<String> stripNames = [];
  String stripIP = "192.168.1.1";

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

  @override
  void initState() {
    getNewStripName();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Manually add strip"),
        centerTitle: true,
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () async
            {
              Navigator.pop(context);
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
                  initialValue: stripName,
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
                width: MediaQuery.of(context).size.width/2,
                alignment: Alignment.bottomLeft,
                child: Text("Ip:", textAlign: TextAlign.left,)),
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width/2,
                child: TextFormField(
                  initialValue: stripIP,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(15),
                  ],
                  onChanged: (String value) {
                    setState(() {
                      stripIP = value;
                    });
                  },
                ),
              ),
            ),
            SizedBox(height: 20,),
            RaisedButton(
              onPressed: () async {
                Storage storage  = Storage();
                await storage.setup();
                storage.appendStripsFile(LedStrip(ip: stripIP, name: stripName));
                Navigator.pop(context);
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(Icons.save, color: Colors.black,),
                  SizedBox(width: 5,),
                  Text("Add", style: TextStyle(color: Colors.black),),
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


