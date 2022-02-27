# checkm8-nonce-setter
A nonce setter for devices compatible with checkm8

-----------------------------------------

iOS version doesn't matter. If your device is compatible with checkm8 + Linus Henze's Signature Check Remover then you can set your nonce and downgrade. This script is macOS only.

-----------------------------------------

Instructions - 

Run `xattr -dr com.apple.quarantine [a9-checkm8-nonce-setter-folder]/files` to resolve unsigned binary errors.   
`"./main.sh"`

Thats it. The script will tell you what to do.

-----------------------------------------

After setting nonce with this, you can futurerestore with the shsh you used during the script. 

-----------------------------------------

Keep in mind SEP and Baseband both need to be compatible with the version you are trying to downgrade to. This script doesn't change that, only allows you to set your nonce without being jailbroken.

-----------------------------------------

Please don't ask me stupid questions, I'll just ignore you. Please don't use issues to ask stupid questions, just for actual issues thanks.

-----------------------------------------


Support includes : 
<br/>
<br/>
iPhone SE (2016)

iPhone 6s 

iPhone 6s Plus


-----------------------------------------

# Credits 

[libimobiledevice](https://github.com/libimobiledevice) for [irecovery](https://github.com/libimobiledevice/libirecovery)

[0x7ff](https://github.com/0x7ff) for [eclipsa](https://github.com/0x7ff/eclipsa)
