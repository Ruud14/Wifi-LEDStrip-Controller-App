import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:ledstripcontroller/dialogs.dart';

// Visualisation of an item from the conf list of a 'configuration' object.
// Is displayed on the 'configuration_control' page.
class ConfigItem extends StatefulWidget {

  bool isColor;
  String name;
  dynamic value;
  Function delete;
  Function changeValue;
  Function changeTransitionType;
  bool isLast = false;

  ConfigItem(String thing, Function delete, Function changeValue, Function changeTransitionType, bool isLast)
  {
    this.changeValue = changeValue;
    this.changeTransitionType = changeTransitionType;
    this.delete = delete;
    this.name = thing;
    this.isLast = isLast;
    if (thing.startsWith('(')){
      // It is a color.
      this.isColor = true;
      List rgb = thing.substring(1,thing.length-1).split(",");
      int r = (int.parse(rgb[0])*(255/1024)).round();
      int g = (int.parse(rgb[1])*(255/1024)).round();
      int b = (int.parse(rgb[2])*(255/1024)).round();
      this.value = Color.fromRGBO(r,g,b, 1);

    }
    else{
      // It is a transition.
      this.isColor = false;
      this.value = double.parse(thing.split('(')[1].split(')')[0]);
    }
  }

  @override
  _ConfigItemState createState() => _ConfigItemState();
}

class _ConfigItemState extends State<ConfigItem> {
  @override
  Widget build(BuildContext context) {

    dynamic valueField;
    Color pickerColor = widget.isColor ? widget.value : Colors.grey[200];

    // changes the color of the ColorPicker.
    void changeColor(Color color) {
      setState(() => pickerColor = color);
    }

    // Shows the 'NumberChanger' dialog
    // in which the duration of a transition can be changed.
    void openNumberChanger() {
       showDialog<double>(
        context: context,
        builder: (BuildContext context) {
          return NumberPickerDialog.decimal(
            minValue: 0,
            maxValue: 10,
            decimalPlaces: 2,
            initialDoubleValue: widget.value,
            title: Text("Pick a decimal number"),
          );
        },
      ).then((num value) {
        if (value > 0.05) {
          widget.changeValue(value.toString());
        }
        else
          {
            showDialog(
              context: context,
              child:  AlertDialog(
                title: Text("Minimum is 0.05 sec"),
                content: Text("The minimum delayed time is 0.05 seconds, so that is what it is set to now."),
                actions: <Widget>[
                  FlatButton(
                    child: const Text('ok'),
                    onPressed: () {Navigator.of(context).pop();},
                  )
                ],
              ),
            );
            widget.changeValue("0.05");
          }
      });
    }
    // Opens the 'ColorPicker' dialog.
    void openColorPicker()
    {
      showDialog(
        context: context,
        child: AlertDialog(
          title: const Text('Pick a color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: pickerColor,
              onColorChanged: changeColor,
              enableAlpha: false,
              displayThumbColor: true,
              paletteType: PaletteType.hsv,
              pickerAreaHeightPercent: 1,
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: const Text('Change'),
              onPressed: () {
                setState(() => widget.value = pickerColor);
                String strColor = widget.value.toString();
                String hexCode = strColor.substring(strColor.indexOf('(')+5,strColor.indexOf(')'));
                int r = (int.parse(hexCode.substring(0,2), radix: 16)*(1024/255)).round();
                int g = (int.parse(hexCode.substring(2,4), radix: 16)*(1024/255)).round();
                int b = (int.parse(hexCode.substring(4,6), radix: 16)*(1024/255)).round();
                widget.changeValue("$r,$g,$b");
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    }

    if(widget.isColor)
    {
      valueField = Container(
        child: FlatButton(
          onPressed: openColorPicker,
          child: SizedBox(),
        ),
          width: 90,
          height: 30,
        decoration: BoxDecoration(
          border: Border.all(),
          color: widget.value
        )
      );
    }
    else
    {
      valueField = Container(
        child: FlatButton(
          onPressed: openNumberChanger,
          child: Text(widget.value.toString()),
        ),
        width: 90,
        height: 30,
        decoration: BoxDecoration(
          border: Border.all(),
        ),
      );
    }

    return Card(
      child: ListTile(
        title: Text(widget.name),
        onTap: () async{
          if(!widget.isColor)
            {
              await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return ChangeTransitionDialog(widget.name.substring(0, 4), widget.changeTransitionType,);
                  }
              );
            }
        },
        leading: widget.isLast ? IconButton(icon: Icon(Icons.delete), onPressed: () {widget.delete();},) : null,
        trailing: valueField,
      ),

    );
  }
}
