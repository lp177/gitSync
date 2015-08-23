#!/bin/bash
set -e

###Personal informations (you need to set him):

myGit="https://github.com/lp177/42.git"
#Dir wanted for Sync
dirSync="$HOME/Sync"
#Dir target for temporary storage
tmpSync="$HOME/.gitSync/ExtSync"
#path for gitSync files
gitSyncPath="$HOME/.gitSync"
#interval in second into two auto sync (after launch cmd gitAutoSync)
interval_auto_sync=60

#declare -a arr=("$MAC_HOME" "/Library/Application\ Support/Sublime\ Text\ 3/Packages/User/Preferences.sublime-settings")

whotest[1]='test' || (echo 'Failure: arrays not supported in this version of bash.' && exit 2)

# $for_cp[0]="$MAC_HOME"
# $for_cp[0]+='/Library/Application\ Support/Sublime\ Text\ 3/Packages/User/Preferences.sublime-settings'
# $for_cp[1]=$MAC_HOME
# $for_cp[4]+='/.atom/'
for_cp[3]='~/.vim'
for_cp[2]='~/.vimrc'
for_cp[1]='~/.zshrc'
# $for_cp[5]=$gitSyncPath/gitSync.sh
for_cp[5]='~/.z42.sh'
for_cp[4]='~/.start.sh'
###

###Routines:

#Command sh execute previous the save on git (for save various scattered files)
previousSync="

	$i = 0;

	echo \"My array have ${#for_cp[@]} cases\"

	for list_for_cp in \"${for_cp[@]}\"
	do
		if [[ \"$i\" -eq 0 ]]; then;
			echo 'intercept';
			$i += $i;
			echo 'next';
			continue
		fi
		echo \"Foreach on $list_for_cp\"

		if [ -d "$list_for_cp" ]; then
			cp "$list_for_cp" $dirSync/.
		elif [ -f "$list_for_cp" ]; then
			cp -pXRf "$list_for_cp" $dirSync/.
		else
			echo \"$list_for_cp not found\"
		fi
	done
"
preserveHolder="
	cat $gitSyncPath/gitSync.sh > $dirSync/_gitSync.sh
	cat ~/.zshrc > $dirSync/_zshrc
	cat ~/.vimrc > $dirSync/_vimrc
	rm -rf $dirSync/_vim
	cp -R ~/.vim $dirSync/_vim
"
#	cat $path_conf_sublime/Preferences.Sublime-settings > $dirSync/_Preferences.sublime-settings

#Command sh execute after the repatriation (for load automaticaly you remote conf for exemple, empty by default)
afterTake=""
#	$preserveHolder
#	rm -rf ~/.vim
#	cp -R $dirSync/vim ~/.vim
#	cat $dirSync/vimrc > ~/.vimrc
#	cat $dirSync/zshrc > ~/.zshrc
#	cat $dirSync/gitSync.sh > $gitSyncPath/gitSync.sh
#	source ~/.zshrc
#"

updateRemote="
	cd $tmpSync
	git remote rm origin
	git remote add origin $myGit
	cd -
"

###

###Alias:

#Repatriation of your git depot to local $dirSync
alias gitTake="
	rm -rf $tmpSync $dirSync
	git clone $myGit $tmpSync
	cp -R $tmpSync $dirSync
	rm -rf $dirSync/.git
	$afterTake
"

alias gitClean="
	ssh-keygen -R $myGit
	rm -rf ~/.ssh/known_hosts.old
	cat $dirSync/_gitSync.sh > $gitSyncPath/gitSync.sh
	cat $dirSync/_zshrc > ~/.zshrc
	cat $dirSync/_vimrc > ~/.vimrc
	rm -rf ~/.vim
	cp -R $dirSync/_vim ~/.vim
	cat $dirSync/_Preferences.sublime-settings > $path_conf_sublime
	rm -rf $tmpSync $dirSync
	source ~/.zshrc
"

alias gitSyncUninstall="
	$gitSyncPath/uninstaller $gitSyncPath $dirSync
"

alias gitSync="
	# cd $tmpSync
	# rsync -ar $dirSync/* --delete $tmpSync
	$previousSync
	# find */ -name .git | sed 's/\/\//\//' | xargs git rm -rf --ignore-unmatch
	# find */ -name .git | sed 's/\/\//\//' | xargs rm -rf
	# $updateRemote
	# git add ./*
	# git commit -am 'Update `date`'
	# git push -f origin master
	# cd -
"

#alias gs="gitSync"

#Rm all & push
alias gitReset="
	cd $tmpSync
	git pull
	git pull origin master
	git pull
	git commit -am \"reset\"
	git push origin master
	git rm -rf *;rm -rf *
	git push origin master
	cd -
	gitSync
"

#Launch auto gitSync all interval_auto_sync seconde(s) (not require cron)
alias gitAutoSync="
	echo \"Start at: \";date;echo \"\n\"
	gitSync
	echo \"\n\nEnd at: \"
	date
	echo \"Pending next interval ...   ($((interval_auto_sync / 60))mn)\"
	sleep $interval_auto_sync
	clear
	source $gitSyncPath/cronErsatz
"

###

###Create busy files if necessary

#set -x

if [ ! -d $dirSync ]
then
	echo "Create Dir Sync at $dirSync"
	mkdir $dirSync &> /dev/null
fi

if [ ! -d $tmpSync ]
then
	echo "Create Dir tmpSync at $tmpSync"
	mkdir $tmpSync &> /dev/null
	cd $tmpSync
	git init &> /dev/null && git remote add origin $myGit &> /dev/null
	cd -
fi

if [ ! -f $gitSyncPath/.cronErsatz ]
then
	echo "source $gitSyncPath/gitSync.sh 2> /dev/null;\`gitAutoSync\`" > $gitSyncPath/cronErsatz
fi

#set +x
###

set +e
