#!/bin/bash

echo ""
echo ""
echo "#######################################################"
echo ""
echo "	Smart Connection installion script"
echo ""
echo "#######################################################"
echo ""
echo ""

#---------------------------------------------------------------------
# Define the constants.

CC_VERSION="2014"								# Creative Cloud version to install files for.
WWSCTEMPFOLDER="/wwscinsttempcc${CC_VERSION}"	# The temporary installation root folder.
BASE_PATH=${WWSCTEMPFOLDER}						# Base path to temporary installation folder.
TIMEOUT="1800"									# Script timeout for user to response: 1800 seconds = 30 minutes..

# Output all constanst.
echo "WWSCTEMPFOLDER:	${WWSCTEMPFOLDER}"
echo "BASE_PATH:	${BASE_PATH}"
echo "CC_VERSION:	${CC_VERSION}"
echo -e "TIMEOUT:	${TIMEOUT}\n"

#---------------------------------------------------------------------
# Declare the path finding variables.

CHOSEN_INSTANCE=			# Holds correct installation path of the only found or selected from multiple by user.
CHOSEN_USERPATH=			# Holds the path to the correct installation select by the user if no app was found.
GOT_CORRECT_PATH=			# Tipping point of continuation after installation path search.
FOUND_EXTENSIONMANAGER=		# Holds the installation path of the Adobe Extension Manager app that should be found with SearchAdobeExtensionManagerApplication

INDESIGN_PATH=				# Path that will be known for the InDesign product so the InDesign DM installation can provide from it.
INCOPY_PATH=				# Path that will be known for the InCopy product so the InCopy Overset installation can provide from it.
					
WW_PATH=					# Current WW folder path to test on.
WW_PATH_ID=					# Path to the InDesign WoodWing folder.
WW_PATH_IC=					# Path to the InDesign WoodWing folder.
WW_PATH_IDS=				# Path to the InDesign WoodWing folder.
SCRIPT_PANEL_PATH=			# Path to the Smart Connection Book Support scripts.
UNINSTALL_APP_PATH_ID=		# Path to the InDesign uninstaller after placing.
UNINSTALL_APP_PATH_IC=		# Path to the InCopy uninstaller after placing.
UNINSTALL_APP_PATH_IDS=		# Path to the InDesign Server uninstaller after placing.
WW_PLOUT=					# Current Plug-Outs path to test on.
WW_PLOUT_ID=				# Path to the InDesign Plug-Outs folder.
WW_PLOUT_IC=				# Path to the InCopy Plug-Outs folder.
WW_PLOUT_IDS=				# Path to the InDesign Server Plug-Outs folder.


#---------------------------------------------------------------------
# Searches for an instances of the Adobe Extension Manager product of the given CS version.
# If at least one installation is found we use the first fr0m the list.
# If non installations are found we show an error to the user.

function SearchAdobeExtensionManagerApplication()
{
#FOUND_EXTENSIONMANAGER=$(osascript \
#				-e 'with timeout of 30 seconds' \
#				-e 	'set myAppList to paragraphs of (do shell script "find /Applications -maxdepth 4 -iname \"Adobe Extension Manager CC.app\" ; true")' \
#				-e 	'tell application "Installer"' \
#				-e 		'activate' \
#				-e		'if number of myAppList > 0 then' \
#				-e			'set chosen_ to item 1 of myAppList' \
#				-e		'else' \
#				-e			'set chosen_ to ""' \
#				-e			'display dialog "The Sticky Note panel could not be installed because the Adobe Extension Manager CC could not be found.\n\nInstall the Sticky Notes panel manually by double-clicking the StickyNotePanel_CC.zxp file (located in the <InDesign CC>/Plug-Ins/WoodWing folder)." buttons {"OK"} default button "OK"' \
#				-e		'end if' \
#				-e 		'return chosen_' \
#				-e 	'end tell' \
#				-e 'end timeout')
	FOUND_EXTENSIONMANAGER="/Applications/Adobe Extension Manager CC/Adobe Extension Manager CC.app"
}

#---------------------------------------------------------------------
# Searches for all installations of the Adobe product of the given CS version.
# If multiple selections are found we display options to the user to choose from.
# If only one installation is found this is used instantly.
# If non installations are found we ask the user for a folder path in HandleNoInstallationFound().

