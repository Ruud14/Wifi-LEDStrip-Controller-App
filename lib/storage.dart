import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:ledstripcontroller/ledstrip.dart';
import 'package:ledstripcontroller/configuration.dart';
import 'package:ledstripcontroller/group.dart';

// Updates the properties of a saved Group object.
void updateSavedGroup(String initialName, Group newGroup) async
{
  Storage storage  = Storage();
  await storage.setup();
  List<Group> newGroups = [];
  await storage.getGroups().then((savedGroups) async {
    for(int i=0; i < savedGroups.length; i++)
    {
      if(savedGroups[i].name == initialName)
      {
        newGroups.add(newGroup);
        for(int x=0; x<newGroup.strips.length; x++)
        {
          LedStrip newStrip = newGroup.strips[x];
          newStrip.configuration = newGroup.configuration;
          await updateSavedStrip(newGroup.strips[x].name, newStrip);
        }
      }
      else{
        newGroups.add(savedGroups[i]);
      }
    }
  });
  await storage.replaceGroupsFileContent(newGroups);
}

// Updates the properties of a saved LedStrip object.
void updateSavedStrip(String initialName, LedStrip newStrip) async
{
  Storage storage  = Storage();
  await storage.setup();
  List<LedStrip> newStrips = [];
  await storage.getStrips().then((savedStrips) {
    for(int i=0; i < savedStrips.length; i++)
    {
      if(savedStrips[i].name == initialName)
      {
        newStrips.add(newStrip);
      }
      else{
        newStrips.add(savedStrips[i]);
      }
    }
  });
  await storage.replaceStripsFileContent(newStrips);
}

// Delete strip from storage by name.
void deleteStrip(String initialName) async
{
  Storage storage  = Storage();
  await storage.setup();
  List<LedStrip> newStrips = [];
  await storage.getStrips().then((savedStrips) {
    for(int i=0; i < savedStrips.length; i++)
    {
      // Only add the strips that don't have initialName as their name.
      if(savedStrips[i].name != initialName)
      {
        newStrips.add(savedStrips[i]);
      }
      // Send a reset message to the strips that are removed from storage.
      else
        {
          print("Sending reset message to ${savedStrips[i].ip}.");
          Socket.connect(savedStrips[i].ip, dataPort).then((socket) {
            print('Connected to: '
                '${socket.remoteAddress.address}:${socket.remotePort}');
            socket.write("reset");
            socket.destroy();
          });
      }
    }
  });
  // Remove the strip from every group that it is part of.
  await storage.getGroups().then((savedGroups) async {
    for(int i=0; i < savedGroups.length; i++)
    {
      List<LedStrip> newGroupNames = [];
      for(int x=0; x < savedGroups[i].strips.length; x++)
      {
        if(savedGroups[i].strips[x].name != initialName)
        {
          newGroupNames.add(savedGroups[i].strips[x]);
        }
      }
      Group newGroup = savedGroups[i];
      newGroup.strips = newGroupNames;
      await updateSavedGroup(savedGroups[i].name, newGroup);
    }
  });
  await storage.replaceStripsFileContent(newStrips);
}

// Delete configuration from storage by name.
void deleteConfiguration(String initialName) async
{
  Storage storage  = Storage();
  await storage.setup();
  List<Configuration> newConfigurations = [];
  await storage.getConfigurations().then((savedConfigurations) {
    for(int i=0; i < savedConfigurations.length; i++)
    {
      // Only add the configurations that don't have initialName as their name.
      if(savedConfigurations[i].name != initialName)
      {
        newConfigurations.add(savedConfigurations[i]);
      }
    }
  });
  // Change the configuration of every strip that had the removed configuration to the 'Test' configuration.
  await storage.getStrips().then((savedStrips) async {
    for(int i=0; i < savedStrips.length; i++)
    {
      if(savedStrips[i].configuration.name == initialName)
      {
        LedStrip newStrip = savedStrips[i];
        newStrip.configuration = Configuration("(1024, 0, 0);Wait(0.2);(0, 0, 0);Wait(0.2);(1024, 0, 0);Wait(0.2);(0, 0, 0);Wait(2)", "Test");
        newStrip.sendConfigurationToStrip();
        await updateSavedStrip(savedStrips[i].name, newStrip);
      }
    }
  });
  // Change the configuration of every group that had the removed configuration to the 'Test' configuration.
  await storage.getGroups().then((savedGroups) async{
    for(int i=0; i < savedGroups.length; i++)
    {
      if(savedGroups[i].configuration.name == initialName)
      {
        Group newGroup = savedGroups[i];
        newGroup.configuration = Configuration("(1024, 0, 0);Wait(0.2);(0, 0, 0);Wait(0.2);(1024, 0, 0);Wait(0.2);(0, 0, 0);Wait(2)", "Test");
        await updateSavedGroup(savedGroups[i].name, newGroup);
      }
    }
  });
  await storage.replaceConfigurationsFileContent(newConfigurations);
}

