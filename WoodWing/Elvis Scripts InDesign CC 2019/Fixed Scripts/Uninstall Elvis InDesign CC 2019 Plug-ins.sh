#!/bin/bash

##Double pound signs are edits from Patrick Fergus
#---------------------------------------------------------------------
# Declare the path finding variables.

# Get the absolute path to this very script with script name and extension.
# To get the path only, detract the directory name.
##Don't need to find the application folder to uninstall from, let's hard-code this
##path_only=`dirname "${0}"`
##path_only=`dirname "${path_only}"`
##path_only=`dirname "${path_only}"`
##path_only=`dirname "${path_only}"`
path_only="/Applications/Adobe InDesign CC 2019"

# Boolean to show message on success.
B_MSG=true

# Ask the user for the administrator username and password.
# IF the user cancels then nothing will be done.
##Don't need this any more, there is no choice.  Let's hard-code this
##UNINSTALL_ELVISINDESIGN_APP=$(osascript \
##								-e	'set the_results to ""' \
##								-e	'try' \
##								-e		'tell application "Finder"' \
##								-e		'activate' \
##								-e		'set the_results to ((display dialog "You are about to remove all Elvis InDesign files, including the ElvisInDesign.app.\nWhen you have multiple installations of Elvis InDesign on your system, you might want to leave this file on your system.\n\nDo you want to remove the ElvisInDesign.app?" with title "Uninstall Elvis InDesign" buttons {"Yes", "No"} default button 2))' \
##								-e		'end tell' \
##								-e	'end try' \
##								-e 'return {the_results}')

##Set ElvisInDesign to be uninstalled
UNINSTALL_ELVISINDESIGN_APP=":Yes"

echo "USER ACTION: ${UNINSTALL_ELVISINDESIGN_APP}"
echo ""

if [[ "${UNINSTALL_ELVISINDESIGN_APP}" == *":Yes"* ]]; then
##	# Ask the user for the administrator username and password.
##	# IF the user cancels then nothing will be done.
##	# The script will set some access rights and
##	# the script will remove the ElvisInDesign.app
##	DO_SUDO=$(osascript \
##				-e	'set the_password to ""' \
##				-e	'try' \
##				-e		'tell application "Finder"' \
##				-e			'set the_username to do shell script "whoami"' \
##				-e			'set the_password to ""' \
##				-e 			"do shell script \"sudo chmod -R 777 '$path_only'/Plug-Ins/Elvis\" password the_password with administrator privileges" \
##				-e 			"do shell script \"sudo chmod -R 777 '$path_only'/Plug-Ins/WoodWing\" password the_password with administrator privileges" \
##				-e 			'do shell script "sudo chmod -R 777 /Applications/ElvisInDesign.app" password the_password with administrator privileges' \
##				-e 			'do shell script "sudo chmod -R 777 /Applications/ElvisInDesign.app/Contents" password the_password with administrator privileges' \
##	        	-e 			'do shell script "sudo rm -rf /Applications/ElvisInDesign.app" password the_password with administrator privileges' \
##				-e			'set the_password to "1"' \
##				-e		'end tell' \
##				-e	'on error number -128' \
##				-e		'set the_password to "0"' \
##				-e	'end try' \
##				-e 'return {the_password}')

##Removing ElvisInDesign App via a shell script
	rm -rf "/Applications/ElvisInDesign.app"

	echo "USER ACTION: ${UNINSTALL_ELVISINDESIGN_APP}"
	echo ""

	# Check if the user has canceled (0) or not (1).
	if [ "${UNINSTALL_ELVISINDESIGN_APP}" == "0" ]; then
		echo "${UNINSTALL_ELVISINDESIGN_APP}"
		exit 1;
	else
		echo "NO CANCEL"
	fi
