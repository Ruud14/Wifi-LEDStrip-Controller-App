
// Class representation of the configuration of the lights of a strip.
class Configuration
{
  String name = "New Configuration";
  List conf = [];
  Configuration(String strConf, String _name)
  {
    conf = strTConf(strConf);
    name = _name;
  }

  Configuration.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        conf = json['conf'];

  Map<String, dynamic> toJson() =>
      {
        'name': name,
        'conf': conf,
      };

  // Converts a configuration from a String to a List.
  List strTConf(String strConf)
  {
    return strConf.split(";");
  }
}