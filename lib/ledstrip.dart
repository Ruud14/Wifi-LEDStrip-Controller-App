import 'dart:io';
import 'package:ledstripcontroller/configuration.dart';

int dataPort = 8778;

// Class representation of a ledstrip.
class LedStrip
{
  String ip;
  String name;
  Configuration configuration = Configuration("(1024, 0, 0);Wait(0.2);(0, 0, 0);Wait(0.2);(1024, 0, 0);Wait(0.2);(0, 0, 0);Wait(2)", "Test");

  LedStrip({this.ip,this.name});

  LedStrip.fromJson(Map<String, dynamic> json)
      : ip = json['ip'],
        configuration = Configuration.fromJson(json['configuration']),
        name = json['name'];

  Map<String, dynamic> toJson() =>
      {
        'ip': ip,
        'configuration': configuration,
        'name': name,
      };


  void sendConfigurationToStrip() async
  {
    print("Sending ${this.configuration.conf.join(";").replaceAll(' ', '')} to ${this.ip}.");
    await Socket.connect(this.ip, dataPort).then((socket) {
      print('Connected to: '
          '${socket.remoteAddress.address}:${socket.remotePort}');
      socket.write(this.configuration.conf.join(";").replaceAll(' ', ''));
      socket.destroy();
    });
  }
}
