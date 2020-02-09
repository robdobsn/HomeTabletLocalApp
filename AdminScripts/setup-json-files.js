
(function() {
  var DefaultTabletConfig, bAction, blindsActions, calendarServerUrl, commonConfig, configServerSaveURL;
  var configSettingsToGet, configsToSet, dAction, defaultTabletConfig, devConf, deviceConfigList, devicesInfoMaster;
  var devicesInfoMasterSource, devicesInfoMasterStr, doorActions, energyServerUrl, frontDoorLockHostname;
  var frontDoorLockUserNum, frontDoorLockUserPin, fs, gamesRoomBlindsHostname, genBlindsActions, getBlindsActions;
  var getDeviceConfigList, getDoorActions, getServerList, getSonosConfig, i, j, k, key, l;
  var landingBathBlindsHostname, len, len1, len2, len3, newConfig, officeBlindsHostname, replaceAll, replaceFavs;
  var request, sAction, sendConfigToConfigServer, sonosConfig, sonosServerUrl, val;

  fs = require('fs');

  request = require('request');

  DefaultTabletConfig = require('../www/js/default-tablet-config.js');

  getSonosConfig = function(deviceConfigList) {
    var act, actionConfig, confIdx, deviceConfig, i, j, len, len1, roomName, sonosConfig, sonosRoomName;
    sonosConfig = [];
    for (confIdx = i = 0, len = deviceConfigList.length; i < len; confIdx = ++i) {
      deviceConfig = deviceConfigList[confIdx];
      sonosRoomName = deviceConfig['sonosRoomName'];
      roomName = deviceConfig['roomName'];
      // Add sonos config if there is a sonos device in the room
      if (deviceConfig['sonosRoomName'] === '') {
        confIdx++;
        continue;
      }
      actionConfig = [
        {
          'actionName': 'Play',
          'iconName': 'music-play',
          'uri': '/play'
        },
        {
          'actionName': 'Stop',
          'iconName': 'music-stop',
          'uri': '/pause'
        },
        {
          'actionName': 'Vol +',
          'iconName': 'music-vol-up',
          'uri': '/volume/+10'
        },
        {
          'actionName': 'Vol -',
          'iconName': 'music-vol-down',
          'uri': '/volume/-10'
        }
      ];
// Add the serverpath and tile info
      for (j = 0, len1 = actionConfig.length; j < len1; j++) {
        act = actionConfig[j];
        act['actionUrl'] = sonosServerUrl + '/' + sonosRoomName + act['uri'];
        act['uri'] = sonosServerUrl + '/' + sonosRoomName + act['uri'];
        act['groupName'] = roomName;
        act['tierName'] = 'sonosTier';
        act['colSpan'] = 1;
        act['rowSpan'] = 1;
        act['name'] = act['actionName'];
        act['visibility'] = 'all';
        act['tileType'] = 'Sonos';
        sonosConfig.push(act);
      }
      // console.log("setting sonos actions config for " + sonosRoomName);
      confIdx++;
    }
    return sonosConfig;
  };

  getBlindsActions = function() {
    var blindsDef;
    blindsDef = [
       ["Games", [["1", "Shade 1"], ["2", "Shade 2"]], "http://" + gamesRoomBlindsHostname + "/blind/"],
       ["Kitchen Front", [["3", "Front"]], "http://" + kitchenFrontBlindsHostname + "/blind/"], 
       ["Kitchen Back", [["4", "Left"], ["5", "Right"]], "http://" + kitchenBackBlindsHostname + "/blind/"], 
       ["Landing Bath", [["1", "Shade"]], "http://" + landingBathBlindsHostname + "/blind/"], 
       ["Office", [["1", "Rob's Shade"], ["2", "Left"], ["3", "Mid-Left"], ["4", "Mid-Right"], ["5", "Right"]], "http://" + officeBlindsHostname + "/blind/"]];
    return genBlindsActions(blindsDef);
  };

  genBlindsActions = function(blindsDefs) {
    var actions, blindsDirns, dirn, i, j, k, len, len1, len2, ref, room, win;
    blindsDirns = [["Up", "up"], ["Stop", "stop"], ["Down", "down"]];
    actions = [];
    for (i = 0, len = blindsDefs.length; i < len; i++) {
      room = blindsDefs[i];
      for (j = 0, len1 = blindsDirns.length; j < len1; j++) {
        dirn = blindsDirns[j];
        ref = room[1];
        for (k = 0, len2 = ref.length; k < len2; k++) {
          win = ref[k];
          actions.push({
            tierName: "doorBlindsTier",
            actionNum: 0,
            actionName: win[1] + " " + dirn[0],
            groupName: room[0],
            actionUrl: room[2] + win[0] + "/" + dirn[1] + "/pulse",
            iconName: "blinds-" + dirn[1]
          });
        }
      }
    }
    return actions;
  };

  getDoorActions = function() {
    return [
      {
        //		{
        //			actionName: "Main Unlock", groupName: "Front Door", iconName: "door-unlock",
        //			actionUrl: "https://api.particle.io/v1/devices/320035001147343438323536/apiCall\?access_token=ab1fba812bf2ff055ef347d9230be5d9a470bdfe~POST~arg=main-unlock"
        //		},
        //		{
        //			actionName: "Main Lock", groupName: "Front Door", iconName: "door-lock",
        //			actionUrl: "https://api.particle.io/v1/devices/320035001147343438323536/apiCall\?access_token=ab1fba812bf2ff055ef347d9230be5d9a470bdfe~POST~arg=main-lock"
        //		},
        //		{
        //			actionName: "Inner Unlock", groupName: "Front Door", iconName: "door-unlock",
        //			actionUrl: "https://api.particle.io/v1/devices/320035001147343438323536/apiCall\?access_token=ab1fba812bf2ff055ef347d9230be5d9a470bdfe~POST~arg=inner-unlock"
        //		},
        //		{
        //			actionName: "Inner Lock", groupName: "Front Door", iconName: "door-lock",
        //			actionUrl: "https://api.particle.io/v1/devices/320035001147343438323536/apiCall\?access_token=ab1fba812bf2ff055ef347d9230be5d9a470bdfe~POST~arg=inner-unlock"
        //		}
        actionName: "Main Unlock",
        groupName: "Front Door",
        actionUrl: "http://" + frontDoorLockHostname + "/u/0/" + frontDoorLockUserNum + "/" + frontDoorLockUserPin,
        iconName: "door-unlock"
      },
      {
        actionName: "Main Lock",
        groupName: "Front Door",
        actionUrl: "http://" + frontDoorLockHostname + "/l/0",
        iconName: "door-lock"
      },
      {
        actionName: "Inner Unlock",
        groupName: "Front Door",
        actionUrl: "http://" + frontDoorLockHostname + "/u/1/" + frontDoorLockUserNum + "/" + frontDoorLockUserPin,
        iconName: "door-unlock"
      },
      {
        actionName: "Inner Lock",
        groupName: "Front Door",
        actionUrl: "http://" + frontDoorLockHostname + "/l/1",
        iconName: "door-lock"
      }
    ];
  };

  getDeviceConfigList = function(configDb) {
    var baseFolder, devInfo, deviceInfoList, fIdx, folderList, jsonStr;
    deviceInfoList = [];
    // Get contents of folder to find device definition files
    baseFolder = './tablets/';
    folderList = fs.readdirSync(baseFolder);
    fIdx = 0;
    while (fIdx < folderList.length) {
      if (folderList[fIdx].indexOf('.json') > 0) {
        jsonStr = fs.readFileSync(baseFolder + folderList[fIdx], {
          encoding: 'utf8'
        });
        jsonStr = replaceAll('@sonosServerUrl', sonosServerUrl, jsonStr);
        devInfo = JSON.parse(jsonStr);
        deviceInfoList.push(devInfo);
      }
      fIdx++;
    }
    return deviceInfoList;
  };

  getServerList = function() {
    return [
      {
      //   // {"type":"indigo", "name":"IndigoUp", "url":"http://192.168.0.230:8176", "iconAliasing":"automationIcons" },
      //   // {"type":"indigo", "name":"IndigoDown", "url":"http://192.168.0.231:8176", "iconAliasing":"automationIcons"  },
        "type": "RobHome",
        "name": "RobHomeServer",
        "url": "http://192.168.86.235:5076",
        "iconAliasing": "automationIcons"
      },
      {
        "type": "domoticz",
        "name": "DomoticzPLC",
        "url": "http://192.168.86.233:80",
        "iconAliasing": "automationIcons"
      },
      {
        "type": "domoticz",
        "name": "DomoticzCEL",
        "url": "http://192.168.86.234:80",
        "iconAliasing": "automationIcons"
      },
      {
        "type": "domoticz",
        "name": "DomoticzOFF",
        "url": "http://192.168.86.235:80",
        "iconAliasing": "automationIcons"
      },
      {
        "type": "domoticz",
        "name": "DomoticzKIT",
        "url": "http://192.168.86.231:80",
        "iconAliasing": "automationIcons"
      }
    ];
  };

  // {"type":"domoticz", "name":"DomoticzOFI", "url":"http://192.168.0.235:80", "iconAliasing":"automationIcons"  },
  // {"type":"indigo-test", "name":"IndigoTest", "url":"", "iconAliasing":"automationIcons"  },
  // {"type":"fibaro", "name":"FibaroHS2", "url":"http://macallan:5079" },
  // {"type":"vera", "name":"Vera", "url":"http://192.168.0.206:3480" },
  // {"type":"intermediate", "name":"intermediate", "url":"http://macallan:5000" },
  sendConfigToConfigServer = function(deviceConfig, configsToSet, favourites) {
    var configUrl, options;
    // Send to the config server
    configUrl = configServerSaveURL + deviceConfig['deviceName'];
    options = {
      uri: configUrl,
      method: 'POST',
      json: true,
      headers: {
        "content-type": "application/json"
      },
      body: deviceConfig
    };
    console.log("Sending config for " + deviceConfig['deviceName']);
    request(options, function(error, response, body) {
      if (error != null) {
        console.error("Failed to post data to " + configUrl + ", err: " + error);
      } else {
        console.info("Config for " + deviceConfig['deviceName'] + "sent to " + configUrl);
      }
    });
  };

  sendConfigToJSONFiles = function(deviceConfig, configsToSet, favourites) {
    var configUrl, options;
    // Send to the config file
    configFileName = "//domoticzoff/NodeUserHome/config/" + deviceConfig['deviceName'] + ".json";
    var jsonStr = JSON.stringify(deviceConfig, null, 2);
    fs.writeFile(configFileName, jsonStr, 'utf8', (err) => {
      if (err) {
          console.error(err);
          return;
      };
    });

    // console.info(configFileName);
    // configUrl = configServerSaveURL + deviceConfig['deviceName'];
    // options = {
    //   uri: configUrl,
    //   method: 'POST',
    //   json: true,
    //   headers: {
    //     "content-type": "application/json"
    //   },
    //   body: deviceConfig
    // };
    // console.log("Sending config for " + deviceConfig['deviceName']);
    // request(options, function(error, response, body) {
    //   if (error != null) {
    //     console.error("Failed to post data to " + configUrl + ", err: " + error);
    //   } else {
    //     console.info("Config for " + deviceConfig['deviceName'] + "sent to " + configUrl);
    //   }
    // });
    // console.info(deviceConfig, configsToSet, favourites)
  };

  //	"/home/nodeuser/config/" + deviceConfig['deviceName'] + ".json";

  //	configDb.collection('TabletConfig').findOne { 'deviceName': deviceConfig['deviceName'] },
  //		(err, doc) ->
  //			# console.log("current doc " + JSON.stringify(doc))
  //			# Get favourites - use current database unless not there
  //			curFavourites = []
  //			if (not replaceFavs) and doc? and doc.favourites? and doc.favourites.length isnt 0
  //				# De-duplicate
  //				curFavourites.push fav for fav in doc.favourites when fav not in curFavourites

  //			# Debug code
  //			# if deviceConfig['deviceName'] is "tabmasterbed"
  //			# 	for fav in curFavourites
  //			# 		console.log "tab " + deviceConfig['deviceName'] + " curdbFavourite " + JSON.stringify(fav)
  //			# 	for fav in deviceConfig["favourites"]
  //			# 		console.log "tab " + deviceConfig['deviceName'] + " fileFavourite " + JSON.stringify(fav)

  //			if curFavourites.length > 0
  //				deviceConfig["favourites"] = curFavourites
  //			# Merge favourites - adding only distinct ones - no longer doing this way
  //			# favsToAdd = []
  //			# for curFav in curFavourites
  //			# 	addThis = true
  //			# 	for newFav in deviceConfig["favourites"]
  //			# 		if curFav.tileName is newFav.tileName and curFav.groupName is newFav.groupName
  //			# 			addThis = false
  //			# 			break
  //			# 	if addThis
  //			# 		favsToAdd.push curFav
  //			# for fav in favsToAdd
  //			# 	deviceConfig["favourites"].push fav

  //			# Debug code
  //			# if deviceConfig['deviceName'] is "tabmasterbed"
  //			# 	for fav in deviceConfig["favourites"]
  //			# 		console.log "tab " + deviceConfig['deviceName'] + " finalFavourite " + JSON.stringify(fav)

  //			# Set the new config
  //			configsToSet.count++
  //			# console.log "++ " + configsToSet.count
  //			configDb.collection('TabletConfig').update { 'deviceName': deviceConfig['deviceName'] },
  //				deviceConfig, {upsert:true}, (err, numberOfRemovedDocs) ->
  //					if err isnt null
  //						console.log 'Failed to save new info ' + err
  //						configDb.close()
  //						process.exit 1
  //					else
  //						configsToSet.count--
  //						# console.log "-- " + configsToSet.count
  //						if configsToSet.count is 0
  //							console.log 'All config set'
  //							configDb.close()
  //							process.exit 1
  //					return
  //			return
  //	return

  // Config server URL
  configServerSaveURL = "http://192.168.86.235:5076/tabletconfig/";

  //configServerSaveURL = "http://localhost:5076/tabletconfig/"

  // Devices info master
  devicesInfoMasterSource = "//domoticzoff/PiShare/nodeuser/config/MasterDevices.json";

  devicesInfoMasterStr = fs.readFileSync(devicesInfoMasterSource, {
    encoding: 'utf8'
  });

  devicesInfoMaster = JSON.parse(devicesInfoMasterStr);

  // Check for override current favourites from files
  replaceFavs = false;

  if ((process.argv[2] != null) && process.argv[2] === "-replacefavs" || (process.argv[3] != null) && process.argv[3] === "-replacefavs") {
    replaceFavs = true;
  }

  // Sonos Server URL
  sonosServerUrl = devicesInfoMaster.devices.sonosServer.url;

  console.log("SonosServer is " + sonosServerUrl);

  // Calendar and energy servers
  calendarServerUrl = devicesInfoMaster.devices.calendarServer.url;

  energyServerUrl = devicesInfoMaster.devices.energyServer.url;

  console.log("CalendarServer is " + calendarServerUrl);

  console.log("EnergyServer is " + energyServerUrl);

  // Blinds
  officeBlindsHostname = devicesInfoMaster.devices.officeBlinds.hostname;

  gamesRoomBlindsHostname = devicesInfoMaster.devices.gamesRoomBlinds.hostname;

  landingBathBlindsHostname = devicesInfoMaster.devices.landingBathBlinds.hostname;

  let kitchenFrontBlindsHostname = devicesInfoMaster.devices.kitchenFrontBlinds.hostname;
  let kitchenBackBlindsHostname = devicesInfoMaster.devices.kitchenBackBlinds.hostname;

  console.log("OfficeBlinds is " + officeBlindsHostname);

  console.log("Games Room Blinds is " + gamesRoomBlindsHostname);

  console.log("Kitchen Front Blinds is " + kitchenFrontBlindsHostname);
  console.log("Kitchen Back Blinds is " + kitchenBackBlindsHostname);

  console.log("Landing Bath Blinds is " + landingBathBlindsHostname);

  // Front Door Lock
  frontDoorLockHostname = devicesInfoMaster.devices.frontDoorLock.hostname;

  frontDoorLockUserNum = devicesInfoMaster.devices.frontDoorLock.userNum;

  frontDoorLockUserPin = devicesInfoMaster.devices.frontDoorLock.userPin;

  console.log("Front Door is " + frontDoorLockHostname);

  replaceAll = function(find, replace, str) {
    return str.replace(new RegExp(find, 'g'), replace);
  };

  console.log('Setting Tablet Configuration from folder');

  console.log(__dirname + '/tablets');

  console.log();

  configsToSet = {
    count: 0
  };

  // Get the default config
  defaultTabletConfig = new DefaultTabletConfig();

  configSettingsToGet = {
    showCalServerButton: true,
    showEnergyServerButton: true,
    calServerUrl: calendarServerUrl + "/calendar/min/45",
    energyServerUrl: energyServerUrl
  };

  commonConfig = defaultTabletConfig.get(configSettingsToGet);

  // Get the list of tablets from the configuration
  deviceConfigList = getDeviceConfigList();

  // Get Sonos/Blinds/Door configs
  doorActions = getDoorActions();

  sonosConfig = getSonosConfig(deviceConfigList);

  blindsActions = getBlindsActions();

// Add blinds and sonos actions to common config
  for (i = 0, len = doorActions.length; i < len; i++) {
    dAction = doorActions[i];
    commonConfig.common.fixedActions.push(dAction);
  }

  for (j = 0, len1 = blindsActions.length; j < len1; j++) {
    bAction = blindsActions[j];
    commonConfig.common.fixedActions.push(bAction);
  }

  for (k = 0, len2 = sonosConfig.length; k < len2; k++) {
    sAction = sonosConfig[k];
    commonConfig.common.fixedActions.push(sAction);
  }

// Go through tablets (devices) that have config info
  for (l = 0, len3 = deviceConfigList.length; l < len3; l++) {
    devConf = deviceConfigList[l];
    // Add in the favourites and other info like tablet name
    newConfig = {};
    for (key in devConf) {
      val = devConf[key];
      newConfig[key] = val;
    }
    // Set the common configuration for all tablets
    newConfig["common"] = commonConfig.common;
    newConfig.common["servers"] = getServerList();
    sendConfigToJSONFiles(newConfig, configsToSet, devConf.favourites);
  }

}).call(this);

//# sourceMappingURL=setup-db.js.map
