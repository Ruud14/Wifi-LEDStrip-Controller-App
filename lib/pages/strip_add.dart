import 'package:flutter/material.dart';
import 'package:wifi/wifi.dart';
import 'package:ledstripcontroller/tiles.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';


// Page that shows new strips on the network.
class StripAdd extends StatefulWidget {
  @override
  _StripAddState createState() => _StripAddState();
}


class _StripAddState extends State<StripAdd> {

  List ssidList = [];

  // Populates 'ssidList' with all non-configured strips on the network.
  void loadNetworks() async {
    ssidList = [];
    await Wifi.list('').then((list) {
      for(int i=0; i<list.length; i++)
        {
          if(list[i].ssid == "LedStrip Setup")
            {
              ssidList.add(list[i]);
            }
        }
    });
  }

  @override
  void initState() {
    loadNetworks();
    super.initState();
  }

  RefreshController _refreshController =  RefreshController(initialRefresh: false);

  void _onRefresh() async{
    await Future.delayed(Duration(milliseconds: 100));
    await loadNetworks();
    _refreshController.refreshCompleted();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Strip"),
        centerTitle: true,
      ),
      body: SmartRefresher(
        controller: _refreshController,
        onRefresh: _onRefresh,
        child: SingleChildScrollView(
          child: Column(

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
              ListView(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                children: ssidList.length == 0 ? [
                  Center(
                    child: Column(
                      children: <Widget>[
                        SizedBox(height: 40,),
                        Text("No Strips found on network",
                            style: TextStyle(fontSize: 20, fontStyle: FontStyle.italic)),
                        SizedBox(height: 20,),
                        Text("You might want to go to the wifi settings of your phone, reaload the available networks (BUT DON'T CONNECT TO ANY) and come back here. ",
                            style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic,),
                            textAlign: TextAlign.center,),
                        SizedBox(height: 20,)
                      ],
                    ),
                  ),]
                    :
                ssidList.asMap().entries.map((entry)
                {
                  return NewStripTile(strip_ssid:entry.value.ssid);
                }).toList(),
              ),
              RaisedButton(
                onPressed: () {
                  setState(() {
                    loadNetworks();
                  });
                },
                child: Icon(Icons.autorenew, color: Colors.black,),
                color: Colors.amber,
                padding: EdgeInsets.symmetric(horizontal: 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
              ),

              SizedBox(height: 80,),
              Container(
                  width: MediaQuery.of(context).size.width/2,
                  alignment: Alignment.center,
                  child: Text("Add a strip that is already connected to your wifi network:", textAlign: TextAlign.center,)),
              SizedBox(height: 10,),
              RaisedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/strip_add_connected');
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(Icons.warning, color: Colors.black,),
                    SizedBox(width: 5,),
                    Text("Add wifi-connected strip", style: TextStyle(color: Colors.black),),
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

