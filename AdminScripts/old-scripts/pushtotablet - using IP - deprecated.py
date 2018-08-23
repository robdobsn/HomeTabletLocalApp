import os
import sys

# Note that on windows this script is best run from cmd prompt rather than in IDLE
# Navigate to the source code folder for the phonegap app - the folder should have www folder in it
# Default password for android tablets root account is admin
all_tablet_ips = { "kitchen": 153, "dining room": 158, "sitting Room": 203, "gamesroom": 218, "hall":184, "master bedroom":21,
               "landing": 45, "grace's room": 186, "guest room": 215, "office": 150, "joe's bedroom": 183 }
adbRemoteCmds = [ "setprop service.adb.tcp.port 5555", "stop adbd", "start adbd" ]

# Check if we want all tablets or just one
if len(sys.argv) > 1:
    if sys.argv[1] in all_tablet_ips.keys():
        tablet_ips = {}
        tablet_ips[sys.argv[1]] = all_tablet_ips[sys.argv[1]]
    else:
        print "Cannot find " + sys.argv[1] + " in list of tablets"
        exit(0)
else:
    tablet_ips = all_tablet_ips

# Get admin pw for tablets
tablet_pw = raw_input("Enter password for tablets: ")

# First build the phonegap app
buildCmd = "phonegap build android"
result = os.system(buildCmd)
print "Build result = " + str(result)

# Now install on each tablet
for room, ip in tablet_ips.iteritems():
    print "Attempting installation on " + room + " tablet (192.168.0." + str(ip) + ")"

    # Using plink which is like putty but takes a command to run remotely as parameter
    plinkCmd = 'plink.exe root@192.168.0.' + str(ip) + ' -pw ' + tablet_pw + " "

    # Set up adbd on the remote system
    for cmd in adbRemoteCmds:
        result = os.system(plinkCmd + cmd)

    # Connect adb on local system to remote
    result = os.system("adb connect 192.168.0." + str(ip) + ":5555")
    print "Result = " + str(result)
    checkCmd = "adb devices"
    result = os.system(checkCmd)

    # Install the app
    runCmd = "phonegap install android"
    result = os.system(runCmd)
    print "Install result = " + str(result)
    result = os.system("adb disconnect 192.168.0." + str(ip) + ":5555")

#raw_input("press enter")

