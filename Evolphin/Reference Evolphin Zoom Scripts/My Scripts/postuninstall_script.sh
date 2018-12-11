#!/bin/bash

pathToDelete="/Applications/Evolphin"
receiptName="com.evolphin.zoom.pkg"

if [ -d "${pathToDelete}" ]
then
	rm -rf "${pathToDelete}"
fi

if `pkgutil --pkgs="${receiptName}" 2>&1 > /dev/null`
then
	pkgutil --forget "${receiptName}"
fi