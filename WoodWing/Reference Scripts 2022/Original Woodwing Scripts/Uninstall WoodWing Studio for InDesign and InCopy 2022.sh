#!/bin/bash
echo ""

#---------------------------------------------------------------------
# Declare the path finding variables.

# Get the absolute path to this very script with script name and extension.
# To get the path only, detract the directory name.
uninstaller_path=`dirname "$0"`
uninstaller_path=`dirname "${uninstaller_path}"`
uninstaller_path=`dirname "${uninstaller_path}"`
path_only=`dirname "${uninstaller_path}"`

# Boolean to show message on success.
B_MSG=true

# Ask the user for the administrator username and password.
# IF the user cancels then nothing will be done.
UNINSTALL_WOODWINGSTUDIOIDP_APP=$(osascript \
								-e	'set the_results to ""' \
								-e	'try' \
								-e		'tell application "Finder"' \
								-e		'activate' \
								-e		'set the_results to ((display dialog "You are about to remove all WoodWing Studio files, including the WoodWing Studio IDP.app.\nWhen you have multiple installations of WoodWing Studio on your system, you might want to leave this file on your system.\n\nDo you want to remove the WoodWing Studio IDP.app?" with title "Uninstall WoodWing Studio" buttons {"Yes", "No"} default button 2))' \
								-e		'end tell' \
								-e	'end try' \
								-e 'return {the_results}')

echo "USER ACTION: ${UNINSTALL_WOODWINGSTUDIOIDP_APP}"
echo ""

if [[ "${UNINSTALL_WOODWINGSTUDIOIDP_APP}" == *":Yes"* ]]; then
	# Ask the user for the administrator username and password.
	# IF the user cancels then nothing will be done.
	DO_SUDO=$(osascript \
				-e	'set the_password to ""' \
				-e	'try' \
				-e		'tell application "Finder"' \
				-e			'set the_username to do shell script "whoami"' \
				-e			'set the_password to ""' \
				-e 			"do shell script \"sudo chmod -R 777 '${uninstaller_path}'\" password the_password with administrator privileges" \
				-e 			"do shell script \"sudo chmod -R 777 '${path_only}'/Plug-Ins\" password the_password with administrator privileges" \
				-e 			"do shell script \"sudo chmod -R 777 '${path_only}'/Plug-Ins/WoodWing\" password the_password with administrator privileges" \
				-e 			'do shell script "sudo chmod -R 777 \"/Applications/WoodWing Studio IDP.app\"" password the_password with administrator privileges' \
				-e 			'do shell script "sudo chmod -R 777 \"/Applications/WoodWing Studio IDP.app/Contents\"" password the_password with administrator privileges' \
    	    	-e 			'do shell script "sudo rm -rf \"/Applications/WoodWing Studio IDP.app\"" password the_password with administrator privileges' \
				-e			'set the_password to "1"' \
				-e		'end tell' \
				-e	'on error number -128' \
				-e		'set the_password to "0"' \
				-e	'end try' \
				-e 'return {the_password}')

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
    echo "Setting admin rights for folders"
	DO_SUDO=$(osascript \
				-e	'set the_password to ""' \
				-e	'try' \
				-e		'tell application "Finder"' \
				-e			'set the_username to do shell script "whoami"' \
				-e			'set the_password to ""' \
				-e 			"do shell script \"sudo chmod -R 777 '${uninstaller_path}'\" password the_password with administrator privileges" \
				-e 			"do shell script \"sudo chmod -R 777 '${path_only}'/Plug-Ins\" password the_password with administrator privileges" \
				-e 			"do shell script \"sudo chmod -R 777 '${path_only}'/Plug-Ins/WoodWing\" password the_password with administrator privileges" \
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
	FILES=$(find "${path_only}/Plug-Ins/$FOLDER/" -maxdepth "1" -iname "$PRODUCT*.InDesignPlugin")

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
		find "${path_only}/Plug-Ins/WoodWing" \
				-maxdepth "1" \
				\( -iname "SCCore*.InDesignPlugin" \
				-o -iname "SCEnt*.InDesignPlugin" \
				-o -iname "SCEnt*.swf" \
				-o -iname "SCPro*.InDesignPlugin" \
				-o -iname "SmartImage*.InDesignPlugin" \
				-o -iname "SmartJump*.InDesignPlugin" \
				-o -iname "SmartJump*.InDesignPlugin" \
				-o -iname "SmartDPSTools*.InDesignPlugin" \) \
				-exec echo "  Deleting {}" \; \
				-exec rm -Rf {} \;

	fi

	if [ "$MODE" == "woodwingstudio" ]; then
		# Find all the conventional WoodWing Studio plugins.
		# Includes strange SmartJump naming.
		# Remove the found plugins.
		find "${path_only}/Plug-Ins/WoodWing" \
				-maxdepth "1" \
				\( -iname "SCCore*.InDesignPlugin" \
				-o -iname "SCEnt*.InDesignPlugin" \
				-o -iname "SCEnt*.swf" \
				-o -iname "SCPro*.InDesignPlugin" \
				-o -iname "SmartImage*.InDesignPlugin" \
				-o -iname "SmartJump*.InDesignPlugin" \
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
		rm -Rf "${path_only}/Plug-Ins/WoodWing"
	fi

	echo ""
}

#---------------------------------------------------------------------
# Uninstall the installed PluginConfig.txt file.
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
	IsProductInstalled "Assets" "WoodWing"
	if [ $? == 0 ]; then
		UninstallPlugins "woodwingstudio"
		B_MSG=false
	else
		UninstallPlugins "totally"
	fi

	B_MSG=true
fi

#Uninsatll the PluginConfig.txt file.
UninstallPluginConfig

# Show a message to the user on success.
if [ $B_MSG == true ]; then
	osascript \
	-e 'with timeout of 1800 seconds' \
	-e 	'tell application "Finder"' \
	-e		'display dialog "WoodWing Studio is successfully uninstalled." buttons {"OK"}' \
	-e 	'end tell' \
	-e 'end timeout'
fi

# Remove the uninstaller.
rm -Rf "${uninstaller_path}"

exit 0