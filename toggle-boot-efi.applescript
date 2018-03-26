-- Toggle Boot EFI
-- Written by David Spiegelman
-- Inspired by EFI Mounter v3 by MacMan
--
-- This script will mount/unmount your EFI partition on your boot disk only
-- The will work with the new APFS format introduced in High Sierra as
-- well as HFS Plus formatted disks
-- It requires no interaction from the user whatsoever (password, disk selection, etc.)
-- You must already be an Admin to run this script
-- Tested with High Sierra (10.13.x) should work with 10.10.x and higher
-- Use at your own risk
-- Feel free to improve it but please credit me

on run
	if " admin " is in (do shell script "groups") then
		set bootdisk to do shell script "diskutil info / | grep 'Device Identifier:' | awk '{print $NF}'"
		
		# check if boot disk is a APFS volume
		set is_APFS to (do shell script "(diskutil list | grep " & bootdisk & " | grep APFS > /dev/null) ; echo $?") is "0"
		if is_APFS then set bootdisk to do shell script "diskutil list | grep " & quoted form of ("Container " & get_disknum(bootdisk)) & " | awk '{print $NF}'"
		
		# check if the boot disk's EFI partion is already mounted
		set efiDev to "/dev/" & get_disknum(bootdisk) & "s1"
		set mounted to do shell script "diskutil info " & efiDev & " | grep Mounted: | awk '{print $NF}'"
		
		try
			if mounted is "Yes" then
				set scriptResult to do shell script "diskutil unmount " & efiDev
			else
				set scriptResult to do shell script "diskutil mount " & efiDev
				try
					tell application "Finder" to make new Finder window to (get "/Volumes/EFI/EFI/Clover") as POSIX file
				end try
			end if
		on error
			set scriptResult to ""
		end try
	else
		set scriptResult to "Admin privileges required."
		display dialog scriptResult buttons {"OK"}
	end if
	
	return scriptResult
end run

on get_disknum(identifier)
	# turns diskXsY into diskX regardless of the number of digits of X and Y
	# for example disk11s15 (although very unlikely) will return disk11
	set org_tid to AppleScript's text item delimiters
	set AppleScript's text item delimiters to {"s"}
	set identifier to text 5 thru -1 of identifier
	set disknum to text item 1 of identifier
	set AppleScript's text item delimiters to org_tid
	return "disk" & disknum
end get_disknum
