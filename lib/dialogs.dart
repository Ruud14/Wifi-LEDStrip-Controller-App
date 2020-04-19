import 'package:flutter/material.dart';
import 'package:ledstripcontroller/ledstrip.dart';
import 'package:ledstripcontroller/storage.dart';
import 'package:ledstripcontroller/configuration.dart';

// Dialog that pops up when changes haven't been saved yet.
class NotAppliedDialog extends StatefulWidget {

  final Function applyFunction;
  NotAppliedDialog({this.applyFunction});

  @override
  _NotAppliedDialogState createState() => _NotAppliedDialogState();
}

class _NotAppliedDialogState extends State<NotAppliedDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Changes aren't applied!"),
      content: Text(
          "Not all changes have been applied, did you forget to apply?"),
      actions: <Widget>[
        FlatButton(
            child: Text("Don't apply"),
            onPressed: () {
              Navigator.pop(context, true); // removes the dialog
              Navigator.pop(context, true); // removes configuration_control
            }
        ),
        FlatButton(
            child: Text("apply"),
            onPressed: () {
              widget.applyFunction();
              Navigator.pop(context, true);
            }
        )
      ],
    );
  }
}

// Dialog that pops up when the changes can't be applied for some reason.
class CantApplyDialog extends StatefulWidget {

  final Function dontApply;
  CantApplyDialog({this.dontApply});

  @override
  _CantApplyDialogState createState() => _CantApplyDialogState();
}

class _CantApplyDialogState extends State<CantApplyDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Changes can't be applied!"),
      content: Text(
          "Can't apply because the last configuration item must be a transition from the last to the first color."),
      actions: <Widget>[
        FlatButton(
            child: Text("Don't apply"),
            onPressed: () {
              widget.dontApply();
              Navigator.pop(context, true);
            }
        ),
        FlatButton(
            child: Text("Cancel"),
            onPressed: () {
              Navigator.pop(context, true);
            }
        )
      ],
    );
  }
}

// Popup that shows up when changing the configuration of a strip or group.
class ChangeConfigurationDialog extends StatefulWidget {

  List<Configuration> allConfigurations = [];
  Configuration selectedConf = Configuration("","");
  Configuration currentConf;
  Function applyConfigurationChange;


  ChangeConfigurationDialog(Configuration conf, applyFunc)
  {
    this.currentConf = conf;
    this.applyConfigurationChange = applyFunc;
    setSelected(conf);
  }

  // Sets the currently selected configuration to value
  // of the saved strip.configuration or group.configuration.
  void setSelected(Configuration newSelected)
  {
    List<String> newConf = [];
    for(int i = 0; i < newSelected.conf.length; i++)
    {
      newConf.add(newSelected.conf[i]);
    }
    this.selectedConf.name = newSelected.name;
    this.selectedConf.conf = newConf;
  }

  @override
  _ChangeConfigurationDialogState createState() => _ChangeConfigurationDialogState();
}

class _ChangeConfigurationDialogState extends State<ChangeConfigurationDialog> {

  // Populates 'widgets.allConfigurations' with all the configurations from storage.
  void getSavedConfs() async
  {
    Storage storage = Storage();
    await storage.setup();
    await storage.getConfigurations().then((savedConfs)
    {
      setState(() {
        widget.allConfigurations = savedConfs;
      });
    });
  }


  @override
  void initState() {
    super.initState();
    getSavedConfs();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Choose the configuration for this strip."),
      content: Container(
        width: MediaQuery.of(context).size.width-20,
        height: MediaQuery.of(context).size.height/2,
        child: ListView(
          children: widget.allConfigurations.asMap().entries.map((entry)
          {
            return Column(
              children: <Widget>[
                FlatButton(
                  onPressed: () {
                    setState(() {
                      widget.setSelected(entry.value);
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(),
                      color: entry.value.name == widget.selectedConf.name ?  Colors.amber : null,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                "Name: ",
                                style: TextStyle(
                                  fontWeight: FontWeight.w300,
                                  letterSpacing: 2.0,
                                  color: entry.value.name == widget.selectedConf.name ? Colors.black : null,
                                ),
                              ),
                              Text(
                                entry.value.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2.0,
                                  color: entry.value.name == widget.selectedConf.name ? Colors.black : null,
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
                                      color: entry.value.name == widget.selectedConf.name ? Colors.black : null,
                                    ),
                                  ),
                                  Text(
                                    entry.value.conf.toString(),
                                    style: TextStyle(
                                      letterSpacing: 2.0,
                                      color: entry.value.name == widget.selectedConf.name ? Colors.black : null,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                  ),
                ),
              ),
              SizedBox(height: 10,),
              ],
            );
          }).toList(),
        ),
      ),

      actions: <Widget>[
        FlatButton(
            child: Text("Apply"),
            onPressed: () {
              widget.applyConfigurationChange(widget.selectedConf);
              Navigator.pop(context, true);
            }
        ),
        FlatButton(
            child: Text("Cancel"),
            onPressed: () {
              widget.applyConfigurationChange(widget.currentConf);
              Navigator.pop(context, true);
            }
        )
      ],
    );
  }
}

