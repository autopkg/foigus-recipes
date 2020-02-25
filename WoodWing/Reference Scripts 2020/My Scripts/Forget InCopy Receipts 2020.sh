#!/bin/bash

#List of receipt names to forget
receiptsToForget=( com.woodwing.smartconnectionCC2020.payload.pkg com.woodwing.smartconnectionCC2020.sciccc2020.pkg )

#Forget the receipts in the receiptsToForget array
for receiptName in "${receiptsToForget[@]}"
do
	if pkgutil --pkgs="${receiptName}" > /dev/null 2>&1
	then
		pkgutil --forget "${receiptName}" 
	else
		echo Receipt to remove "${receiptName}" NOT FOUND
	fi
done