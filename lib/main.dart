import 'package:flutter/material.dart';
import 'package:ledstripcontroller/pages/home.dart';
import 'package:ledstripcontroller/pages/configuration_control.dart';
import 'package:ledstripcontroller/pages/configurations.dart';
import 'package:ledstripcontroller/pages/strip_control.dart';
import 'package:ledstripcontroller/pages/loading.dart';
import 'package:ledstripcontroller/pages/group_control.dart';
import 'package:ledstripcontroller/pages/strip_add.dart';
import 'package:ledstripcontroller/pages/strip_new.dart';
import 'package:ledstripcontroller/pages/settings.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:ledstripcontroller/pages/strip_add_connected.dart';

void main() {
  runApp(Main());
}

class Main extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DynamicTheme(
      defaultBrightness: Brightness.dark,
      data: (brightness) => new ThemeData(
        brightness: brightness,
        primaryColor: Colors.amber,
      ),
      themedWidgetBuilder: (context, theme) {
        return MaterialApp(
          initialRoute: '/',
          routes:
          {
            '/': (context) => Loading(),                                      // Loads all the stored data.
            '/home': (context) => Home(),                                     // Shows the home screen with the saved strips and groups.
            '/configurations': (context) => ConfigurationsPage(),             // Shows the saved configurations.
            '/configuration_control': (context) => ConfigurationControl(),    // page to make changes to a specific configuration.
            '/strip_control': (context) => StripControl(),                    // Page to make changes to a specific ledstrip.
            '/group_control': (context) => GroupControl(),                    // Page to make changes to a specific group.
            '/strip_add': (context) => StripAdd(),                            // Page that shows new strips on the network.
            '/strip_add_connected': (context) => StripAddConnected(),         // Page to manually add a strip that is already connected to the wifi.
            '/strip_new': (context) => StripNew(),                            // Page to configure a new strip from the network.
            '/settings': (context) => Settings(),
          },
          theme: theme,
        );
      },
    );
  }
}