// Popup that shows up when changing the strips of a group.
class ChangeGroupStripsDialog extends StatefulWidget {

  List<LedStrip> allStrips = [];
  List<LedStrip> selectedStrips;
  List<LedStrip> currentStrips;
  Function applyStripsChange;


  ChangeGroupStripsDialog(List<LedStrip> strips, Function applyFunc)
  {
    this.currentStrips = strips;
    this.applyStripsChange = applyFunc;
    setSelected(strips);
  }

  // Sets the strips in group.strips as currently selected strips.
  void setSelected(List<LedStrip> newSelected)
  {
    List<LedStrip> newStrips = [];
    for(int i = 0; i < newSelected.length; i++)
    {
      newStrips.add(newSelected[i]);
    }
    this.selectedStrips = newStrips;
  }

  // Adds or removes strip from selectedStrips
  // depending on if it was already selected or not.
  void clickStrip(LedStrip strip)
  {
    for(int i = 0; i< selectedStrips.length; i++)
      {
        //Remove from selected if it is already in.
        if(selectedStrips[i].name == strip.name)
          {
            selectedStrips.removeAt(i);
            return;
          }
      }
    //add to selected if it isn't in jet.
    selectedStrips.add(strip);
  }

  // Returns if the strip is currently selected.
  bool inSelected(LedStrip strip)
  {
    for(int i = 0; i< selectedStrips.length; i++)
    {
      if(selectedStrips[i].name == strip.name)
      {
        return true;
      }
    }
    return false;
  }

  @override
  _ChangeGroupStripsDialogState createState() => _ChangeGroupStripsDialogState();
}

class _ChangeGroupStripsDialogState extends State<ChangeGroupStripsDialog> {

  // Populates 'widget.allStrips' with all the strips from storage.
  void getSavedStrips() async
  {
    Storage storage = Storage();
    await storage.setup();
    await storage.getStrips().then((savedStrips)
    {
      setState(() {
        widget.allStrips = savedStrips;
      });
    });
  }