// Delete Group from storage by name.
void deleteGroup(String initialName) async
{
  Storage storage  = Storage();
  await storage.setup();
  List<Group> newGroups = [];
  await storage.getGroups().then((savedGroups) {
    for(int i=0; i < savedGroups.length; i++)
    {
      // Only add the groups that don't have initialName as their name.
      if(savedGroups[i].name != initialName)
      {
        newGroups.add(savedGroups[i]);
      }
    }
  });
  await storage.replaceGroupsFileContent(newGroups);
}


// Changes the configuration of all strips with the specified configuration name.
void changeConfigurationOfStrips(String configurationName, Configuration newConfiguration) async
{
  Storage storage  = Storage();
  await storage.setup();
  List<LedStrip> newStrips = [];
  await storage.getStrips().then((savedStrips) {
    for(int i=0; i < savedStrips.length; i++)
    {
      if(savedStrips[i].configuration.name == configurationName)
      {
        LedStrip newStrip = savedStrips[i];
        newStrip.configuration = newConfiguration;
        newStrips.add(newStrip);
      }
      else{
        newStrips.add(savedStrips[i]);
      }
    }
  });
  await storage.replaceStripsFileContent(newStrips);
}

// Changes the configuration of all groups with the specified configuration name.
void changeConfigurationOfGroups(String configurationName, Configuration newConfiguration) async
{
  Storage storage  = Storage();
  await storage.setup();
  List<Group> newGroups = [];
  await storage.getGroups().then((savedGroups) async {
    for(int i=0; i < savedGroups.length; i++)
    {
      if(savedGroups[i].configuration.name == configurationName)
      {
        Group newGroup = savedGroups[i];
        newGroup.configuration = newConfiguration;

        for(int x=0; x<newGroup.strips.length; x++)
        {
          LedStrip newStrip = newGroup.strips[x];
          newStrip.configuration = newConfiguration;
          await updateSavedStrip(newGroup.strips[x].name, newStrip);
        }

        newGroups.add(newGroup);
      }
      else{
        newGroups.add(savedGroups[i]);
      }
    }
  });
  await storage.replaceGroupsFileContent(newGroups);
}

// Updates the saved configurations in storage.
// also changes the configuration of the strips and groups that have this configuration applied.
void updateSavedConfiguration(String initialName, Configuration newConfiguration) async
{
  Storage storage  = Storage();
  await storage.setup();
  List<Configuration> newConfs = [];
  await storage.getConfigurations().then((savedConfs) {
    for(int i=0; i < savedConfs.length; i++)
    {
      if(savedConfs[i].name == initialName)
      {
        newConfs.add(newConfiguration);
      }
      else{
        newConfs.add(savedConfs[i]);
      }
    }
  });
  await storage.replaceConfigurationsFileContent(newConfs);
  await changeConfigurationOfStrips(initialName, newConfiguration);
  await changeConfigurationOfGroups(initialName, newConfiguration);
}


// Class representation of the storage.
// The storage contains all the saved strips, groups and configurations.
class Storage
{
  File stripsFile;
  File configurationsFile;
  File groupsFile;
  String stripsFileName = "strips.json";
  String configurationsFileName = "configurations.json";
  String groupsFileName = "groups.json";
  List stripsFileContent;
  List configurationsFileContent;
  List groupsFileContent;
  bool stripsFileExists = false;
  bool configurationsFileExists = false;
  bool groupsFileExists = false;
  Directory dir;
  bool constructed = false;

  // Configures the storage so it can be accessed.
  void setup() async
  {
    await getApplicationDocumentsDirectory().then((Directory directory)
    {
      dir = directory;
      stripsFile = File(dir.path + "/" + stripsFileName);
      configurationsFile = File(dir.path + "/" + configurationsFileName);
      groupsFile = File(dir.path + "/" + groupsFileName);
      if(stripsFile.existsSync())
      {
        stripsFileExists = true;
        getStrips().then((value) => stripsFileContent);
      }
      else{
        createStripsFile();
      }
      if(configurationsFile.existsSync())
      {
        configurationsFileExists = true;
        getConfigurations().then((value) => configurationsFileContent);
      }
      else{
        createConfigurationsFile();
      }
      if(groupsFile.existsSync())
      {
        groupsFileExists = true;
        getGroups().then((value) => groupsFileContent);
      }
      else{
        createGroupsFile();
      }
      constructed = true;
    });
  }

  // Add strip the storage.
  void appendStripsFile(LedStrip strip) async
  {
    if(!constructed) {await setup();}
    if(!stripsFileExists)
      {
        await createStripsFile();
      }
    getStrips().then((oldStrips){
      oldStrips.add(strip);
      stripsFile.writeAsStringSync(json.encode({'strips':oldStrips}));
    });
  }

