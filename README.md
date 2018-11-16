# TdmPlug

### Enable Target Display Mode on iMac automatically without Physical Keyboard

## About the Project

In order to enable Target Display Mode automatically on an iMac, you are required to press a keyboard combination.
To solve this issue, there have been several projects which aim to automate this process. And even though you don't have to press any shortcut with these tools, a physical keyboard still has to be connected to the iMac – otherwise, the tools won't work. This is because of macOS requiring a keyboard to initialize the Target Display Mode.

TdmPlug solves this issue by installing a virtual keyboard which then simulates the shortcut to initialize Target Display Mode. This is done by a custom kernel extension (kext).

TdmPlug is a Daemon that runs automatically on boot of your iMac and it's already ready at the login window. So you aren't even required to login into your iMac. Target Display Mode will be enabled as soon as you connect another Mac via Thunderbolt.
It's even possible to connect a device already before booting the iMac. Connection will then be established as soon as the iMac has finished booting into the login screen.

Please note that it might take some seconds for a connected device to be detected and Target Display Mode being enabled.

*TdmPlug is based on the two Open Source projects ([VirtualKVM](https://github.com/duanefields/VirtualKVM) and [foohid](https://github.com/unbit/foohid) which have been slightly modified and put into a single installer. Thanks to the authors of these two amazing projects which have made possible TdmPlug.*


## Installation Instructions

### Installer

* [Download the installer](https://github.com/uvoglu/TdmPlug/releases/download/1.0/TdmPlug.dmg) from the releases section.


* Disable System Integrity Protection (SIP). This is required as you install a custom Kernel Extension (kext) which is not signed. To disable SIP, reboot your iMac and press `CMD+R` while booting. macOS will boot into recovery mode.
* In the menu bar, select «Utilities» and then «Terminal».
* In the Terminal, type the following: `csrutil disable`
* Reboot by typing `reboot` into the terminal.


* Right click on the TdmPlugInstall.pkg. Select «Open» and confirm the message. If you just double click you might not be able to open the installer because of Gatekeeper preventing it.
* The Daemon should now be running and Target Display Mode should be enabled automatically.


* Last, you should enable SIP again. Once the kext is installed, SIP can be enabled again and the unsigned kext should continue to work. Reboot your iMac again and again press `CMD+R` while booting.
* In the menu bar, select «Utilities» and then «Terminal».
* In the Terminal, type the following: `csrutil enable`
* Reboot by typing `reboot` into the terminal.


* In case you want to uninstall TdmPlug completely from your system, there is an uninstaller package as well.


### Manual installation

* Compile the two Xcode projects.
* Disable SIP (see steps above in the installer section on how to disable SIP).


* Copy the `tdmplug` binary to `/usr/local/bin/`


* Copy `tdmfoohid.kext` to `/Library/Exensions/`
* Change permissions on the kext by executing the following command in terminal: `sudo chown -R root:wheel /Library/Exensions/tdmfoohid.kext`
* Load the custom kext by executing `sudo kextload -b com.uvoglu.tdmfoohid`

* Copy `com.uvoglu.tdmplug.plist` to `/Library/LaunchDaemons/`
* Change permissions on `com.uvoglu.tdmplug.plist` by executing the following command in terminal: `sudo chown root:wheel /Library/LaunchDaemons/com.uvoglu.tdmplug.plist`
* Enable the LaunchDaemon with `sudo launchctl load -w /Library/LaunchDaemons/com.uvoglu.tdmplug.plist`


* The project should now be installed. SIP can then be enabled again. (See steps in the installer section on how to do so).
* To uninstall, run the following commands:  
```
sudo launchctl unload -w /Library/LaunchDaemons/com.uvoglu.tdmplug.plist
sudo rm /usr/local/bin/tdmplug
sudo kextunload -b com.uvoglu.tdmfoohid
sudo rm -r /Library/Extensions/tdmfoohid.kext
```
