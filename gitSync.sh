#Edit for point on your server/repository
myGit="https://github.com/[MyGitPseudo]/[MyRepository].git"
#Dir wanted for Sync
dirSync="~/Sync"
#Dir target for temporary storage
tmpSync="~/ExtSync"
#interval in second into two auto sync (after launch cmd gitAutoSync)
interval_auto_sync=60

#Command sh execute previous the save on git (for save various scattered files)
previousSync="
	cp ~/.zshrc $dirSync/zshrc;
	cp ~/.vimrc $dirSync/vimrc;
	cp ~/.cronErsatz $dirSync
	cp ~/.gitSync.sh $dirSync
"
#For not erease directly specifics files
preserveHolder="
	cat ~/gitSync.sh > $dirSync/_gitSync.sh
	cat ~/.zshrc > $dirSync/_zshrc
	cat ~/.vimrc > $dirSync/_vimrc
	rm -rf $dirSync/_vim
"
#Command sh execute after the repatriation (for load automaticaly you remote conf for exemple, empty by default)
afterTake=""
#"$preserveHolder
#	cat $dirSync/vimrc > ~/.vimrc
#	cat $dirSync/zshrc > ~/.zshrc
#	cat $dirSync/.gitSync.sh > ~/.gitSync.sh
#	source ~/.zshrc
#"

#Repatriation of your git repository to local $dirSync
alias gitTake="
	rm -rf $tmpSync $dirSync
	git clone $myGit $tmpSync
	cp -R $tmpSync $dirSync
	rm -rf $dirSync/.git
"
#Removes all SSH keys and busy directories $dirSync/$tmpSync
alias gitClean="
	ssh-keygen -R $myGit
	rm -rf ~/.ssh/known_hosts.old
	rm -rf $tmpSync $dirSync
"
#Save your Sync directory
alias gitSync="
	cd $tmpSync;
	$previousSync;
	rsync -lrv $dirSync/* --delete $tmpSync;
	find */ -name .git | sed 's/\/\//\//' | xargs git rm -rvf --ignore-unmatch;
	find */ -name .git | sed 's/\/\//\//' | xargs rm -rfv;
	git add ./*;git commit -am 'Update `date`';git push origin master;cd -
"
#Rm all & push (alternative for push -f)
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
alias gs="gitSync"

#Create busy dirs/files if necessary

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
	echo "Create Dir tmpSync at $tmpSync"
	echo "source $HOME/.gitSync.sh 2> /dev/null;\`gitAutoSync\`" > $HOME/.cronErsatz
fi
