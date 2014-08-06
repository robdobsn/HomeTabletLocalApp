import os
import sys

# Note that on windows this script is best run from cmd prompt rather than in IDLE
tablet_names = [ "tabkitchen", "tabsitting", "tabgames", "tabhall", "tabmasterbed",
               "tablanding", "tabgrace", "tabguest", "taboffice", "tabjoe" ]
adbRemoteCmds = [ "setprop service.adb.tcp.port 5555", "stop adbd", "start adbd" ]

# Run on all tablets
cmdStr = ""
if len(sys.argv) > 1:
    for cmdIdx in range(1,len(sys.argv)):
        cmdStr += sys.argv[cmdIdx] + " "
    if cmdStr[0:2] == "-t":
        cmdSplit = cmdStr.split(" ")
        tablet_names = [ cmdSplit[1] ]
        cmdStr = ""
        for cmdIdx in range(2, len(cmdSplit)):
            cmdStr += cmdSplit[cmdIdx] + " "
        print ("Running cmd on " + tablet_names[0])
    if cmdStr[0:3] == "adb":
        cmdStr = "adb -s {tabname}" + cmdStr[3:]
else:
    print ("Suitable commands:")
    print ("adb shell pm list packages ... list packages installed")
    print ("adb shell pm uninstall com.robdobsn.hometablet ... uninstall hometablet app")
    print ("adb shell am force-stop com.robdobsn.hometablet ... stop hometablet app")
    print ("adb shell am start -n com.robdobsn.hometablet/com.robdobsn.hometablet.HomeTablet ... start hometablet app")
    print ("adb shell ps ... list running processes")
    exit(0)

print ("Command is " + cmdStr)

os.system("adb disconnect")

# Get admin pw for tablets
tablet_pw = raw_input("Enter password for tablets: ")

# Now install on each tablet
for tabname in tablet_names:
    print "Running command on " + tabname

    # Using plink which is like putty but takes a command to run remotely as parameter
    tabfullname = tabname+".local"
    tabfullplusport = tabfullname + ":5555"
    plinkCmd = 'plink.exe root@' + tabfullname + ' -pw ' + tablet_pw + " "


    # Set up adbd on the remote system
    for cmd in adbRemoteCmds:
        result = os.system(plinkCmd + cmd)

    # Connect adb on local system to remote
    result = os.system("adb connect " + tabfullplusport)
    print "Result = " + str(result)
    checkCmd = "adb devices"
    result = os.system(checkCmd)

    # Run command
#    runCmd = "adb shell am force-stop "
#    runCmd = "phonegap install android"
    specCmdStr = cmdStr.format(tabname=tabfullplusport)
    result = os.system(specCmdStr)
    print (specCmdStr + " Result = " + str(result))
    
    os.system("adb disconnect " + tabfullplusport)

#raw_input("press enter")