else
	# Ask the user for the administrator username and password.
	# IF the user cancels then nothing will be done.
	# The script will set some access rights.
	DO_SUDO=$(osascript \
				-e	'set the_password to ""' \
				-e	'try' \
				-e		'tell application "Finder"' \
				-e			'set the_username to do shell script "whoami"' \
				-e			'set the_password to ""' \
				-e 			"do shell script \"sudo chmod -R 777 '$path_only'/Plug-Ins/Elvis\" password the_password with administrator privileges" \
				-e 			"do shell script \"sudo chmod -R 777 '$path_only'/Plug-Ins/WoodWing\" password the_password with administrator privileges" \
				-e 			'do shell script "sudo chmod -R 777 /Applications/ElvisInDesign.app" password the_password with administrator privileges' \
				-e 			'do shell script "sudo chmod -R 777 /Applications/ElvisInDesign.app/Contents" password the_password with administrator privileges' \
				-e			'set the_password to "1"' \
				-e		'end tell' \
				-e	'on error number -128' \
				-e		'set the_password to "0"' \
				-e	'end try' \
				-e 'return {the_password}')

	echo "USER ACTION: ${DO_SUDO}"
	echo ""

	# Check if the user has canceled (0) or not (1).
	if [ "${DO_SUDO}" == "0" ]; then
		echo "${DO_SUDO}"
		exit 1;
	else
		echo "NO CANCEL"
	fi
fi


#---------------------------------------------------------------------
# Remove plugins.

function UninstallPlugins()
{
	# Delete the whole 'Plug-Ins/Elvis' folder.
	#	echo " Deleting the Elvis Folder"
	if [ -d "${path_only}/Plug-Ins/Elvis" ]; then
		rm -rf "${path_only}/Plug-Ins/Elvis"
	fi

	# Delete the WoodWingCommon plugins.
	if [ -d "${path_only}/Plug-Ins/WoodWing" ]; then

		# Find and remopve all the WoodwingCommon plugins.
		find "${path_only}/Plug-Ins/WoodWing" \
				-maxdepth "1" \
				\( -iname "WoodWingCommon*.InDesignPlugin" \) \
				-exec echo "  Deleting {}" \; \
				-exec rm -rf {} \;

		# Delete the whole 'Plug-Ins/WoodWing' folder if it is empty.
		rmdir "${path_only}/Plug-Ins/WoodWing"
	fi
}


#---------------------------------------------------------------------
# Remove the Elvis InDesign installer log files.

function UninstallInstallerLogs()
{
	if [ -f "/private/tmp/WWElvisInDesignInstallCheck.log" ]; then
		:> "/private/tmp/WWElvisInDesignInstallCheck.log"
		rm -rf "/private/tmp/WWElvisInDesignInstallCheck.log"
	fi

	if [ -f "/private/tmp/WWElvisInDesignInstaller.log" ]; then
		:> "/private/tmp/WWElvisInDesignInstaller.log"
		rm -rf "/private/tmp/WWElvisInDesignInstaller.log"
	fi
}

# Remove all package IDs
#function UninstallPackageIDs()


#---------------------------------------------------------------------
# Main script.

# Delete the 'Plug-Ins/Elvis' folder and its content.
UninstallPlugins

UninstallInstallerLogs

#UninstallPackageIDs

# Show a message to the user on success.
##Want this to be silent--removing this bit of UI
##if [ $B_MSG == true ]; then
##	osascript \
##	-e 'with timeout of 1800 seconds' \
##	-e 	'tell application "Finder"' \
##	-e	'activate' \
##	-e		'display dialog "Elvis InDesign has been succesfully removed." with title "Uninstall Elvis InDesign" buttons {"OK"}' \
##	-e 	'end tell' \
##	-e 'end timeout'
##fi

# Remove the uninstaller.
##Another hard path here
##new_path_only=`dirname "${0}"`
##new_path_only=`dirname "${new_path_only}"`
##new_path_only=`dirname "${new_path_only}"`
new_path_only="/Applications/Adobe InDesign CC 2019/Uninstall Elvis InDesign plug-ins.app"
#echo "New path only: ${new_path_only}"

# Delete the uninstaller app if it exists in the found path name.
if [[ "${new_path_only}" == *"Uninstall Elvis InDesign plug-ins.app"* ]]; then
	rm -rf "${new_path_only}"
fi

##Elvis has left the building
exit 0
