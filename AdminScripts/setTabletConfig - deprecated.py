__author__ = 'rob'

from pymongo import MongoClient

favouritesConfig = {
        "tabkitchen":   [ "Kitchen Mood", "Kitchen Off", "Kitchen On", "Kitchen|Play", "Kitchen|Stop", "Radio 4&groupName=Kitchen", "Kitchen|Vol +", "Kitchen|Vol -", "Dinner Ready", "Conservatory On&destGroup=Conservatory", "Conservatory Off&destGroup=Conservatory" ],
        "tabsitting":   [ "Living Room On", "Living Room Off", "Hall Off" ],
        "tabgames":     [ "Games Room On", "Games Room Off" ],
        "tabhall":      [ "Hall Mood", "Hall Off", "Nighttime" "Cloakroom On", "Cloakroom Off", "Cellar On" ],
        "tabmasterbed": [ "Master Bed Mood", "Master Bed Off", "Master Bath Mood", "Master Bath Off", "Master Bed On", "Master Bath On" ],
        "tablanding":   [ "Hall Mood", "Hall Off", "Nighttime", "Office On", "Office Off", "Hall On" ],
        "tabgrace":     [ "Grace 1", "Grace 2", "Grace Off", "Grace Bath On", "Grace Bath Off", "Grace On" ],
        "tabguest":     [ "Guest Bed 1 On", "Guest Bed 1 Off", "Guest Bath 1 On", "Guest Bath 1 Off" ],
        "taboffice":    [ "Office Mood", "Office On", "Office Off" ],
        "tabjoe":       [ "Joe Evening", "Joe Off", "Joe On", "Joe Bath On", "Spidey On", "Spidey Off" ],
        "fractal":      [ "Kitchen Mood", "Kitchen Off", "Kitchen On", "Kitchen|Play", "Kitchen|Stop", "Radio 4&groupName=Kitchen", "Kitchen|Vol +", "Kitchen|Vol -", "Dinner Ready", "Conservatory On&destGroup=Conservatory", "Conservatory Off&destGroup=Conservatory" ]
}

mongoDbServer =  "mongodb://macallan/"
mongoClient = MongoClient(mongoDbServer)
configDb = mongoClient.WallTablets

configDb.TabletConfig.drop()

for tabName, tabFavs in favouritesConfig.items():
    confList = []
    for tileDef in tabFavs:
        tileConf = {}
        splitAmp = tileDef.split("&")
        if len(splitAmp) > 0:
            splitDef = splitAmp[0].split("|")
            if len(splitDef) > 1:
                tileConf["groupName"] = splitDef[0]
                tileConf["tileName"] = splitDef[1]
            elif len(splitDef) == 1:
                tileConf["tileName"] = splitDef[0]
            for sa in splitAmp[1:len(splitAmp)]:
                splitQ = sa.split("=")
                if len(splitQ) == 2:
                    tileConf[splitQ[0]] = splitQ[1]
            confList.append(tileConf)
    tabConfig = { "deviceName" : tabName.strip(),
                  "favourites" : confList
    }
    configDb.TabletConfig.insert(tabConfig)

