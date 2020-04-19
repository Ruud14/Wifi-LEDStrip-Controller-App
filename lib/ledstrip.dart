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
    await this.sendMSG(this.configuration.conf.join(";").replaceAll(' ', ''));
  }
  void turnOff() async
  {
    await this.sendMSG("off");
  }
  void restart() async
  {
    await this.sendMSG("restart");
  }
  void reset() async
  {
    await this.sendMSG("reset");
  }
  void sendMSG(String what) async
  {
    print("Sending $what message to ${this.ip}.");
    await Socket.connect(this.ip, dataPort).then((socket) {
      print('Connected to: '
          '${socket.remoteAddress.address}:${socket.remotePort}');
      socket.write(what);
      socket.destroy();
    });
  }
}
