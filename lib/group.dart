import 'package:ledstripcontroller/ledstrip.dart';
import 'package:ledstripcontroller/configuration.dart';

// Class representation of a group of strips.
class Group
{
  String name = "New Group";
  List<LedStrip> strips = [];
  Configuration configuration = Configuration("(1024, 0, 0);Wait(0.2);(0, 0, 0);Wait(0.2);(1024, 0, 0);Wait(0.2);(0, 0, 0);Wait(2)", "Test");

  Group({this.name});

  addStrip(LedStrip strip)
  {
    strips.add(strip);
  }

  Group.fromJson(Map<String, dynamic> json)
  {
    name = json['name'];
    List<LedStrip> convertedStrips = [];
    for(int i=0; i< json['strips'].length; i++)
    {
      convertedStrips.add(LedStrip.fromJson(json['strips'][i]));
    }
    strips = convertedStrips;
    configuration = Configuration.fromJson(json['configuration']);

  }

  Map<String, dynamic> toJson() =>
      {
        'name': name,
        'strips': strips,
        'configuration': configuration,
      };
}