function SearchInstalledApplication()
{
#	local PRODUCT_MAIN=$1		# The main Adobe product to look the app for.
#	local PRODUCT_ADD=$2		# 'Server' in case of InDesign server, otherwise empty.
#	local SEARCH_PATH=$3		# Starting path of which the search for the app is kicked off.
#	local MAXDEPTH=$4			# Max directory depth the search action has to go in to find the apps.
#	local EXCLUDE_CODE=$5		# String which may not occur in the whole path of the found app.
#	
#	echo "PRODUCT_MAIN:	${PRODUCT_MAIN}"
#	echo "PRODUCT_ADD:	${PRODUCT_ADD}"
#	echo "SEARCH_PATH:	${SEARCH_PATH}"
#	echo "MAXDEPTH:	${MAXDEPTH}"
#	echo "CC_VERSION:	${CC_VERSION}"
#	echo -e "EXCLUDE_CODE:	${EXCLUDE_CODE}\n"
#
#	
#	if [ "${PRODUCT_ADD}" == "Server" ]; then
#		CHOSEN_INSTANCE=$(osascript \
#				-e 'with timeout of '${TIMEOUT}' seconds' \
#				-e 	'set myAppList to paragraphs of (do shell script "find '${SEARCH_PATH}' -maxdepth '${MAXDEPTH}' -iwholename '*${PRODUCT_MAIN}*' -iwholename '*${CC_VERSION}*' -iname '${PRODUCT_MAIN}${PRODUCT_ADD}.app'; true")' \
#				-e  'tell application "Installer"' \
#				-e  	'activate' \
#				-e	 	'if number of myAppList = 1 then' \
#				-e	 		'set chosen_ to item 1 of myAppList' \
#				-e	 	'else' \
#				-e 			'set chosen_ to (choose from list myAppList with prompt "Multiple instances of '${PRODUCT_MAIN}' CC '${CC_VERSION}' '${PRODUCT_ADD}' are found. Please select one:" without multiple selections allowed) as text' \
#				-e		'end if' \
#				-e 		'return chosen_' \
#				-e 	'end tell' \
#				-e 'end timeout')
#	else
#		CHOSEN_INSTANCE=$(osascript \
#				-e 'with timeout of '${TIMEOUT}' seconds' \
#				-e 	'set myAppList to paragraphs of (do shell script "find '${SEARCH_PATH}' -maxdepth 4 -iname *'${PRODUCT_MAIN}'*.app -iname \"*CC*'${CC_VERSION}'*.app\" -not -iwholename *'${EXCLUDE_CODE}'*; true")' \
#				-e 	'tell application "Installer"' \
#				-e 		'activate' \
#				-e		'if number of myAppList = 1 then' \
#				-e			'set chosen_ to item 1 of myAppList' \
#				-e		'else' \
#				-e 			'set chosen_ to (choose from list myAppList with prompt "Multiple instances of '${PRODUCT_MAIN}' CC '${CC_VERSION}' are found. Please select one:" without multiple selections allowed) as text' \
#				-e		'end if' \
#				-e 		'return chosen_' \
#				-e 	'end tell' \
#				-e 'end timeout')
#	fi

	CHOSEN_INSTANCE="/Applications/Adobe InDesign CC 2014/Adobe InDesign CC 2014.app"
	echo -e "CHOSEN_INSTANCE:	${CHOSEN_INSTANCE}\n"
}

# ---------------------------------------------------------------------------------
# If in SearchInstalledApplication() no installation is found we ask
# the user to browse for a folder path to do the installation in.

function HandleNoInstallationFound()
{
	local PRODUCT_MAIN=$1
	local PRODUCT_ADD=$2
	
	CHOSEN_USERPATH=$(osascript \
			-e 'with timeout of '$TIMEOUT' seconds' \
			-e 	'tell application "Installer"' \
			-e		'set userPath_ to (choose folder with prompt "\nNo Adobe '$PRODUCT_MAIN' CC '$CC_VERSION' '$PRODUCT_ADD' installation was found.\nPlease select the folder where the Adobe '$PRODUCT_MAIN' CC '$CC_VERSION' '$PRODUCT_ADD' application is installed in:\n" invisibles false) as text' \
			-e		'set userPathPosix_ to POSIX path of userPath_' \
			-e		'return userPathPosix_' \
			-e 	'end tell' \
			-e 'end timeout')
}

# ---------------------------------------------------------------------------------
# 

function HandleReturnedInstallationPath()
{
	# Check the found installation path found.
	if [ "${CHOSEN_INSTANCE}" == "" ]; then

		# Do a user-request-for-installation-path loop until
		# we have a correct path which meets our standards.
		while [ "${GOT_CORRECT_PATH}" != "yes" ]
		do 
			# The darned thing is empty, message the user about it
			# and end the installation.
			HandleNoInstallationFound ${PRODUCT_MAIN} ${PRODUCT_ADD}
	
			# Check the returned value of the user selection.
			# Empty if cancelled (or escaped) or non chosen (quit the installation)
			if [ "${CHOSEN_USERPATH}" == "" ]; then
				
				# Clean up all temp plugin stuff we placed on the disk.
				CleanUpTempInstallation
				echo -e "Too bad...\n"
				exit 1
			else
	
				# check if there is a 'Plug-Ins' folder in the chosen folder.
				# If not, ask the user again with notion that it cannot find the folder.
				if [ -d "${CHOSEN_USERPATH}Plug-Ins" ]; then
	
					# The user chose a correct path (with Plug-Ins folder), continue.
					GOT_CORRECT_PATH="yes"
	
					# Set the given folder path as the chosen folder path.
					CHOSEN_INSTANCE=${CHOSEN_USERPATH}
				else
	
					# The user chose an incorrect folder (without any Plug-Ins folder).
					# Display this to the user and give again the option to choose a folder.
					$(osascript \
						-e 'with timeout of '${TIMEOUT}' seconds' \
						-e 	'tell application "Installer"' \
						-e		'display dialog "The chosen folder does not contain a correct '${PRODUCT_MAIN}' CC '${CC_VERSION}' '${PRODUCT_ADD}' installation.\n\nPlease choose a correct folder" buttons {"OK"} default button "OK"' \
						-e 	'end tell' \
						-e 'end timeout')
				fi
			fi
		done
	fi
}

# ---------------------------------------------------------------------------------
# Check if the *.txt file count is more than '0'.
# If so, quit the script.

function CheckMarkerExistence()
{
	# Get the amount of *.txt files in the temporary wwscinsttempcc* folder.
	local TXT_COUNT=`ls -1 $BASE_PATH/*.txt | wc -l`
	# Remove all spaces.
	TXT_COUNT=$(echo ${TXT_COUNT}|sed 's/ //g')
	echo -e "There are ${TXT_COUNT} installation marker files\n"

	# If there are no txt files we assume that the installation is done.
	if [ ${TXT_COUNT} -le 0 ]; then
		echo "No more *.txt files are found. Assumed to have installed all"
		echo -e "Quitting installation script\n"
		exit 0
	fi
}

# ---------------------------------------------------------------------------------
# Search for and install for the installation targets.

