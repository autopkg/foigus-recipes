#!/bin/sh

#-------------------------------------------------------------------
#
#  Auxilary functions
#

ID_TMP_FILE="/tmp/gmc-id-plugins"
ID_STAMP_FILE="/tmp/gmc-id-stamp"
ID_CHOOSER="InDesignChooser"
ID_PKGS_COUNT=3


# $1 = bad TMP_FILE error
# $2 = TMP_FILE
# $3 = STAMP_FILE
# $4 = REQUIRED_PKGS_COUNT
# $5 = chooser
TestPlugInsFolder()
{
	if [ -f "$3" ]; then
		# read stamp count
		local stampCount=`cat "$3"`
		if [ $stampCount = "1" ]; then
			# last package - deleting stamp
			rm "$3"
		else
			# decrease stamp count
			echo `expr $stampCount - 1` > "$3"
		fi
		# check whether Plug-Ins folder was correctly set in the first run
		if [ ! -s "$2" ]; then
			echo "You must choose Plug-Ins folder."
			exit $1
		else
			# do not run chooser
			exit 0
		fi
	else
		# create stamp with count - 1
		echo `expr $4 - 1` > "$3"
		# remove TMP_FILE if exists (previous install cancelled)
		rm -f "$2"
	fi
		
	"`dirname "$0"`/"$5".app/Contents/MacOS/$5"
	if [ ! -s "$2" ]; then
		echo "You must choose Plug-Ins folder."
		exit $1
	else
		exit 0
	fi
}

TestInDesignFolder()
{
	TestPlugInsFolder $1 "$ID_TMP_FILE" "$ID_STAMP_FILE" "$ID_PKGS_COUNT" "$ID_CHOOSER"
}
