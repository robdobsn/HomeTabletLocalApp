from __future__ import print_function
from builtins import input
import os
import sys
from subprocess import Popen, PIPE

# Note that on windows this script is best run from cmd prompt rather than in IDLE
all_tablet_names = ["tabgames",
                    "tabhall",
                    "tabmasterbed",
                    "tablanding",
                    # "192.168.0.78", # "tabgrace"
                    "tabguest",
                    "taboffice",
                    "tabjoe",
                    # "tablobby",
                    # "192.168.0.219",
                    "tabsitting"]
adbRemoteCmds = ["setprop service.adb.tcp.port 5555", "stop adbd", "start adbd"]

# Check if we want all tablets or just one
if len(sys.argv) > 1:
    if sys.argv[1] == "-":
        tablet_names = all_tablet_names
        for i in range(2,len(sys.argv)):
            tablet_names.remove(sys.argv[i])
    else:
        tablet_names = []
        for i in range(1,len(sys.argv)):
            tablet_names.append(sys.argv[i])
else:
    tablet_names = all_tablet_names

print("Operating on ", end="")
for tabname in tablet_names:
    print(tabname, end="")
print()

# Get admin pw for tablets
tablet_pw = input("Enter password for walltablet(s): ")

# First build the phonegap app
# buildCmd = "phonegap build android"
# result = os.system(buildCmd)
# print("Build result = " + str(result))

# Now install on each tablet
commandResults = []
for tabname in tablet_names:
    print("Attempting connection to " + tabname)

    # Using plink which is like putty but takes a command to run remotely as parameter
    tabfullname = tabname+".local"
    tabfullplusport = tabfullname + ":5555"
    plinkCmd = 'plink.exe root@' + tabfullname + ' -pw ' + tablet_pw + " "

    # Set up adbd on the remote system
    for cmd in adbRemoteCmds:
        result = os.system(plinkCmd + cmd)

    # Connect adb on local system to remote
    p = Popen(['adb', 'connect', tabfullplusport], stdout=PIPE, stderr=PIPE, stdin=PIPE)
    output0 = p.stdout.read()
    p.wait()
    print("ADB CONNECT Result = " + str(output0))
    # result = os.system("adb connect " + tabfullplusport)
    # print("ADB CONNECT Result = " + str(result))

    # Check that the device connected by calling ADB DEVICES
    p = Popen(['adb', 'devices'], stdout=PIPE, stderr=PIPE, stdin=PIPE)
    output = p.stdout.read()
    p.wait()
    print("ADB DEVICES Result = " + str(output))

    if not tabname in output:
        commandResults.append("Failed to connect to " + tabname)
        continue

    # Install the app
    print("Running cordova install on " + tabname)
    p2 = Popen(['cordova', 'install', '--device=' + tabfullplusport, 'android'], shell=True, stdout=PIPE, stderr=PIPE, stdin=PIPE)
    output2 = p2.stdout.read()
    output3 = p2.stderr.read()
    p2.wait()
    # print("Phonegap stdout " + output2)
    # print("Phonegap stderr " + output3)

    # runCmd = "phonegap install --device=" + tabfullplusport + " android"
    # result = os.system(runCmd)
    # print("Install result = " + str(result))

    # Check for success
    if "LAUNCH SUCCESS" in output2:
        commandResults.append("Install OK for " + tabname)
    else:
        commandResults.append("No LAUNCH SUCCESS for " + tabname)

    # disconnect 
    os.system("adb disconnect " + tabfullplusport)

print("----------------\n\nResults\n\n------------------\n\n")
for res in commandResults:
    print(res)

#raw_input("press enter")

