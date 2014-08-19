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
    
    -- For getting disk space for Elementary
    property intGetterTitle : "Total space for Elementary"
    
    on applicationWillFinishLaunching_(aNotification)
        -- Insert code here to initialize your application before any files are opened
    end applicationWillFinishLaunching_
    
    
    
    -- extract and do standard install of refind
    
    on ButtonHandlerInstall_(sender)
        # set elementarySpace to my getIntValue()
        
        tell application "Finder" to set diskCapacity to capacity of startup disk
        tell application "Finder" to set diskFreeSpace to free space of startup disk
        
        do shell script "say " & diskCapacity as number
        
        display dialog elementarySpace
        
        display dialog "Insert your thumb drive and click \"OK\" - the thumb drive will be erased and its contents lost. Your computer will be prepared for the installation. This could take a while."
        
        -- just in case script failed earlier (even though that has never happened) erase our directory
        do shell script "rm -rf ~/eosinstall" with administrator privileges
        
        -- make our own directory so as not to mess up others
        do shell script "mkdir -p ~/eosinstall"
        
        -- download latest version of rEFInd
        do shell script "curl -L -o ~/eosinstall/refind.zip \"http://sourceforge.net/projects/refind/files/latest/download?source=files\""
        
        -- unzip said rEFInd
        do shell script "unzip ~/eosinstall/refind* -d ~/eosinstall"
        
        -- clean up zip file
        do shell script "rm ~/eosinstall/refind.zip"
        
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
        
        log "rEFInd installed"
        
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
        
        # get the name of the ISO
        
        set isoFile to (choose file with prompt "Choose an Elementary OS ISO for conversion, then wait a while:" of type {"public.iso-image"})
        
        do shell script "rm -rf ~/eosinstall &> /dev/null &"
        do shell script "mkdir -p ~/eosinstall"
        do shell script "hdiutil convert -format UDRW -o ~/eosinstall/elementary.img " & POSIX path of isoFile
        do shell script "mv ~/eosinstall/elementary.img.dmg ~/eosinstall/elementary.img"
        
        # select thumb drive, wipe it, and put installer on it
        
        set devicePath to POSIX path of "/Volumes/" & selectedDrive & ";"
        set mainDrive to do shell script "diskutil list | grep " & selectedDrive & " | grep -oh \"\\w*disk*\\w\";"
        
        do shell script "diskutil partitionDisk " & mainDrive & " 1 GPT fat32 FLASHDISK 100%"
        
        set devPath to "/dev/r" & mainDrive
        
        do shell script "diskutil unmountDisk " & devPath
        set userName to (short user name of (system info))
        do shell script "dd if=/Users/" & userName & "/eosinstall/elementary.img of=" & devPath & " bs=1m" with administrator privileges
        do shell script "rm ~/eosinstall/elementary.img"
        do shell script "rm -rf ~/eosinstall"
        
        display dialog "Congratulations! You're ready to install Elementary OS. Press OK to print instructions"
        
        
        
    end ButtonHandlerInstall_
    
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
    
    
    -- BEGIN HELPER FUNCTIONS
    
    
    -- asks for integer
    -- credit to http://macscripter.net/viewtopic.php?id=25830
    -- I am asking the user to provide an integer
    -- In case the user cancels the dialog, I return «missing value»
    on getIntValue()
        set dlgmsg to "How many GB do you want to give Elementary OS? This much space will be lost from OS X."
        try
            display dialog dlgmsg default answer "15" buttons {"Cancel", "Enter"} default button 2 with title intGetterTitle
            on error
            -- User canceled
            return missing value
        end try
        set dlgresult to result
        set usrinput to text returned of dlgresult
        -- the user did not enter anything...
        if usrinput is "" then
            my getIntValue()
            else
            -- let's check if the user entered numbers only
            set nums to {"1", "2", "3", "4", "5", "6", "7", "8", "9", "0"}
            set invalidchars to ""
            repeat with char in usrinput
                if char is not in nums then
                    set invalidchars to invalidchars & char & space
                end if
            end repeat
            -- we found invalid characters
            if invalidchars is not "" then
                set errmsg to "The following characters were in your input. Please enter numbers only." & return & return & invalidchars & return
                my dsperrmsg(errmsg, "--")
                my getIntValue()
                else
                -- let's try to transform the user input into an integer
                try
                    set intvalue to usrinput as integer
                    return intvalue
                    on error
                    set errmsg to "We could not coerce the given input into an integer:" & return & return & usrinput & return
                    my dsperrmsg(errmsg, "--")
                    my getIntValue()
                end try
            end if
        end if
    end getIntValue
    
    -- I am displaying error messages to the user
    on dsperrmsg(errmsg, errnum)
        tell me
            activate
            display dialog errmsg & " (" & errnum & ")" buttons {"OK"} default button 1 with title intGetterTitle with icon stop
        end tell
    end dsperrmsg
    
    -- converts number to string without worrying about scientific notation
    -- credit to http://www.macosxautomation.com/applescript/sbrt/sbrt-02.html
    on number_to_string(this_number)
        set this_number to this_number as string
        if this_number contains "E+" then
            set x to the offset of "." in this_number
            set y to the offset of "+" in this_number
            set z to the offset of "E" in this_number
            set the decimal_adjust to characters (y - (length of this_number)) thru ¬
            -1 of this_number as string as number
            if x is not 0 then
                set the first_part to characters 1 thru (x - 1) of this_number as string
                else
                set the first_part to ""
            end if
            set the second_part to characters (x + 1) thru (z - 1) of this_number as string
            set the converted_number to the first_part
            repeat with i from 1 to the decimal_adjust
                try
                    set the converted_number to ¬
                    the converted_number & character i of the second_part
                    on error
                    set the converted_number to the converted_number & "0"
                end try
            end repeat
            return the converted_number
            else
            return this_number
        end if
    end number_to_string
    
end script