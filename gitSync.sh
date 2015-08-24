set -e

###Personal informations (you need to set him):

myGit="https://github.com/lp177/42.git"
#Dir wanted for Sync
dirSync="$HOME/Sync"
#Dir wanted for save config files
dirCfg="$dirSync/Cfg"
#Dir target for temporary storage
tmpSync="$HOME/.gitSync/ExtSync"
#path for gitSync files
gitSyncPath="$HOME/.gitSync"
#interval in second into two auto sync (after launch cmd gitAutoSync)
interval_auto_sync=60


###Routines:

#Command sh execute previous the save on git with gitSync alias (for save various scattered files/folders)
previousSync="
	if [ -d $HOME/.atom ]; then
		rm -rf $dirCfg/.atom
		cp -pXRf $HOME/.atom $dirCfg/.atom
	fi
	if [ -d $HOME/.vim ]; then
		rm -rf $dirCfg/.vim
		cp -pXRf $HOME/.vim $dirCfg/.vim
	fi
	cp $HOME/.vimrc $dirCfg/.
	cp $HOME/.zshrc $dirCfg/.
	cp $gitSyncPath/gitSync.sh $dirCfg/.
	if [ -f $HOME/.z42.sh ]; then
		cp $HOME/.z42.sh $dirCfg/.
		cp $HOME/.start.sh $dirCfg/.
	fi
"

#Command sh execute at the end of alias gitTake
afterTake="$infect"

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
	read -p 'Do you want infect \( the actual cfg is already save \) ?' -n 1 -r
	echo
	if [[ $REPLY =~ ^[Yy]$ ]]
	then
		rm -rf $HOME/.vim
		cp -R $dirCfg/.vim $HOME/.vim
		cat $dirCfg/.vimrc > $HOME/.vimrc
		if [ ! -d $gitSyncPath ]; then
			cp -R $dirCfg/.gitSync > $gitSyncPath
		fi
		cat $dirCfg/.zshrc > $HOME/.zshrc
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
	$uninfect
	rm -rf $tmpSync $dirSync
	source $HOME/.zshrc
"

alias gitSyncUninstall="
	$gitSyncPath/uninstaller $gitSyncPath $dirSync
"

alias gitSync="
	rsync -a --inplace $dirSync/* --delete $tmpSync
	$previousSync
	cd $tmpSync
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

if [ ! -d $dirCfg ]
then
	echo "Create Dir dirCfg at $dirCfg"
	mkdir $dirCfg &> /dev/null
fi

if [ ! -f $gitSyncPath/.cronErsatz ]
then
	echo "source $gitSyncPath/gitSync.sh 2> /dev/null;\`gitAutoSync\`" > $gitSyncPath/cronErsatz
fi

#set +x
###

set +e
