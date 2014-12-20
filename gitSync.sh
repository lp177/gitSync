#Url of my repository
myGit="https://github.com/myID/Mygit.git"

#Dir wanted for Sync (From ~)
dirSync="Sync"

#Dir target for temporary storage (From ~)
tmpSync="ExtSync"

#Command sh execute previous the push
previousSync="cp ~/.zshrc ~/$tmpSync/;cp ~/.vimrc ~/$tmpSync/;git add -f .vimrc .zshrc"

#Dir wanted for Sync
dirSync="Sync"
#Dir target for temporary storage
tmpSync="ExtSync"
#interval in second into two auto sync (after launch cmd gitAutoSync)
interval_auto_sync="600"
#Command sh execute previous the push (gitSync)
previousSync="cp -R ~/.vim ~/$tmpSync/vim;cp ~/.zshrc ~/$tmpSync/zshrc;cp ~/.vimrc ~/$tmpSync/vimrc;git add -f vimrc zshrc;cp ~/cron_GitSync_177 ~/$tmpSync"
#Command sh execute after the incoming clone (gitTake)
afterTake="ls $dirSync;"
#Expl of auoload config with afterTake:
#"chmod 755 ~/.zshrc ~/.vimrc;cat ~/$dirSync/zshrc > ~/.zshrc;cat ~/$dirSync/vimrc > ~/.vimrc"

echo "gitAutoSync" > ~/cron_GitSync_177
mkdir ~/$dirSync ~/$tmpSync &> /dev/null
cd ~/$tmpSync
git init &> /dev/null && git remote add origin $myGit &> /dev/null
cd -

#New stuff? and you haven't your local files for sync or just an duty obsolet copy ? Take your git with gitTake guy!
alias gitTake="rm -rf ~/$tmpSync ~/$dirSync;git clone $myGit ~/$tmpSync;cp -R ~/$tmpSync ~/$dirSync;rm -rf ~/$dirSync/.git;$afterTake;"
alias Sync177="cd ~/$tmpSync;diff -qr ~/$dirSync ~/$tmpSync | grep 'Only.*$tmpSync' | sed 's/Only.*$tmpSync: //' | sed '/.git/d' | xargs git rm -rf --ignore-unmatch;rsync -r ~/$dirSync/* --delete ~/$tmpSync;find */ -name .git | sed 's/\/\//\//' | xargs git rm -rf;find */ -name .git | sed 's/\/\//\//' | xargs rm -rf;$previousSync;git add ./*;git commit -am 'Update `date`';git push origin master;cd -"
alias gitSync="Sync177;Sync177"

#short cmd
#alias gs="gitSync"

#Any problem with a ***lovely merge requiered and other infamous thougs?
#Rm all & push
alias gitReset="cd ~/$tmpSync;git pull;git pull origin master;git pull;git commit -am \"reset\";git push origin master;git rm -rf *;rm -rf *;git push origin master;cd -;gitSync"
#Git reset is the power to impose the respect of your repository at the scope of all, use this warm with abuse

#Launch auto gitSync all interval_auto_sync seconde(s) (not require cron)
alias gitAutoSync="clear;echo \"Start at: \";date;echo \"\n\";gitSync;echo \"\n\nEnd at: \";date;echo -n \"Pending next interval...\";sleep $interval_auto_sync;source ~/cron_GitSync_177"