  // Replaces all saved strips.
  void replaceStripsFileContent(List<LedStrip> strips) async
  {
    if(!constructed) {
      await setup();
    }
    if(!stripsFileExists)
    {
      await createStripsFile();
    }
    stripsFile.writeAsStringSync(json.encode({'strips':strips}));
  }

  // Returns all the saved strips from storage.
  Future<List> getStrips() async
  {
    if(!constructed) {
      await setup();
    }
    if(!stripsFileExists)
    {
      await createStripsFile();
    }
    Map<String, dynamic> content = json.decode(stripsFile.readAsStringSync());
    List strips = content['strips'];
    List<LedStrip> convertedStrips = [];
    for(int i=0; i<strips.length; i++)
      {
        convertedStrips.add(LedStrip.fromJson(strips[i]));
      }
    return convertedStrips;
  }

  // Add configuration to storage.
  void appendConfigurationsFile(Configuration conf) async
  {
    if(!constructed) {await setup();}
    if(!configurationsFileExists)
    {
       await createConfigurationsFile();
    }
    getConfigurations().then((oldConfigurations) {
      oldConfigurations.add(conf);
      configurationsFile.writeAsStringSync(json.encode({'confs':oldConfigurations}));
    });
  }

  // Replace all the configurations in storage.
  void replaceConfigurationsFileContent(List<Configuration> confs) async
  {
    if(!constructed) {
      await setup();
    }
    if(!configurationsFileExists)
    {
      await createConfigurationsFile();
    }
    configurationsFile.writeAsStringSync(json.encode({'confs':confs}));
  }

  // Returns all the configurations from storage.
  Future<List> getConfigurations() async
  {
    if(!constructed) {
      await setup();
    }
    if(!configurationsFileExists)
    {
      await createConfigurationsFile();
    }
    Map<String, dynamic> content = json.decode(configurationsFile.readAsStringSync());
    List confs = content['confs'];
    List<Configuration> convertedConfs = [];
    for(int i=0; i<confs.length; i++)
    {
      convertedConfs.add(Configuration.fromJson(confs[i]));
    }
    return convertedConfs;
  }

  // Adds group to storage.
  void appendGroupsFile(Group group) async
  {
    if(!constructed) {await setup();}
    if(!groupsFileExists)
    {
      await createGroupsFile();
    }
    getGroups().then((oldGroups) {
      oldGroups.add(group);
      groupsFile.writeAsStringSync(json.encode({'groups':oldGroups}));
    });
  }

  // Replaces all the groups in storage.
  void replaceGroupsFileContent(List<Group> groups) async
  {
    if(!constructed) {
      await setup();
    }
    if(!groupsFileExists)
    {
      await createGroupsFile();
    }
    groupsFile.writeAsStringSync(json.encode({'groups':groups}));
  }

  // Returns all the groups from the storage.
  Future<List> getGroups() async
  {
    if(!constructed) {
      await setup();
    }
    if(!groupsFileExists)
    {
      await createGroupsFile();
    }
    Map<String, dynamic> content = json.decode(groupsFile.readAsStringSync());
    List groups = content['groups'];
    List<Group> convertedGroups = [];
    for(int i=0; i<groups.length; i++)
    {
      convertedGroups.add(Group.fromJson(groups[i]));
    }
    return convertedGroups;
  }

  // Creates the file for storing strips.
  void createStripsFile()
  {
    stripsFile = File(dir.path + "/" + stripsFileName);
    stripsFile.createSync();
    stripsFileExists = true;
    stripsFile.writeAsStringSync(json.encode({'strips':[]}));
  }
  // Creates the file for storing configurations.
  void createConfigurationsFile()
  {
    configurationsFile = File(dir.path + "/" + configurationsFileName);
    configurationsFile.createSync();
    configurationsFileExists = true;
    configurationsFile.writeAsStringSync(json.encode({'confs':[]}));
  }
  // Creates the file for storing groups.
  void createGroupsFile()
  {
    groupsFile = File(dir.path + "/" + groupsFileName);
    groupsFile.createSync();
    groupsFileExists = true;
    groupsFile.writeAsStringSync(json.encode({'groups':[]}));
  }


  // Deletes the file that stores the strips.
  void deleteStripsFile()
  {
    stripsFile = File(dir.path + "/" + stripsFileName);
    stripsFile.deleteSync();
    stripsFileExists = false;
  }
  // Deletes the file that stores the configurations.
  void deleteConfigurationsFile()
  {
    configurationsFile = File(dir.path + "/" + configurationsFileName);
    configurationsFile.deleteSync();
    configurationsFileExists = false;
  }
  // Deletes the file that stores the groups.
  void deleteGroupsFile()
  {
    groupsFile = File(dir.path + "/" + groupsFileName);
    groupsFile.deleteSync();
    groupsFileExists = false;
  }
}