function FindAndInstallForTargets()
{
	# Check marker existence.
	# If non found, we quit the script.
	CheckMarkerExistence

	# Get all the *.txt files in the wwscinsttempcc* temporary installation folder.
	local FILES=${BASE_PATH}/*.txt
	
	# Loop over all the found files.
	for MARKER in ${FILES}
	do
	
		# Check if the current file is "InDesign.txt"
		if [ ${MARKER} == "${BASE_PATH}/InDesign.txt" ]; then
			echo "-------------------------------------------------------"
			echo -e "Found InDesign marker\n"
	
			# Install plugins for product 'InDesign'.
			InstallPluginsFor "InDesign"
	
			# Remove the current product marker after installation.
			RemoveInstallationMarker "InDesign"
		fi
	
		# Check if the current file is "InDesignDM.txt"
		if [ ${MARKER} == "${BASE_PATH}/InDesignDM.txt" ]; then
			echo "-------------------------------------------------------"
			echo -e "Found InDesignDM marker\n"
	
			# Install plugins for product 'InDesign'.
			InstallPluginsFor "InDesignDM"
	
			# Remove the current product marker after installation.
			RemoveInstallationMarker "InDesignDM"
		fi
	
		# Check if the current file is "InCopy.txt"
		if [ ${MARKER} == "${BASE_PATH}/InCopy.txt" ]; then
			echo "-------------------------------------------------------"
			echo -e "Found InCopy marker\n"
	
			# Install plugins for product 'InCopy'.
			InstallPluginsFor "InCopy"
	
			# Remove the current product marker after installation.
			RemoveInstallationMarker "InCopy"
		fi
	
		# Check if the current file is "InCopyOverset.txt"
		if [ ${MARKER} == "${BASE_PATH}/InCopyOverset.txt" ]; then
			echo "-------------------------------------------------------"
			echo -e "Found InCopyOverset marker\n"
	
			# Install plugins for product 'InCopyOverset'.
			InstallPluginsFor "InCopyOverset"
	
			# Remove the current product marker after installation.
			RemoveInstallationMarker "InCopyOverset"
		fi
	
		# Check if the current file is "InDesignServer.txt"
		if [ ${MARKER} == "${BASE_PATH}/InDesignServer.txt" ]; then
			echo "-------------------------------------------------------"
			echo -e "Found InDesignServer marker\n"
	
			# Install plugins for product 'InDesignServer'.
			InstallPluginsFor "InDesignServer"
	
			# Remove the current product marker after installation.
			RemoveInstallationMarker "InDesignServer"
		fi
	
		# Check if the current file is "InDesignServerDM.txt"
		if [ ${MARKER} == "${BASE_PATH}/InDesignServerDM.txt" ]; then
			echo "-------------------------------------------------------"
			echo -e "Found InDesignServerDM marker\n"
	
			# Install plugins for product 'InDesignServerDM'.
			InstallPluginsFor "InDesignServerDM"
	
			# Remove the current product marker after installation.
			RemoveInstallationMarker "InDesignServerDM"
		fi
	
	done
}

# ---------------------------------------------------------------------------------
# Install the plugins for the given target.

function InstallPluginsFor()
{
	local PRODUCT=$1		# The product which is checked in the wizard menu.
	local PRODUCT_MAIN=$1	# The name of the main product the PRODUCT belongs to.
	local PRODUCT_ADD=		# This is an addition for an extra search or display parameter.

	# Change the PRODUCT_MAIN appropriately. 	
	if [ "${PRODUCT}" == "InDesignDM" ]; then
		PRODUCT_MAIN="InDesign"
	elif [ "${PRODUCT}" == "InCopyOverset" ]; then
		PRODUCT_MAIN="InCopy"
	elif [ "${PRODUCT}" == "InDesignServer" ] || [ "${PRODUCT}" == "InDesignServerDM" ]; then
		PRODUCT_MAIN="InDesign"
		PRODUCT_ADD="Server"
	fi

	echo "Product:	${PRODUCT}"
	echo "Product main:	${PRODUCT_MAIN}"
	echo -e "Product add:	${PRODUCT_ADD}\n"

	# -------------------------------------------

	# Checking InDesign product path existence.
	# Later in this function the found installation path
	# is writen in the .txt files so it will not prompt again here
	# when it wants to install another product for the same target.
	if [ "${PRODUCT_MAIN}" == "InDesign" ]; then
		# Check if there is an install path written in the files.
		CHOSEN_INSTANCE=$(cat ${BASE_PATH}/InDesign.txt)
		if [ "${CHOSEN_INSTANCE}" == "" ]; then
			CHOSEN_INSTANCE=$(cat ${BASE_PATH}/InDesignDM.txt)
		fi
		# Path found, round up the install for the product. Otherwise search again.
		if [ "${CHOSEN_INSTANCE}" != "" ]; then
			# Check folders and plugins inside the given installation folder.
			CheckInternalInstallationFolders "${CHOSEN_INSTANCE}" "${PRODUCT}"
			return 0
		fi
	fi
	# Checking InCopy product path existence.
	if [ "${PRODUCT_MAIN}" == "InCopy" ]; then
		# Check if there is an install path written in the files.
		CHOSEN_INSTANCE=$(cat ${BASE_PATH}/InCopy.txt)
		if [ "$CHOSEN_INSTANCE" == "" ]; then
			CHOSEN_INSTANCE=$(cat ${BASE_PATH}/InCopyOverset.txt)
		fi
		# Path found, round up the install for the product. Otherwise search again.
		if [ "${CHOSEN_INSTANCE}" != "" ]; then
			# Check folders and plugins inside the given installation folder.
			CheckInternalInstallationFolders "${CHOSEN_INSTANCE}" "${PRODUCT}"
			return 0
		fi
	fi

	# -------------------------------------------

	# Search installation(s) for the current target in the '/Applications' directory.
	SearchInstalledApplication "${PRODUCT_MAIN}" "${PRODUCT_ADD}" "/Applications" "4" "@"
	echo ""
	
	# Check the found installation path found.
	if [ "$CHOSEN_INSTANCE" == "" ]; then
		# If no installation found, try it again from the root directory
		# and without the '/Applications' directory.
		SearchInstalledApplication "$PRODUCT_MAIN" "$PRODUCT_ADD" "/" "5" "/Applications"
		echo ""
	fi

	# Display the found installation path.
	#echo -e "The installation path is: ${CHOSEN_INSTANCE}\n"

	# Check the returned path for the installation.
	HandleReturnedInstallationPath
	
	# -------------------------------------------

	# Store the found InDesign installation path.
	if [ "${PRODUCT_MAIN}" == "InDesign" ] && [ "${CHOSEN_INSTANCE}" != "" ]; then
		if [ -f "${BASE_PATH}/InDesign.txt" ]; then
			echo "${CHOSEN_INSTANCE}" > "${BASE_PATH}/InDesign.txt"
		fi
		if [ -f "${BASE_PATH}/InDesignDM.txt" ]; then
			echo "${CHOSEN_INSTANCE}" > "${BASE_PATH}/InDesignDM.txt"
		fi
	fi
	# Store the found InCopy installation path.
	if [ "${PRODUCT_MAIN}" == "InCopy" ] && [ "${CHOSEN_INSTANCE}" != "" ]; then
		if [ -f "${BASE_PATH}/InCopy.txt" ]; then
			echo "${CHOSEN_INSTANCE}" > "${BASE_PATH}/InCopy.txt"
		fi
		if [ -f "${BASE_PATH}/InCopyOverset.txt" ]; then
			echo "${CHOSEN_INSTANCE}" > "${BASE_PATH}/InCopyOverset.txt"
		fi
	fi

	# -------------------------------------------

	# If $CHOSEN_INSTANCE = 'false' then we can be sure that the user
	# canceled or escaped the multiple install user choice dialog.
	if [ "${CHOSEN_INSTANCE}" == "false" ]; then
		echo ""
		echo "-------------------------------------------------------"
		echo "-------------------------------------------------------"
		echo ""
		echo "	User has canceled the installation"
		echo "	Quitting installation script"
		echo ""
		echo "-------------------------------------------------------"
		echo "-------------------------------------------------------"
		echo ""
		exit 1
	fi

	# Check folders and plugins inside the given installation folder.
	CheckInternalInstallationFolders "${CHOSEN_INSTANCE}" "${PRODUCT}"
}

# ---------------------------------------------------------------------------------
# Moves the source file to the plug-outs folder
# We do this by "cp -LRPp" to merge partially plug-in updates from Adobe Update
# Noop if source plug-in does not exists
function MoveToPlugOuts()
{
	local SOURCEPATH=$1		# Source path of plugin to be moved
	local TARGETPATH=$2		# Destination path (i.e. Plug-Outs folder)
	local TARGET=$3			# Plug-in name

	if [ -d "${SOURCEPATH}/${TARGET}" ]; then
		cp -LRPp "${SOURCEPATH}/${TARGET}"			"${TARGETPATH}"
		rm -rf "${SOURCEPATH}/${TARGET}"
	fi
}

# ---------------------------------------------------------------------------------
# Check folders and plugins inside the given installation folder.

function CheckInternalInstallationFolders()
{
	local INSTALL_PATH=`dirname "$1"`	# Only get the preceding directory and remove the app name.
	local PRODUCT=$2					# Get the product we have to do the installation for.

	echo "Path found: ${INSTALL_PATH}"
	echo -e "Product: ${PRODUCT}\n"

	# ------------------------------------------------------------
	# Construct the Plug-Outs directory.
	# First, check if the Plug-Outs directory is present.
	# If not so, first create it.

	WW_PLOUT="${INSTALL_PATH}/Plug-Outs"
	
	# Assign the unique paths for the current product.
	if [ "${PRODUCT}" == "InDesign" ] || [ "${PRODUCT}" == "InDesignDM" ]; then
		WW_PLOUT_ID="${INSTALL_PATH}/Plug-Outs"
	elif [ "${PRODUCT}" == "InCopy" ] || [ "${PRODUCT}" == "InCopyOverset" ]; then
		WW_PLOUT_IC="${INSTALL_PATH}/Plug-Outs"
	elif [ "${PRODUCT}" == "InDesignServer" ] || [ "${PRODUCT}" == "InDesignServerDM" ]; then
		WW_PLOUT_IDS="${INSTALL_PATH}/Plug-Outs"
	fi

	# Check if a Plug-Outs folder exists and if not, create it.
	if [ -d "${WW_PLOUT}" ]; then
		echo -e "OK: Plug-Outs directory found\n"
	else
		echo "ERROR: No Plug-Outs directory found."
		echo "Creating Plug-Outs director. . ."

		mkdir "${WW_PLOUT}"
		echo -e "Done\n"
	fi

	# ------------------------------------------------------------
	# Construct the WoodWing install directory.
	# First, check if the WoodWing directory is present.
	# If not so, create it.

	WW_PATH="${INSTALL_PATH}/Plug-Ins/WoodWing"

	# Assign the unique paths for the current product.
	if [ "${PRODUCT}" == "InDesign" ] || [ "${PRODUCT}" == "InDesignDM" ]; then
		WW_PATH_ID="${INSTALL_PATH}/Plug-Ins/WoodWing"
	elif [ "${PRODUCT}" == "InCopy" ] || [ "${PRODUCT}" == "InCopyOverset" ]; then
		WW_PATH_IC="${INSTALL_PATH}/Plug-Ins/WoodWing"
	elif [ "${PRODUCT}" == "InDesignServer" ] || [ "${PRODUCT}" == "InDesignServerDM" ]; then
		WW_PATH_IDS="${INSTALL_PATH}/Plug-Ins/WoodWing"
	fi

	# Check if a WoodWing folder exists and if not, create it.
	if [ -d "${WW_PATH}" ]; then
		echo -e "OK: WoodWing directory found\n"
	else
		echo "ERROR: No WoodWing directory found."
		echo "Creating WoodWing director. . ."
	
		mkdir "${WW_PATH}"
		echo -e "Done\n"
	fi

	# ------------------------------------------------------------
	# Move the superfluous InDesign files to the Plug-Outs directory.

	WW_PLIN="${INSTALL_PATH}/Plug-Ins"
	#echo -e "Path to remove folder: ${WW_PLIN}\n"

	# Remove the superfuous files from the 'InCopyWorkflow' folder.
	if [ -d "${WW_PLIN}/InCopyWorkflow" ]; then

		#echo -e "${WW_PLIN}/InCopyWorkflow exists\n"
		
		MoveToPlugOuts "${WW_PLIN}/InCopyWorkflow" "${WW_PLOUT}" "InCopy Bridge.InDesignPlugin"
		MoveToPlugOuts "${WW_PLIN}/InCopyWorkflow" "${WW_PLOUT}" "InCopy Bridge UI.InDesignPlugin"
		MoveToPlugOuts "${WW_PLIN}/InCopyWorkflow" "${WW_PLOUT}" "InCopyImport.InDesignPlugin"
		MoveToPlugOuts "${WW_PLIN}/InCopyWorkflow" "${WW_PLOUT}" "Assignment UI.InDesignPlugin"
		MoveToPlugOuts "${WW_PLIN}/InCopyWorkflow" "${WW_PLOUT}" "InCopyExport.InDesignPlugin"
		MoveToPlugOuts "${WW_PLIN}/InCopyWorkflow" "${WW_PLOUT}" "InCopyExportUI.InDesignPlugin"
		MoveToPlugOuts "${WW_PLIN}/InCopyWorkflow" "${WW_PLOUT}" "InCopyWorkflow UI.InDesignPlugin"

	else
		echo -e "${WW_PLIN}/InCopyWorkflow DOES NOT exist\n"
	fi

	# Remove the superfuous files from the 'UI' folder.
	if [ -d "${WW_PLIN}/UI" ]; then

		#echo -e "${WW_PLIN}/UI exists\n"

		MoveToPlugOuts "${WW_PLIN}/UI" "${WW_PLOUT}" "InCopyFileActions.InDesignPlugin"
		MoveToPlugOuts "${WW_PLIN}/UI" "${WW_PLOUT}" "InCopyFileActionsUI.InDesignPlugin"

	else
		echo -e "${WW_PLIN}/UI DOES NOT exist\n"
	fi

	# ------------------------------------------------------------
	# Check if the temporary wwscinsttempcc* folder is present.
	# If so, move it to the Plug-Ins folder.

	WW_TMP_PATH="/${WWSCTEMPFOLDER}"

	if [ -d "${WW_TMP_PATH}"  ]; then
		echo "Copying all ${PRODUCT} CC ${CC_VERSION} plugins to \"${WW_PATH}\". . ."

		# Copy the files for the concerning product.
		CopyPluginsFor "${PRODUCT}" "${WW_PATH}"

		echo "Done"
	fi
	
	echo "WW PATH: ${WW_TMP_PATH}"
	GiveAllRightsToPath "${WW_TMP_PATH}"
	echo ""
	
	# ------------------------------------------------------------
	# Install the Smart Connection Book Support scripts.
	
	# Reset the install path.
	INSTALL_PATH=`dirname "$1"`
	
	# Check if the preceding folder path exists. If not, create them.
	SCRIPT_PANEL_PATH="${INSTALL_PATH}/Scripts/Scripts Panel"

	mkdir -p "${SCRIPT_PANEL_PATH}"
	
	if [ -d "${SCRIPT_PANEL_PATH}" ]; then
		echo "Script panel path exists."
		echo "Installing the Smart Connection Book Suppor scripts."
		echo "Copying '${BASE_PATH}/Smart Connection Book Support' to '${SCRIPT_PANEL_PATH}'"
		
		# Install the Smart Connection Book Support scripts.
		cp -rf "${BASE_PATH}/Smart Connection Book Support" "${SCRIPT_PANEL_PATH}"
		
		echo "Done."
	else
		echo "Script panel path does not exitst."
		echo "We do not install the Smart Connection Book Support scripts."
		#echo "Exiting."
		#return 0
	fi

	# ------------------------------------------------------------
	# Install the uninstaller.app.
	
	# Reset the install path.
	INSTALL_PATH=`dirname "$1"`

	# Find the uninstaller app.
	UN_APP=$(find "${BASE_PATH}/Uninstaller" -maxdepth "1" -iname "Uninstall*.app")
	echo "PATH: ${BASE_PATH}/Uninstaller"
	echo "UNAPP: ${UN_APP}"
	echo -e "INSTALL_PATH: ${INSTALL_PATH}\n"
	
	# Check if the uninstaller exists.
	if [ "${UN_APP}" == "" ]; then
		echo -e "Uninstaller does not exist.\n"
	else
		# Install the Uninstaller for the current prduduct.
		cp -rf "${UN_APP}" "${INSTALL_PATH}"
		
		UNIN_BASENAME=`basename "${UN_APP}"`
		
		# Assign the unique paths for the current product.
		if [ "${PRODUCT}" == "InDesign" ] || [ "{$PRODUCT}" == "InDesignDM" ]; then
			UNINSTALL_APP_PATH_ID="${INSTALL_PATH}/${UNIN_BASENAME}"
		elif [ "${PRODUCT}" == "InCopy" ] || [ "${PRODUCT}" == "InCopyOverset" ]; then
			UNINSTALL_APP_PATH_IC="${INSTALL_PATH}/${UNIN_BASENAME}"
		elif [ "${PRODUCT}" == "InDesignServer" ] || [ "${PRODUCT}" == "InDesignServerDM" ]; then
			UNINSTALL_APP_PATH_IDS="${INSTALL_PATH}/${UNIN_BASENAME}"
		fi
	fi
}

# ---------------------------------------------------------------------------------
# Firstly remove the plugin from destination if present and then copy
# the plugin for the given product.

function RemoveAndCopy()
{
	# The current plugin name to remove and copy.
	TARGET=$1

	# Source path.
	SOURCEPATH=$2

	# Remove and copy the plugin.
	rm -rf "$INSTALL_PATH/${TARGET}"
	rsync -az "${SOURCEPATH}/${TARGET}"			"$INSTALL_PATH"
}

# ---------------------------------------------------------------------------------
# Copy all files for the given product.

function CopyPluginsFor()
{
	local PRODUCT=$1		# The product we have to install all files for.
	local INSTALL_PATH=$2	# Installation path.

	# Default installation path.
	WW_TMP_PATH="/${WWSCTEMPFOLDER}"

	# Copy all plugins and files for the main InDesign product.
	if [ "${PRODUCT}" == "InDesign" ]; then
		RemoveAndCopy "ElementLabel.InDesignPlugin"				"${WW_TMP_PATH}"
		RemoveAndCopy "ElementLabelUI.InDesignPlugin"			"${WW_TMP_PATH}"
		RemoveAndCopy "SCCoreContent.InDesignPlugin"			"${WW_TMP_PATH}"
		RemoveAndCopy "SCCoreDataLink.InDesignPlugin"			"${WW_TMP_PATH}"
		RemoveAndCopy "SCCoreDataLinkUI.InDesignPlugin"			"${WW_TMP_PATH}"
		RemoveAndCopy "SCCoreGeometry.InDesignPlugin"			"${WW_TMP_PATH}"
		RemoveAndCopy "SCCoreInDesign.InDesignPlugin"			"${WW_TMP_PATH}"
		RemoveAndCopy "SCCoreStickyNotes.InDesignPlugin"		"${WW_TMP_PATH}"
		RemoveAndCopy "SCCoreStickyNotesUI.InDesignPlugin"		"${WW_TMP_PATH}"
		RemoveAndCopy "SCCoreTemplate.InDesignPlugin"			"${WW_TMP_PATH}"
		RemoveAndCopy "SCEntAccessUI.InDesignPlugin"			"${WW_TMP_PATH}"
		RemoveAndCopy "SCEntEditioning.InDesignPlugin"			"${WW_TMP_PATH}"
		RemoveAndCopy "SCEntEditioningUI.InDesignPlugin"		"${WW_TMP_PATH}"
		RemoveAndCopy "SCEnterprise.InDesignPlugin"				"${WW_TMP_PATH}"
		RemoveAndCopy "SCEnterpriseUI.InDesignPlugin"			"${WW_TMP_PATH}"
		RemoveAndCopy "SCEntFields.InDesignPlugin"				"${WW_TMP_PATH}"
		RemoveAndCopy "SCEntFieldsUI.InDesignPlugin"			"${WW_TMP_PATH}"
		RemoveAndCopy "SCEntScripting.InDesignPlugin"			"${WW_TMP_PATH}"
		RemoveAndCopy "SCEntWidgets.InDesignPlugin"				"${WW_TMP_PATH}"
		RemoveAndCopy "SCProElementsPanel.InDesignPlugin"		"${WW_TMP_PATH}"
		RemoveAndCopy "SCProFramesInDesign.InDesignPlugin"		"${WW_TMP_PATH}"
		RemoveAndCopy "SCProInDesignUI.InDesignPlugin"			"${WW_TMP_PATH}"
		RemoveAndCopy "SCProPanel.InDesignPlugin"				"${WW_TMP_PATH}"
		RemoveAndCopy "SmartImage.InDesignPlugin"				"${WW_TMP_PATH}"
		RemoveAndCopy "SmartImageUI.InDesignPlugin"				"${WW_TMP_PATH}"
		RemoveAndCopy "SmartJump.InDesignPlugin"				"${WW_TMP_PATH}"
		RemoveAndCopy "SmartJumpInDesignUI.InDesignPlugin"		"${WW_TMP_PATH}"
		RemoveAndCopy "style"									"${WW_TMP_PATH}"
		RemoveAndCopy "WoodWing.InDesignPlugin"					"${WW_TMP_PATH}"
		RemoveAndCopy "WoodWingUI.InDesignPlugin"				"${WW_TMP_PATH}"
		RemoveAndCopy "woodwingui.swf"							"${WW_TMP_PATH}"
		RemoveAndCopy "WoodWingWidgets.InDesignPlugin"			"${WW_TMP_PATH}"
		RemoveAndCopy "StickyNotesPanel_CC${CC_VERSION}.zxp"	"${WW_TMP_PATH}"
	fi

	# Copy all plugins and files for the InDesign Digital Magazine product.
	if [ "${PRODUCT}" == "InDesignDM" ]; then
		RemoveAndCopy "SmartDPSTools.InDesignPlugin"			"${WW_TMP_PATH}"
		RemoveAndCopy "SmartDPSToolsUI.InDesignPlugin"			"${WW_TMP_PATH}"
		RemoveAndCopy "SCEntDMActiveElement.swf"				"${WW_TMP_PATH}"
		RemoveAndCopy "SCEntDMAudio.swf"						"${WW_TMP_PATH}"
		RemoveAndCopy "SCEntDMDossierLink.swf"					"${WW_TMP_PATH}"
		RemoveAndCopy "SCEntDMHotspot.swf"						"${WW_TMP_PATH}"
		RemoveAndCopy "SCEntDMScrollableArea.swf"				"${WW_TMP_PATH}"
		RemoveAndCopy "SCEntDMSlideShow.swf"					"${WW_TMP_PATH}"
		RemoveAndCopy "SCEntDMVideo.swf"						"${WW_TMP_PATH}"
		RemoveAndCopy "SCEntDMWidget.swf"						"${WW_TMP_PATH}"
	fi

	# Copy all plugins and files for the main InCopy product.
	if [ "${PRODUCT}" == "InCopy" ]; then
		RemoveAndCopy "ElementLabel.InDesignPlugin"				"${WW_TMP_PATH}"
		RemoveAndCopy "SCCoreContent.InDesignPlugin"			"${WW_TMP_PATH}"
		RemoveAndCopy "SCCoreDataLink.InDesignPlugin"			"${WW_TMP_PATH}"
		RemoveAndCopy "SCCoreDataLinkUI.InDesignPlugin"			"${WW_TMP_PATH}"
		RemoveAndCopy "SCCoreGeometry.InDesignPlugin"			"${WW_TMP_PATH}"
		RemoveAndCopy "SCCoreInCopy.InDesignPlugin"				"${WW_TMP_PATH}"
		RemoveAndCopy "SCCoreInCopyOverset.InDesignPlugin"		"${WW_TMP_PATH}"
		RemoveAndCopy "SCCoreInCopyUI.InDesignPlugin"			"${WW_TMP_PATH}"
		RemoveAndCopy "SCCoreStickyNotes.InDesignPlugin"		"${WW_TMP_PATH}"
		RemoveAndCopy "SCCoreStickyNotesUI.InDesignPlugin"		"${WW_TMP_PATH}"
		RemoveAndCopy "SCCoreTemplate.InDesignPlugin"			"${WW_TMP_PATH}"
		RemoveAndCopy "SCEntAccessUI.InDesignPlugin"			"${WW_TMP_PATH}"
		RemoveAndCopy "SCEntEditioning.InDesignPlugin"			"${WW_TMP_PATH}"
		RemoveAndCopy "SCEntEditioningUI.InDesignPlugin"		"${WW_TMP_PATH}"
		RemoveAndCopy "SCEnterprise.InDesignPlugin"				"${WW_TMP_PATH}"
		RemoveAndCopy "SCEnterpriseUI.InDesignPlugin"			"${WW_TMP_PATH}"
		RemoveAndCopy "SCEntFields.InDesignPlugin"				"${WW_TMP_PATH}"
		RemoveAndCopy "SCEntFieldsUI.InDesignPlugin"			"${WW_TMP_PATH}"
		RemoveAndCopy "SCEntScripting.InDesignPlugin"			"${WW_TMP_PATH}"
		RemoveAndCopy "SCEntWidgets.InDesignPlugin"				"${WW_TMP_PATH}"
		RemoveAndCopy "SCProFramesInCopy.InDesignPlugin"		"${WW_TMP_PATH}"
		RemoveAndCopy "SCProFramesInCopyUI.InDesignPlugin"		"${WW_TMP_PATH}"
		RemoveAndCopy "SCProInCopyUI.InDesignPlugin"			"${WW_TMP_PATH}"
		RemoveAndCopy "SCProPanel.InDesignPlugin"				"${WW_TMP_PATH}"
		RemoveAndCopy "SmartImage.InDesignPlugin"				"${WW_TMP_PATH}"
		RemoveAndCopy "SmartImageUI.InDesignPlugin"				"${WW_TMP_PATH}"
		RemoveAndCopy "SmartJump.InDesignPlugin"				"${WW_TMP_PATH}"
		RemoveAndCopy "SmartJumpInCopyUI.InDesignPlugin"		"${WW_TMP_PATH}"
		RemoveAndCopy "style"									"${WW_TMP_PATH}"
		RemoveAndCopy "WoodWing.InDesignPlugin"					"${WW_TMP_PATH}"
		RemoveAndCopy "WoodWingUI.InDesignPlugin"				"${WW_TMP_PATH}"
		RemoveAndCopy "woodwingui.swf"							"${WW_TMP_PATH}"
		RemoveAndCopy "WoodWingWidgets.InDesignPlugin"			"${WW_TMP_PATH}"
		RemoveAndCopy "StickyNotesPanel_CC${CC_VERSION}.zxp"	"${WW_TMP_PATH}"
	fi

	# Copy the plugin for the InCopyOverset product.
	if [ "${PRODUCT}" == "InCopyOverset" ]; then
		RemoveAndCopy "SCCoreInCopyOverset.InDesignPlugin"		"${WW_TMP_PATH}"
	fi

	# Copy all the plugins for the InDesign Server product.
	if [ "${PRODUCT}" == "InDesignServer" ]; then
		RemoveAndCopy "ElementLabel.InDesignPlugin"				"${WW_TMP_PATH}"
		RemoveAndCopy "SCCoreContent.InDesignPlugin"			"${WW_TMP_PATH}"
		RemoveAndCopy "SCCoreDataLink.InDesignPlugin"			"${WW_TMP_PATH}"
		RemoveAndCopy "SCCoreGeometry.InDesignPlugin"			"${WW_TMP_PATH}"
		RemoveAndCopy "SCCoreInDesign.InDesignPlugin"			"${WW_TMP_PATH}"
		RemoveAndCopy "SCCoreStickyNotes.InDesignPlugin"		"${WW_TMP_PATH}"
		RemoveAndCopy "SCCoreTemplate.InDesignPlugin"			"${WW_TMP_PATH}"
		RemoveAndCopy "SCEntEditioning.InDesignPlugin"			"${WW_TMP_PATH}"
		RemoveAndCopy "SCEnterprise.InDesignPlugin"				"${WW_TMP_PATH}"
		RemoveAndCopy "SCEntFields.InDesignPlugin"				"${WW_TMP_PATH}"
		RemoveAndCopy "SCEntScripting.InDesignPlugin"			"${WW_TMP_PATH}"
		RemoveAndCopy "SCProFramesInDesign.InDesignPlugin"		"${WW_TMP_PATH}"
		RemoveAndCopy "SmartImage.InDesignPlugin"				"${WW_TMP_PATH}"
		RemoveAndCopy "SmartJump.InDesignPlugin"				"${WW_TMP_PATH}"
		RemoveAndCopy "WoodWing.InDesignPlugin"					"${WW_TMP_PATH}"
	fi

	# Copy all the plugins for the InDesign Server Digital Magazine product.
	if [ "${PRODUCT}" == "InDesignServerDM" ]; then
		RemoveAndCopy "SmartDPSTools.InDesignPlugin"			"${WW_TMP_PATH}"
	fi

	if [ "${PRODUCT}" == "InDesign" ] || [ "$PRODUCT" == "InCopy" ]; then
		SearchAdobeExtensionManagerApplication
		
		if [ "${FOUND_EXTENSIONMANAGER}" != "" ]; then
			"${FOUND_EXTENSIONMANAGER}/Contents/MacOS/ExManCmd" --install "${INSTALL_PATH}/StickyNotesPanel_CC${CC_VERSION}.zxp"
		fi
	fi
}

# ---------------------------------------------------------------------------------
# Remove an installation marker.

function RemoveInstallationMarker()
{
	PRODUCT=$1

	# Remove the instalation marker for the given product.
	rm -rf $BASE_PATH/$PRODUCT.txt
}

# ---------------------------------------------------------------------------------
# Clean-up the remaining temporary files.

function CleanUpTempInstallation()
{
	echo "REMOVING TEMP INSTALLATION FOLDER"
	rm -rf $BASE_PATH
}

# ---------------------------------------------------------------------------------
# Check and/or install the WWSettings.xml and WWActivate.xml files.

function InstallWWXMLFiles()
{
	OLD_PATH="/Library/Preferences"
	NEW_PATH="/Library/Application Support/WoodWing"


	# If the new path already exists...
	if [ -d "$NEW_PATH" ]; then

		# Check if the files exist and otherwise install them.
		if [ ! -f "$NEW_PATH/WWActivate.xml" ]; then
			cp -f "$BASE_PATH/WWActivate.xml" "$NEW_PATH"
		fi
		if [ ! -f "$NEW_PATH/WWSettings.xml" ]; then
			cp -f "$BASE_PATH/WWSettings.xml" "$NEW_PATH"
		fi

	# Else, if the new path does not yet exist...
	else

		# If the old path exists...
		if [ -d "$OLD_PATH/WoodWing" ]; then

			# New directory does not exist. Creat it.
			mkdir "$NEW_PATH"

			# Move the old folder to the folder.
			mv "$OLD_PATH/WoodWing" "$NEW_PATH"

			# Create a symbolic link for the old folder to the new folder.
			ln -s "$NEW_PATH" "$OLD_PATH"

		# Else, if the old path does not exist...
		else

			# New directory does not exist. Creat it.
			mkdir "$NEW_PATH"

			# Check if the files exist and otherwise install them.
			if [ ! -f "$NEW_PATH/WWActivate.xml" ]; then
				cp -f "$BASE_PATH/WWActivate.xml" "$NEW_PATH"
			fi
			if [ ! -f "$NEW_PATH/WWSettings.xml" ]; then
				cp -f "$BASE_PATH/WWSettings.xml" "$NEW_PATH"
			fi

		fi	
	fi
		
	echo -e "Done.\n"
}

# ---------------------------------------------------------------------------------
# Give the given argumented path all rights.

function GiveAllRightsToPath()
{
	chmod -R 777 "$1"
	echo -e "Setting 777 permissions to folder [ $1 ]\n"
}

# ---------------------------------------------------------------------------------
# This function can be called when logging to better oversee the steps done.

function PauseTheScript()
{
	read -p "	>> Press any key to continue... "
	echo ""
}

# ---------------------------------------------------------------------------------
# ---------------------------------------------------------------------------------
# Main script.

# Give all rights to the temporary installation folder and all its content.
GiveAllRightsToPath "${BASE_PATH}"

FindAndInstallForTargets

# Check and/or install the WWSettings.xml and WWActivate.xml files.
InstallWWXMLFiles

# Give all rights to the following paths.
GiveAllRightsToPath "${WW_PATH_ID}"
GiveAllRightsToPath "${WW_PATH_IC}"
GiveAllRightsToPath "${WW_PATH_IDS}"
GiveAllRightsToPath "${WW_PLOUT_ID}"
GiveAllRightsToPath "${WW_PLOUT_IC}"
GiveAllRightsToPath "${WW_PLOUT_IDS}"
GiveAllRightsToPath "${SCRIPT_PANEL_PATH}"
GiveAllRightsToPath "${UNINSTALL_APP_PATH_ID}"
GiveAllRightsToPath "${UNINSTALL_APP_PATH_IC}"
GiveAllRightsToPath "${UNINSTALL_APP_PATH_IDS}"

# If all files are installed for al targets
# remove the temporary installation folder.
rm -rf ${BASE_PATH}

exit 0