import os
import sys

# Note that on windows this script is best run from cmd prompt rather than in IDLE
all_tablet_names = [ "tabkitchen", "tabsitting", "tabgames", "tabhall", "tabmasterbed",
               "tablanding", "tabgrace", "tabguest", "taboffice", "tabjoe", "tablobby" ]
adbRemoteCmds = [ "setprop service.adb.tcp.port 5555", "stop adbd", "start adbd" ]

# Check if we want all tablets or just one
if len(sys.argv) > 1:
    tablet_names = []
    tablet_names.append(sys.argv[1])
    print ("Operating on " + tablet_names[0])
else:
    tablet_names = all_tablet_names

# Get admin pw for tablets
tablet_pw = raw_input("Enter password for tablets: ")

# First build the phonegap app
buildCmd = "phonegap build android"
result = os.system(buildCmd)
print "Build result = " + str(result)

# Now install on each tablet
for tabname in tablet_names:
    print "Attempting installation on " + tabname

    # Using plink which is like putty but takes a command to run remotely as parameter
    tabfullname = tabname+".local"
    tabfullplusport = tabfullname + ":5555"
    plinkCmd = 'plink.exe root@' + tabfullname + ' -pw ' + tablet_pw + " "

    # Set up adbd on the remote system
    for cmd in adbRemoteCmds:
        result = os.system(plinkCmd + cmd)

    # Connect adb on local system to remote
    result = os.system("adb connect " + tabfullplusport)
    print "ADB CONNECT Result = " + str(result)
    checkCmd = "adb devices"
    result = os.system(checkCmd)
    print "ADB DEVICES Result = " + str(result)

    # Install the app
    runCmd = "phonegap install --device=" + tabfullplusport + " android"
    print "Running command ... " + runCmd
    result = os.system(runCmd)
    print "Install result = " + str(result)
    os.system("adb disconnect " + tabfullplusport)

#raw_input("press enter")

