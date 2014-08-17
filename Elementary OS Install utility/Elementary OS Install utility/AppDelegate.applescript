--
--  AppDelegate.applescript
--  Elementary OS Install utility
--
--  Created by Sam Daitzman on 3/29/14.
--  Copyright (c) 2014 Sam Daitzman. All rights reserved.
--

script AppDelegate
    property parent : class "NSObject"
    
    -- IBOutlets
    property window : missing value
    
    on applicationWillFinishLaunching_(aNotification)
        -- Insert code here to initialize your application before any files are opened
    end applicationWillFinishLaunching_
    
    
    
    -- extract and do standard install of refind
    
    on ButtonHandlerInstallRefind_(sender)
        
        display dialog "Elementary OS Install Assistant will help you download and install rEFInd."
        
        -- just in case script failed earlier (even though that has never happened) erase our directory
        do shell script "rm -rf ~/eosinstall"
        
        -- make our own directory so as not to mess up others
        do shell script "mkdir -p ~/eosinstall"
        
        -- download latest version of rEFInd
        do shell script "curl -L -o ~/eosinstall/refind.zip \"http://sourceforge.net/projects/refind/files/latest/download?source=files\""
        
        -- unzip said rEFInd
        do shell script "unzip ~/eosinstall/refind* -d ~/eosinstall"
        
        -- clean up zip file
        do shell script "rm ~/eosinstall/refind.zip"
        
        display dialog "rEFInd has been downloaded and unzipped. Would you like to install it? If you already have rEFInd installed, it will automatically be upgraded and your old settings, icons, and directories preserved."
        
        -- unmount ESP then mount to a known location
        do shell script "diskutil unmount /Volumes/EFI &> /dev/null &"
        do shell script "diskutil unmount /Volumes/ESP &> /dev/null &"
        delay 3
        do shell script "mkdir -p /Volumes/EFI"
        do shell script "mount -t msdos /dev/disk0s1 /Volumes/EFI/" with administrator privileges
        
        -- if already installed, allows to be updated rather than messed up
        do shell script "mv  /Volumes/EFI/EFI/BOOT/bootx64.efi /Volumes/EFI/EFI/BOOT/refind_x64.efi &> /dev/null &"
        do shell script "mv /Volumes/EFI/EFI/BOOT /Volumes/EFI/EFI/refind &> /dev/null &"
        
        -- installs rEFInd on ESP with all drivers
        do shell script "~/eosinstall/refind-bin*/install.sh --esp --alldrivers" with administrator privileges
        
        -- removes refind install folder
        do shell script "rm -rf ~/eosinstall/refind-bin*"
        
        -- moves to faster-booting location
        do shell script "mv /Volumes/EFI/EFI/refind /Volumes/EFI/EFI/BOOT"
        do shell script "mv /Volumes/EFI/EFI/BOOT/refind_x64.efi /Volumes/EFI/EFI/BOOT/bootx64.efi"
        
        -- deletes entire install folder
        do shell script "rm -rf ~/eosinstall"
        
        -- unmount partition again
        do shell script "diskutil unmount /Volumes/EFI &> /dev/null &"
        do shell script "diskutil unmount /Volumes/ESP &> /dev/null &"
        
        display dialog "Congratulations, rEFInd has been installed! It should show up next time you reboot."
        
    end ButtonHandlerInstallRefind_
    
    on ButtonHandlerMakeThumbDrive_(sender)
        # get the name of the ISO
        
        display dialog "Elementary OS Install Utility will help you create a bootable thumb drive to install Elementary OS and, if you choose, also install rEFInd. An Elementary installer thumb drive can be easily restored to a standard thumb drive later."
        set isoFile to (choose file with prompt "Choose an Elementary OS ISO for conversion, then wait a while:" of type {"public.iso-image"})
        
        do shell script "rm -rf ~/eosinstall &> /dev/null &"
        do shell script "mkdir -p ~/eosinstall"
        do shell script "hdiutil convert -format UDRW -o ~/eosinstall/elementary.img " & POSIX path of isoFile
        do shell script "mv ~/eosinstall/elementary.img.dmg ~/eosinstall/elementary.img"
        
        # select thumb drive, wipe it, and put installer on it
        
        display dialog "The file has been successfully converted! Please insert your thumb drive, wait for it to be recognized and click \"OK\""
        
        tell application "Finder"
            try
                set allDrives to the name of every disk
                on error
                display dialog "There are no other drives to install on."
                return
            end try
        end tell
        
        set selectedDrive to "driveForInstallerGoesHere"
        set selectedDrive to {choose from list allDrives with prompt "Choose the drive for the Elementary installer:"} as text
        set selectedDrive to "\"" & selectedDrive & "\""
        
        set devicePath to POSIX path of "/Volumes/" & selectedDrive & ";"
        set mainDrive to do shell script "diskutil list | grep " & selectedDrive & " | grep -oh \"\\w*disk*\\w\";"
        
        
        display dialog "The drive " & selectedDrive & " will be completely wiped as well as any other partitions on that drive." & return & "Do you want to continue?"
        do shell script "diskutil partitionDisk " & mainDrive & " 1 GPT fat32 FLASHDISK 100%"
        
        display dialog "Your thumb drive has been partitioned - next the Elementary installer will be flashed to it. This could take a while."
        
        set devPath to "/dev/r" & mainDrive
        
        do shell script "diskutil unmountDisk " & devPath
        set userName to (short user name of (system info))
        do shell script "dd if=/Users/" & userName & "/eosinstall/elementary.img of=" & devPath & " bs=1m" with administrator privileges
        do shell script "rm ~/eosinstall/elementary.img"
        do shell script "rm -rf ~/eosinstall"
        
        display dialog "Congratulations! The thumb drive is now an Elementary OS installer. Have fun! It's now safe to remove the drive."
    end ButtonHandlerMakeThumbDrive_
    
    on ButtonHandlerDocs_(sender)
        do shell script "open http://www.rodsbooks.com/refind/"
    end ButtonHandlerDocs_
    
    on ButtonHandlerSupport_(sender)
        do shell script "open http://elementaryos.org/support"
    end ButtonHandlerSupport_
    
    
    
    -- quit install utility
    
    on ButtonHandlerQuit_(sender)
        quit
    end ButtonHandlerQuit_
    
    
    
    on applicationShouldTerminate_(sender)
        -- Insert code here to do any housekeeping before your application quits
        return current application's NSTerminateNow
    end applicationShouldTerminate_
    
end script