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

if " admin " is in (do shell script "groups") then
	set mountName to "EFI"
	set cloverPath to "/EFI/Clover"
	
	set bootdisk to do shell script "diskutil info / | awk '/Identifier/ {print $3}'"
	
	#check if boot disk is a APFS volume
	set is_APFS to do shell script "(diskutil list | grep " & bootdisk & " | grep APFS > /dev/null) ; echo $?"
	set is_APFS to (is_APFS is "0")
	
	if is_APFS then
		set phy_disk to do shell script "diskutil list | grep " & quoted form of ("Container " & get_disknum(bootdisk))
		set bootdisk to last word of phy_disk
	end if
	
	set efiDev to "/dev/" & get_disknum(bootdisk) & "s1"
	set mountPoint to "/Volumes/" & mountName & cloverPath
	
	# check if the boot disk's EFI partion is already mounted
	set is_mounted to do shell script "diskutil info " & efiDev & " | grep Mounted: | awk '{print $2}'"
	set is_mounted to (is_mounted is "Yes")
	
	try
		if is_mounted then
			do shell script "diskutil unmount " & efiDev
		else
			do shell script "diskutil mount " & efiDev
			tell application "Finder" to make new Finder window to (get mountPoint) as POSIX file
		end if
	on error
		return
	end try
else
	display dialog "Sorry, this script requires Admin privileges." buttons {"OK"}
	return
end if

on get_disknum(identifier)
	#turns diskXsY into diskX regardless of the number of digits of X and Y
	#for example disk11s15 (although very unlikely) will return disk11
	set org_tid to AppleScript's text item delimiters
	set AppleScript's text item delimiters to {"s"}
	set identifier to text 5 thru -1 of identifier
	set disknum to text item 1 of identifier
	set AppleScript's text item delimiters to org_tid
	return "disk" & disknum
end get_disknum