  @override
  void initState() {
    super.initState();
    getSavedStrips();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Select the strips that you want to be part of this group."),
      content: Container(
        width: MediaQuery.of(context).size.width-20,
        height: MediaQuery.of(context).size.height/2,
        child: ListView(
          children: widget.allStrips.asMap().entries.map((entry)
          {
            return Column(
              children: <Widget>[
                FlatButton(
                  onPressed: () {
                    setState(() {
                      widget.clickStrip(entry.value);
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(),
                      color: widget.inSelected(entry.value) ?  Colors.amber : null,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                "Name: ",
                                style: TextStyle(
                                  fontWeight: FontWeight.w300,
                                  letterSpacing: 2.0,
                                  color: widget.inSelected(entry.value) ?  Colors.black : null,
                                ),
                              ),
                              Text(
                                entry.value.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2.0,
                                  color: widget.inSelected(entry.value) ?  Colors.black : null,
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
                                      color: widget.inSelected(entry.value) ?  Colors.black : null,
                                    ),
                                  ),
                                  Text(
                                    entry.value.configuration.conf.toString(),
                                    style: TextStyle(
                                      letterSpacing: 2.0,
                                      color: widget.inSelected(entry.value) ?  Colors.black : null,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10,),
              ],
            );
          }).toList(),
        ),
      ),

      actions: <Widget>[
        FlatButton(
            child: Text("Apply"),
            onPressed: () {
              widget.applyStripsChange(widget.selectedStrips);
              Navigator.pop(context, true);
            }
        ),
        FlatButton(
            child: Text("Cancel"),
            onPressed: () {
              widget.applyStripsChange(widget.currentStrips);
              Navigator.pop(context, true);
            }
        )
      ],
    );
  }
}

// Dialog that pops up when changing the configuration of a strip or group.
class ChangeTransitionDialog extends StatefulWidget {

  Function applyFunc;
  String startTransition;
  String newTransition;

  ChangeTransitionDialog(String startTransition, Function applyFunc)
      {
        this.startTransition = startTransition;
        this.newTransition = startTransition;
        this.applyFunc = applyFunc;
      }

  @override
  _ChangeTransitionDialogState createState() => _ChangeTransitionDialogState();
}

class _ChangeTransitionDialogState extends State<ChangeTransitionDialog> {
  @override
  build(BuildContext context) {
    return AlertDialog(
      title: Text("Choose a transition"),
      content: Container(
        width: MediaQuery.of(context).size.width-20,
        height: MediaQuery.of(context).size.height/4,
        child: Column(
          children: <Widget>[
            FlatButton(
              onPressed: () {
                setState(() {
                  widget.newTransition = "Fade";
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(),
                  color: widget.newTransition == "Fade" ? Colors.amber : null,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: <Widget>[
                      Text(
                        "Fade",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2.0,
                          color: widget.newTransition == "Fade" ? Colors.black : null,
                        ),
                      ),
                      Text(
                        "Fades from one color to another.",
                        style: TextStyle(
                          fontWeight: FontWeight.w300,
                          letterSpacing: 2.0,
                          fontSize: 12,
                          color: widget.newTransition == "Fade" ? Colors.black : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            FlatButton(
              onPressed: () {
                setState(() {
                  widget.newTransition = "Wait";
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(),
                  color: widget.newTransition == "Wait" ? Colors.amber : null,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: <Widget>[
                      Text(
                        "Wait",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2.0,
                          color: widget.newTransition == "Wait" ? Colors.black : null,
                        ),
                      ),
                      Text(
                        "Waits for the specified amount of seconds and then goes to the next color.",
                        style: TextStyle(
                          fontWeight: FontWeight.w300,
                          letterSpacing: 2.0,
                          fontSize: 12,
                          color: widget.newTransition == "Wait" ? Colors.black : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 10,),
          ],
        ),
      ),
      actions: <Widget>[
        FlatButton(
            child: Text("Cancel"),
            onPressed: () {
              widget.applyFunc(widget.startTransition);
              Navigator.pop(context, true);
            }
        ),
        FlatButton(
            child: Text("Ok"),
            onPressed: () {
              widget.applyFunc(widget.newTransition);
              Navigator.pop(context, true);
            }
        )
      ],
    );
  }
}


// Dialog that shows up when a connection to a strip can't be established.
class CantConnectToStripDialog extends StatefulWidget {
  @override
  _CantConnectToStripDialogState createState() => _CantConnectToStripDialogState();
}

class _CantConnectToStripDialogState extends State<CantConnectToStripDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Can't connect to strip"),
      content: Container(
        width: MediaQuery.of(context).size.width-20,
        height: MediaQuery.of(context).size.height/4,
        child: Text("Couldn't connect to strip. Make sure you and the strip a close enough to a wifi access point and you are close enough to the strip. Removing power from the strip for a few seconds might help as well.")
      ),
      actions: <Widget>[
        FlatButton(
            child: Text("Ok"),
            onPressed: () {
              Navigator.pop(context, true);
            }
        )
      ],
    );
  }
}

class ConfirmationDialog extends StatefulWidget {

  Function callback;
  String title;
  String message;
  ConfirmationDialog({this.callback, this.title, this.message});

  @override
  _ConfirmationDialogState createState() => _ConfirmationDialogState();
}

class _ConfirmationDialogState extends State<ConfirmationDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Container(
          width: MediaQuery.of(context).size.width-20,
          height: MediaQuery.of(context).size.height/4,
          child: Text(widget.message)
      ),
      actions: <Widget>[
        FlatButton(
            child: Text("Cancel"),
            onPressed: () {
              Navigator.pop(context, true);
            }
        ),
        FlatButton(
            child: Text("Continue"),
            onPressed: () {
              Navigator.pop(context, true);
              widget.callback();
            }
        )
      ],
    );
  }
}
