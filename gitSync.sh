#Dir wanted for Sync
dirSync="Sync"
#Dir target for temporary storage
tmpSync="ExtSync"
#Command sh execute previous the push

previousSync="
cp -R ~/.vim ~/$dirSync/vim;
cp ~/.zshrc ~/$dirSync/zshrc;
cp ~/.vimrc ~/$dirSync/vimrc;
cp ~/cron_ersatz_177 ~/$dirSync"
#interval in second into two auto sync (after launch cmd gitAutoSync)
interval_auto_sync=60

mkdir ~/$dirSync ~/$tmpSync &> /dev/null
cd ~/$tmpSync
git init &> /dev/null && git remote add origin $myGit &> /dev/null
cd -

alias gs="gitSync"
alias gitTake="
rm -rf ~/$tmpSync ~/$dirSync;git clone $myGit ~/$tmpSync;
cp -R ~/$tmpSync ~/$dirSync;
rm -rf ~/$dirSync/.git"
alias gitSync="
cd ~/$tmpSync;
$previousSync;
rsync -r ~/$dirSync/* --delete ~/$tmpSync;
find */ -name .git | sed 's/\/\//\//' | xargs git rm -rf --ignore-unmatch;
find */ -name .git | sed 's/\/\//\//' | xargs rm -rf;
git add ./*;git commit -am 'Update `date`';git push origin master;cd -"

#Rm all & push
alias gitReset="
cd ~/$tmpSync;
git pull;
git pull origin master;
git pull;
git commit -am \"reset\";
git push origin master;
git rm -rf *;rm -rf *;
git push origin master;
cd -;
gitSync"

#Launch auto gitSync all interval_auto_sync seconde(s) (not require cron)
alias gitAutoSync="
	echo \"Start at: \";date;echo \"\n\";
	gitSync;
	echo \"\n\nEnd at: \";date;
	echo \"Pending next interval ...   ($((interval_auto_sync / 60))mn)\";
	sleep $interval_auto_sync;
	clear;
	source ~/cron_ersatz_177
"
#Create ersatz of cron
echo "source $HOME/gitSync.sh 2> /dev/null;\`gitAutoSync\`" > $HOME/cronErsatz
