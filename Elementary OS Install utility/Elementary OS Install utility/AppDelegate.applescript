--
--  AppDelegate.applescript
--  Elementary OS Install utility
--
--  Created by Sam Daitzman on 3/29/14.
--  Copyright (c) 2014 Sam Daitzman. All rights reserved. License available at project page.
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
	
	-- all of the below
	on ButtonHandlerInstallAll_(sender)
		display dialog "This Utility will set up your computer to boot both Elementary OS and OS X. Click OK to begin!"
		do shell script "" with administrator privileges
		
		partitionMac()
		installRefind()
		mkFrugalInstaller()
		display dialog "It's now safe to reboot your computer and install Elementary OS - click OK to open the instructions. You should print them if you aren't familiar with the process!"
		openInstructions()
	end ButtonHandlerInstallAll_
	
	-- partitions the Mac with space for Elementary OS
	on ButtonHandlerPartition_(sender)
		partitionMac()
		display dialog "Your Mac has been successfully partitioned for Elementary OS and the Elementary OS installer"
	end ButtonHandlerPartition_
	
	-- Install or update rEFInd
	on buttonHandlerInstallRefind_(sender)
		display dialog "Click OK to install the boot picker or upgrade it if it's already installed"
		installRefind()
		display dialog "The boot picker has been installed and is up-to-date!"
	end buttonHandlerInstallRefind_
	
	-- DEPRECATED: creates a thumb drive to install
	on ButtonHandlerMkThumbDrive_(sender)
		display dialog "Insert your thumb drive and click \"OK\" - the thumb drive will be erased and its contents lost."
		delay 5
		-- make the thumb drive installer
		mkThumbDriveInstaller()
		display dialog "Finished! It is now safe to remove the thumb drive."
	end ButtonHandlerMkThumbDrive_
	
	-- put installer on installer partition created in other step
	on ButtonHandlerMkInstall_(sender)
		display dialog "Choose the downloaded ISO file to create the installer"
		mkFrugalInstaller()
		display dialog "Installer created!"
	end ButtonHandlerMkInstall_
	
	-- remove installer from installer partition
	on ButtonHandlerRmInstall_(sender)
		do shell script "diskutil reformat /Volumes/EOSINSTALL/" with administrator privileges
		display dialog "Installer volume reformatted"
	end ButtonHandlerRmInstall_
	
	
	-- open Elementary OS support page
	on ButtonHandlerSupport_(sender)
		do shell script "open http://elementaryos.org/support"
	end ButtonHandlerSupport_
	
	-- open instructions and app guide
	on ButtonHandlerOpenInstructions_(sender)
		openInstructions()
	end ButtonHandleropenInstructions_
	
	-- quit install utility
	on ButtonHandlerQuit_(sender)
		quit
	end ButtonHandlerQuit_
	on applicationShouldTerminate_(sender)
		-- Insert code here to do any housekeeping before your application quits
		do shell script "rm -rf ~/eosinstall"
		return current application's NSTerminateNow
	end applicationShouldTerminate_
	
	
	
	
	
	-- BEGIN HELPER FUNCTIONS
	
	-- make space for Elementary by partitioning
	on partitionMac()
		set elementarySpace to my getIntValue() * 1073741824
		
		tell application "Finder" to set diskCapacity to capacity of startup disk
		
		-- current disk space - elementary space - a little over 2gb
		set newMacSpace to number_to_string(diskCapacity - elementarySpace - 2147484648)
		
		do shell script "diskutil resizeVolume / " & newMacSpace  & "B 2 MS-DOS ELEMENTARY " & elementarySpace & "B MS-DOS EOSINSTALL 2G" with administrator privileges
		
		log "Mac has been partitioned"
	end partitionMac
	
	-- install bootpicker (rEFInd)
	on installRefind()
		
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
		log "downloaded and unzipped refind"
		
		-- unmount ESP
		do shell script "diskutil unmount /Volumes/EFI &> /dev/null &"
		do shell script "diskutil unmount /Volumes/ESP &> /dev/null &"
		log "unmounted ESP locations"
		
		-- installs rEFInd on ESP with all drivers
		delay 3
		do shell script "~/eosinstall/refind-bin*/install.sh --alldrivers --usedefault /dev/disk0s1" with administrator privileges
		log "ran install script"
		
		-- removes refind install folder
		do shell script "rm -rf ~/eosinstall/refind-bin*"
		
		-- deletes entire install folder
		do shell script "rm -rf ~/eosinstall"
		log "got rid of scratch directory"
		
		-- mount partition and erase 32-bit versions
		do shell script "mkdir -p /Volumes/ESP"
		do shell script "mount -t msdos /dev/disk0s1 /Volumes/ESP &> /dev/null &" with administrator privileges
		do shell script "rm /Volumes/ESP/EFI/BOOT/bootia32.efi" with administrator privileges
		do shell script "rm -rf /Volumes/ESP/EFI/BOOT/drivers_ia32/" with administrator privileges
		log "erased 32-bit rEFInd"
		
		-- bless rEFInd and unmount
		do shell script "bless --mount /Volumes/ESP --setBoot --file /Volumes/ESP/EFI/BOOT/bootx64.efi" with administrator privileges
		do shell script "diskutil unmount force /Volumes/ESP &> /dev/null &"
		
		log "unmounted ESP - rEFInd installed and blessed"
	end installRefind
	
	-- DEPRECATED: make thumb drive
	on mkThumbDriveInstaller()
		tell application "Finder"
			try
				set allDrives to the name of every disk
				on error
				display dialog "There are no other drives to install on."
				return
			end try
		end tell
		
		set selectedDrive to "driveForInstallerGoesHere"
		set selectedDrive to {choose from list allDrives with prompt "Choose your thumb drive from the list:"} as text
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
	end mkThumbDriveInstaller
	
	-- make frugal install
	on mkFrugalInstaller()
		set isoFile to (choose file with prompt "Choose an Elementary OS ISO:" of type {"public.iso-image"})
		do shell script "diskutil reformat /Volumes/EOSINSTALL/" with administrator privileges
		do shell script "hdiutil mount " & POSIX path of isoFile
		do shell script "cp -R /Volumes/elementary\\ OS/ /Volumes/EOSINSTALL/"
		do shell script "diskutil unmount force /Volumes/elementary\\ OS"
	end mkFrugalInstaller
		
	-- open complete instructions
	on openInstructions()
		tell application "Safari"
			activate
			open location "https://gitprint.com/sdaitzman/elementary-os-install-utility/blob/master/INSTRUCTIONS.md"
		end tell
	end openInstructions
		
		
		
		
	-- asks for integer - credit to http://macscripter.net/viewtopic.php?id=25830
	on getIntValue()
			set dlgmsg to "How many GB do you want to give Elementary OS? Slightly more than this much space will be lost from OS X."
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
		
	-- converts number to string without worrying about scientific notation - credit to http://www.macosxautomation.com/applescript/sbrt/sbrt-02.html
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