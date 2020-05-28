#!/bin/bash
echo ""

##Double pound signs are edits from Patrick Fergus
#---------------------------------------------------------------------
# Declare the path finding variables.

# Get the absolute path to this very script with script name and extension.
# To get the path only, detract the directory name.
##Don't need to find the application folder to uninstall from, let's hard-code this
##path_only=`dirname "$0"`
##path_only=`dirname "$path_only"`
##path_only=`dirname "$path_only"`
##path_only=`dirname "$path_only"`
path_only="/Applications/Adobe InCopy 2020"
##path_only="/Applications/Adobe InDesign 2020"

# Boolean to show message on success.
B_MSG=true

##Not needed, this will run as root
### Ask the user for the administrator username and password.
### IF the user cancels then nothing will be done.
##UNINSTALL_WOODWINGSTUDIOIDP_APP=$(osascript \
##								-e	'set the_results to ""' \
##								-e	'try' \
##								-e		'tell application "Finder"' \
##								-e		'activate' \
##								-e		'set the_results to ((display dialog "You are about to remove all WoodWing Studio files, including the WoodWing Studio IDP.app.\nWhen you have multiple installations of WoodWing Studio on your system, you might want to leave this file on your system.\n\nDo you want to remove the WoodWing Studio IDP.app?" with title "Uninstall WoodWing Studio" buttons {"Yes", "No"} default button 2))' \
##								-e		'end tell' \
##								-e	'end try' \
##								-e 'return {the_results}')

##Set Woodwing Studio IDP App to be uninstalled
UNINSTALL_WOODWINGSTUDIOIDP_APP=":Yes"

echo "USER ACTION: ${UNINSTALL_WOODWINGSTUDIOIDP_APP}"
echo ""

if [[ "${UNINSTALL_WOODWINGSTUDIOIDP_APP}" == *":Yes"* ]]; then
##Don't remove Woodwing Studio IDP App via AppleScript
##	# Ask the user for the administrator username and password.
##	# IF the user cancels then nothing will be done.
##	DO_SUDO=$(osascript \
##				-e	'set the_password to ""' \
##				-e	'try' \
##				-e		'tell application "Finder"' \
##				-e			'set the_username to do shell script "whoami"' \
##				-e			'set the_password to ""' \
##				-e 			"do shell script \"sudo chmod -R 777 '$path_only'/Plug-Ins/WoodWing\" password the_password with administrator privileges" \
##				-e 			'do shell script "sudo chmod -R 777 \"/Applications/WoodWing Studio IDP.app\"" password the_password with administrator privileges' \
##				-e 			'do shell script "sudo chmod -R 777 \"/Applications/WoodWing Studio IDP.app/Contents\"" password the_password with administrator privileges' \
##    	    	-e 			'do shell script "sudo rm -rf \"/Applications/WoodWing Studio IDP.app\"" password the_password with administrator privileges' \
##				-e			'set the_password to "1"' \
##				-e		'end tell' \
##				-e	'on error number -128' \
##				-e		'set the_password to "0"' \
##				-e	'end try' \
##				-e 'return {the_password}')

##Removing Woodwing Studio IDP App via a shell script
	rm -rf "/Applications/WoodWing Studio IDP.app"

	echo "USER ACTION: ${UNINSTALL_WOODWINGSTUDIOIDP_APP}"
	echo ""

	# Check if the user has canceled (0) or not (1).
	if [ "${UNINSTALL_WOODWINGSTUDIOIDP_APP}" == "0" ]; then
		echo "${UNINSTALL_WOODWINGSTUDIOIDP_APP}"
		exit 1;
	else
		echo "NO CANCEL"
	fi
