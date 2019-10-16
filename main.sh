#!/bin/bash
rm -rf ipwndfu_public

git clone https://github.com/MatthewPierson/ipwndfu_public.git

clear

echo "Do you want to input a generator? (y,n)"

read input

if [ $input = y ];
then
    echo "Please enter your desiered generator."

    read generator

    echo "Your generator is $generator"
elif [ $input = n ];
then

    echo "Please drag and drop the SHSH file that you want to downgrade with into this terminal window then press enter"

    read shsh

    echo "Is $shsh the correct location and file name of your SHSH? (y/n)"

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

        if [ -z "$generator" ]
        then
            echo "[ERROR] SHSH does not contain a generator!"
            echo "[ERROR] Please use a different SHSH with a generator!"
            echo "[ERROR] SHSH saved with shsh.host (will show generator) or tsssaver.1conan.com (in noapnonce folder) are acceptable"
            echo "Exiting..."
            exit
        else
            echo "Your generator is: $generator"
        fi

else
    echo "Input not recognized, Exiting..."
    exit
fi

echo "$generator"

echo "Enter device model please"

read device

if [ $device == "iPhone6,1" ] || [ $device == "iPhone6,2" ] || [ $device == "iPhone9,1" ] || [ $device == "iPhone9,2" ] || [ $device == "iPhone9,3" ] || [ $device == "iPhone9,4" ] || [ $device == "iPad4,1" ] || [ $device == "iPad4,2" ] || [ $device == "iPad4,3" ] || [ $device == "iPad4,4" ] || [ $device == "iPad4,5" ] || [ $device == "iPad4,6" ] || [ $device == "iPad7,6" ] || [ $device == "iPad7,5" ] || [ $device == "iPad4,7" ] || [ $device == "iPad4,8" ] || [ $device == "iPad4,9" ] || [ $device == "iPod9,1" ];
then
    echo "Your $device is supported"

else
    echo "Your $device is not supported, sorry."
    echo "Exiting..."
    exit
fi

echo "Please connect device in DFU mode. Press enter when ready to continue"

read randomIrrelevant

echo "Starting ipwndfu"
cd ipwndfu_public
string=$(../files/lsusb | grep -c "checkm8")
until [ $string = 1 ];
do
    killall iTunes && killall iTunesHelper
    echo "Waiting 10 seconds to allow you to enter DFU mode"
    sleep 10
    echo "Attempting to get into pwndfu mode"
    echo "Please just enter DFU mode again on each reboot"
    echo "The script will run ipwndfu again and again until the device is in PWNDFU mode"
    ./ipwndfu -p
    string=$(../files/lsusb | grep -c "checkm8")
done

sleep 3

python rmsigchks.py
cd ..
echo "Device is now in PWNDFU mode with signature checks removed (Thanks to Linus Henze)"

echo "Entering PWNREC mode"
cd files

./irecovery -f ibss."$device".img4

if [ $device = iPhone6,1 ] || [ $device = iPhone6,2 ] || [ $device = iPad4,1 ] || [ $device = iPad4,2 ] || [ $device = iPad4,3 ] || [ $device = iPad4,4 ] || [ $device = iPad4,5 ] || [ $device = iPad4,6 ] || [ $device = iPad4,7 ] || [ $device = iPad4,8 ] || [ $device = iPad4,9 ];
then
    ./irecovery -f ibec."$device".img4
fi

echo "Entered PWNREC mode"
sleep 4
echo "Current nonce"
./irecovery -q | grep NONC
echo "Setting nonce!"
./irecovery -c "setenv com.apple.System.boot-nonce $generator"
./irecovery -c "saveenv"
./irecovery -c "setenv auto-boot false"
./irecovery -c "saveenv"
./irecovery -c "reset"
echo "Waiting for device to restart into recovery mode"
sleep 7
echo "New nonce"
./irecovery -q | grep NONC

echo "We are done!"
echo ""
echo "You can now futurerestore to the firmware that this SHSH is vaild for"
echo "Assuming that signed SEP and Baseband are compatible"
