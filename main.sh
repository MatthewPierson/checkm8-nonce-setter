#!/bin/bash

clear

echo "Please drag and drop the SHSH file that you want to downgrade with into this terminal window then press enter"

read shsh

echo "Is $shsh the correct location and file name of your SHSH?"

read pass

if [ $pass == yes ] || [ $pass == Yes ] || [ $pass == y ] || [ $pass == Y ];
then
echo "Continuing with given SHSH"

elif [ $pass == no ] || [ $pass == No ] || [ $pass == n ] || [ $pass == n ];
then
echo "Please restart script and give the correct location and file name"
echo "Exiting..."
exit

else
echo "Unrecognised input"
echo "Exiting..."
exit

fi

if [ ${shsh: -6} == ".shsh2" ] || [ ${shsh: -5} == ".shsh" ];
then
echo "File verified as SHSH2 file, continuing"

else
echo "Please ensure that the file extension is either .shsh or .shsh2 and retry"
echo "Exiting..."
exit
fi

echo "Getting generator from SHSH"

getGenerator() {
echo $1 | grep "<string>0x" $shsh  | cut -c10-27
}
generator=$(getGenerator $shsh)

echo "Your generator is: $generator"

echo "Enter device model please"

read device

if [ $device == "iPhone6,1" ] || [ $device == "iPhone6,2" ];
then
echo "Your $device is supported"

else
echo "No support sorry"
fi

echo "Please connect device in DFU mode. Press enter when ready to continue"

read randomIrrelevant

echo "Starting ipwndfu"
cd ipwndfu_public
string=$(./lsusb | grep -c "checkm8")
until [ $string = 1 ];
do
    echo "Waiting 10 seconds to allow you to re-enter DFU mode"
    sleep 10
    echo "Attempting to get into pwndfu mode"
    echo "Please just enter DFU mode again on each reboot"
    echo "The script will run ipwndfu again and again until the device is in PWNDFU mode"
    ./ipwndfu -p
    string=$(./lsusb | grep -c "checkm8")
done
python rmsigchks.py
cd ..
echo "Device is now in PWNDFU mode with signature checks removed (Thanks to Linus Henze)"

echo "Entering PWNREC mode"
cd files
../ipwndfu_public/irecovery -f ibss.$device.img4
../ipwndfu_public/irecovery -f ibec.$device.img4
echo "Entered PWNREC mode"

echo "Setting nonce!"

echo "Current nonce"
../ipwndfu_public/irecovery -q | grep NONC
../ipwndfu_public/irecovery -c "sentenv com.apple.System.boot-nonce $generator"
../ipwndfu_public/irecovery -c "saveenv"
../ipwndfu_public/irecovery -c "setenv auto-boot false"
../ipwndfu_public/irecovery -c "saveenv"
../ipwndfu_public/irecovery -c "reset"
echo "New nonce"
../ipwndfu_public/irecovery -q | grep NONC

echo "We are done!"
echo ""
echo "You can now futurerestore to the firmware that this SHSH is vaild for"
