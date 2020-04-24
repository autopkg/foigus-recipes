#!/bin/bash

#This is essentially the technique used in "Uninstall Zoom.app", minus tolerance for
#installations outside of the default location
zoomInstallPath="/Applications/Evolphin"
zoomUninstallScriptRelativePath="zoom/Resources/bin/uninstall"

#If the uninstaller exists
if [ -x "${zoomInstallPath}/${zoomUninstallScriptRelativePath}" ]
then
	#Go ahead and uninstall
	cd "${zoomInstallPath}"
	sh "${zoomUninstallScriptRelativePath}" `pwd`/zoom true true /var/log/install.log
else
	#The uninstaller does not exist, exit with an error
	exit 1
fi