else
	# Ask the user for the administrator username and password.
	# IF the user cancels then nothing will be done.
	DO_SUDO=$(osascript \
				-e	'set the_password to ""' \
				-e	'try' \
				-e		'tell application "Finder"' \
				-e			'set the_username to do shell script "whoami"' \
				-e			'set the_password to ""' \
				-e 			"do shell script \"sudo chmod -R 777 '$path_only'/Plug-Ins/WoodWing\" password the_password with administrator privileges" \
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
# Check if a certain (sent) product currently is installed.

function IsProductInstalled()
{
	# The product name to look for.
	PRODUCT=$1
	FOLDER=$2

	# Check if any installed plugins which match the sent criteria are found.
	FILES=$(find "$path_only/Plug-Ins/$FOLDER/" -maxdepth "1" -iname "$PRODUCT*.InDesignPlugin")

	# Check if files exist and return a value correctly.
	if [[ ! $FILES ]]; then
		echo "No $PRODUCT plugins are installed."
		echo ""
		return 1	# False.
	else
		echo "$PRODUCT plugins are installed:"
		echo ""
		echo "    $FILES"
		echo ""
		return 0	# True.
	fi
}

#---------------------------------------------------------------------
# Check if we can uninstall.

function CanWeUninstallAll()
{
	# Check if the "SmartStyle(s)" plugins currently are installed.
	IsProductInstalled "SmartStyle" "WoodWing"
	if [ $? == 0 ]; then
		return 1
	fi

	# Check if the "SmartTables" plugins currently are installed.
	IsProductInstalled "SmartTables" "WoodWing"
	if [ $? == 0 ]; then
		return 1
	fi

	# Check if the "WWStyling" plugins currently are installed.
	IsProductInstalled "WWStyling" "WoodWing"
	if [ $? == 0 ]; then
		return 1
	fi
	
	return 0
}

#---------------------------------------------------------------------
# Remove plugins.

function UninstallPlugins()
{
	# Tells the function what and how to remove.
	MODE=$1

	# Delete only the conventional plugins.
	if [ "$MODE" == "conventional" ]; then

		# Find all the conventional WoodWing Studio plugins.
		# Includes strange SmartJump naming.
		# Remove the found plugins.
		find "$path_only/Plug-Ins/WoodWing" \
				-maxdepth "1" \
				\( -iname "SCCore*.InDesignPlugin" \
				-o -iname "SCEnt*.InDesignPlugin" \
				-o -iname "SCEnt*.swf" \
				-o -iname "SCPro*.InDesignPlugin" \
				-o -iname "SmartImage*.InDesignPlugin" \
## Removed above line in find command due to problematic characters, SmartXXtJump*.InDesignPlugin.  XX are bad characters \
##				-o -iname "SmarXXtJump*.InDesignPlugin" \
				-o -iname "SmartJump*.InDesignPlugin" \
				-o -iname "SmartDPSTools*.InDesignPlugin" \) \
				-exec echo "  Deleting {}" \; \
				-exec rm -Rf {} \;

	fi

	if [ "$MODE" == "woodwingstudio" ]; then
		# Find all the conventional WoodWing Studio plugins.
		# Includes strange SmartJump naming.
		# Remove the found plugins.
		find "$path_only/Plug-Ins/WoodWing" \
				-maxdepth "1" \
				\( -iname "SCCore*.InDesignPlugin" \
				-o -iname "SCEnt*.InDesignPlugin" \
				-o -iname "SCEnt*.swf" \
				-o -iname "SCPro*.InDesignPlugin" \
				-o -iname "SmartImage*.InDesignPlugin" \
## Removed above line in find command due to problematic characters, SmartXXtJump*.InDesignPlugin.  XX are bad characters \
##				-o -iname "SmarXXtJump*.InDesignPlugin" \
				-o -iname "SmartJump*.InDesignPlugin" \
				-o -iname "SmartDPSTools*.InDesignPlugin" \
				-o -iname "ElementLabel*.InDesignPlugin" \
				-o -iname "WoodWingWidgets.InDesignPlugin" \
				-o -iname "WoodWing.InDesignPlugin" \
				-o -iname "WoodWingUI.InDesignPlugin" \) \
				-exec echo "  Deleting {}" \; \
				-exec rm -Rf {} \;
	fi

	# Delete the whole 'Plug-Ins/WoodWing' folder.
	if [ "$MODE" == "totally" ]; then
		echo "  Deleting the WoodWing Folder"
		rm -Rf "$path_only/Plug-Ins/WoodWing"
	fi

	echo ""
}

#---------------------------------------------------------------------
# Re-Install a single Plug-Out
# If target destination already exists, it will first merge it with Plug-Outs
# No-op if Plug-Out does not exists
function ReInstallPlugOut()
{
	# Plug-Out path of plugin to be re-installed
	SOURCEPATH=$1
	
	# Destination path of Plug-In
	TARGETPATH=$2
	
	# Plug-in name
	TARGET=$3
	
	# Only if the Plug-Out exists
	if [ -d "${SOURCEPATH}/$TARGET" ]; then
		# If there  is already a Plug-In in the destination path, first
		# copy this plug-in back into the Plug-Outs.
		# This Plug-In was probably placed by an Adobe Update and might only be partial.
		# By copying it into Plug-Outs we apply it to the older Plug-In version
		if [ -d "${TARGETPATH}/$TARGET" ]; then
			cp -LRPp "${TARGETPATH}/$TARGET" "$SOURCEPATH"
			rm -rf "$TARGETPATH/$TARGET"
		fi
		
		# Finally re-install the Plug-Out
		mv "$SOURCEPATH/$TARGET"			"$TARGETPATH"
	fi
}

#---------------------------------------------------------------------
# Re-install InDesign/InCopy plugins from the Plug-Outs folder to their
# original Plug-Ins folder InCopyWorkflow and UI.

function ReInstallPlugOuts()
{
	# Plug-Outs folder.
	WW_PLOUT="$path_only/Plug-Outs"
	PI_ICWF="$path_only/Plug-Ins/InCopyWorkflow"
	PI_UI="$path_only/Plug-Ins/UI"
	echo "PI_ICWF: $PI_ICWF"
	echo "PI_UI: $PI_UI"
	echo ""

	# Check if the 'InCopyWorkflow' folder exists.
	if [ -d "$PI_ICWF" ]; then

		ReInstallPlugOut "$WW_PLOUT" "$PI_ICWF" "InCopy Bridge.InDesignPlugin"
		ReInstallPlugOut "$WW_PLOUT" "$PI_ICWF" "InCopy Bridge UI.InDesignPlugin"
		ReInstallPlugOut "$WW_PLOUT" "$PI_ICWF" "InCopyImport.InDesignPlugin"
		ReInstallPlugOut "$WW_PLOUT" "$PI_ICWF" "Assignment UI.InDesignPlugin"
		ReInstallPlugOut "$WW_PLOUT" "$PI_ICWF" "InCopyExport.InDesignPlugin"
		ReInstallPlugOut "$WW_PLOUT" "$PI_ICWF" "InCopyExportUI.InDesignPlugin"
		ReInstallPlugOut "$WW_PLOUT" "$PI_ICWF" "InCopyWorkflow UI.InDesignPlugin"
		
	else
		echo "$WW_PLOUT DOES NOT exist"
		echo ""
	fi

	# Check if the 'UI' folder exists.
	if [ -d "$PI_UI" ]; then

		ReInstallPlugOut "$WW_PLOUT" "$PI_UI" "InCopyFileActions.InDesignPlugin"
		ReInstallPlugOut "$WW_PLOUT" "$PI_UI" "InCopyFileActionsUI.InDesignPlugin"

	else
		echo "$PI_UI DOES NOT exist"
		echo ""
	fi

	# We assume that we have re-installed everything so delete the Plug-Outs folder.
	rm -Rf "$WW_PLOUT"
}

#---------------------------------------------------------------------
# Uninstalls the WoodWingUI panel

function UninstallWoodWingUIPanel()
{
	"${path_only}/WoodWingUI ZXP/ExManCmd/MacOS/ExManCmd" --remove "WoodWingUICC2020"

	rm -Rf "${path_only}/WoodWingUI ZXP"
}

# Uninstall the installed Sticky Notes panel from Adobe Extension Manager.
#
UninstallPluginConfig()
{
	rm -f "${path_only}/PluginConfig.txt"
}

#---------------------------------------------------------------------
# Main script.

# Check if we can uninstall the WoodWing Studio product.
CanWeUninstallAll
# No, just delete the conventional SCEnt plugins.
if [ $? == 1 ]; then

	# We cannot uninstall totally due to other installed products.
	# Only install the conventional WoodWing Studio plugins.
	UninstallPlugins "conventional"

	B_MSG=false

# Yes, delete the whole 'Plug-Ins/WoodWing' folder.
else
	IsProductInstalled "Elvis" "Elvis"
	if [ $? == 0 ]; then
		UninstallPlugins "woodwingstudio"
		B_MSG=false
	else
		UninstallPlugins "totally"
	fi

	B_MSG=true
fi

# if [ -d "$path_only/Plug-Outs" ]; then
# 	B_MSG=false
# fi

# What ever the outcome of the 'CanWeUninstallAll' function
# we set back all original InCopyWorkflow and UI plugins during
# the de-installation of the WoodWing Studio product.
ReInstallPlugOuts

# Uninstall the installed WoodWingUI panel from Adobe Extension Manager.
UninstallWoodWingUIPanel

#Uninsatll the PluginConfig.txt file.
UninstallPluginConfig

# Show a message to the user on success.
##Want this to be silent--removing this bit of UI
##if [ $B_MSG == true ]; then
##	osascript \
##	-e 'with timeout of 1800 seconds' \
##	-e 	'tell application "Finder"' \
##	-e		'display dialog "WoodWing Studio is successfully uninstalled." buttons {"OK"}' \
##	-e 	'end tell' \
##	-e 'end timeout'
##fi

# Remove the uninstaller.
##Just setting the hard path
##new_path_only=`dirname "$0"`
##new_path_only=`dirname "$new_path_only"`
##new_path_only=`dirname "$new_path_only"`
new_path_only="/Applications/Adobe InCopy 2020/Uninstall WoodWing Studio for InDesign and InCopy 2020.app"
##new_path_only="/Applications/Adobe InDesign 2020/Uninstall WoodWing Studio for InDesign and InCopy 2020.app"

rm -Rf "$new_path_only"

exit 0