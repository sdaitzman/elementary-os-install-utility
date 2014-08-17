:penguin: Elementary OS Install utility
=============================

Easy-to-use utility that installs Elementary OS on your Mac and helps you boot it

## Instructions:
1. [Download](https://github.com/sdaitzman/elementary-os-install-utility/releases/download/3.2.0beta/Elementary-OS-Install-utility.app.zip)
2. Open
3. Follow the instructions :smile:

## Screenshot:
![screenshot](http://f.cl.ly/items/0x370S1h0U2X2U0K1r1u/Screen%20Shot%202014-08-16%20at%2010.24.31%20PM.png)

## Building from source:
Should support OOTB building from source using Xcode >4, and is tested to work with Xcode 5.1.1 on OS X 10.9.3 and 10.9.4 and with Xcode 6 Beta 5 on OS X Yosemite.

## Technical Details:
Elementary OS Install Utility is a Cocoa-Applescript App created using Xcode. It uses mostly shell scripts to perform its tasks.

### Thumb drive burner:
1. Prompts user to choose an ISO file
2. Erases eosinstall directory then makes it again (just in case it got left behind)
3. Converts ISO to IMG in eosinstall file
4. Renames from DMG to IMG (Apple is weird sometimes)
5. Prompts for thumb drive then asks Finder about all drives
6. Lets user choose drive by name and uses ~~grep~~ magic to find /dev/rdiskn location of thumb drive
7. Uses dd to flash IMG onto thumb drive
8. Deletes IMG file and eosinstall folder
9. :smile:

### rEFInd Install:
1. Tells you what it'll do
2. Erases eosinstall directory then makes it again (just in case it got left behind)
3. `curl`s rEFInd from sourceforge into eosinstall directory
4. Unzips then deletes zip file
5. Tells you rEFInd has been downloaded and unzipped
6. Unzips rEFInd binary package
7. Unmounts both common EFI System Partition mount points (`/Volumes/ESP` and `/Volumes/EFI`) in case they're already mounted
8. Mounts EFI partition (disk0s1) to `/Volumes/EFI`
9. Renames bootx64.efi in BOOT folder as refind_x64.efi, and BOOT folder as refind - this step is in case it's already installed. It will allow installations to be upgraded.
10. Runs rEFInd install script with all drivers onto ESP partition
11. Deletes rEFInd binary installer folder
12. Renames refind folder as BOOT and refind_x64.efi as bootx64.efi. This step often reduces boot time on some EFI systems, namely most Macs, by ≈30-40 seconds.
13. Deletes entire eosinstall folder
14. Unmounts both common EFI System Partition mount points
15. Tells the user it's finished :smile:

## What it does:
This utility helps you install Elementary OS on a Mac. It installs rEFInd (an EFI boot picker) to the EFI System Partition, and burns a thumb drive with the Elementary OS installer.

You'll need an Elementary OS ISO from the Elementary OS [website](http://elementaryos.org) to install, and you'll need to make a FAT partition using Disk Utility. This will be documented in the greyed out button at the bottom of the app but instructions have not yet been written.

## Boring stuff:
This tool is licensed under the file contained in LICENSE.md. The following non-legalese does not represent a contract and LICENSE.md takes priority:

I will not prosecute, sue, or send grumpy emails to anyone using any part of this project for a fully open-source project.
I ask that you mention me in credits, or your README, or somewhere like that if you do use this.
If you make money with this, it's cool as long as you've made some changes. You absolutely may not sell this on its own.
By using this project you surrender your immortal souls, now and forevermore, to Me and Me alone. They shall be claimable within one week of notification by Me or any divine or mortal representative of Me.
