#!/bin/bash
myGit='https://github.com/lp177/42.git'

set -e

###Personal informations (you need to set him):

#Dir wanted for Sync
dirSync="$HOME/Sync"
#Dir wanted for save config files
dirCfg="$dirSync/Cfg"
#Dir target for temporary storage
tmpSync="$HOME/.gitSync/ExtSync"
#Dir tmp for default path when not precise
tmp="$dirSync/.tmp"
#path for gitSync files
gitSyncPath="$HOME/.gitSync"
#Make one save of last archive for configFile/Guest files with _ prefixe.
#Set at 0 for disable
archiver=1
#Path to cp guest config previous infect him
preserveGuest="$dirSync/.preserveGuest"
#interval in second into two auto sync (after launch cmd gitAutoSync)
interval_auto_sync=60

# Target Cfg
favorites="$HOME/.zshrc
$HOME/.vimrc
$HOME/.vim
$HOME/.atom
$HOME/.gitSync
$HOME/.*.sh
"

# Colors
red="\033[0;31m"
green="\033[1;32m"
nc="\033[0m"
###Routines:

#Command sh execute previous the save on git with gitSync alias (for save various scattered files/folders)

function extractItem
{
	if [ -z "$1" ] ||  ( [ ! -f "$1" ] && [ ! -d "$1" ] ); then
		return 0
	fi

	local -i target="$(basename $1)"
	
	if [ -z "$2" ]
	then
		local -i $saveFolder="$tmp"
	else
		local -i $saveFolder="$2"
	fi
	
	if [ $archiver -eq 1 ] && ( [ -f "$saveFolder/$target" ] || [ -d "$saveFolder/$target" ] )
	then
		cp -R "$saveFolder/$target" "$saveFolder/_$target"
	fi
	if [ -f "$1" ]
	then
		cat "$1" > "$saveFolder/$target"
	elif [ -d "$1" ]
	then
		if [ -d "$saveFolder/$target" ]
		then
			echo "Rsync $1"
			rsync -a "$1/"/ --delete --exclude '.git' "$saveFolder/$target/"
		else
			echo "Cp $1"
			cp -R "$1" "$saveFolder/$target"
		fi
	else
		cp "$1" > "$saveFolder/$target"
	fi
}
function saveMyCfg
{
	for conf in $favorites
	do
		extractItem "$conf" "$dirCfg"
	done
}
function getCfg
{
	for conf in $favorites
	do
		extractItem "$dirCfg/$(basename $conf)" "$HOME"
	done
}
function extractGuest
{
	for conf in $favorites
	do
		extractItem "$conf" "$preserveGuest"
	done
}
# Reinitialise configuration of guest from $preserveGuest folder
function uninfect
{
	echo 'Do you want uninfect ?\n'
	read -p 'Reset guest cfg in $preserveGuest folder (y/n):' -n 1 -r
	echo
	if [[ "$REPLY" =~ ^[Yy]$ ]]
	then
		for conf in $favorites
		do
			extractItem "$preserveGuest/$(basename $conf)" "$HOME"
		done
	fi
}
# Load your cfg on guest device and preserve guest cfg in $preserveGuest folder
function infect
{
	echo 'Do you want infect ?\n'
	read -p 'Get your cfg on guest and preserve guest cfg in $preserveGuest folder (y/n):' -n 1 -r
	echo
	if [[ "$REPLY" =~ ^[Yy]$ ]]
	then
		extractGuest
		getCfg
		source "$HOME/.zshrc"
	fi
}

function updateRemote
{
	cd $tmpSync
	find */ -name .git | sed 's/\/\//\//' | xargs git rm -rf --ignore-unmatch
	find */ -name .git | sed 's/\/\//\//' | xargs rm -rf
	rm -rf .git
	git init
	git remote add origin $myGit
	git add ./*
	git commit -am 'Update `date`'
	git push -f origin master
	cd -
}

###

###Alias:

alias gitSync="
	echo 'In progress...'
	saveMyCfg
	rsync -a $dirSync/ --delete --exclude '.git' $tmpSync/
	updateRemote
"

#Launch auto gitSync all interval_auto_sync seconde(s) (not require cron)
alias gitSyncAuto="
	echo \"Start at: \";date;echo \"\n\"
	gitSync
	echo \"\n\nEnd at: \"
	date
	echo \"Pending next interval ...   ($((interval_auto_sync / 60))mn)\"
	sleep $interval_auto_sync
	clear
	source $gitSyncPath/cronErsatz
"

#Get your git depot to local $dirSync
# /!\ Delete the holdest $dirSync & $tmpSync path given at the top of this file
alias gitSyncTake="
	rm -rf $tmpSync $dirSync
	git clone $myGit $tmpSync
	cp -R $tmpSync $dirSync
	rm -rf $dirSync/.git
	infect
"

#/!\ Delete all trace of gitSync
alias gitSyncClean="
	uninfect
	ssh-keygen -R $myGit
	rm -rf $HOME/.ssh/known_hosts.old
	$uninfect
	rm -rf $tmpSync $dirSync
	gitSyncUninstall
	exit
"
# Uninstaller
alias gitSyncUninstall="
	$gitSyncPath/uninstaller $gitSyncPath $dirSync
"

###

###Create busy files if necessary

#set -x

function createFolder
{
	if [ -z "$1" ] || [ -d "$1" ]; then
		return 0
	fi
	mkdir $1# &> /dev/null
	if [ -d $1 ]; then
		echo "$green Create Dir $(basename $1) at $1$nc"
	else
		echo "$red Fail to create Dir $(basename $1) at $1$nc"
	fi
}

createFolder $dirSync
createFolder $tmpSync
createFolder $dirCfg
createFolder $preserveGuest
createFolder $tmp

if [ ! -f $gitSyncPath/cronErsatz ]
then
	echo "source $gitSyncPath/gitSync.sh 2> /dev/null;\`gitAutoSync\`" > $gitSyncPath/cronErsatz
	if [ -f $1 ]; then
		echo "$green Create cronErsatz at $gitSyncPath/cronErsatz$nc"
	else
		echo "$red Fail to create cronErsatz at $gitSyncPath/cronErsatz$nc"
	fi
fi

#set +x
###

set +e
