import os
import sys

# Note that on windows this script is best run from cmd prompt rather than in IDLE
tablet_ips = { "kitchen": 153, "sitting Room": 203, "gamesroom": 218, "hall":184, "master bedroom":21,
               "landing": 45, "grace's room": 186, "guest room": 215, "office": 150, "joe's bedroom": 183 }
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
for room, ip in tablet_ips.iteritems():
    print "Running command on " + room + " tablet (192.168.0." + str(ip) + ")"

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

    # Run command
#    runCmd = "adb shell am force-stop "
#    runCmd = "phonegap install android"
    result = os.system(cmdStr)
    print (cmdStr + " Result = " + str(result))
    
    os.system("adb disconnect 192.168.0." + str(ip) + ":5555")

#raw_input("press enter")

