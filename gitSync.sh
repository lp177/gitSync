myGit="https://github.com/lp177/42.git"

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

# Colors
red=\033[0;31m
green=\033[1;32m
nc=\033[0m
###Routines:

#Command sh execute previous the save on git with gitSync alias (for save various scattered files/folders)

function extractFile
{
	if [ ! -z "$1" ] || [ ! -f "$1" ]; then
		return 0
	fi
	
	local -i target=$(basename "$1")
	
	if [ ! -z "$2" ]
		local -i $saveFolder="$dirSync/$tmp"
	else
		local -i $saveFolder="$dirSync/$2"
	fi
	
	if [ $archiver -eq 1 ] && [ -f "$saveFolder/$target" ]
	then
		mv "$saveFolder/$target" "$saveFolder/_$target"
	fi
	cat "$1" > "$saveFolder/$target"
}
function extractFolder
{
	if [ ! -z "$1" ] || [ ! -d "$1" ]; then
		return 0
	fi
	
	local -i target=$(basename "$1")

	if [ ! -z "$2" ]
		local -i $saveFolder="$dirSync/$tmp"
	else
		local -i $saveFolder="$dirSync/$2"
	fi

	if [ $archiver -eq 1 ] && [ -d "$saveFolder/$target" ]
	then
		cp -R "$saveFolder/$target" "$saveFolder/_$target"
		rsync -a "$1"/ --delete "$saveFolder/$target/"
	else
		rm -rf "$saveFolder/$target"
		cp -R "$1" "$saveFolder/$target"
	fi
}
function getFile
{
	if [ ! -z "$1" ] || [ ! -f "$1" ]; then
		return 0
	fi
	
	local -i target=$(basename "$1")

	if [ ! -z "$2" ]
		local -i $saveFolder="$HOME"
	else
		local -i $saveFolder="$2"
	fi

	cat "$1" > "$saveFolder/$target"
}
function getFolder
{
	if [ ! -z "$1" ] || [ ! -d "$1" ]; then
		return 0
	fi
	
	local -i target=$(basename "$1")

	if [ ! -z "$2" ]
		local -i $saveFolder="$HOME"
	else
		local -i $saveFolder="$2"
	fi

	if [ -d "$saveFolder/$target" ]
	then
		rsync -a "$1"/ --delete "$saveFolder/$target/"
	else
		cp -R "$1" "$saveFolder/$target"
	fi
}
function extractGuest
{
	local -i target=$(basename "$preserveGuest")

	extractFile "$HOME/.zshrc" "$target"
	extractFile "$HOME/.vimrc" "$target"
	extractFolder "$HOME/.vim" "$target"
	extractFolder "$HOME/.atom" "$target"
}
function saveMyCfg
{
	extractFile "$HOME/.zshrc" "Cfg"
	extractFile "$HOME/.vimrc" "Cfg"
	extractFile "$HOME/gitSync.sh" "Cfg"
	extractFolder "$HOME/.vim" "Cfg"
	extractFolder "$HOME/.atom" "Cfg"
	extractFile "$HOME/.*.sh" "Cfg"
}
function getCfg
{
	getFile "$HOME/.zshrc"
	getFile "$HOME/.vimrc"
	getFile "$HOME/gitSync.sh"
	getFolder "$HOME/.vim"
	getFolder "$HOME/.atom"
	getFile "$HOME/.*.sh"
}

#Command sh execute at the end of alias gitTake
afterTake="$infect"

uninfect="
	if [ -d $dirSync/.preserveGuest ]
	then
		cat $dirSync/.preserveGuest/.zshrc > $HOME/.zshrc
		cat $dirSync/.preserveGuest/.vimrc > $HOME/.vimrc
		if [ -d $HOME/.vim ]
		then
			rsync -a $dirSync/.preserveGuest/.vim/ --delete $HOME/.vim/
		else
			rm -rf $HOME/.vim
			cp -R $dirSync/.preserveGuest/.vim $HOME/.vim
		fi
	fi
"
#get your cfg on lambda device in preserve all switched files
infect="
	read -p 'Do you want infect \( the actual cfg is already save \) ?' -n 1 -r
	echo
	if [[ $REPLY =~ ^[Yy]$ ]]
	then
	
		extractGuest
		source $HOME/.zshrc
	fi
"
#For use always the given $myGit path
updateRemote="
	cd $tmpSync
	git remote rm origin
	git remote add origin $myGit
	cd -
"
connectRemote="
	cd $tmpSync
	rm -rf .git
	git init
	git remote add origin $myGit
	cd -
"

###

###Alias:

alias gitSync="
	saveCfg
	rsync -a $dirSync/ --delete $tmpSync/
	cd $tmpSync
	find */ -name .git | sed 's/\/\//\//' | xargs git rm -rf --ignore-unmatch
	find */ -name .git | sed 's/\/\//\//' | xargs rm -rf
	$connectRemote
	git add ./*
	git commit -am 'Update `date`'
	git push -f origin master
	cd -
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
	$afterTake
"

#/!\ Delete all trace of gitSync
alias gitSyncClean="
	ssh-keygen -R $myGit
	rm -rf $HOME/.ssh/known_hosts.old
	$uninfect
	rm -rf $tmpSync $dirSync
	exit
"

alias gitSyncUninstall="
	$gitSyncPath/uninstaller $gitSyncPath $dirSync
"

###

###Create busy files if necessary

#set -x

function createDir
{
	if [ ! -z "$1" ] || [ ! -d "$1" ]; then
		return 0
	fi
	mkdir $1 &> /dev/null
	if [ -d $1 ]; then
		echo "$green Create Dir $(basename $1) at $1$nc"
	else
		echo "$red Fail to create Dir $(basename $1) at $1$nc"
	fi
}

createDir $dirSync
createDir $tmpSync
createDir $dirCfg
createDir $preserveGuest
createDir $tmp

if [ ! -f $gitSyncPath/.cronErsatz ]
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
