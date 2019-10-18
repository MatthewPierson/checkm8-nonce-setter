#!/bin/bash
cd ipwndfu_public; if [ $? = 0 ];
then
    git pull
    cd ..
else
    rm -rf ipwndfu_public
    git clone https://github.com/MatthewPierson/ipwndfu_public.git
fi

exit_flag=0

# Generator setup
while [ $exit_flag -ne 1 ]
do
    echo "Do you want to input a generator? (y,n)"

    read input

    if [ $input = y ];
    then
        echo "Please enter your desired generator."

        read generator

        echo "Your generator is $generator"
        echo ""
        break
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
            break

        else
            echo "Unrecognised input"
            break

        fi

        if [ ${shsh: -6} == ".shsh2" ] || [ ${shsh: -5} == ".shsh" ];
        then
            echo "File verified as SHSH2 file, continuing"

        else
            echo "Please ensure that the file extension is either .shsh or .shsh2 and retry"
            break
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
            break
        else
            echo "Your generator is: $generator"
        fi
    elif [ $input = 'exit' ]
    then
        exit_flag=1
    fi
done

echo "Set device into DFU mode, then press enter..."
read
echo "Connecting to device"

# Model retrieving
cd files
./irecovery -v > output.txt 2>&1
output=`cat output.txt | tail -1`

case $output in
*"ERROR"*)
    echo "Unable to connect to device"
    exit
    ;;
*"iPhone6,1"*)
    model="iPhone6,1"
    ;;
*"iPhone6,2"*)
    model="iPhone6,2"
    ;;
*"iPhone9,1"*)
    model="iPhone9,1"
    ;;
*"iPhone9,2"*)
    model="iPhone9,2"
    ;;
*"iPhone9,3"*)
    model="iPhone9,3"
    ;;
*"iPhone9,4"*)
    model="iPhone9,4"
    ;;
*"iPad4,1"*)
    model="iPad4,1"
    ;;
*"iPad4,2"*)
    model="iPad4,2"
    ;;
*"iPad4,3"*)
    model="iPad4,3"
    ;;
*"iPad4,4"*)
    model="iPad4,4"
    ;;
*"iPad4,5"*)
    model="iPad4,5"
    ;;
*"iPad4,6"*)
    model="iPad4,6"
    ;;
*"iPad4,7"*)
    model="iPad4,7"
    ;;
*"iPad4,8"*)
    model="iPad4,8"
    ;;
*"iPad4,9"*)
    model="iPad4,9"
    ;;
*"iPad7,5"*)
    model="iPad7,5"
    ;;
*"iPad7,6"*)
    model="iPad7,6"
    ;;
*"iPad7,11"*)
    model="iPad7,11"
    ;;
*"iPod9,1"*)
    model="iPod9,1"
    ;;
*)
    echo "Your device is currently not supported, or not supported at all by checkm8."
    echo "Exiting..."
    exit
    ;;
esac

echo "Your $model is supported"

# ipwndfu start
echo "Starting ipwndfu"
cd ../ipwndfu_public
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

# Bypassing signature checks
python rmsigchks.py
cd ..
echo "Device is now in PWNDFU mode with signature checks removed (Thanks to Linus Henze)"

echo "Entering PWNREC mode"
cd files

# Sending image to device
./irecovery -f ibss."$model".img4

if [ $model = iPhone6,1 ] || [ $model = iPhone6,2 ] || [ $model = iPad4,1 ] || [ $model = iPad4,2 ] || [ $model = iPad4,3 ] || [ $model = iPad4,4 ] || [ $model = iPad4,5 ] || [ $model = iPad4,6 ] || [ $model = iPad4,7 ] || [ $model = iPad4,8 ] || [ $model = iPad4,9 ];
then
    ./irecovery -f ibec."$model".img4
fi

# Setting nonce
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
echo "You can now futurerestore to the firmware that this SHSH is valid for"
echo "Assuming that signed SEP and Baseband are compatible"
