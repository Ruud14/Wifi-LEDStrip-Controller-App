import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';


// The navigation that shows up by clicking on the hamburger in the top left
// corner of the main, configurations and settings screen.
class NavDrawer extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      child: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            Container(
              color: Colors.amber,
              child: DrawerHeader(
                child: Column(
                  children: <Widget>[
                    Text("Wifi Led Strip Controller", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black),),
                    SizedBox(height: 20,),
                    Center(
                      child: Text("https://github.com/Ruud14", style: TextStyle(decoration: TextDecoration.underline, color: Colors.black)),
                    ),
                  ],
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.brightness_1, color: Colors.amber,),
              title: Text("Strips & Groups"),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.pushReplacementNamed(context, '/home');
              },
            ),
            ListTile(
              leading: Icon(Icons.brightness_1, color: Colors.amber,),
              title: Text("Configurations"),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.pushReplacementNamed(context, '/configurations');
              },
            ),
            ListTile(
              leading: Icon(Icons.brightness_1, color: Colors.amber,),
              title: Text("Settings"),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.pushNamed(context, '/settings');
              },
            ),
          ],
        ),

      ),
    );
  }
}
