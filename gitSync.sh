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


###Routines:

#Command sh execute previous the save on git with gitSync alias (for save various scattered files/folders)
previousSync="
	cp -R $gitSyncPath $dirSync/.
	cp -pXRf $HOME/.atom $dirSync/.
	cp -pXRf $HOME/.vim $dirSync/.
	cp $HOME/.vimrc $dirSync/.
	cp $HOME/.zshrc $dirSync/.
	cp $HOME/.z42.sh $dirSync/.
	cp $HOME/.start.sh $dirSync/.
"

#Command sh execute at the end of alias gitTake
afterTake=""

#swapper of cfg
preserveHolder="
	mkdir $dirSync/.preserveHolder
	cat $HOME/.zshrc > $dirSync/.preserveHolder/.zshrc
	cat $HOME/.vimrc > $dirSync/.preserveHolder/.vimrc
	rm -rf $dirSync/.preserveHolder/.vim
	cp -R $HOME/.vim $dirSync/.preserveHolder/.vim
"
getHolder="
	if [ -d $dirSync/.preserveHolder ]
	then
		cat $dirSync/.preserveHolder/.zshrc > $HOME/.zshrc
		cat $dirSync/.preserveHolder/.vimrc > $HOME/.vimrc
		rm -rf $HOME/.vim
		cp -R $dirSync/.preserveHolder/.vim $HOME/.vim
	fi
"
#get your cfg on lambda device in preserve all switched files
infect="
	$preserveHolder
	read -p "Do you want infect \( the actual cfg is already save \) ?" -n 1 -r
	echo
	if [[ $REPLY =~ ^[Yy]$ ]]
	then
		rm -rf $HOME/.vim
		cp -R $dirSync/.vim $HOME/.vim
		cat $dirSync/.vimrc > $HOME/.vimrc
		if [ ! -d $gitSyncPath ]; then
			cp -R $dirSync/.gitSync > $gitSyncPath
		fi
		cat $dirSync/.zshrc > $HOME/.zshrc
		source $HOME/.zshrc
	fi
"
uninfect="
	$getHolder
"
#For use always the given $myGit path
updateRemote="
	cd $tmpSync
	git remote rm origin
	git remote add origin $myGit
	cd -
"

###

###Alias:

#Get your git depot to local $dirSync
# /!\ Delete the holdest $dirSync & $tmpSync path given at the top of this file
alias gitTake="
	rm -rf $tmpSync $dirSync
	git clone $myGit $tmpSync
	cp -R $tmpSync $dirSync
	rm -rf $dirSync/.git
	$afterTake
"

alias gitClean="
	ssh-keygen -R $myGit
	rm -rf $HOME/.ssh/known_hosts.old
	cat $dirSync/_gitSync.sh > $gitSyncPath/gitSync.sh
	cat $dirSync/_zshrc > $HOME/.zshrc
	cat $dirSync/_vimrc > $HOME/.vimrc
	rm -rf $HOME/.vim
	cp -R $dirSync/_vim $HOME/.vim
	cat $dirSync/_Preferences.sublime-settings > $path_conf_sublime
	rm -rf $tmpSync $dirSync
	source $HOME/.zshrc
"

alias gitSyncUninstall="
	$gitSyncPath/uninstaller $gitSyncPath $dirSync
"

alias gitSync="
	cd $tmpSync
	rsync -ar $dirSync/* --delete $tmpSync
	$previousSync
	find */ -name .git | sed 's/\/\//\//' | xargs git rm -rf --ignore-unmatch
	find */ -name .git | sed 's/\/\//\//' | xargs rm -rf
	$updateRemote
	git add ./*
	git commit -am 'Update `date`'
	git push -f origin master
	cd -
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
