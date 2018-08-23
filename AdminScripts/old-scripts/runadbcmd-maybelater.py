import os
import sys

# Note that on windows this script is best run from cmd prompt rather than in IDLE
tablet_names = [ "tabkitchen", "tabsitting", "tabgames", "tabhall", "tabmasterbed",
               "tablanding", "tabgrace", "tabguest", "taboffice", "tabjoe" ]
adbRemoteCmds = [ "setprop service.adb.tcp.port 5555", "stop adbd", "start adbd" ]

# Check if we want all tablets or just one
cmdStr = ""
if len(sys.argv) > 1:
    for cmdIdx in range(1,len(sys.argv)):
        cmdStr += sys.argv[cmdIdx] + " "
else:
    print ("Suitable commands:")
    print ("adb shell pm list packages ... list packages installed")
    print ("adb shell pm uninstall com.robdobsn.hometablet ... uninstall hometablet app")
    print ("adb shell am force-stop com.robdobsn.hometablet ... stop hometablet app")
    print ("adb shell am start -n com.robdobsn.hometablet/com.robdobsn.hometablet.HomeTablet ... start hometablet app")
    print ("adb shell ps ... list running processes")
    exit(0)

print (cmdStr)

os.system("adb disconnect")

# Get admin pw for tablets
tablet_pw = raw_input("Enter password for tablets: ")

# Now install on each tablet
for tabname in tablet_names:
    print "Running command on " + tabname

    # Using plink which is like putty but takes a command to run remotely as parameter
    tabfullname = tabname+".local"
    plinkCmd = 'plink.exe root@' + tabfullname + ' -pw ' + tablet_pw + " "


    # Set up adbd on the remote system
    for cmd in adbRemoteCmds:
        result = os.system(plinkCmd + cmd)

    # Connect adb on local system to remote
    result = os.system("adb connect " + tabfullname + ":5555")
    print "Result = " + str(result)
    checkCmd = "adb devices"
    result = os.system(checkCmd)

    # Run command
#    runCmd = "adb shell am force-stop "
#    runCmd = "phonegap install android"
    result = os.system(cmdStr)
    print (cmdStr + " Result = " + str(result))
    
    os.system("adb disconnect " + tabfullname + ":5555")

#raw_input("press enter")

