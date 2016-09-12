#!/bin/bash

#List of receipt names to forget
#The same uninstaller is used for Digital Magazine plugins as is used for the regular
#Smart Connection plugins, so include the Smart Connection receipts in the list to forget
#
#Note there really are package IDs for "woodwingui" and "WoodWingUI"
#Since it appears that pkgutil is case-sensitive and there's no solid way to know which
#receipt is there, remove them both
receiptsToForget=( InDesignDM PluginConfig SCEntDMActiveElement SCEntDMAudio SCEntDMDossierLink SCEntDMHotspot SCEntDMScrollableArea SCEntDMSlideShow SCEntDMVideo SCEntDMWidget SmartDPSTools SmartDPSToolsUI WWActivate WWSettings )

#Forget the single outlier receipt
if pkgutil --pkg-info com.WoodWing.smartconnectioncs5vxyzbuild.Uninstaller.pkg > /dev/null 2>&1
then
	pkgutil --forget com.WoodWing.smartconnectioncs5vxyzbuild.Uninstaller.pkg
else
	echo Receipt to remove com.WoodWing.smartconnectioncs5vxyzbuild.Uninstaller.pkg NOT FOUND
fi

#Forget the receipts in the receiptsToForget array
#Since Woodwing uses version names in the package receipts, need to use a regex to remove all receipts with a particular name
for receiptName in "${receiptsToForget[@]}"
do
	if pkgutil --pkgs=com\\.WoodWing\\.smartConnectionForAdobeCc2015V[\\d]+\\."${receiptName}"\\.pkg > /dev/null 2>&1
	then
		pkgutil --pkgs=com\\.WoodWing\\.smartConnectionForAdobeCc2015V[\\d]+\\."${receiptName}"\\.pkg | tr '\n' '\0' | xargs -n 1 -0 pkgutil --forget 
	else
		echo Receipt to remove com.WoodWing.smartConnectionForAdobeCc2015V\*version\*."${receiptName}".pkg NOT FOUND
	fi
done