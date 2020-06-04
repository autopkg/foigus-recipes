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
path_only="/Applications/Adobe InCopy CC 2015"
##path_only="/Applications/Adobe InDesign CC 2015"

# Boolean to show message on success.
B_MSG=true

#---------------------------------------------------------------------
# Uninstalls the ZXP extensions

function UninstallZXPExtensions()
{
##	Don't need these variables any more
##	USERNAME=`id -un`
##	BASENAME=`basename "$0"`
##	#BASENAME="${BASENAME/Uninstall }"
##	#BASENAME="${BASENAME/DAILY }"
##	BASENAME="${BASENAME/.sh}"

	# Get the password from the currect user.
##	We're already root, don't need to run this
##	pw="$(osascript -e 'Tell application "System Events" to display dialog "Please enter the password for '"'"$USERNAME"'"':" default answer "" with hidden answer with title "'"$BASENAME"'"' -e 'text returned of result' 2>/dev/null)" 
##
##	# If the password is emprt (cancel) we stop the uninstaller.
##	if [ "$pw" == "" ]; then
##		exit 1
##	fi

	# Get the path to the ExManCmd tool.
##	I reject your reality of EXMANPATH and substitute my own, since "dirname" isn't
##	effective if I'm not running the script from just the right directory.
##	EXMANPATH=`dirname "${0}"`
##	EXMANPATH=`dirname "${EXMANPATH}"`

	# Give all rights to installation paths.
##	We're already root, we don't need additional rights
##	echo "$pw" | sudo -S chmod -R 777 "$path_only/Plug-Ins/WoodWing"
##	echo "$pw" | sudo -S chmod -R 777 "$path_only/Plug-Outs"

	# Uninstall the ZXP extensions.
##	I again reject your reality of EXMANPATH and substitute my own, since "dirname" isn't
##	effective if I'm not running the script from just the right directory.
##	echo "$pw" | sudo -S "${EXMANPATH}/ExManCmd/MacOS/ExManCmd" --remove "Sticky Notes"
##	echo "$pw" | sudo -S "${EXMANPATH}/ExManCmd/MacOS/ExManCmd" --remove "Smart Caching 2015"
	/Applications/Adobe\ InCopy\ CC\ 2015/Uninstall\ Smart\ Connection\ for\ Adobe\ CC\ 2015\ v*\ Build*.app/Contents/ExManCmd/MacOS/ExManCmd --remove "Sticky Notes"
	/Applications/Adobe\ InCopy\ CC\ 2015/Uninstall\ Smart\ Connection\ for\ Adobe\ CC\ 2015\ v*\ Build*.app/Contents/ExManCmd/MacOS/ExManCmd --remove "Smart Caching 2015"

	# If the password was not correct we let the user try again.
##	Again, we're root--this no longer applies
##	if [ "$?" == "1" ]; then
##		UninstallZXPExtensions		
##	fi
}
# Uninstall the installed ZXP extensions from Adobe Extension Manager.
UninstallZXPExtensions


#---------------------------------------------------------------------
# Check if a certain (sent) product currently is installed.

function IsProductInstalled()
{
	# The product name to look for.
	PRODUCT=$1

	# Check if any installed plugins which match the sent criteria are found.
	FILES=$(find "$path_only/Plug-Ins/WoodWing/" -maxdepth "1" -iname "$PRODUCT*.InDesignPlugin")

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
	# Check if the "SmartCatalog" plugins currently are installed.
	IsProductInstalled "SmartCatalog"
	if [ $? == 0 ]; then
		return 1
	fi

	# Check if the "SmartLayout" plugins currently are installed.
	IsProductInstalled "SmartLayout"
	if [ $? == 0 ]; then
		return 1
	fi

	# Check if the "SmartStyle(s)" plugins currently are installed.
	IsProductInstalled "SmartStyle"
	if [ $? == 0 ]; then
		return 1
	fi

	# Check if the "SmartTables" plugins currently are installed.
	IsProductInstalled "SmartTables"
	if [ $? == 0 ]; then
		return 1
	fi

	# Check if the "WWStyling" plugins currently are installed.
	IsProductInstalled "WWStyling"
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

		# Find all the conventional Smart Connection plugins.
		# Includes strange SmartJump naming.
		# Remove the found plugins.
## Removed the "strange SmartJump naming" line, since it causes the script to not work properly when run by Munki
		find "$path_only/Plug-Ins/WoodWing" \
				-maxdepth "1" \
				\( -iname "SCCore*.InDesignPlugin" \
				-o -iname "SCEnt*.InDesignPlugin" \
				-o -iname "SCEnt*.swf" \
				-o -iname "SCPro*.InDesignPlugin" \
				-o -iname "SmartImage*.InDesignPlugin" \
				-o -iname "SmartJump*.InDesignPlugin" \
				-o -iname "SmartDPSTools*.InDesignPlugin" \) \
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
# Main script.

# Check if we can uninstall the Smart Connection product.
CanWeUninstallAll
# No, just delete the conventional SCEnt plugins.
if [ $? == 1 ]; then

	# We cannot uninstall totally due to other installed products.
	# Only install the conventional Smart Connection plugins.
	UninstallPlugins "conventional"

	B_MSG=false

# Yes, delete the whole 'Plug-Ins/WoodWing' folder.
else
	UninstallPlugins "totally"

	B_MSG=true
fi

# if [ -d "$path_only/Plug-Outs" ]; then
# 	B_MSG=false
# fi

# What ever the outcome of the 'CanWeUninstallAll' function
# we set back all original InCopyWorkflow and UI plugins during
# the de-installation of the Smart Connection product.
ReInstallPlugOuts

# Show a message to the user on success.
##Want this to be silent--removing this bit of UI
##if [ $B_MSG == true ]; then
##	osascript \
##	-e 'with timeout of 1800 seconds' \
##	-e 	'tell application "Finder"' \
##	-e		'display dialog "Smart Connection is successfully uninstalled." buttons {"OK"}' \
##	-e 	'end tell' \
##	-e 'end timeout'
##fi

# Remove the uninstaller.
##Another hard path here
##new_path_only=`dirname "$0"`
##new_path_only=`dirname "$new_path_only"`
##new_path_only=`dirname "$new_path_only"`
new_path_only="/Applications/Adobe InCopy CC 2015/Uninstall Smart Connection for Adobe CC 2015"
##new_path_only="/Applications/Adobe InDesign CC 2015/Uninstall Smart Connection for Adobe CC 2015"

##rm -Rf "$new_path_only"
##Wildcarded to remove all Smart Connection CC 2015 uninstallers since they're named "Uninstall Smart Connection for Adobe CC 2015 <version>"
rm -Rf "$new_path_only"*

exit 0