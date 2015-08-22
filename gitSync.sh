set -e

###Personal informations (you need to set him):

myGit="https://github.com/[MyGitPseudo]/[My repo].git"
#Dir wanted for Sync
dirSync="$HOME/Sync"
#Dir target for temporary storage
tmpSync="$HOME/ExtSync"
#interval in second into two auto sync (after launch cmd gitAutoSync)
interval_auto_sync=60

path_conf_sublime="$MAC_HOME/Library/Application\ Support/Sublime\ Text\ 3/Packages/User/Preferences.sublime-settings"

###

###Routines:

#Command sh execute previous the save on git (for save various scattered files)
previousSync="
	cp $path_conf_sublime $dirSync/.
	cp -pXRf ~/.vim $dirSync/vim;
	cp ~/.zshrc $dirSync/zshrc;
	cp ~/.vimrc $dirSync/vimrc;
	cp ~/.cronErsatz $dirSync/cronErsatz
	cp ~/.gitSync.sh $dirSync/gitSync
	cp ~/.z42.sh $dirSync/z42.sh
	cp ~/.start.sh $dirSync/start.sh
"
preserveHolder="
	cat ~/gitSync.sh > $dirSync/_gitSync.sh
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
#	cat $dirSync/gitSync.sh > ~/gitSync.sh
#	source ~/.zshrc
#"

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
	cat $dirSync/_gitSync.sh > ~/gitSync.sh
	cat $dirSync/_zshrc > ~/.zshrc
	cat $dirSync/_vimrc > ~/.vimrc
	rm -rf ~/.vim
	cp -R $dirSync/_vim ~/.vim
	cat $dirSync/_Preferences.sublime-settings > $path_conf_sublime
	rm -rf $tmpSync $dirSync
	source ~/.zshrc
"

alias gitSyncUninstall="
	read -p "Do you want rm `$dirSync` ? " -n 1 -r
	echo
	if [[ $REPLY =~ ^[Yy]$ ]]
	then
		rm -rf $dirSync
	fi
	rm -rf ~/.cronErsatz $tmpSync ~/.gitSync
"

alias gitSync="
	cd $tmpSync;
	rsync -ar $dirSync/* --delete $tmpSync;
	$previousSync;
	find */ -name .git | sed 's/\/\//\//' | xargs git rm -rf --ignore-unmatch;
	find */ -name .git | sed 's/\/\//\//' | xargs rm -rf;
	git add ./*;git commit -am 'Update `date`';git push origin master;cd -
"

#alias gs="gitSync"

#Rm all & push
alias gitReset="
	cd $tmpSync;
	git pull;
	git pull origin master;
	git pull;
	git commit -am \"reset\";
	git push origin master;
	git rm -rf *;rm -rf *;
	git push origin master;
	cd -;
	gitSync
"

#Launch auto gitSync all interval_auto_sync seconde(s) (not require cron)
alias gitAutoSync="
	echo \"Start at: \";date;echo \"\n\";
	gitSync;
	echo \"\n\nEnd at: \";date;
	echo \"Pending next interval ...   ($((interval_auto_sync / 60))mn)\";
	sleep $interval_auto_sync;
	clear;
	source ~/.cronErsatz
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

if [ ! -f $HOME/.cronErsatz ]
then
	echo "source $HOME/.gitSync.sh 2> /dev/null;\`gitAutoSync\`" > $HOME/.cronErsatz
fi

#set +x
###

set +e
